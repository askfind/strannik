//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 7:���������
//���� �����    2:����� ������ ROL (������/�������,1/CL/������)
module Test7_2;

var i:integer;

begin
  asm
   ROL EAX,1;
   SHL ESI,0xA;
   RCL BL,CL;
   RCL dword [offs(i)],CL;
   SHL byte ptr [EBP+0x1011],1;

   ROL AX,1;
   SHL SI,0xA;
   RCL word [offs(i)],CL;
  end  
end Test7_2.
