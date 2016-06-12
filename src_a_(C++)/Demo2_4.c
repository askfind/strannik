// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.4:Use Trackbar

include Win32

define hINSTANCE 0x400000
define id1 102
define id2 200
define id3 1000

//================= init trackbar =======================

void id4(HWND id5, uint id6)
{
  InitCommonControls();
//range 1 to 100
  SendMessage(GetDlgItem(id5,id6),TBM_SETRANGE,(int)true,1+100*0x10000);
//Rough step through 10
  SendMessage(GetDlgItem(id5,id6),TBM_SETPAGESIZE,0,10);
//Exact step through 1
  SendMessage(GetDlgItem(id5,id6),TBM_SETLINESIZE,0,1);
//init 50
  SendMessage(GetDlgItem(id5,id6),TBM_SETPOS,(int)true,50);
  SetDlgItemInt(id5,id1,50,true);
}

//================= processing of the notices from the window =======================

void id7(HWND id5, uint id6, uint wparam)
{int id8;
  switch(loword(wparam)) {
    case SB_THUMBTRACK:
      id8=hiword(wparam);
      SetDlgItemInt(id5,id1,id8,true);
    break;
  }
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:id4(wnd,id3); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK: case id2:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_HSCROLL:id7(wnd,id3,wparam); break;
    default:return false; break;
  }
  return true;
}

//================= call dialog ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

