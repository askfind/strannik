// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Internet)
// Demo 4.1:Reading HTML file

include "Win32"

define maxText 1000

  HINTERNET internet;
  HINTERNET file;
  bool result;
  int number;
  char buffer[maxText];

void main() {
//init WinInet and file
  internet=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if(internet==0) MessageBox(0,"InternetOpen error",nil,0);
  file= InternetOpenUrl(internet,"http://home.perm.ru/~strannik/index.html",nil,0,0,0);
  if(file==0) MessageBox(0,"InternetOpenUrl error",nil,0);
//file reading
  result=InternetReadFile(file,&buffer,maxText,&number);
  buffer[number]='\0';
//close WinInet and file
  InternetCloseHandle(file);
  InternetCloseHandle(internet);
  MessageBox(0,buffer,"http://home.perm.ru/~strannik/index.html",0);
  ExitProcess(0);
}

