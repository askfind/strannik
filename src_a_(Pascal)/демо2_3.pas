// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.3:��������� Progressbar

program Demo2_3;
uses Win32;

const 
  hINSTANCE=0x400000;

  ��������=100;
  ��������=101;
  ���������=102;
  ����=200;
  �����������=1000;

//================= ������������ ��������� =======================

procedure ���������������������(�������:HWND; ��:dword);
begin
  InitCommonControls();
//�������� �������� �� 1 �� 100
  SendMessage(GetDlgItem(�������,��),PBM_SETRANGE,0,1+100*0x10000);
//��� ����� 1
  SendMessage(GetDlgItem(�������,��),PBM_SETSTEP,1,0);
//��������� �������� 50
  SendMessage(GetDlgItem(�������,��),PBM_SETPOS,50,0);
  SetDlgItemInt(�������,���������,50,true);
end;

//================= ������ �� 10 ��������� =======================

procedure �������������(�������:HWND; ��:dword);
var �������:integer;
begin
  �������:=SendMessage(GetDlgItem(�������,��),PBM_DELTAPOS,0,0);
  dec(�������,10);
  if �������<1 then �������:=1;
  SendMessage(GetDlgItem(�������,��),PBM_SETPOS,�������,0);
  SetDlgItemInt(�������,���������,�������,true);
end;

//================= ������ �� 10 ��������� =======================

procedure �������������(�������:HWND; ��:dword);
var �������:integer;
begin
  �������:=SendMessage(GetDlgItem(�������,��),PBM_DELTAPOS,0,0);
  inc(�������,10);
  if �������>100 then �������:=100;
  SendMessage(GetDlgItem(�������,��),PBM_SETPOS,�������,0);
  SetDlgItemInt(�������,���������,�������,true);
end;

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,83,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_3:��������� Progress"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,54,64,45,14
  control "������",��������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,115,8,40,12
  control "������",��������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,6,8,40,12
  control "",�����������,"msctls_progress32",WS_CHILD | WS_VISIBLE | WS_BORDER,8,28,146,14
  control "",���������,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,64,43,25,13
end;

//================= ���������� ������� =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:���������������������(wnd,�����������);
    WM_COMMAND:case loword(wparam) of
      ��������:�������������(wnd,�����������);
      ��������:�������������(wnd,�����������);
      IDOK,����:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= ����� ������� ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

