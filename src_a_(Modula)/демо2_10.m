// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.10:Ввод даты и времени (Date and Time Picker Controls)

module Demo2_10;
import Win32;

const 
  hINSTANCE=0x400000;

var
  окно:HWND;
  структ:INITCOMMONCONTROLSEX;
  время,дата:SYSTEMTIME;

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
procedure procDLG_TIME(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:
      SendDlgItemMessage(wnd,100,DTM_SETSYSTEMTIME,GDT_VALID,integer(addr(дата)));
      SendDlgItemMessage(wnd,101,DTM_SETSYSTEMTIME,GDT_VALID,integer(addr(время)));|
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:
        SendDlgItemMessage(wnd,100,DTM_GETSYSTEMTIME,0,integer(addr(дата)));
        SendDlgItemMessage(wnd,101,DTM_GETSYSTEMTIME,0,integer(addr(время)));
        EndDialog(wnd,1);|
    end;|
  else return false
  end;
  return true
end procDLG_TIME;

//вывод целого
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end mbI;

begin
//инициализация библиотеки
  структ.dwSize:=sizeof(INITCOMMONCONTROLSEX);
  структ.dwICC:=ICC_DATE_CLASSES;
  InitCommonControlsEx(структ);
//инициализация даты и времени
  RtlZeroMemory(addr(время),sizeof(SYSTEMTIME));
  with время do
    wHour:=12;
    wMinute:=35;
    wSecond:=10;
  end;
  RtlZeroMemory(addr(дата),sizeof(SYSTEMTIME));
  with дата do
    wYear:=2004;
    wMonth:=8;
    wDay:=15;
  end;
//вызов диалога
  DialogBoxParam(hINSTANCE,"DLG_TIME",0,addr(procDLG_TIME),0);
//вывод результатов
  with время do
    mbI(wHour,"Часов:");
    mbI(wMinute,"Минут:");
    mbI(wSecond,"Секунд:");
  end;
  with дата do
    mbI(wDay,"Число:");
    mbI(wMonth,"Месяц:");
    mbI(wYear,"Год:");
  end;
end Demo2_10.

