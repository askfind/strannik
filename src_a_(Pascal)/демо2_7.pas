// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.7: нопки Up-Down

program Demo2_7;
uses Win32;

const 
  hINSTANCE=0x400000;

  ид–едактор=100;
  идќк=200;

//================= инициировать updown =======================

procedure »нициироватьUpDown(главное,редактор:HWND; верхнее,нижнее,начальное,шаг:integer);
var структ:UDACCEL; окноUpDown:HWND;
begin
  InitCommonControls();
  окноUpDown:=CreateUpDownControl(WS_CHILD | WS_BORDER | WS_VISIBLE | UDS_ALIGNRIGHT | UDS_SETBUDDYINT,
    0,0,0,0,главное,0,hINSTANCE,редактор,верхнее,нижнее,начальное);
  with структ do begin
     nSec:=1; //после секундного нажати€
     nInc:=шаг; //мен€ть через шаг
  end;
  SendMessage(окноUpDown,UDM_SETACCEL,1,integer(addr(структ)));
end;

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,37,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_7: нопки Up-Down"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,21,45,14
  control "",ид–едактор,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,52,6,50,10
end;

//================= диалогова€ функци€ =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:»нициироватьUpDown(wnd,GetDlgItem(wnd,ид–едактор),100,0,50,5);
    WM_COMMAND:case loword(wparam) of
      IDOK,идќк:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= вызов диалога ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

