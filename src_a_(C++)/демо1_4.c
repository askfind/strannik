// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа
// Демо 4:Текстовый редактор

include Win32

define INSTANCE 0x400000
define className "Strannik"

define menuNew 100
define menuOpen 101
define menuSave 102
define menuExit 200

WNDCLASS classMain;
HWND wndMain;
HWND wndEdit;
MSG message;

//================ системные процедуры =================

void* memAlloc(unsigned int len) {
HANDLE h;

    h=GlobalAlloc(GMEM_FIXED,len);
    return(GlobalLock(h));
} //memAlloc

void memFree(void* p) {
HANDLE h;

  h=GlobalHandle(p);
  GlobalFree(h);
} //memFree

void messInt(int цел, char* комм) {
char* стр;

  стр=memAlloc(50);
  wvsprintf(стр,"%li",&цел);
  MessageBox(0,стр,комм,0);
  memFree(стр);
} //messInt

//================= создание меню(create menu)=======================

void createMenu(HWND окно) {
HMENU mainMenu,popupMenu;

  mainMenu=CreateMenu();

  popupMenu=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING,menuExit,"Exit");
  SetMenu(окно,mainMenu);
} //createMenu

//================ получить имя файла(Get file name)=================

bool getFileName(char* файл, bool bitOpen) {
OPENFILENAME откр; bool bitOk;

  RtlZeroMemory(&откр,sizeof(OPENFILENAME));
  with(откр) {
    lStructSize=sizeof(OPENFILENAME);
    nMaxFile=512;
    lpstrFile=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle=512;
    lpstrFileTitle=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]='\0';
  }
  if(bitOpen) bitOk=GetOpenFileName(откр);
  else bitOk=GetSaveFileName(откр);
  with(откр) {
    lstrcpyn(файл,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  }
  return(bitOk);
} //getFileName

//=============== загрузить файл(load file)======================

void LoadFile(char* имя) {
HFILE файл; unsigned int разм; char* буф;

  файл=_lopen(имя,OF_READ);
  разм=_llseek(файл,0,FILE_END);
  буф=memAlloc(разм+1);
  _llseek(файл,0,FILE_BEGIN);
  _lread(файл,буф,разм);
  буф[разм]='\0';
  _lclose(файл);
  SetWindowText(wndEdit,буф);
  SetWindowText(wndMain,имя);
  memFree(буф);
} //LoadFile

//================= новый файл(new file)======================

void procNew()
{
  SetWindowText(wndEdit,nil);
  SetWindowText(wndMain,nil);
} //procNew

//================= открыть файл(open file)======================

void procOpen() {
char имя[200];

  if(getFileName(имя,true))
    LoadFile(имя);
  SetFocus(wndEdit);
} //procOpen

//================= сохранить файл(save file)======================

void procSave() {
char имя[200]; HFILE файл; char* буф; unsigned int разм; bool bitOk;

  GetWindowText(wndMain,имя,200);
  bitOk=true;
  if(имя[0]=='\0') {
    lstrcpy(имя,'*.txt');
    bitOk=getFileName(имя,false);
    if(bitOk)
      SetWindowText(wndMain,имя);
  }
  if(bitOk) {
    разм=GetWindowTextLength(wndEdit);
    буф=memAlloc(разм+1);
    GetWindowText(wndEdit,буф,разм);
    файл=_lcreat(имя,0);
    _lwrite(файл,буф,разм);
    _lclose(файл);
  }
  SetFocus(wndEdit);
} //procSave

//================= оконная функция(window function)======================

bool wndProc(HWND hWnd,uint msg,uint wParam,uint lParam) {
RECT рег;

  switch(msg) {
    case WM_CREATE:break;
    case WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
    case WM_SIZE:
      GetClientRect(wndMain,рег);
      MoveWindow(wndEdit,рег.left+5,рег.top+5,рег.right-рег.left-10,рег.bottom-рег.top-10,true); break;
    case WM_COMMAND:switch(loword(wParam)) {
      case menuNew:procNew(); break;
      case menuOpen:procOpen(); break;
      case menuSave:procSave(); break;
      case menuExit:DestroyWindow(wndMain); break;
    } break;
    default:return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
  }
  return(true);
} //wndProc

//================= основная программа(main routine)====================

void main() {
// регистрация класса(class registration)
  with(classMain) {
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=addr(wndProc);
    cbClsExtra=0;
    cbWndExtra=0;
    hInstance=INSTANCE;    
    hIcon=0;
    hCursor=LoadCursor(0,(pchar)IDC_ARROW);
    hbrBackground=COLOR_WINDOW;
    lpszMenuName=nil;
    lpszClassName=className;
  }
  RegisterClass(classMain);
                     
// создание окна(window create)
  wndMain=CreateWindowEx(0,className,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(wndMain,SW_SHOW);
  UpdateWindow(wndMain);

// создание окна(window create) редактора
  wndEdit=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    wndMain,0,INSTANCE,nil);
  ShowWindow(wndEdit,SW_SHOW);
  UpdateWindow(wndEdit);
  SetFocus(wndEdit);

// создание меню(create menu)
  createMenu(wndMain);

//цикл сообщений (message cycle)
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
  ExitProcess(0);
} //main

