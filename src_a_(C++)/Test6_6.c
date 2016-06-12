//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    6:МОДУЛЬ DLL

include Win32
include Test6_6a

char s[50];

void main()
{
  LoadLibrary("Test6_6a.dll");
  ExpProc1("ExpProc1 ok");
  ExpProc2("ExpProc2 ok");
}

