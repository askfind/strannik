// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use SQL)
// Demo 3.1:Create table
module Demo3_1;
import Win32;

const
  sqlSERVER="dBASE Files";
  sqlID="Admin";
  sqlPASSWORD="";

var
  env:HANDLE;
  connection:HANDLE;
  stat:HANDLE;

  id:integer;
  name:string[1000];

//-------------------------- integer output -----------------------------------
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end mbI;

//----------------- test result SQL, output error text ----------------------
procedure sqlCALL(conn:HANDLE; fun:pstr; ret:integer):integer;
var str1,str2:string[500]; ret1,ret2:integer;
begin
  case loword(ret) of
    SQL_SUCCESS:|
    SQL_SUCCESS_WITH_INFO:|
    SQL_INVALID_HANDLE:MessageBox(0,fun,"Invalid HANDLE",0);|
    SQL_ERROR:
      if SQLGetDiagRec(SQL_HANDLE_DBC,conn,1,str1,addr(ret1),str2,500,addr(ret2))=SQL_SUCCESS
        then MessageBox(0,fun,str2,0)
        else MessageBox(0,fun,"SQL error",0)
      end;|
  else mbI(ret,fun);
  end;
  return ret
end sqlCALL;

//--------------------- execute SQL statement ------------------------------
procedure sqlEXECUTE(conn:HANDLE; str:pstr);
var statement:HANDLE;
begin
  sqlCALL(conn,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,conn,addr(statement)));
  sqlCALL(conn,str,SQLExecDirect(statement,str,SQL_NTS));
  sqlCALL(conn,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,statement));
end sqlEXECUTE;

begin
//connection with SQL server
  sqlCALL(connection,"SQLAllocHandle(ENV)",SQLAllocHandle(SQL_HANDLE_ENV,0,addr(env)));
  sqlCALL(connection,"SQLSetEnvAttr",SQLSetEnvAttr(env,SQL_ATTR_ODBC_VERSION,address(SQL_OV_ODBC2),0));
  sqlCALL(connection,"SQLAllocHandle(DBC)",SQLAllocHandle(SQL_HANDLE_DBC,env,addr(connection)));
  sqlCALL(connection,"SQLConnect",SQLConnect(connection,sqlSERVER,lstrlen(sqlSERVER),sqlID,lstrlen(sqlID),sqlPASSWORD,lstrlen(sqlPASSWORD)));
  sqlCALL(connection,"SQLSetConnectAttr(READ_WRITE)",SQLSetConnectAttr(connection,SQL_ATTR_ACCESS_MODE,address(SQL_MODE_READ_WRITE),0));
  sqlCALL(connection,"SQLSetConnectAttr(AUTOCOMMIT)",SQLSetConnectAttr(connection,SQL_ATTR_AUTOCOMMIT,address(SQL_AUTOCOMMIT_ON),0));
//create table
  sqlEXECUTE(connection,"CREATE TABLE Personal (PersId INTEGER,PersName CHAR (70),PersMoney FLOAT);");
//disconnect with SQL server
  sqlCALL(connection,"SQLDisconnect",SQLDisconnect(connection));
  sqlCALL(connection,"SQLFreeHandle(DBC)",SQLFreeHandle(SQL_HANDLE_DBC,connection));
  sqlCALL(connection,"SQLFreeHandle(ENV)",SQLFreeHandle(SQL_HANDLE_ENV,env));
//exit process
  MessageBox(0,"","The end",0);
  ExitProcess(0)
end Demo3_1.


