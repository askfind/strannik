//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер    3:Файловые утилиты
module Test9_3;
import Win32,Win32ext;

var str:string[50]; file,i:integer;

begin

  if _fileok("test9_3.m")
    then MessageBox(0,"test9_3.m","Ok",0)
    else MessageBox(0,"test9_3.m","Error",0)
  end;
  if _fileok("test9_3.mm")
    then MessageBox(0,"test9_3.mm","Error",0)
    else MessageBox(0,"test9_3.mm","Ok",0)
  end;
  file:=_lopen("test9_3.m",0);
  i:=_lsize(file);
  _lclose(file);

  wvsprintf(str,"_lsize=%li",addr(i));
  MessageBox(0,str,"_lsize=642",0);

end Test9_3.

