//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 2:ПЕРВИЧНОЕ
//Тест номер    2:ПЕРВИЧНОЕ PSTR
module Test2_2;
import Win32;

var s:string[50];

var ps:pstr;

begin
  ps:="Ok\33";
  wvsprintf(s,"ps=%s",addr(ps));
  MessageBox(0,s,"ps=Ok!",0);
  ps:="\Stroka1\13\10Stroka2\nStroka3";
  wvsprintf(s,"ps=%s",addr(ps));
  MessageBox(0,s,"ps=\Stroka1\13\10Stroka2\nStroka3",0);
end Test2_2.

