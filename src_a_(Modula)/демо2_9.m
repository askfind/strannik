// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.9:Блокнот PropertySheet

module Demo2_9;
import Win32;

const 
  hINSTANCE=0x400000;

  идПапка=200;
  идОбзор=201;
  идПереключ0=202;
  идПереключ1=203;
  идПереключ2=204;

type
  списокСтраниц=(стрПереключ,стрПапка);
  массивСтраниц=array[списокСтраниц]of record
    стрЗаголовок:pstr;
    стрДиалог:pstr;
  end;

const начСтраницы=массивСтраниц{
  {"Переключатели","DLG_1"},
  {"Папка программы","DLG_2"}};

var
  страницы:array[списокСтраниц]of PROPSHEETPAGE;
  ключи:array[списокСтраниц]of HANDLE;
  заголовок:PROPSHEETHEADER;
  текущая:списокСтраниц;
  строка:string[100];
  папка:string[500];
  вариант:integer;

//================= диалоги страниц =======================

dialog DLG_1 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Переключатели"
begin
  control "Первый вариант",идПереключ0,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,24,108,14
  control "Второй вариант",идПереключ1,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,39,108,14
  control "Третий вариант",идПереключ2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,54,108,14
end;

dialog DLG_2 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Папка программы"
begin
  control "Папка для размещения программы:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,39,126,11
  control "",идПапка,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,5,57,126,11
  control "Обзор",идОбзор,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,87,73,40,12
end;

//================= диалоговые функции =======================

procedure procDLG_1(wnd:HWND; message,wparam,lparam:integer):boolean;
var сооб:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_NOTIFY:сооб:=pNMHDR(lparam);
    case сооб^.code of
      PSN_SETACTIVE://активация страницы        
        case вариант of
          0:SendDlgItemMessage(wnd,идПереключ0,BM_SETCHECK,BST_CHECKED,0);|
          1:SendDlgItemMessage(wnd,идПереключ1,BM_SETCHECK,BST_CHECKED,0);|
          2:SendDlgItemMessage(wnd,идПереключ2,BM_SETCHECK,BST_CHECKED,0);|
        end;|
      PSN_KILLACTIVE:
        if IsDlgButtonChecked(wnd,идПереключ0)=BST_CHECKED then вариант:=0 end;
        if IsDlgButtonChecked(wnd,идПереключ1)=BST_CHECKED then вариант:=1 end;
        if IsDlgButtonChecked(wnd,идПереключ2)=BST_CHECKED then вариант:=2 end;|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_1;

procedure procDLG_2(wnd:HWND; message,wparam,lparam:integer):boolean;
var сооб:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_COMMAND:case loword(wparam) of
      идОбзор:MessageBox(0,"Стандартный диалог выбора файла смотри в Demo2_6","Нажато:Обзор",0);|
    end;|
    WM_NOTIFY:сооб:=pNMHDR(lparam);
    case сооб^.code of
      PSN_SETACTIVE:SetDlgItemText(wnd,идПапка,папка);|
      PSN_KILLACTIVE:GetDlgItemText(wnd,идПапка,папка,500);|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_2;

//================= инициализация и вызов установки ====================

begin
//инициализация страниц
  for текущая:=стрПереключ to стрПапка do
  with страницы[текущая] do
    RtlZeroMemory(addr(страницы[текущая]),sizeof(PROPSHEETPAGE));
    dwSize:=sizeof(PROPSHEETPAGE);
    dwFlags:=PSP_USETITLE;
    hInstance:=hINSTANCE;
    pszTemplate:=начСтраницы[текущая].стрДиалог;
    pszTitle:=начСтраницы[текущая].стрЗаголовок;
    case текущая of
      стрПереключ:pfnDlgProc:=addr(procDLG_1);|
      стрПапка:pfnDlgProc:=addr(procDLG_2);|
    end;
    ключи[текущая]:=CreatePropertySheetPage(addr(страницы[текущая]));
  end end;
//инициализация заголовка
  with заголовок do
    RtlZeroMemory(addr(заголовок),sizeof(PROPSHEETHEADER));
    dwSize:=sizeof(PROPSHEETHEADER);
    dwFlags:=0;
    hwndParent:=0;
    hInstance:=hINSTANCE;
    pszCaption:="Demo2_9";
    nPages:=2;
    nStartPage:=0;
    ppsp:=addr(ключи);
  end;
//вызов установки
  lstrcpy(папка,"c:\Program Files\demo2_9");
  вариант:=1;
  InitCommonControls();
  PropertySheet(заголовок);
  wvsprintf(строка,"%li",addr(вариант));
  MessageBox(0,строка,"Выбран вариант:",0);
  MessageBox(0,папка,"Выбрана папка:",0);
end Demo2_9.

