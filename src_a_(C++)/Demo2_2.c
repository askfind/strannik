// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.2:Use ListView

include Win32

define hINSTANCE 0x400000

define id1 100
define id2 101
define id3 102
define id4 200
define id5 1000

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

uint id6;
uint id7;

//================= init listview =======================

void id8(HWND id9, uint id10)
{HIMAGELIST id11; HBITMAP id12; RECT id13; LV_COLUMN id14;

  InitCommonControls();
//images list
  id11=ImageList_Create(20,20,0,2,0);
  id12=LoadBitmap(hINSTANCE,"TreeOpen"); id6=ImageList_Add(id11,id12,0);
  id12=LoadBitmap(hINSTANCE,"TreeClose"); id7=ImageList_Add(id11,id12,0);
  SendMessage(GetDlgItem(id9,id10),LVM_SETIMAGELIST,LVSIL_NORMAL,id11);
  SendMessage(GetDlgItem(id9,id10),LVM_SETIMAGELIST,LVSIL_SMALL,id11);
//colons list
  GetClientRect(GetDlgItem(id9,id10),id13);
  with(id14,id13) {
    mask=LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;
    fmt=LVCFMT_LEFT; pszText="Name"; cchTextMax=lstrlen(pszText); cx=right*40 div 100; SendMessage(GetDlgItem(id9,id10),LVM_INSERTCOLUMN,0,(int)(&id14));
    fmt=LVCFMT_LEFT; pszText="Size"; cchTextMax=lstrlen(pszText); cx=right*20 div 100; SendMessage(GetDlgItem(id9,id10),LVM_INSERTCOLUMN,1,(int)(&id14));
    fmt=LVCFMT_LEFT; pszText="Data"; cchTextMax=lstrlen(pszText); cx=right*40 div 100; SendMessage(GetDlgItem(id9,id10),LVM_INSERTCOLUMN,2,(int)(&id14));
  }
}

void id15(HWND id16, int id17, char* id18, HBITMAP id12)
{LV_ITEM id14;

  with(id14) {
    RtlZeroMemory(&id14,sizeof(LV_ITEM));
    mask=LVIF_TEXT | LVIF_IMAGE;
    iItem=id17;
    iImage=id12;
    iSubItem=0;
    pszText=id18;
    cchTextMax=lstrlen(pszText);
    SendMessage(id16,LVM_INSERTITEM,0,(int)(&id14));
  }
}

//================= fill listview =======================

void id19(HWND id16)
{
  SendMessage(id16,LVM_DELETEALLITEMS,0,0);
  id15(id16,0,"0 item",id7);
  id15(id16,1,"1 item",id7);
  id15(id16,2,"2 item",id7);
}

//================= add new item after current =======================

void id20(HWND id16)
{int id21;

  id21=SendMessage(id16,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  id15(id16,id21+1,"Новый элемент",id6);
}

//================= delete current item =======================

void id22(HWND id16)
{int id21;

  id21=SendMessage(id16,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  SendMessage(id16,LVM_DELETEITEM,id21,0);
}

//================= change sort of the list =======================

void id23(HWND id16)
{uint id24;

  id24=GetWindowLong(id16,GWL_STYLE);
  switch(id24 & (LVS_REPORT | LVS_LIST | LVS_SMALLICON | LVS_ICON)) {
    case LVS_REPORT:id24=(id24 & (! LVS_REPORT)) | LVS_LIST; break;
    case LVS_LIST:id24=(id24 & (! LVS_LIST)) | LVS_SMALLICON; break;
    case LVS_SMALLICON:id24=(id24 & (! LVS_SMALLICON)) | LVS_ICON; break;
    case LVS_ICON:id24=(id24 & (! LVS_ICON)) | LVS_REPORT; break;
  }
  SetWindowLong(id16,GWL_STYLE,id24);
}

//================= processing of the notices from the window =======================

bool id25(HWND id16, LV_DISPINFO* id26)
{
  with(id26^.hdr,id26^.item) {
  switch(code) {
    case LVN_GETDISPINFO:if(mask & LVIF_TEXT<>0) { //text
      switch(iSubItem) { //number in iItem
        case 1:pszText="230"; break;
        case 2:pszText="12.09.2001"; break;
      }
      return true;
    } break;
  }}
  return false;
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:id8(wnd,id5); id19(GetDlgItem(wnd,id5)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case id1:id20(GetDlgItem(wnd,id5)); break;
      case id2:id22(GetDlgItem(wnd,id5)); break;
      case id3:id23(GetDlgItem(wnd,id5)); break;
      case IDOK: case id4:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_NOTIFY:switch(loword(wparam)) {
      case id5:return id25(GetDlgItem(wnd,id5),(void*)lparam); break;
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

