// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.5:������������� avi-������

include Win32

define hINSTANCE 0x400000

define ������ 100
define ������� 101
define ������ 102
define ���� 200
define �������� 1000

define ��������AVI "filecopy.avi"

//================= ������������ ������ =======================

void ������������������(HWND �������, uint ��)
{
  InitCommonControls();
  SendMessage(GetDlgItem(�������,��),ACM_OPEN,0,(int)��������AVI);
  SetDlgItemText(�������,������,��������AVI);
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:������������������(wnd,��������); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case �������:SendDlgItemMessage(wnd,��������,ACM_PLAY,-1,60*0x10000); break; //��������� 60 ���
      case ������:SendDlgItemMessage(wnd,��������,ACM_STOP,0,0); break;
      case IDOK: case ����:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    default:return false; break;
  }
  return true;
}

//================= ����� ������� ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

