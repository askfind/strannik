//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 6:������
//���� �����    3:������ �����
program Test6_3;
uses Win32,Test6_3a;

var s:string[15];

var i:integer;
     ����:typeArr;

begin
  ����[2].f2:=12;
  wvsprintf(s,'i=%i',addr(����[2].f2));
  MessageBox(0,s,'i=12',0);
end.

