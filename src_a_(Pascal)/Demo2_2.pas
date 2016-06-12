// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.2:Use ListView

program Demo2_2;
uses Win32;

const 
  hINSTANCE=0x400000;

  id1=100;
  id2=101;
  id3=102;
  id4=200;
  id5=1000;

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

var
  id6:dword;
  id7:dword;

//================= init listview =======================

procedure id8(id9:HWND; id10:dword);
var id11:HIMAGELIST; id12:HBITMAP; id13:RECT; id14:LV_COLUMN;
begin
  InitCommonControls();
//images list
  id11:=ImageList_Create(20,20,0,2,0);
  id12:=LoadBitmap(hINSTANCE,"TreeOpen"); id6:=ImageList_Add(id11,id12,0);
  id12:=LoadBitmap(hINSTANCE,"TreeClose"); id7:=ImageList_Add(id11,id12,0);
  SendMessage(GetDlgItem(id9,id10),LVM_SETIMAGELIST,LVSIL_NORMAL,id11);
  SendMessage(GetDlgItem(id9,id10),LVM_SETIMAGELIST,LVSIL_SMALL,id11);
//colons list
  GetClientRect(GetDlgItem(id9,id10),id13);
  with id14,id13 do begin
    mask:=LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;
    fmt:=LVCFMT_LEFT; pszText:="Name"; cchTextMax:=lstrlen(pszText); cx:=right*40 div 100; SendMessage(GetDlgItem(id9,id10),LVM_INSERTCOLUMN,0,integer(addr(id14)));
    fmt:=LVCFMT_LEFT; pszText:="Size"; cchTextMax:=lstrlen(pszText); cx:=right*20 div 100; SendMessage(GetDlgItem(id9,id10),LVM_INSERTCOLUMN,1,integer(addr(id14)));
    fmt:=LVCFMT_LEFT; pszText:="Data"; cchTextMax:=lstrlen(pszText); cx:=right*40 div 100; SendMessage(GetDlgItem(id9,id10),LVM_INSERTCOLUMN,2,integer(addr(id14)));
  end;
end;

procedure id15(id16:HWND; id17:integer; id18:pstr; id12:HBITMAP);
var id14:LV_ITEM;
begin
  with id14 do begin
    RtlZeroMemory(addr(id14),sizeof(LV_ITEM));
    mask:=LVIF_TEXT | LVIF_IMAGE;
    iItem:=id17;
    iImage:=id12;
    iSubItem:=0;
    pszText:=id18;
    cchTextMax:=lstrlen(pszText);
    SendMessage(id16,LVM_INSERTITEM,0,integer(addr(id14)));
  end
end;

//================= fill listview =======================

procedure id19(id16:HWND);
begin
  SendMessage(id16,LVM_DELETEALLITEMS,0,0);
  id15(id16,0,"0 item",id7);
  id15(id16,1,"1 item",id7);
  id15(id16,2,"2 item",id7);
end;

//================= add new item after current =======================

procedure id20(id16:HWND);
var id21:integer;
begin
  id21:=SendMessage(id16,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  id15(id16,id21+1,"New item",id6);
end;

//================= delete current item =======================

procedure id22(id16:HWND);
var id21:integer;
begin
  id21:=SendMessage(id16,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  SendMessage(id16,LVM_DELETEITEM,id21,0);
end;

//================= change sort of the list =======================

procedure id23(id16:HWND);
var id24:dword;
begin
  id24:=GetWindowLong(id16,GWL_STYLE);
  case id24 and (LVS_REPORT | LVS_LIST | LVS_SMALLICON | LVS_ICON) of
    LVS_REPORT:id24:=(id24 and (not LVS_REPORT))or LVS_LIST;
    LVS_LIST:id24:=(id24 and (not LVS_LIST))or LVS_SMALLICON;
    LVS_SMALLICON:id24:=(id24 and (not LVS_SMALLICON))or LVS_ICON;
    LVS_ICON:id24:=(id24 and (not LVS_ICON))or LVS_REPORT;
  end;
  SetWindowLong(id16,GWL_STYLE,id24);
end;

//================= processing of the notices from the window =======================

function id25(id16:HWND; id26:pLV_DISPINFO):boolean;
begin
  with id26^.hdr,id26^.item do
  case code of
    LVN_GETDISPINFO:if mask and LVIF_TEXT<>0 then begin//text
      case iSubItem of //number in iItem
        1:pszText:="230";
        2:pszText:="12.09.2001";
      end;
      id25:=true
    end;
  end;
  id25:=false
end;

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,115,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_2:Use listview"
begin
  control "Ok",id4,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,62,97,45,14
  control "Delete",id2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,115,8,40,12
  control "Add",id1,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,6,8,40,12
  control "Change",id3,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,54,8,56,12
  control "",id5,"SysListView32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LVS_REPORT,8,25,147,68
end;

//================= dialog function =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:begin id8(wnd,id5); id19(GetDlgItem(wnd,id5)) end;
    WM_COMMAND:case loword(wparam) of
      id1:id20(GetDlgItem(wnd,id5));
      id2:id22(GetDlgItem(wnd,id5));
      id3:id23(GetDlgItem(wnd,id5));
      IDOK,id4:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
    WM_NOTIFY:case loword(wparam) of
      id5:procDLG_MAIN:=id25(GetDlgItem(wnd,id5),address(lparam));
    end;
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= call dialog ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

