//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 1:��������� ������
//���� �����    6:��������� ���
program Test1_6;
uses Win32;

var s:string[15];

type typ=(t0,t1,t2,t3);
var sca:typ; i:integer;

begin
  i:=integer(t3);
  sca:=t2;
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,'i=3',0);
end.
