import processing.sound.*;
SoundFile main;
SoundFile eat;
SoundFile game_over;
int[][] board = new int[25][19];
Area2D[] snake = new Area2D[25 * 19]; // maximal snake length;
int apple_x, apple_y;
Area2D apple;
String dir = "";
String limit_dir = "";
enum States{MOVE, STOP}
int score = 0;
States state = States.STOP;

void setup(){
  main = new SoundFile(this, "sound\\theme.mp3");
  eat = new SoundFile(this, "sound\\apple.mp3");
  game_over = new SoundFile(this, "sound\\game_over.mp3");
  size(800, 608);
  fill(255, 0, 0);
  frameRate(10);
  main.loop();
  snake[0] = new Area2D(12 * 32, 11 * 32, 32, 32);
  snake[1] = new Area2D(12 * 32, 10 * 32, 32, 32);
  snake[2] = new Area2D(12 * 32, 9 * 32, 32, 32);
  snake[3] = new Area2D(12 * 32, 8 * 32, 32, 32);
  snake[4] = new Area2D(12 * 32, 7 * 32, 32, 32);
  for(int i = 0; i < 25; i++){
    for(int j = 0; j < 19; j++){
      board[i][j] = -1;
    }
  }
  apple_x = int(random(0, 25)) * 32;
  apple_y = int(random(0, 19)) * 32;
  apple = new Area2D(apple_x, apple_y, 32, 32);
  board[apple_x / 32][apple_y / 32] = 0;
}

void draw(){
  draw_board();
  drawApple();
  draw_snake();
  updateBoard();
  check_colliding_apple();
  if(isInBoard(snake[0]))
    listen();
  move(dir);
  check_dead();
  if(state != States.STOP)follow();
  checkBorder();  
}

public void draw_board(){
  fill(255);
  for(int i = 0; i < 25; i++){
    for(int j = 0; j < 19; j++){
      rect(i * 32, j * 32, 32, 32);
    }
  }
}

public void draw_snake(){
  fill(255, 0, 0);
  for(Area2D temp : snake){
    if(temp != null)
      rect(temp.getX(), temp.getY(), temp.getWidth(), temp.getLength());
    else
      break;
  }
}

public void listen(){
    if(keyCode == RIGHT && !limit_dir.equals("right")){
    dir = "right";
    limit_dir = "left";
  }
    else if(keyCode == LEFT && !limit_dir.equals("left")){
    dir = "left";
    limit_dir = "right";
  }
    else if(keyCode == UP && !limit_dir.equals("up")){
    dir = "up";
    limit_dir = "down";
  }
    else if(keyCode == DOWN && !limit_dir.equals("down")){
    dir = "down";
    limit_dir = "up";
  }
}

public void move(String _dir){
  snake[0].setLastCoords(new float[]{snake[0].getX(), snake[0].getY()});
  if(_dir.equals("right")){
    snake[0].setX(snake[0].getX() + 32);
  }
  else if(_dir.equals("left")){
   snake[0].setX(snake[0].getX() - 32);
  }
  else if(_dir.equals("up")){
   snake[0].setY(snake[0].getY() - 32);
  }
  else if(_dir.equals("down")){
   snake[0].setY(snake[0].getY() + 32);
  }
}

public void follow(){
  for(int i = 1; i < snake.length; i++){
    if(snake[i] != null){
      snake[i].setLastCoords(new float[]{snake[i].getX(), snake[i].getY()});
      snake[i].move(snake[i - 1].getLastCoords());
    }
    else
      break;
  }
}

void keyPressed(){
  state = States.MOVE;
}

public void checkBorder(){
  if(snake[0].getX() > 25 * 32)
    snake[0].setX(0);
  else if(snake[0].getX() < 0)
    snake[0].setX(25 * 32);
  else if(snake[0].getY() > 19 * 32)
    snake[0].setY(0);
  else if(snake[0].getY() < 0)
    snake[0].setY(19 * 32);
}

public boolean isInBoard(Area2D temp){
  if(temp.getX() >= 25 * 32 || temp.getX() < 0 || 
     temp.getY() >= 19 * 32 || temp.getY() < 0){return false;}
  return true;
}

public void updateBoard(){
  for(Area2D temp : snake){
    if(temp != null && isInBoard(temp)){
      board[int(temp.getX() / 32)][int(temp.getY() / 32)] = 1;
    }
    else
      break;
  }
}

public void check_colliding_apple(){
  if(snake[0].getX() == apple_x && snake[0].getY() == apple_y){
    board[toGrid(apple_x)][toGrid(apple_y)] = -1;
    score += 10;
    eat.play();
    add_tail();
  }
}

public void add_tail(){
  for(int i = 1; i < snake.length; i++){
    if(snake[i] == null){
      snake[i] = new Area2D(snake[i - 1].getLastCoords()[0], snake[i - 1].getLastCoords()[1],
                            32, 32);
      return;
    }
  }
}
public void drawApple(){
  fill(51, 255, 255);
  
  if(appleNotExist()){
    apple_x = int(random(0, 25)) * 32;
    apple_y = int(random(0, 19)) * 32;
    apple.setX(apple_x);
    apple.setY(apple_y);
  }
  board[toGrid(apple_x)][toGrid(apple_y)] = 0;
  rect(apple.getX(), apple.getY(), 32, 32);
}

public boolean appleNotExist(){
  for(int i = 0; i < 25; i++){
    for(int j = 0; j < 19; j++){
      if(board[i][j] == 0)
        return false;
    }
  } 
  return true;
}

public void check_dead(){
  for(int i = 1; i < snake.length; i++){
    if(snake[i] != null){
      if(snake[0].getX() == snake[i].getX() && snake[0].getY() == snake[i].getY())
        {kill(); state = States.STOP;}
    }
  }
}

public void kill(){
  dir = "";
  limit_dir = "";
  main.stop();
  game_over.play();
  noLoop();
  textSize(64);
  fill(0);
  text("Du bist tot", 100, 100);
  text("Score: " + str(score), 100, 400);
}
public int toGrid(float num){
  return int(num / 32);
}

public void showBoard(){
  for(int i = 0; i < 25; i++){
    for(int j = 0; j < 19; j++){
      print(board[i][j]);
    }
    println();
  } 
}
class Area2D{
  private float x;
  private float y;
  private float _width;
  private float _length;
  private float[] lastCoords = new float[2];
  
  public Area2D(float x, float y, float _width, float _length){
    this.x = x;
    this.y = y;
    this._width = _width;
    this._length = _length;
    lastCoords[0] = x;
    lastCoords[1] = y;
  }
  
  public float[] getCoords(){
    return new float[]{x, y};
  }
  
  public float[] getLastCoords(){
    return lastCoords;
  }
  
  public void setLastCoords(float[] lastCoords){
    this.lastCoords = lastCoords;
  }
  
  public float getArea(){
    return _width * _length;
  }
  
  public float getX(){
    return x;
  }
  
  public float getY(){
    return y;
  }
  
  public void move(float[] coords){
      setX(coords[0]);
      setY(coords[1]);
  }
  public void setX(float x){
    this.x = x;
  }
  
  public void setY(float y){
    this.y = y;
  }
  
  public float getWidth(){
    return _width;
  }
  
  public float getLength(){
    return _length;
  }
}
