//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    2:ОПЕРАТОР IF

include Win32

char s[15];

int i,j;
void main() {
  i=4;
  j=0;
//THEN-часть
  if(i<8) j=1;
  elsif(i<8) j=2;
  else j=3;
  wvsprintf(s,"j=%i",&j);
  MessageBox(0,s,"j=1",0);
//ELSIF-часть
  if(i<4) j=1;
  elsif(i<8) j=2;
  else j=3;
  wvsprintf(s,"j=%i",&j);
  MessageBox(0,s,"j=2",0);
//ELSE-часть
  if(i<4) j=1;
  elsif(i<4) j=2;
  else j=3;
  wvsprintf(s,"j=%i",&j);
  MessageBox(0,s,"j=3",0);
}

