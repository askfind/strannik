//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    6:СКАЛЯРНЫЙ ТИП
module Test1_6;
import Win32;

var s:string[15];

type typ=(t0,t1,t2,t3);
var sca:typ; i:integer;

begin
  i:=integer(t3);
  sca:=t2;
  wvsprintf(s,"i=%li",addr(i));
  MessageBox(0,s,'i=3',0);
end Test1_6.
