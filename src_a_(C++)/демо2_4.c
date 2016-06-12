// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.4:ƒвижок Trackbar

include Win32

define hINSTANCE 0x400000
define идѕроцент 102
define идќк 200
define идƒвижок 1000

//================= инициировать движок =======================

void »нициироватьƒвижок(HWND главное, uint ид)
{
  InitCommonControls();
//диапазон значений от 1 до 100
  SendMessage(GetDlgItem(главное,ид),TBM_SETRANGE,(int)true,1+100*0x10000);
//грубый шаг через 10
  SendMessage(GetDlgItem(главное,ид),TBM_SETPAGESIZE,0,10);
//точный шаг через 1
  SendMessage(GetDlgItem(главное,ид),TBM_SETLINESIZE,0,1);
//начальное значение 50
  SendMessage(GetDlgItem(главное,ид),TBM_SETPOS,(int)true,50);
  SetDlgItemInt(главное,идѕроцент,50,true);
}

//================= обработка извещений от окна =======================

void ќбработать»звещениеќтƒвижка(HWND главное, uint ид, uint wparam)
{int текущий;
  switch(loword(wparam)) {
    case SB_THUMBTRACK:
      текущий=hiword(wparam);
      SetDlgItemInt(главное,идѕроцент,текущий,true);
    break;
  }
}

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_4:ƒвижок Trackbar"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",идѕроцент,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,65,30,25,13
  control "",идƒвижок,"msctls_trackbar32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TBS_HORZ | TBS_BOTTOM,5,4,150,20
end;

//================= диалогова€ функци€ =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:»нициироватьƒвижок(wnd,идƒвижок); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK: case идќк:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_HSCROLL:ќбработать»звещениеќтƒвижка(wnd,идƒвижок,wparam); break;
    default:return false; break;
  }
  return true;
}

//================= вызов диалога ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

