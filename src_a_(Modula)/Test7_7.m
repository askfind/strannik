//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    7:�����������:������� ��������-��������
module Test7_7;

var r:real;

begin
  asm
//�������� � ST0
   FLD [offs(r)];
   FLD  d [offs(r)];
   FILD [offs(r)];
   FBLD [offs(r)];
//�������� ��� ������������ �� �����
   FST [offs(r)];
   FST d [offs(r)];
   FIST [offs(r)];
//�������� � ������������� �� �����
   FSTP [offs(r)];
   FSTP d [offs(r)];
   FISTP [offs(r)];
   FBSTP [offs(r)];
//������� ������ �� ������� ���������
   FLDCW [offs(r)];
   FSTCW [offs(r)];
   FSTSW [offs(r)];
  end  
end Test7_7.
