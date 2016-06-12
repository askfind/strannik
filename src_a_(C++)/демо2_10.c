// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.10:���� ���� � ������� (Date and Time Picker Controls)

include Win32

define hINSTANCE 0x400000

  INITCOMMONCONTROLSEX ������;
  SYSTEMTIME �����,����;

//������ ����� ������� � ����
dialog DLG_TIME 126,61,256,88,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_10"
begin
  control "��",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,92,68,72,14
  control "",100,"SysDateTimePick32",WS_BORDER | WS_CHILD | WS_VISIBLE,32,8,70,15
  control "",101,"SysDateTimePick32",WS_BORDER | WS_CHILD | WS_VISIBLE | DTS_TIMEFORMAT,157,8,70,15
end;

//���������� ������� ����� ������� � ����
bool procDLG_TIME(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:
      SendDlgItemMessage(wnd,100,DTM_SETSYSTEMTIME,GDT_VALID,(int)(&����));
      SendDlgItemMessage(wnd,101,DTM_SETSYSTEMTIME,GDT_VALID,(int)(&�����));
      break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:
        SendDlgItemMessage(wnd,100,DTM_GETSYSTEMTIME,0,(int)(&����));
        SendDlgItemMessage(wnd,101,DTM_GETSYSTEMTIME,0,(int)(&�����));
        EndDialog(wnd,1);
        break;
    } break;
  default:return false; break;
  }
  return true;
}

//����� ������
void mbI(int i, char* title)
{char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

void main()
{
//������������� ����������
  ������.dwSize=sizeof(INITCOMMONCONTROLSEX);
  ������.dwICC=ICC_DATE_CLASSES;
  InitCommonControlsEx(������);
//������������� ���� � �������
  RtlZeroMemory(&�����,sizeof(SYSTEMTIME));
  with(�����) {
    wHour=12;
    wMinute=35;
    wSecond=10;
  }
  RtlZeroMemory(&����,sizeof(SYSTEMTIME));
  with(����) {
    wYear=2004;
    wMonth=8;
    wDay=15;
  }
//����� �������
  DialogBoxParam(hINSTANCE,"DLG_TIME",0,&procDLG_TIME,0);
//����� �����������
  with(�����) {
    mbI(wHour,"�����:");
    mbI(wMinute,"�����:");
    mbI(wSecond,"������:");
  }
  with(����) {
    mbI(wDay,"�����:");
    mbI(wMonth,"�����:");
    mbI(wYear,"���:");
  }
}

