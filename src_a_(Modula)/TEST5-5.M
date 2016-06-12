//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    5:ФУНКЦИЯ
module Test5_5;
import Win32;

var s:string;

var i:integer;

procedure pr(j:integer):integer;
begin
  return j+3;
end pr;

//procedure st(str:string):string;
//begin
//  return str;
//end st;

begin
  i:=4;
  i:=pr(i);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=7',0);
//  s:=st("sss111sss");
//  MessageBox(0,s,"sss111sss",0);
end Test5_5.

