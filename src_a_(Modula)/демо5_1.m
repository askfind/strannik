// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � DirectX
// ���� 1:��������� �����������
module Demo5_1;
import Win32;

var
  ddraw:pDIRECTDRAW;

begin
  DirectDrawCreate(nil,addr(ddraw),nil);
  ddraw.SetDisplayMode(800, 600, 16);
  ddraw.Release();
  ExitProcess(0)
end Demo5_1.


