//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    5:����� ������ OTHER (����/�����, ���������� � call)
module Test7_5;

var i:integer;

begin
  asm
   OUT 0x12,AL;
   OUT DX,AL;
   IN AL,DX;
�����:
   NOP;
   INT 0x21;
   CALL �����;
   CALL [offs(i)];
   RET;
   RET 4;
  end  
end Test7_5.
