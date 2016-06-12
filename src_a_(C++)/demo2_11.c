// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.11:Use Calendar Control

include Win32

define hINSTANCE 0x400000

  INITCOMMONCONTROLSEX struc;
  SYSTEMTIME time,date;

//dialog
dialog DLG_CAL 126,61,171,142,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_11"
begin
  control "",100,"SysMonthCal32",WS_BORDER | WS_CHILD | WS_VISIBLE | MCS_DAYSTATE,32,8,111,100
  control "Îê",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,66,120,52,14
end;

//dialog function
bool procDLG_CAL(HWND wnd, int message, int wparam, int lparam) 
{
  switch(message) {
    case WM_INITDIALOG:SendDlgItemMessage(wnd,100,MCM_SETCURSEL,0,(int)(&date)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:SendDlgItemMessage(wnd,100,MCM_GETCURSEL,0,(int)(&date)); EndDialog(wnd,1); break;
    } break;
  default:return false; break;
  }
  return true;
}

//integer output
void mbI(int i, char* title)
{ char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

void main() {
//common controls init
  struc.dwSize=sizeof(INITCOMMONCONTROLSEX);
  struc.dwICC=ICC_DATE_CLASSES;
  InitCommonControlsEx(struc);
//date init
  RtlZeroMemory(&date,sizeof(SYSTEMTIME));
  with(date) {
    wYear=2004;
    wMonth=8;
    wDay=15;
  }
//call dialog
  DialogBoxParam(hINSTANCE,"DLG_CAL",0,addr(procDLG_CAL),0);
//exit result
  with(date) {
    mbI(wDay,"Day:");
    mbI(wMonth,"Month:");
    mbI(wYear,"Year:");
  }
}

