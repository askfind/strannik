//�������� ������-��-������� ��� Win32
//������ RES (��������� ��������)
//���� SMRES.D

definition module SmRes;
import Win32,SmDat;

const �������������="Str32DlgItem";
const ������������="Str32DlgMain";

procedure envCorrFont(f:classFrag);
procedure resTxtToDlg(cart:integer; var ���Y,���Y:integer):boolean;
procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean;
procedure �������������(��������:boolean):pstr;
procedure ������������();
procedure �������������();
procedure ������������();

end SmRes.

