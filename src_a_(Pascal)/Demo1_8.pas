// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 8:Generator of random numbers

program Demo1_8;
uses Win32;

const 
  INSTANCE=0x400000;

var
  id1:dword;
  id2:dword;
  id3:string[100];
  id4:boolean;

procedure id5();
var id6:SYSTEMTIME;
begin
  GetSystemTime(id6);
  id1:=
    dword(id6.wMinute)*60000+
    dword(id6.wSecond)*1000+
    dword(id6.wMilliseconds);
end;

function id7(id8:dword):dword;
begin
  id1:=1664525*id1+1013904223;
  id7:=id1 mod id8;
end;

begin
  id5();
  id4:=false;
  while not id4 do begin
    id2:=id7(1000000000);
    wvsprintf(id3,"%lu",addr(id2));
    id4:=MessageBox(0,id3,"Rundom number:",MB_OKCANCEL)=IDCANCEL;
  end
end.

