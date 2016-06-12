// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с Интернет через WinInet
// Демо 1:Получение текста HTML-страницы с сайта

include "Win32"

define максТекст 1000

  HINTERNET интернет;
  HINTERNET файл;
  bool результат;
  int количество;
  char буфер[максТекст];

void main() {
//инициализация WinInet и файла
  интернет=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if(интернет==0) MessageBox(0,"Ошибка InternetOpen",nil,0);
  файл= InternetOpenUrl(интернет,"http://home.perm.ru/~strannik/index.html",nil,0,0,0);
  if(файл==0) MessageBox(0,"Ошибка InternetOpenUrl",nil,0);
//чтение файла с сайта
  результат=InternetReadFile(файл,&буфер,максТекст,&количество);
  буфер[количество]='\0';
//закрытие WinInet и файла
  InternetCloseHandle(файл);
  InternetCloseHandle(интернет);
  MessageBox(0,буфер,"http://home.perm.ru/~strannik/index.html",0);
  ExitProcess(0);
}

