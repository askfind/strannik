//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    8:ДИРЕКТИВА FROM

include Test4_8a

char s[15];

void main() {
  lstrcpy(s,"frag1 ");
  lstrcat(s,"frag2");
  MessageBox(0,s,"fraf1 frag2",0);
}

