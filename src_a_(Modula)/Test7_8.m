//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    8:�����������:�������������� �������
module Test7_8;

var r:real;

begin
  asm
//���������
   FCOM [offs(r)];
   FCOM d [offs(r)];
   FICOM [offs(r)];
   FCOMP [offs(r)];
   FCOMP d [offs(r)];
   FICOMP [offs(r)];
   FTST;
//�������� � ���������
   FADD [offs(r)];
   FADD d [offs(r)];
   FIADD [offs(r)];
   FSUB [offs(r)];
   FSUB dword ptr [offs(r)];
   FISUB [offs(r)];
   FSUBR [offs(r)];
   FSUBR d [offs(r)];
   FISUBR [offs(r)];
//��������� � �������
   FMUL [offs(r)];
   FMUL dword ptr [offs(r)];
   FIMUL [offs(r)];
   FDIV [offs(r)];
   FDIV d [offs(r)];
   FIDIV [offs(r)];
   FDIVR qword [offs(r)];
   FDIVR dword [offs(r)];
   FIDIVR [offs(r)];
//������ �������
   FABS;
   FCHS;
   FRNDINT;
   FXTRACT;
 end  
end Test7_8.
