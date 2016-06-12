// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.10:Use Date and Time Picker Controls

include Win32

define hINSTANCE 0x400000

  INITCOMMONCONTROLSEX struc;
  SYSTEMTIME time,date;

//dialog
dialog DLG_TIME 126,61,256,88,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_10"
begin
  control "Îê",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,92,68,72,14
  control "",100,"SysDateTimePick32",WS_BORDER | WS_CHILD | WS_VISIBLE,32,8,70,15
  control "",101,"SysDateTimePick32",WS_BORDER | WS_CHILD | WS_VISIBLE | DTS_TIMEFORMAT,157,8,70,15
end;

//dialog function
bool procDLG_TIME(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:
      SendDlgItemMessage(wnd,100,DTM_SETSYSTEMTIME,GDT_VALID,(int)(&date));
      SendDlgItemMessage(wnd,101,DTM_SETSYSTEMTIME,GDT_VALID,(int)(&time));
      break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:
        SendDlgItemMessage(wnd,100,DTM_GETSYSTEMTIME,0,(int)(&date));
        SendDlgItemMessage(wnd,101,DTM_GETSYSTEMTIME,0,(int)(&time));
        EndDialog(wnd,1);
        break;
    } break;
  default:return false; break;
  }
  return true;
}

//integer output
void mbI(int i, char* title)
{char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

void main() {
//common controls init
  struc.dwSize=sizeof(INITCOMMONCONTROLSEX);
  struc.dwICC=ICC_DATE_CLASSES;
  InitCommonControlsEx(struc);
//time and date init
  RtlZeroMemory(addr(time),sizeof(SYSTEMTIME));
  with(time) {
    wHour=12;
    wMinute=35;
    wSecond=10;
  }
  RtlZeroMemory(addr(date),sizeof(SYSTEMTIME));
  with(date) {
    wYear=2004;
    wMonth=8;
    wDay=15;
  }
//call dialog
  DialogBoxParam(hINSTANCE,"DLG_TIME",0,&procDLG_TIME,0);
//result output
  with(time) {
    mbI(wHour,"Hour:");
    mbI(wMinute,"Minute:");
    mbI(wSecond,"Second:");
  }
  with(date) {
    mbI(wDay,"Day:");
    mbI(wMonth,"Month:");
    mbI(wYear,"Year:");
  }
}

