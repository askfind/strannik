// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.6:����������� ������ ������ �����

program Demo2_6;
uses Win32;

var
  ��������:string[512];
  ����������:string[512];

function ����������������(����,�����:pstr; ������:integer; bitOpen���:boolean):boolean;
var ������:OPENFILENAME;
begin
  RtlZeroMemory(addr(������),sizeof(OPENFILENAME));
  with ������ do begin
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=������;
    lpstrFile:=�����; 
    lpstrFilter:=�����; 
    nMaxFileTitle:=������;
    lpstrFileTitle:=����; 
    Flags:=OFN_EXPLORER;
  end;
  if bitOpen���
    then ����������������:=GetOpenFileName(������)
    else ����������������:=GetSaveFileName(������)
end;

begin
  lstrcpy(��������,"");
  lstrcpy(����������,"*.m;*.c;*.pas");
  if ����������������(��������,����������,512,true)
    then MessageBox(0,��������,"������ ����:",0)
    else MessageBox(0,"����� �� ������ �����","",0);
  ExitProcess(0); //���������� ��� �������� ������������ ������� �� ������
end.

