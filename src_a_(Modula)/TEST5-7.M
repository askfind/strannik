//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    7:������� ��� ���������
module Test5_7;
import Win32;

var s:string[15];

var i:integer;

procedure pr(j:integer):integer;
begin
  i:=i+2;
  return j+3;
end pr;

begin
  i:=4;
  pr(i);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=6',0);
end Test5_7.

