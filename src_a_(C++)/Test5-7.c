//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    7:������� ��� ���������

include Win32

char s[15];

int i;

int pr(int j) {
  i=i+2;
  return(j+3);
}

void main() {
  i=4;
  pr(i);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=6",0);
}

