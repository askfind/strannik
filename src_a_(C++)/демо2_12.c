// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.12:Список с заголовком

include Win32

define hINSTANCE 0x400000

//поиск символа в строке
  int lstrposc(char sym, char* str)
{int i;
  
    if(str==NULL) return -1;
    i=0;
    while((str[i]!='\0')&&(str[i]!=sym))
      i++;
    if(str[i]==sym) return(i);
    else return(-1);
  }

//удаление подстроки
  void lstrdel(char* str, int pos,int len)
{int i,l;
  
    if(pos<0) {
      len=len+pos;
      pos=0;
    }
    if(len>=0) {
      l=lstrlen(str);
      if(pos+len>l)
        if(pos<l) str[pos]='\0'; else {}
      else
        for(i=1; i<=l-(pos+len)+1; i++)
          str[pos+i-1]=str[pos+i+len-1];
    }
  }

//заполнить окно заголовка
void ЗаполнитьЗаголовок(HWND заголовок, char* формат) {
  RECT регион; HDITEM элемент; int тек,макс;
  char текст[500],строка[500];

  GetClientRect(заголовок,регион);
  макс=0;
  for(тек=0;тек<=lstrlen(формат)-1;тек++) {
    if(формат[тек]!='\9') макс++;
  }
  lstrcpyn(текст,формат,500);
  тек=0;
  while(lstrposc('\9',текст)>=0) {
    lstrcpy(строка,текст);
    строка[lstrposc('\9',текст)]='\0';
    элемент.mask=HDI_TEXT | HDI_FORMAT | HDI_WIDTH;
    элемент.pszText=&строка;
    элемент.cxy=(регион.right-регион.left)*lstrlen(строка) / (макс-1);
    элемент.cchTextMax=lstrlen(строка);
    элемент.fmt=HDF_LEFT | HDF_STRING;
    SendMessage(заголовок,HDM_INSERTITEM,тек,(int)(&элемент));
    lstrdel(текст,0,lstrposc('\9',текст)+1);
    тек++;
  }
}

// нарисовать строку списка
void НарисоватьСтроку(HWND заголовок, pDRAWITEMSTRUCT пар) {
char строка[1000],текст[1000]; RECT рег; int тек,смещ; HDITEM элем;

  SendMessage(пар->hwndItem,LB_GETTEXT,пар->itemID,(int)(&текст));
  тек=0;
  смещ=0;
  while(lstrposc('\9',текст)>=0) {
    lstrcpy(строка,текст);
    строка[lstrposc('\9',текст)]='\0';
    элем.mask=HDI_WIDTH;
    SendMessage(заголовок,HDM_GETITEM,тек,(int)(&элем));
    рег=пар->rcItem;
    рег.left++смещ;
    рег.right=рег.left+элем.cxy;
    if(пар->itemState and ODS_SELECTED<>0)
      {SetTextColor(пар->hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(пар->hDC,GetSysColor(COLOR_HIGHLIGHT));}
    else {SetTextColor(пар->hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(пар->hDC,GetSysColor(COLOR_MENU));}
    ExtTextOut(пар->hDC,рег.left,рег.top,ETO_CLIPPED | ETO_OPAQUE,&рег,строка,lstrlen(строка),NULL);
    lstrdel(текст,0,lstrposc('\9',текст)+1);
    тек++;
    смещ++элем.cxy;
  }
}

//диалог
dialog DLG_LIST 126,40,306,169,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_12"
begin
  control "",100,"Listbox",WS_BORDER | WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_VSCROLL | LBS_OWNERDRAWFIXED | LBS_HASSTRINGS | LBS_WANTKEYBOARDINPUT,32,18,240,123
  control "",101,"SysHeader32",WS_CHILD | WS_VISIBLE | WS_BORDER | HDS_BUTTONS | HDS_HORZ,32,3,240,14
  control "Ок",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,128,144,52,14
end;

//диалоговая функция
bool procDLG_LIST(HWND wnd, int message,int wparam,int lparam) {
  switch(message) {
    case WM_INITDIALOG:
      ЗаполнитьЗаголовок(GetDlgItem(wnd,101),"File             \9Size     \9Date        \9");
      SendDlgItemMessage(wnd,100,LB_RESETCONTENT,0,0);
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_10 \9 12K \9 12.03.2004 \9");
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_11 \9 29K \9 01.08.2004 \9");
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_12 \9 18K \9 20.11.2004 \9");
    break;
    case WM_DRAWITEM:if(wparam<>0) НарисоватьСтроку(GetDlgItem(wnd,101),(pDRAWITEMSTRUCT)(lparam)); break;
    case WM_MEASUREITEM:break;//высота строки списка
    case WM_VKEYTOITEM:break;//обработать нажатие на клавиатуру в списке
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:EndDialog(wnd,1); break;
    } break;
  default:return false; break;
  }
  return true;
}

void main() {
  InitCommonControlsEx(NULL);
  DialogBoxParam(hINSTANCE,"DLG_LIST",0,&procDLG_LIST,0);
}

