//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    11:����� ������� ������ �������

include Win32

char s[15];

int i;

void pr1(int p1,int p2) {
  p1=p2;
}

int pr2(int p1,int p2) {
  p1=p2;
  return(0);
}

int pr3() {
  MessageBox(0,"Ok","Ok",0);
  return(0);
}

void main() {
  pr1(8,pr2(2,pr3()));
  pr1(8,pr2(2,MessageBox(0,"Ok","Ok",0)));
}

