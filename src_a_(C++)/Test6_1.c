//������ ��������-������ ��� Windows, �������� ���������
//������ ������ 6:������
//���� �����    1:������ ���������

include Win32,Test6_1a

char s[15];

int i;
void main() {
  i=2;
  pr(i);
  wvsprintf(s,"i=%i",&i);
  MessageBox(0,s,"i=3",0);
}

