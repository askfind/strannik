//Ïğîåêò Ñòğàííèê-Ìîäóëà Äëÿ Windows 32, òåñòîâàÿ ïğîãğàììà
//Ãğóïïà òåñòîâ 5:ÏĞÎÖÅÄÓĞÛ
//Òåñò íîìåğ    12:ÂÛÇÎÂ ÈÇ ÂÛØÅËÅÆÀÙÅÃÎ ÌÎÄÓËß
implementation module Test5_12a;
import Win32;

var s:string[15];

var i:integer;

procedure pr1(j:integer); forward; 
procedure pr2(j:integer); forward;

procedure pr1;
begin
  if j>0
    then pr2(j-1)
    else return
  end;
  i:=i+1
end pr1;

end Test5_12a.

