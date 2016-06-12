//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    3:ИМПОРТ ТИПОВ
module Test6_3;
import Win32,Test6_3a;

var s:string[15];

var i:integer;
     масс:typeArr;

begin
  масс[2].f2:=12;
  wvsprintf(s,'i=%i',addr(масс[2].f2));
  MessageBox(0,s,'i=12',0);
end Test6_3.

