// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.4:Moving ball

#include "Win32"

#define hINSTANCE 0x400000

HWND mainwnd;
WNDCLASS cls;
MSG message;

pDIRECTDRAW ddraw;
DDSCAPS ddscaps;
pDIRECTDRAWSURFACE surface,back;
DDSURFACEDESC ddsd;

#define radius 20
#define line 100
#define speed 2

int center,step;

//window function
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
HDC dc; HBRUSH brush,old; RECT reg;

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
      center=50;
      step=speed;
      SetTimer(wnd,1,10,NULL); break; //redraw on 0.01 sec
    case WM_TIMER:
      if(back.GetDC(&dc)==DD_OK) {
      //black background
        brush=CreateSolidBrush(0x000000);
        old=SelectObject(dc,brush);
        reg.left=0;
        reg.top=0;
        reg.right=1024;
        reg.bottom=786;
        FillRect(dc,reg,brush);
        SelectObject(dc,old);
        DeleteObject(brush);
    //draw ball
        brush=CreateSolidBrush(0xFF0000);
        old=SelectObject(dc,brush);
        Ellipse(dc,center-radius,line-radius,center+radius,line+radius);
        SelectObject(dc,old);
        DeleteObject(brush);
        back.ReleaseDC(dc);
    //swap surfaces
        surface.Flip(NULL,0);
      }
    //ball step
      center++step;
      if(center>900) step=-speed;
      if(center<100) step=speed; break;
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
  cls.lpszClassName="Demo5_4";
  RegisterClass(cls);
  mainwnd=CreateWindowEx(WS_EX_TOPMOST,"Demo5_4","Demo5_4",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(mainwnd,SW_SHOW);
  UpdateWindow(mainwnd);

//message cikl
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
  ExitProcess(0);
}

