//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    6:МОДУЛЬ DLL
program Test6_6;
uses Win32,Test6_6a;

var s:string[50];

begin
  LoadLibrary("Test6_6a.dll");
  ExpProc1("ExpProc1 ok");
  ExpProc2("ExpProc2 ok");
end.

