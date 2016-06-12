//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    5:ЦИКЛ DO

include Win32

char s[15];

int i;

void main() {
  i=4;
  do
    i=i+1;
  while(i<>8);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=8",0);
}

