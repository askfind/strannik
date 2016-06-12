// —“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа работы с »нтернет через WinInet
// ƒемо 3:ѕримитивный браузер
module Demo4_3;
import Win32;

const
  hINSTANCE=0x400000;
  макс‘айл=200000;

//чтение файла с сайта
procedure „итать‘айлѕоUrl(url:pstr; текст:pstr; макс:integer):integer;
var
  интернет:HINTERNET;
  файл:HINTERNET;
  количество:integer;
  размер:integer;
  читать:integer;
  результат:boolean;
begin
  интернет:=InternetOpen("Strannik",INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0); if интернет=0 then return 1 end;
  файл:= InternetOpenUrl(интернет,url,nil,0,0,0); if файл=0 then InternetCloseHandle(интернет); return 2 end;
  размер:=0;
  repeat
    if размер+500>макс
      then читать:=макс-размер
      else читать:=500
    end;
    результат:=InternetReadFile(файл,addr(текст[размер]),читать,addr(количество));
    inc(размер,количество)
  until not результат or(размер>=макс)or(количество=0);
  текст[размер]:='\0';
  InternetCloseHandle(файл);
  InternetCloseHandle(интернет);
  if not результат
    then return 3 //ошибка InternetReadFile
    else return 0 //успешное завершение
  end
end „итать‘айлѕоUrl;

//диалог браузера
const
  idUrl=100;
  idGo=101;
  idHtml=102;

dialog DLG 41,30,404,250,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "ƒемо4_3"
begin
  control "",idUrl,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,6,336,15
  control "«агрузить",idGo,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,346,6,50,16
  control "",idHtml,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_HSCROLL | WS_VSCROLL,6,23,390,224
end;

//диалогова€ функци€ браузера
procedure procDLG(wnd:HWND; message,wparam,lparam:integer):boolean;
var буфер:pstr; url:string[500];
begin
  case message of
    WM_INITDIALOG:
      SetDlgItemText(wnd,idUrl,"http://gazeta.ru/index.shtml");
      SendDlgItemMessage(wnd,idHtml,EM_EXLIMITTEXT,0,макс‘айл);|
    WM_COMMAND:case loword(wparam) of
      idGo:if hiword(wparam)=BN_CLICKED then
        буфер:=address(GlobalAlloc(0,макс‘айл));
        GetDlgItemText(wnd,idUrl,url,500);
        case „итать‘айлѕоUrl(url,буфер,макс‘айл) of
          0:SetDlgItemText(wnd,idHtml,буфер);|
          1:MessageBox(wnd,"ќшибка InternetOpen",nil,0);|
          2:MessageBox(wnd,"ќшибка InternetOpenUrl",nil,0);|
          3:MessageBox(wnd,"ќшибка InternetReadFile",nil,0);|
        end;
        GlobalFree(HANDLE(буфер));
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

