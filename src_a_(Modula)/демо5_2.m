// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с DirectX
// Демо 2:Рисование линии
module Demo5_2;
import Win32;

const hINSTANCE=0x400000;

var
  окно:HWND;
  класс:WNDCLASS;
  сообщение:MSG;

  ddraw:pDIRECTDRAW;
  поверхность:pDIRECTDRAWSURFACE;
  реквизиты:DDSURFACEDESC;

//оконная функция
procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var экран:pstr; начало,точка:integer;
begin
  case msg of
    WM_CREATE:
    //создание объекта DirectDraw и поверхности
      DirectDrawCreate(nil,addr(ddraw),nil);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(addr(реквизиты),sizeof(DDSURFACEDESC));
      реквизиты.dwSize:=sizeof(DDSURFACEDESC);
      реквизиты.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE;
      реквизиты.dwFlags:=DDSD_CAPS;
      ddraw.CreateSurface(addr(реквизиты),addr(поверхность),nil);
      SetTimer(wnd,1,500,nil);| //рисовать каждые 0.5 секунды
    WM_TIMER:
    //рисование линии
      if поверхность.Lock(nil,addr(реквизиты),DDLOCK_WAIT,0)=DD_OK then
        RtlFillMemory(реквизиты.lpSurface,реквизиты.lPitch*реквизиты.dwHeight,0x00);
        экран:=реквизиты.lpSurface;
        начало:=реквизиты.lPitch*100; //строка 100
        for точка:=0 to реквизиты.dwWidth-1 do
          экран[начало+точка*4+0]:=char(0xFF); //синий цвет
          экран[начало+точка*4+1]:=char(0x00);
          экран[начало+точка*4+2]:=char(0x00);
          экран[начало+точка*4+3]:=char(0x00);
        end;
        поверхность.Unlock(реквизиты.lpSurface);
      end;|
    WM_KEYDOWN,WM_LBUTTONDOWN:DestroyWindow(wnd);|
    WM_DESTROY:
    //освобождение объектов
      KillTimer(wnd,1);
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
    lpszClassName:="Demo5_2";
  end;
  RegisterClass(класс);                     
  окно:=CreateWindowEx(WS_EX_TOPMOST,"Demo5_2","Demo5_2",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(окно,SW_SHOW);
  UpdateWindow(окно);

//цикл сообщений
  while GetMessage(сообщение,0,0,0) do
    TranslateMessage(сообщение);
    DispatchMessage(сообщение);
  end;
  ExitProcess(0)
end Demo5_2.


