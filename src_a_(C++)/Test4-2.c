//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    2:�������� IF

include Win32

char s[15];

int i,j;
void main() {
  i=4;
  j=0;
//THEN-�����
  if(i<8) j=1;
  elsif(i<8) j=2;
  else j=3;
  wvsprintf(s,"j=%i",&j);
  MessageBox(0,s,"j=1",0);
//ELSIF-�����
  if(i<4) j=1;
  elsif(i<8) j=2;
  else j=3;
  wvsprintf(s,"j=%i",&j);
  MessageBox(0,s,"j=2",0);
//ELSE-�����
  if(i<4) j=1;
  elsif(i<4) j=2;
  else j=3;
  wvsprintf(s,"j=%i",&j);
  MessageBox(0,s,"j=3",0);
}

