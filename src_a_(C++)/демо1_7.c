// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа
// Демо 7:Работа с консолью
include Win32

define INSTANCE 0x400000

uint Длина;
char Строка[100];
HANDLE Консоль;
HANDLE Клавиатура;

void main()
{
//создаем консоль и клавиатуру
  AllocConsole();
  Консоль=GetStdHandle(STD_OUTPUT_HANDLE);
  Клавиатура=GetStdHandle(STD_INPUT_HANDLE);
//вывод строки
  lstrcpy(Строка,"Наберите строку на клавиатуре:");
  CharToOem(Строка,Строка);
  WriteConsole(Консоль,&Строка,lstrlen(Строка),&Длина,nil);
//ввод с клавиатуры
  ReadConsole(Клавиатура,&Строка,100,&Длина,nil);
  Строка[Длина]='\0';
//установка курсора в позицию 5,5
  SetConsoleCursorPosition(Консоль,(COORD)(5*0x10000+5));
//вывод набранной строки
  WriteConsole(Консоль,&Строка,lstrlen(Строка),&Длина,nil);
//вывод строки с переводом строки
  lstrcpy(Строка,"\13\10Нажмите Enter");
  CharToOem(Строка,Строка);
  WriteConsole(Консоль,&Строка,lstrlen(Строка),&Длина,nil);
//ожидание ввода с клавиатуры
  ReadConsole(Клавиатура,&Строка,100,&Длина,nil);
//освобождаем консоль
  FreeConsole();

} //Demo1_7

