// �������� ������-��-������� ��� Win32
// ���������������� ��������� ������ � SQL
// ���� 3.3:�������� ������
include Win32

define sql������ "dBASE Files"
define sql������������ "Admin"
define sql������ ""

HANDLE ���������;
HANDLE ����������;
HANDLE ����;

int ���������;
char ���������[1000];

//-------------------------- ����� ������ ����� -----------------------------------
void mbI(int i, char* title)
{char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

//----------------- �������� ���������� ������� SQL, ����� ������ ������ ----------------------
int sql�����(HANDLE ����, char* �������, int �������)
{char ������1[500],������2[500]; int ���1,���2;

  switch(loword(�������)) {
    case SQL_SUCCESS:break;
    case SQL_SUCCESS_WITH_INFO:break;
    case SQL_INVALID_HANDLE:MessageBox(0,�������,"�������� HANDLE",0); break;
    case SQL_ERROR:{
      if(SQLGetDiagRec(SQL_HANDLE_DBC,����,1,������1,&���1,������2,500,&���2)==SQL_SUCCESS)
        MessageBox(0,�������,������2,0);
      else MessageBox(0,�������,"������ SQL",0);
    }
    default:mbI(�������,�������); break;
  }
  return �������;
}

//--------------------- ���������� ��������� SQL ------------------------------
void sql���������(HANDLE ����, char* ������)
{HANDLE ��������;

  sql�����(����,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,����,&��������));
  sql�����(����,������,SQLExecDirect(��������,������,SQL_NTS));
  sql�����(����,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,��������));
}

void main () {
//���������� � �������� SQL
  sql�����(����������,"SQLAllocHandle(ENV)",SQLAllocHandle(SQL_HANDLE_ENV,0,&���������));
  sql�����(����������,"SQLSetEnvAttr",SQLSetEnvAttr(���������,SQL_ATTR_ODBC_VERSION,(void*)(SQL_OV_ODBC2),0));
  sql�����(����������,"SQLAllocHandle(DBC)",SQLAllocHandle(SQL_HANDLE_DBC,���������,&����������));
  sql�����(����������,"SQLConnect",SQLConnect(����������,sql������,lstrlen(sql������),sql������������,lstrlen(sql������������),sql������,lstrlen(sql������)));
  sql�����(����������,"SQLSetConnectAttr(READ_WRITE)",SQLSetConnectAttr(����������,SQL_ATTR_ACCESS_MODE,(void*)(SQL_MODE_READ_WRITE),0));
  sql�����(����������,"SQLSetConnectAttr(AUTOCOMMIT)",SQLSetConnectAttr(����������,SQL_ATTR_AUTOCOMMIT,(void*)(SQL_AUTOCOMMIT_ON),0));
//�������� ������ 0002
  sql���������(����������,"DELETE FROM ��������� WHERE ���������=0002;");
//����� �������
  sql�����(����������,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,����������,&����));
  sql�����(����������,"SELECT ���������,��������� FROM ���������;",SQLExecDirect(����,"SELECT ���������,��������� FROM ���������;",SQL_NTS));
  while(SQLFetch(����)==SQL_SUCCESS) {
    SQLGetData(����,1,SQL_C_SLONG,&���������,0,nil); mbI(���������,"���������");
    SQLGetData(����,2,SQL_C_CHAR,&���������,1000,nil); MessageBox(0,���������,"���������",0);
  }
  sql�����(����������,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,����));
//������������ � �������� SQL
  sql�����(����������,"SQLDisconnect",SQLDisconnect(����������));
  sql�����(����������,"SQLFreeHandle(DBC)",SQLFreeHandle(SQL_HANDLE_DBC,����������));
  sql�����(����������,"SQLFreeHandle(ENV)",SQLFreeHandle(SQL_HANDLE_ENV,���������));
//���������� ��������
  MessageBox(0,"","���������",0);
  ExitProcess(0);
}

