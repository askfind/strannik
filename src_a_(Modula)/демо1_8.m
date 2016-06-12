// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа
//Демо 8:Генератор случайных чисел
module Demo1_8;
import Win32;

const 
  INSTANCE=0x400000;

var
  СлучайноеЧисло:cardinal;
  Результат:cardinal;
  Строка:string[100];
  Выход:boolean;

procedure ИнициироватьСлучайноеЧисло();
var время:SYSTEMTIME;
begin
  GetSystemTime(время);
  СлучайноеЧисло:=
    cardinal(время.wMinute)*60000+
    cardinal(время.wSecond)*1000+
    cardinal(время.wMilliseconds);
end ИнициироватьСлучайноеЧисло;

procedure ВыдатьСлучайноеЧисло(максимум:cardinal):cardinal;
begin
  СлучайноеЧисло:=1664525*СлучайноеЧисло+1013904223;
  return СлучайноеЧисло mod максимум;
end ВыдатьСлучайноеЧисло;

begin
  ИнициироватьСлучайноеЧисло();
  Выход:=false;
  while not Выход do
    Результат:=ВыдатьСлучайноеЧисло(1000000000);
    wvsprintf(Строка,"%lu",addr(Результат));
    Выход:=MessageBox(0,Строка,"Очередное случайное число:",MB_OKCANCEL)=IDCANCEL;
  end
end Demo1_8.

