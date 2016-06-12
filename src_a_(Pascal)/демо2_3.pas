// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.3:»ндикатор Progressbar

program Demo2_3;
uses Win32;

const 
  hINSTANCE=0x400000;

  идћеньше=100;
  идЅольше=101;
  идѕроцент=102;
  идќк=200;
  ид»ндикатор=1000;

//================= инициировать индикатор =======================

procedure »нициировать»ндикатор(главное:HWND; ид:dword);
begin
  InitCommonControls();
//диапазон значений от 1 до 100
  SendMessage(GetDlgItem(главное,ид),PBM_SETRANGE,0,1+100*0x10000);
//шаг через 1
  SendMessage(GetDlgItem(главное,ид),PBM_SETSTEP,1,0);
//начальное значение 50
  SendMessage(GetDlgItem(главное,ид),PBM_SETPOS,50,0);
  SetDlgItemInt(главное,идѕроцент,50,true);
end;

//================= меньше на 10 процентов =======================

procedure командаћеньше(главное:HWND; ид:dword);
var текущий:integer;
begin
  текущий:=SendMessage(GetDlgItem(главное,ид),PBM_DELTAPOS,0,0);
  dec(текущий,10);
  if текущий<1 then текущий:=1;
  SendMessage(GetDlgItem(главное,ид),PBM_SETPOS,текущий,0);
  SetDlgItemInt(главное,идѕроцент,текущий,true);
end;

//================= больше на 10 процентов =======================

procedure командаЅольше(главное:HWND; ид:dword);
var текущий:integer;
begin
  текущий:=SendMessage(GetDlgItem(главное,ид),PBM_DELTAPOS,0,0);
  inc(текущий,10);
  if текущий>100 then текущий:=100;
  SendMessage(GetDlgItem(главное,ид),PBM_SETPOS,текущий,0);
  SetDlgItemInt(главное,идѕроцент,текущий,true);
end;

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,83,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_3:»ндикатор Progress"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,54,64,45,14
  control "Ѕольше",идЅольше,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,115,8,40,12
  control "ћеньше",идћеньше,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,6,8,40,12
  control "",ид»ндикатор,"msctls_progress32",WS_CHILD | WS_VISIBLE | WS_BORDER,8,28,146,14
  control "",идѕроцент,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,64,43,25,13
end;

//================= диалогова€ функци€ =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:»нициировать»ндикатор(wnd,ид»ндикатор);
    WM_COMMAND:case loword(wparam) of
      идћеньше:командаћеньше(wnd,ид»ндикатор);
      идЅольше:командаЅольше(wnd,ид»ндикатор);
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

