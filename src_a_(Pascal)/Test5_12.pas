//������ �������� ������-��-������� ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    12:����� �� ������������ ������
program Test5_12;
uses Win32,Test5_12a;

procedure pr2(j:integer);
begin
  if j>0
    then pr1(j-1)
    else exit;
  i:=i+1
end;

begin
  i:=4;
  pr1(8);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=12',0);
end.

