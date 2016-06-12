// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа
// ƒемо 4:“екстовый редактор
module Demo1_4;
import Win32;

const 
  INSTANCE=0x400000;
  им€ ласса="Strannik";

  менюЌовый=100;
  менюќткрыть=101;
  меню—охранить=102;
  меню¬ыход=200;

var
  класс√лав:WNDCLASS;
  окно√лав:HWND;
  окно–ед:HWND;
  сообщ:MSG;

//================ системные процедуры =================

procedure memAlloc(len:cardinal):address;
var h:HANDLE;
begin
    h:=GlobalAlloc(GMEM_FIXED,len);
    return(GlobalLock(h));
end memAlloc;

procedure memFree(p:address);
var h:HANDLE;
begin
  h:=GlobalHandle(p);
  GlobalFree(h);
end memFree;

procedure показ÷ел(цел:integer; комм:pstr);
var стр:pstr;
begin
  стр:=memAlloc(50);
  wvsprintf(стр,'%li',addr(цел));
  MessageBox(0,стр,комм,0);
  memFree(стр);
end показ÷ел;

//================= создание меню =======================

procedure создћеню(окно:HWND);
var оснћеню,всплћеню:HMENU;
begin
  оснћеню:=CreateMenu();

  всплћеню:=CreatePopupMenu();
  AppendMenu(всплћеню,MF_STRING,менюЌовый,"Ќовый");
  AppendMenu(всплћеню,MF_STRING,менюќткрыть,"ќткрыть");
  AppendMenu(всплћеню,MF_STRING,меню—охранить,"—охранить");
  AppendMenu(оснћеню,MF_POPUP,всплћеню,"‘айл");

  AppendMenu(оснћеню,MF_STRING,меню¬ыход,"¬ыход");
  SetMenu(окно,оснћеню);
end создћеню;

//================ получить им€ файла =================

procedure ¬з€ть»м€‘айла(файл:pstr; битќткр:boolean):boolean;
var откр:OPENFILENAME; битќк:boolean;
begin
  RtlZeroMemory(addr(откр),sizeof(OPENFILENAME));
  with откр do
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=512;
    lpstrFile:=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle:=512;
    lpstrFileTitle:=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]:='\0';
  end;
  if битќткр
    then битќк:=GetOpenFileName(откр)
    else битќк:=GetSaveFileName(откр)
  end;
//  показ÷ел(integer(битќк),"битќк");
//  показ÷ел(CommDlgExtendedError(),"error");
  with откр do
    lstrcpyn(файл,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  end;
  return(битќк);
end ¬з€ть»м€‘айла;

//=============== загрузить файл ======================

procedure «агр‘айл(им€:pstr);
var файл:HFILE; разм:cardinal; буф:pstr;
begin
  файл:=_lopen(им€,OF_READ);
  разм:=_llseek(файл,0,FILE_END);
  буф:=memAlloc(разм+1);
  _llseek(файл,0,FILE_BEGIN);
  _lread(файл,буф,разм);
  буф[разм]:='\0';
  _lclose(файл);
  SetWindowText(окно–ед,буф);  
  SetWindowText(окно√лав,им€);
  memFree(буф);
end «агр‘айл;

//================= новый файл ======================

procedure процЌовый();
begin
  SetWindowText(окно–ед,nil);
  SetWindowText(окно√лав,nil);
end процЌовый;

//================= открыть файл ======================

procedure процќткрыть();
var им€:string[200];
begin
  if ¬з€ть»м€‘айла(им€,true) then
    «агр‘айл(им€)
  end;
  SetFocus(окно–ед);
end процќткрыть;

//================= сохранить файл ======================

procedure проц—охранить();
var им€:string[200]; файл:HFILE; буф:pstr; разм:cardinal; битќк:boolean;
begin
  GetWindowText(окно√лав,им€,200);
  битќк:=true;
  if им€[0]='\0' then
    lstrcpy(им€,'*.txt');
    битќк:=¬з€ть»м€‘айла(им€,false);
    if битќк then
      SetWindowText(окно√лав,им€);
    end  
  end;
  if битќк then
    разм:=GetWindowTextLength(окно–ед);
    буф:=memAlloc(разм+1);
    GetWindowText(окно–ед,буф,разм);
    файл:=_lcreat(им€,0);
    _lwrite(файл,буф,разм);
    _lclose(файл);
  end;
  SetFocus(окно–ед);
end проц—охранить;

//================= оконна€ функци€ ======================

procedure оконѕроц(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
var рег:RECT;
begin
  case msg of
    WM_CREATE:|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam));|
    WM_SIZE:
      GetClientRect(окно√лав,рег);
      MoveWindow(окно–ед,рег.left+5,рег.top+5,рег.right-рег.left-10,рег.bottom-рег.top-10,true);|
    WM_COMMAND:case loword(wParam) of
      менюЌовый:процЌовый();|
      менюќткрыть:процќткрыть();|
      меню—охранить:проц—охранить();|
      меню¬ыход:DestroyWindow(окно√лав);|
    end;|
    else return(DefWindowProc(hWnd,msg,wParam,lParam));
  end;
  return(true)
end оконѕроц;

//================= основна€ программа ====================

begin
//регистраци€ класса
  with класс√лав do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(оконѕроц);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=INSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=им€ ласса;
  end;
  RegisterClass(класс√лав);
                     
//создание окна
  окно√лав:=CreateWindowEx(0,им€ ласса,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(окно√лав,SW_SHOW);
  UpdateWindow(окно√лав);

//создание окна редактора
  окно–ед:=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    окно√лав,0,INSTANCE,nil);
  ShowWindow(окно–ед,SW_SHOW);
  UpdateWindow(окно–ед);
  SetFocus(окно–ед);

//создание меню
  создћеню(окно√лав);

//цикл сообщений
  while GetMessage(сообщ,0,0,0) do
    TranslateMessage(сообщ);
    DispatchMessage(сообщ);
  end;
  ExitProcess(0);
end Demo1_4.

