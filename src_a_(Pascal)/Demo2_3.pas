// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.3:Use Progressbar

program Demo2_3;
uses Win32;

const 
  hINSTANCE=0x400000;

  id1=100;
  id2=101;
  id3=102;
  id4=200;
  id5=1000;

//================= init progressbar =======================

procedure id6(id7:HWND; id8:dword);
begin
  InitCommonControls();
//range 1 to 100
  SendMessage(GetDlgItem(id7,id8),PBM_SETRANGE,0,1+100*0x10000);
//step 1
  SendMessage(GetDlgItem(id7,id8),PBM_SETSTEP,1,0);
//init 50
  SendMessage(GetDlgItem(id7,id8),PBM_SETPOS,50,0);
  SetDlgItemInt(id7,id3,50,true);
end;

//================= down 10 percent =======================

procedure id9(id7:HWND; id8:dword);
var id10:integer;
begin
  id10:=SendMessage(GetDlgItem(id7,id8),PBM_DELTAPOS,0,0);
  dec(id10,10);
  if id10<1 then id10:=1;
  SendMessage(GetDlgItem(id7,id8),PBM_SETPOS,id10,0);
  SetDlgItemInt(id7,id3,id10,true);
end;

//================= up 10 percent =======================

procedure id11(id7:HWND; id8:dword);
var id10:integer;
begin
  id10:=SendMessage(GetDlgItem(id7,id8),PBM_DELTAPOS,0,0);
  inc(id10,10);
  if id10>100 then id10:=100;
  SendMessage(GetDlgItem(id7,id8),PBM_SETPOS,id10,0);
  SetDlgItemInt(id7,id3,id10,true);
end;

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,83,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_3:Progressbar"
begin
  control "Ok",id4,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,54,64,45,14
  control "More",id2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,115,8,40,12
  control "Less",id1,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,6,8,40,12
  control "",id5,"msctls_progress32",WS_CHILD | WS_VISIBLE | WS_BORDER,8,28,146,14
  control "",id3,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,64,43,25,13
end;

//================= dialog function =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:id6(wnd,id5);
    WM_COMMAND:case loword(wparam) of
      id1:id9(wnd,id5);
      id2:id11(wnd,id5);
      IDOK,id4:EndDialog(wnd,1);
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

