//Проект Странник Модула-Си Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер 6:Функции с плавающей точкой

include Win32,Win32ext

char str[50]; float r;

void main()
{
//ln
  r=wvscanr("0.2");
  wvsprintr(ln(r),5,str);
  MessageBox(0,str,"-1.60944",0);
  r=wvscanr("1.2");
  wvsprintr(ln(r),5,str);
  MessageBox(0,str,"0.18232",0);
//exp
  r=wvscanr("0.2");
  wvsprintr(exp(r),5,str);
  MessageBox(0,str,"exp ?",0);
  r=wvscanr("1.2");
  wvsprintr(exp(r),5,str);
  MessageBox(0,str,"exp ?",0);
//sqrt
  r=wvscanr("4.0");
  wvsprintr(sqrt(r),5,str);
  MessageBox(0,str,"2.00000",0);
  r=wvscanr("5.0");
  wvsprintr(sqrt(r),5,str);
  MessageBox(0,str,"2.23607",0);
//sin
  r=wvscanr("0.5");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"0.47943",0);
  r=wvscanr("-0.5");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"-0.47943",0);
  r=wvscanr("1.0");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"0.84147",0);
  r=wvscanr("2.0");
  wvsprintr(sin(r),5,str);
  MessageBox(0,str,"0.90930",0);
//cos
  r=wvscanr("0.5");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"0.87758",0);
  r=wvscanr("-0.5");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"0.87758",0);
  r=wvscanr("1.0");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"0.54030",0);
  r=wvscanr("2.0");
  wvsprintr(cos(r),5,str);
  MessageBox(0,str,"-0.41615",0);
//tg
  r=wvscanr("-0.5");
  wvsprintr(tg(r),5,str);
  MessageBox(0,str,"-0.54630",0);
  r=wvscanr("1");
  wvsprintr(tg(r),5,str);
  MessageBox(0,str,"1.55741",0);
//arctg
  r=wvscanr("-0.54630");
  wvsprintr(arctg(r),5,str);
  MessageBox(0,str,"-0.50000",0);
  r=wvscanr("1.55741");
  wvsprintr(arctg(r),5,str);
  MessageBox(0,str,"1.00000",0);
}

