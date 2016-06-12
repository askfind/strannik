//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    4:ЦИКЛ WHILE

include Win32
char s[15];

int i;
void main() {
  i=4;
  while(i<6)
    i=i+1;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=6",0);
}

