//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    4:��������� TRUE

include Win32

char s[15];

boolean b1,b2;

void main() {
  b1=true;
  b2=false;
  wvsprintf(s,"b1=%i",&b1);
  MessageBox(0,s,"b1=1",0);
}

