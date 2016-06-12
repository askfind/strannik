//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    4:ПЕРВИЧНОЕ TRUE
module Test2_4;
import Win32;

var s:string[15];

var b1,b2:boolean;

begin
  b1:=true;
  b2:=false;
  wvsprintf(s,"b1=%i",addr(b1));
  MessageBox(0,s,"b1=1",0);
end Test2_4.
