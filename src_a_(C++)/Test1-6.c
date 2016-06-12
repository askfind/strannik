//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    6:СКАЛЯРНЫЙ ТИП

include Win32

char s[15];

enum typ {t0,t1,t2,t3};
typ sca; int i;

void main() {
  i=ord(t3);
  sca=t2;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=3",0);
}

