//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 11:КЛАССЫ
//Тест номер    4:ВИРТУАЛЬНЫЙ МЕТОД

include Win32

char s[35];

class cla {
  int f1;
  byte f2;
}
class cla2:cla {
  int f3;
}

void cla::metCla(char* title)
{
  MessageBox(0,"1",title,0);
}

void cla2::metCla(char* title)
{
  MessageBox(0,"2",title,0);
}

cla* v;
cla2* v2;

void main()
{
  v=new cla;
  v2=new cla2;
  v.metCla("1"); //1
  v=v2;
  v.metCla("2"); //2
  GlobalFree(HANDLE(v));
  GlobalFree(HANDLE(v2));
}

