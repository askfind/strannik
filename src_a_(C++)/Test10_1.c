//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 10:�������
//���� �����    1:������

include Win32

define INSTANCE 0x400000

//================= �������� ������� ======================

dialog ������ 21,53,263,84,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_VISIBLE | DS_MODALFRAME,
  "��������� ���������:"
begin
  control "������", -1, "Static", SS_CENTER | WS_CHILD | WS_VISIBLE,34, 17, 156, 16
  control "������", 100, "Button", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,34, 34, 58, 16
  control "��",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,79,66,44,13
  control "������",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,128,66,44,13
end;

//================= ���������� ������� ======================

boolean procDlg(HWND hWnd,int msg,int wParam,int lParam)
{
  switch(msg) {
    case WM_COMMAND:switch(loword(wParam)) {
      case IDOK:EndDialog(hWnd,1); break;
      case IDCANCEL:EndDialog(hWnd,0); break;
    } break;
    default:return(false);
  }
}

void main()
{
  DialogBoxParam(INSTANCE,"������",0,&procDlg,0);
}

