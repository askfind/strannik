//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА СОПРОЦЕССОРА
//Тест номер    5:ПРЕОБРАЗОВАНИЯ ТИПОВ И ДРУГИЕ ФУНКЦИИ

include Win32,Test8

char str[15];

int l;
float r;

void main() {
//integer(real)
  l=(int)2.51;
  wvsprintf(str,"l=%li",&l);
  MessageBox(0,str,"l=3",0);
//real(integer)
  r=(float)20000;
  wvsprintr(r,4,str);
  MessageBox(0,str,"20000.0000",0);
//смена знака integer
  l=-20;
  wvsprintf(str,"l=%li",&l);
  MessageBox(0,str,"l=-20",0);
//смена знака real
  r=-20000.0;
  wvsprintr(r,4,str);
  MessageBox(0,str,"-20000.0000",0);
//функция trunc
  r=trunc(2.6);
  wvsprintr(r,4,str);
  MessageBox(0,str,"2.0000",0);
}

