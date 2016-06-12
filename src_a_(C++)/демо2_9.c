// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.9:Блокнот PropertySheet

include Win32

define hINSTANCE 0x400000
define идПапка 200 
define идОбзор 201 
define идПереключ0 202 
define идПереключ1 203 
define идПереключ2 204 

enum списокСтраниц {стрПереключ,стрПапка};
typedef struct {
    char* стрЗаголовок;
    char* стрДиалог;
  } [списокСтраниц] массивСтраниц;

define начСтраницы массивСтраниц{
  {"Переключатели","DLG_1"},
  {"Папка программы","DLG_2"}}

  PROPSHEETPAGE страницы[списокСтраниц];
  HANDLE ключи[списокСтраниц];
  PROPSHEETHEADER заголовок;
  списокСтраниц текущая;
  char строка[100];
  char папка[500];
  int вариант;

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

bool procDLG_1(HWND wnd, int message, int wparam, int lparam)
{pNMHDR сооб;

  switch(message) {
    case WM_INITDIALOG:break;
    case WM_NOTIFY:сооб=pNMHDR(lparam);
    switch(сооб->code) {
      case PSN_SETACTIVE://активация страницы        
        switch(вариант) {
          case 0:SendDlgItemMessage(wnd,идПереключ0,BM_SETCHECK,BST_CHECKED,0); break;
          case 1:SendDlgItemMessage(wnd,идПереключ1,BM_SETCHECK,BST_CHECKED,0); break;
          case 2:SendDlgItemMessage(wnd,идПереключ2,BM_SETCHECK,BST_CHECKED,0); break;
        }
      break;
      case PSN_KILLACTIVE:
        if(IsDlgButtonChecked(wnd,идПереключ0)==BST_CHECKED) вариант=0;
        if(IsDlgButtonChecked(wnd,идПереключ1)==BST_CHECKED) вариант=1;
        if(IsDlgButtonChecked(wnd,идПереключ2)==BST_CHECKED) вариант=2;
      break;
    }
    return false; break;
  default:return false; break;
  }
  return true;
}

bool procDLG_2(HWND wnd, int message, int wparam, int lparam)
{pNMHDR сооб;

  switch(message) {
    case WM_INITDIALOG: break;
    case WM_COMMAND:switch(loword(wparam)) {
      case идОбзор:MessageBox(0,"Стандартный диалог выбора файла смотри в Demo2_6","Нажато:Обзор",0); break;
    } break;
    case WM_NOTIFY:сооб=pNMHDR(lparam);
    switch(сооб->code) {
      case PSN_SETACTIVE:SetDlgItemText(wnd,идПапка,папка); break;
      case PSN_KILLACTIVE:GetDlgItemText(wnd,идПапка,папка,500); break;
    }
    return false; break;
  default:return false; break;
  }
  return true;
}

//================= инициализация и вызов установки ====================

void main()
{
//инициализация страниц
  for(текущая=стрПереключ; текущая<=стрПапка; текущая++)
  with(страницы[текущая]) {
    RtlZeroMemory(&(страницы[текущая]),sizeof(PROPSHEETPAGE));
    dwSize=sizeof(PROPSHEETPAGE);
    dwFlags=PSP_USETITLE;
    hInstance=hINSTANCE;
    pszTemplate=начСтраницы[текущая].стрДиалог;
    pszTitle=начСтраницы[текущая].стрЗаголовок;
    switch(текущая) {
      case стрПереключ:pfnDlgProc=&procDLG_1; break;
      case стрПапка:pfnDlgProc=&procDLG_2; break;
    }
    ключи[текущая]=CreatePropertySheetPage(&(страницы[текущая]));
  }
//инициализация заголовка
  with(заголовок) {
    RtlZeroMemory(&заголовок,sizeof(PROPSHEETHEADER));
    dwSize=sizeof(PROPSHEETHEADER);
    dwFlags=0;
    hwndParent=0;
    hInstance=hINSTANCE;
    pszCaption="Demo2_9";
    nPages=2;
    nStartPage=0;
    ppsp=&ключи;
  }
//вызов установки
  lstrcpy(папка,"c:\Program Files\demo2_9");
  вариант=1;
  InitCommonControls();
  PropertySheet(заголовок);
  wvsprintf(строка,"%li",&вариант);
  MessageBox(0,строка,"Выбран вариант:",0);
  MessageBox(0,папка,"Выбрана папка:",0);
}

