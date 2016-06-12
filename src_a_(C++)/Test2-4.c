//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    4:ПЕРВИЧНОЕ TRUE

include Win32

char s[15];

boolean b1,b2;

void main() {
  b1=true;
  b2=false;
  wvsprintf(s,"b1=%i",&b1);
  MessageBox(0,s,"b1=1",0);
}

