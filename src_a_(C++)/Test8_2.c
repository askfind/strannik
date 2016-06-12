//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА СОПРОЦЕССОРА
//Тест номер    2:ОПЕРАЦИИ СРАВНЕНИЯ REAL

include Win32

char str[15];

float r1;

void main() {
  r1=1.20;
//равенство
  if(r1==1.2) MessageBox(0,'Ok','равенство true',0);
  else MessageBox(0,'Error','равенство true',0);
  if(r1==1.211) MessageBox(0,'Error','равенство false',0);
  else MessageBox(0,'Ok','равенство false',0);
//неравенство
  if(r1!=1.211) MessageBox(0,'Ok','неравенство true',0);
  else MessageBox(0,'Error','неравенство true',0);
  if(r1!=1.2) MessageBox(0,'Error','неравенство false',0);
  else MessageBox(0,'Ok','неравенство false',0);
//меньше
  if(r1<1.211) MessageBox(0,'Ok','меньше true',0);
  else MessageBox(0,'Error','меньше true',0);
  if(r1<1.1) MessageBox(0,'Error','меньше false',0);
  else MessageBox(0,'Ok','меньше false',0);
  if(r1<1.2) MessageBox(0,'Error','меньше false 2',0);
  else MessageBox(0,'Ok','меньше false 2',0);
//больше
  if(r1>1.199) MessageBox(0,'Ok','больше true',0);
  else MessageBox(0,'Error','больше true',0);
  if(r1>1.21) MessageBox(0,'Error','больше false',0);
  else MessageBox(0,'Ok','больше false',0);
  if(r1>1.2) MessageBox(0,'Error','больше false 2',0);
  else MessageBox(0,'Ok','больше false 2',0);
//меньше или равно
  if(r1<=1.211) MessageBox(0,'Ok','меньше или равно true',0);
  else MessageBox(0,'Error','меньше или равно true',0);
  if(r1<=1.1) MessageBox(0,'Error','меньше или равно false',0);
  else MessageBox(0,'Ok','меньше или равно false',0);
  if(r1<=1.2) MessageBox(0,'Ok','меньше или равно true 2',0);
  else MessageBox(0,'Error','меньше или равно true 2',0);
//больше или равно
  if(r1>=1.199) MessageBox(0,'Ok','больше или равно true',0);
  else MessageBox(0,'Error','больше или равно true',0);
  if(r1>=1.21) MessageBox(0,'Error','больше или равно false',0);
  else MessageBox(0,'Ok','больше или равно false',0);
  if(r1>=1.2) MessageBox(0,'Ok','больше или равно true 2',0);
  else MessageBox(0,'Error','больше или равно true 2',0);
}

