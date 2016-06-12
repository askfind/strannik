// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.7: нопки Up-Down

include Win32

define hINSTANCE 0x400000

define ид–едактор 100
define идќк 200

//================= инициировать updown =======================

void »нициироватьUpDown(HWND главное, HWND редактор, int верхнее, int нижнее, int начальное, int шаг)
{UDACCEL структ; HWND окноUpDown;

  InitCommonControls();
  окноUpDown=CreateUpDownControl(WS_CHILD | WS_BORDER | WS_VISIBLE | UDS_ALIGNRIGHT | UDS_SETBUDDYINT,
    0,0,0,0,главное,0,hINSTANCE,редактор,верхнее,нижнее,начальное);
  with(структ) {
     nSec=1; //после секундного нажати€
     nInc=шаг; //мен€ть через шаг
  }
  SendMessage(окноUpDown,UDM_SETACCEL,1,(int)(&структ));
}

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,37,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_7: нопки Up-Down"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,21,45,14
  control "",ид–едактор,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,52,6,50,10
end;

//================= диалогова€ функци€ =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:»нициироватьUpDown(wnd,GetDlgItem(wnd,ид–едактор),100,0,50,5); break;
    case WM_COMMAND:switch(loword(wparam)) {
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

