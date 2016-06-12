// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � �������� ����� WinInet
// ���� 3:����������� �������
program Demo4_3;
uses Win32;

const
  hINSTANCE=0x400000;
  ��������=200000;

//������ ����� � �����
function ������������Url(url:pstr; �����:pstr; ����:integer):integer;
var
  ��������:HINTERNET;
  ����:HINTERNET;
  ����������:integer;
  ������:integer;
  ������:integer;
  ���������:boolean;
begin
  ��������:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0); if ��������=0 then return 1;
  ����:= InternetOpenUrl(��������,url,nil,0,0,0); if ����=0 then begin InternetCloseHandle(��������); return 2 end;
  ������:=0;
  repeat
    if ������+500>����
      then ������:=����-������
      else ������:=500;
    ���������:=InternetReadFile(����,addr(�����[������]),������,addr(����������));
    inc(������,����������)
  until not ��������� or(������>=����)or(����������=0);
  �����[������]:='\0';
  InternetCloseHandle(����);
  InternetCloseHandle(��������);
  if not ���������
    then return 3 //������ InternetReadFile
    else return 0 //�������� ����������
end;

//������ ��������
const
  idUrl=100;
  idGo=101;
  idHtml=102;

dialog DLG 41,30,404,250,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "����4_3"
begin
  control "",idUrl,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,6,336,15
  control "���������",idGo,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,346,6,50,16
  control "",idHtml,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_HSCROLL | WS_VSCROLL,6,23,390,224
end;

//���������� ������� ��������
function procDLG(wnd:HWND; message,wparam,lparam:integer):boolean;
var �����:pstr; url:string[500];
begin
  case message of
    WM_INITDIALOG:begin
      SetDlgItemText(wnd,idUrl,"http://gazeta.ru/index.shtml");
      SendDlgItemMessage(wnd,idHtml,EM_EXLIMITTEXT,0,��������) end;
    WM_COMMAND:case loword(wparam) of
      idGo:if hiword(wparam)=BN_CLICKED then begin
        �����:=address(GlobalAlloc(0,��������));
        GetDlgItemText(wnd,idUrl,url,500);
        case ������������Url(url,�����,��������) of
          0:SetDlgItemText(wnd,idHtml,�����);
          1:MessageBox(wnd,"������ InternetOpen",nil,0);
          2:MessageBox(wnd,"������ InternetOpenUrl",nil,0);
          3:MessageBox(wnd,"������ InternetReadFile",nil,0);
        end;
        GlobalFree(HANDLE(�����));
      end;
      IDOK:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
  else return false
  end;
  return true
end;

begin
  InternetAttemptConnect(0);
  DialogBoxParam(hINSTANCE,"DLG",0,addr(procDLG),0);
  ExitProcess(0)
end.

