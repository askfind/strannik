// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 3:������������ ������������
program Demo5_3;
uses Win32;

const hINSTANCE=0x400000;

var
  ����:HWND;
  �����:WNDCLASS;
  ���������:MSG;

  ddraw:pDIRECTDRAW;
  ddscaps:DDSCAPS;
  �����������,���������������:pDIRECTDRAWSURFACE;
  ���������:DDSURFACEDESC;
  �������������:boolean;

//������� �������
function wndProc(wnd:HWND; msg,wparam,lparam:dword):boolean;
var �����:pstr; ������,�����:integer; dc:HDC;
begin
  case msg of
    WM_CREATE: begin
    //�������� ������� DirectDraw � ����������� � ��������������� �������
      DirectDrawCreate(nil,addr(ddraw),nil);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(addr(���������),sizeof(DDSURFACEDESC));
      ���������.dwSize:=sizeof(DDSURFACEDESC);
      ���������.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
      ���������.dwFlags:=DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
      ���������.dwBackBufferCount:=1;
      ddraw.CreateSurface(addr(���������),addr(�����������),nil);
      ddscaps.dwCaps:=DDSCAPS_BACKBUFFER;
      �����������.GetAttachedSurface(addr(ddscaps),addr(���������������));
      �������������:=false;
      SetTimer(wnd,1,1000,nil); //�������� ������ �������
    end;
    WM_TIMER:begin
    //������ ���
      if �����������.Lock(nil,addr(���������),DDLOCK_WAIT,0)=DD_OK then begin
        RtlFillMemory(���������.lpSurface,���������.lPitch*���������.dwHeight,0x00);
        �����������.Unlock(���������.lpSurface);
      end;
    //����� ������
      if ���������������.GetDC(addr(dc))=DD_OK then begin
        SetBkColor(dc,0x000000);
        SetTextColor(dc,0x00FF00);
        if �������������
          then TextOut(dc,0,0,"Front",lstrlen("Front"))
          else TextOut(dc,0,0,"Back",lstrlen("Back"));
        ���������������.ReleaseDC(dc);
    //����� ������������
        �������������:=not �������������;
        �����������.Flip(nil,0);
      end;
    end;
    WM_KEYDOWN,WM_LBUTTONDOWN:DestroyWindow(wnd);
    WM_DESTROY:begin
    //������������ ��������
      KillTimer(wnd,1);
      ���������������.Release();
      �����������.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(����,msg,wparam,lparam);
    end;
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end;

begin
//�������� ����
  RtlZeroMemory(addr(�����),sizeof(WNDCLASS));
  with ����� do begin
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    hInstance:=hINSTANCE;    
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:="Demo5_2";
  end;
  RegisterClass(�����);                     
  ����:=CreateWindowEx(WS_EX_TOPMOST,"Demo5_2","Demo5_2",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(����,SW_SHOW);
  UpdateWindow(����);

//���� ���������
  while GetMessage(���������,0,0,0) do begin
    TranslateMessage(���������);
    DispatchMessage(���������);
  end;
  ExitProcess(0)
end.


