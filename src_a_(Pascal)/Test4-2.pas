//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    2:�������� IF
program Test4_2;
uses Win32;

var s:string[15];

var i,j:integer;
begin
  i:=4;
  j:=0;
//THEN-�����
  if i<8 then j:=1
  elsif i<8 then j:=2
  else j:=3;
  wvsprintf(s,"j=%i",addr(j));
  MessageBox(0,s,"j=1",0);
//ELSIF-�����
  if i<4 then j:=1
  elsif i<8 then j:=2
  else j:=3;
  wvsprintf(s,"j=%i",addr(j));
  MessageBox(0,s,"j=2",0);
//ELSE-�����
  if i<4 then j:=1
  elsif i<4 then j:=2
  else j:=3;
  wvsprintf(s,"j=%i",addr(j));
  MessageBox(0,s,"j=3",0);
end.

