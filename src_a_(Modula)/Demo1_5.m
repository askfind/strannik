// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 5:Text editor RTF-files

module Demo1_5;
import Win32;

icon "icon_rtf.bmp";
const INSTANCE=0x400000;

//===============================================
//                      VARIABLES
//===============================================

type
  id1=(id2,id3,id4,id5,id6,id7);
  id8=array[id1]of integer;
const
  id9=id8{35,10,20,15,10,10};

var
  id10:HWND;
  id11:HWND;
  id12:HWND;
  id13:HWND;
  id14:HANDLE;
  id15:string[500];
  id16:string[500];

//------------------------ editor commands ----------------------------

type
  id17=(
    id18,id19,id20,id21,id22,id23,id24,id25,
    id26,id27,id28,id29,id30,id31,id32,id33,
    id34,id35,
    id36,id37,id38,id39,id40,id41,id42,id43,
    id44,id45,
    id46);

  id47=(
    id48,id49,id50,id51,id52,id53);

type
  id54=array[id17]of pstr;
  id55=array[id47]of record
    id56:pstr;
    id57:id17;
    id58:id17;
  end;

const
  id59=id54{
    "New file","Open file...","Save file","Save As...","","Print...","","Exit",
    "Undo","","Cut\9Shift+Delete","Copy\9Ctrl+Insert","Paste\9Shift+Insert","Delete\9Delete","","Select All",
    "Find...","Next find\9F3",
    "Font","","Bold","Italic","","Align left","Align right","Align center",
    "Translate WINDOWS","Translate DOS",
    "Exit"};
  id60=id55{
    {"File",id18,id25},
    {"Edit",id26,id33},
    {"Find",id34,id35},
    {"Format",id36,id43},
    {"Tools",id44,id45},
    {"Exit",id46,id46}};

type id61=array[id17]of integer;
const id62=id61{
    1,2,3,4,0,5,0,0,
    6,0,7,8,9,10,0,0,
    11,12,
    13,0,14,15,0,16,17,18,
    19,20,
    0};

const
  id63=200;
  id64=101;

//===============================================
//              SYSTEM PROCEDURES
//===============================================

procedure mbI(id65:integer; id66:pstr);
var id67:string[100];
begin
  wvsprintf(id67,'%li',addr(id65));
  MessageBox(0,id67,id66,0);
end mbI;

//---------------- Create status ----------------

procedure id68(id69:HWND; id70:boolean);
var
  id71:array[id1]of integer;
  id72:RECT;
  id73:id1;
  id74,id75:integer;
begin
  if not id70 then
    id12:=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      nil,id69,0);
  end;
  GetClientRect(id69,id72);
  if id70 then
  with id72 do
    SendMessage(id12,WM_SIZE,right-left+1,bottom-top+1);
  end end;
  id74:=0;
  for id73:=id2 to id7 do
    id75:=(id72.right-id72.left+1)*id9[id73] div 100;
    id71[id73]:=id74+id75;
    inc(id74,id75)
  end;
  id71[id7]:=-1;
  SendMessage(id12,SB_SETPARTS,ord(id7)+1,cardinal(addr(id71)));
end id68;

//------------- Upgrade status --------------------

procedure id76(wnd:HWND);
var id77:string[500]; id78:CHARFORMAT;
begin
  SendMessage(id12,SB_SETTEXT,ord(id2),cardinal(addr(id15)));
  if boolean(SendMessage(id11,EM_GETMODIFY,0,0))
    then SendMessage(id12,SB_SETTEXT,ord(id3),cardinal("Modified"));
    else SendMessage(id12,SB_SETTEXT,ord(id3),cardinal(""));
  end;
  with id78 do
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(id11,EM_GETCHARFORMAT,1,cardinal(addr(id78)));
    SendMessage(id12,SB_SETTEXT,ord(id4),cardinal(addr(szFaceName)));
    yHeight:=yHeight div 20;
    wvsprintf(id77,"Size:%li",addr(yHeight));
    SendMessage(id12,SB_SETTEXT,ord(id5),cardinal(addr(id77)));
    if dwEffects and CFE_BOLD=0
      then SendMessage(id12,SB_SETTEXT,ord(id6),cardinal(""));
      else SendMessage(id12,SB_SETTEXT,ord(id6),cardinal("Bold"));
    end;
    if dwEffects and CFE_ITALIC=0
      then SendMessage(id12,SB_SETTEXT,ord(id7),cardinal(""));
      else SendMessage(id12,SB_SETTEXT,ord(id7),cardinal("Italic"));
    end;
  end
end id76;

//------------------------ Align ----------------------------

procedure id79(wnd:HWND; id80:integer);
var id78:PARAFORMAT;
begin
  with id78 do
    cbSize:=sizeof(PARAFORMAT);
    dwMask:=PFM_ALIGNMENT;
    case id80 of
      -1:wAlignment:=PFA_LEFT;|
      0:wAlignment:=PFA_CENTER;|
      1:wAlignment:=PFA_RIGHT;|
    end;
    SendMessage(id11,EM_SETPARAFORMAT,0,cardinal(addr(id78)));
  end
end id79;

//-------------------- select font -------------------------

procedure id81(wnd:HWND; id82:boolean);
var id78:CHARFORMAT;
begin
  with id78 do
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(id11,EM_GETCHARFORMAT,1,cardinal(addr(id78)));
    case id82 of
      true:dwMask:=CFM_BOLD; dwEffects:=(not dwEffects and CFE_BOLD)or(dwEffects and not CFE_BOLD);|
      false:dwMask:=CFM_ITALIC; dwEffects:=(not dwEffects and CFE_ITALIC)or(dwEffects and not CFE_ITALIC);|
    end;
    SendMessage(id11,EM_SETCHARFORMAT,SCF_SELECTION,cardinal(addr(id78)));
  end
end id81;

//-------------------- test text -------------------------

procedure id83(id84:pstr):boolean;
var id85:integer;
begin
  id85:=lstrlen(id84)-4;
  return (id85>=0)and((id84[id85+1]='t')or(id84[id85+1]='T'));
end id83;

//------------ backcall function (load) ----------

procedure id86(dwCookie:cardinal; pbBuff:address; cb:cardinal; pcb:pINT):cardinal;
begin
  pcb^:=_lread(dwCookie,pbBuff,cb);
  if pcb^<0 then
    pcb^:=0
  end;
  return 0;
end id86;

//-------------------- load file -------------------------

procedure id87(wnd:HWND; id84:pstr);
var id88:integer; id89:EDITSTREAM;
begin
  with id89 do
    id88:=_lopen(id84,0);
    if id88>0 then 
      dwCookie:=id88;
      dwError:=0;
      pfnCallback:=addr(id86);
      if id83(id84)
        then SendMessage(id11,EM_STREAMIN,SF_TEXT,cardinal(addr(id89)))
        else SendMessage(id11,EM_STREAMIN,SF_RTF,cardinal(addr(id89)))
      end;
      _lclose(id88);
       SendMessage(id11,EM_SETMODIFY,0,0)
    end
  end
end id87;

//------------ backcall function (save) ----------

procedure id90(dwCookie:cardinal; pbBuff:address; cb:cardinal; pcb:pINT):cardinal;
begin
  cb:=_lwrite(dwCookie,pbBuff,cb);
  pcb^:=cb;
  return 0;
end id90;

//-------------------- save file-------------------------

procedure id91(wnd:HWND; id84:pstr);
var id88:integer; id89:EDITSTREAM;
begin
  with id89 do
    id88:=_lcreat(id84,0);
    if id88>0 then
      dwCookie:=id88;
      dwError:=0;
      pfnCallback:=addr(id90);
      if id83(id84)
        then SendMessage(id11,EM_STREAMOUT,SF_TEXT,cardinal(addr(id89)))
        else SendMessage(id11,EM_STREAMOUT,SF_RTF,cardinal(addr(id89)))
      end;
      _lclose(id88);
       SendMessage(id11,EM_SETMODIFY,0,0)
    end
  end
end id91;

//-------------------- find dialog -------------------------

const
  id92=101;

dialog DLG_FIND 80,58,160,65,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Text find"
begin
  control "Text:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,5,3,149,11
  control "",id92,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,16,149,12
  control "Ok",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,31,48,45,12
  control "Cancel",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,82,48,45,12
end;

procedure id93(wnd:HWND; msg,wparam,lparam:cardinal):cardinal;
begin
  case msg of
    WM_INITDIALOG:SetDlgItemText(wnd,id92,id16);|
    WM_COMMAND:case loword(wparam) of
      IDOK:
        GetDlgItemText(wnd,id92,id16,500);
        EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
    else return(0);
  end;
  return(1);
end id93;

//--------------------------- toolbar init------------------------------

bitmap bmpToolbar="tool_rtf.bmp";

procedure id94(wnd:HWND);
var
  id95:array[1..50]of TBBUTTON;
  id96:integer;
  bmp:HBITMAP;
  id97:id47;
  id98:id17;
  id72:RECT;
begin
  InitCommonControls();
  bmp:=LoadBitmap(INSTANCE,"bmpToolbar");
  //buttons array
  id96:=0;
  for id97:=id48 to id52 do
  with id60[id97] do 
    //group
    for id98:=id57 to id58 do
    if (id62[id98]>0)and(id96<50) then
      inc(id96);
      RtlZeroMemory(addr(id95[id96]),sizeof(TBBUTTON));
      with id95[id96] do
        iBitmap:=id62[id98]-1;
        idCommand:=id63+integer(id98);
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_BUTTON;
      end;
    end end;
    //Interval between buttons
    if id96<50 then
      inc(id96);
      RtlZeroMemory(addr(id95[id96]),sizeof(TBBUTTON));
      with id95[id96] do
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_SEP;
      end
    end
  end end;
  //create toolbar
  id13:=CreateToolbarEx(
    wnd,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,id96,0,bmp,addr(id95),id96,20,20,20,20,sizeof(TBBUTTON));
  //correct pos toolbar
  with id72 do
    GetWindowRect(id13,id72);
    dec(top,10);
    MoveWindow(id13,left,top,right-left+1,bottom-top+1,true);
  end;
end id94;

//--------------------------- toolbar texts------------------------------

procedure id99(lparam:cardinal);
var
  id100:pNMHDR;
  id101:pTOOLTIPTEXT;
  id98:id17;
begin
  id100:=address(lparam);
  id101:=address(lparam);  
  with id100^,id101^ do
    id98:=id17(idFrom-id63);
    case code of
      TTN_NEEDTEXT:
        id98:=id17(idFrom-id63);
        lpszText:=id59[id98];|
    end
  end
end id99;

//--------------------------- RTF window size------------------------------

procedure id102(wnd:HWND);
var id103,id104,id105,id106:RECT;
begin
  with id106 do
    GetClientRect(wnd,id103);
    GetWindowRect(id13,id104);
    GetWindowRect(id12,id105);
    left:=5;
    right:=id103.right-id103.left-10;
    top:=id104.bottom-id104.top+5;
    bottom:=
      (id103.bottom-id103.top)-
      (id105.bottom-id105.top)-
      (id104.bottom-id104.top)-10;
    MoveWindow(id11,left,top,right,bottom,true);
  end
end id102;

//-------------------- change code -------------------------

procedure id107(wnd:HWND; id108:boolean);
var id109:pstr;
begin
  if not(not id83(id15)and
    (MessageBox(id10,"You are sure ?",nil,MB_YESNO)<>IDYES)) then
    id109:=GlobalLock(GlobalAlloc(GMEM_FIXED,GetWindowTextLength(id11)+1));
    GetWindowText(id11,id109,GetWindowTextLength(id11)+1);
    if id108
      then CharToOem(id109,id109);
      else OemToChar(id109,id109);
    end;
    SetWindowText(id11,id109);
    GlobalFree(GlobalHandle(id109));
  end
end id107;

//===============================================
//                  MENU COMMANDS
//===============================================

//-------------------- open file-------------------------

procedure id110(wnd:HWND);
var id111,id112:string[500]; ofn:OPENFILENAME;
begin
  with ofn do
    lstrcpy(id111,"*.rtf");
    id112[0]:=char(0);
    RtlZeroMemory(addr(ofn),sizeof(OPENFILENAME));
    lStructSize:=sizeof(OPENFILENAME);
    lpstrFilter:="RTF-files\0*.rtf\0Texts\0*.txt\0";
    nFilterIndex:=1;
    lpstrFile:=addr(id111);
    nMaxFile:=500;
    lpstrFileTitle:=addr(id112);
    nMaxFileTitle:=500;
    Flags:=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if GetOpenFileName(ofn) then
      id87(wnd,id111);
      lstrcpy(id15,id111);
    end;
  end
end id110;

//-------------------- save file-------------------------

procedure id113(wnd:HWND);
begin
  if id15[0]<>'\0' then
    id91(wnd,id15);
  end
end id113;

//-------------------- save as -------------------------

procedure id114(wnd:HWND);
var id111,id112:string[500]; ofn:OPENFILENAME;
begin
  with ofn do
    lstrcpy(id111,"*.rtf");
    id112[0]:=char(0);
    RtlZeroMemory(addr(ofn),sizeof(OPENFILENAME));
    lStructSize:=sizeof(OPENFILENAME);
    lpstrFilter:="RTF-files\0*.rtf\0Text files\0*.txt\0";
    nFilterIndex:=1;
    lpstrFile:=addr(id111);
    nMaxFile:=500;
    lpstrFileTitle:=addr(id112);
    nMaxFileTitle:=500;
    Flags:=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if GetSaveFileName(ofn) then
      id91(wnd,id111);
      lstrcpy(id15,id111);
    end
  end
end id114;

//-------------------- select all -------------------------

procedure id115(wnd:HWND);
var id72:CHARRANGE;
begin
  with id72 do
    cpMin:=0;
    cpMax:=-1;
    SendMessage(id11,EM_EXSETSEL,0,cardinal(addr(id72)));
  end
end id115;

//-------------------- find -------------------------

procedure id116(wnd:HWND; id117:boolean);
var id118:FINDTEXTEX; id119:integer;
begin
  if (id117 and
    boolean(DialogBoxParam(INSTANCE,"DLG_FIND",id11,addr(id93),0))) or
    not id117 then
    with id118 do
      if id117
        then chrg.cpMin:=0;
        else chrg.cpMin:=hiword(SendMessage(id11,EM_GETSEL,0,0));
      end;
      chrg.cpMax:=-1;
      lpstrText:=addr(id16);
      id119:=SendMessage(id11,EM_FINDTEXTEX,0,cardinal(addr(id118)));
      if id119=-1
        then MessageBox(id11,"Not find",nil,MB_ICONSTOP)
        else SendMessage(id11,EM_SETSEL,chrgText.cpMin,chrgText.cpMax)
      end;
    end
  end
end id116;

//-------------------- font select -------------------------

procedure id120(wnd:HWND);
var id78:CHARFORMAT; id121:CHOOSEFONT; id122:LOGFONT; dc:HDC;
begin
  with id78 do
  //get current format
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(id11,EM_GETCHARFORMAT,1,cardinal(addr(id78)));
    dc:=GetDC(wnd);
  //fill font
    with id122 do
      RtlZeroMemory(addr(id122),sizeof(LOGFONT));
      lfItalic:=byte((dwEffects and CFE_ITALIC)<>0);
      lfHeight:=-yHeight div 15;
      lfPitchAndFamily:=bPitchAndFamily;
      lstrcpy(lfFaceName,szFaceName);
      if (dwEffects and CFE_BOLD)=0
        then lfWidth:=FW_NORMAL
        else lfWidth:=FW_BOLD
      end;
    end;
  //fill font structure
    with id121 do
      RtlZeroMemory(addr(id121),sizeof(CHOOSEFONT));
      lStructSize:=sizeof(CHOOSEFONT);
      Flags:=CF_SCREENFONTS | CF_INITTOLOGFONTSTRUCT;
      hDC:=dc;
      hwndOwner:=wnd;
      lpLogFont:=addr(id122);
      rgbColors:=0;
      nFontType:=SCREEN_FONTTYPE;
    end;
  //select font
    if ChooseFont(id121) then
  //fill symbol format
      with id122 do
        dwMask:=CFM_BOLD | CFM_FACE | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE | CFM_OFFSET;
        yHeight:=-lfHeight*15;
        dwEffects:=0;
        if boolean(lfItalic) then dwEffects:=dwEffects or CFE_ITALIC end;
        if lfWeight=FW_BOLD then dwEffects:=dwEffects or CFE_BOLD end;
        bPitchAndFamily:=lfPitchAndFamily;
        lstrcpy(szFaceName,lfFaceName);
      end;
//change symbol format
      SendMessage(id11,EM_SETCHARFORMAT,SCF_SELECTION,cardinal(addr(id78)));
    end;
    ReleaseDC(wnd,dc);
  end
end id120;

//-------------------- print file -------------------------

procedure id123(wnd:HWND);
var
  id124:DOCINFO;
  id78:FORMATRANGE;
  id125:PRINTDLG;
  id126:integer;
  id127,id128:integer;
  dc:HDC;
begin
  //fill print structure
  with id125 do
    RtlZeroMemory(addr(id125),sizeof(PRINTDLG));
    lStructSize:=sizeof(PRINTDLG);
    hwndOwner:=id11;
    hInstance:=INSTANCE;
    Flags:=PD_RETURNDC | PD_NOPAGENUMS | PD_NOSELECTION | PD_PRINTSETUP | PD_ALLPAGES;
    nFromPage:=0xFFFF;
    nToPage:=0xFFFF;
    nMinPage:=0;
    nMaxPage:=0xFFFF;
    nCopies:=1;
  end;
  //print dialog
  if PrintDlg(id125) then
    dc:=id125.hDC;
  //fill format
    with id78 do
      RtlZeroMemory(addr(id78),sizeof(FORMATRANGE));
      hdc:=dc; //printer context
      hdcTarget:=dc;
      chrg.cpMin:=0; //full text
      chrg.cpMax:=-1;
      rcPage.top:=0; //page size TWIPS
      rcPage.left:=0;
      rcPage.right:=MulDiv(GetDeviceCaps(dc,PHYSICALWIDTH),1440,GetDeviceCaps(dc,LOGPIXELSX));
      rcPage.bottom:=MulDiv(GetDeviceCaps(dc,PHYSICALHEIGHT),1440,GetDeviceCaps(dc,LOGPIXELSY));
      rc:=rcPage;
    end;  
  //fill document
    with id124 do
      RtlZeroMemory(addr(id124),sizeof(DOCINFO));
      cbSize:=sizeof(DOCINFO);
      lpszOutput:=nil;
      lpszDocName:="Strannik";
    end;
  //print document
    id126:=StartDoc(dc,id124);
    if id126<=0 then MessageBox(id11,"Print error",nil,MB_ICONSTOP)
    else
      id127:=0;
      id128:=SendMessage(id11,WM_GETTEXTLENGTH,0,0);
      while id127<id128 do
      //format and print
        id127:=SendMessage(id11,EM_FORMATRANGE,1,cardinal(addr(id78)));
        if id127<id128 then
          EndPage(dc);
          StartPage(dc);
          id78.chrg.cpMin:=id127;
          id78.chrg.cpMax:=-1;
        end;
        SendMessage(id11,EM_FORMATRANGE,1,0);
        EndPage(dc);
        EndDoc(dc);
      end
    end;
    DeleteDC(dc);
  end;
end id123;

//-------------------- exit -------------------------

procedure id129(wnd:HWND):boolean;
var id130:cardinal;
begin
   if boolean(SendMessage(id11,EM_GETMODIFY,0,0)) then
     id130:=MessageBox(id11,"File was modified. Save ?",nil,MB_ICONSTOP | MB_YESNOCANCEL);
     case id130 of
       IDYES:id91(wnd,id15); return true;|
       IDNO:return true;|
       IDCANCEL:return false;|
     end;
   else return true
   end
end id129;

//===============================================
//            DIALOG FUNCTION
//===============================================

//------------------------ create menu----------------------------

procedure id131(wnd:HWND);
var
  id132,id133:HMENU;
  id98:id17;
  id97:id47;
begin
  id132:=CreateMenu();
  for id97:=id48 to id52 do
  with id60[id97] do 
    id133:=CreatePopupMenu();
    for id98:=id57 to id58 do
      if id59[id98][0]='\0'
        then AppendMenu(id133,MF_SEPARATOR,0,nil)
        else AppendMenu(id133,MF_STRING,id63+integer(id98),id59[id98])
      end
    end;
    AppendMenu(id132,MF_POPUP,id133,id56);
  end end;
  AppendMenu(id132,MF_STRING,id63+integer(id46),id59[id46]);
  SetMenu(wnd,id132);
end id131;

//------------ filter function for RichEdit ------------------

procedure id134(code,wparam,lparam:integer):cardinal;
var id135:pMSG;
begin
  id135:=pMSG(lparam);
  with id135^ do
  if  code=HC_ACTION then
    id76(hwnd);
    case message of
      WM_KEYDOWN:SendMessage(id10,message,wParam,lParam);|
    end;
  end end;
  return 0
end id134;

//------------------------ editor dialog ----------------------------

dialog DLG_EDI 6,5,291,179,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "Text editor 'Strannik'"
begin
  control "",id64,"RichEdit",WS_CHILD | WS_BORDER | ES_MULTILINE | ES_AUTOVSCROLL | WS_VSCROLL | ES_WANTRETURN | WS_VISIBLE | ES_SAVESEL,2,12,286,146
end;

//--------------- dialog function ------------------

procedure id136(wnd:HWND; msg,wparam,lparam:cardinal):cardinal;
begin
  case msg of
    WM_INITDIALOG:
      id131(wnd);
      id10:=wnd;
      id11:=GetDlgItem(wnd,id64);
      id15[0]:=char(0);
      id16[0]:=char(0);
      id14:=SetWindowsHookEx(WH_GETMESSAGE,addr(id134),0,GetWindowThreadProcessId(id11,nil));
      id94(wnd);
      id68(wnd,false);
      id102(wnd);|
    WM_SIZE:id102(wnd); id68(wnd,true);|
    WM_COMMAND:case loword(wparam) of
      id63+id18:if id129(wnd) then SetWindowText(id11,"") end;|
      id63+id19:if id129(wnd) then id110(wnd) end;|
      id63+id20:id113(wnd);|
      id63+id21:id114(wnd);|
      id63+id23:id123(wnd);|
      id63+id26:SendMessage(id11,EM_UNDO,0,0);|
      id63+id28:SendMessage(id11,WM_CUT,0,0);|
      id63+id29:SendMessage(id11,WM_COPY,0,0);|
      id63+id30:SendMessage(id11,WM_PASTE,0,0);|
      id63+id31:SendMessage(id11,WM_CLEAR,0,0);|
      id63+id33:id115(wnd);|
      id63+id34:id116(wnd,true);|
      id63+id35:id116(wnd,false);|
      id63+id36:id120(wnd);|
      id63+id38:id81(wnd,true);|
      id63+id39:id81(wnd,false);|
      id63+id41:id79(wnd,-1);|
      id63+id42:id79(wnd,1);|
      id63+id43:id79(wnd,0);|
      id63+id44:id107(wnd,false);|
      id63+id45:id107(wnd,true);|
      IDCANCEL,id63+id25,id63+id46:if id129(wnd) then
        UnhookWindowsHookEx(id14);
        EndDialog(wnd,1)
      end;|
    end;|
    WM_KEYDOWN:case loword(wparam) of
      VK_F3:SendMessage(wnd,WM_COMMAND,id63+ord(id35),0);|
    end;|
    WM_NOTIFY:id99(lparam);|
  else return(0);
  end;
  return(1);
end id136;

//--------------- call editor ------------------

procedure id137(id138:HWND);
var id139:HANDLE;
begin
  id139:=LoadLibrary("RICHED32.DLL");
  DialogBoxParam(INSTANCE,"DLG_EDI",id138,addr(id136),0);
  FreeLibrary(id139);
end id137;

begin
  id137(0);
  ExitProcess(0); //need for unload RTF
end Demo1_5.

