//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    7:�����������:������� ��������-��������

float r;

void main() {
  asm {
//�������� � ST0
   FLD [offs(r)];
   FILD [offs(r)];
   FBLD [offs(r)];
//�������� ��� ������������ �� �����
   FST [offs(r)];
   FIST [offs(r)];
//�������� � ������������� �� �����
   FSTP [offs(r)];
   FISTP [offs(r)];
   FBSTP [offs(r)];
//������� ������ �� ������� ���������
   FLDCW [offs(r)];
   FSTCW [offs(r)];
   FSTSW [offs(r)];
  }
}

