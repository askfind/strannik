//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    7:СОПРОЦЕССОР:КОМАНДЫ ЗАГРУЗКИ-ВЫГРУЗКИ
module Test7_7;

var r:real;

begin
  asm
//загрузка в ST0
   FLD [offs(r)];
   FLD  d [offs(r)];
   FILD [offs(r)];
   FBLD [offs(r)];
//выгрузка без выталкивания из стека
   FST [offs(r)];
   FST d [offs(r)];
   FIST [offs(r)];
//выгрузка с выталкиванием из стека
   FSTP [offs(r)];
   FSTP d [offs(r)];
   FISTP [offs(r)];
   FBSTP [offs(r)];
//команды работы со словами состояния
   FLDCW [offs(r)];
   FSTCW [offs(r)];
   FSTSW [offs(r)];
  end  
end Test7_7.
