--Проект Странник-Модула Для Windows 32, тестовая программа
--Группа тестов 7:АССЕМБЛЕР
--Тест номер    6:КЛАСС КОМАНД NULL (без параметров)
module Test7_6;

var i:integer;

begin
  asm
   REP STOS;
   ENTER;
  end  
end Test7_6.
