// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.10:Tennis (Classes)

include Win32

define hINSTANCE 0x400000
define className 'Strannik'

define RedColor 0x0000FF
define BlueColor 0xFF0000
define GreenColor 0x00FF00

define width 3

//------------------------ element ------------------------------

class element {
private:
  int x,y;
  int oldX,oldY;
  uint color;
public:
  void Initial(int ini_x, int ini_y, uint ini_color);
  int GetX();
  int GetY();
  int GetOldX();
  int GetOldY();
  int GetColor();
  void Move(int mov_x, int mov_y);
}

void element::Initial(int ini_x, int ini_y, uint ini_color)
{
  x=ini_x;
  y=ini_y;
  oldX=ini_x;
  oldY=ini_y;
  color=ini_color;
}

int element::GetX() {return x;}
int element::GetY() {return y;}
int element::GetOldX() {return oldX;}
int element::GetOldY() {return oldY;}
int element::GetColor() {return color;}

void element::Move(int mov_x, int mov_y)
{
  oldX=x;
  oldY=y;
  x+=mov_x;
  y+=mov_y;
}

//------------------------ region ------------------------------

class region:element {
private:
  int sizeX,sizeY;
public:
  void InitialRegion(int ini_x,int ini_y,int ini_sizeX,int ini_sizeY,uint ini_color);
  int GetSizeX()
  int GetSizeY()
  virtual void Paint(HDC dc, COLORREF back);
}

void region::InitialRegion(int ini_x,int ini_y,int ini_sizeX,int ini_sizeY,uint ini_color)
{
  this.Initial(ini_x,ini_y,ini_color);
  sizeX=ini_sizeX;
  sizeY=ini_sizeY;
}

int region::GetSizeX() {return sizeX;}
int region::GetSizeY() {return sizeY;}

void region::Paint(HDC dc, COLORREF back)
{
HPEN pen,oldpen; int colorBound,carX,carY; HBRUSH brush,oldbrush;

  if(back==0) {colorBound=this.GetColor(); carX=this.GetX(); carY=this.GetY();}
  else {colorBound=back; carX=this.GetOldX(); carY=this.GetOldY();}
  pen=CreatePen(PS_SOLID,width,colorBound); oldpen=SelectObject(dc,pen);
  brush=CreateSolidBrush(colorBound); oldbrush=SelectObject(dc,brush);
  Rectangle(dc,carX,carY,carX+sizeX,carY+sizeY);
  SelectObject(dc,oldpen); DeleteObject(pen);
  SelectObject(dc,oldbrush); DeleteObject(brush);
}

//------------------------ sphere ------------------------------

class sphere:element {
private:
  int diameter;
  int speedX,speedY;
public:
  void InitialSphere(int ini_x,int ini_y,int ini_speedX,int ini_speedY,int ini_diameter,uint ini_color);
  virtual void Paint(HDC dc, COLORREF back);
  bool MoveSphere(HWND wnd, region block,region screen);
}

void sphere::InitialSphere(int ini_x,int ini_y,int ini_speedX,int ini_speedY,int ini_diameter,uint ini_color)
{
  this.Initial(ini_x,ini_y,ini_color);
  diameter=ini_diameter;
  speedX=ini_speedX;
  speedY=ini_speedY;
}

void sphere::Paint(HDC dc, COLORREF back)
{
HPEN pen,oldpen; HBRUSH brush,oldbrush; int colorSphere,carX,carY;

  if(back==0) {colorSphere=this.GetColor(); carX=this.GetX(); carY=this.GetY();}
  else {colorSphere=back; carX=this.GetOldX(); carY=this.GetOldY();}
  pen=CreatePen(PS_SOLID,1,colorSphere); oldpen=SelectObject(dc,pen);
  brush=CreateSolidBrush(colorSphere); oldbrush=SelectObject(dc,brush);
  Ellipse(dc,carX-diameter/2,carY-diameter/2,carX+diameter/2,carY+diameter/2);
  SelectObject(dc,oldpen); DeleteObject(pen);
  SelectObject(dc,oldbrush); DeleteObject(brush);
}

bool sphere::MoveSphere(HWND wnd, region block,region screen)
{
int newX,newY;

  newX=this.GetX();
  newY=this.GetY();
  newX+=speedX; //move sphere
  newY+=speedY;
  if((newY>screen.GetSizeY())&&(  //test on contact with block
    (newX<block.GetX())||
    (newX>block.GetX()+block.GetSizeX())))
    return true;
  if(newX<0) {newX=-newX; speedX=-speedX;} //test on out of screen bound's
  if(newY<0) {newY=-newY; speedY=-speedY;}
  if(newX>screen.GetSizeX()) {newX=screen.GetSizeX()-(newX-screen.GetSizeX()); speedX=-speedX;}
  if(newY>screen.GetSizeY()) {newY=screen.GetSizeY()-(newY-screen.GetSizeY()); speedY=-speedY;}
  if(newX<0) {newX=-newX; speedX=-speedX;} //second test on out of screen bound's
  if(newY<0) {newY=-newY; speedY=-speedY;}
  if(newX>screen.GetSizeX()) {newX=screen.GetSizeX()-(newX-screen.GetSizeX()); speedX=-speedX;}
  if(newY>screen.GetSizeY()) {newY=screen.GetSizeY()-(newY-screen.GetSizeY()); speedY=-speedY;}
  this.Move(newX-this.GetX(),newY-this.GetY());
  return false;
}

//------------------------ main ------------------------------

  sphere ball;
  region block,screen;
  bool screenPaint;

bool wndProc(HWND wnd,uint msg,uint wparam,uint lparam)
{
HDC dc; PAINTSTRUCT stru; RECT reg;

  switch(msg) {
    case WM_CREATE:
      GetClientRect(wnd,reg);
      screen=new region; screen.InitialRegion(0,0,reg.right-1,reg.bottom-1,GreenColor);
      block=new region; block.InitialRegion(screen.GetSizeX()/2,screen.GetSizeY()-width,screen.GetSizeX()/10,width,RedColor);
      ball=new sphere; ball.InitialSphere(screen.GetSizeX()/2,1,5,25,10,BlueColor);
      screenPaint=false;
      SetTimer(wnd,1,100,NULL);
      return true;
      break;
    case WM_PAINT:
      dc=BeginPaint(wnd,stru);
      if(!screenPaint) {
        screen.Paint(dc,0);
        screenPaint=true;
      }
      ball.Paint(dc,screen.color);
      ball.Paint(dc,0);
      block.Paint(dc,screen.color);
      block.Paint(dc,0);
      EndPaint(wnd,stru);
      break;
    case WM_ERASEBKGND:return true; break;
    case WM_KEYDOWN:switch(loword(wparam)) {
      case VK_LEFT:
        if(block.GetX()>0) {
          block.Move(-block.GetSizeX()/2,0);
          InvalidateRect(wnd,NULL,true);
          UpdateWindow(wnd);
        }
        break;
      case VK_RIGHT:
        if(block.GetX()+block.GetSizeX()<screen.GetSizeX()) {
          block.Move(block.GetSizeX()/2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd);
        }
        break;
      }
      break;
    case WM_TIMER:
      if(ball.MoveSphere(wnd,block,screen)) {
        KillTimer(wnd,1);
        MessageBox(0,"You lost.","Attention:",MB_ICONSTOP);
        DestroyWindow(wnd);
      }
      InvalidateRect(wnd,NULL,true);
      UpdateWindow(wnd);
      break;
    case WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

  WNDCLASS cla;
  HWND wnd;
  MSG message;

void main()
{
//class registration
  with(cla) {
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=&wndProc;
    cbClsExtra=0;
    cbWndExtra=0;
    hInstance=hINSTANCE;    
    hIcon=0;
    hCursor=LoadCursor(0,pchar(IDC_ARROW));
    hbrBackground=COLOR_WINDOW;
    lpszMenuName=NULL;
    lpszClassName=className;
  }
  RegisterClass(cla);
                     
//create window
  wnd=CreateWindowEx(0,className,'Demo1_10',WS_OVERLAPPEDWINDOW,
    100,100,500,400, 0,0,hINSTANCE,NULL);

  ShowWindow(wnd,SW_SHOW);
  UpdateWindow(wnd);

//messages loop
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }

}

