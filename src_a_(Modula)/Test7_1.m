//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    1:����� ������ MD (������/�������,�����/�������/������)
module Test7_1;

var i:integer;

begin
//  i:=0;
  asm
   MOV EAX,1;
   SUB dword [offs(i)],0xE0E0E0E0;
   ADD EBX,[EBP+ESI+0x10];

   MOV AX,DS;
   MOV AX,GS;
   MOV AX,1;
   SUB word [offs(i)],0xE0E0;
   ADD BX,[EBP+ESI+0x10];
  end  
end Test7_1.
