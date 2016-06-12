//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    5:ПЕРВИЧНОЕ SIZEOF

include Win32

char s[15];

typedef struct {
           int f1;
           int f2[1..100];
         } rec;
int i;

void main() {
  i=sizeof(rec);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=404",0);
}

