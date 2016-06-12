//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    4:ЦИКЛ WHILE
module Test4_4;
import Win32;
var s:string[15];

var i:integer;
begin
  i:=4;
  while i<6 do
    i:=i+1
  end;
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,"i=6",0);
end Test4_4.

