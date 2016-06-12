// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.2:Line draw
module Demo5_2;
import Win32;

const hINSTANCE=0x400000;

var
  main:HWND;
  cls:WNDCLASS;
  message:MSG;

  ddraw:pDIRECTDRAW;
  surface:pDIRECTDRAWSURFACE;
  ddsd:DDSURFACEDESC;

//window function
procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var screen:pstr; beg,point:integer;
begin
  case msg of
    WM_CREATE:
    //create DirectDraw and surface
      DirectDrawCreate(nil,addr(ddraw),nil);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(addr(ddsd),sizeof(DDSURFACEDESC));
      ddsd.dwSize:=sizeof(DDSURFACEDESC);
      ddsd.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE;
      ddsd.dwFlags:=DDSD_CAPS;
      ddraw.CreateSurface(addr(ddsd),addr(surface),nil);
      SetTimer(wnd,1,500,nil);| //swap period 0.5 sec
    WM_TIMER:
    //Line draw
      if surface.Lock(nil,addr(ddsd),DDLOCK_WAIT,0)=DD_OK then
        RtlFillMemory(ddsd.lpSurface,ddsd.lPitch*ddsd.dwHeight,0x00);
        screen:=ddsd.lpSurface;
        beg:=ddsd.lPitch*100; //line 100
        for point:=0 to ddsd.dwWidth-1 do
          screen[beg+point*4+0]:=char(0xFF); //blue color
          screen[beg+point*4+1]:=char(0x00);
          screen[beg+point*4+2]:=char(0x00);
          screen[beg+point*4+3]:=char(0x00);
        end;
        surface.Unlock(ddsd.lpSurface);
      end;|
    WM_KEYDOWN,WM_LBUTTONDOWN:DestroyWindow(wnd);|
    WM_DESTROY:
    //free all objects
      KillTimer(wnd,1);
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
    lpszClassName:="Demo5_2";
  end;
  RegisterClass(cls);
  main:=CreateWindowEx(WS_EX_TOPMOST,"Demo5_2","Demo5_2",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(main,SW_SHOW);
  UpdateWindow(main);

//message cikl
  while GetMessage(message,0,0,0) do
    TranslateMessage(message);
    DispatchMessage(message);
  end;
  ExitProcess(0)
end Demo5_2.


