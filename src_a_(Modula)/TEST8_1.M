//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА СОПРОЦЕССОРА
//Тест номер    1:АРИФМЕТИЧЕСКИЕ ОПЕРАЦИИ REAL
module Test8_1;
import Win32,Test8;

var str:string[15];

var r1,r2:real;

begin
  r1:=1.20;
  r2:=4.0;
  wvsprintr((r1+0.05)*r2/2.0,4,str);
  MessageBox(0,str,'2.5000',0);
end Test8_1.

