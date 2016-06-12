//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    1:ПРОСТАЯ ПРОЦЕДУРА

include Win32

char s[15];

int i;

void pr() {
  i=i+3;
}

void main() {
  i=4;
  pr();
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=7",0);
}

