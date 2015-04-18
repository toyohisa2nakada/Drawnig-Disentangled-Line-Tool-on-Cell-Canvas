class Point{
  public Point(){}
  public Point(int x,int y){
    this.x = x;
    this.y = y;
  }
  public Point(Point p){
    this(p.x,p.y);
  }
  @Override boolean equals(Object o){
    if(o instanceof Point){
      Point p = (Point)o;
      return p.x==this.x && p.y==this.y;
    }
    return false;
  }
  int x;
  int y;
}
class PointF {
  float x;
  float y;
  public PointF(float x,float y){
    this.x = x;
    this.y = y;
  }
  @Override boolean equals(Object o){
    if(o instanceof PointF){
      PointF p = (PointF)o;
      return this.x==p.x && this.y==p.y;
    }
    return false;
  }
}
boolean drawingIntersects = false;
int cell_width = 25;
int cell_height= 25;
int margin = 10;
int[][] map = new int[20][20];
Point playerIndex;
Disentangle disentangle;
HashMap<Integer,Integer> colors = new HashMap<Integer,Integer>();
PApplet theApplet;

void reset(){
  playerIndex = new Point(9,18);
  disentangle = new Disentangle();
  disentangle.add(playerIndex.x,playerIndex.y);
}
void setup(){
  size(600,600);
  theApplet = this;
  cell_width = (width-2*margin)/map[0].length;
  cell_height = (height-2*margin)/map.length;
  reset();
}
Point index2Pos(int index_x,int index_y){
  return new Point(index_x*cell_width+margin,index_y*cell_height+margin);
}
PointF index2Pos(float index_x,float index_y){
  return new PointF(index_x*cell_width+margin,index_y*cell_height+margin);
}
Point index2Pos(Point index){
  return index2Pos(index.x,index.y);
}
color getLineColor(int id){
  Integer i = colors.get(id);
  if(i == null){
    i = new Integer(color(random(128,255),random(28,50),random(28,50)));
    colors.put(id,i);
  }
  return color(i);
}
void draw(){
  background(224);
  strokeWeight(1);
  stroke(0);
  noFill();
  for(int y=0;y<map.length;y++){
    for(int x=0;x<map[y].length;x++){
      Point pos = index2Pos(x,y);
      rect(pos.x,pos.y,cell_width,cell_height);
    }
  }
  ellipseMode(CENTER);
  strokeWeight(3);
  stroke(disentangle.linesSize()==0?
    0:
    getLineColor(disentangle.getLastLineId()),
    128*(sin((frameCount/20f)%TWO_PI)+1));
  Point playerPos = index2Pos(playerIndex);
  ellipse(playerPos.x+cell_width/2,playerPos.y+cell_height/2,
    cell_width/2,cell_height/2);
  
  disentangle.linesForEach(new DisentangleForEachInterface(){
    @Override public void line(Disentangle.Line l){
      if(l.endPoint != null){
        PointF p0 = index2Pos(l.getStartPointF().x,l.getStartPointF().y);
        PointF p1 = index2Pos(l.getEndPointF().x,l.getEndPointF().y);
        p0.x += cell_width/2;
        p0.y += cell_height/2;
        p1.x += cell_width/2;
        p1.y += cell_height/2;
  
        stroke(getLineColor(l.id));
        strokeWeight(2);
        theApplet.line(p0.x,p0.y,p1.x,p1.y);
        
        strokeWeight(1);
        fill(getLineColor(l.id));
        triangle(p1.x,p1.y,
          l.xy==0?p1.x-8*l.getDirection():p1.x-3,l.xy==0?p1.y-3:p1.y-8*l.getDirection(),
          l.xy==0?p1.x-8*l.getDirection():p1.x+3,l.xy==0?p1.y+3:p1.y-8*l.getDirection());
      }
    }
  });
  if(drawingIntersects){
    disentangle.intersectionsForEach(new DisentangleForEachInterface(){
      @Override public void intersection(Disentangle.Intersection i){
        for(int cnt=0;cnt<i.parts.size();cnt++){
          Point p0 = index2Pos(i.parts.get(cnt).getMinX(),i.parts.get(cnt).getMinY());
          Point p1 = index2Pos(i.parts.get(cnt).getMaxX(),i.parts.get(cnt).getMaxY());
          p0.x += cell_width/2;
          p0.y += cell_height/2;
          p1.x += cell_width/2;
          p1.y += cell_height/2;
          stroke(0,255,0);
          strokeWeight(2);
          theApplet.line(p0.x,p0.y,p1.x,p1.y);
        }
      }
    });
  }
}
void keyPressed(){
  if(key==CODED){
    Point backup = new Point(playerIndex);
    switch(keyCode){
    case UP:
      playerIndex.y = playerIndex.y==0?0:playerIndex.y-1;
      break;
    case DOWN:
      playerIndex.y = playerIndex.y==map.length-1?map.length-1:playerIndex.y+1;
      break;
    case LEFT:
      playerIndex.x = playerIndex.x==0?0:playerIndex.x-1;
      break;
    case RIGHT:
      playerIndex.x = playerIndex.x==map[playerIndex.y].length-1?map[playerIndex.y].length-1:playerIndex.x+1;
      break;
    }
    if(playerIndex.equals(backup)==false){
      disentangle.add(playerIndex.x,playerIndex.y);
    }
  }else{
    switch(key){
    case 'r':
      reset();
      break;
    case 'i':
      drawingIntersects = !drawingIntersects;
      break;
    }
  }
}
