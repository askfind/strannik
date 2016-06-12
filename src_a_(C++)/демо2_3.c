// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.3:��������� Progressbar

include Win32

define hINSTANCE 0x400000

define �������� 100
define �������� 101
define ��������� 102
define ���� 200
define ����������� 1000

//================= ������������ ��������� =======================

void ���������������������(HWND �������, uint ��)
{
  InitCommonControls();
//�������� �������� �� 1 �� 100
  SendMessage(GetDlgItem(�������,��),PBM_SETRANGE,0,1+100*0x10000);
//��� ����� 1
  SendMessage(GetDlgItem(�������,��),PBM_SETSTEP,1,0);
//��������� �������� 50
  SendMessage(GetDlgItem(�������,��),PBM_SETPOS,50,0);
  SetDlgItemInt(�������,���������,50,true);
}

//================= ������ �� 10 ��������� =======================

void �������������(HWND �������, uint ��)
{int �������;
  �������=SendMessage(GetDlgItem(�������,��),PBM_DELTAPOS,0,0);
  �������--10;
  if(�������<1) �������=1;
  SendMessage(GetDlgItem(�������,��),PBM_SETPOS,�������,0);
  SetDlgItemInt(�������,���������,�������,true);
}

//================= ������ �� 10 ��������� =======================

void �������������(HWND �������, uint ��)
{int �������;
  �������=SendMessage(GetDlgItem(�������,��),PBM_DELTAPOS,0,0);
  �������++10;
  if(�������>100) �������=100;
  SendMessage(GetDlgItem(�������,��),PBM_SETPOS,�������,0);
  SetDlgItemInt(�������,���������,�������,true);
}

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,83,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_3:��������� Progress"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,54,64,45,14
  control "������",��������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,115,8,40,12
  control "������",��������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,6,8,40,12
  control "",�����������,"msctls_progress32",WS_CHILD | WS_VISIBLE | WS_BORDER,8,28,146,14
  control "",���������,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,64,43,25,13
end;

//================= ���������� ������� =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:���������������������(wnd,�����������); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case ��������:�������������(wnd,�����������); break;
      case ��������:�������������(wnd,�����������); break;
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

