// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.8:Installation program

include Win32

define hINSTANCE 0x400000

define id1 200
define id2 201
define id3 202

enum id4 {id5,id6,id7};
typedef struct {
    char* id8;
    char* id9;
    uint id10;
  } [id4] id11;

define id12 id11{
  {"Prolog","DLG_1",PSWIZB_NEXT},
  {"Program folder","DLG_2",PSWIZB_BACK | PSWIZB_NEXT},
  {"Start installation","DLG_3",PSWIZB_BACK | PSWIZB_FINISH}}

  PROPSHEETPAGE id13[id4];
  PROPSHEETHEADER id14;
  id4 id15;
  char id16[500];

//================= pages dialoges =======================

dialog DLG_1 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Prolog"
begin
  control "Welcome in the installation program.",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,38,183,13
  control "Please, follow the further instructions",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,52,183,13
  control "Press 'Next'",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,66,183,13
end;

dialog DLG_2 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Program folder"
begin
  control "Select a folder for placement of the program:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,38,183,12
  control "",id1,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,5,55,183,12
  control "Browse",id2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,148,71,40,12
end;

dialog DLG_3 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Start installation"
begin
  control "All is ready to installation",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,5,183,13
  control "You have selected the following parameters:",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,19,183,13
  control "",id3,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,34,185,43
  control "For the beginning installations press 'Start'",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,4,79,183,13
end;

//============ init page of dialog  ==================

void id17(HWND wnd, id4 id18)
{
  switch(id18) {
    case id5:break;
    case id6:SetDlgItemText(wnd,id1,id16); break;
    case id7:SetDlgItemText(wnd,id3,id16); break;
  }
}

void id19(HWND wnd, id4 id18)
{
  switch(id18) {
    case id5: break;
    case id6:GetDlgItemText(wnd,id1,id16,500); break;
    case id7: break;
  }
}

//================= dialog function  =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{pNMHDR id20;

  switch(message) {
    case WM_INITDIALOG: break;
    case WM_COMMAND:switch(loword(wparam)) {
      case id2:MessageBox(0,"Select files see Demo2_6","Browse pressed",0); break;
    } break;
    case WM_NOTIFY:
      id20=pNMHDR(lparam);
      switch(id20->code) {
        case PSN_SETACTIVE://page activate
          SendMessage(GetParent(wnd),PSM_SETWIZBUTTONS,0,id12[id15].id10);
          id17(wnd,id15);
        break;
        case PSN_WIZBACK:case PSN_WIZNEXT://page deactivate
          id19(wnd,id15);
          if(id20^.code==PSN_WIZBACK) id15--;
          else id15++;
        break;
        case PSN_WIZFINISH://end dialog
          MessageBox(0,id16,"Select folder:",0); break;
      } return false;
    break;    
  default:return false; break;
  }
  return true;
}

//================= init and call installation ====================

void main()
{
//init pages
  for(id15=id5; id15<=id7; id15++)
  with(id13[id15]) {
    RtlZeroMemory(&(id13[id15]),sizeof(PROPSHEETPAGE));
    dwSize=sizeof(PROPSHEETPAGE);
    dwFlags=PSP_USETITLE;
    hInstance=hINSTANCE;
    pszTemplate=id12[id15].id9;
    pszTitle=id12[id15].id8;
    pfnDlgProc=&procDLG_MAIN;
  }
//init title
  with(id14) {
    RtlZeroMemory(&id14,sizeof(PROPSHEETHEADER));
    dwSize=sizeof(PROPSHEETHEADER);
    dwFlags=PSH_PROPSHEETPAGE | PSH_WIZARD;
    hwndParent=0;
    hInstance=hINSTANCE;
    pszCaption="Demo2_8";
    nPages=ord(id7)+1;
    nStartPage=0;
    ppsp=&id13;
  }
//call installation
  lstrcpy(id16,"c:\Program Files\demo2_8");
  InitCommonControls();
  id15=id5;
  PropertySheet(id14);
}

