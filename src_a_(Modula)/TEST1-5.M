//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 1:��������� ������
//���� �����    5:���������
module Test1_5;
import Win32;

var s:string[15];

type ptyp=pointer to typ;
        typ=record
          f1:integer;
         case of
          |f2:array[0..3]of byte;
          |f3:integer;
        end;

var poi:ptyp;

begin
  poi:=GlobalLock(GlobalAlloc(0,sizeof(typ)));
  poi^.f2[0]:=1;
  poi^.f2[1]:=1;
  poi^.f2[2]:=0;
  poi^.f2[3]:=0;
  wvsprintf(s,"poi^.f3=%i",addr(poi^.f3));
  MessageBox(0,s,"poi^.f3=257",0);
end Test1_5.

