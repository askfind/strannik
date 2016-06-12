//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 8:АРИФМЕТИКА С ПЛАВАЮЩЕЙ ТОЧКОЙ
//Модуль вывода чисел с плавающей точкой

implementation module Test8;
import Win32;

  procedure wvsprintr(r:real; dest:integer; s:pstr);
  var  b:array[0..9]of byte; r10:real; i,j,k:integer;
  begin
  //проверка на НЕ ЧИСЛО
    RtlMoveMemory(addr(b),addr(r),8);
    if ((b[7] and 0x7F)=0x7F)and((b[6] and 0xF0)=0xF0) then
      r:=0.0;
    end;
  //число в двоично-десятичный буфер
    r10:=10.0;
    asm
   WAIT; FLD [EBP+offs(r)];//загрузка числа в ST0
   MOV ECX,[EBP+offs(dest)];//цикл по точности
   JCXZ Пропуск;//проверка на dest=0
Цикл:
   WAIT; FMUL [EBP+offs(r10)];//ST0*10
   LOOP Цикл;
Пропуск:
   WAIT; FBSTP [EBP+offs(b)];
    end;
//знак числа
    if b[9]=0 
      then s[0]:=' '
      else s[0]:='-'
    end;
//значащие цифры
    k:=0;
    for i:=8 downto 0 do
      for j:=2 downto 1 do
//десятичная точка
        if (i*2+j)=dest then
          if k=0 then
            k:=k+1;
            s[k]:='0';
          end;
          k:=k+1;
          s[k]:='.';
        end;
//цифра
        k:=k+1;
        if j=1
          then s[k]:=char(b[i] mod 16 + integer('0'))
          else s[k]:=char(b[i] div 16 + integer('0'))
        end;
//убрать префикс 0
        if (k=1)and(s[k]='0')and((i*2+j)<>1) then
          k:=0;
        end
      end
    end;
    s[k+1]:=char(0)
  end wvsprintr;

end Test8.

