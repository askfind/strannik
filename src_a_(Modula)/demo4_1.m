// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Internet)
// Demo 4.1:Reading HTML file
module Demo4_1;
import Win32;

const
  maxText=1000;

var
  internet:HINTERNET;
  file:HINTERNET;
  result:boolean;
  number:integer;
  buffer:string[maxText];

begin
//init WinInet and file
  internet:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  if internet=0 then MessageBox(0,"InternetOpen error",nil,0) end;
  file:= InternetOpenUrl(internet,"http://home.perm.ru/~strannik/index.html",nil,0,0,0);
  if file=0 then MessageBox(0,"InternetOpenUrl error",nil,0) end;
//file reading
  result:=InternetReadFile(file,addr(buffer),maxText,addr(number));
  buffer[number]:='\0';
//close WinInet and file
  InternetCloseHandle(file);
  InternetCloseHandle(internet);
  MessageBox(0,buffer,"http://home.perm.ru/~strannik/index.html",0);
  ExitProcess(0)
end Demo4_1.


