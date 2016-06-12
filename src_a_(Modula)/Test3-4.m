//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 3:ВЫРАЖЕНИЕ
//Тест номер 4:ВЫЧИСЛЕНИЕ ПО КОРОТКОЙ СХЕМЕ
module Test3_4;
import Win32;

procedure бул(стр:pstr):boolean;
begin
  MessageBox(0,стр,"",0);
  return false
end бул;

begin
  if бул("1 (Ок)")and бул("2 (Ошибка)") then
    MessageBox(0,"Ошибка","",0);
  end;
  MessageBox(0,"Тест завершен","",0);
end Test3_4.

