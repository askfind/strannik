//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    3:�������� SWITCH

include Win32

char s[15];

int i,j;
void main() {
  i=4;
  j=0;
//1-� ������������
  switch (i) {
    case 4:j=1; break;
    case 5:j=2; break;
    default:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=1",0);
//2-� ������������
  switch (i) {
    case 2:j=1; break;
    case 3..5:j=2; break;
    default:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=2",0);
//ELSE �����
  switch (i) {
    case 2:j=1; break;
    case 3: case 5:j=2; break;
    default:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=3",0);
//������������� ���������
  i=-1;
  switch (i) {
    case 2:j=1; break;
    case -1:j=2; break;
    case 3:j=3; break;
  }
  wvsprintf(s,"j=%li",&j);
  MessageBox(0,s,"j=2",0);
}

