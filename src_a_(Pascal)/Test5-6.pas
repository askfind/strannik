//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    6:������� � ���������
program Test5_6;
uses Win32;

var s:string[15];

var i:integer;

function pr(j:integer):integer;
begin
  pr:=j+3;
end;

begin
  i:=4;
  i:=pr(pr(i));
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=10',0);
end.

