//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    9:�����������:�������������� �������

unsigned int sw;
float r1,r2;

void main() {
  r1=2.0;
  r2=1.0;
  asm {
   FLD [offs(r1)];
   FCOMP [offs(r2)];
   FSTSW [offs(sw)];
   AND d [offs(sw)],0x4100;
  }
}

