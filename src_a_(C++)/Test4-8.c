//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    8:��������� FROM

include Test4_8a

char s[15];

void main() {
  lstrcpy(s,"frag1 ");
  lstrcat(s,"frag2");
  MessageBox(0,s,"fraf1 frag2",0);
}

