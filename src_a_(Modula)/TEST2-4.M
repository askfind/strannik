//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    4:��������� TRUE
module Test2_4;
import Win32;

var s:string[15];

var b1,b2:boolean;

begin
  b1:=true;
  b2:=false;
  wvsprintf(s,"b1=%i",addr(b1));
  MessageBox(0,s,"b1=1",0);
end Test2_4.
