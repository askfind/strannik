//Ïðîåêò Ñòðàííèê Ìîäóëà-Ñè-Ïàñêàëü Äëÿ Windows 32, òåñòîâàÿ ïðîãðàììà
//Ãðóïïà òåñòîâ 5:ÏÐÎÖÅÄÓÐÛ
//Òåñò íîìåð    12:ÂÛÇÎÂ ÈÇ ÂÛØÅËÅÆÀÙÅÃÎ ÌÎÄÓËß
unit Test5_12a;
uses Win32;

var s:string[15];

var i:integer;

procedure pr1(j:integer); forward; 
procedure pr2(j:integer); forward;

procedure pr1(j:integer);
begin
  if j>0
    then pr2(j-1)
    else exit;
  i:=i+1
end;

end.

