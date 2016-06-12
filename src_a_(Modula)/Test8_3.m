//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА СОПРОЦЕССОРА
//Тест номер    3:ПРЕОБРАЗОВАНИЯ ТИПОВ И ДРУГИЕ ФУНКЦИИ
module Test8_3;
import Win32,Test8;

var str:string[15];

var l:integer; r:real; r32:real32;

begin
//integer(real)
  l:=integer(2.51);
  wvsprintf(str,"l=%li",addr(l));
  MessageBox(0,str,'l=3',0);
//real(integer)
  r:=real(20000);
  wvsprintr(r,4,str);
  MessageBox(0,str,'20000.0000',0);
//integer(real32)
  r32:=real32(2.51);
  l:=integer(r32);
  wvsprintf(str,"l=%li",addr(l));
  MessageBox(0,str,'l=3',0);
//real32(integer)
  r32:=real32(20000);
  wvsprintr(real(r32),4,str);
  MessageBox(0,str,'20000.0000',0);
//смена знака integer
  l:=-20;
  wvsprintf(str,"l=%li",addr(l));
  MessageBox(0,str,'l=-20',0);
//смена знака real
  r:=-20000.0;
  wvsprintr(r,4,str);
  MessageBox(0,str,'-20000.0000',0);
//смена знака real32
  r32:=-real32(20000.0);
  wvsprintr(real(r32),4,str);
  MessageBox(0,str,'-20000.0000',0);
//функция trunc(real)
  r:=trunc(2.6);
  wvsprintr(r,4,str);
  MessageBox(0,str,'2.0000',0);
end Test8_3.

