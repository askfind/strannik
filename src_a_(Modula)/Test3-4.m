//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 3:���������
//���� ����� 4:���������� �� �������� �����
module Test3_4;
import Win32;

procedure ���(���:pstr):boolean;
begin
  MessageBox(0,���,"",0);
  return false
end ���;

begin
  if ���("1 (��)")and ���("2 (������)") then
    MessageBox(0,"������","",0);
  end;
  MessageBox(0,"���� ��������","",0);
end Test3_4.

