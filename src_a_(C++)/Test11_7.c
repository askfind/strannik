//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 11:������
//���� �����    7:����� ������ ������ ������

include Win32

class cla {
private:
  int f1;
  byte f2;
public:
  virtual void pr(int j);
}
void cla::pr(int j) {f1=j;}

class cla2:cla {
private:
  int f3;
public:
  virtual void pr2(int j);
}
void cla2::pr2(int j) {this.pr(j);}

char s[15];
int i;
cla2 v2;

void main()
{
  v2=new cla2;
  v2.pr2(9);
  v2.pr(9);
  wvsprintf(s,'i=%li',&(v2.f1));
  MessageBox(0,s,'i=9',0);
}

