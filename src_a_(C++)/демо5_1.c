// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 1:��������� �����������
#include "Win32.h"

int i;
pDIRECTDRAW ddraw;

void main() {
  DirectDrawCreate(nil,addr(ddraw),nil);
  ddraw.SetDisplayMode(800, 600, 16);
  ddraw.Release();
  ExitProcess(0);
}


