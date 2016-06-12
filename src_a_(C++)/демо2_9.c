// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.9:������� PropertySheet

include Win32

define hINSTANCE 0x400000
define ������� 200 
define ������� 201 
define ����������0 202 
define ����������1 203 
define ����������2 204 

enum ������������� {�����������,��������};
typedef struct {
    char* ������������;
    char* ���������;
  } [�������������] �������������;

define ����������� �������������{
  {"�������������","DLG_1"},
  {"����� ���������","DLG_2"}}

  PROPSHEETPAGE ��������[�������������];
  HANDLE �����[�������������];
  PROPSHEETHEADER ���������;
  ������������� �������;
  char ������[100];
  char �����[500];
  int �������;

//================= ������� ������� =======================

dialog DLG_1 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "�������������"
begin
  control "������ �������",����������0,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,24,108,14
  control "������ �������",����������1,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,39,108,14
  control "������ �������",����������2,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,4,54,108,14
end;

dialog DLG_2 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "����� ���������"
begin
  control "����� ��� ���������� ���������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,39,126,11
  control "",�������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,5,57,126,11
  control "�����",�������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,87,73,40,12
end;

//================= ���������� ������� =======================

bool procDLG_1(HWND wnd, int message, int wparam, int lparam)
{pNMHDR ����;

  switch(message) {
    case WM_INITDIALOG:break;
    case WM_NOTIFY:����=pNMHDR(lparam);
    switch(����->code) {
      case PSN_SETACTIVE://��������� ��������        
        switch(�������) {
          case 0:SendDlgItemMessage(wnd,����������0,BM_SETCHECK,BST_CHECKED,0); break;
          case 1:SendDlgItemMessage(wnd,����������1,BM_SETCHECK,BST_CHECKED,0); break;
          case 2:SendDlgItemMessage(wnd,����������2,BM_SETCHECK,BST_CHECKED,0); break;
        }
      break;
      case PSN_KILLACTIVE:
        if(IsDlgButtonChecked(wnd,����������0)==BST_CHECKED) �������=0;
        if(IsDlgButtonChecked(wnd,����������1)==BST_CHECKED) �������=1;
        if(IsDlgButtonChecked(wnd,����������2)==BST_CHECKED) �������=2;
      break;
    }
    return false; break;
  default:return false; break;
  }
  return true;
}

bool procDLG_2(HWND wnd, int message, int wparam, int lparam)
{pNMHDR ����;

  switch(message) {
    case WM_INITDIALOG: break;
    case WM_COMMAND:switch(loword(wparam)) {
      case �������:MessageBox(0,"����������� ������ ������ ����� ������ � Demo2_6","������:�����",0); break;
    } break;
    case WM_NOTIFY:����=pNMHDR(lparam);
    switch(����->code) {
      case PSN_SETACTIVE:SetDlgItemText(wnd,�������,�����); break;
      case PSN_KILLACTIVE:GetDlgItemText(wnd,�������,�����,500); break;
    }
    return false; break;
  default:return false; break;
  }
  return true;
}

//================= ������������� � ����� ��������� ====================

void main()
{
//������������� �������
  for(�������=�����������; �������<=��������; �������++)
  with(��������[�������]) {
    RtlZeroMemory(&(��������[�������]),sizeof(PROPSHEETPAGE));
    dwSize=sizeof(PROPSHEETPAGE);
    dwFlags=PSP_USETITLE;
    hInstance=hINSTANCE;
    pszTemplate=�����������[�������].���������;
    pszTitle=�����������[�������].������������;
    switch(�������) {
      case �����������:pfnDlgProc=&procDLG_1; break;
      case ��������:pfnDlgProc=&procDLG_2; break;
    }
    �����[�������]=CreatePropertySheetPage(&(��������[�������]));
  }
//������������� ���������
  with(���������) {
    RtlZeroMemory(&���������,sizeof(PROPSHEETHEADER));
    dwSize=sizeof(PROPSHEETHEADER);
    dwFlags=0;
    hwndParent=0;
    hInstance=hINSTANCE;
    pszCaption="Demo2_9";
    nPages=2;
    nStartPage=0;
    ppsp=&�����;
  }
//����� ���������
  lstrcpy(�����,"c:\Program Files\demo2_9");
  �������=1;
  InitCommonControls();
  PropertySheet(���������);
  wvsprintf(������,"%li",&�������);
  MessageBox(0,������,"������ �������:",0);
  MessageBox(0,�����,"������� �����:",0);
}

