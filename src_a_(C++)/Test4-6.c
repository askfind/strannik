//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    6:ЦИКЛ FOR

include Win32

char s[15];

enum скалТип {s0,s1,s2,s3};
byte b; int i,j; unsigned int w; скалТип скал,скал2;

void main() {
//BYTE
  i=4;
  for(b=0; b<=255; b++)
    i=i+1;
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=260',0);
//INTEGER
  i=4;
  for(j=1; j<=3; j++)
    i=i+1;
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=7',0);
//INTEGER DOWN
  i=4;
  for(j=3; j>=1; j--)
    i=i+1;
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=7',0);
//DWORD
  i=4;
  for(w=0xFFFFFFF0; w<=0xFFFFFFF3; w++)
    i=i+1;
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=8',0);
//SCAL
  i=4;
  for(скал=s1; скал<=s2; скал++)
    i=i+1;
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=6',0);
//INTEGER DOWN STRONG
  i=4;
  for(j=3; j>1; j--)
    i=i+1;
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=6',0);
}

