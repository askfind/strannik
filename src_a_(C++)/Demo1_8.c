// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 8:Generator of random numbers

include Win32

define INSTANCE 0x400000

  uint id1;
  uint id2;
  char id3[100];
  bool id4;

void id5() {
SYSTEMTIME id6;

  GetSystemTime(id6);
  id1=
    (uint)(id6.wMinute)*60000+
    (uint)(id6.wSecond)*1000+
    (uint)(id6.wMilliseconds);
}

uint id7(uint id8)
{
  id1=1664525*id1+1013904223;
  return id1 % id8;
}

void main() {
  id5();
  id4=false;
  while(!id4) {
    id2=id7(1000000000);
    wvsprintf(id3,"%lu",&id2);
    id4=MessageBox(0,id3,"Rundom number:",MB_OKCANCEL)==IDCANCEL;
  }
}

