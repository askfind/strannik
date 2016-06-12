//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    3:КЛАСС КОМАНД M (память/регистр)
module Test7_3;

var i:integer;

begin
  asm
   MUL EBX;
   INC dword [offs(i)];
   POP ESI;
   CALL [EBP+0x1011];
   CALL ESI;

   MUL BX;
   INC word [offs(i)];
  end  
end Test7_3.
