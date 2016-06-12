// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.3:»ндикатор Progressbar

include Win32

define hINSTANCE 0x400000

define идћеньше 100
define идЅольше 101
define идѕроцент 102
define идќк 200
define ид»ндикатор 1000

//================= инициировать индикатор =======================

void »нициировать»ндикатор(HWND главное, uint ид)
{
  InitCommonControls();
//диапазон значений от 1 до 100
  SendMessage(GetDlgItem(главное,ид),PBM_SETRANGE,0,1+100*0x10000);
//шаг через 1
  SendMessage(GetDlgItem(главное,ид),PBM_SETSTEP,1,0);
//начальное значение 50
  SendMessage(GetDlgItem(главное,ид),PBM_SETPOS,50,0);
  SetDlgItemInt(главное,идѕроцент,50,true);
}

//================= меньше на 10 процентов =======================

void командаћеньше(HWND главное, uint ид)
{int текущий;
  текущий=SendMessage(GetDlgItem(главное,ид),PBM_DELTAPOS,0,0);
  текущий--10;
  if(текущий<1) текущий=1;
  SendMessage(GetDlgItem(главное,ид),PBM_SETPOS,текущий,0);
  SetDlgItemInt(главное,идѕроцент,текущий,true);
}

//================= больше на 10 процентов =======================

void командаЅольше(HWND главное, uint ид)
{int текущий;
  текущий=SendMessage(GetDlgItem(главное,ид),PBM_DELTAPOS,0,0);
  текущий++10;
  if(текущий>100) текущий=100;
  SendMessage(GetDlgItem(главное,ид),PBM_SETPOS,текущий,0);
  SetDlgItemInt(главное,идѕроцент,текущий,true);
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:»нициировать»ндикатор(wnd,ид»ндикатор); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case идћеньше:командаћеньше(wnd,ид»ндикатор); break;
      case идЅольше:командаЅольше(wnd,ид»ндикатор); break;
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

