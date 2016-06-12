//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    9:ОПЕРАТОРЫ INC и DEC
module Test4_9;
import Win32;

var s:string[25];

var i:integer;
var w1,w2:word;

type scalType=(s0,s1,s2,s3);
var scal:array[1..3]of scalType;

begin
  i:=12;
  dec(i,3);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=9',0);

  scal[1]:=s1;
  scal[2]:=s2;
  scal[3]:=s3;

  inc(scal[2]);

  i:=integer(scal[1]); wvsprintf(s,'scal[1]=%li',addr(i)); MessageBox(0,s,'scal[1]=1',0);
  i:=integer(scal[2]); wvsprintf(s,'scal[2]=%li',addr(i)); MessageBox(0,s,'scal[2]=3',0);
  i:=integer(scal[3]); wvsprintf(s,'scal[3]=%li',addr(i)); MessageBox(0,s,'scal[3]=3',0);

  w1:=3;
  w2:=3;
  inc(w1,5);
  dec(w2);
  i:=integer(w1); wvsprintf(s,'w1=%li',addr(i)); MessageBox(0,s,'w1=8',0);
  i:=integer(w2); wvsprintf(s,'w2=%li',addr(i)); MessageBox(0,s,'w2=2',0);
end Test4_9.

