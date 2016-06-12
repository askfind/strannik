//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    7:НОВЫЙ ТИП

include Win32

char s[15];

define con 0x0009
typedef cardinal new;

new i;

void main() {
  i=(new)con;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=9",0);
}

