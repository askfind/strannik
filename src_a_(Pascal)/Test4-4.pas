//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    4:���� WHILE
program Test4_4;
uses Win32;
var s:string[15];

var i:integer;
begin
  i:=4;
  while i<6 do
    i:=i+1;
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,"i=6",0);
end.

