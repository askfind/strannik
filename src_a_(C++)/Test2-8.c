//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    8:��������� LOWORD,HIWORD,LOBYTE,HIBYTE

include Win32

char s[15];

int i;

void main() {
  i=loword(0x12345678);
  wvsprintf(s,'i=%lx',&i);
  MessageBox(0,s,'i=5678',0);
  i=hiword(0x12345678);
  wvsprintf(s,'i=%lx',&i);
  MessageBox(0,s,'i=1234',0);
  i=lobyte(0x12345678);
  wvsprintf(s,'i=%lx',&i);
  MessageBox(0,s,'i=78',0);
  i=hibyte(0x12345678);
  wvsprintf(s,'i=%lx',&i);
  MessageBox(0,s,'i=56',0);
}

