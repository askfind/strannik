// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 4:�������� �����

#include "Win32.h"

#define hINSTANCE 0x400000

HWND ����;
WNDCLASS �����;
MSG ���������;

pDIRECTDRAW ddraw;
DDSCAPS ddscaps;
pDIRECTDRAWSURFACE �����������,���������������;
DDSURFACEDESC ���������;

#define ������ 20
#define ����������� 100
#define �������� 2

int �����,���;

//������� �������
bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
HDC dc; HBRUSH �����,������; RECT ���;

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
      �����=50;
      ���=��������;
      SetTimer(wnd,1,10,NULL); break; //�������� ������ 0.01 �������
    case WM_TIMER:
      if(���������������.GetDC(addr(dc))==DD_OK) {
      //������ ���
        �����=CreateSolidBrush(0x000000);
        ������=SelectObject(dc,�����);
        ���.left=0;
        ���.top=0;
        ���.right=1024;
        ���.bottom=786;
        FillRect(dc,���,�����);
        SelectObject(dc,������);
        DeleteObject(�����);
    //��������� ������
        �����=CreateSolidBrush(0xFF0000);
        ������=SelectObject(dc,�����);
        Ellipse(dc,�����-������,�����������-������,�����+������,�����������+������);
        SelectObject(dc,������);
        DeleteObject(�����);
        ���������������.ReleaseDC(dc);
    //����� ������������
        �����������.Flip(NULL,0);
      }
    //������������ ������
      �����++���;
      if(�����>900) ���=-��������;
      if(�����<100) ���=��������; break;
    case WM_KEYDOWN: case WM_LBUTTONDOWN:DestroyWindow(wnd); break;
    case WM_DESTROY:
    //������������ ��������
      KillTimer(wnd,1);
      ���������������.Release();
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
  �����.lpszClassName="Demo5_4";
  RegisterClass(�����);                     
  ����=CreateWindowEx(WS_EX_TOPMOST,"Demo5_4","Demo5_4",WS_POPUP | WS_MAXIMIZE,100,100,300,300, 0,0,hINSTANCE,NULL);
  ShowWindow(����,SW_SHOW);
  UpdateWindow(����);

//���� ���������
  while(GetMessage(���������,0,0,0)) {
    TranslateMessage(���������);
    DispatchMessage(���������);
  }
  ExitProcess(0);
}

