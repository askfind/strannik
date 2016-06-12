//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    8:ДИРЕКТИВА FROM (def-модуль)

definition unit Test4_8a;

from Kernel32;
  procedure lstrcpy ascii(s1,s2:pstr);
  procedure lstrcat ascii(s1,s2:pstr);

from User32;
  procedure MessageBox ascii(wnd:cardinal; mess,title:pstr; flags:cardinal);
  procedure wvsprintf ascii(buf,form:pstr; par:address);

end.

