//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    3:��������� � ����������� VAR
program Test5_3;
uses Win32;

var s:string[15];

type recType=record
               f1:string[4];
               f2:integer;
             end;
var rec:recType;

procedure pr(j:integer; var recpar:recType);
begin
  recpar.f2:=recpar.f2+j;
end;

begin
  rec.f2:=4;
  pr(3,rec);
  wvsprintf(s,'rec.f2=%li',addr(rec.f2));
  MessageBox(0,s,'rec.f2=7',0);
end.

