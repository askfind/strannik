// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.12:Listview with header

include Win32

define hINSTANCE 0x400000

//search symbol in string
  int lstrposc(char sym, char* str)
{int i;
  
    if(str==NULL) return -1;
    i=0;
    while((str[i]!='\0')&&(str[i]!=sym))
      i++;
    if(str[i]==sym) return(i);
    else return(-1);
  }

//substring delete
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

//set header paths
void SetHeader(HWND header, char* format) {
  RECT reg; HDITEM item; int car,max;
  char text[500],str[500];

  GetClientRect(header,reg);
  max=0;
  for(car=0;car<=lstrlen(format)-1;car++) {
    if(format[car]!='\9') max++;
  }
  lstrcpyn(text,format,500);
  car=0;
  while(lstrposc('\9',text)>=0) {
    lstrcpy(str,text);
    str[lstrposc('\9',text)]='\0';
    item.mask=HDI_TEXT | HDI_FORMAT | HDI_WIDTH;
    item.pszText=&str;
    item.cxy=(reg.right-reg.left)*lstrlen(str) / (max-1);
    item.cchTextMax=lstrlen(str);
    item.fmt=HDF_LEFT | HDF_STRING;
    SendMessage(header,HDM_INSERTITEM,car,(int)(&item));
    lstrdel(text,0,lstrposc('\9',text)+1);
    car++;
  }
}

//Draw list string
void DrawListString(HWND header, pDRAWITEMSTRUCT par) {
char str[1000],text[1000]; RECT reg; int car,track; HDITEM item;

  SendMessage(par->hwndItem,LB_GETTEXT,par->itemID,(int)(&text));
  car=0;
  track=0;
  while(lstrposc('\9',text)>=0) {
    lstrcpy(str,text);
    str[lstrposc('\9',text)]='\0';
    item.mask=HDI_WIDTH;
    SendMessage(header,HDM_GETITEM,car,(int)(&item));
    reg=par->rcItem;
    reg.left++track;
    reg.right=reg.left+item.cxy;
    if(par->itemState and ODS_SELECTED<>0)
      {SetTextColor(par->hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(par->hDC,GetSysColor(COLOR_HIGHLIGHT));}
    else {SetTextColor(par->hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(par->hDC,GetSysColor(COLOR_MENU));}
    ExtTextOut(par->hDC,reg.left,reg.top,ETO_CLIPPED | ETO_OPAQUE,&reg,str,lstrlen(str),NULL);
    lstrdel(text,0,lstrposc('\9',text)+1);
    car++;
    track++item.cxy;
  }
}

//dialog
dialog DLG_LIST 126,40,306,169,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_12"
begin
  control "",100,"Listbox",WS_BORDER | WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_VSCROLL | LBS_OWNERDRAWFIXED | LBS_HASSTRINGS | LBS_WANTKEYBOARDINPUT,32,18,240,123
  control "",101,"SysHeader32",WS_CHILD | WS_VISIBLE | WS_BORDER | HDS_BUTTONS | HDS_HORZ,32,3,240,14
  control "Îê",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,128,144,52,14
end;

//dialog function
bool procDLG_LIST(HWND wnd, int message,int wparam,int lparam) {
  switch(message) {
    case WM_INITDIALOG:
      SetHeader(GetDlgItem(wnd,101),"File             \9Size     \9Date        \9");
      SendDlgItemMessage(wnd,100,LB_RESETCONTENT,0,0);
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_10 \9 12K \9 12.03.2004 \9");
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_11 \9 29K \9 01.08.2004 \9");
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_12 \9 18K \9 20.11.2004 \9");
    break;
    case WM_DRAWITEM:if(wparam<>0) DrawListString(GetDlgItem(wnd,101),(pDRAWITEMSTRUCT)(lparam)); break;
    case WM_MEASUREITEM:break;//set height string
    case WM_VKEYTOITEM:break;//execute push keyboard key
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

