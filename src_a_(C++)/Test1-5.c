//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    5:УКАЗАТЕЛЬ

include Win32

char s[16];

typedef struct {
  int f1;
  union {
    {byte f2[4];}
    {int f3;}
}} typ;

typ* poi;

void main() {
  poi=GlobalLock(GlobalAlloc(0,sizeof(typ)));
  poi^.f2[0]=1;
  poi^.f2[1]=1;
  poi->f2[2]=0;
  poi->f2[3]=0;
  wvsprintf(s,"poi^.f3=%i",&(poi^.f3));
  MessageBox(0,s,"poi^.f3=257",0);
}

