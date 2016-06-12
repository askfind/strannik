// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Internet)
// Demo 4.2:Reading file list from FTP
module Demo4_2;
import Win32;

const
  maxText=1000;

var
  internet:HINTERNET;
  session:HINTERNET;
  find:HINTERNET;
  file:WIN32_FIND_DATA;
  buffer:string[maxText];

begin
//connect with provider
  InternetAttemptConnect(0);
//init WinInet and session
  internet:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if internet=0 then MessageBox(0,"InternetOpen error",nil,0) end;
  session:=InternetConnect(internet,"home.perm.ru",INTERNET_DEFAULT_FTP_PORT,"strannik","",INTERNET_SERVICE_FTP,0,0);
  if session=0 then MessageBox(0,"InternetConnect error",nil,0) end;
//find files
  buffer[0]:='\0';
  find:=FtpFindFirstFile(session,"*.html",file,0,0);
  if (find=0)and(GetLastError()<>ERROR_NO_MORE_FILES) then MessageBox(0,"FtpFindFirstFile error",nil,0)
  else
    repeat
      lstrcat(buffer,file.cFileName);
      lstrcat(buffer,"\13\10");
    until not InternetFindNextFile(find,file);
    if GetLastError()<>ERROR_NO_MORE_FILES then MessageBox(0,"InternetFindNextFile error",nil,0) end;
  end;
//close WinInet, session, find
  InternetCloseHandle(find);
  InternetCloseHandle(session);
  InternetCloseHandle(internet);
  MessageBox(0,buffer,"http://home.perm.ru/~strannik",0);
  ExitProcess(0)
end Demo4_2.

