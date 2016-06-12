// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с SQL
// Демо 3.1:Создание таблицы
program Demo3_1;
uses Win32;

const
  sqlСервер="dBASE Files";
  sqlПользователь="Admin";
  sqlПароль="";

var
  окружение:HANDLE;
  соединение:HANDLE;
  опер:HANDLE;

  табельный:integer;
  фамилияио:string[1000];

//-------------------------- вывод целого числа -----------------------------------
procedure mbI(i:integer; title:pstr);
var str:string[50];
begin
  wvsprintf(str,"%li",addr(i));
  MessageBox(0,str,title,0);
end;

//----------------- проверка результата функции SQL, вывод текста ошибки ----------------------
function sqlВызов(соед:HANDLE; функция:pstr; возврат:integer):integer;
var строка1,строка2:string[500]; рез1,рез2:integer;
begin
  case loword(возврат) of
    SQL_SUCCESS:;
    SQL_SUCCESS_WITH_INFO:;
    SQL_INVALID_HANDLE:MessageBox(0,функция,"Неверный HANDLE",0);
    SQL_ERROR:
      if SQLGetDiagRec(SQL_HANDLE_DBC,соед,1,строка1,addr(рез1),строка2,500,addr(рез2))=SQL_SUCCESS
        then MessageBox(0,функция,строка2,0)
        else MessageBox(0,функция,"Ошибка SQL",0);
  else mbI(возврат,функция)
  end;
  return возврат
end;

//--------------------- исполнение оператора SQL ------------------------------
procedure sqlВыполнить(соед:HANDLE; строка:pstr);
var оператор:HANDLE;
begin
  sqlВызов(соед,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,соед,addr(оператор)));
  sqlВызов(соед,строка,SQLExecDirect(оператор,строка,SQL_NTS));
  sqlВызов(соед,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,оператор));
end;

begin
//соединение с сервером SQL
  sqlВызов(соединение,"SQLAllocHandle(ENV)",SQLAllocHandle(SQL_HANDLE_ENV,0,addr(окружение)));
  sqlВызов(соединение,"SQLSetEnvAttr",SQLSetEnvAttr(окружение,SQL_ATTR_ODBC_VERSION,address(SQL_OV_ODBC2),0));
  sqlВызов(соединение,"SQLAllocHandle(DBC)",SQLAllocHandle(SQL_HANDLE_DBC,окружение,addr(соединение)));
  sqlВызов(соединение,"SQLConnect",SQLConnect(соединение,sqlСервер,lstrlen(sqlСервер),sqlПользователь,lstrlen(sqlПользователь),sqlПароль,lstrlen(sqlПароль)));
  sqlВызов(соединение,"SQLSetConnectAttr(READ_WRITE)",SQLSetConnectAttr(соединение,SQL_ATTR_ACCESS_MODE,address(SQL_MODE_READ_WRITE),0));
  sqlВызов(соединение,"SQLSetConnectAttr(AUTOCOMMIT)",SQLSetConnectAttr(соединение,SQL_ATTR_AUTOCOMMIT,address(SQL_AUTOCOMMIT_ON),0));
//создание таблицы
  sqlВыполнить(соединение,"CREATE TABLE Работники (Табельный INTEGER,ФамилияИО CHAR (70),Оклад FLOAT);");
//разъединение с сервером SQL
  sqlВызов(соединение,"SQLDisconnect",SQLDisconnect(соединение));
  sqlВызов(соединение,"SQLFreeHandle(DBC)",SQLFreeHandle(SQL_HANDLE_DBC,соединение));
  sqlВызов(соединение,"SQLFreeHandle(ENV)",SQLFreeHandle(SQL_HANDLE_ENV,окружение));
//завершение процесса
  MessageBox(0,"","Завершено",0);
  ExitProcess(0)
end.


