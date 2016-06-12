// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с DirectX
// Демо 3:Переключение поверхностей

#include "Win32.h"

#define hINSTANCE 0x400000

HWND окно;
WNDCLASS класс;
MSG сообщение;

pDIRECTDRAW ddraw;
DDSCAPS ddscaps;
pDIRECTDRAWSURFACE поверхность,вспомогательная;
DDSURFACEDESC реквизиты;
bool переключатель;

//оконная функция
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
HDC dc;

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
      переключатель=false;
      SetTimer(wnd,1,1000,nil); break; //рисовать каждую секунду
    case WM_TIMER:
    //черный фон
      if(поверхность.Lock(NULL,&реквизиты,DDLOCK_WAIT,0)==DD_OK) {
        RtlFillMemory(реквизиты.lpSurface,реквизиты.lPitch*реквизиты.dwHeight,0x00);
        поверхность.Unlock(реквизиты.lpSurface);
      }
    //вывод текста
      if(вспомогательная.GetDC(addr(dc))==DD_OK) {
        SetBkColor(dc,0x000000);
        SetTextColor(dc,0x00FF00);
        if(переключатель) TextOut(dc,0,0,"Front",lstrlen("Front"));
        else TextOut(dc,0,0,"Back",lstrlen("Back"));
        вспомогательная.ReleaseDC(dc);
    //обмен поверхностей
        переключатель=~переключатель;
        поверхность.Flip(nil,0);
      } break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //освобождение объектов
      KillTimer(wnd,1);
      вспомогательная.Release();
      поверхность.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(окно,msg,wparam,lparam); break;
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
  класс.lpszClassName="Demo5_3";
  RegisterClass(класс);                     
  окно=CreateWindowEx(WS_EX_TOPMOST,"Demo5_3","Demo5_3",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(окно,SW_SHOW);
  UpdateWindow(окно);

//цикл сообщений
  while(GetMessage(сообщение,0,0,0)) {
    TranslateMessage(сообщение);
    DispatchMessage(сообщение);
  }
  ExitProcess(0);
}

