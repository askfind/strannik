//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    4:��������� � ���������� �����������

include Win32

char s[15];

int i;

void pr(int j)
{int l1,l2,l3;
  l2=j;
  l1=0;
  l3=0;
  i=i+l2;
}

void main() {
  i=4;
  pr(3);
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=7",0);
}

