// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.1:������ � �������

program Demo2_1;
uses Win32;

const 
  hINSTANCE=0x400000;

  ����������=100;
  ���������=101;
  ����=200;
  ������������=1000;

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

var
  ����������:dword;
  ����������:dword;

//================= �������� ������� � ������ =======================

function ����������������������(����:HWND; ����,�����:HTREEITEM; �����:pstr, ������,�����������:HBITMAP):HTREEITEM;
var ������:TV_INSERTSTRUCT;
begin
  RtlZeroMemory(addr(������),sizeof(TV_INSERTSTRUCT));
  with ������,item do begin
    mask:=TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;
    pszText:=�����;
    cchTextMax:=lstrlen(�����);
    iImage:=������;
    iSelectedImage:=�����������;
    hInsertAfter:=�����;
    hParent:=����;  
  end;
  ����������������������:=HTREEITEM(SendMessage(����,TVM_INSERTITEM,0,integer(addr(������))))
end;

//================= ������� ���� � ������� =======================

procedure �������������(�������:HWND; ��:dword);
var ������:HIMAGELIST; ������:HBITMAP;
begin
  InitCommonControls();
  ������:=ImageList_Create(20,20,0,2,0);
  ������:=LoadBitmap(hINSTANCE,"TreeOpen"); ����������:=ImageList_Add(������,������,0);
  ������:=LoadBitmap(hINSTANCE,"TreeClose"); ����������:=ImageList_Add(������,������,0);
  SendMessage(GetDlgItem(�������,��),TVM_SETIMAGELIST,TVSIL_NORMAL,������);
end;

//================= ��������� ������ ���������� =======================

procedure ���������������(����:HWND);
var ������,������,������:HTREEITEM;
begin
  ������:=����������������������(����,TVI_ROOT,TVI_FIRST,"�������� �������",����������,����������);
  ������:=����������������������(����,������,TVI_LAST,"������ ������, ������� 1",����������,����������);
  ������:=����������������������(����,������,TVI_LAST,"������ ������, ������� 1",����������,����������);
  ������:=����������������������(����,������,TVI_LAST,"������ ������, ������� 2",����������,����������);
  ������:=����������������������(����,������,TVI_LAST,"������ ������, ������� 2",����������,����������);
  ������:=����������������������(����,������,TVI_LAST,"������ ������, ������� 3",����������,����������);
end;

//================= ������� ����� ������� ����� �������� =======================

procedure ���������������(����:HWND);
var �������,�����������:HTREEITEM;
begin
  �������:=SendMessage(����,TVM_GETNEXTITEM,TVGN_CARET,0);
  �����������:=SendMessage(����,TVM_GETNEXTITEM,TVGN_PARENT,�������);
  ����������������������(����,�����������,�������,"����� �������",����������,����������);
end;

//================= ������� ������� ������� =======================

procedure ��������������(����:HWND);
var �������:HTREEITEM;
begin
  �������:=SendMessage(����,TVM_GETNEXTITEM,TVGN_CARET,0);
  SendMessage(����,TVM_DELETEITEM,0,�������);
end;

//================= ��������� ��������� �� ���� =======================

function ���������������������������(����:HWND; ����:pTV_DISPINFO):boolean;
begin
  with ����^.hdr,����^.item do begin
  case code of
    TVN_ENDLABELEDIT://��������� ������ ��������
      if pszText=nil then return false
      else begin
        MessageBox(0,pszText,"����� �����",0);
        return true
      end;
  end end;
  ���������������������������:=false
end;

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,115,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_1:������ � �������"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,62,97,45,14
  control "",������������,"SysTreeView32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TVS_HASLINES | TVS_HASBUTTONS | TVS_LINESATROOT | TVS_EDITLABELS,8,24,145,67
  control "�������",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,97,6,40,12
  control "��������",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,33,6,40,12
end;

//================= ���������� ������� =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:begin �������������(wnd,������������); ���������������(GetDlgItem(wnd,������������)) end;
    WM_COMMAND:case loword(wparam) of
      ����������:���������������(GetDlgItem(wnd,������������));
      ���������:��������������(GetDlgItem(wnd,������������));
      IDOK,����:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
    WM_NOTIFY:case loword(wparam) of
      ������������:procDLG_MAIN:=���������������������������(GetDlgItem(wnd,������������),address(lparam));
    end;
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= ����� ������� ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

