//�������� ������-�� ��� Win32
// ������� Win32 Extention (���� ���������)
definition module Win32ext;
import Win32;

var mainWnd:HWND;

//������ �� �������� ��������
  procedure lstrcatc(str:pstr; sym:char);
  procedure lstrposc(sym:char; str:pstr):integer;
  procedure lstrpos(sub,str:pstr):integer;
  procedure lstrposi(sub,str:pstr; i:integer):integer;
  procedure lstrdel(str:pstr; pos,len:integer);
  procedure lstrinsc(sym:char; str:pstr; pos:integer);
  procedure lstrins(ins,str:pstr; pos:integer);

//�������������� �����
  const iERROR=0;
  const rERROR=0.0;
  procedure wvscani(s:pstr):integer;
  procedure wvscanr(s:pstr):real;
  procedure wvsprintr(r:real; dest:integer; s:pstr);
  procedure wvsprinte(r:real; s:pstr);

//��������� � ������������ ������
  procedure memAlloc(len:cardinal):address;
  procedure memFree(p:address);

//������ � �������
  procedure _lsize(file:integer):cardinal;
  procedure _fileok(path:pstr):boolean;
  procedure _lreads(hFile:integer; s:pstr; max:cardinal):boolean;

//��������� MessageBox
  procedure mbS(str:pstr);
  procedure mbI(i:integer; title:pstr);
  procedure mbX(x:cardinal; title:pstr);
  procedure mbR(r:real; title:pstr; dest:integer);

//���������� � ��������� ������
  procedure ln(r:real):real;
  procedure exp(r:real):real;
  procedure sqrt(r:real):real;
  procedure sin(r:real):real;
  procedure cos(r:real):real;
  procedure tg(r:real):real;
  procedure arctg(r:real):real;
  procedure abs(r:real):real;

//������ � dbf-�������
  const maxDbfField=1000; //������������ ����� ����� � ������
  type
    recDbfTitle=record //����� ��������� DBF-�����
      dbfDescription:byte;
      dbfYear:byte;
      dbfMouns:byte;
      dbfDay:byte;
      dbfNumRecords:cardinal;
      dbfHeaderLenght:word;
      dbfRecordLenght:word;
      dbfReserved:array[1..20]of byte;
    end;
    recDbfField=record //���� �������
      dbfFieldName:string[10];
      dbfFieldType:char;
      dbfFieldTrack:cardinal;
      dbfFieldLength:byte;
      dbfFieldDecimal:byte;
      dbfFieldReserved:array[1..14]of byte;
    end;
    recDBF=record //��������� DBF-�����
      dbfTitle:recDbfTitle;
      dbfTopField:integer;
      dbfFields:array[1..maxDbfField]of recDbfField;
    end;
    pDBF=pointer to recDBF;

  procedure dbfNewTitle(dbfStruct:pDBF; dbfFile:integer); //�������� ������ DBF-�����
  procedure dbfGetTitle(dbfStruct:pDBF; dbfFile:integer):boolean; //������ ��������� DBF-�����
  procedure dbfGetSize(dbfStruct:pDBF; dbfFile:integer):cardinal; //���������� �������� � DBF-�����
  procedure dbfNewRecord(dbfStruct:pDBF):pstr; //������������� �������
  procedure dbfReadRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //������ �������
  procedure dbfWriteRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //������ �������
  procedure dbfInsertRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //������� �������
  procedure dbfDeleteRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; bitUnDelete:boolean); //��������/�������������� �������
  procedure dbfIsDeleted(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer):boolean; //�������� ������� �������� �������
  procedure dbfClearFile(dbfStruct:pDBF; dbfFile:integer); //������� DBF-����� �� ��������� �������
  procedure dbfGetField(dbfStruct:pDBF; dbfRecord:pstr; dbfField:integer; dbfFieldValue:pstr); //���������� ���� �� �������
  procedure dbfSetField(dbfStruct:pDBF; dbfRecord:pstr; dbfField:integer; dbfFieldValue:pstr); //������ ���� � ������
  procedure dbfFindField(dbfStruct:pDBF; dbfName:pstr):integer; //����� ������ ���� �� �����

//�������� ������� indirect
  const indMAXMEM=8000;
  const indMAXWSTR=200;
  var indERROR:boolean;
  procedure indCaption(pDlg:pstr; var topDlg:integer; style,x,y,cx,cy:integer; menu,cla,caption:pstr);
  procedure indItem(pDlg:pstr; var topDlg:integer; x,y,cx,cy,ID,style:integer; cla,txt:pstr):boolean;

end Win32ext.

