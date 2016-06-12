// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 7:Use DOS console

program Demo1_7;
uses Win32;

const 
  INSTANCE=0x400000;

var
  id1:dword;
  id2:string[100];
  id3:HANDLE;
  id4:HANDLE;

begin
//create console and keyboard
  AllocConsole();
  id3:=GetStdHandle(STD_OUTPUT_HANDLE);
  id4:=GetStdHandle(STD_INPUT_HANDLE);
//output line
  lstrcpy(id2,"Get line:");
  CharToOem(id2,id2);
  WriteConsole(id3,addr(id2),lstrlen(id2),addr(id1),nil);
//input from keyboard
  ReadConsole(id4,addr(id2),100,addr(id1),nil);
  id2[id1]:='\0';
//set cursor to 5,5
  SetConsoleCursorPosition(id3,COORD(5*0x10000+5));
//output line
  WriteConsole(id3,addr(id2),lstrlen(id2),addr(id1),nil);
//output line with translate Dos-Windows
  lstrcpy(id2,"\13\10Press Enter");
  CharToOem(id2,id2);
  WriteConsole(id3,addr(id2),lstrlen(id2),addr(id1),nil);
//waiting of a keyboard input
  ReadConsole(id4,addr(id2),100,addr(id1),nil);
//free console
  FreeConsole();

end. //Demo1_7

