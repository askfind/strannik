// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � �������� ����� WinInet
// ���� 1:��������� ������ HTML-�������� � �����

include "Win32"

define ��������� 1000

  HINTERNET ��������;
  HINTERNET ����;
  bool ���������;
  int ����������;
  char �����[���������];

void main() {
//������������� WinInet � �����
  ��������=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if(��������==0) MessageBox(0,"������ InternetOpen",nil,0);
  ����= InternetOpenUrl(��������,"http://home.perm.ru/~strannik/index.html",nil,0,0,0);
  if(����==0) MessageBox(0,"������ InternetOpenUrl",nil,0);
//������ ����� � �����
  ���������=InternetReadFile(����,&�����,���������,&����������);
  �����[����������]='\0';
//�������� WinInet � �����
  InternetCloseHandle(����);
  InternetCloseHandle(��������);
  MessageBox(0,�����,"http://home.perm.ru/~strannik/index.html",0);
  ExitProcess(0);
}

