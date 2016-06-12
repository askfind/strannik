//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    7:def-модуль
module Test6_7;
import Test6_7a;

begin
  s[0]:='0';
  s[1]:='1';
  s[2]:='2';
  s[3]:='\0';
  MessageBox(0,s,"012",0);
  MessageBox(0,sCon,"sCon",0);
  MessageBox(0,struCon[1].sfield,"s1",0);
  MessageBox(0,struCon2[1],"s1",0);
end Test6_7.

