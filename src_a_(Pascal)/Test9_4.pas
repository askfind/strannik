//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер    4:Аналоги MessageBox
program Test9_4;
uses Win32,Win32ext;

begin

  mbS("Ok");
  mbI(-305,"-305");
  mbX(0xFFF01112,"0XFFF01112");
  mbR(-300000012.12,"-300000012.12",2);

end.

