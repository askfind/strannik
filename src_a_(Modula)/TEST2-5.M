//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    5:��������� SIZE
module Test2_5;
import Win32;

var s:string[15];

type rec=record
           f1:integer;
           f2:array[1..100]of integer;
         end;
var i:integer;

begin
  i:=sizeof(rec);
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,"i=404",0);
end Test2_5.
