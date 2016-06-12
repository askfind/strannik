//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    4:ПРОЦЕДУРА С ЛОКАЛЬНЫМИ ПЕРЕМЕННЫМИ
program Test5_4;
uses Win32;

var s:string[15];

var i:integer;

procedure pr(j:integer);
var l1,l2,l3:integer;
begin
  l2:=j;
  l1:=0;
  l3:=0;
  i:=i+l2;
end;

begin
  i:=4;
  pr(3);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=7',0);
end.

