//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    7:ФУНКЦИЯ КАК ПРОЦЕДУРА

include Win32

char s[15];

int i;

int pr(int j) {
  i=i+2;
  return(j+3);
}

void main() {
  i=4;
  pr(i);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=6",0);
}

