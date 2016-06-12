#include <win32.h>

#define maxArr 5000
#define maxWord 500
#define fnInp "input.txt"
#define fnOut "output.txt"

int fInp,fOut;
int top;
char* arr[maxArr];
int sort[maxArr];
char* buf;

//ввод текста и разбивка
bool inpText()
{int car,size; char* str;

  str=(char*)(GlobalAlloc(0,maxWord+1));
  fInp=_lopen(fnInp,0);
  if(fInp<=0) return false;
  size=_llseek(fInp,0,2);
  buf=(char*)(GlobalAlloc(0,size+1));
  _llseek(fInp,0,0);
  _lread(fInp,buf,size);
  _lclose(fInp);
  buf[size]='\0';
  top=0;
  car=0;
  while(buf[car]!='\0') {
    str[0]='\0';
    while((buf[car]==' ')||(buf[car]=='\9')||(buf[car]=='\10')||(buf[car]=='\11')||(buf[car]=='\13')) {
      car++;
    }
    while((buf[car]!='\0')&&(buf[car]!=' ')&&(buf[car]!='\9')&&(buf[car]!='\10')&&(buf[car]!='\11')&&(buf[car]!='\13')&&(lstrlen(str)<maxWord)) {
      str[lstrlen(str)+1]='\0';
      str[lstrlen(str)]=buf[car];
      car++;
    }
    if(top<maxArr-1) {
      top++;
      arr[top]=(char*)(GlobalAlloc(0,lstrlen(str)+1));
      lstrcpy(arr[top],str);
    }
    if(buf[car]!='\0') {
      car++;
    }
  }
  return true;
}

//сортровка текста
void sortText()
{int topSort,i,pos;

  for(i=0; i<maxArr; i++) {
    sort[i]=i;
  }
  for(topSort=0; topSort<top; topSort++) {
    pos=-1;
    for(i=0; i<topSort; i++)
      if((lstrcmp(arr[sort[i]],arr[topSort])>=0)&&(pos==-1))
        pos=i;
    if(pos>=0) {
      for(i=topSort; i>pos; i--)
        sort[i]=sort[i-1];
      sort[pos]=topSort;
    }
  }
}

//вывод текста
bool outText()
{int i;

  fOut=_lcreat(fnOut,0);
  if(fOut<=0) return false;
  for(i=0; i<top; i++) {
    _lwrite(fOut,arr[sort[i]],lstrlen(arr[sort[i]]));
    _lwrite(fOut,"\13\10",2);
  }
  _lclose(fOut);
  return true;
}

//программа
SYSTEMTIME stBeg,stEnd;
int tim,i;
char* str;

void main() {
  str=(char*)GlobalAlloc(0,1000);
  GetSystemTime(&stBeg);
  inpText();
  sortText();
  outText();
  GetSystemTime(&stEnd);
  tim=(int)stEnd.wSecond*1000+(int)stEnd.wMilliseconds-
      (int)stBeg.wSecond*1000-(int)stBeg.wMilliseconds;
  wvsprintf(str,"msk=%li",&tim);
  MessageBox(0,str,"all time:",0);
  GlobalFree(HANDLE(str));
  GlobalFree(HANDLE(buf));
  for(i=0; i<top; i++)
    GlobalFree(HANDLE(arr[i]));
  ExitProcess(0);
}

