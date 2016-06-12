//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 11:КЛАССЫ
//Тест номер    2:КЛАСС С МЕТОДОМ

include Win32

char s[35];

class cla {
  int f1;
  byte f2;
}

void cla::setF1(int i)
{
  f1=i;
}

cla v;

void main()
{
  v=new cla;
  v.setF1(1234567);
  wvsprintf(s,'i=%li',&(v.f1));
  MessageBox(0,s,'i=1234567',0);
}

