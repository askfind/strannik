//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 11:КЛАССЫ
//Тест номер    7:ВЫЗОВ МЕТОДА ВНУТРИ МЕТОДА

program Test11_7;
uses Win32;

type cla=object
private:
  f1:integer;
  f2:byte;
public:
  procedure pr(j:integer);
end;

procedure cla.pr(j:integer); begin f1:=j end;

type cla2=object (cla)
private:
  f3:integer;
public:
  procedure pr2(j:integer);
end;

procedure cla2.pr2(j:integer); begin self.pr(j) end;

var
  s:string[15];
  i:integer;
  v2:cla2;

begin
  new(v2);
  v2.pr2(9);
  v2.pr(9);
  wvsprintf(s,'i=%li',addr(v2.f1));
  MessageBox(0,s,'i=9',0);
end.

