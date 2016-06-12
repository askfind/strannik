//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    3:ИМПОРТ ТИПОВ

include Win32,Test6_3a

char s[15];

int i;
typeArr масс;

void main() {
  масс[2].f2=12;
  wvsprintf(s,"i=%i",&(масс[2].f2));
  MessageBox(0,s,"i=12",0);
}

