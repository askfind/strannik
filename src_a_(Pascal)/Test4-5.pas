//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    5:ЦИКЛ REPEAT
program Test4_5;
uses Win32;

var s:string[15];

var i:integer;

begin
  i:=4;
  repeat
    i:=i+1
  until i=8;
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,"i=8",0);
end.

