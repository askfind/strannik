//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    8:������ ��������
program Test5_8;
uses Win32;

var s:string[15];

var i:integer;

procedure pr(j:integer);
begin
  if j>0
    then pr(j-1)
    else exit;
  i:=i+1
end;

begin
  i:=4;
  pr(8);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=12',0);
end.

