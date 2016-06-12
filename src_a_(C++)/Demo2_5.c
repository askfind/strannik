// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.5:Player of avi-files

include Win32

define hINSTANCE 0x400000

define id1 100
define id2 101
define id3 102
define id4 200
define id5 1000

define id6 "filecopy.avi"

//================= ini player =======================

void id7(HWND id8, uint id9)
{
  InitCommonControls();
  SendMessage(GetDlgItem(id8,id9),ACM_OPEN,0,(int)id6);
  SetDlgItemText(id8,id1,id6);
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:id7(wnd,id5); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case id2:SendDlgItemMessage(wnd,id5,ACM_PLAY,-1,60*0x10000); break; //repeat 60 times
      case id3:SendDlgItemMessage(wnd,id5,ACM_STOP,0,0); break;
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

