//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    6:������� � ���������

include Win32

char s[15];

int i;

int pr(int j) {
  return(j+3);
}

void main() {
  i=4;
  i=pr(pr(i));
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=10",0);
}

