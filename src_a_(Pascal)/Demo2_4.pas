// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.4:Use Trackbar

program Demo2_4;
uses Win32;

const 
  hINSTANCE=0x400000;

  id1=102;
  id2=200;
  id3=1000;

//================= init trackbar =======================

procedure id4(id5:HWND; id6:dword);
begin
  InitCommonControls();
//range 1 to 100
  SendMessage(GetDlgItem(id5,id6),TBM_SETRANGE,integer(true),1+100*0x10000);
//Rough step through 10
  SendMessage(GetDlgItem(id5,id6),TBM_SETPAGESIZE,0,10);
//Exact step through 1
  SendMessage(GetDlgItem(id5,id6),TBM_SETLINESIZE,0,1);
//init 50
  SendMessage(GetDlgItem(id5,id6),TBM_SETPOS,integer(true),50);
  SetDlgItemInt(id5,id1,50,true);
end;

//================= processing of the notices from the window =======================

procedure id7(id5:HWND; id6:dword; wparam:dword);
var id8:integer;
begin
  case loword(wparam) of
    SB_THUMBTRACK:begin
      id8:=hiword(wparam);
      SetDlgItemInt(id5,id1,id8,true);
    end;
  end;
end;

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_4:Trackbar"
begin
  control "Ok",id2,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",id1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,65,30,25,13
  control "",id3,"msctls_trackbar32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TBS_HORZ | TBS_BOTTOM,5,4,150,20
end;

//================= dialog function =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:id4(wnd,id3);
    WM_COMMAND:case loword(wparam) of
      IDOK,id2:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
    WM_HSCROLL:id7(wnd,id3,wparam);
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= call dialog ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

