// �������� ������-��-������� ��� Win32
// ���������������� ���������
//���� 8:��������� ��������� �����
include Win32

define INSTANCE 0x400000

  uint ��������������;
  uint ���������;
  char ������[100];
  bool �����;

void ��������������������������() {
SYSTEMTIME �����;

  GetSystemTime(�����);
  ��������������=
    (uint)(�����.wMinute)*60000+
    (uint)(�����.wSecond)*1000+
    (uint)(�����.wMilliseconds);
}

uint ��������������������(uint ��������)
{
  ��������������=1664525*��������������+1013904223;
  return �������������� % ��������;
}

void main() {
  ��������������������������();
  �����=false;
  while(!�����) {
    ���������=��������������������(1000000000);
    wvsprintf(������,"%lu",&���������);
    �����=MessageBox(0,������,"��������� ��������� �����:",MB_OKCANCEL)==IDCANCEL;
  }
}

