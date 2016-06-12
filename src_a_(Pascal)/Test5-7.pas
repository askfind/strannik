//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    7:ФУНКЦИЯ КАК ПРОЦЕДУРА
module Test5_7;
import Win32;

var s:string[15];

var i:integer;

procedure pr(j:integer):integer;
begin
  i:=i+2;
  return j+3;
end pr;

begin
  i:=4;
  pr(i);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=6',0);
end Test5_7.

