// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 10:Tennis (Classes)

module Demo1_10;
import Win32;

const 
  hINSTANCE=0x400000;
  className='Strannik';

  RedColor=0x0000FF;
  BlueColor=0xFF0000;
  GreenColor=0x00FF00;

  width=3;

//------------------------ element ------------------------------

type element=record ()
    x,y:integer;
    oldX,oldY:integer;
    color:cardinal;
    procedure Initial*(ini_x,ini_y:integer; ini_color:cardinal);
    procedure GetX*():integer;
    procedure GetY*():integer;
    procedure GetOldX*():integer;
    procedure GetOldY*():integer;
    procedure GetColor*():integer;
    procedure Move*(mov_x,mov_y:integer);
  end;

procedure (element) Initial(ini_x,ini_y:integer; ini_color:cardinal);
begin
  x:=ini_x;
  y:=ini_y;
  oldX:=ini_x;
  oldY:=ini_y;
  color:=ini_color;
end Initial;

procedure (element) GetX():integer; begin return x end GetX;
procedure (element) GetY():integer; begin return y end GetY;
procedure (element) GetOldX():integer; begin return oldX end GetOldX;
procedure (element) GetOldY():integer; begin return oldY end GetOldY;
procedure (element) GetColor():integer; begin return color end GetColor;

procedure (element) Move(mov_x,mov_y:integer);
begin
  oldX:=x;
  oldY:=y;
  inc(x,mov_x);
  inc(y,mov_y);
end Move;

//------------------------ region ------------------------------

type region=record (element)
    sizeX,sizeY:integer;
  end;

procedure (region) InitialRegion(ini_x,ini_y,ini_sizeX,ini_sizeY:integer; ini_color:cardinal);
begin
  self.Initial(ini_x,ini_y,ini_color);
  sizeX:=ini_sizeX;
  sizeY:=ini_sizeY;
end InitialRegion;

procedure (region) GetSizeX*():integer; begin return sizeX end GetSizeX;
procedure (region) GetSizeY*():integer; begin return sizeY end GetSizeY;

procedure (region) Paint(dc:HDC; back:COLORREF);
var pen,oldpen:HPEN; colorBound,carX,carY:integer; brush,oldbrush:HBRUSH;
begin
  if back=0
    then colorBound:=self.GetColor(); carX:=self.GetX(); carY:=self.GetY();
    else colorBound:=back; carX:=self.GetOldX(); carY:=self.GetOldY();
  end;
  pen:=CreatePen(PS_SOLID,width,colorBound); oldpen:=SelectObject(dc,pen);
  brush:=CreateSolidBrush(colorBound); oldbrush:=SelectObject(dc,brush);
  Rectangle(dc,carX,carY,carX+sizeX,carY+sizeY);
  SelectObject(dc,oldpen); DeleteObject(pen);
  SelectObject(dc,oldbrush); DeleteObject(brush);
end Paint;

//------------------------ sphere ------------------------------

type sphere=record (element)
    diameter:integer;
    speedX,speedY:integer;
  end;

procedure (sphere) InitialSphere(ini_x,ini_y,ini_speedX,ini_speedY,ini_diameter:integer; ini_color:cardinal);
begin
  self.Initial(ini_x,ini_y,ini_color);
  diameter:=ini_diameter;
  speedX:=ini_speedX;
  speedY:=ini_speedY;
end InitialSphere;

procedure (sphere) Paint(dc:HDC; back:COLORREF);
var pen,oldpen:HPEN; brush,oldbrush:HBRUSH; colorSphere,carX,carY:integer;
begin
  if back=0
    then colorSphere:=self.GetColor(); carX:=self.GetX(); carY:=self.GetY();
    else colorSphere:=back; carX:=self.GetOldX(); carY:=self.GetOldY();
  end;
  pen:=CreatePen(PS_SOLID,1,colorSphere); oldpen:=SelectObject(dc,pen);
  brush:=CreateSolidBrush(colorSphere); oldbrush:=SelectObject(dc,brush);
  Ellipse(dc,carX-diameter div 2,carY-diameter div 2,carX+diameter div 2,carY+diameter div 2);
  SelectObject(dc,oldpen); DeleteObject(pen);
  SelectObject(dc,oldbrush); DeleteObject(brush);
end Paint;

procedure (sphere) MoveSphere(wnd:HWND; block,screen:region):boolean;
var newX,newY:integer;
begin
  newX:=self.GetX();
  newY:=self.GetY();
  inc(newX,speedX); //moving sphere
  inc(newY,speedY);
  if (newY>screen.GetSizeY())and(  //test on contact with block
    (newX<block.GetX())or
    (newX>block.GetX()+block.GetSizeX())) then
    return true
  end;
  if newX<0 then newX:=-newX; speedX:=-speedX end; //test on out to screen bound's
  if newY<0 then newY:=-newY; speedY:=-speedY end;
  if newX>screen.GetSizeX() then newX:=screen.GetSizeX()-(newX-screen.GetSizeX()); speedX:=-speedX end;
  if newY>screen.GetSizeY() then newY:=screen.GetSizeY()-(newY-screen.GetSizeY()); speedY:=-speedY end;
  if newX<0 then newX:=-newX; speedX:=-speedX end; //second test on out to screen bound's
  if newY<0 then newY:=-newY; speedY:=-speedY end;
  if newX>screen.GetSizeX() then newX:=screen.GetSizeX()-(newX-screen.GetSizeX()); speedX:=-speedX end;
  if newY>screen.GetSizeY() then newY:=screen.GetSizeY()-(newY-screen.GetSizeY()); speedY:=-speedY end;
  self.Move(newX-self.GetX(),newY-self.GetY());
  return false
end MoveSphere;

//------------------------ main ------------------------------

var
  ball:sphere;
  block,screen:region;
  screenPaint:boolean;

procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var dc:HDC; stru:PAINTSTRUCT; reg:RECT;
begin
  case msg of
    WM_CREATE:
      GetClientRect(wnd,reg);
      new(screen); screen.InitialRegion(0,0,reg.right-1,reg.bottom-1,GreenColor);
      new(block); block.InitialRegion(screen.GetSizeX() div 2,screen.GetSizeY()-width,screen.GetSizeX() div 10,width,RedColor);
      new(ball); ball.InitialSphere(screen.GetSizeX() div 2,1,5,25,10,BlueColor);
      screenPaint:=false;
      SetTimer(wnd,1,100,nil);
      return true;|
    WM_PAINT:
      dc:=BeginPaint(wnd,stru);
      if not screenPaint then
        screen.Paint(dc,0);
        screenPaint:=true
      end;
      ball.Paint(dc,screen.color);
      ball.Paint(dc,0);
      block.Paint(dc,screen.color);
      block.Paint(dc,0);
      EndPaint(wnd,stru);|
    WM_ERASEBKGND:return true;|
    WM_KEYDOWN:case loword(wparam) of
      VK_LEFT:
        if block.GetX()>0 then
          block.Move(-block.GetSizeX() div 2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd)
        end;|
      VK_RIGHT:
        if block.GetX()+block.GetSizeX()<screen.GetSizeX() then
          block.Move(block.GetSizeX() div 2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd)
        end;|
    end;|
    WM_TIMER:
      if ball.MoveSphere(wnd,block,screen) then
        KillTimer(wnd,1);
        MessageBox(0,"You lost.","Attention:",MB_ICONSTOP);
        DestroyWindow(wnd);
      end;
      InvalidateRect(wnd,nil,true);
      UpdateWindow(wnd);|
    WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam);|
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end wndProc;

var
  cla:WNDCLASS;
  wnd:HWND;
  message:MSG;

begin

//class registration
  with cla do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=className;
  end;
  RegisterClass(cla);
                     
//window create
  wnd:=CreateWindowEx(0,className,'Demo1_10',WS_OVERLAPPEDWINDOW,
    100,100,500,400, 0,0,hINSTANCE,nil);

  ShowWindow(wnd,SW_SHOW);
  UpdateWindow(wnd);

//messages loop
  while GetMessage(message,0,0,0) do
    TranslateMessage(message);
    DispatchMessage(message);
  end;

end Demo1_10.

