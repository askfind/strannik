//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА СОПРОЦЕССОРА
//Тест номер    0:ТЕСТИРОВАНИЕ wvsprintr

include Win32,Test8

char str[15];

float r;

void main() {
  r=1.25;
  wvsprintr(r,4,str);
  MessageBox(0,str,"1.2500",0);
  r=-1.25;
  wvsprintr(r,4,str);
  MessageBox(0,str,"-1.2500",0);
  r=0.0099;
  wvsprintr(r,4,str);
  MessageBox(0,str,"0.0099",0);
  r=-0.0099;
  wvsprintr(r,4,str);
  MessageBox(0,str,"-0.0099",0);
}

