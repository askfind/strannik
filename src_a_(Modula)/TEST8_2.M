//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 8:���������� ������������
//���� �����    2:�������� ��������� REAL
module Test8_2;
import Win32;

var str:string[15];

var r1:real;

begin
  r1:=1.20;
//���������
  if r1=1.2 //4000
    then MessageBox(0,'Ok','��������� true',0)
    else MessageBox(0,'Error','��������� true',0)
  end;
  if r1=1.211 //0100
    then MessageBox(0,'Error','��������� false',0)
    else MessageBox(0,'Ok','��������� false',0)
  end;
//�����������
  if r1<>1.211
    then MessageBox(0,'Ok','����������� true',0)
    else MessageBox(0,'Error','����������� true',0)
  end;
  if r1<>1.2
    then MessageBox(0,'Error','����������� false',0)
    else MessageBox(0,'Ok','����������� false',0)
  end;
//������
  if r1<1.211 //0100
    then MessageBox(0,'Ok','������ true',0)
    else MessageBox(0,'Error','������ true',0)
  end;
  if r1<1.1 //0000
    then MessageBox(0,'Error','������ false',0)
    else MessageBox(0,'Ok','������ false',0)
  end;
  if r1<1.2 //4000
    then MessageBox(0,'Error','������ false 2',0)
    else MessageBox(0,'Ok','������ false 2',0)
  end;
//������
  if r1>1.199
    then MessageBox(0,'Ok','������ true',0)
    else MessageBox(0,'Error','������ true',0)
  end;
  if r1>1.21
    then MessageBox(0,'Error','������ false',0)
    else MessageBox(0,'Ok','������ false',0)
  end;
  if r1>1.2
    then MessageBox(0,'Error','������ false 2',0)
    else MessageBox(0,'Ok','������ false 2',0)
  end;
//������ ��� �����
  if r1<=1.211 //0100
    then MessageBox(0,'Ok','������ ��� ����� true',0)
    else MessageBox(0,'Error','������ ��� ����� true',0)
  end;
  if r1<=1.1 //0000
    then MessageBox(0,'Error','������ ��� ����� false',0)
    else MessageBox(0,'Ok','������ ��� ����� false',0)
  end;
  if r1<=1.2 //4000
    then MessageBox(0,'Ok','������ ��� ����� true 2',0)
    else MessageBox(0,'Error','������ ��� ����� true 2',0)
  end;
//������ ��� �����
  if r1>=1.199
    then MessageBox(0,'Ok','������ ��� ����� true',0)
    else MessageBox(0,'Error','������ ��� ����� true',0)
  end;
  if r1>=1.21
    then MessageBox(0,'Error','������ ��� ����� false',0)
    else MessageBox(0,'Ok','������ ��� ����� false',0)
  end;
  if r1>=1.2
    then MessageBox(0,'Ok','������ ��� ����� true 2',0)
    else MessageBox(0,'Error','������ ��� ����� true 2',0)
  end;

end Test8_2.

