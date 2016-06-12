// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Internet)
// Demo 4.3:Simple browser
module Demo4_3;
import Win32;

const
  hINSTANCE=0x400000;
  maxFile=200000;

//read file from url
procedure ReadFileByUrl(url:pstr; text:pstr; max:integer):integer;
var
  internet:HINTERNET;
  file:HINTERNET;
  number:integer;
  size:integer;
  read:integer;
  result:boolean;
begin
  internet:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0); if internet=0 then return 1 end;
  file:= InternetOpenUrl(internet,url,nil,0,0,0); if file=0 then InternetCloseHandle(internet); return 2 end;
  size:=0;
  repeat
    if size+500>max
      then read:=max-size
      else read:=500
    end;
    result:=InternetReadFile(file,addr(text[size]),read,addr(number));
    inc(size,number)
  until not result or(size>=max)or(number=0);
  text[size]:='\0';
  InternetCloseHandle(file);
  InternetCloseHandle(internet);
  if not result
    then return 3 //InternetReadFile error
    else return 0 //success
  end
end ReadFileByUrl;

//browser dialog
const
  idUrl=100;
  idGo=101;
  idHtml=102;

dialog DLG 41,30,404,250,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo4_3"
begin
  control "",idUrl,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,6,336,15
  control "Go",idGo,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,346,6,50,16
  control "",idHtml,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_HSCROLL | WS_VSCROLL,6,23,390,224
end;

//browser dialog function
procedure procDLG(wnd:HWND; message,wparam,lparam:integer):boolean;
var buffer:pstr; url:string[500];
begin
  case message of
    WM_INITDIALOG:
      SetDlgItemText(wnd,idUrl,"http://gazeta.ru/index.shtml");
      SendDlgItemMessage(wnd,idHtml,EM_EXLIMITTEXT,0,maxFile);|
    WM_COMMAND:case loword(wparam) of
      idGo:if hiword(wparam)=BN_CLICKED then
        buffer:=address(GlobalAlloc(0,maxFile));
        GetDlgItemText(wnd,idUrl,url,500);
        case ReadFileByUrl(url,buffer,maxFile) of
          0:SetDlgItemText(wnd,idHtml,buffer);|
          1:MessageBox(wnd,"InternetOpen error",nil,0);|
          2:MessageBox(wnd,"InternetOpenUrl error",nil,0);|
          3:MessageBox(wnd,"InternetReadFile error",nil,0);|
        end;
        GlobalFree(HANDLE(buffer));
      end;|
      IDOK:EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
  else return false
  end;
  return true
end procDLG;

begin
  InternetAttemptConnect(0);
  DialogBoxParam(hINSTANCE,"DLG",0,addr(procDLG),0);
  ExitProcess(0)
end Demo4_3.

