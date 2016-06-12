// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.4:ƒвижок Trackbar

module Demo2_4;
import Win32;

const 
  hINSTANCE=0x400000;

  идѕроцент=102;
  идќк=200;
  идƒвижок=1000;

//================= инициировать движок =======================

procedure »нициироватьƒвижок(главное:HWND; ид:cardinal);
begin
  InitCommonControls();
//диапазон значений от 1 до 100
  SendMessage(GetDlgItem(главное,ид),TBM_SETRANGE,integer(true),1+100*0x10000);
//грубый шаг через 10
  SendMessage(GetDlgItem(главное,ид),TBM_SETPAGESIZE,0,10);
//точный шаг через 1
  SendMessage(GetDlgItem(главное,ид),TBM_SETLINESIZE,0,1);
//начальное значение 50
  SendMessage(GetDlgItem(главное,ид),TBM_SETPOS,integer(true),50);
  SetDlgItemInt(главное,идѕроцент,50,true);
end »нициироватьƒвижок;

//================= обработка извещений от окна =======================

procedure ќбработать»звещениеќтƒвижка(главное:HWND; ид:cardinal; wparam:cardinal);
var текущий:integer;
begin
  case loword(wparam) of
    SB_THUMBTRACK:
      текущий:=hiword(wparam);
      SetDlgItemInt(главное,идѕроцент,текущий,true);|
  end;
end ќбработать»звещениеќтƒвижка;

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_4:ƒвижок Trackbar"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",идѕроцент,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,65,30,25,13
  control "",идƒвижок,"msctls_trackbar32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TBS_HORZ | TBS_BOTTOM,6,6,150,16
end;

//================= диалогова€ функци€ =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:»нициироватьƒвижок(wnd,идƒвижок);|
    WM_COMMAND:case loword(wparam) of
      IDOK,идќк:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
    WM_HSCROLL:ќбработать»звещениеќтƒвижка(wnd,идƒвижок,wparam);|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= вызов диалога ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end Demo2_4.

