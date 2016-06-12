// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.9:������� PropertySheet

module Demo2_9;
import Win32;

const 
  hINSTANCE=0x400000;

  �������=200;
  �������=201;
  ����������0=202;
  ����������1=203;
  ����������2=204;

type
  �������������=(�����������,��������);
  �������������=array[�������������]of record
    ������������:pstr;
    ���������:pstr;
  end;

const �����������=�������������{
  {"�������������","DLG_1"},
  {"����� ���������","DLG_2"}};

var
  ��������:array[�������������]of PROPSHEETPAGE;
  �����:array[�������������]of HANDLE;
  ���������:PROPSHEETHEADER;
  �������:�������������;
  ������:string[100];
  �����:string[500];
  �������:integer;

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

procedure procDLG_1(wnd:HWND; message,wparam,lparam:integer):boolean;
var ����:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_NOTIFY:����:=pNMHDR(lparam);
    case ����^.code of
      PSN_SETACTIVE://��������� ��������        
        case ������� of
          0:SendDlgItemMessage(wnd,����������0,BM_SETCHECK,BST_CHECKED,0);|
          1:SendDlgItemMessage(wnd,����������1,BM_SETCHECK,BST_CHECKED,0);|
          2:SendDlgItemMessage(wnd,����������2,BM_SETCHECK,BST_CHECKED,0);|
        end;|
      PSN_KILLACTIVE:
        if IsDlgButtonChecked(wnd,����������0)=BST_CHECKED then �������:=0 end;
        if IsDlgButtonChecked(wnd,����������1)=BST_CHECKED then �������:=1 end;
        if IsDlgButtonChecked(wnd,����������2)=BST_CHECKED then �������:=2 end;|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_1;

procedure procDLG_2(wnd:HWND; message,wparam,lparam:integer):boolean;
var ����:pNMHDR;
begin
  case message of
    WM_INITDIALOG:|
    WM_COMMAND:case loword(wparam) of
      �������:MessageBox(0,"����������� ������ ������ ����� ������ � Demo2_6","������:�����",0);|
    end;|
    WM_NOTIFY:����:=pNMHDR(lparam);
    case ����^.code of
      PSN_SETACTIVE:SetDlgItemText(wnd,�������,�����);|
      PSN_KILLACTIVE:GetDlgItemText(wnd,�������,�����,500);|
    end;
    return false;|
  else return false
  end;
  return true
end procDLG_2;

//================= ������������� � ����� ��������� ====================

begin
//������������� �������
  for �������:=����������� to �������� do
  with ��������[�������] do
    RtlZeroMemory(addr(��������[�������]),sizeof(PROPSHEETPAGE));
    dwSize:=sizeof(PROPSHEETPAGE);
    dwFlags:=PSP_USETITLE;
    hInstance:=hINSTANCE;
    pszTemplate:=�����������[�������].���������;
    pszTitle:=�����������[�������].������������;
    case ������� of
      �����������:pfnDlgProc:=addr(procDLG_1);|
      ��������:pfnDlgProc:=addr(procDLG_2);|
    end;
    �����[�������]:=CreatePropertySheetPage(addr(��������[�������]));
  end end;
//������������� ���������
  with ��������� do
    RtlZeroMemory(addr(���������),sizeof(PROPSHEETHEADER));
    dwSize:=sizeof(PROPSHEETHEADER);
    dwFlags:=0;
    hwndParent:=0;
    hInstance:=hINSTANCE;
    pszCaption:="Demo2_9";
    nPages:=2;
    nStartPage:=0;
    ppsp:=addr(�����);
  end;
//����� ���������
  lstrcpy(�����,"c:\Program Files\demo2_9");
  �������:=1;
  InitCommonControls();
  PropertySheet(���������);
  wvsprintf(������,"%li",addr(�������));
  MessageBox(0,������,"������ �������:",0);
  MessageBox(0,�����,"������� �����:",0);
end Demo2_9.

