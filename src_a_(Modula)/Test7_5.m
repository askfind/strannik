//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    5:КЛАСС КОМАНД OTHER (ввод/вывод, прерывания и call)
module Test7_5;

var i:integer;

begin
  asm
   OUT 0x12,AL;
   OUT DX,AL;
   IN AL,DX;
Метка:
   NOP;
   INT 0x21;
   CALL Метка;
   CALL [offs(i)];
   RET;
   RET 4;
  end  
end Test7_5.
