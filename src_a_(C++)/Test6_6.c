//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 6:������
//���� �����    6:������ DLL

include Win32
include Test6_6a

char s[50];

void main()
{
  LoadLibrary("Test6_6a.dll");
  ExpProc1("ExpProc1 ok");
  ExpProc2("ExpProc2 ok");
}

