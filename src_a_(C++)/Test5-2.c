//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    2:ПРОЦЕДУРА С ПАРАМЕТОРОМ

include Win32

char s[15];

int i;

void pr(int j) {
  i=i+j;
}

void main() {
  i=4;
  pr(3);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=7",0);
}

