//������ �������� ������-��-������� ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    12:����� �� ������������ ������

include Win32
include Test5_12a

void pr2(int j)
{
  if(j>0) pr1(j-1);
  else return;
  i++;
}

void main()
{
  i=4;
  pr1(8);
  wvsprintf(s,'i=%li',&i);
  MessageBox(0,s,'i=12',0);
}

