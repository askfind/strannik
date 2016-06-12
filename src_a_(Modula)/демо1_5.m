// ��������  ������-��-������� ��� Win32
// ���������������� ���������
// ���� 5:��������� �������� RTF-������

module Demo1_5;
import Win32;

icon "icon_rtf.bmp";
const INSTANCE=0x400000;

//===============================================
//                      ����������
//===============================================

type
  ������������=(��������������,�������������,�����������,������������,������������,������������);
  ���������=array[������������]of integer;
const
  ����������=���������{35,10,20,15,10,10};

var
  �������������:HWND;
  ����RTF:HWND;
  ����������:HWND;
  ����������:HWND;
  ������RTF:HANDLE;
  �����������������:string[500];
  ����������������:string[500];

//------------------------ ������� ��������� ----------------------------

type
  ���������������������=(
    ������������,��������������,����������������,�������������������,��������1,�������������,��������11,������������,
    �����������������,��������2,�����������������,�������������������,�����������������,����������������,��������3,��������������������,
    ��������,�����������������,
    ��������������,��������31,��������������������,��������������������,��������4,�������������������,��������������������,����������������������,
    �������������WINDOWS,�������������DOS,
    ��������);

  ��������������������������=(
    �������������,���������������,��������������,���������������,�������������������,��������������);

type
  �������������������������=array[���������������������]of pstr;
  ������������������������������=array[��������������������������]of record
    ���������:pstr;
    �������������������:���������������������;
    ����������������������:���������������������;
  end;

const
  �����������������������=�������������������������{
    "����� ����","������� ����...","��������� ����","������������...","","������...","","Exit",
    "��������","","��������\9Shift+Delete","����������\9Ctrl+Insert","��������\9Shift+Insert","�������\9Delete","","�������� ���",
    "�����...","��������� �����\9F3",
    "�����","","����������/������ ������","����������/������ ������","","��������� ����� �����","��������� ����� ������","��������� ����� �� ������",
    "��������� � ��������� WINDOWS","��������� � ��������� DOS",
    "Exit"};
  ����������������������������=������������������������������{
    {"File",������������,������������},
    {"������",�����������������,��������������������},
    {"�����",��������,�����������������},
    {"������",��������������,����������������������},
    {"�����������",�������������WINDOWS,�������������DOS},
    {"Exit",��������,��������}};

//������ ������ � toolbar (�� 1)
type ���������=array[���������������������]of integer;
const �����������=���������{
    1,2,3,4,0,5,0,0,
    6,0,7,8,9,10,0,0,
    11,12,
    13,0,14,15,0,16,17,18,
    19,20,
    0};

const
  ����������=200;
  ����������RTF=101;

//===============================================
//              ��������������� ���������
//===============================================

procedure mbI(���:integer; ����:pstr);
var ���:string[100];
begin
  wvsprintf(���,'%li',addr(���));
  MessageBox(0,���,����,0);
end mbI;

//---------------- �������� ������-������ ��������� ----------------

procedure �������������(����:HWND; ����������������:boolean);
var
  ������:array[������������]of integer;
  ������:RECT;
  ������:������������;
  ���,������:integer;
begin
  if not ���������������� then
    ����������:=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      nil,����,0);
  end;
  GetClientRect(����,������);
  if ���������������� then
  with ������ do
    SendMessage(����������,WM_SIZE,right-left+1,bottom-top+1);
  end end;
  ���:=0;
  for ������:=�������������� to ������������ do
    ������:=(������.right-������.left+1)*����������[������] div 100;
    ������[������]:=���+������;
    inc(���,������)
  end;
  ������[������������]:=-1;
  SendMessage(����������,SB_SETPARTS,ord(������������)+1,cardinal(addr(������)));
end �������������;

//------------- ���������� ������-������ --------------------

procedure ��������������(wnd:HWND);
var ������:string[500]; ������:CHARFORMAT;
begin
  SendMessage(����������,SB_SETTEXT,ord(��������������),cardinal(addr(�����������������)));
  if boolean(SendMessage(����RTF,EM_GETMODIFY,0,0))
    then SendMessage(����������,SB_SETTEXT,ord(�������������),cardinal("�������"));
    else SendMessage(����������,SB_SETTEXT,ord(�������������),cardinal(""));
  end;
  with ������ do
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(����RTF,EM_GETCHARFORMAT,1,cardinal(addr(������)));
    SendMessage(����������,SB_SETTEXT,ord(�����������),cardinal(addr(szFaceName)));
    yHeight:=yHeight div 20;
    wvsprintf(������,"������:%li",addr(yHeight));
    SendMessage(����������,SB_SETTEXT,ord(������������),cardinal(addr(������)));
    if dwEffects and CFE_BOLD=0
      then SendMessage(����������,SB_SETTEXT,ord(������������),cardinal(""));
      else SendMessage(����������,SB_SETTEXT,ord(������������),cardinal("����������"));
    end;
    if dwEffects and CFE_ITALIC=0
      then SendMessage(����������,SB_SETTEXT,ord(������������),cardinal(""));
      else SendMessage(����������,SB_SETTEXT,ord(������������),cardinal("������"));
    end;
  end
end ��������������;

//------------------------ ������������ ������ ----------------------------

procedure ����������������������������(wnd:HWND; ������������:integer);
var ������:PARAFORMAT;
begin
  with ������ do
    cbSize:=sizeof(PARAFORMAT);
    dwMask:=PFM_ALIGNMENT;
    case ������������ of
      -1:wAlignment:=PFA_LEFT;|
      0:wAlignment:=PFA_CENTER;|
      1:wAlignment:=PFA_RIGHT;|
    end;
    SendMessage(����RTF,EM_SETPARAFORMAT,0,cardinal(addr(������)));
  end
end ����������������������������;

//-------------------- ������� ���������� ������ -------------------------

procedure ��������������������������(wnd:HWND; �������������:boolean);
var ������:CHARFORMAT;
begin
  with ������ do
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(����RTF,EM_GETCHARFORMAT,1,cardinal(addr(������)));
    case ������������� of
      true:dwMask:=CFM_BOLD; dwEffects:=(not dwEffects and CFE_BOLD)or(dwEffects and not CFE_BOLD);|
      false:dwMask:=CFM_ITALIC; dwEffects:=(not dwEffects and CFE_ITALIC)or(dwEffects and not CFE_ITALIC);|
    end;
    SendMessage(����RTF,EM_SETCHARFORMAT,SCF_SELECTION,cardinal(addr(������)));
  end
end ��������������������������;

//-------------------- �������� �� ��������� ���� -------------------------

procedure �������������(��������:pstr):boolean;
var �����:integer;
begin
  �����:=lstrlen(��������)-4;
  return (�����>=0)and((��������[�����+1]='t')or(��������[�����+1]='T'));
end �������������;

//------------ ������� ��������� ������ �������� ----------

procedure �������������(dwCookie:cardinal; pbBuff:address; cb:cardinal; pcb:pINT):cardinal;
begin
  pcb^:=_lread(dwCookie,pbBuff,cb);
  if pcb^<0 then
    pcb^:=0
  end;
  return 0;
end �������������;

//-------------------- ��������� ����(load file)-------------------------

procedure ����������������������(wnd:HWND; ��������:pstr);
var ����:integer; �����:EDITSTREAM;
begin
  with ����� do
    ����:=_lopen(��������,0);
    if ����>0 then 
      dwCookie:=����;
      dwError:=0;
      pfnCallback:=addr(�������������);
      if �������������(��������)
        then SendMessage(����RTF,EM_STREAMIN,SF_TEXT,cardinal(addr(�����)))
        else SendMessage(����RTF,EM_STREAMIN,SF_RTF,cardinal(addr(�����)))
      end;
      _lclose(����);
       SendMessage(����RTF,EM_SETMODIFY,0,0)
    end
  end
end ����������������������;

//------------ ������� ��������� ������ ���������� ----------

procedure �������������(dwCookie:cardinal; pbBuff:address; cb:cardinal; pcb:pINT):cardinal;
begin
  cb:=_lwrite(dwCookie,pbBuff,cb);
  pcb^:=cb;
  return 0;
end �������������;

//-------------------- ��������� ����(save file)-------------------------

procedure ����������������������(wnd:HWND; ��������:pstr);
var ����:integer; �����:EDITSTREAM;
begin
  with ����� do
    ����:=_lcreat(��������,0);
    if ����>0 then
      dwCookie:=����;
      dwError:=0;
      pfnCallback:=addr(�������������);
      if �������������(��������)
        then SendMessage(����RTF,EM_STREAMOUT,SF_TEXT,cardinal(addr(�����)))
        else SendMessage(����RTF,EM_STREAMOUT,SF_RTF,cardinal(addr(�����)))
      end;
      _lclose(����);
       SendMessage(����RTF,EM_SETMODIFY,0,0)
    end
  end
end ����������������������;

//-------------------- ������ ������ -------------------------

const
  ������������������=101;

dialog DLG_FIND 80,58,160,65,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "����� ������"
begin
  control "������� ��� ������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,5,3,149,11
  control "",������������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,16,149,12
  control "��",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,31,48,45,12
  control "������",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,82,48,45,12
end;

procedure �����������������������(wnd:HWND; msg,wparam,lparam:cardinal):cardinal;
begin
  case msg of
    WM_INITDIALOG:SetDlgItemText(wnd,������������������,����������������);|
    WM_COMMAND:case loword(wparam) of
      IDOK:
        GetDlgItemText(wnd,������������������,����������������,500);
        EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
    else return(0);
  end;
  return(1);
end �����������������������;

//---------------------------������������� toolbar------------------------------

bitmap bmpToolbar="tool_rtf.bmp";

procedure �������������(wnd:HWND);
var
  ������:array[1..50]of TBBUTTON;
  ����������:integer;
  bmp:HBITMAP;
  ������:��������������������������;
  �������:���������������������;
  ������:RECT;
begin
  InitCommonControls();
  bmp:=LoadBitmap(INSTANCE,"bmpToolbar");
  //���������� ������� ������
  ����������:=0;
  for ������:=������������� to ������������������� do
  with ����������������������������[������] do 
    //������ ������ ������
    for �������:=������������������� to ���������������������� do
    if (�����������[�������]>0)and(����������<50) then
      inc(����������);
      RtlZeroMemory(addr(������[����������]),sizeof(TBBUTTON));
      with ������[����������] do
        iBitmap:=�����������[�������]-1;
        idCommand:=����������+integer(�������);
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_BUTTON;
      end;
    end end;
    //���������� ����� ��������
    if ����������<50 then
      inc(����������);
      RtlZeroMemory(addr(������[����������]),sizeof(TBBUTTON));
      with ������[����������] do
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_SEP;
      end
    end
  end end;
  //�������� toolbar
  ����������:=CreateToolbarEx(
    wnd,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,����������,0,bmp,addr(������),����������,20,20,20,20,sizeof(TBBUTTON));
  //��������� ��������� toolbar
  with ������ do
    GetWindowRect(����������,������);
    dec(top,10);
    MoveWindow(����������,left,top,right-left+1,bottom-top+1,true);
  end;
end �������������;

//---------------------------������ ������ toolbar------------------------------

procedure ������������������(lparam:cardinal);
var
  ������:pNMHDR;
  �����������:pTOOLTIPTEXT;
  �������:���������������������;
begin
  ������:=address(lparam);
  �����������:=address(lparam);  
  with ������^,�����������^ do
    �������:=���������������������(idFrom-����������);
    case code of
      TTN_NEEDTEXT:
        �������:=���������������������(idFrom-����������);
        lpszText:=�����������������������[�������];|
    end
  end
end ������������������;

//---------------------------������� ���� RTF------------------------------

procedure ��������������RTF(wnd:HWND);
var ���������������,������������,������������,������RTF:RECT;
begin
  with ������RTF do
    GetClientRect(wnd,���������������);
    GetWindowRect(����������,������������);
    GetWindowRect(����������,������������);
    left:=5;
    right:=���������������.right-���������������.left-10;
    top:=������������.bottom-������������.top+5;
    bottom:=
      (���������������.bottom-���������������.top)-
      (������������.bottom-������������.top)-
      (������������.bottom-������������.top)-10;
    MoveWindow(����RTF,left,top,right,bottom,true);
  end
end ��������������RTF;

//-------------------- ������� ��������� -------------------------

procedure ����������������(wnd:HWND; ���DOS:boolean);
var �����:pstr;
begin
  if not(not �������������(�����������������)and
    (MessageBox(�������������,"�� ������� � ������������� ����� ��������� ?","��������:",MB_YESNO)<>IDYES)) then
    �����:=GlobalLock(GlobalAlloc(GMEM_FIXED,GetWindowTextLength(����RTF)+1));
    GetWindowText(����RTF,�����,GetWindowTextLength(����RTF)+1);
    if ���DOS
      then CharToOem(�����,�����);
      else OemToChar(�����,�����);
    end;
    SetWindowText(����RTF,�����);
    GlobalFree(GlobalHandle(�����));
  end
end ����������������;

//===============================================
//                  ����������� ������ ����
//===============================================

//-------------------- ������� ����(open file)-------------------------

procedure ������������������(wnd:HWND);
var ����,���:string[500]; ofn:OPENFILENAME;
begin
  with ofn do
    lstrcpy(����,"*.rtf");
    ���[0]:=char(0);
    RtlZeroMemory(addr(ofn),sizeof(OPENFILENAME));
    lStructSize:=sizeof(OPENFILENAME);
    lpstrFilter:="RTF-�����\0*.rtf\0��������� �����\0*.txt\0";
    nFilterIndex:=1;
    lpstrFile:=addr(����);
    nMaxFile:=500;
    lpstrFileTitle:=addr(���);
    nMaxFileTitle:=500;
    Flags:=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if GetOpenFileName(ofn) then
      ����������������������(wnd,����);
      lstrcpy(�����������������,����);
    end;
  end
end ������������������;

//-------------------- ��������� ����(save file)-------------------------

procedure ��������������������(wnd:HWND);
begin
  if �����������������[0]<>'\0' then
    ����������������������(wnd,�����������������);
  end
end ��������������������;

//-------------------- ��������� ��� -------------------------

procedure �����������������������(wnd:HWND);
var ����,���:string[500]; ofn:OPENFILENAME;
begin
  with ofn do
    lstrcpy(����,"*.rtf");
    ���[0]:=char(0);
    RtlZeroMemory(addr(ofn),sizeof(OPENFILENAME));
    lStructSize:=sizeof(OPENFILENAME);
    lpstrFilter:="RTF-�����\0*.rtf\0��������� �����\0*.txt\0";
    nFilterIndex:=1;
    lpstrFile:=addr(����);
    nMaxFile:=500;
    lpstrFileTitle:=addr(���);
    nMaxFileTitle:=500;
    Flags:=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if GetSaveFileName(ofn) then
      ����������������������(wnd,����);
      lstrcpy(�����������������,����);
    end
  end
end �����������������������;

//-------------------- �������� ��� -------------------------

procedure ������������������(wnd:HWND);
var ������:CHARRANGE;
begin
  with ������ do
    cpMin:=0;
    cpMax:=-1;
    SendMessage(����RTF,EM_EXSETSEL,0,cardinal(addr(������)));
  end
end ������������������;

//-------------------- ����� -------------------------

procedure ������������(wnd:HWND; ����������������:boolean);
var �������:FINDTEXTEX; �������:integer;
begin
  if (���������������� and
    boolean(DialogBoxParam(INSTANCE,"DLG_FIND",����RTF,addr(�����������������������),0))) or
    not ���������������� then
    with ������� do
      if ����������������
        then chrg.cpMin:=0;
        else chrg.cpMin:=hiword(SendMessage(����RTF,EM_GETSEL,0,0));
      end;
      chrg.cpMax:=-1;
      lpstrText:=addr(����������������);
      �������:=SendMessage(����RTF,EM_FINDTEXTEX,0,cardinal(addr(�������)));
      if �������=-1
        then MessageBox(����RTF,"�������� �� ������","��������:",MB_ICONSTOP)
        else SendMessage(����RTF,EM_SETSEL,chrgText.cpMin,chrgText.cpMax)
      end;
    end
  end
end ������������;

//-------------------- ����� ������ -------------------------

procedure ������������(wnd:HWND);
var ������:CHARFORMAT; �����:CHOOSEFONT; ��������:LOGFONT; dc:HDC;
begin
  with ������ do
  //�������� ������� ������
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(����RTF,EM_GETCHARFORMAT,1,cardinal(addr(������)));
    dc:=GetDC(wnd);
  //��������� ����� �������� ����������������
    with �������� do
      RtlZeroMemory(addr(��������),sizeof(LOGFONT));
      lfItalic:=byte((dwEffects and CFE_ITALIC)<>0);
      lfHeight:=-yHeight div 15;
      lfPitchAndFamily:=bPitchAndFamily;
      lstrcpy(lfFaceName,szFaceName);
      if (dwEffects and CFE_BOLD)=0
        then lfWidth:=FW_NORMAL
        else lfWidth:=FW_BOLD
      end;
    end;
  //��������� ��������� ������ ������
    with ����� do
      RtlZeroMemory(addr(�����),sizeof(CHOOSEFONT));
      lStructSize:=sizeof(CHOOSEFONT);
      Flags:=CF_SCREENFONTS | CF_INITTOLOGFONTSTRUCT;
      hDC:=dc;
      hwndOwner:=wnd;
      lpLogFont:=addr(��������);
      rgbColors:=0;
      nFontType:=SCREEN_FONTTYPE;
    end;
  //����� ������
    if ChooseFont(�����) then
  //��������� ������ �������
      with �������� do
        dwMask:=CFM_BOLD | CFM_FACE | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE | CFM_OFFSET;
        yHeight:=-lfHeight*15;
        dwEffects:=0;
        if boolean(lfItalic) then dwEffects:=dwEffects or CFE_ITALIC end;
        if lfWeight=FW_BOLD then dwEffects:=dwEffects or CFE_BOLD end;
        bPitchAndFamily:=lfPitchAndFamily;
        lstrcpy(szFaceName,lfFaceName);
      end;
//�������� ������ ��������
      SendMessage(����RTF,EM_SETCHARFORMAT,SCF_SELECTION,cardinal(addr(������)));
    end;
    ReleaseDC(wnd,dc);
  end
end ������������;

//-------------------- ������ ����� -------------------------

procedure �����������������(wnd:HWND);
var
  ��������:DOCINFO;
  ������:FORMATRANGE;
  ������:PRINTDLG;
  ���������:integer;
  �������������,���������������:integer;
  dc:HDC;
begin
  //��������� ��������� ��� ������� ������
  with ������ do
    RtlZeroMemory(addr(������),sizeof(PRINTDLG));
    lStructSize:=sizeof(PRINTDLG);
    hwndOwner:=����RTF;
    hInstance:=INSTANCE;
    Flags:=PD_RETURNDC | PD_NOPAGENUMS | PD_NOSELECTION | PD_PRINTSETUP | PD_ALLPAGES;
    nFromPage:=0xFFFF;
    nToPage:=0xFFFF;
    nMinPage:=0;
    nMaxPage:=0xFFFF;
    nCopies:=1;
  end;
  //����� ������� ������
  if PrintDlg(������) then
    dc:=������.hDC;
  //���������� ����� ��������� ��������������
    with ������ do
      RtlZeroMemory(addr(������),sizeof(FORMATRANGE));
      hdc:=dc; //�������� ������ ��������
      hdcTarget:=dc;
      chrg.cpMin:=0; //���� ��������
      chrg.cpMax:=-1;
      rcPage.top:=0; //������� �������� � TWIPS
      rcPage.left:=0;
      rcPage.right:=MulDiv(GetDeviceCaps(dc,PHYSICALWIDTH),1440,GetDeviceCaps(dc,LOGPIXELSX));
      rcPage.bottom:=MulDiv(GetDeviceCaps(dc,PHYSICALHEIGHT),1440,GetDeviceCaps(dc,LOGPIXELSY));
      rc:=rcPage;
    end;  
  //���������� ����� ���������
    with �������� do
      RtlZeroMemory(addr(��������),sizeof(DOCINFO));
      cbSize:=sizeof(DOCINFO);
      lpszOutput:=nil;
      lpszDocName:="Strannik";
    end;
  //������ ���������
    ���������:=StartDoc(dc,��������);
    if ���������<=0 then MessageBox(����RTF,"������ ������","��������:",MB_ICONSTOP)
    else
      �������������:=0;
      ���������������:=SendMessage(����RTF,WM_GETTEXTLENGTH,0,0);
      while �������������<��������������� do
      //�������������� � ������
        �������������:=SendMessage(����RTF,EM_FORMATRANGE,1,cardinal(addr(������)));
        if �������������<��������������� then
          EndPage(dc);
          StartPage(dc);
          ������.chrg.cpMin:=�������������;
          ������.chrg.cpMax:=-1;
        end;
        SendMessage(����RTF,EM_FORMATRANGE,1,0);
        EndPage(dc);
        EndDoc(dc);
      end
    end;
    DeleteDC(dc);
  end;
end �����������������;

//-------------------- ����� �� ��������� -------------------------

procedure ������������(wnd:HWND):boolean;
var �����:cardinal;
begin
   if boolean(SendMessage(����RTF,EM_GETMODIFY,0,0)) then
     �����:=MessageBox(����RTF,"���� ��� �������. ��������� ?","��������",MB_ICONSTOP | MB_YESNOCANCEL);
     case ����� of
       IDYES:����������������������(wnd,�����������������); return true;|
       IDNO:return true;|
       IDCANCEL:return false;|
     end;
   else return true
   end
end ������������;

//===============================================
//            ���������� ������� ���������
//===============================================

//------------------------ �������� ����(create menu)----------------------------

procedure ��������������������(wnd:HWND);
var
  ����������,����������:HMENU;
  �������:���������������������;
  ������:��������������������������;
begin
  ����������:=CreateMenu();
  for ������:=������������� to ������������������� do
  with ����������������������������[������] do 
    ����������:=CreatePopupMenu();
    for �������:=������������������� to ���������������������� do
      if �����������������������[�������][0]='\0'
        then AppendMenu(����������,MF_SEPARATOR,0,nil)
        else AppendMenu(����������,MF_STRING,����������+integer(�������),�����������������������[�������])
      end
    end;
    AppendMenu(����������,MF_POPUP,����������,���������);
  end end;
  AppendMenu(����������,MF_STRING,����������+integer(��������),�����������������������[��������]);
  SetMenu(wnd,����������);
end ��������������������;

//------------ ������� ������� ��� RichEdit ------------------

procedure ��������������(code,wparam,lparam:integer):cardinal;
var message����:pMSG;
begin
  message����:=pMSG(lparam);
  with message����^ do
  if  code=HC_ACTION then
    ��������������(hwnd);
    case message of
      WM_KEYDOWN:SendMessage(�������������,message,wParam,lParam);|
    end;
  end end;
  return 0
end ��������������;

//------------------------ ������ ��������� ----------------------------

dialog DLG_EDI 6,5,291,179,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "��������� �������� '��������'"
begin
  control "",����������RTF,"RichEdit",WS_CHILD | WS_BORDER | ES_MULTILINE | ES_AUTOVSCROLL | WS_VSCROLL | ES_WANTRETURN | WS_VISIBLE | ES_SAVESEL,2,12,286,146
end;

//--------------- ���������� ������� ��������� ------------------

procedure ��������������������������(wnd:HWND; msg,wparam,lparam:cardinal):cardinal;
begin
  case msg of
    WM_INITDIALOG:
      ��������������������(wnd);
      �������������:=wnd;
      ����RTF:=GetDlgItem(wnd,����������RTF);
      �����������������[0]:=char(0);
      ����������������[0]:=char(0);
      ������RTF:=SetWindowsHookEx(WH_GETMESSAGE,addr(��������������),0,GetWindowThreadProcessId(����RTF,nil));
      �������������(wnd);
      �������������(wnd,false);
      ��������������RTF(wnd);|
    WM_SIZE:��������������RTF(wnd); �������������(wnd,true);|
    WM_COMMAND:case loword(wparam) of
      ����������+������������:if ������������(wnd) then SetWindowText(����RTF,"") end;|
      ����������+��������������:if ������������(wnd) then ������������������(wnd) end;|
      ����������+����������������:��������������������(wnd);|
      ����������+�������������������:�����������������������(wnd);|
      ����������+�������������:�����������������(wnd);|
      ����������+�����������������:SendMessage(����RTF,EM_UNDO,0,0);|
      ����������+�����������������:SendMessage(����RTF,WM_CUT,0,0);|
      ����������+�������������������:SendMessage(����RTF,WM_COPY,0,0);|
      ����������+�����������������:SendMessage(����RTF,WM_PASTE,0,0);|
      ����������+����������������:SendMessage(����RTF,WM_CLEAR,0,0);|
      ����������+��������������������:������������������(wnd);|
      ����������+��������:������������(wnd,true);|
      ����������+�����������������:������������(wnd,false);|
      ����������+��������������:������������(wnd);|
      ����������+��������������������:��������������������������(wnd,true);|
      ����������+��������������������:��������������������������(wnd,false);|
      ����������+�������������������:����������������������������(wnd,-1);|
      ����������+��������������������:����������������������������(wnd,1);|
      ����������+����������������������:����������������������������(wnd,0);|
      ����������+�������������WINDOWS:����������������(wnd,false);|
      ����������+�������������DOS:����������������(wnd,true);|
      IDCANCEL,����������+������������,����������+��������:if ������������(wnd) then
        UnhookWindowsHookEx(������RTF);
        EndDialog(wnd,1)
      end;|
    end;|
    WM_KEYDOWN:case loword(wparam) of
      VK_F3:SendMessage(wnd,WM_COMMAND,����������+ord(�����������������),0);|
    end;|
    WM_NOTIFY:������������������(lparam);|
  else return(0);
  end;
  return(1);
end ��������������������������;

//--------------- ����� ��������� ------------------

procedure ��������RTF(����������������:HWND);
var ������:HANDLE;
begin
  ������:=LoadLibrary("RICHED32.DLL");
  DialogBoxParam(INSTANCE,"DLG_EDI",����������������,addr(��������������������������),0);
  FreeLibrary(������);
end ��������RTF;

begin
  ��������RTF(0);
  ExitProcess(0); //���������� ��� �������� �� ������ RTF
end Demo1_5.

