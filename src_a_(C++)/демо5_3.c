// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 3:������������ ������������

#include "Win32.h"

#define hINSTANCE 0x400000

HWND ����;
WNDCLASS �����;
MSG ���������;

pDIRECTDRAW ddraw;
DDSCAPS ddscaps;
pDIRECTDRAWSURFACE �����������,���������������;
DDSURFACEDESC ���������;
bool �������������;

//������� �������
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
HDC dc;

  switch(msg) {
    case WM_CREATE:
    //�������� ������� DirectDraw � ����������� � ��������������� �������
      DirectDrawCreate(NULL,&ddraw,NULL);
      ddraw.SetCooperativeLevel(wnd,DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN);
      ddraw.SetDisplayMode(1024,786,32);
      RtlZeroMemory(&���������,sizeof(DDSURFACEDESC));
      ���������.dwSize=sizeof(DDSURFACEDESC);
      ���������.ddsCaps.dwCaps=DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;
      ���������.dwFlags=DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
      ���������.dwBackBufferCount=1;
      ddraw.CreateSurface(&���������,&�����������,NULL);
      ddscaps.dwCaps=DDSCAPS_BACKBUFFER;
      �����������.GetAttachedSurface(&ddscaps,&���������������);
      �������������=false;
      SetTimer(wnd,1,1000,nil); break; //�������� ������ �������
    case WM_TIMER:
    //������ ���
      if(�����������.Lock(NULL,&���������,DDLOCK_WAIT,0)==DD_OK) {
        RtlFillMemory(���������.lpSurface,���������.lPitch*���������.dwHeight,0x00);
        �����������.Unlock(���������.lpSurface);
      }
    //����� ������
      if(���������������.GetDC(addr(dc))==DD_OK) {
        SetBkColor(dc,0x000000);
        SetTextColor(dc,0x00FF00);
        if(�������������) TextOut(dc,0,0,"Front",lstrlen("Front"));
        else TextOut(dc,0,0,"Back",lstrlen("Back"));
        ���������������.ReleaseDC(dc);
    //����� ������������
        �������������=~�������������;
        �����������.Flip(nil,0);
      } break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //������������ ��������
      KillTimer(wnd,1);
      ���������������.Release();
      �����������.Release();
      ddraw.Release();
      PostQuitMessage(0);
      return DefWindowProc(����,msg,wparam,lparam); break;
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
  �����.lpszClassName="Demo5_3";
  RegisterClass(�����);                     
  ����=CreateWindowEx(WS_EX_TOPMOST,"Demo5_3","Demo5_3",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(����,SW_SHOW);
  UpdateWindow(����);

//���� ���������
  while(GetMessage(���������,0,0,0)) {
    TranslateMessage(���������);
    DispatchMessage(���������);
  }
  ExitProcess(0);
}

