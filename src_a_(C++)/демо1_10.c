// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа
// Демо 10:Теннис (Классы)

include Win32

define hINSTANCE 0x400000
define className 'Strannik'

define КрасныйЦвет 0x0000FF
define СинийЦвет 0xFF0000
define ЗеленыйЦвет 0x00FF00

define ширина 3

//------------------------ объект ------------------------------

class объект {
private:
  int x,y;
  int старыйX,старыйY;
  uint цвет;
public:
  void Инициировать(int ини_x, int ини_y, uint ини_цвет);
  int ПолучитьX();
  int ПолучитьY();
  int ПолучитьСтарыйX();
  int ПолучитьСтарыйY();
  int ПолучитьЦвет();
  void Переместить(int изм_x, int изм_y);
}

void объект::Инициировать(int ини_x, int ини_y, uint ини_цвет)
{
  x=ини_x;
  y=ини_y;
  старыйX=ини_x;
  старыйY=ини_y;
  цвет=ини_цвет;
}

int объект::ПолучитьX() {return x;}
int объект::ПолучитьY() {return y;}
int объект::ПолучитьСтарыйX() {return старыйX;}
int объект::ПолучитьСтарыйY() {return старыйY;}
int объект::ПолучитьЦвет() {return цвет;}

void объект::Переместить(int изм_x, int изм_y)
{
  старыйX=x;
  старыйY=y;
  x+=изм_x;
  y+=изм_y;
}

//------------------------ регион ------------------------------

class регион:объект {
private:
  int размерX,размерY;
public:
  void ИнициироватьРегион(int ини_x,int ини_y,int ини_размерX,int ини_размерY,uint ини_цвет);
  int ПолучитьРазмерX();
  int ПолучитьРазмерY();
  virtual void Нарисовать(HDC dc, COLORREF фон);
}

void регион::ИнициироватьРегион(int ини_x,int ини_y,int ини_размерX,int ини_размерY,uint ини_цвет)
{
  this.Инициировать(ини_x,ини_y,ини_цвет);
  размерX=ини_размерX;
  размерY=ини_размерY;
}

int регион::ПолучитьРазмерX() {return размерX;}
int регион::ПолучитьРазмерY() {return размерY;}

void регион::Нарисовать(HDC dc, COLORREF фон)
{
HPEN перо,старое; int цветРамки,текX,текY; HBRUSH кисть,старая;

  if(фон==0) {цветРамки=this.ПолучитьЦвет(); текX=this.ПолучитьX(); текY=this.ПолучитьY();}
  else {цветРамки=фон; текX=this.ПолучитьСтарыйX(); текY=this.ПолучитьСтарыйY();}
  перо=CreatePen(PS_SOLID,ширина,цветРамки); старое=SelectObject(dc,перо);
  кисть=CreateSolidBrush(цветРамки); старая=SelectObject(dc,кисть);
  Rectangle(dc,текX,текY,текX+размерX,текY+размерY);
  SelectObject(dc,старое); DeleteObject(перо);
  SelectObject(dc,старая); DeleteObject(кисть);
}

//------------------------ шар ------------------------------

class шар:объект {
private:
  int диаметр;
  int скоростьX,скоростьY;
public:
  void ИнициироватьШар(int ини_x,int ини_y,int ини_скоростьX,int ини_скоростьY,int ини_диаметр,uint ини_цвет);
  virtual void Нарисовать(HDC dc, COLORREF фон);
  bool ПереместитьШар(HWND wnd, регион ракетка,регион экран);
}

void шар::ИнициироватьШар(int ини_x,int ини_y,int ини_скоростьX,int ини_скоростьY,int ини_диаметр,uint ини_цвет)
{
  this.Инициировать(ини_x,ини_y,ини_цвет);
  диаметр=ини_диаметр;
  скоростьX=ини_скоростьX;
  скоростьY=ини_скоростьY;
}

void шар::Нарисовать(HDC dc, COLORREF фон)
{
HPEN перо,старое; HBRUSH кисть,старая; int цветШара,текX,текY;

  if(фон==0) {цветШара=this.ПолучитьЦвет(); текX=this.ПолучитьX(); текY=this.ПолучитьY();}
  else {цветШара=фон; текX=this.ПолучитьСтарыйX(); текY=this.ПолучитьСтарыйY();}
  перо=CreatePen(PS_SOLID,1,цветШара); старое=SelectObject(dc,перо);
  кисть=CreateSolidBrush(цветШара); старая=SelectObject(dc,кисть);
  Ellipse(dc,текX-диаметр/2,текY-диаметр/2,текX+диаметр/2,текY+диаметр/2);
  SelectObject(dc,старое); DeleteObject(перо);
  SelectObject(dc,старая); DeleteObject(кисть);
}

bool шар::ПереместитьШар(HWND wnd, регион ракетка,регион экран)
{
int новX,новY;

  новX=this.ПолучитьX();
  новY=this.ПолучитьY();
  новX+=скоростьX; //передвижение шара
  новY+=скоростьY;
  if((новY>экран.ПолучитьРазмерY())&&(  //проверка на удар об ракетку
    (новX<ракетка.ПолучитьX())||
    (новX>ракетка.ПолучитьX()+ракетка.ПолучитьРазмерX())))
    return true;
  if(новX<0) {новX=-новX; скоростьX=-скоростьX;} //проверка на выход за границы экрана
  if(новY<0) {новY=-новY; скоростьY=-скоростьY;}
  if(новX>экран.ПолучитьРазмерX()) {новX=экран.ПолучитьРазмерX()-(новX-экран.ПолучитьРазмерX()); скоростьX=-скоростьX;}
  if(новY>экран.ПолучитьРазмерY()) {новY=экран.ПолучитьРазмерY()-(новY-экран.ПолучитьРазмерY()); скоростьY=-скоростьY;}
  if(новX<0) {новX=-новX; скоростьX=-скоростьX;} //повторная проверка на выход за границы экрана
  if(новY<0) {новY=-новY; скоростьY=-скоростьY;}
  if(новX>экран.ПолучитьРазмерX()) {новX=экран.ПолучитьРазмерX()-(новX-экран.ПолучитьРазмерX()); скоростьX=-скоростьX;}
  if(новY>экран.ПолучитьРазмерY()) {новY=экран.ПолучитьРазмерY()-(новY-экран.ПолучитьРазмерY()); скоростьY=-скоростьY;}
  this.Переместить(новX-this.ПолучитьX(),новY-this.ПолучитьY());
  return false;
}

//------------------------ программа ------------------------------

  шар шарик;
  регион ракетка,экран;
  bool экранНарисован;

bool wndProc(HWND wnd,uint msg,uint wparam,uint lparam)
{
HDC dc; PAINTSTRUCT stru; RECT reg;

  switch(msg) {
    case WM_CREATE:
      GetClientRect(wnd,reg);
      экран=new регион; экран.ИнициироватьРегион(0,0,reg.right-1,reg.bottom-1,ЗеленыйЦвет);
      ракетка=new регион; ракетка.ИнициироватьРегион(экран.ПолучитьРазмерX()/2,экран.ПолучитьРазмерY()-ширина,экран.ПолучитьРазмерX()/10,ширина,КрасныйЦвет);
      шарик=new шар; шарик.ИнициироватьШар(экран.ПолучитьРазмерX()/2,1,5,25,10,СинийЦвет);
      экранНарисован=false;
      SetTimer(wnd,1,100,NULL);
      return true;
      break;
    case WM_PAINT:
      dc=BeginPaint(wnd,stru);
      if(!экранНарисован) {
        экран.Нарисовать(dc,0);
        экранНарисован=true;
      }
      шарик.Нарисовать(dc,экран.цвет);
      шарик.Нарисовать(dc,0);
      ракетка.Нарисовать(dc,экран.цвет);
      ракетка.Нарисовать(dc,0);
      EndPaint(wnd,stru);
      break;
    case WM_ERASEBKGND:return true; break;
    case WM_KEYDOWN:switch(loword(wparam)) {
      case VK_LEFT:
        if(ракетка.ПолучитьX()>0) {
          ракетка.Переместить(-ракетка.ПолучитьРазмерX()/2,0);
          InvalidateRect(wnd,NULL,true);
          UpdateWindow(wnd);
        }
        break;
      case VK_RIGHT:
        if(ракетка.ПолучитьX()+ракетка.ПолучитьРазмерX()<экран.ПолучитьРазмерX()) {
          ракетка.Переместить(ракетка.ПолучитьРазмерX()/2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd);
        }
        break;
      }
      break;
    case WM_TIMER:
      if(шарик.ПереместитьШар(wnd,ракетка,экран)) {
        KillTimer(wnd,1);
        MessageBox(0,"Вы проиграли.","Внимание:",MB_ICONSTOP);
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
//регистрация класса
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
                     
//создание окна
  wnd=CreateWindowEx(0,className,'Demo1_10',WS_OVERLAPPEDWINDOW,
    100,100,500,400, 0,0,hINSTANCE,NULL);

  ShowWindow(wnd,SW_SHOW);
  UpdateWindow(wnd);

//цикл сообщений
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }

}

