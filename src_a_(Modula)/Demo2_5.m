// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.5:Player of avi-files

module Demo2_5;
import Win32;

const 
  hINSTANCE=0x400000;

  id1=100;
  id2=101;
  id3=102;
  id4=200;
  id5=1000;

  id6="filecopy.avi";

//================= ini player =======================

procedure id7(id8:HWND; id9:cardinal);
begin
  InitCommonControls();
  SendMessage(GetDlgItem(id8,id9),ACM_OPEN,0,integer(id6));
  SetDlgItemText(id8,id1,id6);
end id7;

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_5:Player of avi-files"
begin
  control "Ok",id4,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",id1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,41,5,68,12
  control "",id5,"SysAnimate32",WS_CHILD | WS_VISIBLE | WS_BORDER | ACS_CENTER | ACS_TRANSPARENT,5,24,149,21
  control "Stop",id3,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,114,5,34,12
  control "Start",id2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,3,5,34,12
end;

//================= dialog function =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:id7(wnd,id5);|
    WM_COMMAND:case loword(wparam) of
      id2:SendDlgItemMessage(wnd,id5,ACM_PLAY,-1,60*0x10000);| //repeat 60 times
      id3:SendDlgItemMessage(wnd,id5,ACM_STOP,0,0);|
      IDOK,id4:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= call dialog ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end Demo2_5.

