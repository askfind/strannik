// �������� ������-��-������� ��� Win32
// ���������������� ���������
//���� 8:��������� ��������� �����
module Demo1_8;
import Win32;

const 
  INSTANCE=0x400000;

var
  ��������������:cardinal;
  ���������:cardinal;
  ������:string[100];
  �����:boolean;

procedure ��������������������������();
var �����:SYSTEMTIME;
begin
  GetSystemTime(�����);
  ��������������:=
    cardinal(�����.wMinute)*60000+
    cardinal(�����.wSecond)*1000+
    cardinal(�����.wMilliseconds);
end ��������������������������;

procedure ��������������������(��������:cardinal):cardinal;
begin
  ��������������:=1664525*��������������+1013904223;
  return �������������� mod ��������;
end ��������������������;

begin
  ��������������������������();
  �����:=false;
  while not ����� do
    ���������:=��������������������(1000000000);
    wvsprintf(������,"%lu",addr(���������));
    �����:=MessageBox(0,������,"��������� ��������� �����:",MB_OKCANCEL)=IDCANCEL;
  end
end Demo1_8.

