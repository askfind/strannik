//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 7:АССЕМБЛЕР
//Тест номер    5:КЛАСС КОМАНД OTHER (ввод/вывод, прерывания и call)

int i;

void main() {
  asm {
   OUT 0x12,AL;
   IN DX,AL;
Метка:
   NOP;
   INT 0x21;
   CALL Метка;
   CALL [offs(i)];
   RET;
   RET 4;
  }
}

