// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.8:Программа установки

include Win32

define hINSTANCE 0x400000

define идПапка 200
define идОбзор 201
define идРезультат 202

enum списокСтраниц {стрВступление,стрПапка,стрФиниш};
typedef struct {
    char* стрЗаголовок;
    char* стрДиалог;
    uint стрФлаги;
  } [списокСтраниц] массивСтраниц;

define начСтраницы массивСтраниц{
  {"Вступление","DLG_1",PSWIZB_NEXT},
  {"Папка программы","DLG_2",PSWIZB_BACK | PSWIZB_NEXT},
  {"Готовность к установке","DLG_3",PSWIZB_BACK | PSWIZB_FINISH}}

  PROPSHEETPAGE страницы[списокСтраниц];
  PROPSHEETHEADER заголовок;
  списокСтраниц текущая;
  char папка[500];

//================= диалоги страниц =======================

dialog DLG_1 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Вступление"
begin
  control "Добро пожаловать в программу установки.",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,38,183,13
  control "Пожалуйста, следуйте дальнейшим инструкциям",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,52,183,13
  control "Нажмите кнопку 'Далее'",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,66,183,13
end;

dialog DLG_2 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Папка программы"
begin
  control "Выберите папку для размещения программы:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,38,183,12
  control "",идПапка,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,5,55,183,12
  control "Обзор",идОбзор,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,148,71,40,12
end;

dialog DLG_3 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Готовность к установке"
begin
  control "Все готово к установке",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,5,183,13
  control "Вы выбрали следующие параметры:",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,19,183,13
  control "",идРезультат,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,34,185,43
  control "Для начала установки нажмите кнопку 'Готово'",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,4,79,183,13
end;

//============ иницализация страницы диалога  ==================

void ЗаполнитьСтраницу(HWND wnd, списокСтраниц тек)
{
  switch(тек) {
    case стрВступление:break;
    case стрПапка:SetDlgItemText(wnd,идПапка,папка); break;
    case стрФиниш:SetDlgItemText(wnd,идРезультат,папка); break;
  }
}

void ЗаполнитьДанные(HWND wnd, списокСтраниц тек)
{
  switch(тек) {
    case стрВступление: break;
    case стрПапка:GetDlgItemText(wnd,идПапка,папка,500); break;
    case стрФиниш: break;
  }
}

//================= диалоговая функция  =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{pNMHDR сооб;

  switch(message) {
    case WM_INITDIALOG: break;
    case WM_COMMAND:switch(loword(wparam)) {
      case идОбзор:MessageBox(0,"Стандартный диалог выбора файла смотри в Demo2_6","Нажата кнопка Обзор",0); break;
    } break;
    case WM_NOTIFY:
      сооб=pNMHDR(lparam);
      switch(сооб->code) {
        case PSN_SETACTIVE://активация страницы
          SendMessage(GetParent(wnd),PSM_SETWIZBUTTONS,0,начСтраницы[текущая].стрФлаги);
          ЗаполнитьСтраницу(wnd,текущая);
        break;
        case PSN_WIZBACK:case PSN_WIZNEXT://деактивация страницы
          ЗаполнитьДанные(wnd,текущая);
          if(сооб^.code==PSN_WIZBACK) текущая--;
          else текущая++;
        break;
        case PSN_WIZFINISH://конец диалога
          MessageBox(0,папка,"Выбрана папка:",0); break;
      } return false;
    break;    
  default:return false; break;
  }
  return true;
}

//================= инициализация и вызов установки ====================

void main()
{
//инициализация страниц
  for(текущая=стрВступление; текущая<=стрФиниш; текущая++)
  with(страницы[текущая]) {
    RtlZeroMemory(&(страницы[текущая]),sizeof(PROPSHEETPAGE));
    dwSize=sizeof(PROPSHEETPAGE);
    dwFlags=PSP_USETITLE;
    hInstance=hINSTANCE;
    pszTemplate=начСтраницы[текущая].стрДиалог;
    pszTitle=начСтраницы[текущая].стрЗаголовок;
    pfnDlgProc=&procDLG_MAIN;
  }
//инициализация заголовка
  with(заголовок) {
    RtlZeroMemory(&заголовок,sizeof(PROPSHEETHEADER));
    dwSize=sizeof(PROPSHEETHEADER);
    dwFlags=PSH_PROPSHEETPAGE | PSH_WIZARD;
    hwndParent=0;
    hInstance=hINSTANCE;
    pszCaption="Demo2_8";
    nPages=ord(стрФиниш)+1;
    nStartPage=0;
    ppsp=&страницы;
  }
//вызов установки
  lstrcpy(папка,"c:\Program Files\demo2_8");
  InitCommonControls();
  текущая=стрВступление;
  PropertySheet(заголовок);
}

