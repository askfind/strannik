//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    9:СОПРОЦЕССОР:АРИФМЕТИЧЕСКИЕ КОМАНДЫ

unsigned int sw;
float r1,r2;

void main() {
  r1=2.0;
  r2=1.0;
  asm {
   FLD [offs(r1)];
   FCOMP [offs(r2)];
   FSTSW [offs(sw)];
   AND d [offs(sw)],0x4100;
  }
}

