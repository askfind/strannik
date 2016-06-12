//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 6:МОДУЛИ
//Тест номер    5:ИМПОРТ СТРОКОВЫХ КОНСТАНТ
module Test6_5;
import Win32,Test6_5a;

procedure Вывести();
begin
  MessageBox(0,СтрКонст1,СтрКонст2,0);
end Вывести;

begin
  Вывести();
  MessageBox(0,struCon[1],"s1",0);
end Test6_5.

