//������ �������� ������-��-������� ��� Windows 32, �������� ���������
//������ ������ 1:��������� ������
//���� �����    8:��� ���������

include Win32

char s[25];

struct {
  union {
    {byte varset0[31];}
    {setbyte varset1;}
    {set[char] varset2;}
    {set[enum{s1,s2,s3};] varset3;}
}} varset;

typedef struct {
  int f1;
  setbyte f2;
} typeSruct;
define constStruct typeSruct{10,[2,15..16]}

void main() {
  with(varset) {
  //���������-���������
    varset1=[2,15..16];
    wvsprintf(s,"varset1[0]=%lx",&(varset0[0]));
    MessageBox(0,s,"varset1[0]=18004",0);
    varset1=['\2','\16','a'];
    wvsprintf(s,"varset1[0]=%lx",&(varset0[0]));
    MessageBox(0,s,"varset1[0]=10004",0);
    varset1=[s2];
    wvsprintf(s,"varset1[0]=%lx",&(varset0[0]));
    MessageBox(0,s,"varset1[0]=2",0);
  //��������� � ����������� ���������
    varset1=constStruct.f2;
    wvsprintf(s,"constStruct.f2=%lx",&(varset0[0]));
    MessageBox(0,s,"constStruct.f2=18004",0);
  //�������� in
    varset1=[2,16];
    if(16 in varset1)
      MessageBox(0,"in","Ok",0);
    else MessageBox(0,"in","Error",0);
    if(15 in varset1)
      MessageBox(0,"in","Error",0);
    else MessageBox(0,"in","Ok",0);
//�������� ���������+�������
    varset1=[2,16];
    varset1=varset1+15;
    wvsprintf(s,"varset1[0]=%lx",&(varset0[0]));
    MessageBox(0,s,"varset1[0]=18004",0);
//�������� ���������-�������
    varset1=[2,15,16];
    varset1=varset1-15;
    wvsprintf(s,"varset1[0]=%lx",&(varset0[0]));
    MessageBox(0,s,"varset1[0]=10004",0);
//�������� ���������+���������
    varset1=[2,16];
    varset1=varset1+[15];
    wvsprintf(s,"varset1[0]=%lx",&(varset0[0]));
    MessageBox(0,s,"varset1[0]=18004",0);
//�������� ���������-���������
    varset1=[2,15,16];
    varset1=varset1-[15];
    wvsprintf(s,"varset1[0]=%lx",&(varset0[0]));
    MessageBox(0,s,"varset1[0]=10004",0);
  }
}

