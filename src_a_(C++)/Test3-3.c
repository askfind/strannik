//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 3:���������
//���� �����    3:������� ���������

include Win32

char s[15];

struct {
  char f1[1..10];
  int f2;
  } rec1,rec2;

void main() {
  rec1.f2=0;
  rec2.f2=8;
  rec1=rec2;
  wvsprintf(s,"rec1.f2=%li",&(rec1.f2));
  MessageBox(0,s,"rec1.f2=8",0);
}

