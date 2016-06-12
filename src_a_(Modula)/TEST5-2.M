//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    2:ПРОЦЕДУРА С ПАРАМЕТОРОМ
module Test5_2;
import Win32;

var s:string[15];

var i:integer;

procedure pr(j:integer);
begin
  i:=i+j;
end pr;

begin
  i:=4;
  pr(3);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=7',0);
end Test5_2.

