// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с DirectX
// Демо 2:Рисование линии

#include "Win32.h"

#define hINSTANCE 0x400000

HWND окно;
WNDCLASS класс;
MSG сообщение;

pDIRECTDRAW ddraw;
pDIRECTDRAWSURFACE поверхность;
DDSURFACEDESC реквизиты;

//оконная функция
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
char* экран; int начало,точка;

  switch(msg) {
    case WM_CREATE:
    //создание объекта DirectDraw и поверхности
      DirectDrawCreate(NULL,&ddraw,NULL);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(&реквизиты,sizeof(DDSURFACEDESC));
      реквизиты.dwSize=sizeof(DDSURFACEDESC);
      реквизиты.ddsCaps.dwCaps=DDSCAPS_PRIMARYSURFACE;
      реквизиты.dwFlags=DDSD_CAPS;
      ddraw.CreateSurface(&реквизиты,&поверхность,NULL);
      SetTimer(wnd,1,500,nil); break; //рисовать каждые 0.5 секунды
    case WM_TIMER:
    //рисование линии
      if(поверхность.Lock(NULL,&реквизиты,DDLOCK_WAIT,0)==DD_OK) {
        RtlFillMemory(реквизиты.lpSurface,реквизиты.lPitch*реквизиты.dwHeight,0x00);
        экран=реквизиты.lpSurface;
        начало=реквизиты.lPitch*100; //строка 100
        for(точка=0; точка<=реквизиты.dwWidth-1; точка++) {
          экран[начало+точка*4+0]=(char)(0xFF); //синий цвет
          экран[начало+точка*4+1]=(char)(0x00);
          экран[начало+точка*4+2]=(char)(0x00);
          экран[начало+точка*4+3]=(char)(0x00);
        }
        поверхность.Unlock(реквизиты.lpSurface);
      } break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //освобождение объектов
      KillTimer(wnd,1);
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
  класс.lpszClassName="Demo5_2";
  RegisterClass(класс);                     
  окно=CreateWindowEx(WS_EX_TOPMOST,"Demo5_2","Demo5_2",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(окно,SW_SHOW);
  UpdateWindow(окно);

//цикл сообщений
  while(GetMessage(сообщение,0,0,0)) {
    TranslateMessage(сообщение);
    DispatchMessage(сообщение);
  }
  ExitProcess(0);
}


