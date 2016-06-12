//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    11:ВЫЗОВ ФУНКЦИИ ВНУТРИ ФУНКЦИИ
program Test5_11;
uses Win32;

var s:string[15];

var i:integer;

procedure pr1(p1,p2:integer);
begin
  p1:=p2;
end;

function pr2(p1,p2:integer):integer;
begin
  p1:=p2;
  p2:=0;
end;

function pr3():integer;
begin
  MessageBox(0,"Ok","Ok",0);
  pr3:=0;
end;

begin
  pr1(8,pr2(2,pr3()));
  pr1(8,pr2(2,MessageBox(0,"Ok","Ok",0)));
end.

