//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    7:СОПРОЦЕССОР:КОМАНДЫ ЗАГРУЗКИ-ВЫГРУЗКИ

float r;

void main() {
  asm {
//загрузка в ST0
   FLD [offs(r)];
   FILD [offs(r)];
   FBLD [offs(r)];
//выгрузка без выталкивания из стека
   FST [offs(r)];
   FIST [offs(r)];
//выгрузка с выталкиванием из стека
   FSTP [offs(r)];
   FISTP [offs(r)];
   FBSTP [offs(r)];
//команды работы со словами состояния
   FLDCW [offs(r)];
   FSTCW [offs(r)];
   FSTSW [offs(r)];
  }
}

