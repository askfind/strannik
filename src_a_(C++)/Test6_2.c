//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 6:������
//���� �����    2:������ ��������

include Win32,Test6_2a

char s[15];

int i;
char c;

void main() {
  i=constInt;
  wvsprintf(s,"i=%li",&i);
  MessageBox(0,s,"i=35",0);
  c=constChar;
  wvsprintf(s,"c=%c",&c);
  MessageBox(0,s,"c=Y",0);
}

