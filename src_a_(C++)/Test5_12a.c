//Ïğîåêò Ñòğàííèê Ìîäóëà-Ñè-Ïàñêàëü Äëÿ Windows 32, òåñòîâàÿ ïğîãğàììà
//Ãğóïïà òåñòîâ 5:ÏĞÎÖÅÄÓĞÛ
//Òåñò íîìåğ    12:ÂÛÇÎÂ ÈÇ ÂÛØÅËÅÆÀÙÅÃÎ ÌÎÄÓËß

include Win32

char s[15];

int i;

void pr1(int j);
void pr2(int j);

void pr1(int j)
{
  if(j>0) pr2(j-1);
  else return;
  i++;
}

