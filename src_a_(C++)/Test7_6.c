//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    6:����� ������ NULL (��� ����������)

int i;

void main() {
  asm {
   REP STOS;
   ENTER;
  }
}
