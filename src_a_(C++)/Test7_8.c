//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    8:СОПРОЦЕССОР:АРИФМЕТИЧЕСКИЕ КОМАНДЫ

float r;

void main() {
  asm {
//сравнения
   FCOM [offs(r)];
   FICOM [offs(r)];
   FCOMP [offs(r)];
   FICOMP [offs(r)];
   FTST;
//сложение и вычитание
   FADD [offs(r)];
   FIADD [offs(r)];
   FSUB [offs(r)];
   FISUB [offs(r)];
   FSUBR [offs(r)];
   FISUBR [offs(r)];
//умножение и деление
   FMUL [offs(r)];
   FIMUL [offs(r)];
   FDIV [offs(r)];
   FIDIV [offs(r)];
   FDIVR [offs(r)];
   FIDIVR [offs(r)];
//другие команды
   FABS;
   FCHS;
   FRNDINT;
   FXTRACT;
 }
}

