//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    5:�������
program Test5_5;
uses Win32;

var s:string[15];

var i:integer;

function pr(j:integer):integer;
begin
  pr:=j+3;
end;

begin
  i:=4;
  i:=pr(i);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=7',0);
end.

