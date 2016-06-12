//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    2:КЛАСС КОМАНД ROL (память/регистр,1/CL/данное)
module Test7_2;

var i:integer;

begin
  asm
   ROL EAX,1;
   SHL ESI,0xA;
   RCL BL,CL;
   RCL dword [offs(i)],CL;
   SHL byte ptr [EBP+0x1011],1;

   ROL AX,1;
   SHL SI,0xA;
   RCL word [offs(i)],CL;
  end  
end Test7_2.
