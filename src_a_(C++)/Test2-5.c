//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    5:��������� SIZEOF

include Win32

char s[15];

typedef struct {
           int f1;
           int f2[1..100];
         } rec;
int i;

void main() {
  i=sizeof(rec);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=404",0);
}

