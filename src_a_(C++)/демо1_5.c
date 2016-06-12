// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 5:��������� �������� RTF

include Win32

icon "icon_rtf.bmp";
define INSTANCE 0x400000

//===============================================
//                      ����������
//===============================================

enum ������������ {��������������,�������������,�����������,������������,������������,������������};
typedef int[������������] ���������;
define ���������� ���������{35,10,20,15,10,10}

HWND �������������;
HWND ����RTF;
HWND ����������;
HWND ����������;
HANDLE ������RTF;
char �����������������[500];
char ����������������[500];

//------------------------ ������� ��������� ----------------------------

enum ��������������������� {
    ������������,��������������,����������������,�������������������,��������1,�������������,��������11,������������,
    �����������������,��������2,�����������������,�������������������,�����������������,����������������,��������3,��������������������,
    ��������,�����������������,
    ��������������,��������31,��������������������,��������������������,��������4,�������������������,��������������������,����������������������,
    �������������WINDOWS,�������������DOS,
    ��������};

enum �������������������������� {
    �������������,���������������,��������������,���������������,�������������������,��������������};

typedef pchar[���������������������] �������������������������;
typedef struct {
    pchar ���������;
    ��������������������� �������������������;
    ��������������������� ����������������������;
  } [��������������������������] ������������������������������;

define ����������������������� �������������������������{
    "����� ����","������� ����...","��������� ����","������������...","","������...","","Exit",
    "��������","","��������\9Shift+Delete","����������\9Ctrl+Insert","��������\9Shift+Insert","�������\9Delete","","�������� ���",
    "�����...","��������� �����\9F3",
    "�����","","����������/������ ������","����������/������ ������","","��������� ����� �����","��������� ����� ������","��������� ����� �� ������",
    "��������� � ��������� WINDOWS","��������� � ��������� DOS",
    "Exit"}
define ���������������������������� ������������������������������{
    {"File",������������,������������},
    {"������",�����������������,��������������������},
    {"�����",��������,�����������������},
    {"������",��������������,����������������������},
    {"�����������",�������������WINDOWS,�������������DOS},
    {"Exit",��������,��������}}

//������ ������ � toolbar (�� 1)
typedef int [���������������������] ���������;
define ����������� ���������{
    1,2,3,4,0,5,0,0,
    6,0,7,8,9,10,0,0,
    11,12,
    13,0,14,15,0,16,17,18,
    19,20,
    0}

define ���������� 200
define ����������RTF 101

//===============================================
//              ��������������� ���������
//===============================================

void mbI(int ���, char* ����) {
char ���[100];

  wvsprintf(���,'%li',&���);
  MessageBox(0,���,����,0);
}

//---------------- �������� ������-������ ��������� ----------------

void �������������(HWND ����, bool ����������������) {
 int ������[������������];
 RECT ������;
 ������������ ������;
 int ���,������;

  if(!����������������) {
    ����������=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      NULL,����,0);
  }
  GetClientRect(����,������);
  if(����������������) {
  with(������) {
    SendMessage(����������,WM_SIZE,right-left+1,bottom-top+1);
  }}
  ���=0;
  for(������=��������������; ������<=������������; ������++) {
    ������=(������.right-������.left+1)*����������[������] / 100;
    ������[������]=���+������;
    ���++������;
  }
  ������[������������]=-1;
  SendMessage(����������,SB_SETPARTS,ord(������������)+1,(uint)&������);
}

//------------- ���������� ������-������ --------------------

void ��������������(HWND wnd) {
char ������[500]; CHARFORMAT ������;

  SendMessage(����������,SB_SETTEXT,ord(��������������),(uint)&�����������������);
  if((bool)SendMessage(����RTF,EM_GETMODIFY,0,0))
    SendMessage(����������,SB_SETTEXT,ord(�������������),(uint)"�������");
  else SendMessage(����������,SB_SETTEXT,ord(�������������),(uint)"");
  with(������) {
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(����RTF,EM_GETCHARFORMAT,1,(uint)&������);
    SendMessage(����������,SB_SETTEXT,ord(�����������),(uint)&szFaceName);
    yHeight=yHeight / 20;
    wvsprintf(������,"������:%li",&yHeight);
    SendMessage(����������,SB_SETTEXT,ord(������������),(uint)&������);
    if(dwEffects & CFE_BOLD==0)
      SendMessage(����������,SB_SETTEXT,ord(������������),(uint)"");
    else SendMessage(����������,SB_SETTEXT,ord(������������),(uint)"����������");
    if(dwEffects & CFE_ITALIC==0)
      SendMessage(����������,SB_SETTEXT,ord(������������),(uint)"");
    else SendMessage(����������,SB_SETTEXT,ord(������������),(uint)"������");
  }
}

//------------------------ ������������ ������ ----------------------------

void ����������������������������(HWND wnd, int ������������) {
PARAFORMAT ������;

  with(������) {
    cbSize=sizeof(PARAFORMAT);
    dwMask=PFM_ALIGNMENT;
    switch(������������) {
      case -1:wAlignment=PFA_LEFT; break;
      case 0:wAlignment=PFA_CENTER; break;
      case 1:wAlignment=PFA_RIGHT; break;
    }
    SendMessage(����RTF,EM_SETPARAFORMAT,0,(uint)&������);
  }
}

//-------------------- ������� ���������� ������ -------------------------

void ��������������������������(HWND wnd, bool �������������) {
CHARFORMAT ������;

  with(������) {
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(����RTF,EM_GETCHARFORMAT,1,(uint)&������);
    switch(�������������) {
      case true:dwMask=CFM_BOLD; dwEffects=(!dwEffects & CFE_BOLD) | (dwEffects & !CFE_BOLD); break;
      case false:dwMask=CFM_ITALIC; dwEffects=(!dwEffects & CFE_ITALIC) | (dwEffects & !CFE_ITALIC); break;
    }
    SendMessage(����RTF,EM_SETCHARFORMAT,SCF_SELECTION,(uint)&������);
  }
}

//-------------------- �������� �� ��������� ���� -------------------------

bool �������������(char *��������) {
int �����;

  �����=lstrlen(��������)-4;
  return (�����>=0)&((��������[�����+1]=='t') | (��������[�����+1]=='T'));
}

//------------ ������� ��������� ������ �������� ----------

uint �������������(uint dwCookie, void *pbBuff, uint cb, pINT pcb)
{
  *pcb=_lread(dwCookie,pbBuff,cb);
  if(*pcb<0)
    *pcb=0;
  return 0;
}

//-------------------- ��������� ����(load file)-------------------------

void ����������������������(HWND wnd, char *��������) {
int ����; EDITSTREAM �����;

  with(�����) {
    ����=_lopen(��������,0);
    if(����>0) {
      dwCookie=����;
      dwError=0;
      pfnCallback=&�������������;
      if(�������������(��������))
        SendMessage(����RTF,EM_STREAMIN,SF_TEXT,(uint)&�����);
      else SendMessage(����RTF,EM_STREAMIN,SF_RTF,(uint)&�����);
      _lclose(����);
      SendMessage(����RTF,EM_SETMODIFY,0,0);
    }
  }
}

//------------ ������� ��������� ������ ���������� ----------

uint �������������(uint dwCookie, void *pbBuff, uint cb, pINT pcb)
{
  cb=_lwrite(dwCookie,pbBuff,cb);
  *pcb=cb;
  return 0;
}

//-------------------- ��������� ����(save file)-------------------------

void ����������������������(HWND wnd, char *��������) {
int ����; EDITSTREAM �����;

  with(�����) {
    ����=_lcreat(��������,0);
    if(����>0) {
      dwCookie=����;
      dwError=0;
      pfnCallback=&�������������;
      if(�������������(��������))
        SendMessage(����RTF,EM_STREAMOUT,SF_TEXT,(uint)&�����);
      else SendMessage(����RTF,EM_STREAMOUT,SF_RTF,(uint)&�����);
      _lclose(����);
       SendMessage(����RTF,EM_SETMODIFY,0,0);
    }
  }
}

//-------------------- ������ ������ -------------------------

define ������������������ 101

dialog DLG_FIND 80,58,160,65,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "����� ������"
begin
  control "������� ��� ������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,5,3,149,11
  control "",������������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,16,149,12
  control "��",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,31,48,45,12
  control "������",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,82,48,45,12
end;

uint �����������������������(HWND wnd,uint msg,uint wparam,uint lparam)
{
  switch(msg) {
    case WM_INITDIALOG:SetDlgItemText(wnd,������������������,����������������); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:
        GetDlgItemText(wnd,������������������,����������������,500);
        EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    default:return 0; break;
  }
  return 1;
}

//---------------------------������������� toolbar------------------------------

bitmap bmpToolbar="tool_rtf.bmp";

void �������������(HWND wnd) {
  TBBUTTON ������[50];
  int ����������;
  HBITMAP bmp;
  �������������������������� ������;
  ��������������������� �������;
  RECT ������;

  InitCommonControls();
  bmp=LoadBitmap(INSTANCE,"bmpToolbar");
  //���������� ������� ������
  ����������=-1;
  for(������=�������������; ������<=�������������������; ������++) {
  with(����������������������������[������]) { 
    //������ ������ ������
    for(�������=�������������������; �������<=����������������������; �������++) {
    if((�����������[�������]>0)and(����������<50)) {
      ����������++;
      RtlZeroMemory(&(������[����������]),sizeof(TBBUTTON));
      with(������[����������]) {
        iBitmap=�����������[�������]-1;
        idCommand=����������+ord(�������);
        fsState=TBSTATE_ENABLED;
        fsStyle=TBSTYLE_BUTTON;
      }
    }}
    //���������� ����� ��������
    if(����������<50) {
      ����������++;
      RtlZeroMemory(&(������[����������]),sizeof(TBBUTTON));
      with(������[����������]) {
        fsState=TBSTATE_ENABLED;
        fsStyle=TBSTYLE_SEP;
      }
    }
  }}
  //�������� toolbar
  ����������=CreateToolbarEx(
    wnd,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,����������,0,bmp,&������,����������,20,20,20,20,sizeof(TBBUTTON));
  //��������� ��������� toolbar
  with(������) {
    GetWindowRect(����������,������);
    bottom++10;
    MoveWindow(����������,left,top,right-left+1,bottom-top+1,true);
  }
}

//---------------------------������ ������ toolbar------------------------------

void ������������������(uint lparam) {
  pNMHDR ������;
  pTOOLTIPTEXT �����������;
  ��������������������� �������;

  ������=(pvoid)lparam;
  �����������=(pvoid)lparam;
  with(*������,*�����������) {
    �������=���������������������(idFrom-����������);
    switch(code) {
      case TTN_NEEDTEXT:{
        �������=���������������������(idFrom-����������);
        lpszText=�����������������������[�������];}
    }
  }
}

//---------------------------������� ���� RTF------------------------------

void ��������������RTF(HWND wnd) {
RECT ���������������,������������,������������,������RTF;

  with(������RTF) {
    GetClientRect(wnd,���������������);
    GetWindowRect(����������,������������);
    GetWindowRect(����������,������������);
    left=5;
    right=���������������.right-���������������.left-10;
    top=������������.bottom-������������.top+5;
    bottom=
      (���������������.bottom-���������������.top)-
      (������������.bottom-������������.top)-
      (������������.bottom-������������.top)-10;
    MoveWindow(����RTF,left,top,right,bottom,true);
  }
}

//-------------------- ������� ��������� -------------------------

void ����������������(HWND wnd, bool ���DOS) {
char *�����;

  if(!(!�������������(�����������������) &
    (MessageBox(�������������,"�� ������� � ������������� ����� ��������� ?","��������:",MB_YESNO)!=IDYES))) {
    �����=GlobalLock(GlobalAlloc(GMEM_FIXED,GetWindowTextLength(����RTF)+1));
    GetWindowText(����RTF,�����,GetWindowTextLength(����RTF)+1);
    if(���DOS)
      CharToOem(�����,�����);
    else OemToChar(�����,�����);
    SetWindowText(����RTF,�����);
    GlobalFree(GlobalHandle(�����));
  }
}

//===============================================
//                  ����������� ������ ����
//===============================================

//-------------------- ������� ����(open file)-------------------------

void ������������������(HWND wnd) {
char[500] ����,���; OPENFILENAME ofn;

  with(ofn) {
    lstrcpy(����,"*.rtf");
    ���[0]='\0';
    RtlZeroMemory(&ofn,sizeof(OPENFILENAME));
    lStructSize=sizeof(OPENFILENAME);
    lpstrFilter="RTF-�����\0*.rtf\0��������� �����\0*.txt\0";
    nFilterIndex=1;
    lpstrFile=&����;
    nMaxFile=500;
    lpstrFileTitle=&���;
    nMaxFileTitle=500;
    Flags=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if(GetOpenFileName(ofn)) {
      ����������������������(wnd,����);
      lstrcpy(�����������������,����);
    }
  }
}

//-------------------- ��������� ����(save file)-------------------------

void ��������������������(HWND wnd)
{
  if(�����������������[0]!='\0') {
    ����������������������(wnd,�����������������);
  }
}

//-------------------- ��������� ��� -------------------------

void �����������������������(HWND wnd) {
char[500] ����,���; OPENFILENAME ofn;

  with(ofn) {
    lstrcpy(����,"*.rtf");
    ���[0]='\0';
    RtlZeroMemory(&ofn,sizeof(OPENFILENAME));
    lStructSize=sizeof(OPENFILENAME);
    lpstrFilter="RTF-�����\0*.rtf\0��������� �����\0*.txt\0";
    nFilterIndex=1;
    lpstrFile=&����;
    nMaxFile=500;
    lpstrFileTitle=&���;
    nMaxFileTitle=500;
    Flags=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if(GetSaveFileName(ofn)) {
      ����������������������(wnd,����);
      lstrcpy(�����������������,����);
    }
  }
}

//-------------------- �������� ��� -------------------------

void ������������������(HWND wnd) {
CHARRANGE ������;

  with(������) {
    cpMin=0;
    cpMax=-1;
    SendMessage(����RTF,EM_EXSETSEL,0,(uint)&������);
  }
}

//-------------------- ����� -------------------------

void ������������(HWND wnd, bool ����������������) {
FINDTEXTEX �������; int �������;

  if((���������������� &
    (bool)DialogBoxParam(INSTANCE,"DLG_FIND",����RTF,&�����������������������,0)) |
    !����������������) {
    with(�������) {
      if(����������������)
        chrg.cpMin=0;
      else chrg.cpMin=hiword(SendMessage(����RTF,EM_GETSEL,0,0));
      chrg.cpMax=-1;
      lpstrText=&����������������;
      �������=SendMessage(����RTF,EM_FINDTEXTEX,0,(uint)&�������);
      if(�������==-1)
        MessageBox(����RTF,"�������� �� ������","��������:",MB_ICONSTOP);
      else SendMessage(����RTF,EM_SETSEL,chrgText.cpMin,chrgText.cpMax);
    }
  }
}

//-------------------- ����� ������ -------------------------

void ������������(HWND wnd) {
CHARFORMAT ������; CHOOSEFONT �����; LOGFONT ��������; HDC dc;

  with(������) {
  //�������� ������� ������
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(����RTF,EM_GETCHARFORMAT,1,(uint)&������);
    dc=GetDC(wnd);
  //��������� ����� �������� ����������������
    with(��������) {
      RtlZeroMemory(&��������,sizeof(LOGFONT));
      lfItalic=(byte)((dwEffects & CFE_ITALIC)!=0);
      lfHeight=-yHeight / 15;
      lfPitchAndFamily=bPitchAndFamily;
      lstrcpy(lfFaceName,szFaceName);
      if((dwEffects & CFE_BOLD)==0)
        lfWidth=FW_NORMAL;
      else lfWidth=FW_BOLD;
    }
  //��������� ��������� ������ ������
    with(�����) {
      RtlZeroMemory(&�����,sizeof(CHOOSEFONT));
      lStructSize=sizeof(CHOOSEFONT);
      Flags=CF_SCREENFONTS | CF_INITTOLOGFONTSTRUCT;
      hDC=dc;
      hwndOwner=wnd;
      lpLogFont=&��������;
      rgbColors=0;
      nFontType=SCREEN_FONTTYPE;
    }
  //����� ������
    if(ChooseFont(�����)) {
  //��������� ������ �������
      with(��������) {
        dwMask=CFM_BOLD | CFM_FACE | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE | CFM_OFFSET;
        yHeight=-lfHeight*15;
        dwEffects=0;
        if((bool)lfItalic) dwEffects=dwEffects | CFE_ITALIC;
        if(lfWeight==FW_BOLD) dwEffects=dwEffects | CFE_BOLD;
        bPitchAndFamily=lfPitchAndFamily;
        lstrcpy(szFaceName,lfFaceName);
      }
//�������� ������ ��������
      SendMessage(����RTF,EM_SETCHARFORMAT,SCF_SELECTION,(uint)&������);
    }
    ReleaseDC(wnd,dc);
  }
}

//-------------------- ������ ����� -------------------------

void �����������������(HWND wnd) {
  DOCINFO ��������;
  FORMATRANGE ������;
  PRINTDLG ������;
  int ���������;
  int �������������,���������������;
  HDC dc;

  //��������� ��������� ��� ������� ������
  with(������) {
    RtlZeroMemory(&������,sizeof(PRINTDLG));
    lStructSize=sizeof(PRINTDLG);
    hwndOwner=����RTF;
    hInstance=INSTANCE;
    Flags=PD_RETURNDC | PD_NOPAGENUMS | PD_NOSELECTION | PD_PRINTSETUP | PD_ALLPAGES;
    nFromPage=0xFFFF;
    nToPage=0xFFFF;
    nMinPage=0;
    nMaxPage=0xFFFF;
    nCopies=1;
  }
  //����� ������� ������
  if(PrintDlg(������)) {
    dc=������.hDC;
  //���������� ����� ��������� ��������������
    with(������) {
      RtlZeroMemory(&������,sizeof(FORMATRANGE));
      hdc=dc; //�������� ������ ��������
      hdcTarget=dc;
      chrg.cpMin=0; //���� ��������
      chrg.cpMax=-1;
      rcPage.top=0; //������� �������� � TWIPS
      rcPage.left=0;
      rcPage.right=MulDiv(GetDeviceCaps(dc,PHYSICALWIDTH),1440,GetDeviceCaps(dc,LOGPIXELSX));
      rcPage.bottom=MulDiv(GetDeviceCaps(dc,PHYSICALHEIGHT),1440,GetDeviceCaps(dc,LOGPIXELSY));
      rc=rcPage;
    }
  //���������� ����� ���������
    with(��������) {
      RtlZeroMemory(&��������,sizeof(DOCINFO));
      cbSize=sizeof(DOCINFO);
      lpszOutput=NULL;
      lpszDocName="Strannik";
    }
  //������ ���������
    ���������=StartDoc(dc,��������);
    if(���������<0) MessageBox(����RTF,"������ ������","��������:",MB_ICONSTOP);
    else {
      �������������=0;
      ���������������=SendMessage(����RTF,WM_GETTEXTLENGTH,0,0);
      while(�������������<���������������) {
      //�������������� � ������
        �������������=SendMessage(����RTF,EM_FORMATRANGE,1,(uint)&������);
        if(�������������<���������������) {
          EndPage(dc);
          StartPage(dc);
          ������.chrg.cpMin=�������������;
          ������.chrg.cpMax=-1;
        }
        SendMessage(����RTF,EM_FORMATRANGE,1,0);
        EndPage(dc);
        EndDoc(dc);
      }
    }
    DeleteDC(dc);
  }
}

//-------------------- ����� �� ��������� -------------------------

bool ������������(HWND wnd) {
uint �����;

   if((bool)SendMessage(����RTF,EM_GETMODIFY,0,0)) {
     �����=MessageBox(����RTF,"���� ��� �������. ��������� ?","��������",MB_ICONSTOP | MB_YESNOCANCEL);
     switch(�����) {
       case IDYES:{����������������������(wnd,�����������������); return true;}
       case IDNO:{return true;}
       case IDCANCEL:{return false;}
     }
   }
   else return true;
}

//===============================================
//            ���������� ������� ���������
//===============================================

//------------------------ �������� ����(create menu)----------------------------

void ��������������������(HWND wnd) {
  HMENU ����������,����������;
  ��������������������� �������;
  �������������������������� ������;

  ����������=CreateMenu();
  for(������=�������������;  ������<=�������������������; ������++) {
  with(����������������������������[������]) { 
    ����������=CreatePopupMenu();
    for(�������=�������������������; �������<=����������������������; �������++) {
      if(�����������������������[�������][0]=='\0')
        AppendMenu(����������,MF_SEPARATOR,0,NULL);
      else AppendMenu(����������,MF_STRING,����������+(int)�������,�����������������������[�������]);
    }
    AppendMenu(����������,MF_POPUP,����������,���������);
  }}
  AppendMenu(����������,MF_STRING,����������+(int)��������,�����������������������[��������]);
  SetMenu(wnd,����������);
}

//------------ ������� ������� ��� RichEdit ------------------

uint ��������������(int code,int wparam,int lparam) {
pMSG message����;

  message����=(pMSG)lparam;
  with(*message����) {
  if(code==HC_ACTION) {
    ��������������(hwnd);
    switch(message) {
      case WM_KEYDOWN:SendMessage(�������������,message,wParam,lParam); break;
    }
  }}
  return 0;
}

//------------------------ ������ ��������� ----------------------------

dialog DLG_EDI 6,5,291,179,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "��������� �������� '��������'"
begin
  control "",����������RTF,"RichEdit",WS_CHILD | WS_BORDER | ES_MULTILINE | ES_AUTOVSCROLL | WS_VSCROLL | ES_WANTRETURN | WS_VISIBLE | ES_SAVESEL,2,12,286,146
end;

//--------------- ���������� ������� ��������� ------------------

uint ��������������������������(HWND wnd,uint msg,uint wparam,uint lparam)
{
  switch(msg) {
    case WM_INITDIALOG:
      ��������������������(wnd);
      �������������=wnd;
      ����RTF=GetDlgItem(wnd,����������RTF);
      �����������������[0]='\0';
      ����������������[0]='\0';
      ������RTF=SetWindowsHookEx(WH_GETMESSAGE,&��������������,0,GetWindowThreadProcessId(����RTF,NULL));
      �������������(wnd);
      �������������(wnd,false);
      ��������������RTF(wnd); break;
    case WM_SIZE:��������������RTF(wnd); �������������(wnd,true); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case ����������+������������:if(������������(wnd)) SetWindowText(����RTF,""); break;
      case ����������+��������������:if(������������(wnd)) ������������������(wnd); break;
      case ����������+����������������:��������������������(wnd); break;
      case ����������+�������������������:�����������������������(wnd); break;
      case ����������+�������������:�����������������(wnd); break;
      case ����������+�����������������:SendMessage(����RTF,EM_UNDO,0,0); break;
      case ����������+�����������������:SendMessage(����RTF,WM_CUT,0,0); break;
      case ����������+�������������������:SendMessage(����RTF,WM_COPY,0,0); break;
      case ����������+�����������������:SendMessage(����RTF,WM_PASTE,0,0); break;
      case ����������+����������������:SendMessage(����RTF,WM_CLEAR,0,0); break;
      case ����������+��������������������:������������������(wnd); break;
      case ����������+��������:������������(wnd,true); break;
      case ����������+�����������������:������������(wnd,false); break;
      case ����������+��������������:������������(wnd); break;
      case ����������+��������������������:��������������������������(wnd,true); break;
      case ����������+��������������������:��������������������������(wnd,false); break;
      case ����������+�������������������:����������������������������(wnd,-1); break;
      case ����������+��������������������:����������������������������(wnd,1); break;
      case ����������+����������������������:����������������������������(wnd,0); break;
      case ����������+�������������WINDOWS:����������������(wnd,false); break;
      case ����������+�������������DOS:����������������(wnd,true); break;
      case IDCANCEL: case ����������+������������: case ����������+��������:if(������������(wnd)) {
        UnhookWindowsHookEx(������RTF);
        EndDialog(wnd,1);
      } break;
    } break;
    case WM_KEYDOWN:switch(loword(wparam)) {
      case VK_F3:SendMessage(wnd,WM_COMMAND,����������+ord(�����������������),0); break;
    } break;
    case WM_NOTIFY:������������������(lparam); break;
    default:return 0; break;
  }
  return 1;
}

//--------------- ����� ��������� ------------------

void ��������RTF(HWND ����������������) {
HANDLE ������;

  ������=LoadLibrary("RICHED32.DLL");
  DialogBoxParam(INSTANCE,"DLG_EDI",����������������,&��������������������������,0);
  FreeLibrary(������);
}

void main()
{
  ��������RTF(0);
  ExitProcess(0); //���������� ��� �������� �� ������ RTF
}

