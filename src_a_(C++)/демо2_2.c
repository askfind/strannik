// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.2:–абота со списком

include Win32

define hINSTANCE 0x400000

define идƒобавить 100
define ид”далить 101
define ид¬ид 102
define идќк 200
define ид—писок 1000

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

uint иконкаќткр;
uint иконка«акр;

//================= инициировать список =======================

void »нициировать—писок(HWND главное, uint ид)
{HIMAGELIST список; HBITMAP иконка; RECT регион; LV_COLUMN структ;

  InitCommonControls();
//списки изображений
  список=ImageList_Create(20,20,0,2,0);
  иконка=LoadBitmap(hINSTANCE,"TreeOpen"); иконкаќткр=ImageList_Add(список,иконка,0);
  иконка=LoadBitmap(hINSTANCE,"TreeClose"); иконка«акр=ImageList_Add(список,иконка,0);
  SendMessage(GetDlgItem(главное,ид),LVM_SETIMAGELIST,LVSIL_NORMAL,список);
  SendMessage(GetDlgItem(главное,ид),LVM_SETIMAGELIST,LVSIL_SMALL,список);
//список столбцов
  GetClientRect(GetDlgItem(главное,ид),регион);
  with(структ,регион) {
    mask=LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;
    fmt=LVCFMT_LEFT; pszText="»м€"; cchTextMax=lstrlen(pszText); cx=right*40 div 100; SendMessage(GetDlgItem(главное,ид),LVM_INSERTCOLUMN,0,(int)(&структ));
    fmt=LVCFMT_LEFT; pszText="–азмер"; cchTextMax=lstrlen(pszText); cx=right*20 div 100; SendMessage(GetDlgItem(главное,ид),LVM_INSERTCOLUMN,1,(int)(&структ));
    fmt=LVCFMT_LEFT; pszText="ƒата"; cchTextMax=lstrlen(pszText); cx=right*40 div 100; SendMessage(GetDlgItem(главное,ид),LVM_INSERTCOLUMN,2,(int)(&структ));
  }
}

void ƒобавитьЁлемент¬—писок(HWND окно, int номер, char* текст, HBITMAP иконка)
{LV_ITEM структ;

  with(структ) {
    RtlZeroMemory(&структ,sizeof(LV_ITEM));
    mask=LVIF_TEXT | LVIF_IMAGE;
    iItem=номер;
    iImage=иконка;
    iSubItem=0;
    pszText=текст;
    cchTextMax=lstrlen(pszText);
    SendMessage(окно,LVM_INSERTITEM,0,(int)(&структ));
  }
}

//================= заполнить список элементами =======================

void «аполнить—писок(HWND окно)
{
  SendMessage(окно,LVM_DELETEALLITEMS,0,0);
  ƒобавитьЁлемент¬—писок(окно,0,"Ќулевой элемент",иконка«акр);
  ƒобавитьЁлемент¬—писок(окно,1,"ѕервый элемент",иконка«акр);
  ƒобавитьЁлемент¬—писок(окно,2,"¬торой элемент",иконка«акр);
}

//================= добавть новый элемент после текущего =======================

void командаƒобавить(HWND окно)
{int текущий;

  текущий=SendMessage(окно,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  ƒобавитьЁлемент¬—писок(окно,текущий+1,"Ќовый элемент",иконкаќткр);
}

//================= удалить текущий элемент =======================

void команда”далить(HWND окно)
{int текущий;

  текущий=SendMessage(окно,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  SendMessage(окно,LVM_DELETEITEM,текущий,0);
}

//================= помен€ть вид списка =======================

void команда¬ид(HWND окно)
{uint стиль;

  стиль=GetWindowLong(окно,GWL_STYLE);
  switch(стиль & (LVS_REPORT | LVS_LIST | LVS_SMALLICON | LVS_ICON)) {
    case LVS_REPORT:стиль=(стиль & (! LVS_REPORT)) | LVS_LIST; break;
    case LVS_LIST:стиль=(стиль & (! LVS_LIST)) | LVS_SMALLICON; break;
    case LVS_SMALLICON:стиль=(стиль & (! LVS_SMALLICON)) | LVS_ICON; break;
    case LVS_ICON:стиль=(стиль & (! LVS_ICON)) | LVS_REPORT; break;
  }
  SetWindowLong(окно,GWL_STYLE,стиль);
}

//================= обработка извещений от окна =======================

bool ќбработать»звещениеќт—писка(HWND окно, LV_DISPINFO* инфо)
{
  with(инфо^.hdr,инфо^.item) {
  switch(code) {
    case LVN_GETDISPINFO:if(mask & LVIF_TEXT<>0) { //текст элемента
      switch(iSubItem) { //номер элемента в iItem
        case 1:pszText="230"; break;
        case 2:pszText="12.09.2001"; break;
      }
      return true;
    } break;
  }}
  return false;
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:»нициировать—писок(wnd,ид—писок); «аполнить—писок(GetDlgItem(wnd,ид—писок)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case идƒобавить:командаƒобавить(GetDlgItem(wnd,ид—писок)); break;
      case ид”далить:команда”далить(GetDlgItem(wnd,ид—писок)); break;
      case ид¬ид:команда¬ид(GetDlgItem(wnd,ид—писок)); break;
      case IDOK: case идќк:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_NOTIFY:switch(loword(wparam)) {
      case ид—писок:return ќбработать»звещениеќт—писка(GetDlgItem(wnd,ид—писок),(void*)lparam); break;
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

