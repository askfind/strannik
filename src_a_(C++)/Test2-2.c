//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    2:��������� PCHAR

include Win32

char s[15];

char* ps;

void main() {
  ps="Ok\33";
  wvsprintf(s,"ps=%s",&ps);
  MessageBox(0,s,"ps=Ok!",0);
}

