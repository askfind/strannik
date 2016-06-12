// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 8:Generator of random numbers

module Demo1_8;
import Win32;

const 
  INSTANCE=0x400000;

var
  id1:cardinal;
  id2:cardinal;
  id3:string[100];
  id4:boolean;

procedure id5();
var id6:SYSTEMTIME;
begin
  GetSystemTime(id6);
  id1:=
    cardinal(id6.wMinute)*60000+
    cardinal(id6.wSecond)*1000+
    cardinal(id6.wMilliseconds);
end id5;

procedure id7(id8:cardinal):cardinal;
begin
  id1:=1664525*id1+1013904223;
  return id1 mod id8;
end id7;

begin
  id5();
  id4:=false;
  while not id4 do
    id2:=id7(1000000000);
    wvsprintf(id3,"%lu",addr(id2));
    id4:=MessageBox(0,id3,"Rundom number:",MB_OKCANCEL)=IDCANCEL;
  end
end Demo1_8.

