//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 1:��������� ������
//���� �����    7:����� ���
program Test1_7;
uses Win32;

var s:string[15];

const con=0x0009;
type new=cardinal;

var i:new;

begin
  i:=new(con);
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,"i=9",0);
end.

