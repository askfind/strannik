//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    1:�������� ������������

include Win32

char s[15];

byte b1,b2; int i;

void main() {
  b2=8;
  b1=1;
  i=b2;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=8",0);
}

