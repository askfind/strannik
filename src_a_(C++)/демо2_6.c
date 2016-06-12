// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.6:����������� ������ ������ �����

include Win32

char ��������[512];
char ����������[512];

bool ����������������(char* ����, char* �����, int ������, bool bitOpen���)
{OPENFILENAME ������;

  RtlZeroMemory(&������,sizeof(OPENFILENAME));
  with(������) {
    lStructSize=sizeof(OPENFILENAME);
    nMaxFile=������;
    lpstrFile=�����; 
    lpstrFilter=�����; 
    nMaxFileTitle=������;
    lpstrFileTitle=����; 
    Flags=OFN_EXPLORER;
  }
  if(bitOpen���) return GetOpenFileName(������);
  else return GetSaveFileName(������);
}

void main()
{
  lstrcpy(��������,"");
  lstrcpy(����������,"*.m;*.c;*.pas");
  if(����������������(��������,����������,512,true))
    MessageBox(0,��������,"������ ����:",0);
  else MessageBox(0,"����� �� ������ �����","",0);
  ExitProcess(0); //���������� ��� �������� ������������ ������� �� ������
}

