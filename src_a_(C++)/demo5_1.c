// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.1:Set Display Mode

#include "Win32.h"

int i;
pDIRECTDRAW ddraw;

void main() {
  DirectDrawCreate(NULL,&ddraw,NULL);
  ddraw.SetDisplayMode(800,600,16);
  ddraw.Release();
  ExitProcess(0);
}


