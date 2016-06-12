//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    1:ОПЕРАТОР ПРИСВАИВАНИЯ

include Win32

char s[15];

byte b1,b2; int i;

void main() {
  b2=8;
  b1=1;
  i=b2;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=8",0);
}

