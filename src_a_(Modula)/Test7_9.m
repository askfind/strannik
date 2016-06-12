--Проект Странник-Модула Для Windows 32, тестовая программа
--Группа тестов 7:АССЕМБЛЕР
--Тест номер    9:СОПРОЦЕССОР:АРИФМЕТИЧЕСКИЕ КОМАНДЫ
module Test7_9;

var sw:cardinal; r1,r2:real;

begin
  r1:=2.0;
  r2:=1.0;
  asm
   FLD [offs(r1)];
   FCOMP [offs(r2)];
   FSTSW [offs(sw)];
   AND d [offs(sw)],0x4100;
  end  
end Test7_9.
