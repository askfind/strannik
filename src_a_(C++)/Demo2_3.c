// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.3:Use Progressbar

include Win32

define hINSTANCE 0x400000

define id1 100
define id2 101
define id3 102
define id4 200
define id5 1000

//================= init progressbar =======================

void id6(HWND id7, uint id8)
{
  InitCommonControls();
//range 1 to 100
  SendMessage(GetDlgItem(id7,id8),PBM_SETRANGE,0,1+100*0x10000);
//step 1
  SendMessage(GetDlgItem(id7,id8),PBM_SETSTEP,1,0);
//init 50
  SendMessage(GetDlgItem(id7,id8),PBM_SETPOS,50,0);
  SetDlgItemInt(id7,id3,50,true);
}

//================= down 10 percent =======================

void id9(HWND id7, uint id8)
{int id10;
  id10=SendMessage(GetDlgItem(id7,id8),PBM_DELTAPOS,0,0);
  id10--10;
  if(id10<1) id10=1;
  SendMessage(GetDlgItem(id7,id8),PBM_SETPOS,id10,0);
  SetDlgItemInt(id7,id3,id10,true);
}

//================= up 10 percent =======================

void id11(HWND id7, uint id8)
{int id10;
  id10=SendMessage(GetDlgItem(id7,id8),PBM_DELTAPOS,0,0);
  id10++10;
  if(id10>100) id10=100;
  SendMessage(GetDlgItem(id7,id8),PBM_SETPOS,id10,0);
  SetDlgItemInt(id7,id3,id10,true);
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:id6(wnd,id5); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case id1:id9(wnd,id5); break;
      case id2:id11(wnd,id5); break;
      case IDOK: case id4:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
  default:return false; break;
  }
  return true;
}

//================= call dialog ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

