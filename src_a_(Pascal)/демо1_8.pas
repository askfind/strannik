// �������� ������-��-������� ��� Win32
// ���������������� ���������
//���� 8:��������� ��������� �����
program Demo1_8;
uses Win32;

const 
  INSTANCE=0x400000;

var
  ��������������:dword;
  ���������:dword;
  ������:string[100];
  �����:boolean;

procedure ��������������������������();
var �����:SYSTEMTIME;
begin
  GetSystemTime(�����);
  ��������������:=
    dword(�����.wMinute)*60000+
    dword(�����.wSecond)*1000+
    dword(�����.wMilliseconds);
end;

function ��������������������(��������:dword):dword;
begin
  ��������������:=1664525*��������������+1013904223;
  ��������������������:=�������������� mod ��������;
end;

begin
  ��������������������������();
  �����:=false;
  while not ����� do begin
    ���������:=��������������������(1000000000);
    wvsprintf(������,"%lu",addr(���������));
    �����:=MessageBox(0,������,"��������� ��������� �����:",MB_OKCANCEL)=IDCANCEL;
  end
end.

