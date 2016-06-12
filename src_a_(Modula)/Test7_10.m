//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    10:команды работы с битами
module Test7_10;

var i:integer;

begin
//  i:=0;
  asm
   BT EAX,1;
   BTC d [offs(i)],5;
   BTR [EBP+ESI+0x10],EBX;
   BTS EAX,ECX;

   BT AX,1;
   BTC word ptr [offs(i)],5;
   BTR [EBP+ESI+0x10],BX;
   BTS AX,CX;
  end  
end Test7_10.
