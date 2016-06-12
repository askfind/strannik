// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с Интернет через WinInet
// Демо 2:Получение списка файлов с FTP сайта
module Demo4_2;
import Win32;

const
  максТекст=1000;

var
  интернет:HINTERNET;
  сессия:HINTERNET;
  поиск:HINTERNET;
  файл:WIN32_FIND_DATA;
  буфер:string[максТекст];

begin
//соединение с провайдером
  InternetAttemptConnect(0);
//инициализация WinInet и сессии
  интернет:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if интернет=0 then MessageBox(0,"Ошибка InternetOpen",nil,0) end;
  сессия:=InternetConnect(интернет,"home.perm.ru",INTERNET_DEFAULT_FTP_PORT,"strannik","",INTERNET_SERVICE_FTP,0,0);
  if сессия=0 then MessageBox(0,"Ошибка InternetConnect",nil,0) end;
//поиск файлов
  буфер[0]:='\0';
  поиск:=FtpFindFirstFile(сессия,"*.html",файл,0,0);
  if (поиск=0)and(GetLastError()<>ERROR_NO_MORE_FILES) then MessageBox(0,"Ошибка FtpFindFirstFile",nil,0)
  else
    repeat
      lstrcat(буфер,файл.cFileName);
      lstrcat(буфер,"\13\10");
    until not InternetFindNextFile(поиск,файл);
    if GetLastError()<>ERROR_NO_MORE_FILES then MessageBox(0,"Ошибка InternetFindNextFile",nil,0) end;
  end;
//закрытие WinInet, сессии и поиска
  InternetCloseHandle(поиск);
  InternetCloseHandle(сессия);
  InternetCloseHandle(интернет);
  MessageBox(0,буфер,"http://home.perm.ru/~strannik",0);
  ExitProcess(0)
end Demo4_2.

