// �������� ������-��-������� ��� Win32
// ���������������� ���������
//���� 9:��������� ��������� ������ ���������

module Demo1_9;
import Win32;


var
  ������:pstr;

begin
  ������:=GetCommandLine();
  MessageBox(0,������,"��������� ������:",0);
end Demo1_9.

