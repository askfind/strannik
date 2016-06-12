//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер 6:Функции с плавающей точкой
module Test9_6;
import Win32,Win32ext;

var str:string[50]; r:real;

begin
//wvsprinte
  r:=wvscanr("0.19603211907e-24");
  wvsprinte(r,str);
  MessageBox(0,str,"wvsprinte 0.19603211907e-24",0);
//ln
  r:=wvscanr("0.2");
  wvsprintr(ln(r),5,str);
  MessageBox(0,str,"ln -1.60944",0);
  r:=wvscanr("1.2");
  wvsprintr(ln(r),5,str);
  MessageBox(0,str,"ln 0.18232",0);
//exp
  r:=wvscanr("0.2");
  wvsprintr(exp(r),5,str);
  MessageBox(0,str,"exp ?",0);
  r:=wvscanr("1.2");
  wvsprintr(exp(r),5,str);
  MessageBox(0,str,"exp ?",0);
//sqrt
  r:=wvscanr("4.0");
  wvsprintr(sqrt(r),5,str);
  MessageBox(0,str,"sqrt 2.00000",0);
  r:=wvscanr("5.0");
  wvsprintr(sqrt(r),5,str);
  MessageBox(0,str,"sqrt 2.23607",0);
//sin
  r:=wvscanr("0.5");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"sin 0.47943",0);
  r:=wvscanr("-0.5");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"sin -0.47943",0);
  r:=wvscanr("1.0");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"sin 0.84147",0);
  r:=wvscanr("2.0");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"sin 0.90930",0);
//cos
  r:=wvscanr("0.5");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"cos 0.87758",0);
  r:=wvscanr("-0.5");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"cos 0.87758",0);
  r:=wvscanr("1.0");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"cos 0.54030",0);
  r:=wvscanr("2.0");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"cos -0.41615",0);
//tg
  r:=wvscanr("-0.5");
  wvsprintr(tg(r),5,str);
  MessageBox(0,str,"tg -0.54630",0);
  r:=wvscanr("1");
  wvsprintr(tg(r),5,str);
  MessageBox(0,str,"tg 1.55741",0);
//arctg
  r:=wvscanr("-0.54630");
  wvsprintr(arctg(r),5,str);
  MessageBox(0,str,"arctg -0.50000",0);
  r:=wvscanr("1.55741");
  wvsprintr(arctg(r),5,str);
  MessageBox(0,str,"arctg 1.00000",0);
end Test9_6.

