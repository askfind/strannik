//������ ��������-������ ��� Windows, �������� ���������
//������ ������ 6:������
//���� �����    1:������ ���������
program Test6_1;
uses Win32,Test6_1a;

var s:string[15];

var i:integer;
begin
  i:=2;
  pr(i);
  wvsprintf(addr(s),'i=%i',addr(i));
  MessageBox(0,addr(s),'i=3',0);
end.

