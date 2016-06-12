// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.5:ѕроигрыватель avi-файлов

module Demo2_5;
import Win32;

const 
  hINSTANCE=0x400000;

  ид‘айл=100;
  ид—тарт=101;
  ид—топ=102;
  идќк=200;
  идƒвижок=1000;

  им€‘айлаAVI="filecopy.avi";

//================= инициировать движок =======================

procedure »нициироватьƒвижок(главное:HWND; ид:cardinal);
begin
  InitCommonControls();
  SendMessage(GetDlgItem(главное,ид),ACM_OPEN,0,integer(им€‘айлаAVI));
  SetDlgItemText(главное,ид‘айл,им€‘айлаAVI);
end »нициироватьƒвижок;

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

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:»нициироватьƒвижок(wnd,идƒвижок);|
    WM_COMMAND:case loword(wparam) of
      ид—тарт:SendDlgItemMessage(wnd,идƒвижок,ACM_PLAY,-1,60*0x10000);| //повторить 60 раз
      ид—топ:SendDlgItemMessage(wnd,идƒвижок,ACM_STOP,0,0);|
      IDOK,идќк:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= вызов диалога ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end Demo2_5.

