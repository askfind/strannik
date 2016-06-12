// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.5:������������� avi-������

module Demo2_5;
import Win32;

const 
  hINSTANCE=0x400000;

  ������=100;
  �������=101;
  ������=102;
  ����=200;
  ��������=1000;

  ��������AVI="filecopy.avi";

//================= ������������ ������ =======================

procedure ������������������(�������:HWND; ��:cardinal);
begin
  InitCommonControls();
  SendMessage(GetDlgItem(�������,��),ACM_OPEN,0,integer(��������AVI));
  SetDlgItemText(�������,������,��������AVI);
end ������������������;

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_5:������������� avi-������"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",������,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,41,5,68,12
  control "",��������,"SysAnimate32",WS_CHILD | WS_VISIBLE | WS_BORDER | ACS_CENTER | ACS_TRANSPARENT,5,24,149,21
  control "����",������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,114,5,34,12
  control "�����",�������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,3,5,34,12
end;

//================= ���������� ������� =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:������������������(wnd,��������);|
    WM_COMMAND:case loword(wparam) of
      �������:SendDlgItemMessage(wnd,��������,ACM_PLAY,-1,60*0x10000);| //��������� 60 ���
      ������:SendDlgItemMessage(wnd,��������,ACM_STOP,0,0);|
      IDOK,����:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= ����� ������� ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end Demo2_5.

