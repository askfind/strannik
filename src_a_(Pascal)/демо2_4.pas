// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.4:������ Trackbar

program Demo2_4;
uses Win32;

const 
  hINSTANCE=0x400000;

  ���������=102;
  ����=200;
  ��������=1000;

//================= ������������ ������ =======================

procedure ������������������(�������:HWND; ��:dword);
begin
  InitCommonControls();
//�������� �������� �� 1 �� 100
  SendMessage(GetDlgItem(�������,��),TBM_SETRANGE,integer(true),1+100*0x10000);
//������ ��� ����� 10
  SendMessage(GetDlgItem(�������,��),TBM_SETPAGESIZE,0,10);
//������ ��� ����� 1
  SendMessage(GetDlgItem(�������,��),TBM_SETLINESIZE,0,1);
//��������� �������� 50
  SendMessage(GetDlgItem(�������,��),TBM_SETPOS,integer(true),50);
  SetDlgItemInt(�������,���������,50,true);
end;

//================= ��������� ��������� �� ���� =======================

procedure ���������������������������(�������:HWND; ��:dword; wparam:dword);
var �������:integer;
begin
  case loword(wparam) of
    SB_THUMBTRACK:begin
      �������:=hiword(wparam);
      SetDlgItemInt(�������,���������,�������,true);
    end;
  end;
end;

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_4:������ Trackbar"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "",���������,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,65,30,25,13
  control "",��������,"msctls_trackbar32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TBS_HORZ | TBS_BOTTOM,5,4,150,20
end;

//================= ���������� ������� =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:������������������(wnd,��������);
    WM_COMMAND:case loword(wparam) of
      IDOK,����:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
    WM_HSCROLL:���������������������������(wnd,��������,wparam);
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= ����� ������� ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

