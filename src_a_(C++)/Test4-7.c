//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    7:�������� WITH

include Win32

char s[15];

struct {
  int f1a;
  struct {
    char f2a;
    int f2b;
  } f1b;
} rec;

void main() {
//������� with
  rec.f1a=4;
  with(rec) {
    f1a=f1a+1;
  }
  wvsprintf(s,"i=%li",&(rec.f1a));
  MessageBox(0,s,"i=5",0);
//������� with
  rec.f1a=4;
  with(rec,f1b) {
    f2b=f1a+3;
  }
  wvsprintf(s,"i=%li",&(rec.f1b.f2b));
  MessageBox(0,s,"i=7",0);
//��������� with
  with(rec) {
    f1a=4;
    with(f1b) {
      f2b=f1a+2;
    }
  }
  wvsprintf(s,"i=%li",&(rec.f1b.f2b));
  MessageBox(0,s,"i=6",0);
}

