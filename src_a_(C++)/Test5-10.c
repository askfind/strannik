//Ïðîåêò Ñòðàííèê-Ìîäóëà Äëÿ Windows 32, òåñòîâàÿ ïðîãðàììà
//Ãðóïïà òåñòîâ 5:ÏÐÎÖÅÄÓÐÛ
//Òåñò íîìåð    10:ÊÎÑÂÅÍÍÀß ÐÅÊÓÐÑÈß

include Win32

char s[15];

int i;

void pr1(int j);
void pr2(int j);

void pr1(int j) {
  if(j>0) pr2(j-1);
  else return;
  i=i+1;
}

void pr2(int j) {
  if(j>0) pr1(j-1);
  else return;
  i=i+1;
}

void main() {
  i=4;
  pr1(8);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=12",0);
}

