//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 6:������
//���� �����    4:������ ���������� ����������
program Test6_4;
uses Win32,Test6_4a;

var s:string[15];

var i:integer;

begin
  ����:=12;
  ���������();
  wvsprintf(s,'i=%li',addr(����));
  MessageBox(0,s,'i=13',0);
end.

