// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 7:������ � ��������
include Win32

define INSTANCE 0x400000

uint �����;
char ������[100];
HANDLE �������;
HANDLE ����������;

void main()
{
//������� ������� � ����������
  AllocConsole();
  �������=GetStdHandle(STD_OUTPUT_HANDLE);
  ����������=GetStdHandle(STD_INPUT_HANDLE);
//����� ������
  lstrcpy(������,"�������� ������ �� ����������:");
  CharToOem(������,������);
  WriteConsole(�������,&������,lstrlen(������),&�����,nil);
//���� � ����������
  ReadConsole(����������,&������,100,&�����,nil);
  ������[�����]='\0';
//��������� ������� � ������� 5,5
  SetConsoleCursorPosition(�������,(COORD)(5*0x10000+5));
//����� ��������� ������
  WriteConsole(�������,&������,lstrlen(������),&�����,nil);
//����� ������ � ��������� ������
  lstrcpy(������,"\13\10������� Enter");
  CharToOem(������,������);
  WriteConsole(�������,&������,lstrlen(������),&�����,nil);
//�������� ����� � ����������
  ReadConsole(����������,&������,100,&�����,nil);
//����������� �������
  FreeConsole();

} //Demo1_7

