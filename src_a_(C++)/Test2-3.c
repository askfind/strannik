//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    3:ПЕРВИЧНОЕ NIL

include Win32

char s[15];

char* ps;

void main() {
  ps="Ok";
  ps=nil;
  wvsprintf(s,"ps=%li",&ps);
  MessageBox(0,s,"ps=0",0);
}

