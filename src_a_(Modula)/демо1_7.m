// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа
//Демо 7:Работа с консолью
module Demo1_7;
import Win32;

const 
  INSTANCE=0x400000;

var
  Длина:cardinal;
  Строка:string[100];
  Консоль:HANDLE;
  Клавиатура:HANDLE;

begin
//создаем консоль и клавиатуру
  AllocConsole();
  Консоль:=GetStdHandle(STD_OUTPUT_HANDLE);
  Клавиатура:=GetStdHandle(STD_INPUT_HANDLE);
//вывод строки
  lstrcpy(Строка,"Наберите строку на клавиатуре:");
  CharToOem(Строка,Строка);
  WriteConsole(Консоль,addr(Строка),lstrlen(Строка),addr(Длина),nil);
//ввод с клавиатуры
  ReadConsole(Клавиатура,addr(Строка),100,addr(Длина),nil);
  Строка[Длина]:='\0';
//установка курсора в позицию 5,5
  SetConsoleCursorPosition(Консоль,COORD(5*0x10000+5));
//вывод набранной строки
  WriteConsole(Консоль,addr(Строка),lstrlen(Строка),addr(Длина),nil);
//вывод строки с переводом строки
  lstrcpy(Строка,"\13\10Нажмите Enter");
  CharToOem(Строка,Строка);
  WriteConsole(Консоль,addr(Строка),lstrlen(Строка),addr(Длина),nil);
//ожидание ввода с клавиатуры
  ReadConsole(Клавиатура,addr(Строка),100,addr(Длина),nil);
//освобождаем консоль
  FreeConsole();

end Demo1_7.

