// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с DirectX
// Демо 1:Установка видеорежима
#include "Win32.h"

int i;
pDIRECTDRAW ddraw;

void main() {
  DirectDrawCreate(nil,addr(ddraw),nil);
  ddraw.SetDisplayMode(800, 600, 16);
  ddraw.Release();
  ExitProcess(0);
}


