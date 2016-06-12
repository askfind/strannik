//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    7:СТРУКТУРНАЯ КОНСТАНТА
module Test2_7;
import Win32;

var s:string[15];

type 
  ЗапТип=record
    f1:char;
    f2:integer;
    f3:pstr;
    f4:string[10];
  end;
  СтруктТип=array[1..3]of ЗапТип;

const Структ=СтруктТип{
  {'a',1,"s1","ss1"},
  {,2,"s2","ss2"},
  {'c',3,"s3","ss3"}
};

procedure Проц(пар:ЗапТип);
begin
  MessageBox(0,пар.f3,'s4',0);
end Проц;

begin
  wvsprintf(s,"f2=%li",addr(Структ[2].f2));
  MessageBox(0,s,"f2=2",0);

  MessageBox(0,Структ[2].f3,'s2',0);
  MessageBox(0,Структ[2].f4,'ss2',0);

  Структ[2]:=ЗапТип{'d',4,"s4",};
  MessageBox(0,Структ[2].f3,'s4',0);

  Проц(ЗапТип{'d',4,"s4",});
end Test2_7.

