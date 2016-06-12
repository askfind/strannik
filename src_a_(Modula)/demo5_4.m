// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.4:Moving ball
module Demo5_4;
import Win32;

const hINSTANCE=0x400000;

var
  main:HWND;
  cls:WNDCLASS;
  message:MSG;

  ddraw:pDIRECTDRAW;
  ddscaps:DDSCAPS;
  surface,back:pDIRECTDRAWSURFACE;
  ddsd:DDSURFACEDESC;

const
  radius=20;
  line=100;
  speed=2;

var  center,step:integer;

//window function
procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var dc:HDC; brush,old:HBRUSH; reg:RECT;
begin
  case msg of
    WM_CREATE:
    //create DirectDraw and surface with back buffer
      DirectDrawCreate(nil,addr(ddraw),nil);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(addr(ddsd),sizeof(DDSURFACEDESC));
      ddsd.dwSize:=sizeof(DDSURFACEDESC);
      ddsd.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
      ddsd.dwFlags:=DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
      ddsd.dwBackBufferCount:=1;
      ddraw.CreateSurface(addr(ddsd),addr(surface),nil);
      ddscaps.dwCaps:=DDSCAPS_BACKBUFFER;
      surface.GetAttachedSurface(addr(ddscaps),addr(back));
      center:=50;
      step:=speed;
      SetTimer(wnd,1,10,nil);| //redraw on 0.01 sec
    WM_TIMER:
      if back.GetDC(addr(dc))=DD_OK then
      //black background
        brush:=CreateSolidBrush(0x000000);
        old:=SelectObject(dc,brush);
        reg.left:=0;
        reg.top:=0;
        reg.right:=1024;
        reg.bottom:=786;
        FillRect(dc,reg,brush);
        SelectObject(dc,old);
        DeleteObject(brush);
    //draw ball
        brush:=CreateSolidBrush(0xFF0000);
        old:=SelectObject(dc,brush);
        Ellipse(dc,center-radius,line-radius,center+radius,line+radius);
        SelectObject(dc,old);
        DeleteObject(brush);
        back.ReleaseDC(dc);
    //swap surfaces
        surface.Flip(nil,0);
      end;
    //ball step
      inc(center,step);
      if center>900 then step:=-speed end;
      if center<100 then step:=speed end;|
    WM_KEYDOWN,WM_LBUTTONDOWN:DestroyWindow(wnd);|
    WM_DESTROY:
    //free all objects
      KillTimer(wnd,1);
      back.Release();
      surface.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(wnd,msg,wparam,lparam);|
    else return DefWindowProc(wnd,msg,wparam,lparam);
  end
end wndProc;

begin
//window create
  RtlZeroMemory(addr(cls),sizeof(WNDCLASS));
  with cls do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    hInstance:=hINSTANCE;    
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:="Demo5_4";
  end;
  RegisterClass(cls);
  main:=CreateWindowEx(WS_EX_TOPMOST,"Demo5_4","Demo5_4",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(main,SW_SHOW);
  UpdateWindow(main);

//message cikl
  while GetMessage(message,0,0,0) do
    TranslateMessage(message);
    DispatchMessage(message);
  end;
  ExitProcess(0)
end Demo5_4.

