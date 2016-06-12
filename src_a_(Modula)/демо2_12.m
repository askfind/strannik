// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.12:Список с заголовком

module Demo2_12;
import Win32;

const 
  hINSTANCE=0x400000;

//поиск символа в строке
procedure lstrposc(sym:char; str:pstr):integer;
var i:integer;
begin
  if str=nil then return -1 end;
  i:=0;
  while (str[i]<>'\0')and(str[i]<>sym) do
    i:=i+1;
  end;
  if str[i]=sym
    then return i
    else return -1
  end
end lstrposc;

//удаление подстроки
procedure lstrdel(str:pstr; pos,len:integer);
var i,l:integer;
begin
  if pos<0 then
    len:=len+pos;
    pos:=0;
  end;
  if len>=0 then
    l:=lstrlen(str);
    if pos+len>l then
      if pos<l then str[pos]:='\0' else end
    else
      for i:=1 to l-(pos+len)+1 do
        str[pos+i-1]:=str[pos+i+len-1];
      end
    end
  end
end lstrdel;

//заполнить окно заголовка
procedure ЗаполнитьЗаголовок(заголовок:HWND; формат:pstr);
var
  регион:RECT; элемент:HDITEM; тек,макс:integer;
  текст,строка:string[500];
begin
  GetClientRect(заголовок,регион);
  макс:=0;
  for тек:=0 to lstrlen(формат)-1 do
  if формат[тек]<>'\9' then
    inc(макс)
  end end;
  lstrcpyn(текст,формат,500);
  тек:=0;
  while lstrposc('\9',текст)>=0 do
  with элемент do
    lstrcpy(строка,текст);
    строка[lstrposc('\9',текст)]:='\0';
    mask:=HDI_TEXT | HDI_FORMAT | HDI_WIDTH;
    pszText:=addr(строка);
    cxy:=(регион.right-регион.left)*lstrlen(строка) div (макс-1);
    cchTextMax:=lstrlen(строка);
    fmt:=HDF_LEFT | HDF_STRING;
    SendMessage(заголовок,HDM_INSERTITEM,тек,cardinal(addr(элемент)));
    lstrdel(текст,0,lstrposc('\9',текст)+1);
    inc(тек);
  end end;
end ЗаполнитьЗаголовок;

// нарисовать строку списка
procedure НарисоватьСтроку(заголовок:HWND; пар:pDRAWITEMSTRUCT);
var строка,текст:string[1000]; рег:RECT; тек,смещ:integer; элем:HDITEM;
begin
with пар^ do
  SendMessage(hwndItem,LB_GETTEXT,itemID,integer(addr(текст)));
  тек:=0;
  смещ:=0;
  while lstrposc('\9',текст)>=0 do
    lstrcpy(строка,текст);
    строка[lstrposc('\9',текст)]:='\0';
    элем.mask:=HDI_WIDTH;
    SendMessage(заголовок,HDM_GETITEM,тек,integer(addr(элем)));
    рег:=rcItem;
    inc(рег.left,смещ);
    рег.right:=рег.left+элем.cxy;
    if (itemState and ODS_SELECTED<>0)
      then SetTextColor(hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(hDC,GetSysColor(COLOR_HIGHLIGHT));
      else SetTextColor(hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(hDC,GetSysColor(COLOR_MENU));
    end;
    ExtTextOut(hDC,рег.left,рег.top,ETO_CLIPPED | ETO_OPAQUE,addr(рег),строка,lstrlen(строка),nil);
    lstrdel(текст,0,lstrposc('\9',текст)+1);
    inc(тек);
    inc(смещ,элем.cxy);
  end
end
end НарисоватьСтроку;

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
procedure procDLG_LIST(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:
      ЗаполнитьЗаголовок(GetDlgItem(wnd,101),"File             \9Size     \9Date        \9");
      SendDlgItemMessage(wnd,100,LB_RESETCONTENT,0,0);
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_10 \9 12K \9 12.03.2004 \9"));
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_11 \9 29K \9 01.08.2004 \9"));
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_12 \9 18K \9 20.11.2004 \9"));|
    WM_DRAWITEM:if wparam<>0 then НарисоватьСтроку(GetDlgItem(wnd,101),pDRAWITEMSTRUCT(lparam)) end;|
    WM_MEASUREITEM:|//высота строки списка
    WM_VKEYTOITEM:|//обработать нажатие на клавиатуру в списке
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:EndDialog(wnd,1);|
    end;|
  else return false
  end;
  return true
end procDLG_LIST;

begin
  InitCommonControlsEx(nil);
  DialogBoxParam(hINSTANCE,"DLG_LIST",0,addr(procDLG_LIST),0);
end Demo2_12.

