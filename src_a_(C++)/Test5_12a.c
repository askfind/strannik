//������ �������� ������-��-������� ��� Windows 32, �������� ���������
//������ ������ 5:���������
//���� �����    12:����� �� ������������ ������

include Win32

char s[15];

int i;

void pr1(int j);
void pr2(int j);

void pr1(int j)
{
  if(j>0) pr2(j-1);
  else return;
  i++;
}

