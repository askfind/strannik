//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 4:ОПЕРАТОРЫ
//Тест номер    8:ДИРЕКТИВА FROM
program Test4_8;
uses Test4_8a;

var s:string[15];

begin
  lstrcpy(s,'frag1 ');
  lstrcat(s,'frag2');
  MessageBox(0,s,'fraf1 frag2',0);
end.

