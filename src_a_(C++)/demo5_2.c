// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.2:Line draw

#include "Win32"

#define hINSTANCE 0x400000

HWND mainwnd;
WNDCLASS cls;
MSG message;

pDIRECTDRAW ddraw;
pDIRECTDRAWSURFACE surface;
DDSURFACEDESC ddsd;

//window function
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
char* screen; int beg,point;

  switch(msg) {
    case WM_CREATE:
    //create DirectDraw and surface
      DirectDrawCreate(NULL,&ddraw,NULL);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(&ddsd,sizeof(DDSURFACEDESC));
      ddsd.dwSize=sizeof(DDSURFACEDESC);
      ddsd.ddsCaps.dwCaps=DDSCAPS_PRIMARYSURFACE;
      ddsd.dwFlags=DDSD_CAPS;
      ddraw.CreateSurface(&ddsd,&surface,NULL);
      SetTimer(wnd,1,500,NULL); break; //swap period 0.5 sec
    case WM_TIMER:
    //Line draw
      if(surface.Lock(NULL,&ddsd,DDLOCK_WAIT,0)==DD_OK) {
        RtlFillMemory(ddsd.lpSurface,ddsd.lPitch*ddsd.dwHeight,0x00);
        screen=ddsd.lpSurface;
        beg=ddsd.lPitch*100; //line 100
        for(point=0; point<=ddsd.dwWidth-1; point++) {
          screen[beg+point*4+0]=(char)(0xFF); //blue color
          screen[beg+point*4+1]=(char)(0x00);
          screen[beg+point*4+2]=(char)(0x00);
          screen[beg+point*4+3]=(char)(0x00);
        }
        surface.Unlock(ddsd.lpSurface);
      } break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //free all objects
      KillTimer(wnd,1);
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
  cls.lpszClassName="Demo5_2";
  RegisterClass(cls);
  mainwnd=CreateWindowEx(WS_EX_TOPMOST,"Demo5_2","Demo5_2",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(mainwnd,SW_SHOW);
  UpdateWindow(mainwnd);

//message cikl
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
  ExitProcess(0);
}


