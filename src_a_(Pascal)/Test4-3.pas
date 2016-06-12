//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    3:ОПЕРАТОР CASE
program Test4_3;
uses Win32;

var s:string[15];

var i,j:integer;
begin
  i:=4;
  j:=0;
//1-я альтернатива
  case i of
    4:j:=1;
    5:j:=2;
  else j:=3
  end;
  wvsprintf(s,"j=%li",addr(j));
  MessageBox(0,s,"j=1",0);
//2-я альтернатива
  case i of
    2:j:=1;
    3..5:j:=2;
  else j:=3
  end;
  wvsprintf(s,"j=%li",addr(j));
  MessageBox(0,s,"j=2",0);
//ELSE часть
  case i of
    2:j:=1;
    3,5:j:=2;
  else j:=3
  end;
  wvsprintf(s,"j=%li",addr(j));
  MessageBox(0,s,"j=3",0);
//отрицательная константа
  i:=-1;
  case i of
    2:j:=1;
    -1:j:=2;
    3:j:=3;
  end;
  wvsprintf(s,"j=%li",addr(j));
  MessageBox(0,s,"j=2",0);
end.

