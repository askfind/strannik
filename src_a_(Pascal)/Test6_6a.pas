//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    6:МОДУЛЬ DLL
program Test6_6a;
uses Win32;

var s:string[50];

procedure ExpProc1(str:pstr);
begin
  MessageBox(0,str,"Внимание",0);
end;

procedure ExpProc2(str:pstr);
begin
  MessageBox(0,str,"Внимание",0);
end;

begin
end.

