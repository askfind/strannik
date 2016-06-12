// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с Интернет через WinInet
// Демо 2:Получение списка файлов с FTP сайта

include "Win32"

define максТекст 1000

  HINTERNET интернет;
  HINTERNET сессия;
  HINTERNET поиск;
  WIN32_FIND_DATA файл;
  char буфер[максТекст];

void main() {
//соединение с провайдером
  InternetAttemptConnect(0);
//инициализация WinInet и сессии
  интернет=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if(интернет==0) MessageBox(0,"Ошибка InternetOpen",nil,0);
  сессия=InternetConnect(интернет,"home.perm.ru",INTERNET_DEFAULT_FTP_PORT,"strannik","",INTERNET_SERVICE_FTP,0,0);
  if(сессия==0) MessageBox(0,"Ошибка InternetConnect",nil,0);
//поиск файлов
  буфер[0]='\0';
  поиск=FtpFindFirstFile(сессия,"*.html",файл,0,0);
  if((поиск==0)and(GetLastError()!=ERROR_NO_MORE_FILES)) MessageBox(0,"Ошибка FtpFindFirstFile",nil,0);
  else {
    do {
      lstrcat(буфер,файл.cFileName);
      lstrcat(буфер,"\13\10");
    } while(InternetFindNextFile(поиск,файл));
    if(GetLastError()!=ERROR_NO_MORE_FILES) MessageBox(0,"Ошибка InternetFindNextFile",nil,0);
  }
//закрытие WinInet, сессии и поиска
  InternetCloseHandle(поиск);
  InternetCloseHandle(сессия);
  InternetCloseHandle(интернет);
  MessageBox(0,буфер,"http://home.perm.ru/~strannik",0);
  ExitProcess(0);
}

