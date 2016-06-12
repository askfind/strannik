//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    8:СОПРОЦЕССОР:АРИФМЕТИЧЕСКИЕ КОМАНДЫ
module Test7_8;

var r:real;

begin
  asm
//сравнения
   FCOM [offs(r)];
   FCOM d [offs(r)];
   FICOM [offs(r)];
   FCOMP [offs(r)];
   FCOMP d [offs(r)];
   FICOMP [offs(r)];
   FTST;
//сложение и вычитание
   FADD [offs(r)];
   FADD d [offs(r)];
   FIADD [offs(r)];
   FSUB [offs(r)];
   FSUB dword ptr [offs(r)];
   FISUB [offs(r)];
   FSUBR [offs(r)];
   FSUBR d [offs(r)];
   FISUBR [offs(r)];
//умножение и деление
   FMUL [offs(r)];
   FMUL dword ptr [offs(r)];
   FIMUL [offs(r)];
   FDIV [offs(r)];
   FDIV d [offs(r)];
   FIDIV [offs(r)];
   FDIVR qword [offs(r)];
   FDIVR dword [offs(r)];
   FIDIVR [offs(r)];
//другие команды
   FABS;
   FCHS;
   FRNDINT;
   FXTRACT;
 end  
end Test7_8.
