//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 11:КЛАССЫ
//Тест номер    1:КЛАСС БЕЗ МЕТОДА

include Win32

char s[35];

class cla {
public:
  int f1;
  byte f2;
}

cla *v;

void main()
{
  v=new cla;
  v->f1=1234567;
  wvsprintf(s,'i=%li',&(v->f1));
  MessageBox(0,s,'i=1234567',0);
  GlobalFree(HANDLE(v));
}

