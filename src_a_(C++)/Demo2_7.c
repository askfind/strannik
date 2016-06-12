// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.7:Up-Down buttons

include Win32

define hINSTANCE 0x400000

define id1 100
define id2 200

//================= init updown =======================

void id3(HWND id4, HWND id5, int id6, int id7, int id8, int id9)
{UDACCEL id10; HWND id11;

  InitCommonControls();
  id11=CreateUpDownControl(WS_CHILD | WS_BORDER | WS_VISIBLE | UDS_ALIGNRIGHT | UDS_SETBUDDYINT,
    0,0,0,0,id4,0,hINSTANCE,id5,id6,id7,id8);
  with(id10) {
     nSec=1; //after 1-secund press
     nInc=id9; //change for step
  }
  SendMessage(id11,UDM_SETACCEL,1,(int)(&id10));
}

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,37,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_7:Up-Down buttons"
begin
  control "Ok",id2,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,21,45,14
  control "",id1,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,52,6,50,10
end;

//================= dilaog function =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:id3(wnd,GetDlgItem(wnd,id1),100,0,50,5); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK: case id2:EndDialog(wnd,1); break;
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

