//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    3:ОПЕРАТОР SWITCH

include Win32

char s[15];

int i,j;
void main() {
  i=4;
  j=0;
//1-я альтернатива
  switch (i) {
    case 4:j=1; break;
    case 5:j=2; break;
    default:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=1",0);
//2-я альтернатива
  switch (i) {
    case 2:j=1; break;
    case 3..5:j=2; break;
    default:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=2",0);
//ELSE часть
  switch (i) {
    case 2:j=1; break;
    case 3: case 5:j=2; break;
    default:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=3",0);
//отрицательная константа
  i=-1;
  switch (i) {
    case 2:j=1; break;
    case -1:j=2; break;
    case 3:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=2",0);
}

