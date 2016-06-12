// —“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа работы с »нтернет через WinInet
// ƒемо 3:ѕримитивный браузер

include "Win32"

define hINSTANCE 0x400000
define макс‘айл 200000

//чтение файла с сайта
int „итать‘айлѕоUrl(char* url, char* текст, int макс) {
  HINTERNET интернет;
  HINTERNET файл;
  int количество;
  int размер;
  int читать;
  bool результат;

  интернет=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0); if(интернет==0) return 1;
  файл= InternetOpenUrl(интернет,url,nil,0,0,0); if(файл==0) {InternetCloseHandle(интернет); return 2;}
  размер=0;
  do {
    if(размер+500>макс) читать=макс-размер;
    else читать=500;
    результат=InternetReadFile(файл,&(текст[размер]),читать,&количество);
    размер++количество;
  } while(результат &&(размер<макс)&&(количество!=0));
  текст[размер]='\0';
  InternetCloseHandle(файл);
  InternetCloseHandle(интернет);
  if(~результат) return 3; //ошибка InternetReadFile
  else return 0; //успешное завершение
} //„итать‘айлѕоUrl

//диалог браузера
define idUrl 100
define idGo 101
define idHtml 102

dialog DLG 41,30,404,250,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "ƒемо4_3"
begin
  control "",idUrl,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,6,336,15
  control "«агрузить",idGo,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,346,6,50,16
  control "",idHtml,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_HSCROLL | WS_VSCROLL,6,23,390,224
end;

//диалогова€ функци€ браузера
bool procDLG(HWND wnd, int message, int wparam, int lparam) {
char* буфер; char url[500];

  switch(message) {
    case WM_INITDIALOG:
      SetDlgItemText(wnd,idUrl,"http://gazeta.ru/index.shtml");
      SendDlgItemMessage(wnd,idHtml,EM_EXLIMITTEXT,0,макс‘айл);
    break;
    case WM_COMMAND:switch(loword(wparam)) {
      case idGo:if(hiword(wparam)==BN_CLICKED) {
        буфер=(char*)GlobalAlloc(0,макс‘айл);
        GetDlgItemText(wnd,idUrl,url,500);
        switch(„итать‘айлѕоUrl(url,буфер,макс‘айл)) {
          case 0:SetDlgItemText(wnd,idHtml,буфер); break;
          case 1:MessageBox(wnd,"ќшибка InternetOpen",nil,0); break;
          case 2:MessageBox(wnd,"ќшибка InternetOpenUrl",nil,0); break;
          case 3:MessageBox(wnd,"ќшибка InternetReadFile",nil,0); break;
        }
        GlobalFree(HANDLE(буфер));
      } break;
      case IDOK:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
  default:return false; break;
  }
  return true;
} //procDLG;

void main() {
  InternetAttemptConnect(0);
  DialogBoxParam(hINSTANCE,"DLG",0,addr(procDLG),0);
  ExitProcess(0);
}

