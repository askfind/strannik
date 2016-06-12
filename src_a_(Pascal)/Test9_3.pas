//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер    3:Файловые утилиты
program Test9_3;
uses Win32,Win32ext;

var str:string[50]; file,i:integer;

begin

  if _fileok("test9_3.pas")
    then MessageBox(0,"test9_3.pas","Ok",0)
    else MessageBox(0,"test9_3.pas","Error",0);
  if _fileok("test9_3.pp")
    then MessageBox(0,"test9_3.pp","Error",0)
    else MessageBox(0,"test9_3.pp","Ok",0);
  file:=_lopen("test9_3.pas",0);
  i:=_lsize(file);
  _lclose(file);

  wvsprintf(str,"_lsize=%li",addr(i));
  MessageBox(0,str,"_lsize=627",0);
//  ExitProcess(0)
end.

