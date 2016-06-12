// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с DirectX
// Демо 4:Летающий шарик

#include "Win32.h"

#define hINSTANCE 0x400000

HWND окно;
WNDCLASS класс;
MSG сообщение;

pDIRECTDRAW ddraw;
DDSCAPS ddscaps;
pDIRECTDRAWSURFACE поверхность,вспомогательная;
DDSURFACEDESC реквизиты;

#define радиус 20
#define горизонталь 100
#define скорость 2

int центр,шаг;

//оконная функция
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
HDC dc; HBRUSH кисть,старая; RECT рег;

  switch(msg) {
    case WM_CREATE:
    //создание объекта DirectDraw и поверхности с вспомогательным буфером
      DirectDrawCreate(NULL,&ddraw,NULL);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(&реквизиты,sizeof(DDSURFACEDESC));
      реквизиты.dwSize=sizeof(DDSURFACEDESC);
      реквизиты.ddsCaps.dwCaps=DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
      реквизиты.dwFlags=DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
      реквизиты.dwBackBufferCount=1;
      ddraw.CreateSurface(&реквизиты,&поверхность,NULL);
      ddscaps.dwCaps=DDSCAPS_BACKBUFFER;
      поверхность.GetAttachedSurface(&ddscaps,&вспомогательная);
      центр=50;
      шаг=скорость;
      SetTimer(wnd,1,10,NULL); break; //рисовать каждые 0.01 секунды
    case WM_TIMER:
      if(вспомогательная.GetDC(addr(dc))==DD_OK) {
      //черный фон
        кисть=CreateSolidBrush(0x000000);
        старая=SelectObject(dc,кисть);
        рег.left=0;
        рег.top=0;
        рег.right=1024;
        рег.bottom=786;
        FillRect(dc,рег,кисть);
        SelectObject(dc,старая);
        DeleteObject(кисть);
    //рисование шарика
        кисть=CreateSolidBrush(0xFF0000);
        старая=SelectObject(dc,кисть);
        Ellipse(dc,центр-радиус,горизонталь-радиус,центр+радиус,горизонталь+радиус);
        SelectObject(dc,старая);
        DeleteObject(кисть);
        вспомогательная.ReleaseDC(dc);
    //обмен поверхностей
        поверхность.Flip(NULL,0);
      }
    //передвижение шарика
      центр++шаг;
      if(центр>900) шаг=-скорость;
      if(центр<100) шаг=скорость; break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //освобождение объектов
      KillTimer(wnd,1);
      вспомогательная.Release();
      поверхность.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

void main() {
//создание окна
  RtlZeroMemory(&класс,sizeof(WNDCLASS));
  класс.style=CS_HREDRAW | CS_VREDRAW;
  класс.lpfnWndProc=&wndProc;
  класс.hInstance=hINSTANCE;    
  класс.hbrBackground=COLOR_WINDOW;
  класс.lpszClassName="Demo5_4";
  RegisterClass(класс);                     
  окно=CreateWindowEx(WS_EX_TOPMOST,"Demo5_4","Demo5_4",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(окно,SW_SHOW);
  UpdateWindow(окно);

//цикл сообщений
  while(GetMessage(сообщение,0,0,0)) {
    TranslateMessage(сообщение);
    DispatchMessage(сообщение);
  }
  ExitProcess(0);
}

