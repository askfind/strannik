//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 10:�������
//���� �����    1:������
module Test10_1;
import Win32;

const INSTANCE=0x400000;

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

procedure procDlg(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_COMMAND:case loword(wParam) of
      IDOK:EndDialog(hWnd,1);|
      IDCANCEL:EndDialog(hWnd,0);|
    end;|
    else return(false);
  end
end procDlg;

begin
  DialogBoxParam(INSTANCE,"������",0,addr(procDlg),0);
end Test10_1.

