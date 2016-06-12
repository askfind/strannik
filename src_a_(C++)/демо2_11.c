// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.11:Календарь (Calendar Control)

include Win32

define hINSTANCE 0x400000

  INITCOMMONCONTROLSEX структ;
  SYSTEMTIME дата;

//диалог календаря
dialog DLG_CAL 126,61,171,142,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_11"
begin
  control "",100,"SysMonthCal32",WS_BORDER | WS_CHILD | WS_VISIBLE | MCS_DAYSTATE,32,8,111,100
  control "Ок",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,66,120,52,14
end;

//диалоговая функция календаря
bool procDLG_CAL(HWND wnd, int message, int wparam, int lparam) 
{
  switch(message) {
    case WM_INITDIALOG:SendDlgItemMessage(wnd,100,MCM_SETCURSEL,0,(int)(&дата)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:SendDlgItemMessage(wnd,100,MCM_GETCURSEL,0,(int)(&дата)); EndDialog(wnd,1); break;
    } break;
  default:return false; break;
  }
  return true;
}

//вывод целого
void mbI(int i, char* title)
{ char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

void main() {
//инициализация библиотеки
  структ.dwSize=sizeof(INITCOMMONCONTROLSEX);
  структ.dwICC=ICC_DATE_CLASSES;
  InitCommonControlsEx(структ);
//инициализация даты
  RtlZeroMemory(&дата,sizeof(SYSTEMTIME));
  with(дата) {
    wYear=2004;
    wMonth=8;
    wDay=15;
  }
//вызов диалога
  DialogBoxParam(hINSTANCE,"DLG_CAL",0,&procDLG_CAL,0);
//вывод результатов
  with(дата) {
    mbI(wDay,"Число:");
    mbI(wMonth,"Месяц:");
    mbI(wYear,"Год:");
  }
}

