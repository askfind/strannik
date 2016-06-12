//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    2:ПЕРВИЧНОЕ PCHAR

include Win32

char s[15];

char* ps;

void main() {
  ps="Ok\33";
  wvsprintf(s,"ps=%s",&ps);
  MessageBox(0,s,"ps=Ok!",0);
}

