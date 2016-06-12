//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    2:ИМПОРТ КОНСТАНТ
module Test6_2;
import Win32,Test6_2a;

var s:string[15];

var i:integer;
     c:char;
begin
  i:=constInt;
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=35',0);
  c:=constChar;
  wvsprintf(s,'c=%c',addr(c));
  MessageBox(0,s,'c=Y',0);
end Test6_2.

