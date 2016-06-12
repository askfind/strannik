// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.10:Use Date and Time Picker Controls

module Demo2_10;
import Win32;

const 
  hINSTANCE=0x400000;

var
  struc:INITCOMMONCONTROLSEX;
  time,date:SYSTEMTIME;

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
procedure procDLG_TIME(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:
      SendDlgItemMessage(wnd,100,DTM_SETSYSTEMTIME,GDT_VALID,integer(addr(date)));
      SendDlgItemMessage(wnd,101,DTM_SETSYSTEMTIME,GDT_VALID,integer(addr(time)));|
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:
        SendDlgItemMessage(wnd,100,DTM_GETSYSTEMTIME,0,integer(addr(date)));
        SendDlgItemMessage(wnd,101,DTM_GETSYSTEMTIME,0,integer(addr(time)));
        EndDialog(wnd,1);|
    end;|
  else return false
  end;
  return true
end procDLG_TIME;

//integer output
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end mbI;

begin
//common controls init
  struc.dwSize:=sizeof(INITCOMMONCONTROLSEX);
  struc.dwICC:=ICC_DATE_CLASSES;
  InitCommonControlsEx(struc);
//time and date init
  RtlZeroMemory(addr(time),sizeof(SYSTEMTIME));
  with time do
    wHour:=12;
    wMinute:=35;
    wSecond:=10;
  end;
  RtlZeroMemory(addr(date),sizeof(SYSTEMTIME));
  with date do
    wYear:=2004;
    wMonth:=8;
    wDay:=15;
  end;
//call dialog
  DialogBoxParam(hINSTANCE,"DLG_TIME",0,addr(procDLG_TIME),0);
//result output
  with time do
    mbI(wHour,"Hour:");
    mbI(wMinute,"Minute:");
    mbI(wSecond,"Second:");
  end;
  with date do
    mbI(wDay,"Day:");
    mbI(wMonth,"Month:");
    mbI(wYear,"Year:");
  end;
end Demo2_10.

