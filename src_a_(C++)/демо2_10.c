// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.10:Ввод даты и времени (Date and Time Picker Controls)

include Win32

define hINSTANCE 0x400000

  INITCOMMONCONTROLSEX структ;
  SYSTEMTIME время,дата;

//диалог ввода времени и даты
dialog DLG_TIME 126,61,256,88,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_10"
begin
  control "Ок",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,92,68,72,14
  control "",100,"SysDateTimePick32",WS_BORDER | WS_CHILD | WS_VISIBLE,32,8,70,15
  control "",101,"SysDateTimePick32",WS_BORDER | WS_CHILD | WS_VISIBLE | DTS_TIMEFORMAT,157,8,70,15
end;

//диалоговая функция ввода времени и даты
bool procDLG_TIME(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:
      SendDlgItemMessage(wnd,100,DTM_SETSYSTEMTIME,GDT_VALID,(int)(&дата));
      SendDlgItemMessage(wnd,101,DTM_SETSYSTEMTIME,GDT_VALID,(int)(&время));
      break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:
        SendDlgItemMessage(wnd,100,DTM_GETSYSTEMTIME,0,(int)(&дата));
        SendDlgItemMessage(wnd,101,DTM_GETSYSTEMTIME,0,(int)(&время));
        EndDialog(wnd,1);
        break;
    } break;
  default:return false; break;
  }
  return true;
}

//вывод целого
void mbI(int i, char* title)
{char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

void main()
{
//инициализация библиотеки
  структ.dwSize=sizeof(INITCOMMONCONTROLSEX);
  структ.dwICC=ICC_DATE_CLASSES;
  InitCommonControlsEx(структ);
//инициализация даты и времени
  RtlZeroMemory(&время,sizeof(SYSTEMTIME));
  with(время) {
    wHour=12;
    wMinute=35;
    wSecond=10;
  }
  RtlZeroMemory(&дата,sizeof(SYSTEMTIME));
  with(дата) {
    wYear=2004;
    wMonth=8;
    wDay=15;
  }
//вызов диалога
  DialogBoxParam(hINSTANCE,"DLG_TIME",0,&procDLG_TIME,0);
//вывод результатов
  with(время) {
    mbI(wHour,"Часов:");
    mbI(wMinute,"Минут:");
    mbI(wSecond,"Секунд:");
  }
  with(дата) {
    mbI(wDay,"Число:");
    mbI(wMonth,"Месяц:");
    mbI(wYear,"Год:");
  }
}

