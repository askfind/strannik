//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    8:������ ��������

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

