//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    7:ОПЕРАТОР WITH
program Test4_7;
uses Win32;

var s:string[15];

var 
  rec:record
    f1a:integer;
    f1b:record
      f2a:char;
      f2b:integer;
    end;
  end;

begin
//простой with
  rec.f1a:=4;
  with rec do
    f1a:=f1a+1;
  wvsprintf(s,'i=%li',addr(rec.f1a));
  MessageBox(0,s,'i=5',0);
//сложный with
  rec.f1a:=4;
  with rec,f1b do
    f2b:=f1a+3;
  wvsprintf(s,'i=%li',addr(rec.f1b.f2b));
  MessageBox(0,s,'i=7',0);
//вложенный with
  with rec do begin
    f1a:=4;
    with f1b do
      f2b:=f1a+2;
  end;
  wvsprintf(s,'i=%li',addr(rec.f1b.f2b));
  MessageBox(0,s,'i=6',0);
end.

