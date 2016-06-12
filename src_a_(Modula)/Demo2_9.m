// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.9:Use PropertySheet (Options)

module Demo2_9;
import Win32;

const 
  hINSTANCE=0x400000;

  id1=200;
  id2=201;
  id3=202;
  id4=203;
  id5=204;

type
  id6=(id7,id8);
  id9=array[id6]of record
    id10:pstr;
    id11:pstr;
  end;

const id12=id9{
  {"Radiobuttons","DLG_1"},
  {"Program folder","DLG_2"}};

var
  id13:array[id6]of PROPSHEETPAGE;
  id14:array[id6]of HANDLE;
  id15:PROPSHEETHEADER;
  id16:id6;
  id17:string[100];
  id18:string[500];
  id19:integer;

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

procedure procDLG_1(wnd:HWND; message,wparam,lparam:integer):boolean;
var id20:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_NOTIFY:id20:=pNMHDR(lparam);
    case id20^.code of
      PSN_SETACTIVE://page activate
        case id19 of
          0:SendDlgItemMessage(wnd,id3,BM_SETCHECK,BST_CHECKED,0);|
          1:SendDlgItemMessage(wnd,id4,BM_SETCHECK,BST_CHECKED,0);|
          2:SendDlgItemMessage(wnd,id5,BM_SETCHECK,BST_CHECKED,0);|
        end;|
      PSN_KILLACTIVE:
        if IsDlgButtonChecked(wnd,id3)=BST_CHECKED then id19:=0 end;
        if IsDlgButtonChecked(wnd,id4)=BST_CHECKED then id19:=1 end;
        if IsDlgButtonChecked(wnd,id5)=BST_CHECKED then id19:=2 end;|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_1;

procedure procDLG_2(wnd:HWND; message,wparam,lparam:integer):boolean;
var id20:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_COMMAND:case loword(wparam) of
      id2:MessageBox(0,"Select files see Demo2_6","Browse pressed",0);|
    end;|
    WM_NOTIFY:id20:=pNMHDR(lparam);
    case id20^.code of
      PSN_SETACTIVE:SetDlgItemText(wnd,id1,id18);|
      PSN_KILLACTIVE:GetDlgItemText(wnd,id1,id18,500);|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_2;

//================= init and call options ====================

begin
//init pages
  for id16:=id7 to id8 do
  with id13[id16] do
    RtlZeroMemory(addr(id13[id16]),sizeof(PROPSHEETPAGE));
    dwSize:=sizeof(PROPSHEETPAGE);
    dwFlags:=PSP_USETITLE;
    hInstance:=hINSTANCE;
    pszTemplate:=id12[id16].id11;
    pszTitle:=id12[id16].id10;
    case id16 of
      id7:pfnDlgProc:=addr(procDLG_1);|
      id8:pfnDlgProc:=addr(procDLG_2);|
    end;
    id14[id16]:=CreatePropertySheetPage(addr(id13[id16]));
  end end;
//init title
  with id15 do
    RtlZeroMemory(addr(id15),sizeof(PROPSHEETHEADER));
    dwSize:=sizeof(PROPSHEETHEADER);
    dwFlags:=0;
    hwndParent:=0;
    hInstance:=hINSTANCE;
    pszCaption:="Demo2_9";
    nPages:=2;
    nStartPage:=0;
    ppsp:=addr(id14);
  end;
//call options
  lstrcpy(id18,"c:\Program Files\demo2_9");
  id19:=1;
  InitCommonControls();
  PropertySheet(id15);
  wvsprintf(id17,"%li",addr(id19));
  MessageBox(0,id17,"Selected variant:",0);
  MessageBox(0,id18,"Selected folder:",0);
end Demo2_9.

