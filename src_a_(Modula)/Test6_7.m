//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 6:������
//���� �����    7:def-������
module Test6_7;
import Test6_7a;

begin
  s[0]:='0';
  s[1]:='1';
  s[2]:='2';
  s[3]:='\0';
  MessageBox(0,s,"012",0);
  MessageBox(0,sCon,"sCon",0);
  MessageBox(0,struCon[1].sfield,"s1",0);
  MessageBox(0,struCon2[1],"s1",0);
end Test6_7.

