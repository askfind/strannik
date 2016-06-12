// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 2:��������� �����

#include "Win32.h"

#define hINSTANCE 0x400000

HWND ����;
WNDCLASS �����;
MSG ���������;

pDIRECTDRAW ddraw;
pDIRECTDRAWSURFACE �����������;
DDSURFACEDESC ���������;

//������� �������
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
char* �����; int ������,�����;

  switch(msg) {
    case WM_CREATE:
    //�������� ������� DirectDraw � �����������
      DirectDrawCreate(NULL,&ddraw,NULL);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(&���������,sizeof(DDSURFACEDESC));
      ���������.dwSize=sizeof(DDSURFACEDESC);
      ���������.ddsCaps.dwCaps=DDSCAPS_PRIMARYSURFACE;
      ���������.dwFlags=DDSD_CAPS;
      ddraw.CreateSurface(&���������,&�����������,NULL);
      SetTimer(wnd,1,500,nil); break; //�������� ������ 0.5 �������
    case WM_TIMER:
    //��������� �����
      if(�����������.Lock(NULL,&���������,DDLOCK_WAIT,0)==DD_OK) {
        RtlFillMemory(���������.lpSurface,���������.lPitch*���������.dwHeight,0x00);
        �����=���������.lpSurface;
        ������=���������.lPitch*100; //������ 100
        for(�����=0; �����<=���������.dwWidth-1; �����++) {
          �����[������+�����*4+0]=(char)(0xFF); //����� ����
          �����[������+�����*4+1]=(char)(0x00);
          �����[������+�����*4+2]=(char)(0x00);
          �����[������+�����*4+3]=(char)(0x00);
        }
        �����������.Unlock(���������.lpSurface);
      } break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //������������ ��������
      KillTimer(wnd,1);
      �����������.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

void main() {
//�������� ����
  RtlZeroMemory(&�����,sizeof(WNDCLASS));
  �����.style=CS_HREDRAW | CS_VREDRAW;
  �����.lpfnWndProc=&wndProc;
  �����.hInstance=hINSTANCE;    
  �����.hbrBackground=COLOR_WINDOW;
  �����.lpszClassName="Demo5_2";
  RegisterClass(�����);                     
  ����=CreateWindowEx(WS_EX_TOPMOST,"Demo5_2","Demo5_2",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(����,SW_SHOW);
  UpdateWindow(����);

//���� ���������
  while(GetMessage(���������,0,0,0)) {
    TranslateMessage(���������);
    DispatchMessage(���������);
  }
  ExitProcess(0);
}


