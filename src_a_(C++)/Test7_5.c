//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    5:����� ������ OTHER (����/�����, ���������� � call)

int i;

void main() {
  asm {
   OUT 0x12,AL;
   IN DX,AL;
�����:
   NOP;
   INT 0x21;
   CALL �����;
   CALL [offs(i)];
   RET;
   RET 4;
  }
}

