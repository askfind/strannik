// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.1:Use Tree

module Demo2_1;
import Win32;

const 
  hINSTANCE=0x400000;

  id1=100;
  id2=101;
  id3=200;
  id4=1000;

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

var
  id5:cardinal;
  id6:cardinal;

//================= add item into tree =======================

procedure id7(id8:HWND; id9,id10:HTREEITEM; id11:pstr, id12,id13:HBITMAP):HTREEITEM;
var id14:TV_INSERTSTRUCT;
begin
  RtlZeroMemory(addr(id14),sizeof(TV_INSERTSTRUCT));
  with id14,item do
    mask:=TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;
    pszText:=id11;
    cchTextMax:=lstrlen(id11);
    iImage:=id12;
    iSelectedImage:=id13;
    hInsertAfter:=id10;
    hParent:=id9;  
  end;
  return HTREEITEM(SendMessage(id8,TVM_INSERTITEM,0,integer(addr(id14))))
end id7;

//================= create window with tree =======================

procedure id15(id16:HWND; id17:cardinal);
var id18:HIMAGELIST; id12:HBITMAP;
begin
  InitCommonControls();
  id18:=ImageList_Create(20,20,0,2,0);
  id12:=LoadBitmap(hINSTANCE,"TreeOpen"); id5:=ImageList_Add(id18,id12,0);
  id12:=LoadBitmap(hINSTANCE,"TreeClose"); id6:=ImageList_Add(id18,id12,0);
  SendMessage(GetDlgItem(id16,id17),TVM_SETIMAGELIST,TVSIL_NORMAL,id18);
end id15;

//================= fill tree =======================

procedure id19(id8:HWND);
var id20,id21,id22:HTREEITEM;
begin
  id20:=id7(id8,TVI_ROOT,TVI_FIRST,"root item",id6,id5);
  id21:=id7(id8,id20,TVI_LAST,"first level, item 1",id6,id5);
  id22:=id7(id8,id21,TVI_LAST,"second level, item 1",id6,id5);
  id22:=id7(id8,id21,TVI_LAST,"second level, item 2",id6,id5);
  id21:=id7(id8,id20,TVI_LAST,"first level, item 2",id6,id5);
  id22:=id7(id8,id21,TVI_LAST,"second level, item 3",id6,id5);
end id19;

//================= add new item after current =======================

procedure id23(id8:HWND);
var id24,id25:HTREEITEM;
begin
  id24:=SendMessage(id8,TVM_GETNEXTITEM,TVGN_CARET,0);
  id25:=SendMessage(id8,TVM_GETNEXTITEM,TVGN_PARENT,id24);
  id7(id8,id25,id24,"new item",id6,id5);
end id23;

//================= delete current item =======================

procedure id26(id8:HWND);
var id24:HTREEITEM;
begin
  id24:=SendMessage(id8,TVM_GETNEXTITEM,TVGN_CARET,0);
  SendMessage(id8,TVM_DELETEITEM,0,id24);
end id26;

//================= processing of the notices from the window =======================

procedure id27(id8:HWND; id28:pTV_DISPINFO):boolean;
begin
  with id28^.hdr,id28^.item do
  case code of
    TVN_ENDLABELEDIT://correct item text
      if pszText=nil then return false
      else
        MessageBox(0,pszText,"New text",0);
        return true
      end;|
  end end;
  return false
end id27;

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,115,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_1:Use Tree"
begin
  control "Ok",id3,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,62,97,45,14
  control "",id4,"SysTreeView32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TVS_HASLINES | TVS_HASBUTTONS | TVS_LINESATROOT | TVS_EDITLABELS,8,24,145,67
  control "Delete",id2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,97,6,40,12
  control "Add",id1,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,33,6,40,12
end;

//================= dialog function =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:id15(wnd,id4); id19(GetDlgItem(wnd,id4));|
    WM_COMMAND:case loword(wparam) of
      id1:id23(GetDlgItem(wnd,id4));|
      id2:id26(GetDlgItem(wnd,id4));|
      IDOK,id3:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
    WM_NOTIFY:case loword(wparam) of
      id4:return id27(GetDlgItem(wnd,id4),address(lparam));|
    end;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= call dialog ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end Demo2_1.

