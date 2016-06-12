//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    2:СТРОКА СИМВОЛОВ
module Test1_2;
import Win32;

var s:string[15];
var parr:pstr;

begin
  parr:=GlobalLock(GlobalAlloc(0,80L));
  parr[0]:='1';
  parr[1]:='2';
  parr[2]:='\0';
  wvsprintf(s,"parr=%s",addr(parr));
  MessageBox(0,s,"parr=12",0);
end Test1_2.

