// ��������  ������-��-������� ��� Win32
// ���������������� ���������
// ���� 2:��������� � �����
module Demo1_2;
import Win32;

const 
  hINSTANCE=0x400000;
  ���������="Strannik";

procedure ��������(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_CREATE:return true;|
    WM_DESTROY:PostQuitMessage(0); return DefWindowProc(hWnd,msg,wParam,lParam);|
    else return DefWindowProc(hWnd,msg,wParam,lParam);
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
    hIcon:=0;
    hCursor:=0;//LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=���������;
  end;
  RegisterClass(��������);
                     
//�������� ����
  �������:=CreateWindowEx(0,���������,'Demo1_2',WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);

//���� ���������
  while GetMessage(�����,0,0,0) do
    TranslateMessage(�����);
    DispatchMessage(�����);
  end;

end Demo1_2.

