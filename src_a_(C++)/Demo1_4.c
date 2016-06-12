// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 4:Text editor

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

//================ system function =================

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

void messInt(int id1, char* id2) {
char* id3;

  id3=memAlloc(50);
  wvsprintf(id3,"%li",&id1);
  MessageBox(0,id3,id2,0);
  memFree(id3);
} //messInt

//================= create menu =======================

void createMenu(HWND id4) {
HMENU mainMenu,popupMenu;

  mainMenu=CreateMenu();

  popupMenu=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING,menuExit,"Exit");
  SetMenu(id4,mainMenu);
} //createMenu

//================ get file name =================

bool getFileName(char* id5, bool bitOpen) {
OPENFILENAME id6; bool bitOk;

  RtlZeroMemory(&id6,sizeof(OPENFILENAME));
  with(id6) {
    lStructSize=sizeof(OPENFILENAME);
    nMaxFile=512;
    lpstrFile=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle=512;
    lpstrFileTitle=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]='\0';
  }
  if(bitOpen) bitOk=GetOpenFileName(id6);
  else bitOk=GetSaveFileName(id6);
  with(id6) {
    lstrcpyn(id5,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  }
  return(bitOk);
} //getFileName

//=============== load file ======================

void LoadFile(char* id7) {
HFILE id5; unsigned int id8; char* id9;

  id5=_lopen(id7,OF_READ);
  id8=_llseek(id5,0,FILE_END);
  id9=memAlloc(id8+1);
  _llseek(id5,0,FILE_BEGIN);
  _lread(id5,id9,id8);
  id9[id8]='\0';
  _lclose(id5);
  SetWindowText(wndEdit,id9);
  SetWindowText(wndMain,id7);
  memFree(id9);
} //LoadFile

//================= new file ======================

void procNew()
{
  SetWindowText(wndEdit,nil);
  SetWindowText(wndMain,nil);
} //procNew

//================= open file ======================

void procOpen() {
char id7[200];

  if(getFileName(id7,true))
    LoadFile(id7);
  SetFocus(wndEdit);
} //procOpen

//================= save file ======================

void procSave() {
char id7[200]; HFILE id5; char* id9; unsigned int id8; bool bitOk;

  GetWindowText(wndMain,id7,200);
  bitOk=true;
  if(id7[0]=='\0') {
    lstrcpy(id7,'*.txt');
    bitOk=getFileName(id7,false);
    if(bitOk)
      SetWindowText(wndMain,id7);
  }
  if(bitOk) {
    id8=GetWindowTextLength(wndEdit);
    id9=memAlloc(id8+1);
    GetWindowText(wndEdit,id9,id8);
    id5=_lcreat(id7,0);
    _lwrite(id5,id9,id8);
    _lclose(id5);
  }
  SetFocus(wndEdit);
} //procSave

//================= window function ======================

bool wndProc(HWND hWnd,uint msg,uint wParam,uint lParam) {
RECT id10;

  switch(msg) {
    case WM_CREATE:break;
    case WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
    case WM_SIZE:
      GetClientRect(wndMain,id10);
      MoveWindow(wndEdit,id10.left+5,id10.top+5,id10.right-id10.left-10,id10.bottom-id10.top-10,true); break;
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

//================= main ====================

void main() {
//class registration
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
                     
//window create
  wndMain=CreateWindowEx(0,className,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(wndMain,SW_SHOW);
  UpdateWindow(wndMain);

//editor window create
  wndEdit=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    wndMain,0,INSTANCE,nil);
  ShowWindow(wndEdit,SW_SHOW);
  UpdateWindow(wndEdit);
  SetFocus(wndEdit);

//menu create
  createMenu(wndMain);

//messages loop
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
  ExitProcess(0);
} //main

