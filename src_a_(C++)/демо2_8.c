// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.8:��������� ���������

include Win32

define hINSTANCE 0x400000

define ������� 200
define ������� 201
define ����������� 202

enum ������������� {�������������,��������,��������};
typedef struct {
    char* ������������;
    char* ���������;
    uint ��������;
  } [�������������] �������������;

define ����������� �������������{
  {"����������","DLG_1",PSWIZB_NEXT},
  {"����� ���������","DLG_2",PSWIZB_BACK | PSWIZB_NEXT},
  {"���������� � ���������","DLG_3",PSWIZB_BACK | PSWIZB_FINISH}}

  PROPSHEETPAGE ��������[�������������];
  PROPSHEETHEADER ���������;
  ������������� �������;
  char �����[500];

//================= ������� ������� =======================

dialog DLG_1 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "����������"
begin
  control "����� ���������� � ��������� ���������.",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,38,183,13
  control "����������, �������� ���������� �����������",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,52,183,13
  control "������� ������ '�����'",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,66,183,13
end;

dialog DLG_2 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "����� ���������"
begin
  control "�������� ����� ��� ���������� ���������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,38,183,12
  control "",�������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,5,55,183,12
  control "�����",�������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,148,71,40,12
end;

dialog DLG_3 18,25,210,110,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "���������� � ���������"
begin
  control "��� ������ � ���������",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,5,183,13
  control "�� ������� ��������� ���������:",1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,19,183,13
  control "",�����������,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,5,34,185,43
  control "��� ������ ��������� ������� ������ '������'",-1,"Static",WS_CHILD | WS_VISIBLE | SS_LEFT,4,79,183,13
end;

//============ ������������ �������� �������  ==================

void �����������������(HWND wnd, ������������� ���)
{
  switch(���) {
    case �������������:break;
    case ��������:SetDlgItemText(wnd,�������,�����); break;
    case ��������:SetDlgItemText(wnd,�����������,�����); break;
  }
}

void ���������������(HWND wnd, ������������� ���)
{
  switch(���) {
    case �������������: break;
    case ��������:GetDlgItemText(wnd,�������,�����,500); break;
    case ��������: break;
  }
}

//================= ���������� �������  =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{pNMHDR ����;

  switch(message) {
    case WM_INITDIALOG: break;
    case WM_COMMAND:switch(loword(wparam)) {
      case �������:MessageBox(0,"����������� ������ ������ ����� ������ � Demo2_6","������ ������ �����",0); break;
    } break;
    case WM_NOTIFY:
      ����=pNMHDR(lparam);
      switch(����->code) {
        case PSN_SETACTIVE://��������� ��������
          SendMessage(GetParent(wnd),PSM_SETWIZBUTTONS,0,�����������[�������].��������);
          �����������������(wnd,�������);
        break;
        case PSN_WIZBACK:case PSN_WIZNEXT://����������� ��������
          ���������������(wnd,�������);
          if(����^.code==PSN_WIZBACK) �������--;
          else �������++;
        break;
        case PSN_WIZFINISH://����� �������
          MessageBox(0,�����,"������� �����:",0); break;
      } return false;
    break;    
  default:return false; break;
  }
  return true;
}

//================= ������������� � ����� ��������� ====================

void main()
{
//������������� �������
  for(�������=�������������; �������<=��������; �������++)
  with(��������[�������]) {
    RtlZeroMemory(&(��������[�������]),sizeof(PROPSHEETPAGE));
    dwSize=sizeof(PROPSHEETPAGE);
    dwFlags=PSP_USETITLE;
    hInstance=hINSTANCE;
    pszTemplate=�����������[�������].���������;
    pszTitle=�����������[�������].������������;
    pfnDlgProc=&procDLG_MAIN;
  }
//������������� ���������
  with(���������) {
    RtlZeroMemory(&���������,sizeof(PROPSHEETHEADER));
    dwSize=sizeof(PROPSHEETHEADER);
    dwFlags=PSH_PROPSHEETPAGE | PSH_WIZARD;
    hwndParent=0;
    hInstance=hINSTANCE;
    pszCaption="Demo2_8";
    nPages=ord(��������)+1;
    nStartPage=0;
    ppsp=&��������;
  }
//����� ���������
  lstrcpy(�����,"c:\Program Files\demo2_8");
  InitCommonControls();
  �������=�������������;
  PropertySheet(���������);
}

