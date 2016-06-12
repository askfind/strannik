//Проект Странник Модула-Си-Паскаль Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    8:ТИП МНОЖЕСТВО
module Test1_8;
import Win32;

const SetRazd=['.','/','\','-','_'];

var s:string[25];

var varset:record
  case of
    |varset0:array[0..31]of byte;
    |varset1:setbyte;
    |varset2:set of char;
    |varset3:set of (s1,s2,s3);
  end;

type typeSruct=record
  f1:integer;
  f2:setbyte;
end;
const constStruct=typeSruct{10,[2,15..16]};

begin
  with varset do
  //константа-множество
    varset1:=[2,15..16];
    wvsprintf(s,"varset1[0]=%lx",addr(varset0[0]));
    MessageBox(0,s,"varset1[0]=18004",0);
    varset1:=['\2','\16','a'];
    wvsprintf(s,"varset1[0]=%lx",addr(varset0[0]));
    MessageBox(0,s,"varset1[0]=10004",0);
    varset1:=[s2];
    wvsprintf(s,"varset1[0]=%lx",addr(varset0[0]));
    MessageBox(0,s,"varset1[0]=2",0);
  //множество в структурной константе
    varset1:=constStruct.f2;
    wvsprintf(s,"constStruct.f2=%lx",addr(varset0[0]));
    MessageBox(0,s,"constStruct.f2=18004",0);
  //операция in
    varset1:=[2,16];
    if 16 in varset1
      then MessageBox(0,"in","Ok",0);
      else MessageBox(0,"in","Error",0);
    end;
    if 15 in varset1
      then MessageBox(0,"in","Error",0);
      else MessageBox(0,"in","Ok",0);
    end;
//операция множество+элемент
    varset1:=[2,16];
    varset1:=varset1+15;
    wvsprintf(s,"varset1[0]=%lx",addr(varset0[0]));
    MessageBox(0,s,"varset1[0]=18004",0);
//операция множество-элемент
    varset1:=[2,15,16];
    varset1:=varset1-15;
    wvsprintf(s,"varset1[0]=%lx",addr(varset0[0]));
    MessageBox(0,s,"varset1[0]=10004",0);
//операция множество+множество
    varset1:=[2,16];
    varset1:=varset1+[15];
    wvsprintf(s,"varset1[0]=%lx",addr(varset0[0]));
    MessageBox(0,s,"varset1[0]=18004",0);
//операция множество-множество
    varset1:=[2,15,16];
    varset1:=varset1-[15];
    wvsprintf(s,"varset1[0]=%lx",addr(varset0[0]));
    MessageBox(0,s,"varset1[0]=10004",0);
  end
end Test1_8.

