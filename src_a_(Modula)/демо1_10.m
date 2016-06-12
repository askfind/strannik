// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа
// Демо 10:Теннис (Классы)

module Demo1_10;
import Win32;

const 
  hINSTANCE=0x400000;
  className='Strannik';

  КрасныйЦвет=0x0000FF;
  СинийЦвет=0xFF0000;
  ЗеленыйЦвет=0x00FF00;

  ширина=3;

//------------------------ объект ------------------------------

type объект=record ()
    x,y:integer;
    старыйX,старыйY:integer;
    цвет:cardinal;
    procedure Инициировать*(ини_x,ини_y:integer; ини_цвет:cardinal);
    procedure ПолучитьX*():integer;
    procedure ПолучитьY*():integer;
    procedure ПолучитьСтарыйX*():integer;
    procedure ПолучитьСтарыйY*():integer;
    procedure ПолучитьЦвет*():integer;
    procedure Переместить*(изм_x,изм_y:integer);
  end;

procedure (объект) Инициировать(ини_x,ини_y:integer; ини_цвет:cardinal);
begin
  x:=ини_x;
  y:=ини_y;
  старыйX:=ини_x;
  старыйY:=ини_y;
  цвет:=ини_цвет;
end Инициировать;

procedure (объект) ПолучитьX():integer; begin return x end ПолучитьX;
procedure (объект) ПолучитьY():integer; begin return y end ПолучитьY;
procedure (объект) ПолучитьСтарыйX():integer; begin return старыйX end ПолучитьСтарыйX;
procedure (объект) ПолучитьСтарыйY():integer; begin return старыйY end ПолучитьСтарыйY;
procedure (объект) ПолучитьЦвет():integer; begin return цвет end ПолучитьЦвет;

procedure (объект) Переместить(изм_x,изм_y:integer);
begin
  старыйX:=x;
  старыйY:=y;
  inc(x,изм_x);
  inc(y,изм_y);
end Переместить;

//------------------------ регион ------------------------------

type регион=record (объект)
    размерX,размерY:integer;
  end;

procedure (регион) ИнициироватьРегион(ини_x,ини_y,ини_размерX,ини_размерY:integer; ини_цвет:cardinal);
begin
  self.Инициировать(ини_x,ини_y,ини_цвет);
  размерX:=ини_размерX;
  размерY:=ини_размерY;
end ИнициироватьРегион;

procedure (регион) ПолучитьРазмерX*():integer; begin return размерX end ПолучитьРазмерX;
procedure (регион) ПолучитьРазмерY*():integer; begin return размерY end ПолучитьРазмерY;

procedure (регион) Нарисовать(dc:HDC; фон:COLORREF);
var перо,старое:HPEN; цветРамки,текX,текY:integer; кисть,старая:HBRUSH;
begin
  if фон=0
    then цветРамки:=self.ПолучитьЦвет(); текX:=self.ПолучитьX(); текY:=self.ПолучитьY();
    else цветРамки:=фон; текX:=self.ПолучитьСтарыйX(); текY:=self.ПолучитьСтарыйY();
  end;
  перо:=CreatePen(PS_SOLID,ширина,цветРамки); старое:=SelectObject(dc,перо);
  кисть:=CreateSolidBrush(цветРамки); старая:=SelectObject(dc,кисть);
  Rectangle(dc,текX,текY,текX+размерX,текY+размерY);
  SelectObject(dc,старое); DeleteObject(перо);
  SelectObject(dc,старая); DeleteObject(кисть);
end Нарисовать;

//------------------------ шар ------------------------------

type шар=record (объект)
    диаметр:integer;
    скоростьX,скоростьY:integer;
  end;

procedure (шар) ИнициироватьШар(ини_x,ини_y,ини_скоростьX,ини_скоростьY,ини_диаметр:integer; ини_цвет:cardinal);
begin
  self.Инициировать(ини_x,ини_y,ини_цвет);
  диаметр:=ини_диаметр;
  скоростьX:=ини_скоростьX;
  скоростьY:=ини_скоростьY;
end ИнициироватьШар;

procedure (шар) Нарисовать(dc:HDC; фон:COLORREF);
var перо,старое:HPEN; кисть,старая:HBRUSH; цветШара,текX,текY:integer;
begin
  if фон=0
    then цветШара:=self.ПолучитьЦвет(); текX:=self.ПолучитьX(); текY:=self.ПолучитьY();
    else цветШара:=фон; текX:=self.ПолучитьСтарыйX(); текY:=self.ПолучитьСтарыйY();
  end;
  перо:=CreatePen(PS_SOLID,1,цветШара); старое:=SelectObject(dc,перо);
  кисть:=CreateSolidBrush(цветШара); старая:=SelectObject(dc,кисть);
  Ellipse(dc,текX-диаметр div 2,текY-диаметр div 2,текX+диаметр div 2,текY+диаметр div 2);
  SelectObject(dc,старое); DeleteObject(перо);
  SelectObject(dc,старая); DeleteObject(кисть);
end Нарисовать;

procedure (шар) ПереместитьШар(wnd:HWND; ракетка,экран:регион):boolean;
var новX,новY:integer;
begin
  новX:=self.ПолучитьX();
  новY:=self.ПолучитьY();
  inc(новX,скоростьX); //передвижение шара
  inc(новY,скоростьY);
  if (новY>экран.ПолучитьРазмерY())and(  //проверка на удар об ракетку
    (новX<ракетка.ПолучитьX())or
    (новX>ракетка.ПолучитьX()+ракетка.ПолучитьРазмерX())) then
    return true
  end;
  if новX<0 then новX:=-новX; скоростьX:=-скоростьX end; //проверка на выход за границы экрана
  if новY<0 then новY:=-новY; скоростьY:=-скоростьY end;
  if новX>экран.ПолучитьРазмерX() then новX:=экран.ПолучитьРазмерX()-(новX-экран.ПолучитьРазмерX()); скоростьX:=-скоростьX end;
  if новY>экран.ПолучитьРазмерY() then новY:=экран.ПолучитьРазмерY()-(новY-экран.ПолучитьРазмерY()); скоростьY:=-скоростьY end;
  if новX<0 then новX:=-новX; скоростьX:=-скоростьX end; //повторная проверка на выход за границы экрана
  if новY<0 then новY:=-новY; скоростьY:=-скоростьY end;
  if новX>экран.ПолучитьРазмерX() then новX:=экран.ПолучитьРазмерX()-(новX-экран.ПолучитьРазмерX()); скоростьX:=-скоростьX end;
  if новY>экран.ПолучитьРазмерY() then новY:=экран.ПолучитьРазмерY()-(новY-экран.ПолучитьРазмерY()); скоростьY:=-скоростьY end;
  self.Переместить(новX-self.ПолучитьX(),новY-self.ПолучитьY());
  return false
end ПереместитьШар;

//------------------------ программа ------------------------------

var
  шарик:шар;
  ракетка,экран:регион;
  экранНарисован:boolean;

procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var dc:HDC; stru:PAINTSTRUCT; reg:RECT;
begin
  case msg of
    WM_CREATE:
      GetClientRect(wnd,reg);
      new(экран); экран.ИнициироватьРегион(0,0,reg.right-1,reg.bottom-1,ЗеленыйЦвет);
      new(ракетка); ракетка.ИнициироватьРегион(экран.ПолучитьРазмерX() div 2,экран.ПолучитьРазмерY()-ширина,экран.ПолучитьРазмерX() div 10,ширина,КрасныйЦвет);
      new(шарик); шарик.ИнициироватьШар(экран.ПолучитьРазмерX() div 2,1,5,25,10,СинийЦвет);
      экранНарисован:=false;
      SetTimer(wnd,1,100,nil);
      return true;|
    WM_PAINT:
      dc:=BeginPaint(wnd,stru);
      if not экранНарисован then
        экран.Нарисовать(dc,0);
        экранНарисован:=true
      end;
      шарик.Нарисовать(dc,экран.цвет);
      шарик.Нарисовать(dc,0);
      ракетка.Нарисовать(dc,экран.цвет);
      ракетка.Нарисовать(dc,0);
      EndPaint(wnd,stru);|
    WM_ERASEBKGND:return true;|
    WM_KEYDOWN:case loword(wparam) of
      VK_LEFT:
        if ракетка.ПолучитьX()>0 then
          ракетка.Переместить(-ракетка.ПолучитьРазмерX() div 2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd)
        end;|
      VK_RIGHT:
        if ракетка.ПолучитьX()+ракетка.ПолучитьРазмерX()<экран.ПолучитьРазмерX() then
          ракетка.Переместить(ракетка.ПолучитьРазмерX() div 2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd)
        end;|
    end;|
    WM_TIMER:
      if шарик.ПереместитьШар(wnd,ракетка,экран) then
        KillTimer(wnd,1);
        MessageBox(0,"Вы проиграли.","Внимание:",MB_ICONSTOP);
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

//регистрация класса
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
                     
//создание окна
  wnd:=CreateWindowEx(0,className,'Demo1_10',WS_OVERLAPPEDWINDOW,
    100,100,500,400, 0,0,hINSTANCE,nil);

  ShowWindow(wnd,SW_SHOW);
  UpdateWindow(wnd);

//цикл сообщений
  while GetMessage(message,0,0,0) do
    TranslateMessage(message);
    DispatchMessage(message);
  end;

end Demo1_10.

