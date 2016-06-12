// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.4:������ Trackbar

include Win32

define hINSTANCE 0x400000
define ��������� 102
define ���� 200
define �������� 1000

//================= ������������ ������ =======================

void ������������������(HWND �������, uint ��)
{
  InitCommonControls();
//�������� �������� �� 1 �� 100
  SendMessage(GetDlgItem(�������,��),TBM_SETRANGE,(int)true,1+100*0x10000);
//������ ��� ����� 10
  SendMessage(GetDlgItem(�������,��),TBM_SETPAGESIZE,0,10);
//������ ��� ����� 1
  SendMessage(GetDlgItem(�������,��),TBM_SETLINESIZE,0,1);
//��������� �������� 50
  SendMessage(GetDlgItem(�������,��),TBM_SETPOS,(int)true,50);
  SetDlgItemInt(�������,���������,50,true);
}

//================= ��������� ��������� �� ���� =======================

void ���������������������������(HWND �������, uint ��, uint wparam)
{int �������;
  switch(loword(wparam)) {
    case SB_THUMBTRACK:
      �������=hiword(wparam);
      SetDlgItemInt(�������,���������,�������,true);
    break;
  }
}

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_4:������ Trackbar"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",���������,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,65,30,25,13
  control "",��������,"msctls_trackbar32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TBS_HORZ | TBS_BOTTOM,5,4,150,20
end;

//================= ���������� ������� =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:������������������(wnd,��������); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK: case ����:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_HSCROLL:���������������������������(wnd,��������,wparam); break;
    default:return false; break;
  }
  return true;
}

//================= ����� ������� ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

