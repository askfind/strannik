//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    12:����� �� ������������ ������
module Test5_12;
import Win32,Test5_12a;

procedure pr2(j:integer);
begin
  if j>0
    then pr1(j-1)
    else return
  end;
  i:=i+1
end pr2;

begin
  i:=4;
  pr1(8);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=12',0);
end Test5_12.

