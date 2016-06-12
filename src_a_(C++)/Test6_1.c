//Проект Странник-Модула Для Windows, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    1:ИМПОРТ ПРОЦЕДУРЫ

include Win32,Test6_1a

char s[15];

int i;
void main() {
  i=2;
  pr(i);
  wvsprintf(s,"i=%i",&i);
  MessageBox(0,s,"i=3",0);
}

