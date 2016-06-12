// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.11:Use Calendar Control

program Demo2_11;
uses Win32;

const 
  hINSTANCE=0x400000;

var
  struc:INITCOMMONCONTROLSEX;
  date:SYSTEMTIME;

//dialog
dialog DLG_CAL 126,61,171,142,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_11"
begin
  control "",100,"SysMonthCal32",WS_BORDER | WS_CHILD | WS_VISIBLE | MCS_DAYSTATE,32,8,111,100
  control "Îê",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,66,120,52,14
end;

//dialog function
function procDLG_CAL(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:SendDlgItemMessage(wnd,100,MCM_SETCURSEL,0,integer(addr(date)));
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:begin SendDlgItemMessage(wnd,100,MCM_GETCURSEL,0,integer(addr(date))); EndDialog(wnd,1) end;
    end;
  else return false
  end;
  return true
end;

//integer output
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end;

begin
//common controls init
  struc.dwSize:=sizeof(INITCOMMONCONTROLSEX);
  struc.dwICC:=ICC_DATE_CLASSES;
  InitCommonControlsEx(struc);
//date init
  RtlZeroMemory(addr(date),sizeof(SYSTEMTIME));
  with date do begin
    wYear:=2004;
    wMonth:=8;
    wDay:=15;
  end;
//call dialog
  DialogBoxParam(hINSTANCE,"DLG_CAL",0,addr(procDLG_CAL),0);
//exit result
  with date do begin
    mbI(wDay,"Day:");
    mbI(wMonth,"Month:");
    mbI(wYear,"Year:");
  end;
end.

