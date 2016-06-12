// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 2:Program with window

#include <Win32.h>

#define hINSTANCE 0x400000
#define className "Strannik"

bool wndProc(HWND hWnd,uint msg,uint wParam,uint lParam)
{
  switch(msg) {
    case WM_CREATE:return(true); break;
    case WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
    default:return(DefWindowProc(hWnd,msg,wParam,lParam)); break;
  }
}

WNDCLASS id1;
HWND id2;
MSG message;

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
  id2=CreateWindowEx(0,className,"Demo1_2",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(id2,SW_SHOW);
  UpdateWindow(id2);

//messages loop
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
} //main

