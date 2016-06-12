//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    5:УКАЗАТЕЛЬ
program Test1_5;
uses Win32;

var s:string[15];

type ptyp=^typ;
        typ=record
         case f1:integer of
          1:(f2:array[0..3]of byte);
          2:(f3:integer);
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
end.

