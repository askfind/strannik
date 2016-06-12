//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 5:ПРОЦЕДУРЫ
//Тест номер    9:ПАРАМЕТР-УКАЗАТЕЛЬ
module Test5_9;
import Win32;

var s:string[15];

type 
  типЗап=record
    поле1:byte;
    поле2:integer;
  end;
  укЗап=pointer to типЗап;

var зап:типЗап; зап2:укЗап;

procedure pr(парЗап:укЗап);
begin
  wvsprintf(s,'i=%li',addr(парЗап^.поле2));
  MessageBox(0,s,'i=4',0);
end pr;

begin
  зап.поле2:=4;
  зап2:=addr(зап);
  pr(зап);
  pr(зап2);
end Test5_9.

