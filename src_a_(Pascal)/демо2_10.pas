// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.10:���� ���� � ������� (Date and Time Picker Controls)

program Demo2_10;
uses Win32;

const 
  hINSTANCE=0x400000;

var
  ����:HWND;
  ������:INITCOMMONCONTROLSEX;
  �����,����:SYSTEMTIME;

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
function procDLG_TIME(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:begin
      SendDlgItemMessage(wnd,100,DTM_SETSYSTEMTIME,GDT_VALID,integer(addr(����)));
      SendDlgItemMessage(wnd,101,DTM_SETSYSTEMTIME,GDT_VALID,integer(addr(�����)));
    end;
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:begin
        SendDlgItemMessage(wnd,100,DTM_GETSYSTEMTIME,0,integer(addr(����)));
        SendDlgItemMessage(wnd,101,DTM_GETSYSTEMTIME,0,integer(addr(�����)));
        EndDialog(wnd,1);
      end;
    end;
  else return false
  end;
  return true
end;

//����� ������
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end;

begin
//������������� ����������
  ������.dwSize:=sizeof(INITCOMMONCONTROLSEX);
  ������.dwICC:=ICC_DATE_CLASSES;
  InitCommonControlsEx(������);
//������������� ���� � �������
  RtlZeroMemory(addr(�����),sizeof(SYSTEMTIME));
  with ����� do begin
    wHour:=12;
    wMinute:=35;
    wSecond:=10;
  end;
  RtlZeroMemory(addr(����),sizeof(SYSTEMTIME));
  with ���� do begin
    wYear:=2004;
    wMonth:=8;
    wDay:=15;
  end;
//����� �������
  DialogBoxParam(hINSTANCE,"DLG_TIME",0,addr(procDLG_TIME),0);
//����� �����������
  with ����� do begin
    mbI(wHour,"�����:");
    mbI(wMinute,"�����:");
    mbI(wSecond,"������:");
  end;
  with ���� do begin
    mbI(wDay,"�����:");
    mbI(wMonth,"�����:");
    mbI(wYear,"���:");
  end;
end.

