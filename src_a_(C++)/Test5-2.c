//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    2:��������� � �����������

include Win32

char s[15];

int i;

void pr(int j) {
  i=i+j;
}

void main() {
  i=4;
  pr(3);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=7",0);
}

