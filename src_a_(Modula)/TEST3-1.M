//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 3:ВЫРАЖЕНИЕ
//Тест номер    1:ЦЕЛОЧИСЛЕННОЕ ВЫРАЖЕНИЕ
module Test3_1;
import Win32;

var s:string[15];

var i,j,k:integer;

begin
  i:=0x80;
  j:=-2;
  k:=10*(i+j) div 10+2;
  wvsprintf(s,"k=%li",addr(k));
  MessageBox(0,s,"k=128",0);
end Test3_1.
