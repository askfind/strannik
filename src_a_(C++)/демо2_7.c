// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.7:������ Up-Down

include Win32

define hINSTANCE 0x400000

define ���������� 100
define ���� 200

//================= ������������ updown =======================

void ������������UpDown(HWND �������, HWND ��������, int �������, int ������, int ���������, int ���)
{UDACCEL ������; HWND ����UpDown;

  InitCommonControls();
  ����UpDown=CreateUpDownControl(WS_CHILD | WS_BORDER | WS_VISIBLE | UDS_ALIGNRIGHT | UDS_SETBUDDYINT,
    0,0,0,0,�������,0,hINSTANCE,��������,�������,������,���������);
  with(������) {
     nSec=1; //����� ���������� �������
     nInc=���; //������ ����� ���
  }
  SendMessage(����UpDown,UDM_SETACCEL,1,(int)(&������));
}

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,37,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_7:������ Up-Down"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,21,45,14
  control "",����������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,52,6,50,10
end;

//================= ���������� ������� =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:������������UpDown(wnd,GetDlgItem(wnd,����������),100,0,50,5); break;
    case WM_COMMAND:switch(loword(wparam)) {
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

