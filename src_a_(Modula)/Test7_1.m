//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    1:КЛАСС КОМАНД MD (память/регистр,пусто/регистр/данное)
module Test7_1;

var i:integer;

begin
//  i:=0;
  asm
   MOV EAX,1;
   SUB dword [offs(i)],0xE0E0E0E0;
   ADD EBX,[EBP+ESI+0x10];

   MOV AX,DS;
   MOV AX,GS;
   MOV AX,1;
   SUB word [offs(i)],0xE0E0;
   ADD BX,[EBP+ESI+0x10];
  end  
end Test7_1.
