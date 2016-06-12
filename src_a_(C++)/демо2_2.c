// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.2:������ �� �������

include Win32

define hINSTANCE 0x400000

define ���������� 100
define ��������� 101
define ����� 102
define ���� 200
define �������� 1000

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

uint ����������;
uint ����������;

//================= ������������ ������ =======================

void ������������������(HWND �������, uint ��)
{HIMAGELIST ������; HBITMAP ������; RECT ������; LV_COLUMN ������;

  InitCommonControls();
//������ �����������
  ������=ImageList_Create(20,20,0,2,0);
  ������=LoadBitmap(hINSTANCE,"TreeOpen"); ����������=ImageList_Add(������,������,0);
  ������=LoadBitmap(hINSTANCE,"TreeClose"); ����������=ImageList_Add(������,������,0);
  SendMessage(GetDlgItem(�������,��),LVM_SETIMAGELIST,LVSIL_NORMAL,������);
  SendMessage(GetDlgItem(�������,��),LVM_SETIMAGELIST,LVSIL_SMALL,������);
//������ ��������
  GetClientRect(GetDlgItem(�������,��),������);
  with(������,������) {
    mask=LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM;
    fmt=LVCFMT_LEFT; pszText="���"; cchTextMax=lstrlen(pszText); cx=right*40 div 100; SendMessage(GetDlgItem(�������,��),LVM_INSERTCOLUMN,0,(int)(&������));
    fmt=LVCFMT_LEFT; pszText="������"; cchTextMax=lstrlen(pszText); cx=right*20 div 100; SendMessage(GetDlgItem(�������,��),LVM_INSERTCOLUMN,1,(int)(&������));
    fmt=LVCFMT_LEFT; pszText="����"; cchTextMax=lstrlen(pszText); cx=right*40 div 100; SendMessage(GetDlgItem(�������,��),LVM_INSERTCOLUMN,2,(int)(&������));
  }
}

void ����������������������(HWND ����, int �����, char* �����, HBITMAP ������)
{LV_ITEM ������;

  with(������) {
    RtlZeroMemory(&������,sizeof(LV_ITEM));
    mask=LVIF_TEXT | LVIF_IMAGE;
    iItem=�����;
    iImage=������;
    iSubItem=0;
    pszText=�����;
    cchTextMax=lstrlen(pszText);
    SendMessage(����,LVM_INSERTITEM,0,(int)(&������));
  }
}

//================= ��������� ������ ���������� =======================

void ���������������(HWND ����)
{
  SendMessage(����,LVM_DELETEALLITEMS,0,0);
  ����������������������(����,0,"������� �������",����������);
  ����������������������(����,1,"������ �������",����������);
  ����������������������(����,2,"������ �������",����������);
}

//================= ������� ����� ������� ����� �������� =======================

void ���������������(HWND ����)
{int �������;

  �������=SendMessage(����,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  ����������������������(����,�������+1,"����� �������",����������);
}

//================= ������� ������� ������� =======================

void ��������������(HWND ����)
{int �������;

  �������=SendMessage(����,LVM_GETNEXTITEM,-1,LVNI_ALL | LVNI_SELECTED);
  SendMessage(����,LVM_DELETEITEM,�������,0);
}

//================= �������� ��� ������ =======================

void ����������(HWND ����)
{uint �����;

  �����=GetWindowLong(����,GWL_STYLE);
  switch(����� & (LVS_REPORT | LVS_LIST | LVS_SMALLICON | LVS_ICON)) {
    case LVS_REPORT:�����=(����� & (! LVS_REPORT)) | LVS_LIST; break;
    case LVS_LIST:�����=(����� & (! LVS_LIST)) | LVS_SMALLICON; break;
    case LVS_SMALLICON:�����=(����� & (! LVS_SMALLICON)) | LVS_ICON; break;
    case LVS_ICON:�����=(����� & (! LVS_ICON)) | LVS_REPORT; break;
  }
  SetWindowLong(����,GWL_STYLE,�����);
}

//================= ��������� ��������� �� ���� =======================

bool ���������������������������(HWND ����, LV_DISPINFO* ����)
{
  with(����^.hdr,����^.item) {
  switch(code) {
    case LVN_GETDISPINFO:if(mask & LVIF_TEXT<>0) { //����� ��������
      switch(iSubItem) { //����� �������� � iItem
        case 1:pszText="230"; break;
        case 2:pszText="12.09.2001"; break;
      }
      return true;
    } break;
  }}
  return false;
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:������������������(wnd,��������); ���������������(GetDlgItem(wnd,��������)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case ����������:���������������(GetDlgItem(wnd,��������)); break;
      case ���������:��������������(GetDlgItem(wnd,��������)); break;
      case �����:����������(GetDlgItem(wnd,��������)); break;
      case IDOK: case ����:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_NOTIFY:switch(loword(wparam)) {
      case ��������:return ���������������������������(GetDlgItem(wnd,��������),(void*)lparam); break;
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

