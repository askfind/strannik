//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    9:��������-���������
program Test5_9;
uses Win32;

var s:string[15];

type 
  ������=record
    ����1:byte;
    ����2:integer;
  end;
  �����=^������;

var ���:������; ���2:�����;

procedure pr(������:�����);
begin
  wvsprintf(s,'i=%li',addr(������^.����2));
  MessageBox(0,s,'i=4',0);
end;

begin
  ���.����2:=4;
  ���2:=addr(���);
  pr(���);
  pr(���2);
end.

