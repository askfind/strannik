//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    8:�����������:�������������� �������

float r;

void main() {
  asm {
//���������
   FCOM [offs(r)];
   FICOM [offs(r)];
   FCOMP [offs(r)];
   FICOMP [offs(r)];
   FTST;
//�������� � ���������
   FADD [offs(r)];
   FIADD [offs(r)];
   FSUB [offs(r)];
   FISUB [offs(r)];
   FSUBR [offs(r)];
   FISUBR [offs(r)];
//��������� � �������
   FMUL [offs(r)];
   FIMUL [offs(r)];
   FDIV [offs(r)];
   FIDIV [offs(r)];
   FDIVR [offs(r)];
   FIDIVR [offs(r)];
//������ �������
   FABS;
   FCHS;
   FRNDINT;
   FXTRACT;
 }
}

