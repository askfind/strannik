// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.8:Программа установки

module Demo2_8;
import Win32;

const 
  hINSTANCE=0x400000;

  идПапка=200;
  идОбзор=201;
  идРезультат=202;

type
  списокСтраниц=(стрВступление,стрПапка,стрФиниш);
  массивСтраниц=array[списокСтраниц]of record
    стрЗаголовок:pstr;
    стрДиалог:pstr;
    стрФлаги:cardinal;
  end;

const начСтраницы=массивСтраниц{
  {"Вступление","DLG_1",PSWIZB_NEXT},
  {"Папка программы","DLG_2",PSWIZB_BACK | PSWIZB_NEXT},
  {"Готовность к установке","DLG_3",PSWIZB_BACK | PSWIZB_FINISH}};

var
  страницы:array[списокСтраниц]of PROPSHEETPAGE;
  заголовок:PROPSHEETHEADER;
  текущая:списокСтраниц;
  папка:string[500];

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

procedure ЗаполнитьСтраницу(wnd:HWND; тек:списокСтраниц);
begin
  case тек of
    стрВступление:|
    стрПапка:SetDlgItemText(wnd,идПапка,папка);|
    стрФиниш:SetDlgItemText(wnd,идРезультат,папка);|
  end
end ЗаполнитьСтраницу;

procedure ЗаполнитьДанные(wnd:HWND; тек:списокСтраниц);
begin
  case тек of
    стрВступление:|
    стрПапка:GetDlgItemText(wnd,идПапка,папка,500);|
    стрФиниш:|
  end
end ЗаполнитьДанные;

//================= диалоговая функция  =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
var сооб:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_COMMAND:case loword(wparam) of
      идОбзор:MessageBox(0,"Стандартный диалог выбора файла смотри в Demo2_6","Нажата кнопка Обзор",0);|
    end;|
    WM_NOTIFY:сооб:=pNMHDR(lparam);
    case сооб^.code of
      PSN_SETACTIVE://активация страницы
        SendMessage(GetParent(wnd),PSM_SETWIZBUTTONS,0,начСтраницы[текущая].стрФлаги);
        ЗаполнитьСтраницу(wnd,текущая);|
      PSN_WIZBACK,PSN_WIZNEXT://деактивация страницы
        ЗаполнитьДанные(wnd,текущая);
        if сооб^.code=PSN_WIZBACK
          then dec(текущая)
          else inc(текущая)
        end;|
      PSN_WIZFINISH://конец диалога
        MessageBox(0,папка,"Выбрана папка:",0);|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= инициализация и вызов установки ====================

begin
//инициализация страниц
  for текущая:=стрВступление to стрФиниш do
  with страницы[текущая] do
    RtlZeroMemory(addr(страницы[текущая]),sizeof(PROPSHEETPAGE));
    dwSize:=sizeof(PROPSHEETPAGE);
    dwFlags:=PSP_USETITLE;
    hInstance:=hINSTANCE;
    pszTemplate:=начСтраницы[текущая].стрДиалог;
    pszTitle:=начСтраницы[текущая].стрЗаголовок;
    pfnDlgProc:=addr(procDLG_MAIN);
  end end;
//инициализация заголовка
  with заголовок do
    RtlZeroMemory(addr(заголовок),sizeof(PROPSHEETHEADER));
    dwSize:=sizeof(PROPSHEETHEADER);
    dwFlags:=PSH_PROPSHEETPAGE | PSH_WIZARD;
    hwndParent:=0;
    hInstance:=hINSTANCE;
    pszCaption:="Demo2_8";
    nPages:=ord(стрФиниш)+1;
    nStartPage:=0;
    ppsp:=addr(страницы);
  end;
//вызов установки
  lstrcpy(папка,"c:\Program Files\demo2_8");
  InitCommonControls();
  текущая:=стрВступление;
  PropertySheet(заголовок);
end Demo2_8.

