//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 2:���������
//���� �����    1:��������� LONGINT

include Win32

char s[15];

int li;

void main() {
  li=0x10001L;
  wvsprintf(s,'li=0x%lx',&li);
  MessageBox(0,s,'li=0x10001',0);
}

