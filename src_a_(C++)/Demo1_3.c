// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 3:Program with menu

#include <Win32.h>

#define hINSTANCE 0x400000
#define className "Strannik"

define menuNew 100
define menuOpen 101
define menuSave 102
define menuExit 200

WNDCLASS id1;
HWND id2;
MSG message;

//================= menu create =======================

void createMenu(HWND id3) {
HMENU mainMenu,popupMenu;

  mainMenu=CreateMenu();

  popupMenu=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP|MF_ENABLED,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING|MF_ENABLED,menuExit,"Exit");
  SetMenu(id3,mainMenu);
} //createMenu

//================= window function ======================

bool wndProc(HWND hWnd,uint msg,uint wParam,uint lParam)
{
  switch(msg) {
    case WM_CREATE:return(true); break;
    case WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
    case WM_COMMAND:switch(loword(wParam)) {
      case menuNew:MessageBox(0,"New","Menu:",0); break;
      case menuOpen:MessageBox(0,"Open","Menu:",0); break;
      case menuSave:MessageBox(0,"Save","Menu:",0); break;
      case menuExit:MessageBox(0,"Exit","Menu:",0); break;
    } break;
    default:return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
  }
} //wndProc

//================= main ====================

void main() {

//class registration
  with(id1) {
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=&wndProc;
    cbClsExtra=0;
    cbWndExtra=0;
    hInstance=hINSTANCE;    
    hIcon=0;
    hCursor=LoadCursor(0,pchar(IDC_ARROW));
    hbrBackground=COLOR_WINDOW;
    lpszMenuName=nil;
    lpszClassName=className;
  }
  RegisterClass(id1);
                     
//window create
  id2=CreateWindowEx(0,className,"Demo1_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(id2,SW_SHOW);
  UpdateWindow(id2);

//menu create
  createMenu(id2);

//messages loop
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
} //main

