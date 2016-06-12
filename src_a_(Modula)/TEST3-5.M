//Ïğîåêò Ñòğàííèê-Ìîäóëà Äëÿ Windows 32, òåñòîâàÿ ïğîãğàììà
//Ãğóïïà òåñòîâ 3:ÂÛĞÀÆÅÍÈÅ
//Òåñò íîìåğ    5:ÂÛĞÀÆÅÍÈÅ WORD
module Test3_5;
import Win32;

var s:string[15];

var w,w1:word; i:integer;

begin
  w:=0x80;
  w1:=-2;
  w:=10*(w+w1) div 10+2;
  i:=integer(w);
  wvsprintf(s,"w=%li",addr(i));
  MessageBox(0,s,"w=128",0);
  if w1>w
    then MessageBox(0,"ok","-2>128",0);
    else MessageBox(0,"error","-2>128",0);
  end
end Test3_5.

