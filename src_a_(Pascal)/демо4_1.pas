// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с Интернет через WinInet
// Демо 1:Получение текста HTML-страницы с сайта
program Demo4_1;
uses Win32;

const
  максТекст=1000;

var
  интернет:HINTERNET;
  файл:HINTERNET;
  результат:boolean;
  количество:integer;
  буфер:string[максТекст];

begin
//инициализация WinInet и файла
  интернет:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if интернет=0 then MessageBox(0,"Ошибка InternetOpen",nil,0);
  файл:= InternetOpenUrl(интернет,"http://home.perm.ru/~strannik/index.html",nil,0,0,0);
  if файл=0 then MessageBox(0,"Ошибка InternetOpenUrl",nil,0);
//чтение файла с сайта
  результат:=InternetReadFile(файл,addr(буфер),максТекст,addr(количество));
  буфер[количество]:='\0';
//закрытие WinInet и файла
  InternetCloseHandle(файл);
  InternetCloseHandle(интернет);
  MessageBox(0,буфер,"http://home.perm.ru/~strannik/index.html",0);
  ExitProcess(0)
end.


