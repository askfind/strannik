// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 4:��������� ��������

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

//================ ��������� ��������� =================

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

void messInt(int ���, char* ����) {
char* ���;

  ���=memAlloc(50);
  wvsprintf(���,"%li",&���);
  MessageBox(0,���,����,0);
  memFree(���);
} //messInt

//================= �������� ����(create menu)=======================

void createMenu(HWND ����) {
HMENU mainMenu,popupMenu;

  mainMenu=CreateMenu();

  popupMenu=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING,menuExit,"Exit");
  SetMenu(����,mainMenu);
} //createMenu

//================ �������� ��� �����(Get file name)=================

bool getFileName(char* ����, bool bitOpen) {
OPENFILENAME ����; bool bitOk;

  RtlZeroMemory(&����,sizeof(OPENFILENAME));
  with(����) {
    lStructSize=sizeof(OPENFILENAME);
    nMaxFile=512;
    lpstrFile=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle=512;
    lpstrFileTitle=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]='\0';
  }
  if(bitOpen) bitOk=GetOpenFileName(����);
  else bitOk=GetSaveFileName(����);
  with(����) {
    lstrcpyn(����,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  }
  return(bitOk);
} //getFileName

//=============== ��������� ����(load file)======================

void LoadFile(char* ���) {
HFILE ����; unsigned int ����; char* ���;

  ����=_lopen(���,OF_READ);
  ����=_llseek(����,0,FILE_END);
  ���=memAlloc(����+1);
  _llseek(����,0,FILE_BEGIN);
  _lread(����,���,����);
  ���[����]='\0';
  _lclose(����);
  SetWindowText(wndEdit,���);
  SetWindowText(wndMain,���);
  memFree(���);
} //LoadFile

//================= ����� ����(new file)======================

void procNew()
{
  SetWindowText(wndEdit,nil);
  SetWindowText(wndMain,nil);
} //procNew

//================= ������� ����(open file)======================

void procOpen() {
char ���[200];

  if(getFileName(���,true))
    LoadFile(���);
  SetFocus(wndEdit);
} //procOpen

//================= ��������� ����(save file)======================

void procSave() {
char ���[200]; HFILE ����; char* ���; unsigned int ����; bool bitOk;

  GetWindowText(wndMain,���,200);
  bitOk=true;
  if(���[0]=='\0') {
    lstrcpy(���,'*.txt');
    bitOk=getFileName(���,false);
    if(bitOk)
      SetWindowText(wndMain,���);
  }
  if(bitOk) {
    ����=GetWindowTextLength(wndEdit);
    ���=memAlloc(����+1);
    GetWindowText(wndEdit,���,����);
    ����=_lcreat(���,0);
    _lwrite(����,���,����);
    _lclose(����);
  }
  SetFocus(wndEdit);
} //procSave

//================= ������� �������(window function)======================

bool wndProc(HWND hWnd,uint msg,uint wParam,uint lParam) {
RECT ���;

  switch(msg) {
    case WM_CREATE:break;
    case WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
    case WM_SIZE:
      GetClientRect(wndMain,���);
      MoveWindow(wndEdit,���.left+5,���.top+5,���.right-���.left-10,���.bottom-���.top-10,true); break;
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

//================= �������� ���������(main routine)====================

void main() {
// ����������� ������(class registration)
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
                     
// �������� ����(window create)
  wndMain=CreateWindowEx(0,className,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(wndMain,SW_SHOW);
  UpdateWindow(wndMain);

// �������� ����(window create) ���������
  wndEdit=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    wndMain,0,INSTANCE,nil);
  ShowWindow(wndEdit,SW_SHOW);
  UpdateWindow(wndEdit);
  SetFocus(wndEdit);

// �������� ����(create menu)
  createMenu(wndMain);

//���� ��������� (message cycle)
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
  ExitProcess(0);
} //main

