// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с DirectX
// Демо 4:Летающий шарик
module Demo5_4;
import Win32;

const hINSTANCE=0x400000;

var
  окно:HWND;
  класс:WNDCLASS;
  сообщение:MSG;

  ddraw:pDIRECTDRAW;
  ddscaps:DDSCAPS;
  поверхность,вспомогательная:pDIRECTDRAWSURFACE;
  реквизиты:DDSURFACEDESC;

const
  радиус=20;
  горизонталь=100;
  скорость=2;

var  центр,шаг:integer;

//оконная функция
procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var экран:pstr; начало,точка:integer; dc:HDC; кисть,старая:HBRUSH; рег:RECT;
begin
  case msg of
    WM_CREATE:
    //создание объекта DirectDraw и поверхности с вспомогательным буфером
      DirectDrawCreate(nil,addr(ddraw),nil);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(addr(реквизиты),sizeof(DDSURFACEDESC));
      реквизиты.dwSize:=sizeof(DDSURFACEDESC);
      реквизиты.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
      реквизиты.dwFlags:=DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
      реквизиты.dwBackBufferCount:=1;
      ddraw.CreateSurface(addr(реквизиты),addr(поверхность),nil);
      ddscaps.dwCaps:=DDSCAPS_BACKBUFFER;
      поверхность.GetAttachedSurface(addr(ddscaps),addr(вспомогательная));
      центр:=50;
      шаг:=скорость;
      SetTimer(wnd,1,10,nil);| //рисовать каждые 0.01 секунды
    WM_TIMER:
      if вспомогательная.GetDC(addr(dc))=DD_OK then
      //черный фон
        кисть:=CreateSolidBrush(0x000000);
        старая:=SelectObject(dc,кисть);
        рег.left:=0;
        рег.top:=0;
        рег.right:=1024;
        рег.bottom:=786;
        FillRect(dc,рег,кисть);
        SelectObject(dc,старая);
        DeleteObject(кисть);
    //рисование шарика
        кисть:=CreateSolidBrush(0xFF0000);
        старая:=SelectObject(dc,кисть);
        Ellipse(dc,центр-радиус,горизонталь-радиус,центр+радиус,горизонталь+радиус);
        SelectObject(dc,старая);
        DeleteObject(кисть);
        вспомогательная.ReleaseDC(dc);
    //обмен поверхностей
        поверхность.Flip(nil,0);
      end;
    //передвижение шарика
      inc(центр,шаг);
      if центр>900 then шаг:=-скорость end;
      if центр<100 then шаг:=скорость end;|
    WM_KEYDOWN,WM_LBUTTONDOWN:DestroyWindow(wnd);|
    WM_DESTROY:
    //освобождение объектов
      KillTimer(wnd,1);
      вспомогательная.Release();
      поверхность.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(окно,msg,wparam,lparam);|
    else return DefWindowProc(wnd,msg,wparam,lparam);
  end
end wndProc;

begin
//создание окна
  RtlZeroMemory(addr(класс),sizeof(WNDCLASS));
  with класс do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    hInstance:=hINSTANCE;    
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:="Demo5_4";
  end;
  RegisterClass(класс);                     
  окно:=CreateWindowEx(WS_EX_TOPMOST,"Demo5_4","Demo5_4",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(окно,SW_SHOW);
  UpdateWindow(окно);

//цикл сообщений
  while GetMessage(сообщение,0,0,0) do
    TranslateMessage(сообщение);
    DispatchMessage(сообщение);
  end;
  ExitProcess(0)
end Demo5_4.

