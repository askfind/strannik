//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 4:���������
//���� �����    8:��������� FROM
module Test4_8;
import Test4_8a;

var s:string[15];

begin
  lstrcpy(s,'frag1 ');
  lstrcat(s,'frag2');
  MessageBox(0,s,'fraf1 frag2',0);
end Test4_8.

