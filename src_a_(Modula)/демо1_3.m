// ��������  ������-��-������� ��� Win32
// ���������������� ���������
// ���� 3:��������� � ����
module Demo1_3;
import Win32;

const 
  hINSTANCE=0x400000;
  ���������="Strannik";

  ���������=100;
  �����������=101;
  �������������=102;
  ���������=200;

var
  ��������:WNDCLASS;
  �������:HWND;
  �����:MSG;

//================= �������� ���� =======================

procedure ��������(����:HWND);
var �������,��������:HMENU;
begin
  �������:=CreateMenu();

  ��������:=CreatePopupMenu();
  AppendMenu(��������,MF_STRING|MF_ENABLED,���������,"�����");
  AppendMenu(��������,MF_STRING|MF_ENABLED,�����������,"�������");
  AppendMenu(��������,MF_STRING|MF_ENABLED,�������������,"���������");
  AppendMenu(�������,MF_POPUP|MF_ENABLED,��������,"����");

  AppendMenu(�������,MF_STRING|MF_ENABLED,���������,"�����");
  SetMenu(����,�������);
end ��������;

//================= ������� ������� ======================

procedure ��������(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_CREATE:return(true);|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam));|
    WM_COMMAND:case word(wParam) of
      ���������:MessageBox(0,"�����","����:",0);|
      �����������:MessageBox(0,"�������","����:",0);|
      �������������:MessageBox(0,"���������","����:",0);|
      ���������:MessageBox(0,"�����","����:",0);|
    end;|
    else return(DefWindowProc(hWnd,msg,wParam,lParam));
  end
end ��������;

//================= �������� ��������� ====================

begin

//����������� ������
  with �������� do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(��������);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=���������;
  end;
  RegisterClass(��������);
                     
//�������� ����
  �������:=CreateWindowEx(0,���������,"Beta1_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);

//�������� ����
  ��������(�������);

//���� ���������
  while GetMessage(�����,0,0,0) do
    TranslateMessage(�����);
    DispatchMessage(�����);
  end;

end Demo1_3.

