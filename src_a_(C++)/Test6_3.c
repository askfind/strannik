//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 6:������
//���� �����    3:������ �����

include Win32,Test6_3a

char s[15];

int i;
typeArr ����;

void main() {
  ����[2].f2=12;
  wvsprintf(s,"i=%i",&(����[2].f2));
  MessageBox(0,s,"i=12",0);
}

