// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � �������� ����� WinInet
// ���� 1:��������� ������ HTML-�������� � �����
program Demo4_1;
uses Win32;

const
  ���������=1000;

var
  ��������:HINTERNET;
  ����:HINTERNET;
  ���������:boolean;
  ����������:integer;
  �����:string[���������];

begin
//������������� WinInet � �����
  ��������:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if ��������=0 then MessageBox(0,"������ InternetOpen",nil,0);
  ����:= InternetOpenUrl(��������,"http://home.perm.ru/~strannik/index.html",nil,0,0,0);
  if ����=0 then MessageBox(0,"������ InternetOpenUrl",nil,0);
//������ ����� � �����
  ���������:=InternetReadFile(����,addr(�����),���������,addr(����������));
  �����[����������]:='\0';
//�������� WinInet � �����
  InternetCloseHandle(����);
  InternetCloseHandle(��������);
  MessageBox(0,�����,"http://home.perm.ru/~strannik/index.html",0);
  ExitProcess(0)
end.


