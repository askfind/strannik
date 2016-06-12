//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    3:ЗАПИСЬ

include Win32

char s[15];

struct {
  int f1;
  char f2[3];
  char f3;
} rec;

void main() {
  rec.f2[0]='O';
  rec.f2[1]='k';
  rec.f2[2]='\0';
  rec.f1=0;
  lstrcpy(s,"rec.f2=");
  lstrcat(s,rec.f2);
  MessageBox(0,s,"rec.f2=Ok",0);
}

