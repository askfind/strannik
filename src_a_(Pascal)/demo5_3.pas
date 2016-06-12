// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.3:Swap surfaces
program Demo5_3;
uses Win32;

const hINSTANCE=0x400000;

var
  main:HWND;
  cls:WNDCLASS;
  message:MSG;

  ddraw:pDIRECTDRAW;
  ddscaps:DDSCAPS;
  surface,back:pDIRECTDRAWSURFACE;
  ddsd:DDSURFACEDESC;
  key:boolean;

//window function
function wndProc(wnd:HWND; msg,wparam,lparam:dword):boolean;
var dc:HDC;
begin
  case msg of
    WM_CREATE:begin
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
      key:=false;
      SetTimer(wnd,1,1000,nil); //swap period 1 sec
    end;
    WM_TIMER:begin
    //black background
      if surface.Lock(nil,addr(ddsd),DDLOCK_WAIT,0)=DD_OK then begin
        RtlFillMemory(ddsd.lpSurface,ddsd.lPitch*ddsd.dwHeight,0x00);
        surface.Unlock(ddsd.lpSurface);
      end;
    //text out
      if back.GetDC(addr(dc))=DD_OK then begin
        SetBkColor(dc,0x000000);
        SetTextColor(dc,0x00FF00);
        if key
          then TextOut(dc,0,0,"Front",lstrlen("Front"))
          else TextOut(dc,0,0,"Back",lstrlen("Back"));
        back.ReleaseDC(dc);
    //swap surfaces
        key:=not key;
        surface.Flip(nil,0);
      end;
    end;
    WM_KEYDOWN,WM_LBUTTONDOWN:DestroyWindow(wnd);
    WM_DESTROY:begin
    //free all objects
      KillTimer(wnd,1);
      back.Release();
      surface.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(wnd,msg,wparam,lparam);
    end;
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end;

begin
//window create
  RtlZeroMemory(addr(cls),sizeof(WNDCLASS));
  with cls do begin
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    hInstance:=hINSTANCE;    
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:="Demo5_3";
  end;
  RegisterClass(cls);
  main:=CreateWindowEx(WS_EX_TOPMOST,"Demo5_3","Demo5_3",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(main,SW_SHOW);
  UpdateWindow(main);

//message cikl
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;
  ExitProcess(0)
end.


