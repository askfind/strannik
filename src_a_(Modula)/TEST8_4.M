//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА СОПРОЦЕССОРА
//Тест номер    4:АРИФМЕТИЧЕСКИЕ ОПЕРАЦИИ REAL32
module Test8_4;
import Win32,Test8;

var str:string[500];

var r1,r2:real32;

begin
  r1:=real32(1.20);
  r2:=real32(4.0);
  wvsprintr(real((r1+real32(0.05))*r2/real32(2.0)),4,str);
  MessageBox(0,str,'2.5000',0);
end Test8_4.

