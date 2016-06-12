// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.9:Use PropertySheet (Options)

include Win32

define hINSTANCE 0x400000
define id1 200 
define id2 201 
define id3 202 
define id4 203 
define id5 204 

enum id6 {id7,id8};
typedef struct {
    char* id9;
    char* id10;
  } [id6] id11;

define id12 id11{
  {"Radiobuttons","DLG_1"},
  {"Program folder","DLG_2"}}

  PROPSHEETPAGE id13[id6];
  HANDLE id14[id6];
  PROPSHEETHEADER id15;
  id6 id16;
  char id17[100];
  char id18[500];
  int id19;

//================= pages dialoges =======================

dialog DLG_1 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Radiobuttons"
begin
  control "1 variant",id3,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,24,108,14
  control "2 variant",id4,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,39,108,14
  control "3 variant",id5,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,54,108,14
end;

dialog DLG_2 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Program folders"
begin
  control "Folder for placement of the program:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,39,126,11
  control "",id1,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,5,57,126,11
  control "Browse",id2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,87,73,40,12
end;

//================= dialog functions =======================

bool procDLG_1(HWND wnd, int message, int wparam, int lparam)
{pNMHDR id20;

  switch(message) {
    case WM_INITDIALOG:break;
    case WM_NOTIFY:id20=pNMHDR(lparam);
    switch(id20->code) {
      case PSN_SETACTIVE://page activate
        switch(id19) {
          case 0:SendDlgItemMessage(wnd,id3,BM_SETCHECK,BST_CHECKED,0); break;
          case 1:SendDlgItemMessage(wnd,id4,BM_SETCHECK,BST_CHECKED,0); break;
          case 2:SendDlgItemMessage(wnd,id5,BM_SETCHECK,BST_CHECKED,0); break;
        }
      break;
      case PSN_KILLACTIVE:
        if(IsDlgButtonChecked(wnd,id3)==BST_CHECKED) id19=0;
        if(IsDlgButtonChecked(wnd,id4)==BST_CHECKED) id19=1;
        if(IsDlgButtonChecked(wnd,id5)==BST_CHECKED) id19=2;
      break;
    }
    return false; break;
  default:return false; break;
  }
  return true;
}

bool procDLG_2(HWND wnd, int message, int wparam, int lparam)
{pNMHDR id20;

  switch(message) {
    case WM_INITDIALOG: break;
    case WM_COMMAND:switch(loword(wparam)) {
      case id2:MessageBox(0,"Select files see Demo2_6","Browse pressed",0); break;
    } break;
    case WM_NOTIFY:id20=pNMHDR(lparam);
    switch(id20->code) {
      case PSN_SETACTIVE:SetDlgItemText(wnd,id1,id18); break;
      case PSN_KILLACTIVE:GetDlgItemText(wnd,id1,id18,500); break;
    }
    return false; break;
  default:return false; break;
  }
  return true;
}

//================= init and call options ====================

void main()
{
//init pages
  for(id16=id7; id16<=id8; id16++)
  with(id13[id16]) {
    RtlZeroMemory(&(id13[id16]),sizeof(PROPSHEETPAGE));
    dwSize=sizeof(PROPSHEETPAGE);
    dwFlags=PSP_USETITLE;
    hInstance=hINSTANCE;
    pszTemplate=id12[id16].id10;
    pszTitle=id12[id16].id9;
    switch(id16) {
      case id7:pfnDlgProc=&procDLG_1; break;
      case id8:pfnDlgProc=&procDLG_2; break;
    }
    id14[id16]=CreatePropertySheetPage(&(id13[id16]));
  }
//init title
  with(id15) {
    RtlZeroMemory(&id15,sizeof(PROPSHEETHEADER));
    dwSize=sizeof(PROPSHEETHEADER);
    dwFlags=0;
    hwndParent=0;
    hInstance=hINSTANCE;
    pszCaption="Demo2_9";
    nPages=2;
    nStartPage=0;
    ppsp=&id14;
  }
//call options
  lstrcpy(id18,"c:\Program Files\demo2_9");
  id19=1;
  InitCommonControls();
  PropertySheet(id15);
  wvsprintf(id17,"%li",&id19);
  MessageBox(0,id17,"Selected variant:",0);
  MessageBox(0,id18,"Selected folder:",0);
}

