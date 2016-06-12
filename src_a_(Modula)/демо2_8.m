// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.8:��������� ���������

module Demo2_8;
import Win32;

const 
  hINSTANCE=0x400000;

  �������=200;
  �������=201;
  �����������=202;

type
  �������������=(�������������,��������,��������);
  �������������=array[�������������]of record
    ������������:pstr;
    ���������:pstr;
    ��������:cardinal;
  end;

const �����������=�������������{
  {"����������","DLG_1",PSWIZB_NEXT},
  {"����� ���������","DLG_2",PSWIZB_BACK | PSWIZB_NEXT},
  {"���������� � ���������","DLG_3",PSWIZB_BACK | PSWIZB_FINISH}};

var
  ��������:array[�������������]of PROPSHEETPAGE;
  ���������:PROPSHEETHEADER;
  �������:�������������;
  �����:string[500];

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

procedure �����������������(wnd:HWND; ���:�������������);
begin
  case ��� of
    �������������:|
    ��������:SetDlgItemText(wnd,�������,�����);|
    ��������:SetDlgItemText(wnd,�����������,�����);|
  end
end �����������������;

procedure ���������������(wnd:HWND; ���:�������������);
begin
  case ��� of
    �������������:|
    ��������:GetDlgItemText(wnd,�������,�����,500);|
    ��������:|
  end
end ���������������;

//================= ���������� �������  =======================

procedure procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
var ����:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_COMMAND:case loword(wparam) of
      �������:MessageBox(0,"����������� ������ ������ ����� ������ � Demo2_6","������ ������ �����",0);|
    end;|
    WM_NOTIFY:����:=pNMHDR(lparam);
    case ����^.code of
      PSN_SETACTIVE://��������� ��������
        SendMessage(GetParent(wnd),PSM_SETWIZBUTTONS,0,�����������[�������].��������);
        �����������������(wnd,�������);|
      PSN_WIZBACK,PSN_WIZNEXT://����������� ��������
        ���������������(wnd,�������);
        if ����^.code=PSN_WIZBACK
          then dec(�������)
          else inc(�������)
        end;|
      PSN_WIZFINISH://����� �������
        MessageBox(0,�����,"������� �����:",0);|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_MAIN;

//================= ������������� � ����� ��������� ====================

begin
//������������� �������
  for �������:=������������� to �������� do
  with ��������[�������] do
    RtlZeroMemory(addr(��������[�������]),sizeof(PROPSHEETPAGE));
    dwSize:=sizeof(PROPSHEETPAGE);
    dwFlags:=PSP_USETITLE;
    hInstance:=hINSTANCE;
    pszTemplate:=�����������[�������].���������;
    pszTitle:=�����������[�������].������������;
    pfnDlgProc:=addr(procDLG_MAIN);
  end end;
//������������� ���������
  with ��������� do
    RtlZeroMemory(addr(���������),sizeof(PROPSHEETHEADER));
    dwSize:=sizeof(PROPSHEETHEADER);
    dwFlags:=PSH_PROPSHEETPAGE | PSH_WIZARD;
    hwndParent:=0;
    hInstance:=hINSTANCE;
    pszCaption:="Demo2_8";
    nPages:=ord(��������)+1;
    nStartPage:=0;
    ppsp:=addr(��������);
  end;
//����� ���������
  lstrcpy(�����,"c:\Program Files\demo2_8");
  InitCommonControls();
  �������:=�������������;
  PropertySheet(���������);
end Demo2_8.

