//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    2:СТРОКА СИМВОЛОВ
include Win32

char s[15];
char* parr;

void main() {
  parr=GlobalLock(GlobalAlloc(0,80));
  parr[0]='1';
  parr[1]='2';
  parr[2]='\0';
  wvsprintf(s,"parr=%s",&parr);
  MessageBox(0,s,"parr=12",0);
}

