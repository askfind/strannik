//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    3:����� ������ M (������/�������)
module Test7_3;

var i:integer;

begin
  asm
   MUL EBX;
   INC dword [offs(i)];
   POP ESI;
   CALL [EBP+0x1011];
   CALL ESI;

   MUL BX;
   INC word [offs(i)];
  end  
end Test7_3.
