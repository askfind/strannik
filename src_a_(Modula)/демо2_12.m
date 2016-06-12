// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.12:������ � ����������

module Demo2_12;
import Win32;

const 
  hINSTANCE=0x400000;

//����� ������� � ������
procedure lstrposc(sym:char; str:pstr):integer;
var i:integer;
begin
  if str=nil then return -1 end;
  i:=0;
  while (str[i]<>'\0')and(str[i]<>sym) do
    i:=i+1;
  end;
  if str[i]=sym
    then return i
    else return -1
  end
end lstrposc;

//�������� ���������
procedure lstrdel(str:pstr; pos,len:integer);
var i,l:integer;
begin
  if pos<0 then
    len:=len+pos;
    pos:=0;
  end;
  if len>=0 then
    l:=lstrlen(str);
    if pos+len>l then
      if pos<l then str[pos]:='\0' else end
    else
      for i:=1 to l-(pos+len)+1 do
        str[pos+i-1]:=str[pos+i+len-1];
      end
    end
  end
end lstrdel;

//��������� ���� ���������
procedure ������������������(���������:HWND; ������:pstr);
var
  ������:RECT; �������:HDITEM; ���,����:integer;
  �����,������:string[500];
begin
  GetClientRect(���������,������);
  ����:=0;
  for ���:=0 to lstrlen(������)-1 do
  if ������[���]<>'\9' then
    inc(����)
  end end;
  lstrcpyn(�����,������,500);
  ���:=0;
  while lstrposc('\9',�����)>=0 do
  with ������� do
    lstrcpy(������,�����);
    ������[lstrposc('\9',�����)]:='\0';
    mask:=HDI_TEXT | HDI_FORMAT | HDI_WIDTH;
    pszText:=addr(������);
    cxy:=(������.right-������.left)*lstrlen(������) div (����-1);
    cchTextMax:=lstrlen(������);
    fmt:=HDF_LEFT | HDF_STRING;
    SendMessage(���������,HDM_INSERTITEM,���,cardinal(addr(�������)));
    lstrdel(�����,0,lstrposc('\9',�����)+1);
    inc(���);
  end end;
end ������������������;

// ���������� ������ ������
procedure ����������������(���������:HWND; ���:pDRAWITEMSTRUCT);
var ������,�����:string[1000]; ���:RECT; ���,����:integer; ����:HDITEM;
begin
with ���^ do
  SendMessage(hwndItem,LB_GETTEXT,itemID,integer(addr(�����)));
  ���:=0;
  ����:=0;
  while lstrposc('\9',�����)>=0 do
    lstrcpy(������,�����);
    ������[lstrposc('\9',�����)]:='\0';
    ����.mask:=HDI_WIDTH;
    SendMessage(���������,HDM_GETITEM,���,integer(addr(����)));
    ���:=rcItem;
    inc(���.left,����);
    ���.right:=���.left+����.cxy;
    if (itemState and ODS_SELECTED<>0)
      then SetTextColor(hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(hDC,GetSysColor(COLOR_HIGHLIGHT));
      else SetTextColor(hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(hDC,GetSysColor(COLOR_MENU));
    end;
    ExtTextOut(hDC,���.left,���.top,ETO_CLIPPED | ETO_OPAQUE,addr(���),������,lstrlen(������),nil);
    lstrdel(�����,0,lstrposc('\9',�����)+1);
    inc(���);
    inc(����,����.cxy);
  end
end
end ����������������;

//������
dialog DLG_LIST 126,40,306,169,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_12"
begin
  control "",100,"Listbox",WS_BORDER | WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_VSCROLL | LBS_OWNERDRAWFIXED | LBS_HASSTRINGS | LBS_WANTKEYBOARDINPUT,32,18,240,123
  control "",101,"SysHeader32",WS_CHILD | WS_VISIBLE | WS_BORDER | HDS_BUTTONS | HDS_HORZ,32,3,240,14
  control "��",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,128,144,52,14
end;

//���������� �������
procedure procDLG_LIST(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:
      ������������������(GetDlgItem(wnd,101),"File             \9Size     \9Date        \9");
      SendDlgItemMessage(wnd,100,LB_RESETCONTENT,0,0);
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_10 \9 12K \9 12.03.2004 \9"));
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_11 \9 29K \9 01.08.2004 \9"));
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,integer("demo1_12 \9 18K \9 20.11.2004 \9"));|
    WM_DRAWITEM:if wparam<>0 then ����������������(GetDlgItem(wnd,101),pDRAWITEMSTRUCT(lparam)) end;|
    WM_MEASUREITEM:|//������ ������ ������
    WM_VKEYTOITEM:|//���������� ������� �� ���������� � ������
    WM_COMMAND:case loword(wparam) of
      IDOK,IDCANCEL:EndDialog(wnd,1);|
    end;|
  else return false
  end;
  return true
end procDLG_LIST;

begin
  InitCommonControlsEx(nil);
  DialogBoxParam(hINSTANCE,"DLG_LIST",0,addr(procDLG_LIST),0);
end Demo2_12.

