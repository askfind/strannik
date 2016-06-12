//Ïğîåêò Ñòğàííèê-Ìîäóëà Äëÿ Windows 32, òåñòîâàÿ ïğîãğàììà
//Ãğóïïà òåñòîâ 5:ÏĞÎÖÅÄÓĞÛ
//Òåñò íîìåğ    10:ÊÎÑÂÅÍÍÀß ĞÅÊÓĞÑÈß
program Test5_10;
uses Win32;

var s:string[15];

var i:integer;

procedure pr1(j:integer); forward; 
procedure pr2(j:integer); forward;

procedure pr1(j:integer);
begin
  if j>0
    then pr2(j-1)
    else return;
  i:=i+1
end;

procedure pr2(j:integer);
begin
  if j>0
    then pr1(j-1)
    else return;
  i:=i+1
end;

begin
  i:=4;
  pr1(8);
  wvsprintf(s,'i=%li',addr(i));
  MessageBox(0,s,'i=12',0);
end.

