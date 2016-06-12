//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    6:ФУНКЦИЯ В ПАРАМЕТРЕ

include Win32

char s[15];

int i;

int pr(int j) {
  return(j+3);
}

void main() {
  i=4;
  i=pr(pr(i));
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=10",0);
}

