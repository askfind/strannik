//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 1:��������� ������
//���� �����    4:������ � ���������� ������

include Win32

char s[16];

struct {
  int f1;
  union {
    {byte f2[2];}
    {int f3;}
}} rec;

void main() {
  rec.f2[0]=1;
  rec.f2[1]=1;
  rec.f1=0;
  wvsprintf(s,"rec.f3=%i",&(rec.f3));
  MessageBox(0,s,"rec.f3=257",0);
}

