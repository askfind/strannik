//Ïðîåêò Ñòðàííèê-Ìîäóëà Äëÿ Windows 32, òåñòîâàÿ ïðîãðàììà
//Ãðóïïà òåñòîâ 5:ÏÐÎÖÅÄÓÐÛ
//Òåñò íîìåð    8:ÏÐßÌÀß ÐÅÊÓÐÑÈß

include Win32

char s[15];

int i;

void pr(int j) {
  if(j>0) pr(j-1);
  else return;
  i=i+1;
}

void main() {
  i=4;
  pr(8);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=12",0);
}

