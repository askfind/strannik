// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � �������� ����� WinInet
// ���� 2:��������� ������ ������ � FTP �����

include "Win32"

define ��������� 1000

  HINTERNET ��������;
  HINTERNET ������;
  HINTERNET �����;
  WIN32_FIND_DATA ����;
  char �����[���������];

void main() {
//���������� � �����������
  InternetAttemptConnect(0);
//������������� WinInet � ������
  ��������=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if(��������==0) MessageBox(0,"������ InternetOpen",nil,0);
  ������=InternetConnect(��������,"home.perm.ru",INTERNET_DEFAULT_FTP_PORT,"strannik","",INTERNET_SERVICE_FTP,0,0);
  if(������==0) MessageBox(0,"������ InternetConnect",nil,0);
//����� ������
  �����[0]='\0';
  �����=FtpFindFirstFile(������,"*.html",����,0,0);
  if((�����==0)and(GetLastError()!=ERROR_NO_MORE_FILES)) MessageBox(0,"������ FtpFindFirstFile",nil,0);
  else {
    do {
      lstrcat(�����,����.cFileName);
      lstrcat(�����,"\13\10");
    } while(InternetFindNextFile(�����,����));
    if(GetLastError()!=ERROR_NO_MORE_FILES) MessageBox(0,"������ InternetFindNextFile",nil,0);
  }
//�������� WinInet, ������ � ������
  InternetCloseHandle(�����);
  InternetCloseHandle(������);
  InternetCloseHandle(��������);
  MessageBox(0,�����,"http://home.perm.ru/~strannik",0);
  ExitProcess(0);
}

