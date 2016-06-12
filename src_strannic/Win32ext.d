//СТРАННИК Модула-Си для Win32
// Утилиты Win32 Extention (файл заголовка)
definition module Win32ext;
import Win32;

var mainWnd:HWND;

//работа со строками символов
  procedure lstrcatc(str:pstr; sym:char);
  procedure lstrposc(sym:char; str:pstr):integer;
  procedure lstrpos(sub,str:pstr):integer;
  procedure lstrposi(sub,str:pstr; i:integer):integer;
  procedure lstrdel(str:pstr; pos,len:integer);
  procedure lstrinsc(sym:char; str:pstr; pos:integer);
  procedure lstrins(ins,str:pstr; pos:integer);

//преобразования типов
  const iERROR=0;
  const rERROR=0.0;
  procedure wvscani(s:pstr):integer;
  procedure wvscanr(s:pstr):real;
  procedure wvsprintr(r:real; dest:integer; s:pstr);
  procedure wvsprinte(r:real; s:pstr);

//выделение и освобождение памяти
  procedure memAlloc(len:cardinal):address;
  procedure memFree(p:address);

//работа с файлами
  procedure _lsize(file:integer):cardinal;
  procedure _fileok(path:pstr):boolean;
  procedure _lreads(hFile:integer; s:pstr; max:cardinal):boolean;

//сообщения MessageBox
  procedure mbS(str:pstr);
  procedure mbI(i:integer; title:pstr);
  procedure mbX(x:cardinal; title:pstr);
  procedure mbR(r:real; title:pstr; dest:integer);

//арифметика с плавающей точкой
  procedure ln(r:real):real;
  procedure exp(r:real):real;
  procedure sqrt(r:real):real;
  procedure sin(r:real):real;
  procedure cos(r:real):real;
  procedure tg(r:real):real;
  procedure arctg(r:real):real;
  procedure abs(r:real):real;

//работа с dbf-файлами
  const maxDbfField=1000; //максимальное число полей в записи
  type
    recDbfTitle=record //малый заголовок DBF-файла
      dbfDescription:byte;
      dbfYear:byte;
      dbfMouns:byte;
      dbfDay:byte;
      dbfNumRecords:cardinal;
      dbfHeaderLenght:word;
      dbfRecordLenght:word;
      dbfReserved:array[1..20]of byte;
    end;
    recDbfField=record //поле кортежа
      dbfFieldName:string[10];
      dbfFieldType:char;
      dbfFieldTrack:cardinal;
      dbfFieldLength:byte;
      dbfFieldDecimal:byte;
      dbfFieldReserved:array[1..14]of byte;
    end;
    recDBF=record //заголовок DBF-файла
      dbfTitle:recDbfTitle;
      dbfTopField:integer;
      dbfFields:array[1..maxDbfField]of recDbfField;
    end;
    pDBF=pointer to recDBF;

  procedure dbfNewTitle(dbfStruct:pDBF; dbfFile:integer); //создание нового DBF-файла
  procedure dbfGetTitle(dbfStruct:pDBF; dbfFile:integer):boolean; //чтение заголовка DBF-файла
  procedure dbfGetSize(dbfStruct:pDBF; dbfFile:integer):cardinal; //количество кортежей в DBF-файле
  procedure dbfNewRecord(dbfStruct:pDBF):pstr; //инициализация кортежа
  procedure dbfReadRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //чтение кортежа
  procedure dbfWriteRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //запись кортежа
  procedure dbfInsertRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //вставка кортежа
  procedure dbfDeleteRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; bitUnDelete:boolean); //удаление/восстановление кортежа
  procedure dbfIsDeleted(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer):boolean; //проверка пометки удаления кортежа
  procedure dbfClearFile(dbfStruct:pDBF; dbfFile:integer); //очистка DBF-файла от удаленных записей
  procedure dbfGetField(dbfStruct:pDBF; dbfRecord:pstr; dbfField:integer; dbfFieldValue:pstr); //извлечение поля из кортежа
  procedure dbfSetField(dbfStruct:pDBF; dbfRecord:pstr; dbfField:integer; dbfFieldValue:pstr); //запись поля в кортеж
  procedure dbfFindField(dbfStruct:pDBF; dbfName:pstr):integer; //поиск номера поля по имени

//создание диалога indirect
  const indMAXMEM=8000;
  const indMAXWSTR=200;
  var indERROR:boolean;
  procedure indCaption(pDlg:pstr; var topDlg:integer; style,x,y,cx,cy:integer; menu,cla,caption:pstr);
  procedure indItem(pDlg:pstr; var topDlg:integer; x,y,cx,cy,ID,style:integer; cla,txt:pstr):boolean;

end Win32ext.

