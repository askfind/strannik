// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.3:Swap surfaces

#include "Win32"

#define hINSTANCE 0x400000

HWND mainwnd;
WNDCLASS cls;
MSG message;

pDIRECTDRAW ddraw;
DDSCAPS ddscaps;
pDIRECTDRAWSURFACE surface,back;
DDSURFACEDESC ddsd;
bool key;

//window function
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
HDC dc;

  switch(msg) {
    case WM_CREATE:
    //create DirectDraw and surface with back buffer
      DirectDrawCreate(NULL,&ddraw,NULL);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(&ddsd,sizeof(DDSURFACEDESC));
      ddsd.dwSize=sizeof(DDSURFACEDESC);
      ddsd.ddsCaps.dwCaps=DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
      ddsd.dwFlags=DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
      ddsd.dwBackBufferCount=1;
      ddraw.CreateSurface(&ddsd,&surface,NULL);
      ddscaps.dwCaps=DDSCAPS_BACKBUFFER;
      surface.GetAttachedSurface(&ddscaps,&back);
      key=false;
      SetTimer(wnd,1,1000,NULL); break; //swap period 1 sec
    case WM_TIMER:
    //black background
      if(surface.Lock(NULL,&ddsd,DDLOCK_WAIT,0)==DD_OK) {
        RtlFillMemory(ddsd.lpSurface,ddsd.lPitch*ddsd.dwHeight,0x00);
        surface.Unlock(ddsd.lpSurface);
      }
    //text out
      if(back.GetDC(&dc)==DD_OK) {
        SetBkColor(dc,0x000000);
        SetTextColor(dc,0x00FF00);
        if(key) TextOut(dc,0,0,"Front",lstrlen("Front"));
        else TextOut(dc,0,0,"Back",lstrlen("Back"));
        back.ReleaseDC(dc);
    //swap surfaces
        key=~key;
        surface.Flip(NULL,0);
      } break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //free all objects
      KillTimer(wnd,1);
      back.Release();
      surface.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

void main() {
//window create
  RtlZeroMemory(&cls,sizeof(WNDCLASS));
  cls.style=CS_HREDRAW | CS_VREDRAW;
  cls.lpfnWndProc=addr(wndProc);
  cls.hInstance=hINSTANCE;    
  cls.hbrBackground=COLOR_WINDOW;
  cls.lpszClassName="Demo5_3";
  RegisterClass(cls);
  mainwnd=CreateWindowEx(WS_EX_TOPMOST,"Demo5_3","Demo5_3",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(mainwnd,SW_SHOW);
  UpdateWindow(mainwnd);

//message cikl
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
  ExitProcess(0);
}

