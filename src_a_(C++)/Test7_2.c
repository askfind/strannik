//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    2:����� ������ ROL (������/�������,1/CL/������)

int i;

void main() {
  asm {
   ROL AX,1;
   SHL SI,0xA;
   RCL BL,CL;
   RCL d [offs(i)],CL;
   SHL b [BP+0x1011],1;
  }
}

