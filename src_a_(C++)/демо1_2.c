// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 2:��������� � �����

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

WNDCLASS ��������;
HWND �������;
MSG message;

void main() {
// ����������� ������(class registration)
  with(��������) {
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
  RegisterClass(��������);
                     
// �������� ����(window create)
  �������=CreateWindowEx(0,className,"Beta1_2",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);

//���� ��������� (message cycle)
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }
} //main

