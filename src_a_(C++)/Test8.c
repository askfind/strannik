//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 8:���������� � ��������� ������
//������ ������ ����� � ��������� ������

void wvsprintr(float r; int dest; char* s)
byte b[0..9]; float r10; int i,j,k;
{
  r10=10.0;
  asm {
   WAIT; FLD [BP+offs(r)];//�������� ����� � ST0
   MOV CX,[BP+offs(dest)];//���� �� ��������
   JCXZ �������;//�������� �� dest=0
����:
   WAIT; FMUL [BP+offs(r10)];//ST0*10
   LOOP ����;
�������:
   WAIT; FBSTP [BP+offs(b)];
  }
//���� �����
  if(b[9]==0) s[0]=' ';
  else s[0]='-';
//�������� �����
  k=0;
  for(i=8; i>=0; i--) {
    for(j=2; j>=1; j--) {
//���������� �����
      if((i*2+j)==dest) {
        if(k=0) {
          k++;
          s[k]='0';
        }
        k++;
        s[k]='.';
      }
//�����
      k++;
      if(j==1) s[k]=(char)(b[i] % 16 + (int)'0');
      else s[k]=(char)(b[i] / 16 + (int)'0');
//������ ������� 0
      if((k==1)and(s[k]=='0')and((i*2+j)!=1))
        k=0;
    }
  }
  s[k+1]=(char)0;
}

