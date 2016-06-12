//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 11:КЛАССЫ
//Тест номер    5:ВЫЗОВ МЕТОДА БАЗОВОГО КЛАССА

include Win32

char s[35];

class cla {
  int f1;
  byte f2;
  virtual void metCla(char* title);
}
class cla2:cla {
  int f3;
  virtual void metCla(char* title);
}
class cla3:cla2 {
  int f4;
}

void cla::metCla(char* title) {MessageBox(0,"1",title,0);}
void cla2::metCla(char* title) {MessageBox(0,"2",title,0);}

cla3 v3;

void main()
{
  v3=new cla3;
  v3.metCla("2"); //2
}

