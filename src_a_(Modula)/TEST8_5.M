//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА СОПРОЦЕССОРА
//Тест номер    5:ОПЕРАЦИИ СРАВНЕНИЯ REAL32
module Test8_5;
import Win32;

var str:string[15];

var r1:real32;

begin
  r1:=real32(1.20);
//равенство
  if r1=real32(1.2) //4000
    then MessageBox(0,'Ok','равенство true',0)
    else MessageBox(0,'Error','равенство true',0)
  end;
  if r1=real32(1.211) //0100
    then MessageBox(0,'Error','равенство false',0)
    else MessageBox(0,'Ok','равенство false',0)
  end;
//неравенство
  if r1<>real32(1.211)
    then MessageBox(0,'Ok','неравенство true',0)
    else MessageBox(0,'Error','неравенство true',0)
  end;
  if r1<>real32(1.2)
    then MessageBox(0,'Error','неравенство false',0)
    else MessageBox(0,'Ok','неравенство false',0)
  end;
//меньше
  if r1<real32(1.211) //0100
    then MessageBox(0,'Ok','меньше true',0)
    else MessageBox(0,'Error','меньше true',0)
  end;
  if r1<real32(1.1) //0000
    then MessageBox(0,'Error','меньше false',0)
    else MessageBox(0,'Ok','меньше false',0)
  end;
  if r1<real32(1.2) //4000
    then MessageBox(0,'Error','меньше false 2',0)
    else MessageBox(0,'Ok','меньше false 2',0)
  end;
//больше
  if r1>real32(1.199)
    then MessageBox(0,'Ok','больше true',0)
    else MessageBox(0,'Error','больше true',0)
  end;
  if r1>real32(1.21)
    then MessageBox(0,'Error','больше false',0)
    else MessageBox(0,'Ok','больше false',0)
  end;
  if r1>real32(1.2)
    then MessageBox(0,'Error','больше false 2',0)
    else MessageBox(0,'Ok','больше false 2',0)
  end;
//меньше или равно
  if r1<=real32(1.211) //0100
    then MessageBox(0,'Ok','меньше или равно true',0)
    else MessageBox(0,'Error','меньше или равно true',0)
  end;
  if r1<=real32(1.1) //0000
    then MessageBox(0,'Error','меньше или равно false',0)
    else MessageBox(0,'Ok','меньше или равно false',0)
  end;
  if r1<=real32(1.2) //4000
    then MessageBox(0,'Ok','меньше или равно true 2',0)
    else MessageBox(0,'Error','меньше или равно true 2',0)
  end;
//больше или равно
  if r1>=real32(1.199)
    then MessageBox(0,'Ok','больше или равно true',0)
    else MessageBox(0,'Error','больше или равно true',0)
  end;
  if r1>=real32(1.21)
    then MessageBox(0,'Error','больше или равно false',0)
    else MessageBox(0,'Ok','больше или равно false',0)
  end;
  if r1>=real32(1.2)
    then MessageBox(0,'Ok','больше или равно true 2',0)
    else MessageBox(0,'Error','больше или равно true 2',0)
  end;

end Test8_5.

