//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    7:def-модуль
definition module Test6_7a;

const sCon="sCon";
var s:string[3];
type arrStruct=array[0..1]of record
    sfield:string[50];
    ifield:integer;
  end;
const struCon=arrStruct{{"s0",0},{"s1",1}};

type arrStruct2=array[0..1]of pstr;
const struCon2=arrStruct2{"s0","s1"};

from User32;
procedure MessageBox ascii(parent:cardinal; str,title:pstr; flags:cardinal):integer;

end Test6_7a.

