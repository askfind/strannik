--������ ��������-������ ��� Windows 32, �������� ���������
--������ ������ 7:���������
--���� �����    9:�����������:�������������� �������
module Test7_9;

var sw:cardinal; r1,r2:real;

begin
  r1:=2.0;
  r2:=1.0;
  asm
   FLD [offs(r1)];
   FCOMP [offs(r2)];
   FSTSW [offs(sw)];
   AND d [offs(sw)],0x4100;
  end  
end Test7_9.
