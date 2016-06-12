//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    2:ОПЕРАТОР IF

module Test4_2;
import Win32;

var s:string[15];

var i,j:integer;
begin
//  if not boolean(53980)
//    then MessageBox(0,"error",nil,0);
//    else MessageBox(0,"ok",nil,0);
//  end;
  i:=4;
  j:=0;
//THEN-часть
  if i<8 then
    j:=1
  elsif i<8 then
    j:=2
  else
    j:=3
  end;
  wvsprintf(s,"j=%i",addr(j));
  MessageBox(0,s,"j=1",0);
//ELSIF-часть
  if i<4 then
    j:=1
  elsif i<8 then
    j:=2
  else
    j:=3
  end;
  wvsprintf(s,"j=%i",addr(j));
  MessageBox(0,s,"j=2",0);
//ELSE-часть
  if i<4 then
    j:=1
  elsif i<4 then
    j:=2
  else
    j:=3
  end;
  wvsprintf(s,"j=%i",addr(j));
  MessageBox(0,s,"j=3",0);
end Test4_2.

