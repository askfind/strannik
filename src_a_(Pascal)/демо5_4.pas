// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 4:�������� �����
program Demo5_4;
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

const
  ������=20;
  �����������=100;
  ��������=2;

var  �����,���:integer;

//������� �������
function wndProc(wnd:HWND; msg,wparam,lparam:dword):boolean;
var �����:pstr; ������,�����:integer; dc:HDC; �����,������:HBRUSH; ���:RECT;
begin
  case msg of
    WM_CREATE:begin
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
      �����:=50;
      ���:=��������;
      SetTimer(wnd,1,10,nil); //�������� ������ 0.01 �������
    end;
    WM_TIMER:begin
      if ���������������.GetDC(addr(dc))=DD_OK then begin
      //������ ���
        �����:=CreateSolidBrush(0x000000);
        ������:=SelectObject(dc,�����);
        ���.left:=0;
        ���.top:=0;
        ���.right:=1024;
        ���.bottom:=786;
        FillRect(dc,���,�����);
        SelectObject(dc,������);
        DeleteObject(�����);
    //��������� ������
        �����:=CreateSolidBrush(0xFF0000);
        ������:=SelectObject(dc,�����);
        Ellipse(dc,�����-������,�����������-������,�����+������,�����������+������);
        SelectObject(dc,������);
        DeleteObject(�����);
        ���������������.ReleaseDC(dc);
    //����� ������������
        �����������.Flip(nil,0);
      end;
    //������������ ������
      inc(�����,���);
      if �����>900 then ���:=-��������;
      if �����<100 then ���:=��������;
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
    lpszClassName:="Demo5_4";
  end;
  RegisterClass(�����);                     
  ����:=CreateWindowEx(WS_EX_TOPMOST,"Demo5_4","Demo5_4",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(����,SW_SHOW);
  UpdateWindow(����);

//���� ���������
  while GetMessage(���������,0,0,0) do begin
    TranslateMessage(���������);
    DispatchMessage(���������);
  end;
  ExitProcess(0)
end.

