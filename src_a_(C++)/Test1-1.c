//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    1:МАССИВ
include Win32

char s[15];
int arr[1..3];

void main() {
  arr[1]=1;
  arr[2]=2;
  arr[3]=3;
  wvsprintf(s,"arr[2]=%li",&(arr[2]));
  MessageBox(0,s,"arr[2]=2",0);
}

