// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа
//Демо 8:Генератор случайных чисел
program Demo1_8;
uses Win32;

const 
  INSTANCE=0x400000;

var
  СлучайноеЧисло:dword;
  Результат:dword;
  Строка:string[100];
  Выход:boolean;

procedure ИнициироватьСлучайноеЧисло();
var время:SYSTEMTIME;
begin
  GetSystemTime(время);
  СлучайноеЧисло:=
    dword(время.wMinute)*60000+
    dword(время.wSecond)*1000+
    dword(время.wMilliseconds);
end;

function ВыдатьСлучайноеЧисло(максимум:dword):dword;
begin
  СлучайноеЧисло:=1664525*СлучайноеЧисло+1013904223;
  ВыдатьСлучайноеЧисло:=СлучайноеЧисло mod максимум;
end;

begin
  ИнициироватьСлучайноеЧисло();
  Выход:=false;
  while not Выход do begin
    Результат:=ВыдатьСлучайноеЧисло(1000000000);
    wvsprintf(Строка,"%lu",addr(Результат));
    Выход:=MessageBox(0,Строка,"Очередное случайное число:",MB_OKCANCEL)=IDCANCEL;
  end
end.

