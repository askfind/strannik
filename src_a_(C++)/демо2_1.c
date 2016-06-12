// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.1:������ � �������

include "Win32"

define hINSTANCE 0x400000

define ���������� 100
define ��������� 101
define ���� 200
define ������������ 1000

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

uint ����������;
uint ����������;

//================= �������� ������� � ������ =======================

HTREEITEM ����������������������(HWND ����, HTREEITEM ����, HTREEITEM �����, char* �����, HBITMAP ������, HBITMAP �����������)
{
TV_INSERTSTRUCT ������;

  RtlZeroMemory(&������,sizeof(TV_INSERTSTRUCT));
  with(������,item) {
    mask=TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;
    pszText=�����;
    cchTextMax=lstrlen(�����);
    iImage=������;
    iSelectedImage=�����������;
    hInsertAfter=�����;
    hParent=����;  
  }
  return (HTREEITEM) SendMessage(����,TVM_INSERTITEM,0,(int)(&������));
}

//================= ������� ���� � ������� =======================

void �������������(HWND �������, uint ��)
{
HIMAGELIST ������; HBITMAP ������;
  InitCommonControls();
  ������=ImageList_Create(20,20,0,2,0);
  ������=LoadBitmap(hINSTANCE,"TreeOpen"); ����������=ImageList_Add(������,������,0);
  ������=LoadBitmap(hINSTANCE,"TreeClose"); ����������=ImageList_Add(������,������,0);
  SendMessage(GetDlgItem(�������,��),TVM_SETIMAGELIST,TVSIL_NORMAL,������);
}

//================= ��������� ������ ���������� =======================

void ���������������(HWND ����)
{
HTREEITEM ������,������,������;

  ������=����������������������(����,TVI_ROOT,TVI_FIRST,"�������� �������",����������,����������);
  ������=����������������������(����,������,TVI_LAST,"������ ������, ������� 1",����������,����������);
  ������=����������������������(����,������,TVI_LAST,"������ ������, ������� 1",����������,����������);
  ������=����������������������(����,������,TVI_LAST,"������ ������, ������� 2",����������,����������);
  ������=����������������������(����,������,TVI_LAST,"������ ������, ������� 2",����������,����������);
  ������=����������������������(����,������,TVI_LAST,"������ ������, ������� 3",����������,����������);
}

//================= ������� ����� ������� ����� �������� =======================

void ���������������(HWND ����)
{
HTREEITEM �������,�����������;

  �������=SendMessage(����,TVM_GETNEXTITEM,TVGN_CARET,0);
  �����������=SendMessage(����,TVM_GETNEXTITEM,TVGN_PARENT,�������);
  ����������������������(����,�����������,�������,"����� �������",����������,����������);
}

//================= ������� ������� ������� =======================

void ��������������(HWND ����)
{
HTREEITEM �������;

  �������=SendMessage(����,TVM_GETNEXTITEM,TVGN_CARET,0);
  SendMessage(����,TVM_DELETEITEM,0,�������);
}

//================= ��������� ��������� �� ���� =======================

bool ���������������������������(HWND ����, TV_DISPINFO* ����)
{
  with(����->hdr,����->item) {
  switch(code) {
    case TVN_ENDLABELEDIT://��������� ������ ��������
      if(pszText==nil) return false;
      else {
        MessageBox(0,pszText,"����� �����",0);
        return true;
      } break;
  }}
  return false;
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:�������������(wnd,������������); ���������������(GetDlgItem(wnd,������������)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case ����������:���������������(GetDlgItem(wnd,������������)); break;
      case ���������:��������������(GetDlgItem(wnd,������������)); break;
      case IDOK: case ����:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_NOTIFY:switch(loword(wparam)) {
      case ������������:return ���������������������������(GetDlgItem(wnd,������������),(void*)lparam); break;
    } break;
  default:return false; break;
  }
  return true;
}

//================= ����� ������� ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

