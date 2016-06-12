// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.2:������ �� �������

module Demo2_2;
import Win32;

const 
  hINSTANCE=0x400000;

  ����������=100;
  ���������=101;
  �����=102;
  ����=200;
  ��������=1000;

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

var
  ����������:cardinal;
  ����������:cardinal;

//================= ������������ ������ =======================

procedure ������������������(�������:HWND; ��:cardinal);
var ������:HIMAGELIST; ������:HBITMAP; ������:RECT; ������:LV_COLUMN;
begin
  InitCommonControls();
//������ �����������
  ������:=ImageList_Create(20,20,0,2,0);
  ������:=LoadBitmap(hINSTANCE,"TreeOpen"); ����������:=ImageList_Add(������,������,0);
  ������:=LoadBitmap(hINSTANCE,"TreeClose"); ����������:=ImageList_Add(������,������,0);
  SendMessage(GetDlgItem(�������,��),LVM_SETIMAGELIST,LVSIL_NORMAL,������);
  SendMessage(GetDlgItem(�������,��),LVM_SETIMAGELIST,LVSIL_SMALL,������);
//������ ��������
  GetClientRect(GetDlgItem(�������,��),������);
  with ������,������ do
    mask:=LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;
    fmt:=LVCFMT_LEFT; pszText:="���"; cchTextMax:=lstrlen(pszText); cx:=right*40 div 100; SendMessage(GetDlgItem(�������,��),LVM_INSERTCOLUMN,0,integer(addr(������)));
    fmt:=LVCFMT_LEFT; pszText:="������"; cchTextMax:=lstrlen(pszText); cx:=right*20 div 100; SendMessage(GetDlgItem(�������,��),LVM_INSERTCOLUMN,1,integer(addr(������)));
    fmt:=LVCFMT_LEFT; pszText:="����"; cchTextMax:=lstrlen(pszText); cx:=right*40 div 100; SendMessage(GetDlgItem(�������,��),LVM_INSERTCOLUMN,2,integer(addr(������)));
  end;
end ������������������;

procedure ����������������������(����:HWND; �����:integer; �����:pstr; ������:HBITMAP);
var ������:LV_ITEM;
begin
  with ������ do
    RtlZeroMemory(addr(������),sizeof(LV_ITEM));
    mask:=LVIF_TEXT | LVIF_IMAGE;
    iItem:=�����;
    iImage:=������;
    iSubItem:=0;
    pszText:=�����;
    cchTextMax:=lstrlen(pszText);
    SendMessage(����,LVM_INSERTITEM,0,integer(addr(������)));
  end
end ����������������������;

//================= ��������� ������ ���������� =======================

procedure ���������������(����:HWND);
begin
  SendMessage(����,LVM_DELETEALLITEMS,0,0);
  ����������������������(����,0,"������� �������",����������);
  ����������������������(����,1,"������ �������",����������);
  ����������������������(����,2,"������ �������",����������);
end ���������������;

//================= ������� ����� ������� ����� �������� =======================

procedure ���������������(����:HWND);
var �������:integer;
begin
  �������:=SendMessage(����,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  ����������������������(����,�������+1,"����� �������",����������);
end ���������������;

//================= ������� ������� ������� =======================

procedure ��������������(����:HWND);
var �������:integer;
begin
  �������:=SendMessage(����,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  SendMessage(����,LVM_DELETEITEM,�������,0);
end ��������������;

//================= �������� ��� ������ =======================

procedure ����������(����:HWND);
var �����:cardinal;
begin
  �����:=GetWindowLong(����,GWL_STYLE);
  case ����� and (LVS_REPORT | LVS_LIST | LVS_SMALLICON | LVS_ICON) of
    LVS_REPORT:�����:=(����� and (not LVS_REPORT))or LVS_LIST;|
    LVS_LIST:�����:=(����� and (not LVS_LIST))or LVS_SMALLICON;|
    LVS_SMALLICON:�����:=(����� and (not LVS_SMALLICON))or LVS_ICON;|
    LVS_ICON:�����:=(����� and (not LVS_ICON))or LVS_REPORT;|
  end;
  SetWindowLong(����,GWL_STYLE,�����);
end ����������;

//================= ��������� ��������� �� ���� =======================

procedure ���������������������������(����:HWND; ����:pLV_DISPINFO):boolean;
begin
  with ����^.hdr,����^.item do
  case code of
    LVN_GETDISPINFO:if mask and LVIF_TEXT<>0 then //����� ��������
      case iSubItem of //����� �������� � iItem
        1:pszText:="230";|
        2:pszText:="12.09.2002";|
      end;
      return true
    end;|
//    LVN_BEGINDRAG:return true;|
  end end;
  return false
end ���������������������������;

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,115,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_2:������ �� �������"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,62,97,45,14
  control "�������",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,115,8,40,12
  control "��������",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,6,8,40,12
  control "������� ���",�����,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,54,8,56,12
  control "",��������,"SysListView32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LVS_REPORT,8,25,147,68
end;

//================= ���������� ������� =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:������������������(wnd,��������); ���������������(GetDlgItem(wnd,��������));|
    WM_COMMAND:case loword(wparam) of
      ����������:���������������(GetDlgItem(wnd,��������));|
      ���������:��������������(GetDlgItem(wnd,��������));|
      �����:����������(GetDlgItem(wnd,��������));|
      IDOK,����:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
    WM_NOTIFY:case loword(wparam) of
      ��������:return ���������������������������(GetDlgItem(wnd,��������),address(lparam));|
    end;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= ����� ������� ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end Demo2_2.

