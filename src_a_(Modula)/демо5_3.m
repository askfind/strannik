// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с DirectX
// Демо 3:Переключение поверхностей
module Demo5_3;
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
  переключатель:boolean;

//оконная функция
procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var экран:pstr; начало,точка:integer; dc:HDC;
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
      переключатель:=false;
      SetTimer(wnd,1,1000,nil);| //рисовать каждую секунду
    WM_TIMER:
    //черный фон
      if поверхность.Lock(nil,addr(реквизиты),DDLOCK_WAIT,0)=DD_OK then
        RtlFillMemory(реквизиты.lpSurface,реквизиты.lPitch*реквизиты.dwHeight,0x00);
        поверхность.Unlock(реквизиты.lpSurface);
      end;
    //вывод текста
      if вспомогательная.GetDC(addr(dc))=DD_OK then
        SetBkColor(dc,0x000000);
        SetTextColor(dc,0x00FF00);
        if переключатель
          then TextOut(dc,0,0,"Front",lstrlen("Front"))
          else TextOut(dc,0,0,"Back",lstrlen("Back"))
        end;
        вспомогательная.ReleaseDC(dc);
    //обмен поверхностей
        переключатель:=not переключатель;
        поверхность.Flip(nil,0);
      end;|
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
end Demo5_3.


