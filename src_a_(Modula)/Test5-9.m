//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    9:��������-���������
module Test5_9;
import Win32;

var s:string[15];

type 
  ������=record
    ����1:byte;
    ����2:integer;
  end;
  �����=pointer to ������;

var ���:������; ���2:�����;

procedure pr(������:�����);
begin
  wvsprintf(s,'i=%li',addr(������^.����2));
  MessageBox(0,s,'i=4',0);
end pr;

begin
  ���.����2:=4;
  ���2:=addr(���);
  pr(���);
  pr(���2);
end Test5_9.

