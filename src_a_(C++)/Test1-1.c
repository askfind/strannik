//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 1:��������� ������
//���� �����    1:������
include Win32

char s[15];
int arr[1..3];

void main() {
  arr[1]=1;
  arr[2]=2;
  arr[3]=3;
  wvsprintf(s,"arr[2]=%li",&(arr[2]));
  MessageBox(0,s,"arr[2]=2",0);
}

