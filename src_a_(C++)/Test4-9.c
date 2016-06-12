//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    9:ОПЕРАТОРЫ INC и DEC

include Win32

char s[25];

int i;
word w1,w2;

enum scalType {s0,s1,s2,s3};
scalType scal[1..3];

void main() {
  i=12;
  i-=3;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=9",0);

  scal[1]=s1;
  scal[2]=s2;
  scal[3]=s3;

  scal[2]++;

  i=ord(scal[1]); wvsprintf(s,"scal[1]=%li",&i); MessageBox(0,s,"scal[1]=1",0);
  i=ord(scal[2]); wvsprintf(s,"scal[2]=%li",&i); MessageBox(0,s,"scal[2]=3",0);
  i=ord(scal[3]); wvsprintf(s,"scal[3]=%li",&i); MessageBox(0,s,"scal[3]=3",0);

  w1=3;
  w2=3;
  w1++5;
  w2--;
  i=(int)w1; wvsprintf(s,"w1=%li",&i); MessageBox(0,s,"w1=8",0);
  i=(int)w2; wvsprintf(s,"w2=%li",&i); MessageBox(0,s,"w2=2",0);
}

