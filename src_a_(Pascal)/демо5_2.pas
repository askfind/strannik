// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 2:��������� �����
program Demo5_2;
uses Win32;

const hINSTANCE=0x400000;

var
  ����:HWND;
  �����:WNDCLASS;
  ���������:MSG;

  ddraw:pDIRECTDRAW;
  �����������:pDIRECTDRAWSURFACE;
  ���������:DDSURFACEDESC;

//������� �������
function wndProc(wnd:HWND; msg,wparam,lparam:dword):boolean;
var �����:pstr; ������,�����:integer;
begin
  case msg of
    WM_CREATE:begin
    //�������� ������� DirectDraw � �����������
      DirectDrawCreate(nil,addr(ddraw),nil);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(addr(���������),sizeof(DDSURFACEDESC));
      ���������.dwSize:=sizeof(DDSURFACEDESC);
      ���������.ddsCaps.dwCaps:=DDSCAPS_PRIMARYSURFACE;
      ���������.dwFlags:=DDSD_CAPS;
      ddraw.CreateSurface(addr(���������),addr(�����������),nil);
      SetTimer(wnd,1,500,nil); //�������� ������ 0.5 �������
    end;
    WM_TIMER:begin
    //��������� �����
      if �����������.Lock(nil,addr(���������),DDLOCK_WAIT,0)=DD_OK then begin
        RtlFillMemory(���������.lpSurface,���������.lPitch*���������.dwHeight,0x00);
        �����:=���������.lpSurface;
        ������:=���������.lPitch*100; //������ 100
        for �����:=0 to ���������.dwWidth-1 do begin
          �����[������+�����*4+0]:=char(0xFF); //����� ����
          �����[������+�����*4+1]:=char(0x00);
          �����[������+�����*4+2]:=char(0x00);
          �����[������+�����*4+3]:=char(0x00);
        end;
        �����������.Unlock(���������.lpSurface);
      end;
    end;
    WM_KEYDOWN,WM_LBUTTONDOWN:DestroyWindow(wnd);
    WM_DESTROY:begin
    //������������ ��������
      KillTimer(wnd,1);
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


