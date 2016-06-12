// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.1:Use Tree

include "Win32"

define hINSTANCE 0x400000

define id1 100
define id2 101
define id3 200
define id4 1000

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

uint id5;
uint id6;

//================= add item into tree =======================

HTREEITEM id7(HWND id8, HTREEITEM id9, HTREEITEM id10, char* id11, HBITMAP id12, HBITMAP id13)
{
TV_INSERTSTRUCT id14;

  RtlZeroMemory(&id14,sizeof(TV_INSERTSTRUCT));
  with(id14,item) {
    mask=TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;
    pszText=id11;
    cchTextMax=lstrlen(id11);
    iImage=id12;
    iSelectedImage=id13;
    hInsertAfter=id10;
    hParent=id9;  
  }
  return (HTREEITEM) SendMessage(id8,TVM_INSERTITEM,0,(int)(&id14));
}

//================= create window with tree =======================

void id15(HWND id16, uint id17)
{
HIMAGELIST id18; HBITMAP id12;
  InitCommonControls();
  id18=ImageList_Create(20,20,0,2,0);
  id12=LoadBitmap(hINSTANCE,"TreeOpen"); id5=ImageList_Add(id18,id12,0);
  id12=LoadBitmap(hINSTANCE,"TreeClose"); id6=ImageList_Add(id18,id12,0);
  SendMessage(GetDlgItem(id16,id17),TVM_SETIMAGELIST,TVSIL_NORMAL,id18);
}

//================= fill tree =======================

void id19(HWND id8)
{
HTREEITEM id20,id21,id22;

  id20=id7(id8,TVI_ROOT,TVI_FIRST,"root item",id6,id5);
  id21=id7(id8,id20,TVI_LAST,"first level, item 1",id6,id5);
  id22=id7(id8,id21,TVI_LAST,"second level, item 1",id6,id5);
  id22=id7(id8,id21,TVI_LAST,"second level, item 2",id6,id5);
  id21=id7(id8,id20,TVI_LAST,"first level, item 2",id6,id5);
  id22=id7(id8,id21,TVI_LAST,"second level, item 3",id6,id5);
}

//================= add new item after current =======================

void id23(HWND id8)
{
HTREEITEM id24,id25;

  id24=SendMessage(id8,TVM_GETNEXTITEM,TVGN_CARET,0);
  id25=SendMessage(id8,TVM_GETNEXTITEM,TVGN_PARENT,id24);
  id7(id8,id25,id24,"новый элемент",id6,id5);
}

//================= delete current item =======================

void id26(HWND id8)
{
HTREEITEM id24;

  id24=SendMessage(id8,TVM_GETNEXTITEM,TVGN_CARET,0);
  SendMessage(id8,TVM_DELETEITEM,0,id24);
}

//================= processing of the notices from the window =======================

bool id27(HWND id8, TV_DISPINFO* id28)
{
  with(id28->hdr,id28->item) {
  switch(code) {
    case TVN_ENDLABELEDIT://correct item text
      if(pszText==nil) return false;
      else {
        MessageBox(0,pszText,"New text",0);
        return true;
      } break;
  }}
  return false;
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:id15(wnd,id4); id19(GetDlgItem(wnd,id4)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case id1:id23(GetDlgItem(wnd,id4)); break;
      case id2:id26(GetDlgItem(wnd,id4)); break;
      case IDOK: case id3:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_NOTIFY:switch(loword(wparam)) {
      case id4:return id27(GetDlgItem(wnd,id4),(void*)lparam); break;
    } break;
  default:return false; break;
  }
  return true;
}

//================= call dialog ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

