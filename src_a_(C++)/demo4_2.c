// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Internet)
// Demo 4.2:Reading file list from FTP

include "Win32"

define maxText 1000

  HINTERNET internet;
  HINTERNET session;
  HINTERNET find;
  WIN32_FIND_DATA file;
  char buffer[maxText];

void main() {
//connect with provider
  InternetAttemptConnect(0);
//init WinInet and session
  internet=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if(internet==0) MessageBox(0,"InternetOpen error",nil,0);
  session=InternetConnect(internet,"home.perm.ru",INTERNET_DEFAULT_FTP_PORT,"strannik","",INTERNET_SERVICE_FTP,0,0);
  if(session==0) MessageBox(0,"InternetConnect error",nil,0);
//find files
  buffer[0]='\0';
  find=FtpFindFirstFile(session,"*.html",file,0,0);
  if((find=0)&&(GetLastError()!=ERROR_NO_MORE_FILES)) MessageBox(0,"FtpFindFirstFile error",nil,0);
  else {
    do {
      lstrcat(buffer,file.cFileName);
      lstrcat(buffer,"\13\10");
    } while(InternetFindNextFile(find,file));
    if(GetLastError()!=ERROR_NO_MORE_FILES) MessageBox(0,"InternetFindNextFile error",nil,0);
  }
//close WinInet, session, find
  InternetCloseHandle(find);
  InternetCloseHandle(session);
  InternetCloseHandle(internet);
  MessageBox(0,buffer,"http://home.perm.ru/~strannik",0);
  ExitProcess(0);
}

