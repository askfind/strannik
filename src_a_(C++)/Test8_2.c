//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 8:���������� ������������
//���� �����    2:�������� ��������� REAL

include Win32

char str[15];

float r1;

void main() {
  r1=1.20;
//���������
  if(r1==1.2) MessageBox(0,'Ok','��������� true',0);
  else MessageBox(0,'Error','��������� true',0);
  if(r1==1.211) MessageBox(0,'Error','��������� false',0);
  else MessageBox(0,'Ok','��������� false',0);
//�����������
  if(r1!=1.211) MessageBox(0,'Ok','����������� true',0);
  else MessageBox(0,'Error','����������� true',0);
  if(r1!=1.2) MessageBox(0,'Error','����������� false',0);
  else MessageBox(0,'Ok','����������� false',0);
//������
  if(r1<1.211) MessageBox(0,'Ok','������ true',0);
  else MessageBox(0,'Error','������ true',0);
  if(r1<1.1) MessageBox(0,'Error','������ false',0);
  else MessageBox(0,'Ok','������ false',0);
  if(r1<1.2) MessageBox(0,'Error','������ false 2',0);
  else MessageBox(0,'Ok','������ false 2',0);
//������
  if(r1>1.199) MessageBox(0,'Ok','������ true',0);
  else MessageBox(0,'Error','������ true',0);
  if(r1>1.21) MessageBox(0,'Error','������ false',0);
  else MessageBox(0,'Ok','������ false',0);
  if(r1>1.2) MessageBox(0,'Error','������ false 2',0);
  else MessageBox(0,'Ok','������ false 2',0);
//������ ��� �����
  if(r1<=1.211) MessageBox(0,'Ok','������ ��� ����� true',0);
  else MessageBox(0,'Error','������ ��� ����� true',0);
  if(r1<=1.1) MessageBox(0,'Error','������ ��� ����� false',0);
  else MessageBox(0,'Ok','������ ��� ����� false',0);
  if(r1<=1.2) MessageBox(0,'Ok','������ ��� ����� true 2',0);
  else MessageBox(0,'Error','������ ��� ����� true 2',0);
//������ ��� �����
  if(r1>=1.199) MessageBox(0,'Ok','������ ��� ����� true',0);
  else MessageBox(0,'Error','������ ��� ����� true',0);
  if(r1>=1.21) MessageBox(0,'Error','������ ��� ����� false',0);
  else MessageBox(0,'Ok','������ ��� ����� false',0);
  if(r1>=1.2) MessageBox(0,'Ok','������ ��� ����� true 2',0);
  else MessageBox(0,'Error','������ ��� ����� true 2',0);
}

