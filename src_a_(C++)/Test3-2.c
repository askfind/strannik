//Ïðîåêò Ñòðàííèê-Ìîäóëà Äëÿ Windows 32, òåñòîâàÿ ïðîãðàììà
//Ãðóïïà òåñòîâ 3:ÂÛÐÀÆÅÍÈÅ
//Òåñò íîìåð    2:ËÎÃÈ×ÅÑÊÎÅ ÂÛÐÀÆÅÍÈÅ

include Win32

char s[15];

boolean b1,b2,b3; int i;
void main() {
  i=8;
  b1=true;
  b2=false;
  b3=(b1 || ! b2) & (i>3);
  wvsprintf(s,"b3=%li",&b3);
  MessageBox(0,s,"b3=1",0);
}

