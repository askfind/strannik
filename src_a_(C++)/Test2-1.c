//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    1:ПЕРВИЧНОЕ LONGINT

include Win32

char s[15];

int li;

void main() {
  li=0x10001L;
  wvsprintf(s,'li=0x%lx',&li);
  MessageBox(0,s,'li=0x10001',0);
}

