//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер    1:Строковые утилиты

include Win32,Win32ext

char str[50],buf[50];
int i;

void main()
{
  lstrcpy(str,"0123456789");
  lstrcatc(str,'c');
  MessageBox(0,str,"0123456789c",0);

  lstrcpy(str,"0123456789");
  i=lstrposc('2',str);
  wvsprintf(buf,"i=%li",&i);
  MessageBox(0,buf,"i=2",0);

  lstrcpy(str,"0123456789");
  i=lstrpos("34",str);
  wvsprintf(buf,"i=%li",&i);
  MessageBox(0,buf,"i=3",0);

  lstrcpy(str,"0123 123 123");
  i=lstrposi("23",str,3);
  wvsprintf(buf,"i=%li",&i);
  MessageBox(0,buf,"i=6",0);

  lstrcpy(str,"0123456789");
  lstrdel(str,2,4);
  MessageBox(0,str,"016789",0);

  lstrcpy(str,"0123456789");
  lstrinsc('c',str,4);
  MessageBox(0,str,"0123c456789",0);

  lstrcpy(str,"0123456789");
  lstrins("abc",str,4);
  MessageBox(0,str,"0123abc456789",0);
}

