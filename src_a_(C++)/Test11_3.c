//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 11:������
//���� �����    3:����� � ������� ������ WITH

include Win32

char s[35];

class cla {
  int f1;
  byte f2;
}

void cla::setF1(int i)
{
  f1=i;
}

cla v;

void main()
{
  v=new cla;
  with(v) {
    v.setF1(1234567);
    wvsprintf(s,'i=%li',&f1);
  }
  MessageBox(0,s,'i=1234567',0);
}

