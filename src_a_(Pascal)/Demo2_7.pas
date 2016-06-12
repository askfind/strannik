// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.7:Up-Down buttons

program Demo2_7;
uses Win32;

const 
  hINSTANCE=0x400000;

  id1=100;
  id2=200;

//================= init updown =======================

procedure id3(id4,id5:HWND; id6,id7,id8,id9:integer);
var id10:UDACCEL; id11:HWND;
begin
  InitCommonControls();
  id11:=CreateUpDownControl(WS_CHILD | WS_BORDER | WS_VISIBLE | UDS_ALIGNRIGHT | UDS_SETBUDDYINT,
    0,0,0,0,id4,0,hINSTANCE,id5,id6,id7,id8);
  with id10 do begin
     nSec:=1; //after 1-secund press
     nInc:=id9; //change for step
  end;
  SendMessage(id11,UDM_SETACCEL,1,integer(addr(id10)));
end;

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,37,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_7:Up-Down buttons"
begin
  control "Ok",id2,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,21,45,14
  control "",id1,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,52,6,50,10
end;

//================= dilaog function =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:id3(wnd,GetDlgItem(wnd,id1),100,0,50,5);
    WM_COMMAND:case loword(wparam) of
      IDOK,id2:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= call dialog ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

