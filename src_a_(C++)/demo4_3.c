// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Internet)
// Demo 4.3:Simple browser

include Win32

define hINSTANCE 0x400000
define maxFile 200000

//read file from url
int ReadFileByUrl(char* url, char* text, int max) {
  HINTERNET internet;
  HINTERNET file;
  int number;
  int size;
  int read;
  bool result;

  internet=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0); if(internet==0) return 1;
  file= InternetOpenUrl(internet,url,nil,0,0,0); if(file==0) {InternetCloseHandle(internet); return 2;}
  size=0;
  do {
    if(size+500>max) read=max-size;
    else read=500;
    result=InternetReadFile(file,&(text[size]),read,&number);
    size++number;
  } while (result &&(size<max)&&(number!=0));
  text[size]='\0';
  InternetCloseHandle(file);
  InternetCloseHandle(internet);
  if(~result) return 3; //InternetReadFile error
  else return 0; //success
} //ReadFileByUrl

//browser dialog
define idUrl 100
define idGo 101
define idHtml 102

dialog DLG 41,30,404,250,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo4_3"
begin
  control "",idUrl,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,6,336,15
  control "Go",idGo,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,346,6,50,16
  control "",idHtml,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_HSCROLL | WS_VSCROLL,6,23,390,224
end;

//browser dialog function
bool procDLG(HWND wnd, int message, int wparam, int lparam) {
  char* buffer; char url[500];

  switch(message) {
    case WM_INITDIALOG:
      SetDlgItemText(wnd,idUrl,"http://gazeta.ru/index.shtml");
      SendDlgItemMessage(wnd,idHtml,EM_EXLIMITTEXT,0,maxFile);
    break;
    case WM_COMMAND:switch(loword(wparam)) {
      case idGo:if(hiword(wparam)==BN_CLICKED) {
        buffer=(char*)GlobalAlloc(0,maxFile);
        GetDlgItemText(wnd,idUrl,url,500);
        switch(ReadFileByUrl(url,buffer,maxFile)) {
          case 0:SetDlgItemText(wnd,idHtml,buffer); break;
          case 1:MessageBox(wnd,"InternetOpen error",nil,0); break;
          case 2:MessageBox(wnd,"InternetOpenUrl error",nil,0); break;
          case 3:MessageBox(wnd,"InternetReadFile error",nil,0); break;
        }
        GlobalFree(HANDLE(buffer));
      }
      break;
      case IDOK:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    }
    break;
  default:return false; break;
  }
  return true;
} //procDLG

void main() {
  InternetAttemptConnect(0);
  DialogBoxParam(hINSTANCE,"DLG",0,addr(procDLG),0);
  ExitProcess(0);
}

