//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    8:��������� FROM (def-������)

from Kernel32;
  void lstrcpy ascii(char* s1,s2);
  void lstrcat ascii(char* s1,s2);

from User32;
  void MessageBox ascii(unsigned int wnd; char* mess,title; int flags);
  void wvsprintf ascii(char* buf,form; void* par);

