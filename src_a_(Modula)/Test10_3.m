//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 10:�������
//���� �����    3:������
module Test10_3;
import Win32;

const 
  hINSTANCE=0x400000;
  ���������="Strannik";

icon "Test10_3.bmp";

procedure ��������(����:HWND; ����,������,������:cardinal):boolean;
var dc:HDC; ����:HICON; ������:PAINTSTRUCT;
begin
  case ���� of
    WM_CREATE:return(true);|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(����,����,������,������));|
    WM_PAINT:
      dc:=BeginPaint(����,������);
      ����:=LoadIcon(hINSTANCE,pstr(0x0000));
      DrawIcon(dc,10,10,����);
      DestroyIcon(����);
      EndPaint(����,������);|
    else return(DefWindowProc(����,����,������,������));
  end
end ��������;

var
  ��������:WNDCLASS;
  �������:HWND;
  �����:MSG;

begin

//����������� ������
  with �������� do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(��������);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;
    hIcon:=LoadIcon(hINSTANCE,pstr(0x0000));
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=���������;
  end;
  RegisterClass(��������);
                     
//�������� ����
  �������:=CreateWindowEx(0,���������,"Test10_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);

//���� ���������
  while GetMessage(�����,0,0,0) do
    TranslateMessage(�����);
    DispatchMessage(�����);
  end;

end Test10_3.

