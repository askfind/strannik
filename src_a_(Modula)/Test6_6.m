//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 6:������
//���� �����    6:������ DLL
module Test6_6;
import Win32,Test6_6a;

begin
  LoadLibrary("Test6_6a.dll");
  ExpProc1("ExpProc1 ok");
  ExpProc2("ExpProc2 ok");
end Test6_6.

