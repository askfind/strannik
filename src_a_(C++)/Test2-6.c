//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    6:ПЕРВИЧНОЕ ADDR

include Win32

char s[15];

struct {
  int f1;
  int f2[1..5];
  char f3[4];
} rec;

char* ps;

void main() {
  rec.f3[0]='O';
  rec.f3[1]='k';
  rec.f3[2]='\0';
  ps=&(rec.f3);
  wvsprintf(s,"rec.f3=%s",&ps);
  MessageBox(0,s,"rec.f3=Ok",0);
}

