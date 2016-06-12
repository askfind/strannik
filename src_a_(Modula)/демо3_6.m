// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа работы с SQL
// Демо 6:Получение занчения ячейки из Excel файла
module Demo3_6;
import Win32;

const
  sqlСервер="Excel Files";
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
end mbI;

//----------------- проверка результата функции SQL, вывод текста ошибки ----------------------
procedure sqlВызов(соед:HANDLE; функция:pstr; возврат:integer):integer;
var строка1,строка2:string[500]; рез1,рез2:integer;
begin
  case loword(возврат) of
    SQL_SUCCESS:|
    SQL_SUCCESS_WITH_INFO:|
    SQL_INVALID_HANDLE:MessageBox(0,функция,"Неверный HANDLE",0);|
    SQL_ERROR:
      if SQLGetDiagRec(SQL_HANDLE_DBC,соед,1,строка1,addr(рез1),строка2,500,addr(рез2))=SQL_SUCCESS
        then MessageBox(0,строка2,функция,0)
        else MessageBox(0,"Ошибка SQL",функция,0)
      end;|
  else mbI(возврат,функция);
  end;
  return возврат
end sqlВызов;

//--------------------- исполнение оператора SQL ------------------------------
procedure sqlВыполнить(соед:HANDLE; строка:pstr);
var оператор:HANDLE;
begin
  sqlВызов(соед,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,соед,addr(оператор)));
  sqlВызов(соед,строка,SQLExecDirect(оператор,строка,SQL_NTS));
  sqlВызов(соед,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,оператор));
end sqlВыполнить;

const drv="Driver={Microsoft Excel Driver (*.xls)};DBQ=c:\strannik\compil32\demo\demo3_6.xls;DriverID=790";
var строка:string[1000]; цел:integer;

begin
//соединение с сервером SQL
  sqlВызов(соединение,"SQLAllocHandle(ENV)",SQLAllocHandle(SQL_HANDLE_ENV,0,addr(окружение)));
  sqlВызов(соединение,"SQLSetEnvAttr",SQLSetEnvAttr(окружение,SQL_ATTR_ODBC_VERSION,address(SQL_OV_ODBC2),0));
  sqlВызов(соединение,"SQLAllocHandle(DBC)",SQLAllocHandle(SQL_HANDLE_DBC,окружение,addr(соединение)));
  sqlВызов(соединение,"SQLDriverConnect",SQLDriverConnect(соединение,0,drv,SQL_NTS,строка,1000,addr(цел),0));
//  mbI(цел,строка);

  sqlВызов(соединение,"SQLSetConnectAttr(READ_WRITE)",SQLSetConnectAttr(соединение,SQL_ATTR_ACCESS_MODE,address(SQL_MODE_READ_WRITE),0));
  sqlВызов(соединение,"SQLSetConnectAttr(AUTOCOMMIT)",SQLSetConnectAttr(соединение,SQL_ATTR_AUTOCOMMIT,address(SQL_AUTOCOMMIT_ON),0));
//обновление записи 0003
//  sqlВыполнить(соединение,"UPDATE Лист1 SET SUM=666 WHERE FIO='Сидоров';");
  sqlВыполнить(соединение,"UPDATE Лист1 SET A2='Сидоров' WHERE A2='Петров';");
//вывод таблицы
/*  sqlВызов(соединение,"SQLAllocHandle(STMT)",SQLAllocHandle(SQL_HANDLE_STMT,соединение,addr(опер)));
  sqlВызов(соединение,"SELECT Табельный,ФамилияИО FROM Работники;",SQLExecDirect(опер,"SELECT Табельный,ФамилияИО FROM Работники;",SQL_NTS));
  while SQLFetch(опер)=SQL_SUCCESS do
    SQLGetData(опер,1,SQL_C_SLONG,addr(табельный),0,nil); mbI(табельный,"табельный");
    SQLGetData(опер,2,SQL_C_CHAR,addr(фамилияио),1000,nil); MessageBox(0,фамилияио,"ФамилияИО",0);
  end;
  sqlВызов(соединение,"SQLFreeHandle(STMT)",SQLFreeHandle(SQL_HANDLE_STMT,опер));
*/
//разъединение с сервером SQL
  sqlВызов(соединение,"SQLDisconnect",SQLDisconnect(соединение));
  sqlВызов(соединение,"SQLFreeHandle(DBC)",SQLFreeHandle(SQL_HANDLE_DBC,соединение));
  sqlВызов(соединение,"SQLFreeHandle(ENV)",SQLFreeHandle(SQL_HANDLE_ENV,окружение));
//завершение процесса
  MessageBox(0,"","Завершено",0);
  ExitProcess(0)
end Demo3_6.

