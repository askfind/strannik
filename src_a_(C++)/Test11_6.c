//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 11:������
//���� �����    6:����� ������ � ���������

include Win32

class cla {
private:
  int f1;
  byte f2;
public:
  virtual int pr(int j);
}

char s[15];
int i;
cla v;

int cla::pr(int j)
{
  return j+3;
}

void main()
{
  v=new cla;
  i=4;
  i=v.pr(v.pr(i));
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=10',0);
}

