//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    4:���� WHILE

include Win32
char s[15];

int i;
void main() {
  i=4;
  while(i<6)
    i=i+1;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=6",0);
}

