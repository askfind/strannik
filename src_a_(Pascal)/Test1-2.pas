//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 1:��������� ������
//���� �����    2:������ ��������
program Test1_2;
uses Win32;

var s:string[15];
var parr:pstr;

begin
  parr:=GlobalLock(GlobalAlloc(0,80L));
  parr[0]:='1';
  parr[1]:='2';
  parr[2]:='\0';
  wvsprintf(s,"parr=%s",addr(parr));
  MessageBox(0,s,"parr=12",0);
end.

