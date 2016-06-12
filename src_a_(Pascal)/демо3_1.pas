// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � SQL
// ���� 3.1:�������� �������
program Demo3_1;
uses Win32;

const
  sql������="dBASE Files";
  sql������������="Admin";
  sql������="";

var
  ���������:HANDLE;
  ����������:HANDLE;
  ����:HANDLE;

  ���������:integer;
  ���������:string[1000];

//-------------------------- ����� ������ ����� -----------------------------------
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end;

//----------------- �������� ���������� ������� SQL, ����� ������ ������ ----------------------
function sql�����(����:HANDLE; �������:pstr; �������:integer):integer;
var ������1,������2:string[500]; ���1,���2:integer;
begin
  case loword(�������) of
    SQL_SUCCESS:;
    SQL_SUCCESS_WITH_INFO:;
    SQL_INVALID_HANDLE:MessageBox(0,�������,"�������� HANDLE",0);
    SQL_ERROR:
      if SQLGetDiagRec(SQL_HANDLE_DBC,����,1,������1,addr(���1),������2,500,addr(���2))=SQL_SUCCESS
        then MessageBox(0,�������,������2,0)
        else MessageBox(0,�������,"������ SQL",0);
  else mbI(�������,�������)
  end;
  return �������
end;

//--------------------- ���������� ��������� SQL ------------------------------
procedure sql���������(����:HANDLE; ������:pstr);
var ��������:HANDLE;
begin
  sql�����(����,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,����,addr(��������)));
  sql�����(����,������,SQLExecDirect(��������,������,SQL_NTS));
  sql�����(����,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,��������));
end;

begin
//���������� � �������� SQL
  sql�����(����������,"SQLAllocHandle(ENV)",SQLAllocHandle(SQL_HANDLE_ENV,0,addr(���������)));
  sql�����(����������,"SQLSetEnvAttr",SQLSetEnvAttr(���������,SQL_ATTR_ODBC_VERSION,address(SQL_OV_ODBC2),0));
  sql�����(����������,"SQLAllocHandle(DBC)",SQLAllocHandle(SQL_HANDLE_DBC,���������,addr(����������)));
  sql�����(����������,"SQLConnect",SQLConnect(����������,sql������,lstrlen(sql������),sql������������,lstrlen(sql������������),sql������,lstrlen(sql������)));
  sql�����(����������,"SQLSetConnectAttr(READ_WRITE)",SQLSetConnectAttr(����������,SQL_ATTR_ACCESS_MODE,address(SQL_MODE_READ_WRITE),0));
  sql�����(����������,"SQLSetConnectAttr(AUTOCOMMIT)",SQLSetConnectAttr(����������,SQL_ATTR_AUTOCOMMIT,address(SQL_AUTOCOMMIT_ON),0));
//�������� �������
  sql���������(����������,"CREATE TABLE ��������� (��������� INTEGER,��������� CHAR (70),����� FLOAT);");
//������������ � �������� SQL
  sql�����(����������,"SQLDisconnect",SQLDisconnect(����������));
  sql�����(����������,"SQLFreeHandle(DBC)",SQLFreeHandle(SQL_HANDLE_DBC,����������));
  sql�����(����������,"SQLFreeHandle(ENV)",SQLFreeHandle(SQL_HANDLE_ENV,���������));
//���������� ��������
  MessageBox(0,"","���������",0);
  ExitProcess(0)
end.


