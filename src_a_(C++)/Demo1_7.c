// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 7:Use DOS console

include Win32

define INSTANCE 0x400000

uint id1;
char id2[100];
HANDLE id3;
HANDLE id4;

void main()
{
//create console and keyboard
  AllocConsole();
  id3=GetStdHandle(STD_OUTPUT_HANDLE);
  id4=GetStdHandle(STD_INPUT_HANDLE);
//output line
  lstrcpy(id2,"Get line:");
  CharToOem(id2,id2);
  WriteConsole(id3,&id2,lstrlen(id2),&id1,nil);
//input from keyboard
  ReadConsole(id4,&id2,100,&id1,nil);
  id2[id1]='\0';
//set cursor to 5,5
  SetConsoleCursorPosition(id3,(COORD)(5*0x10000+5));
//output line
  WriteConsole(id3,&id2,lstrlen(id2),&id1,nil);
//output line with translate Dos-Windows
  lstrcpy(id2,"\13\10Press Enter");
  CharToOem(id2,id2);
  WriteConsole(id3,&id2,lstrlen(id2),&id1,nil);
//waiting of a keyboard input
  ReadConsole(id4,&id2,100,&id1,nil);
//free console
  FreeConsole();

} //Demo1_7

