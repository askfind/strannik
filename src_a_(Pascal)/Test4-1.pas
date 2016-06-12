//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    1:ОПЕРАТОР ПРИСВАИВАНИЯ
program Test4_1;
uses Win32;

var s:string[15];

var b1,b2:byte; i:integer;
begin
  b2:=8;
  b1:=1;
  i:=b2;
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,"i=8",0);
end.

