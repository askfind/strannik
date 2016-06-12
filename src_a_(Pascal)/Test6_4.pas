//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    4:ИМПОРТ ГЛОБАДЬНЫХ ПЕРЕМЕННЫХ
program Test6_4;
uses Win32,Test6_4a;

var s:string[15];

var i:integer;

begin
  Глоб:=12;
  Увеличить();
  wvsprintf(s,'i=%li',addr(Глоб));
  MessageBox(0,s,'i=13',0);
end.

