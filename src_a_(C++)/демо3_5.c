// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с SQL
// Демо 3.5:Удаление таблицы
include Win32

define sqlСервер "dBASE Files"
define sqlПользователь "Admin"
define sqlПароль ""

HANDLE окружение;
HANDLE соединение;
HANDLE опер;

int табельный;
char фамилияио[1000];

//-------------------------- вывод целого числа -----------------------------------
void mbI(int i, char* title)
{char str[50];
  wvsprintf(str,"%li",&i);
  MessageBox(0,str,title,0);
}

//----------------- проверка результата функции SQL, вывод текста ошибки ----------------------
int sqlВызов(HANDLE соед, char* функция, int возврат)
{char строка1[500],строка2[500]; int рез1,рез2;

  switch(loword(возврат)) {
    case SQL_SUCCESS:break;
    case SQL_SUCCESS_WITH_INFO:break;
    case SQL_INVALID_HANDLE:MessageBox(0,функция,"Неверный HANDLE",0); break;
    case SQL_ERROR:{
      if(SQLGetDiagRec(SQL_HANDLE_DBC,соед,1,строка1,&рез1,строка2,500,&рез2)==SQL_SUCCESS)
        MessageBox(0,функция,строка2,0);
      else MessageBox(0,функция,"Ошибка SQL",0);
    }
    default:mbI(возврат,функция); break;
  }
  return возврат;
}

//--------------------- исполнение оператора SQL ------------------------------
void sqlВыполнить(HANDLE соед, char* строка)
{HANDLE оператор;

  sqlВызов(соед,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,соед,&оператор));
  sqlВызов(соед,строка,SQLExecDirect(оператор,строка,SQL_NTS));
  sqlВызов(соед,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,оператор));
}

void main () {
//соединение с сервером SQL
  sqlВызов(соединение,"SQLAllocHandle(ENV)",SQLAllocHandle(SQL_HANDLE_ENV,0,&окружение));
  sqlВызов(соединение,"SQLSetEnvAttr",SQLSetEnvAttr(окружение,SQL_ATTR_ODBC_VERSION,(void*)(SQL_OV_ODBC2),0));
  sqlВызов(соединение,"SQLAllocHandle(DBC)",SQLAllocHandle(SQL_HANDLE_DBC,окружение,&соединение));
  sqlВызов(соединение,"SQLConnect",SQLConnect(соединение,sqlСервер,lstrlen(sqlСервер),sqlПользователь,lstrlen(sqlПользователь),sqlПароль,lstrlen(sqlПароль)));
  sqlВызов(соединение,"SQLSetConnectAttr(READ_WRITE)",SQLSetConnectAttr(соединение,SQL_ATTR_ACCESS_MODE,(void*)(SQL_MODE_READ_WRITE),0));
  sqlВызов(соединение,"SQLSetConnectAttr(AUTOCOMMIT)",SQLSetConnectAttr(соединение,SQL_ATTR_AUTOCOMMIT,(void*)(SQL_AUTOCOMMIT_ON),0));
//удаление таблицы
  sqlВыполнить(соединение,"DROP TABLE Работники;");
//разъединение с сервером SQL
  sqlВызов(соединение,"SQLDisconnect",SQLDisconnect(соединение));
  sqlВызов(соединение,"SQLFreeHandle(DBC)",SQLFreeHandle(SQL_HANDLE_DBC,соединение));
  sqlВызов(соединение,"SQLFreeHandle(ENV)",SQLFreeHandle(SQL_HANDLE_ENV,окружение));
//завершение процесса
  MessageBox(0,"","Завершено",0);
  ExitProcess(0);
}

