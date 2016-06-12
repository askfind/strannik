// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 5:Text editor RTF-files

include Win32

icon "icon_rtf.bmp";
define INSTANCE 0x400000

//===============================================
//                      VARIABLES
//===============================================

enum id1 {id2,id3,id4,id5,id6,id7};
typedef int[id1] id8;
define id9 id8{35,10,20,15,10,10}

HWND id10;
HWND id11;
HWND id12;
HWND id13;
HANDLE id14;
char id15[500];
char id16[500];

//------------------------ editor commands ----------------------------

enum id17 {
    id18,id19,id20,id21,id22,id23,id24,id25,
    id26,id27,id28,id29,id30,id31,id32,id33,
    id34,id35,
    id36,id37,id38,id39,id40,id41,id42,id43,
    id44,id45,
    id46};

enum id47 {
    id48,id49,id50,id51,id52,id53};

typedef pchar[id17] id54;
typedef struct {
    pchar id55;
    id17 id56;
    id17 id57;
  } [id47] id58;

define id59 id54{
    "New file","Open file...","Save file","Save As...","","Print...","","Exit",
    "Undo","","Cut\9Shift+Delete","Copy\9Ctrl+Insert","Paste\9Shift+Insert","Delete\9Delete","","Select All",
    "Find...","Next find\9F3",
    "Font","","Bold","Italic","","Align left","Align right","Align center",
    "Translate WINDOWS","Translate DOS",
    "Exit"}
define id60 id58{
    {"File",id18,id25},
    {"Edit",id26,id33},
    {"Find",id34,id35},
    {"Format",id36,id43},
    {"Tools",id44,id45},
    {"Exit",id46,id46}}

typedef int [id17] id61;
define id62 id61{
    1,2,3,4,0,5,0,0,
    6,0,7,8,9,10,0,0,
    11,12,
    13,0,14,15,0,16,17,18,
    19,20,
    0}

define id63 200
define id64 101

//===============================================
//              SYSTEM PROCEDURES
//===============================================

void mbI(int id65, char* id66) {
char id67[100];

  wvsprintf(id67,'%li',&id65);
  MessageBox(0,id67,id66,0);
}

//---------------- Create status ----------------

void id68(HWND id69, bool id70) {
 int id71[id1];
 RECT id72;
 id1 id73;
 int id74,id75;

  if(!id70) {
    id12=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      NULL,id69,0);
  }
  GetClientRect(id69,id72);
  if(id70) {
  with(id72) {
    SendMessage(id12,WM_SIZE,right-left+1,bottom-top+1);
  }}
  id74=0;
  for(id73=id2; id73<=id7; id73++) {
    id75=(id72.right-id72.left+1)*id9[id73] / 100;
    id71[id73]=id74+id75;
    id74++id75;
  }
  id71[id7]=-1;
  SendMessage(id12,SB_SETPARTS,ord(id7)+1,(uint)&id71);
}

//------------- Upgrade status --------------------

void id76(HWND wnd) {
char id77[500]; CHARFORMAT id78;

  SendMessage(id12,SB_SETTEXT,ord(id2),(uint)&id15);
  if((bool)SendMessage(id11,EM_GETMODIFY,0,0))
    SendMessage(id12,SB_SETTEXT,ord(id3),(uint)"Modified");
  else SendMessage(id12,SB_SETTEXT,ord(id3),(uint)"");
  with(id78) {
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(id11,EM_GETCHARFORMAT,1,(uint)&id78);
    SendMessage(id12,SB_SETTEXT,ord(id4),(uint)&szFaceName);
    yHeight=yHeight / 20;
    wvsprintf(id77,"Size:%li",&yHeight);
    SendMessage(id12,SB_SETTEXT,ord(id5),(uint)&id77);
    if(dwEffects & CFE_BOLD==0)
      SendMessage(id12,SB_SETTEXT,ord(id6),(uint)"");
    else SendMessage(id12,SB_SETTEXT,ord(id6),(uint)"Bold");
    if(dwEffects & CFE_ITALIC==0)
      SendMessage(id12,SB_SETTEXT,ord(id7),(uint)"");
    else SendMessage(id12,SB_SETTEXT,ord(id7),(uint)"Italic");
  }
}

//------------------------ Align ----------------------------

void id79(HWND wnd, int id80) {
PARAFORMAT id78;

  with(id78) {
    cbSize=sizeof(PARAFORMAT);
    dwMask=PFM_ALIGNMENT;
    switch(id80) {
      case -1:wAlignment=PFA_LEFT; break;
      case 0:wAlignment=PFA_CENTER; break;
      case 1:wAlignment=PFA_RIGHT; break;
    }
    SendMessage(id11,EM_SETPARAFORMAT,0,(uint)&id78);
  }
}

//-------------------- select font -------------------------

void id81(HWND wnd, bool id82) {
CHARFORMAT id78;

  with(id78) {
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(id11,EM_GETCHARFORMAT,1,(uint)&id78);
    switch(id82) {
      case true:dwMask=CFM_BOLD; dwEffects=(!dwEffects & CFE_BOLD) | (dwEffects & !CFE_BOLD); break;
      case false:dwMask=CFM_ITALIC; dwEffects=(!dwEffects & CFE_ITALIC) | (dwEffects & !CFE_ITALIC); break;
    }
    SendMessage(id11,EM_SETCHARFORMAT,SCF_SELECTION,(uint)&id78);
  }
}

//-------------------- test text -------------------------

bool id83(char *id84) {
int id85;

  id85=lstrlen(id84)-4;
  return (id85>=0)&((id84[id85+1]=='t') | (id84[id85+1]=='T'));
}

//------------ backcall function (load) ----------

uint id86(uint dwCookie, void *pbBuff, uint cb, pINT pcb)
{
  *pcb=_lread(dwCookie,pbBuff,cb);
  if(*pcb<0)
    *pcb=0;
  return 0;
}

//-------------------- load file -------------------------

void id87(HWND wnd, char *id84) {
int id88; EDITSTREAM id89;

  with(id89) {
    id88=_lopen(id84,0);
    if(id88>0) {
      dwCookie=id88;
      dwError=0;
      pfnCallback=&id86;
      if(id83(id84))
        SendMessage(id11,EM_STREAMIN,SF_TEXT,(uint)&id89);
      else SendMessage(id11,EM_STREAMIN,SF_RTF,(uint)&id89);
      _lclose(id88);
      SendMessage(id11,EM_SETMODIFY,0,0);
    }
  }
}

//------------ backcall function (save) ----------

uint id90(uint dwCookie, void *pbBuff, uint cb, pINT pcb)
{
  cb=_lwrite(dwCookie,pbBuff,cb);
  *pcb=cb;
  return 0;
}

//-------------------- save file-------------------------

void id91(HWND wnd, char *id84) {
int id88; EDITSTREAM id89;

  with(id89) {
    id88=_lcreat(id84,0);
    if(id88>0) {
      dwCookie=id88;
      dwError=0;
      pfnCallback=&id90;
      if(id83(id84))
        SendMessage(id11,EM_STREAMOUT,SF_TEXT,(uint)&id89);
      else SendMessage(id11,EM_STREAMOUT,SF_RTF,(uint)&id89);
      _lclose(id88);
       SendMessage(id11,EM_SETMODIFY,0,0);
    }
  }
}

//-------------------- find dialog -------------------------

define id92 101

dialog DLG_FIND 80,58,160,65,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Text find"
begin
  control "Text:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,5,3,149,11
  control "",id92,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,16,149,12
  control "Ok",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,31,48,45,12
  control "Cancel",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,82,48,45,12
end;

uint id93(HWND wnd,uint msg,uint wparam,uint lparam)
{
  switch(msg) {
    case WM_INITDIALOG:SetDlgItemText(wnd,id92,id16); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:
        GetDlgItemText(wnd,id92,id16,500);
        EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    default:return 0; break;
  }
  return 1;
}

//--------------------------- toolbar init------------------------------

bitmap bmpToolbar="tool_rtf.bmp";

void id94(HWND wnd) {
  TBBUTTON id95[50];
  int id96;
  HBITMAP bmp;
  id47 id97;
  id17 id98;
  RECT id72;

  InitCommonControls();
  bmp=LoadBitmap(INSTANCE,"bmpToolbar");
  //buttons array
  id96=-1;
  for(id97=id48; id97<=id52; id97++) {
  with(id60[id97]) { 
    //group
    for(id98=id56; id98<=id57; id98++) {
    if((id62[id98]>0)and(id96<50)) {
      id96++;
      RtlZeroMemory(&(id95[id96]),sizeof(TBBUTTON));
      with(id95[id96]) {
        iBitmap=id62[id98]-1;
        idCommand=id63+ord(id98);
        fsState=TBSTATE_ENABLED;
        fsStyle=TBSTYLE_BUTTON;
      }
    }}
    //Interval between buttons
    if(id96<50) {
      id96++;
      RtlZeroMemory(&(id95[id96]),sizeof(TBBUTTON));
      with(id95[id96]) {
        fsState=TBSTATE_ENABLED;
        fsStyle=TBSTYLE_SEP;
      }
    }
  }}
  //create toolbar
  id13=CreateToolbarEx(
    wnd,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,id96,0,bmp,&id95,id96,20,20,20,20,sizeof(TBBUTTON));
  //correct pos toolbar
  with(id72) {
    GetWindowRect(id13,id72);
    bottom++10;
    MoveWindow(id13,left,top,right-left+1,bottom-top+1,true);
  }
}

//--------------------------- toolbar texts------------------------------

void id99(uint lparam) {
  pNMHDR id100;
  pTOOLTIPTEXT id101;
  id17 id98;

  id100=(pvoid)lparam;
  id101=(pvoid)lparam;
  with(*id100,*id101) {
    id98=id17(idFrom-id63);
    switch(code) {
      case TTN_NEEDTEXT:{
        id98=id17(idFrom-id63);
        lpszText=id59[id98];}
    }
  }
}

//--------------------------- RTF window size------------------------------

void id102(HWND wnd) {
RECT id103,id104,id105,id106;

  with(id106) {
    GetClientRect(wnd,id103);
    GetWindowRect(id13,id104);
    GetWindowRect(id12,id105);
    left=5;
    right=id103.right-id103.left-10;
    top=id104.bottom-id104.top+5;
    bottom=
      (id103.bottom-id103.top)-
      (id105.bottom-id105.top)-
      (id104.bottom-id104.top)-10;
    MoveWindow(id11,left,top,right,bottom,true);
  }
}

//-------------------- change code -------------------------

void id107(HWND wnd, bool id108) {
char *id109;

  if(!(!id83(id15) &
    (MessageBox(id10,"You are sure ?",nil,MB_YESNO)!=IDYES))) {
    id109=GlobalLock(GlobalAlloc(GMEM_FIXED,GetWindowTextLength(id11)+1));
    GetWindowText(id11,id109,GetWindowTextLength(id11)+1);
    if(id108)
      CharToOem(id109,id109);
    else OemToChar(id109,id109);
    SetWindowText(id11,id109);
    GlobalFree(GlobalHandle(id109));
  }
}

//===============================================
//                  MENU COMMANDS
//===============================================

//-------------------- open file-------------------------

void id110(HWND wnd) {
char[500] id111,id112; OPENFILENAME ofn;

  with(ofn) {
    lstrcpy(id111,"*.rtf");
    id112[0]='\0';
    RtlZeroMemory(&ofn,sizeof(OPENFILENAME));
    lStructSize=sizeof(OPENFILENAME);
    lpstrFilter="RTF-files\0*.rtf\0Texts\0*.txt\0";
    nFilterIndex=1;
    lpstrFile=&id111;
    nMaxFile=500;
    lpstrFileTitle=&id112;
    nMaxFileTitle=500;
    Flags=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if(GetOpenFileName(ofn)) {
      id87(wnd,id111);
      lstrcpy(id15,id111);
    }
  }
}

//-------------------- save file-------------------------

void id113(HWND wnd)
{
  if(id15[0]!='\0') {
    id91(wnd,id15);
  }
}

//-------------------- save as -------------------------

void id114(HWND wnd) {
char[500] id111,id112; OPENFILENAME ofn;

  with(ofn) {
    lstrcpy(id111,"*.rtf");
    id112[0]='\0';
    RtlZeroMemory(&ofn,sizeof(OPENFILENAME));
    lStructSize=sizeof(OPENFILENAME);
    lpstrFilter="RTF-files\0*.rtf\0Text files\0*.txt\0";
    nFilterIndex=1;
    lpstrFile=&id111;
    nMaxFile=500;
    lpstrFileTitle=&id112;
    nMaxFileTitle=500;
    Flags=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if(GetSaveFileName(ofn)) {
      id91(wnd,id111);
      lstrcpy(id15,id111);
    }
  }
}

//-------------------- select all -------------------------

void id115(HWND wnd) {
CHARRANGE id72;

  with(id72) {
    cpMin=0;
    cpMax=-1;
    SendMessage(id11,EM_EXSETSEL,0,(uint)&id72);
  }
}

//-------------------- find -------------------------

void id116(HWND wnd, bool id117) {
FINDTEXTEX id118; int id119;

  if((id117 &
    (bool)DialogBoxParam(INSTANCE,"DLG_FIND",id11,&id93,0)) |
    !id117) {
    with(id118) {
      if(id117)
        chrg.cpMin=0;
      else chrg.cpMin=hiword(SendMessage(id11,EM_GETSEL,0,0));
      chrg.cpMax=-1;
      lpstrText=&id16;
      id119=SendMessage(id11,EM_FINDTEXTEX,0,(uint)&id118);
      if(id119==-1)
        MessageBox(id11,"Not find",nil,MB_ICONSTOP);
      else SendMessage(id11,EM_SETSEL,chrgText.cpMin,chrgText.cpMax);
    }
  }
}

//-------------------- font select -------------------------

void id120(HWND wnd) {
CHARFORMAT id78; CHOOSEFONT id121; LOGFONT id122; HDC dc;

  with(id78) {
  //get current format
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(id11,EM_GETCHARFORMAT,1,(uint)&id78);
    dc=GetDC(wnd);
  //fill font
    with(id122) {
      RtlZeroMemory(&id122,sizeof(LOGFONT));
      lfItalic=(byte)((dwEffects & CFE_ITALIC)!=0);
      lfHeight=-yHeight / 15;
      lfPitchAndFamily=bPitchAndFamily;
      lstrcpy(lfFaceName,szFaceName);
      if((dwEffects & CFE_BOLD)==0)
        lfWidth=FW_NORMAL;
      else lfWidth=FW_BOLD;
    }
  //fill font structure
    with(id121) {
      RtlZeroMemory(&id121,sizeof(CHOOSEFONT));
      lStructSize=sizeof(CHOOSEFONT);
      Flags=CF_SCREENFONTS | CF_INITTOLOGFONTSTRUCT;
      hDC=dc;
      hwndOwner=wnd;
      lpLogFont=&id122;
      rgbColors=0;
      nFontType=SCREEN_FONTTYPE;
    }
  //select font
    if(ChooseFont(id121)) {
  //fill symbol format
      with(id122) {
        dwMask=CFM_BOLD | CFM_FACE | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE | CFM_OFFSET;
        yHeight=-lfHeight*15;
        dwEffects=0;
        if((bool)lfItalic) dwEffects=dwEffects | CFE_ITALIC;
        if(lfWeight==FW_BOLD) dwEffects=dwEffects | CFE_BOLD;
        bPitchAndFamily=lfPitchAndFamily;
        lstrcpy(szFaceName,lfFaceName);
      }
//change symbol format
      SendMessage(id11,EM_SETCHARFORMAT,SCF_SELECTION,(uint)&id78);
    }
    ReleaseDC(wnd,dc);
  }
}

//-------------------- print file -------------------------

void id123(HWND wnd) {
  DOCINFO id124;
  FORMATRANGE id78;
  PRINTDLG id125;
  int id126;
  int id127,id128;
  HDC dc;

  //fill print structure
  with(id125) {
    RtlZeroMemory(&id125,sizeof(PRINTDLG));
    lStructSize=sizeof(PRINTDLG);
    hwndOwner=id11;
    hInstance=INSTANCE;
    Flags=PD_RETURNDC | PD_NOPAGENUMS | PD_NOSELECTION | PD_PRINTSETUP | PD_ALLPAGES;
    nFromPage=0xFFFF;
    nToPage=0xFFFF;
    nMinPage=0;
    nMaxPage=0xFFFF;
    nCopies=1;
  }
  //print dialog
  if(PrintDlg(id125)) {
    dc=id125.hDC;
  //fill format
    with(id78) {
      RtlZeroMemory(&id78,sizeof(FORMATRANGE));
      hdc=dc; //printer context
      hdcTarget=dc;
      chrg.cpMin=0; //full text
      chrg.cpMax=-1;
      rcPage.top=0; //page size TWIPS
      rcPage.left=0;
      rcPage.right=MulDiv(GetDeviceCaps(dc,PHYSICALWIDTH),1440,GetDeviceCaps(dc,LOGPIXELSX));
      rcPage.bottom=MulDiv(GetDeviceCaps(dc,PHYSICALHEIGHT),1440,GetDeviceCaps(dc,LOGPIXELSY));
      rc=rcPage;
    }
  //fill document
    with(id124) {
      RtlZeroMemory(&id124,sizeof(DOCINFO));
      cbSize=sizeof(DOCINFO);
      lpszOutput=NULL;
      lpszDocName="Strannik";
    }
  //print document
    id126=StartDoc(dc,id124);
    if(id126<0) MessageBox(id11,"Print error",nil,MB_ICONSTOP);
    else {
      id127=0;
      id128=SendMessage(id11,WM_GETTEXTLENGTH,0,0);
      while(id127<id128) {
      //format and print
        id127=SendMessage(id11,EM_FORMATRANGE,1,(uint)&id78);
        if(id127<id128) {
          EndPage(dc);
          StartPage(dc);
          id78.chrg.cpMin=id127;
          id78.chrg.cpMax=-1;
        }
        SendMessage(id11,EM_FORMATRANGE,1,0);
        EndPage(dc);
        EndDoc(dc);
      }
    }
    DeleteDC(dc);
  }
}

//-------------------- exit -------------------------

bool id129(HWND wnd) {
uint id130;

   if((bool)SendMessage(id11,EM_GETMODIFY,0,0)) {
     id130=MessageBox(id11,"File was modified. Save ?",nil,MB_ICONSTOP | MB_YESNOCANCEL);
     switch(id130) {
       case IDYES:{id91(wnd,id15); return true;}
       case IDNO:{return true;}
       case IDCANCEL:{return false;}
     }
   }
   else return true;
}

//===============================================
//            DIALOG FUNCTION
//===============================================

//------------------------ create menu----------------------------

void id131(HWND wnd) {
  HMENU id132,id133;
  id17 id98;
  id47 id97;

  id132=CreateMenu();
  for(id97=id48;  id97<=id52; id97++) {
  with(id60[id97]) { 
    id133=CreatePopupMenu();
    for(id98=id56; id98<=id57; id98++) {
      if(id59[id98][0]=='\0')
        AppendMenu(id133,MF_SEPARATOR,0,NULL);
      else AppendMenu(id133,MF_STRING,id63+(int)id98,id59[id98]);
    }
    AppendMenu(id132,MF_POPUP,id133,id55);
  }}
  AppendMenu(id132,MF_STRING,id63+(int)id46,id59[id46]);
  SetMenu(wnd,id132);
}

//------------ filter function for RichEdit ------------------

uint id134(int code,int wparam,int lparam) {
pMSG id135;

  id135=(pMSG)lparam;
  with(*id135) {
  if(code==HC_ACTION) {
    id76(hwnd);
    switch(message) {
      case WM_KEYDOWN:SendMessage(id10,message,wParam,lParam); break;
    }
  }}
  return 0;
}

//------------------------ editor dialog ----------------------------

dialog DLG_EDI 6,5,291,179,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "Text editor 'Strannik'"
begin
  control "",id64,"RichEdit",WS_CHILD | WS_BORDER | ES_MULTILINE | ES_AUTOVSCROLL | WS_VSCROLL | ES_WANTRETURN | WS_VISIBLE | ES_SAVESEL,2,12,286,146
end;

//--------------- dialog function ------------------

uint id136(HWND wnd,uint msg,uint wparam,uint lparam)
{
  switch(msg) {
    case WM_INITDIALOG:
      id131(wnd);
      id10=wnd;
      id11=GetDlgItem(wnd,id64);
      id15[0]='\0';
      id16[0]='\0';
      id14=SetWindowsHookEx(WH_GETMESSAGE,&id134,0,GetWindowThreadProcessId(id11,NULL));
      id94(wnd);
      id68(wnd,false);
      id102(wnd); break;
    case WM_SIZE:id102(wnd); id68(wnd,true); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case id63+id18:if(id129(wnd)) SetWindowText(id11,""); break;
      case id63+id19:if(id129(wnd)) id110(wnd); break;
      case id63+id20:id113(wnd); break;
      case id63+id21:id114(wnd); break;
      case id63+id23:id123(wnd); break;
      case id63+id26:SendMessage(id11,EM_UNDO,0,0); break;
      case id63+id28:SendMessage(id11,WM_CUT,0,0); break;
      case id63+id29:SendMessage(id11,WM_COPY,0,0); break;
      case id63+id30:SendMessage(id11,WM_PASTE,0,0); break;
      case id63+id31:SendMessage(id11,WM_CLEAR,0,0); break;
      case id63+id33:id115(wnd); break;
      case id63+id34:id116(wnd,true); break;
      case id63+id35:id116(wnd,false); break;
      case id63+id36:id120(wnd); break;
      case id63+id38:id81(wnd,true); break;
      case id63+id39:id81(wnd,false); break;
      case id63+id41:id79(wnd,-1); break;
      case id63+id42:id79(wnd,1); break;
      case id63+id43:id79(wnd,0); break;
      case id63+id44:id107(wnd,false); break;
      case id63+id45:id107(wnd,true); break;
      case IDCANCEL: case id63+id25: case id63+id46:if(id129(wnd)) {
        UnhookWindowsHookEx(id14);
        EndDialog(wnd,1);
      } break;
    } break;
    case WM_KEYDOWN:switch(loword(wparam)) {
      case VK_F3:SendMessage(wnd,WM_COMMAND,id63+ord(id35),0); break;
    } break;
    case WM_NOTIFY:id99(lparam); break;
    default:return 0; break;
  }
  return 1;
}

//--------------- call editor ------------------

void id137(HWND id138) {
HANDLE id139;

  id139=LoadLibrary("RICHED32.DLL");
  DialogBoxParam(INSTANCE,"DLG_EDI",id138,&id136,0);
  FreeLibrary(id139);
}

void main()
{
  id137(0);
  ExitProcess(0); //need for unload RTF
}

