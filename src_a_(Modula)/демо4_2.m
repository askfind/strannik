// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � �������� ����� WinInet
// ���� 2:��������� ������ ������ � FTP �����
module Demo4_2;
import Win32;

const
  ���������=1000;

var
  ��������:HINTERNET;
  ������:HINTERNET;
  �����:HINTERNET;
  ����:WIN32_FIND_DATA;
  �����:string[���������];

begin
//���������� � �����������
  InternetAttemptConnect(0);
//������������� WinInet � ������
  ��������:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if ��������=0 then MessageBox(0,"������ InternetOpen",nil,0) end;
  ������:=InternetConnect(��������,"home.perm.ru",INTERNET_DEFAULT_FTP_PORT,"strannik","",INTERNET_SERVICE_FTP,0,0);
  if ������=0 then MessageBox(0,"������ InternetConnect",nil,0) end;
//����� ������
  �����[0]:='\0';
  �����:=FtpFindFirstFile(������,"*.html",����,0,0);
  if (�����=0)and(GetLastError()<>ERROR_NO_MORE_FILES) then MessageBox(0,"������ FtpFindFirstFile",nil,0)
  else
    repeat
      lstrcat(�����,����.cFileName);
      lstrcat(�����,"\13\10");
    until not InternetFindNextFile(�����,����);
    if GetLastError()<>ERROR_NO_MORE_FILES then MessageBox(0,"������ InternetFindNextFile",nil,0) end;
  end;
//�������� WinInet, ������ � ������
  InternetCloseHandle(�����);
  InternetCloseHandle(������);
  InternetCloseHandle(��������);
  MessageBox(0,�����,"http://home.perm.ru/~strannik",0);
  ExitProcess(0)
end Demo4_2.

