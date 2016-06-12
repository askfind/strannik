// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.11:Календарь (Calendar Control)

program Demo2_11;
uses Win32;

const 
  hINSTANCE=0x400000;

var
  окно:HWND;
  структ:INITCOMMONCONTROLSEX;
  дата:SYSTEMTIME;

//диалог календаря
dialog DLG_CAL 126,61,171,142,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_11"
begin
  control "",100,"SysMonthCal32",WS_BORDER | WS_CHILD | WS_VISIBLE | MCS_DAYSTATE,32,8,111,100
  control "Ок",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,66,120,52,14
end;

//диалоговая функция календаря
function procDLG_CAL(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:SendDlgItemMessage(wnd,100,MCM_SETCURSEL,0,integer(addr(дата)));
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:begin SendDlgItemMessage(wnd,100,MCM_GETCURSEL,0,integer(addr(дата))); EndDialog(wnd,1) end;
    end;
  else return false
  end;
  return true
end;

//вывод целого
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end;

begin
//инициализация библиотеки
  структ.dwSize:=sizeof(INITCOMMONCONTROLSEX);
  структ.dwICC:=ICC_DATE_CLASSES;
  InitCommonControlsEx(структ);
//инициализация даты
  RtlZeroMemory(addr(дата),sizeof(SYSTEMTIME));
  with дата do begin
    wYear:=2004;
    wMonth:=8;
    wDay:=15;
  end;
//вызов диалога
  DialogBoxParam(hINSTANCE,"DLG_CAL",0,addr(procDLG_CAL),0);
//вывод результатов
  with дата do begin
    mbI(wDay,"Число:");
    mbI(wMonth,"Месяц:");
    mbI(wYear,"Год:");
  end;
end.

