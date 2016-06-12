//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    8: импорт в def-модуле
definition module Test6_8b;
import Test6_8a;

from User32;
procedure MessageBox ascii(parent:HANDLE; str,title:pstr; flags:HANDLE):integer;

end Test6_8b.

