//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 9:������� Win32ext
//���� �����    5:�������� ������� indirect
module Test9_5;
import Win32,Win32ext;

const INSTANCE=0x400000;

var pDlg:address; topDlg:integer;

//================= ���������� ������� ======================

procedure procDlg(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_COMMAND:case loword(wParam) of
      IDOK:EndDialog(hWnd,1);|
      IDCANCEL:EndDialog(hWnd,0);|
    end;|
    else return(false);
  end
end procDlg;

var f:integer;

begin
  topDlg:=0;
  pDlg:=memAlloc(indMAXMEM);
  indCaption(pDlg,topDlg,
    DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_VISIBLE,
    100,100,400,300,
    nil,nil,"��������� �������");
  indItem(pDlg,topDlg,
    10,10,100,30,
    0,SS_RIGHT | WS_CHILD | WS_VISIBLE,
    "Static","������");
  indItem(pDlg,topDlg,
    10,40,100,30,
    0,SS_RIGHT | WS_CHILD | WS_VISIBLE,
    "Static","������");
//  f:=_lcreat("dlg",0);
//  _lwrite(f,pDlg,topDlg);
//  _lclose(f);
  DialogBoxIndirectParam(INSTANCE,pDlg,0,addr(procDlg),0);
  memFree(pDlg);
end Test9_5.

