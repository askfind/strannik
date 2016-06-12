//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 3:ВЫРАЖЕНИЕ
//Тест номер    3:БОЛЬШОЕ ВЫРАЖЕНИЕ
module Test3_3;
import Win32;

var s:string[15];

var rec1,rec2:record
                f1:array[1..10]of char;
                f2:integer;
              end;
begin
  rec1.f2:=3;
  rec2.f2:=1<<rec1.f2;
  rec1:=rec2;
  wvsprintf(s,"rec1.f2=%li",addr(rec1.f2));
  MessageBox(0,s,"rec1.f2=8",0);

  rec2.f2:=8>>2;
  rec1:=rec2;
  wvsprintf(s,"rec1.f2=%li",addr(rec1.f2));
  MessageBox(0,s,"rec1.f2=2",0);
end Test3_3.

