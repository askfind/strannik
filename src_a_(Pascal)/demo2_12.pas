// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.12:Listview with header

program Demo2_12;
uses Win32;

const 
  hINSTANCE=0x400000;

//search symbol in string
  function lstrposc(sym:char; str:pstr):integer;
  var i:integer;
  begin
    if str=nil then return -1;
    i:=0;
    while (str[i]<>'\0')and(str[i]<>sym) do
      i:=i+1;
    if str[i]=sym
      then return i
      else return -1
  end;

//substring delete
  procedure lstrdel(str:pstr; pos,len:integer);
  var i,l:integer;
  begin
    if pos<0 then begin
      len:=len+pos;
      pos:=0;
    end;
    if len>=0 then begin
      l:=lstrlen(str);
      if pos+len>l then
        if pos<l then str[pos]:='\0' else
      else
        for i:=1 to l-(pos+len)+1 do
          str[pos+i-1]:=str[pos+i+len-1];
    end
  end;

//set header paths
procedure SetHeader(header:HWND; format:pstr);
var
  reg:RECT; item:HDITEM; car,max:integer;
  text,str:string[500];
begin
  GetClientRect(header,reg);
  max:=0;
  for car:=0 to lstrlen(format)-1 do
  if format[car]<>'\9' then
    inc(max);
  lstrcpyn(text,format,500);
  car:=0;
  while lstrposc('\9',text)>=0 do
  with item do begin
    lstrcpy(str,text);
    str[lstrposc('\9',text)]:='\0';
    mask:=HDI_TEXT | HDI_FORMAT | HDI_WIDTH;
    pszText:=addr(str);
    cxy:=(reg.right-reg.left)*lstrlen(str) div (max-1);
    cchTextMax:=lstrlen(str);
    fmt:=HDF_LEFT | HDF_STRING;
    SendMessage(header,HDM_INSERTITEM,car,dword(addr(item)));
    lstrdel(text,0,lstrposc('\9',text)+1);
    inc(car);
  end;
end;

//Draw list string
procedure DrawListString(header:HWND; par:pDRAWITEMSTRUCT);
var str,text:string[1000]; reg:RECT; car,track:integer; item:HDITEM;
begin
with par^ do begin
  SendMessage(hwndItem,LB_GETTEXT,itemID,integer(addr(text)));
  car:=0;
  track:=0;
  while lstrposc('\9',text)>=0 do begin
    lstrcpy(str,text);
    str[lstrposc('\9',text)]:='\0';
    item.mask:=HDI_WIDTH;
    SendMessage(header,HDM_GETITEM,car,integer(addr(item)));
    reg:=rcItem;
    inc(reg.left,track);
    reg.right:=reg.left+item.cxy;
    if (itemState and ODS_SELECTED<>0)
      then begin SetTextColor(hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(hDC,GetSysColor(COLOR_HIGHLIGHT)); end
      else begin SetTextColor(hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(hDC,GetSysColor(COLOR_MENU)); end;
    ExtTextOut(hDC,reg.left,reg.top,ETO_CLIPPED | ETO_OPAQUE,addr(reg),str,lstrlen(str),nil);
    lstrdel(text,0,lstrposc('\9',text)+1);
    inc(car);
    inc(track,item.cxy);
  end
end
end;

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
function procDLG_LIST(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:begin
      SetHeader(GetDlgItem(wnd,101),"File             \9Size     \9Date        \9");
      SendDlgItemMessage(wnd,100,LB_RESETCONTENT,0,0);
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_10 \9 12K \9 12.03.2004 \9"));
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_11 \9 29K \9 01.08.2004 \9"));
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_12 \9 18K \9 20.11.2004 \9"));
    end;
    WM_DRAWITEM:if wparam<>0 then DrawListString(GetDlgItem(wnd,101),pDRAWITEMSTRUCT(lparam));
    WM_MEASUREITEM:;//set height string
    WM_VKEYTOITEM:;//execute push keyboard key
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:EndDialog(wnd,1);
    end;
  else return false
  end;
  return true
end;

begin
  InitCommonControlsEx(nil);
  DialogBoxParam(hINSTANCE,"DLG_LIST",0,addr(procDLG_LIST),0);
end.

