// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.8:Installation program

module Demo2_8;
import Win32;

const 
  hINSTANCE=0x400000;

  id1=200;
  id2=201;
  id3=202;

type
  id4=(id5,id6,id7);
  id8=array[id4]of record
    id9:pstr;
    id10:pstr;
    id11:cardinal;
  end;

const id12=id8{
  {"Prolog","DLG_1",PSWIZB_NEXT},
  {"Program folder","DLG_2",PSWIZB_BACK | PSWIZB_NEXT},
  {"Start installation","DLG_3",PSWIZB_BACK | PSWIZB_FINISH}};

var
  id13:array[id4]of PROPSHEETPAGE;
  id14:PROPSHEETHEADER;
  id15:id4;
  id16:string[500];

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

procedure id17(wnd:HWND; id18:id4);
begin
  case id18 of
    id5:|
    id6:SetDlgItemText(wnd,id1,id16);|
    id7:SetDlgItemText(wnd,id3,id16);|
  end
end id17;

procedure id19(wnd:HWND; id18:id4);
begin
  case id18 of
    id5:|
    id6:GetDlgItemText(wnd,id1,id16,500);|
    id7:|
  end
end id19;

//================= dialog function  =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
var id20:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_COMMAND:case loword(wparam) of
      id2:MessageBox(0,"Select files see Demo2_6","Browse pressed",0);|
    end;|
    WM_NOTIFY:id20:=pNMHDR(lparam);
    case id20^.code of
      PSN_SETACTIVE://page activate
        SendMessage(GetParent(wnd),PSM_SETWIZBUTTONS,0,id12[id15].id11);
        id17(wnd,id15);|
      PSN_WIZBACK,PSN_WIZNEXT://page deactivate
        id19(wnd,id15);
        if id20^.code=PSN_WIZBACK
          then dec(id15)
          else inc(id15)
        end;|
      PSN_WIZFINISH://end dialog
        MessageBox(0,id16,"Select folder:",0);|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= init and call installation ====================

begin
//init pages
  for id15:=id5 to id7 do
  with id13[id15] do
    RtlZeroMemory(addr(id13[id15]),sizeof(PROPSHEETPAGE));
    dwSize:=sizeof(PROPSHEETPAGE);
    dwFlags:=PSP_USETITLE;
    hInstance:=hINSTANCE;
    pszTemplate:=id12[id15].id10;
    pszTitle:=id12[id15].id9;
    pfnDlgProc:=addr(procDLG_MAIN);
  end end;
//init title
  with id14 do
    RtlZeroMemory(addr(id14),sizeof(PROPSHEETHEADER));
    dwSize:=sizeof(PROPSHEETHEADER);
    dwFlags:=PSH_PROPSHEETPAGE | PSH_WIZARD;
    hwndParent:=0;
    hInstance:=hINSTANCE;
    pszCaption:="Demo2_8";
    nPages:=ord(id7)+1;
    nStartPage:=0;
    ppsp:=addr(id13);
  end;
//call installation
  lstrcpy(id16,"c:\Program Files\demo2_8");
  InitCommonControls();
  id15:=id5;
  PropertySheet(id14);
end Demo2_8.

