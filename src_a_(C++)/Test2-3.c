//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    3:��������� NIL

include Win32

char s[15];

char* ps;

void main() {
  ps="Ok";
  ps=nil;
  wvsprintf(s,"ps=%li",&ps);
  MessageBox(0,s,"ps=0",0);
}

