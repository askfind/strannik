//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    6:ПЕРВИЧНОЕ ADDR
module Test2_6;
import Win32;

var s:string[15];

var  rec:record
           f1:integer;
           f2:array[1..5]of integer;
           f3:string[3];
         end;
     ps:pstr;

begin
  rec.f3[0]:='O';
  rec.f3[1]:='k';
  rec.f3[2]:='\0';
  ps:=addr(rec.f3);
  wvsprintf(s,"rec.f3=%s",addr(ps));
  MessageBox(0,s,"rec.f3=Ok",0);
end Test2_6.

