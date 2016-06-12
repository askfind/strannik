// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use SQL)
// Demo 3.4:Update record
include Win32

define sqlSERVER "dBASE Files"
define sqlID "Admin"
define sqlPASSWORD ""

HANDLE env;
HANDLE connection;
HANDLE stat;

int id;
char name[1000];

//-------------------------- integer output -----------------------------------
void mbI(int i, char* title)
{char str[50];

  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

//----------------- test result SQL, output error text ----------------------
int sqlCALL(HANDLE conn, char* fun, int ret)
{char str1[500],str2[500]; int ret1,ret2;

  switch(loword(ret)) {
    case SQL_SUCCESS:break;
    case SQL_SUCCESS_WITH_INFO:break;
    case SQL_INVALID_HANDLE:MessageBox(0,fun,"Invalid HANDLE",0); break;
    case SQL_ERROR:{
      if(SQLGetDiagRec(SQL_HANDLE_DBC,conn,1,str1,&ret1,str2,500,&ret2)==SQL_SUCCESS)
        MessageBox(0,fun,str2,0);
      else MessageBox(0,fun,"SQL error",0);
    }
    default:mbI(ret,fun); break;
  }
  return ret;
}

//--------------------- execute SQL statement ------------------------------
void sqlEXECUTE(HANDLE conn, char* str)
{HANDLE statement;

  sqlCALL(conn,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,conn,&statement));
  sqlCALL(conn,str,SQLExecDirect(statement,str,SQL_NTS));
  sqlCALL(conn,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,statement));
}

void main() {
//connection with SQL server
  sqlCALL(connection,"SQLAllocHandle(ENV)",SQLAllocHandle(SQL_HANDLE_ENV,0,&env));
  sqlCALL(connection,"SQLSetEnvAttr",SQLSetEnvAttr(env,SQL_ATTR_ODBC_VERSION,(void*)(SQL_OV_ODBC2),0));
  sqlCALL(connection,"SQLAllocHandle(DBC)",SQLAllocHandle(SQL_HANDLE_DBC,env,&connection));
  sqlCALL(connection,"SQLConnect",SQLConnect(connection,sqlSERVER,lstrlen(sqlSERVER),sqlID,lstrlen(sqlID),sqlPASSWORD,lstrlen(sqlPASSWORD)));
  sqlCALL(connection,"SQLSetConnectAttr(READ_WRITE)",SQLSetConnectAttr(connection,SQL_ATTR_ACCESS_MODE,(void*)(SQL_MODE_READ_WRITE),0));
  sqlCALL(connection,"SQLSetConnectAttr(AUTOCOMMIT)",SQLSetConnectAttr(connection,SQL_ATTR_AUTOCOMMIT,(void*)(SQL_AUTOCOMMIT_ON),0));
//update record 0003
  sqlEXECUTE(connection,"UPDATE Personal SET PersName='Tony' WHERE PersId=0003;");
//output table
  sqlCALL(connection,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,connection,addr(stat)));
  sqlCALL(connection,"SELECT PersId,PersName FROM Personal;",SQLExecDirect(stat,"SELECT PersId,PersName FROM Personal;",SQL_NTS));
  while(SQLFetch(stat)==SQL_SUCCESS) {
    SQLGetData(stat,1,SQL_C_SLONG,&id,0,nil); mbI(id,"id");
    SQLGetData(stat,2,SQL_C_CHAR,&name,1000,nil); MessageBox(0,name,"name",0);
  }
  sqlCALL(connection,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,stat));
//disconnect with SQL server
  sqlCALL(connection,"SQLDisconnect",SQLDisconnect(connection));
  sqlCALL(connection,"SQLFreeHandle(DBC)",SQLFreeHandle(SQL_HANDLE_DBC,connection));
  sqlCALL(connection,"SQLFreeHandle(ENV)",SQLFreeHandle(SQL_HANDLE_ENV,env));
//exit process
  MessageBox(0,"","The end",0);
  ExitProcess(0);
}

