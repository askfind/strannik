// ��������-������ ��� Win32
// ���������������� ���������
// ���� 7:������ � ��������
program Demo1_7;
uses Win32;

const 
  INSTANCE=0x400000;

var
  �����:dword;
  ������:string[100];
  �������:HANDLE;
  ����������:HANDLE;

begin
//������� ������� � ����������
  AllocConsole();
  �������:=GetStdHandle(STD_OUTPUT_HANDLE);
  ����������:=GetStdHandle(STD_INPUT_HANDLE);
//����� ������
  lstrcpy(������,"�������� ������ �� ����������:");
  CharToOem(������,������);
  WriteConsole(�������,addr(������),lstrlen(������),addr(�����),nil);
//���� � ����������
  ReadConsole(����������,addr(������),100,addr(�����),nil);
  ������[�����]:='\0';
//��������� ������� � ������� 5,5
  SetConsoleCursorPosition(�������,COORD(5*0x10000+5));
//����� ��������� ������
  WriteConsole(�������,addr(������),lstrlen(������),addr(�����),nil);
//����� ������ � ��������� ������
  lstrcpy(������,"\13\10������� Enter");
  CharToOem(������,������);
  WriteConsole(�������,addr(������),lstrlen(������),addr(�����),nil);
//�������� ����� � ����������
  ReadConsole(����������,addr(������),100,addr(�����),nil);
//����������� �������
  FreeConsole();

end. //Demo1_7

