// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � �������� ����� WinInet
// ���� 3:����������� �������

include "Win32"

define hINSTANCE 0x400000
define �������� 200000

//������ ����� � �����
int ������������Url(char* url, char* �����, int ����) {
  HINTERNET ��������;
  HINTERNET ����;
  int ����������;
  int ������;
  int ������;
  bool ���������;

  ��������=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0); if(��������==0) return 1;
  ����= InternetOpenUrl(��������,url,nil,0,0,0); if(����==0) {InternetCloseHandle(��������); return 2;}
  ������=0;
  do {
    if(������+500>����) ������=����-������;
    else ������=500;
    ���������=InternetReadFile(����,&(�����[������]),������,&����������);
    ������++����������;
  } while(��������� &&(������<����)&&(����������!=0));
  �����[������]='\0';
  InternetCloseHandle(����);
  InternetCloseHandle(��������);
  if(~���������) return 3; //������ InternetReadFile
  else return 0; //�������� ����������
} //������������Url

//������ ��������
define idUrl 100
define idGo 101
define idHtml 102

dialog DLG 41,30,404,250,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "����4_3"
begin
  control "",idUrl,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,6,336,15
  control "���������",idGo,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,346,6,50,16
  control "",idHtml,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_HSCROLL | WS_VSCROLL,6,23,390,224
end;

//���������� ������� ��������
bool procDLG(HWND wnd, int message, int wparam, int lparam) {
char* �����; char url[500];

  switch(message) {
    case WM_INITDIALOG:
      SetDlgItemText(wnd,idUrl,"http://gazeta.ru/index.shtml");
      SendDlgItemMessage(wnd,idHtml,EM_EXLIMITTEXT,0,��������);
    break;
    case WM_COMMAND:switch(loword(wparam)) {
      case idGo:if(hiword(wparam)==BN_CLICKED) {
        �����=(char*)GlobalAlloc(0,��������);
        GetDlgItemText(wnd,idUrl,url,500);
        switch(������������Url(url,�����,��������)) {
          case 0:SetDlgItemText(wnd,idHtml,�����); break;
          case 1:MessageBox(wnd,"������ InternetOpen",nil,0); break;
          case 2:MessageBox(wnd,"������ InternetOpenUrl",nil,0); break;
          case 3:MessageBox(wnd,"������ InternetReadFile",nil,0); break;
        }
        GlobalFree(HANDLE(�����));
      } break;
      case IDOK:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
  default:return false; break;
  }
  return true;
} //procDLG;

void main() {
  InternetAttemptConnect(0);
  DialogBoxParam(hINSTANCE,"DLG",0,addr(procDLG),0);
  ExitProcess(0);
}

