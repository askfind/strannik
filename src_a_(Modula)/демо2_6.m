// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.6:����������� ������ ������ �����

module Demo2_6;
import Win32;

var
  ��������:string[512];
  ����������:string[512];

procedure ����������������(����,�����:pstr; ������:integer; bitOpen���:boolean):boolean;
var ������:OPENFILENAME;
begin
  RtlZeroMemory(addr(������),sizeof(OPENFILENAME));
  with ������ do
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=������;
    lpstrFile:=�����; 
    lpstrFilter:=�����; 
    nMaxFileTitle:=������;
    lpstrFileTitle:=����; 
    Flags:=OFN_EXPLORER;
  end;
  if bitOpen���
    then return GetOpenFileName(������)
    else return GetSaveFileName(������)
  end;
end ����������������;

begin
  lstrcpy(��������,"");
  lstrcpy(����������,"*.m;*.c;*.pas");
  if ����������������(��������,����������,512,true)
    then MessageBox(0,��������,"������ ����:",0)
    else MessageBox(0,"����� �� ������ �����","",0)
  end;
  ExitProcess(0); //���������� ��� �������� ������������ ������� �� ������
end Demo2_6.

