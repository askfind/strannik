//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 11:КЛАССЫ
//Тест номер    6:ВЫЗОВ МЕТОДА В ПАРАМЕТРЕ

include Win32

class cla {
private:
  int f1;
  byte f2;
public:
  virtual int pr(int j);
}

char s[15];
int i;
cla v;

int cla::pr(int j)
{
  return j+3;
}

void main()
{
  v=new cla;
  i=4;
  i=v.pr(v.pr(i));
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=10',0);
}

