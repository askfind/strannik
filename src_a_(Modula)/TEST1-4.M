//Проект Странник Модула-Си-Паскаль Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    4:ЗАПИСЬ С ВАРИАНТНОЙ ЧАСТЬЮ
module Test1_4;
import Win32;

var s:string[15];

var rec:record
          f1:integer;
        case f0:cardinal of
          |0,1,2:f2:array[0..3]of byte;
          |3:f3:integer;
        end;

begin
  rec.f2[0]:=1;
  rec.f2[1]:=1;
  rec.f1:=0;
  rec.f0:=1;
  wvsprintf(s,"rec.f3=%i",addr(rec.f3));
  MessageBox(0,s,"rec.f3=257",0);
  wvsprintf(s,"rec.f0=%i",addr(rec.f0));
  MessageBox(0,s,"rec.f0=1",0);
  wvsprintf(s,"rec.f1=%i",addr(rec.f1));
  MessageBox(0,s,"rec.f1=0",0);
end Test1_4.

