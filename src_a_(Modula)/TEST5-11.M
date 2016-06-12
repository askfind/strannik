//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    11:ВЫЗОВ ФУНКЦИИ ВНУТРИ ФУНКЦИИ
module Test5_11;
import Win32;

var s:string[15];

var i:integer;

procedure pr1(p1,p2:integer);
begin
  p1:=p2;
end pr1;

procedure pr2(p1,p2:integer):integer;
begin
  p1:=p2;
  return(0);
end pr2;

procedure pr3():integer;
begin
  MessageBox(0,"Ok","Ok",0);
  return(0);
end pr3;

begin
  pr1(8,pr2(2,pr3()));
  pr1(8,pr2(2,MessageBox(0,"Ok","Ok",0)));
end Test5_11.

