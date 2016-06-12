//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер    3:Файловые утилиты

include Win32,Win32ext

char str[50];
int file,i;

void main()
{
  if(_fileok("test9_3.c")) MessageBox(0,"test9_3.c","Ok",0);
  else MessageBox(0,"test9_3.c","Error",0);
  if(_fileok("test9_3.cc")) MessageBox(0,"test9_3.cc","Error",0);
  else MessageBox(0,"test9_3.cc","Ok",0);
  file=_lopen("test9_3.c",0);
  i=_lsize(file);
  _lclose(file);

  wvsprintf(str,"_lsize=%li",&i);
  MessageBox(0,str,"_lsize=571",0);
}

