//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА С ПЛАВАЮЩЕЙ ТОЧКОЙ
//Модуль вывода чисел с плавающей точкой

void wvsprintr(float r; int dest; char* s)
byte b[0..9]; float r10; int i,j,k;
{
  r10=10.0;
  asm {
   WAIT; FLD [BP+offs(r)];//загрузка числа в ST0
   MOV CX,[BP+offs(dest)];//цикл по точности
   JCXZ Пропуск;//проверка на dest=0
Цикл:
   WAIT; FMUL [BP+offs(r10)];//ST0*10
   LOOP Цикл;
Пропуск:
   WAIT; FBSTP [BP+offs(b)];
  }
//знак числа
  if(b[9]==0) s[0]=' ';
  else s[0]='-';
//значащие цифры
  k=0;
  for(i=8; i>=0; i--) {
    for(j=2; j>=1; j--) {
//десятичная точка
      if((i*2+j)==dest) {
        if(k=0) {
          k++;
          s[k]='0';
        }
        k++;
        s[k]='.';
      }
//цифра
      k++;
      if(j==1) s[k]=(char)(b[i] % 16 + (int)'0');
      else s[k]=(char)(b[i] / 16 + (int)'0');
//убрать префикс 0
      if((k==1)and(s[k]=='0')and((i*2+j)!=1))
        k=0;
    }
  }
  s[k+1]=(char)0;
}

