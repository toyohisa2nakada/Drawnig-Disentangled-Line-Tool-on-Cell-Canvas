import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Collections;

// Drawing disentangled Line tool
//
//  canvas environment
//    A line is a connector between cells. A cell has 2D area and the connecting
//    line can start from and end to any positions in the area.
//
//  problem
//    Looking for the graph that has smallest cross points.
//
//  sollution
//    1. find overlaped lines, the found lines become a set which members are lines.
//    2. construct superset of all sets found in the previous procedure.
//    3. count up branches crossing at right angles.
//    4. move line position to the direction having many crossing lines
//
//  restriction
//    Overlaped lines having same directions are drawn on the same position because
//    loop path is supported in this tool. In a loop path lines are drawing many
//    times, therefore if the each positions are changed, many lines are shown and
//    it is not cleared to understand.
//

/** interface for forEach methods. */
class DisentangleForEachInterface{
  public void line(Disentangle.Line l){}
  public void intersection(Disentangle.Intersection i){}
}
/** drawing disentangled line tool class */
public class Disentangle{
  /** integer based 2D point class */
  private class Point{
    private int x;
    private int y;
    public Point(int x,int y){
      this.x = x;
      this.y = y;
    }
    @Override public boolean equals(Object o){
      if(o instanceof Point){
        Point p = (Point)o;
        return this.x==p.x && this.y==p.y;
      }
      return false;
    }
    public boolean equals(int x,int y){
      return this.x==x && this.y==y;
    }
  }
  /** float based 2D point class */
  private class PointF{
    private float x;
    private float y;
    public PointF(Point p){
      this.x = p.x;
      this.y = p.y;
    }
    public PointF(float x,float y){
      this.x = x;
      this.y = y;
    }
    @Override public boolean equals(Object o){
      if(o instanceof PointF){
        PointF p = (PointF)o;
        return this.x==p.x && this.y==p.y;
      }
      return false;
    }
  }
  /** line class for represents individual line by created add method and intersections */
  public class Line{
    // 0: value means y (horizontal line)
    // 1: value means x (vertical line)
    private int xy = -1;
    private int value;
    // slide is used for no overlap
    private float slide = 0;
    // identification of the line
    private int id = -1;

    private int max = Integer.MIN_VALUE;
    private int min = Integer.MAX_VALUE;
    private Point startPoint;
    private Point endPoint;
    private Line previousLine;
    private Line followingLine;
    @Override public boolean equals(Object o){
      if(o instanceof Line){
        Line l = (Line)o;
        return this.xy==l.xy && this.value==l.value && this.max==l.max && this.min==l.min &&
          this.startPoint.equals(l.startPoint) && this.endPoint.equals(l.endPoint);
      }
      return false;
    }
    public Line(int x,int y,int id){
      startPoint = new Point(x,y);
      this.id = id;
    }
    public Line(Point p,int id){
      this(p.x,p.y,id);
    }
    public Line(int xy,int value,int max,int min){
      this.xy = xy;
      this.value = value;
      this.max = max;
      this.min = min;
    }
    public void setPreviousLine(Line l){
      this.previousLine = l;
    }
    public void setFollowingLine(Line l){
      this.followingLine = l;
    }
    public int getDirection(){
      return xy==0?((endPoint.x-startPoint.x)>0?1:-1):((endPoint.y-startPoint.y)>0?1:-1);
    }
    public Point getStartPoint(){
      return startPoint;
    }
    public Point getEndPoint(){
      return endPoint;
    }
    private PointF slidedPointF(Point p){
      PointF pf = new PointF(p);
      pf.x += this.xy==0?0:this.slide;
      pf.y += this.xy==0?this.slide:0;
      return pf;
    }
    private PointF fetchedPointF(PointF p,Line tag,boolean tagStartPoint){
      if(tag!=null && tag.xy!=this.xy){
        PointF p2 = tag.slidedPointF(tagStartPoint?tag.getStartPoint():tag.getEndPoint());
        p.x = this.xy==0?p2.x:p.x;
        p.y = this.xy==0?p.y :p2.y;
      }
      return p;
    }
    public PointF getStartPointF(){
      return fetchedPointF(slidedPointF(startPoint),this.previousLine,false);
    }
    public PointF getEndPointF(){
      return fetchedPointF(slidedPointF(endPoint),this.followingLine,true);
    }
    public int hasVerticalBranch(int x,int y){
      if(isOnline(x,y)){
        if(startPoint.equals(x,y) && previousLine!=null){
          return previousLine.xy==this.xy?0:
            previousLine.getDirection()*-1;
        }else if(endPoint.equals(x,y) && followingLine!=null){
          return followingLine.xy==this.xy?0:
            followingLine.getDirection();
        }
        return 0;
      }
      return 0;
    }
    public int getMinX(){
      return xy==0?min:value;
    }
    public int getMaxX(){
      return xy==0?max:value;
    }
    public int getMinY(){
      return xy==1?min:value;
    }
    public int getMaxY(){
      return xy==1?max:value;
    }
    public boolean isOnline(int x,int y){
      return xy==0?
        (y==this.value&&x>=this.min&&x<=this.max):
        (x==this.value&&y>=this.min&&y<=this.max);
    }
    public boolean isNextPoint(int x,int y){
      if(xy==-1){
        if(this.startPoint.x==x){
          return this.startPoint.y==y-1 || this.startPoint.y==y+1;
        }else if(this.startPoint.y==y){
          return this.startPoint.x==x-1 || this.startPoint.x==x+1;
        }
        return false;
      }else{
        if(xy == 0){
          return this.endPoint.x==(this.endPoint.x-this.startPoint.x>0?x-1:x+1);
        }else{
          return this.endPoint.y==(this.endPoint.y-this.startPoint.y>0?y-1:y+1);
        }
      }
    }
    private void setMaxMin(int x,int y){
      int v = xy==0?x:y;
      max = Math.max(max,v);
      min = Math.min(min,v);
    }
    public void extend(int x,int y){
      endPoint = new Point(x,y);
      if(xy==-1){
        value = x==startPoint.x?x:y;
        xy = x==startPoint.x?1:0;
        setMaxMin(startPoint.x,startPoint.y);
      }
      setMaxMin(x,y);
    }
    private boolean isOverlap(Line l){
      if(this.xy==l.xy && this.value==l.value){
        int bmax = this.max>=l.max ? l.max : this.max;
        int amin = this.max>=l.max ? this.min : l.min;
        return bmax>amin;
      }
      return false;
    }
    private boolean isSameDirection(Line l){
      return this.xy==l.xy &&
        this.xy==0?
          ((this.endPoint.x-this.startPoint.x)*(l.endPoint.x-l.startPoint.x)>0):
          ((this.endPoint.y-this.startPoint.y)*(l.endPoint.y-l.startPoint.y)>0);
    }
    private Intersection intersection(Line l){
      if(true==isOverlap(l)){
        return new Intersection(new Line(this.xy,this.value,Math.min(this.max,l.max),Math.max(this.min,l.min)),new Line[]{this,l});
      }
      return null;
    }
  }
  /** class for managing intersections that have lines of intersection and overlaped lines whose name in this class is member */
  public class Intersection{
    private ArrayList<Line> parts = new ArrayList<Line>();
    private ArrayList<Line> members = new ArrayList<Line>();
    public Intersection(Line l,Line[] members){
      this.parts.add(l);
      Collections.addAll(this.members,members);
    }
    private boolean exactContains(ArrayList l,Object o){
      for(Object t : l){
        if(t == o){
          return true;
        }
      }
      return false;
    }
    public void addAll(ArrayList<Line> parts,ArrayList<Line> members){
      this.parts.addAll(parts);
      for(Line l : members){
        if(exactContains(this.members,l)==false){
          this.members.add(l);
        }
      }
    }
    public boolean hasSameMember(Intersection i){
      ArrayList<Line> small = this.members.size()<=i.members.size()?this.members:i.members;
      ArrayList<Line> large = this.members.size()<=i.members.size()?i.members:this.members;
      for(Line l : small){
        if(true == large.contains(l)){
          return true;
        }
      }
      return false;
    }
  }
  
  /** lines created by add method and this tool tries to become disentangled lines of these.*/
  private ArrayList<Line> lines = new ArrayList<Line>();
  /** intersections */
  private ArrayList<Intersection> intersections = new ArrayList<Intersection>();
  /** parameter of slide range. if some lines are overlaped, those lines move based on this value. */
  private float slidedValue = 0.12f;

  public void linesForEach(DisentangleForEachInterface f){
    for(Line l : lines){
      f.line(l);
    }
  }
  public void intersectionsForEach(DisentangleForEachInterface f){
    for(Intersection i : intersections){
      f.intersection(i);
    }
  }
  public int linesSize(){
    return lines.size();
  }
  public int getLineId(int index){
    if(index >= 0 && index < lines.size()){
      return lines.get(index).id;
    }
    return -1;
  }
  public int getLastLineId(){
    if(lines.size()==0){
      return -1;
    }
    return lines.get(lines.size()-1).id;
  }
  public int intersectionsSize(){
    return intersections.size();
  }
  public void clear(){
    lines.clear();
    intersections.clear();
  }
  private float setSlidedValue(float v){
    this.slidedValue = v;
    return this.slidedValue;
  }  
  private void adjustLines(){
    for(Intersection is : intersections){
      HashMap<Integer,Integer> directions = new HashMap<Integer,Integer>();
      for(Line line : is.members){
        for(Line part : is.parts){
          int x0 = part.getMinX();
          int y0 = part.getMinY();
          int x1 = part.getMaxX();
          int y1 = part.getMaxY();
          
          int d = line.hasVerticalBranch(x0,y0);
          d += line.hasVerticalBranch(x1,y1);
          
          Integer direct = new Integer(line.getDirection());
          Integer sum = directions.get(direct);
          sum = new Integer(d+(sum==null?0:sum.intValue()));
          directions.put(direct,sum);
        }
      }
      if(directions.size()==2){
        int dm = directions.get(new Integer(-1));
        int dp = directions.get(new Integer(1));
        for(Line line : is.members){
          line.slide = (dm<dp?slidedValue:-slidedValue)*line.getDirection();
        }
      }
    }
  }
  private void findIntersection(){
    intersections.clear();
    for(int cnt1=0;cnt1<lines.size()-1;cnt1++){
      Line l1 = lines.get(cnt1);
      for(int cnt2=cnt1+1;cnt2<lines.size();cnt2++){
        Line l2 = lines.get(cnt2);
        Intersection i = l1.intersection(l2);
        if(i != null){
          intersections.add(i);
        }
      }
    }

    // merge intersections
    for(int icnt=0;icnt<intersections.size();icnt++){
      ArrayList<Intersection> toChecks = new ArrayList<Intersection>();
      toChecks.add(intersections.get(icnt));
      while(toChecks.size()!=0){
        Intersection seed = toChecks.get(0);
        toChecks.remove(0);
        for(int icnt2=icnt+1;icnt2<intersections.size();icnt2++){
          Intersection tocheck = intersections.get(icnt2);
          if(seed.hasSameMember(tocheck)){
            seed.addAll(tocheck.parts,tocheck.members);
            toChecks.add(tocheck);
            intersections.remove(icnt2);
            icnt2--;
          }
        }
      }
    }
  }
  public void add(int x,int y){
    if(lines.size()==0){
      lines.add(new Line(x,y,lines.size()+1));
    }else{
      Line l = lines.get(lines.size()-1);
      if(l.isNextPoint(x,y)==true){
        l.extend(x,y);
      }else{
        Line l2 = new Line(l.endPoint,lines.size()+1);
        l.setFollowingLine(l2);
        l2.setPreviousLine(l);
        l2.extend(x,y);
        lines.add(l2);
      }
    }
    findIntersection();
    adjustLines();
  }
}

