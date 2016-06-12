// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.7:������ Up-Down

program Demo2_7;
uses Win32;

const 
  hINSTANCE=0x400000;

  ����������=100;
  ����=200;

//================= ������������ updown =======================

procedure ������������UpDown(�������,��������:HWND; �������,������,���������,���:integer);
var ������:UDACCEL; ����UpDown:HWND;
begin
  InitCommonControls();
  ����UpDown:=CreateUpDownControl(WS_CHILD | WS_BORDER | WS_VISIBLE | UDS_ALIGNRIGHT | UDS_SETBUDDYINT,
    0,0,0,0,�������,0,hINSTANCE,��������,�������,������,���������);
  with ������ do begin
     nSec:=1; //����� ���������� �������
     nInc:=���; //������ ����� ���
  end;
  SendMessage(����UpDown,UDM_SETACCEL,1,integer(addr(������)));
end;

//================= ������� ������ =======================

dialog DLG_MAIN 80,39,160,37,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_7:������ Up-Down"
begin
  control "��",����,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,21,45,14
  control "",����������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,52,6,50,10
end;

//================= ���������� ������� =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:������������UpDown(wnd,GetDlgItem(wnd,����������),100,0,50,5);
    WM_COMMAND:case loword(wparam) of
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

