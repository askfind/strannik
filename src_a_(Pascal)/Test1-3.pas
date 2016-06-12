//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 1:СТРУКТУРЫ ДАННЫХ
//Тест номер    3:ЗАПИСЬ
program Test1_3;
uses Win32;

var s:string[15];

var rec:record
          f1:integer;
          f2:string[2];
          f3:char;
        end;

begin
  rec.f2[0]:='O';
  rec.f2[1]:='k';
  rec.f2[2]:='\0';
  rec.f1:=0;
  lstrcpy(s,"rec.f2=");
  lstrcat(s,rec.f2);
  MessageBox(0,s,"rec.f2=Ok",0);
end.

