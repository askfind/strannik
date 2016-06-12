// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.11:��������� (Calendar Control)

include Win32

define hINSTANCE 0x400000

  INITCOMMONCONTROLSEX ������;
  SYSTEMTIME ����;

//������ ���������
dialog DLG_CAL 126,61,171,142,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_11"
begin
  control "",100,"SysMonthCal32",WS_BORDER | WS_CHILD | WS_VISIBLE | MCS_DAYSTATE,32,8,111,100
  control "��",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,66,120,52,14
end;

//���������� ������� ���������
bool procDLG_CAL(HWND wnd, int message, int wparam, int lparam) 
{
  switch(message) {
    case WM_INITDIALOG:SendDlgItemMessage(wnd,100,MCM_SETCURSEL,0,(int)(&����)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:SendDlgItemMessage(wnd,100,MCM_GETCURSEL,0,(int)(&����)); EndDialog(wnd,1); break;
    } break;
  default:return false; break;
  }
  return true;
}

//����� ������
void mbI(int i, char* title)
{ char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

void main() {
//������������� ����������
  ������.dwSize=sizeof(INITCOMMONCONTROLSEX);
  ������.dwICC=ICC_DATE_CLASSES;
  InitCommonControlsEx(������);
//������������� ����
  RtlZeroMemory(&����,sizeof(SYSTEMTIME));
  with(����) {
    wYear=2004;
    wMonth=8;
    wDay=15;
  }
//����� �������
  DialogBoxParam(hINSTANCE,"DLG_CAL",0,&procDLG_CAL,0);
//����� �����������
  with(����) {
    mbI(wDay,"�����:");
    mbI(wMonth,"�����:");
    mbI(wYear,"���:");
  }
}

