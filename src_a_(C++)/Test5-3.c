//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    3:��������� � ����������� VAR

include Win32

char s[15];

typedef
  struct {
    char f1[5];
    int f2;
  } recType;
recType rec;

void pr(int j, recType &recpar) {
  recpar.f2=recpar.f2+j;
}

void main() {
  rec.f2=4;
  pr(3,rec);
  wvsprintf(s,"rec.f2=%li",&(rec.f2));
  MessageBox(0,s,"rec.f2=7",0);
}

