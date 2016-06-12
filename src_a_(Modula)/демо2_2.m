// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.2:–абота со списком

module Demo2_2;
import Win32;

const 
  hINSTANCE=0x400000;

  идƒобавить=100;
  ид”далить=101;
  ид¬ид=102;
  идќк=200;
  ид—писок=1000;

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

var
  иконкаќткр:cardinal;
  иконка«акр:cardinal;

//================= инициировать список =======================

procedure »нициировать—писок(главное:HWND; ид:cardinal);
var список:HIMAGELIST; иконка:HBITMAP; регион:RECT; структ:LV_COLUMN;
begin
  InitCommonControls();
//списки изображений
  список:=ImageList_Create(20,20,0,2,0);
  иконка:=LoadBitmap(hINSTANCE,"TreeOpen"); иконкаќткр:=ImageList_Add(список,иконка,0);
  иконка:=LoadBitmap(hINSTANCE,"TreeClose"); иконка«акр:=ImageList_Add(список,иконка,0);
  SendMessage(GetDlgItem(главное,ид),LVM_SETIMAGELIST,LVSIL_NORMAL,список);
  SendMessage(GetDlgItem(главное,ид),LVM_SETIMAGELIST,LVSIL_SMALL,список);
//список столбцов
  GetClientRect(GetDlgItem(главное,ид),регион);
  with структ,регион do
    mask:=LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;
    fmt:=LVCFMT_LEFT; pszText:="»м€"; cchTextMax:=lstrlen(pszText); cx:=right*40 div 100; SendMessage(GetDlgItem(главное,ид),LVM_INSERTCOLUMN,0,integer(addr(структ)));
    fmt:=LVCFMT_LEFT; pszText:="–азмер"; cchTextMax:=lstrlen(pszText); cx:=right*20 div 100; SendMessage(GetDlgItem(главное,ид),LVM_INSERTCOLUMN,1,integer(addr(структ)));
    fmt:=LVCFMT_LEFT; pszText:="ƒата"; cchTextMax:=lstrlen(pszText); cx:=right*40 div 100; SendMessage(GetDlgItem(главное,ид),LVM_INSERTCOLUMN,2,integer(addr(структ)));
  end;
end »нициировать—писок;

procedure ƒобавитьЁлемент¬—писок(окно:HWND; номер:integer; текст:pstr; иконка:HBITMAP);
var структ:LV_ITEM;
begin
  with структ do
    RtlZeroMemory(addr(структ),sizeof(LV_ITEM));
    mask:=LVIF_TEXT | LVIF_IMAGE;
    iItem:=номер;
    iImage:=иконка;
    iSubItem:=0;
    pszText:=текст;
    cchTextMax:=lstrlen(pszText);
    SendMessage(окно,LVM_INSERTITEM,0,integer(addr(структ)));
  end
end ƒобавитьЁлемент¬—писок;

//================= заполнить список элементами =======================

procedure «аполнить—писок(окно:HWND);
begin
  SendMessage(окно,LVM_DELETEALLITEMS,0,0);
  ƒобавитьЁлемент¬—писок(окно,0,"Ќулевой элемент",иконка«акр);
  ƒобавитьЁлемент¬—писок(окно,1,"ѕервый элемент",иконка«акр);
  ƒобавитьЁлемент¬—писок(окно,2,"¬торой элемент",иконка«акр);
end «аполнить—писок;

//================= добавть новый элемент после текущего =======================

procedure командаƒобавить(окно:HWND);
var текущий:integer;
begin
  текущий:=SendMessage(окно,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  ƒобавитьЁлемент¬—писок(окно,текущий+1,"Ќовый элемент",иконкаќткр);
end командаƒобавить;

//================= удалить текущий элемент =======================

procedure команда”далить(окно:HWND);
var текущий:integer;
begin
  текущий:=SendMessage(окно,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  SendMessage(окно,LVM_DELETEITEM,текущий,0);
end команда”далить;

//================= помен€ть вид списка =======================

procedure команда¬ид(окно:HWND);
var стиль:cardinal;
begin
  стиль:=GetWindowLong(окно,GWL_STYLE);
  case стиль and (LVS_REPORT | LVS_LIST | LVS_SMALLICON | LVS_ICON) of
    LVS_REPORT:стиль:=(стиль and (not LVS_REPORT))or LVS_LIST;|
    LVS_LIST:стиль:=(стиль and (not LVS_LIST))or LVS_SMALLICON;|
    LVS_SMALLICON:стиль:=(стиль and (not LVS_SMALLICON))or LVS_ICON;|
    LVS_ICON:стиль:=(стиль and (not LVS_ICON))or LVS_REPORT;|
  end;
  SetWindowLong(окно,GWL_STYLE,стиль);
end команда¬ид;

//================= обработка извещений от окна =======================

procedure ќбработать»звещениеќт—писка(окно:HWND; инфо:pLV_DISPINFO):boolean;
begin
  with инфо^.hdr,инфо^.item do
  case code of
    LVN_GETDISPINFO:if mask and LVIF_TEXT<>0 then //текст элемента
      case iSubItem of //номер элемента в iItem
        1:pszText:="230";|
        2:pszText:="12.09.2002";|
      end;
      return true
    end;|
//    LVN_BEGINDRAG:return true;|
  end end;
  return false
end ќбработать»звещениеќт—писка;

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,115,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_2:–абота со списком"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,62,97,45,14
  control "”далить",ид”далить,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,115,8,40,12
  control "ƒобавить",идƒобавить,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,6,8,40,12
  control "—менить вид",ид¬ид,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,54,8,56,12
  control "",ид—писок,"SysListView32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LVS_REPORT,8,25,147,68
end;

//================= диалогова€ функци€ =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:»нициировать—писок(wnd,ид—писок); «аполнить—писок(GetDlgItem(wnd,ид—писок));|
    WM_COMMAND:case loword(wparam) of
      идƒобавить:командаƒобавить(GetDlgItem(wnd,ид—писок));|
      ид”далить:команда”далить(GetDlgItem(wnd,ид—писок));|
      ид¬ид:команда¬ид(GetDlgItem(wnd,ид—писок));|
      IDOK,идќк:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
    WM_NOTIFY:case loword(wparam) of
      ид—писок:return ќбработать»звещениеќт—писка(GetDlgItem(wnd,ид—писок),address(lparam));|
    end;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= вызов диалога ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end Demo2_2.

