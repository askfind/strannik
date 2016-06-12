//Ïðîåêò Ñòðàííèê-Ìîäóëà Äëÿ Windows 32, òåñòîâàÿ ïðîãðàììà
//Ãðóïïà òåñòîâ 3:ÂÛÐÀÆÅÍÈÅ
//Òåñò íîìåð    2:ËÎÃÈ×ÅÑÊÎÅ ÂÛÐÀÆÅÍÈÅ
module Test3_2;
import Win32;

var s:string[15];

var b1,b2,b3:boolean; i:integer; c:cardinal;
begin
  i:=8;
  b1:=true;
  b2:=false;
  b3:=(b1 or not b2) and (i>3);
  wvsprintf(s,"b3=%li",addr(b3));
  MessageBox(0,s,"b3=1",0);
  c:=0xFFFFF1;
  b3:=(c<0xFFFFFF);
  wvsprintf(s,"b3=%li",addr(b3));
  MessageBox(0,s,"b3=1",0);
end Test3_2.

