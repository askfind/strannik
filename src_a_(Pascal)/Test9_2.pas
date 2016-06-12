//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер    2:Операции с плавающей точкой
program Test9_2;
uses Win32,Win32ext;

var str:string[50]; r:real;

begin

  r:=wvscanr("1020.00455");
  wvsprintr(r,5,str);
  MessageBox(0,str,"1020.00455",0);

  r:=wvscanr("-10000020.99");
  wvsprintr(r,2,str);
  MessageBox(0,str,"-10000020.99",0);

  r:=wvscanr("-0.10000020880123452e3");
  wvsprintr(r,14,str);
  MessageBox(0,str,"-100.00020880123452",0);

  r:=wvscanr("0.1020004550002341e-22");
  wvsprinte(r,str);
  MessageBox(0,str,"0.1020004550002341e-22",0);

  r:=wvscanr("-0.1000002099000002e3");
  wvsprinte(r,str);
  MessageBox(0,str,"-0.1000002099000002e+03",0);

  wvsprintr(0.0/0.0,2,str);
  MessageBox(0,str,"0.00",0);
end.

