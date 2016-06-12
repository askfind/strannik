// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.5:ѕроигрыватель avi-файлов

include Win32

define hINSTANCE 0x400000

define ид‘айл 100
define ид—тарт 101
define ид—топ 102
define идќк 200
define идƒвижок 1000

define им€‘айлаAVI "filecopy.avi"

//================= инициировать движок =======================

void »нициироватьƒвижок(HWND главное, uint ид)
{
  InitCommonControls();
  SendMessage(GetDlgItem(главное,ид),ACM_OPEN,0,(int)им€‘айлаAVI);
  SetDlgItemText(главное,ид‘айл,им€‘айлаAVI);
}

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_5:ѕроигрыватель avi-файлов"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",ид‘айл,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,41,5,68,12
  control "",идƒвижок,"SysAnimate32",WS_CHILD | WS_VISIBLE | WS_BORDER | ACS_CENTER | ACS_TRANSPARENT,5,24,149,21
  control "—топ",ид—топ,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,114,5,34,12
  control "—тарт",ид—тарт,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,3,5,34,12
end;

//================= диалогова€ функци€ =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:»нициироватьƒвижок(wnd,идƒвижок); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case ид—тарт:SendDlgItemMessage(wnd,идƒвижок,ACM_PLAY,-1,60*0x10000); break; //повторить 60 раз
      case ид—топ:SendDlgItemMessage(wnd,идƒвижок,ACM_STOP,0,0); break;
      case IDOK: case идќк:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    default:return false; break;
  }
  return true;
}

//================= вызов диалога ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

