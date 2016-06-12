//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    7:ОПЕРАТОР WITH

include Win32

char s[15];

struct {
  int f1a;
  struct {
    char f2a;
    int f2b;
  } f1b;
} rec;

void main() {
//простой with
  rec.f1a=4;
  with(rec) {
    f1a=f1a+1;
  }
  wvsprintf(s,"i=%li",&(rec.f1a));
  MessageBox(0,s,"i=5",0);
//сложный with
  rec.f1a=4;
  with(rec,f1b) {
    f2b=f1a+3;
  }
  wvsprintf(s,"i=%li",&(rec.f1b.f2b));
  MessageBox(0,s,"i=7",0);
//вложенный with
  with(rec) {
    f1a=4;
    with(f1b) {
      f2b=f1a+2;
    }
  }
  wvsprintf(s,"i=%li",&(rec.f1b.f2b));
  MessageBox(0,s,"i=6",0);
}

