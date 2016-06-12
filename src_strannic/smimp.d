//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль
//Файл SMIMP.D

definition module SmImp;
import Win32;

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль SYS (вспомогательные функции)
//Файл SMSYS.D

//definition module SmSys;
//import Win32;

const  maxFonts=40;
type
  sysFonts=record
    top:integer;
    fnts:array[1..maxFonts]of pstr;
  end;
  pSysFonts=pointer to sysFonts;

//присоединение объектов
  procedure sysSelectObject(dc:HDC; h:HANDLE; var old:HANDLE);
  procedure sysDeleteObject(dc:HDC; h:HANDLE; old:HANDLE);

//строки
  procedure listFill(fillLen:integer; fillStr,fillBuf:pstr):pstr;
  procedure SetDlgItemReal(Dlg:HWND; idDlgItem:integer; Value:real; Pre:integer);
  procedure GetDlgItemReal(Dlg:HWND; idDlgItem:integer):real;

//стандартные диалоги
  procedure sysGetFileName(bitOpen:boolean; getMas:pstr; getPath,getTitle:pstr):boolean;
  procedure sysChooseFont(chFace:pstr; var chStyle,chSize:integer):boolean;
  procedure sysGetFamilies(DC:HDC; res:pSysFonts);
  procedure sysChooseColor(wnd:HWND; col:cardinal):cardinal;
  procedure sysPrintDlg(var prnCopies:integer):HDC;

//рисование
  procedure sysDrawBitmap(drawDC:HDC; x,y:integer; drawBitmap:HBITMAP);

//преобразования типов
  procedure sysAnsiToUnicode(c:char):word;
  procedure sysRealToReal32(r:real):cardinal;

//end SmSys.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль DAT (структуры данных)
//Файл SMDAT.D

//definition module SmDat;
//import Win32;

//===============================================
//                 КОНСТАНТЫ
//===============================================

const hINSTANCE=0x400000;

//---------------- Базовые --------------------

const
  idBase=30000;
  idBaseComm=9000;
  maxText=1024;
  maxTxt=20;
  maxFrag=150;
  maxStr=30000;
  maxMod=50;
  maxLIST=200;
  maxSubs=10000;
  maxPars=100;
  maxParCalls=30;
  maxSTRING=5000;
  maxUNDO=400;
  maxWith=16;
  maxStackCon=50;
  maxCode=0x2FFFF;
  maxData=0x2FFFF;
  maxVarCall=5000;
  maxProCall=5000;
  maxDebVar=500;
  maxDebFun=1000;
  maxDebStr=maxStr;
  maxDebLevel=10;
  maxLoadPSTR=300;
  maxLoadVAR=10000;
  maxJamp=2000;
  maxCall=2000;
  maxPoiC=30;
  maxImpDLL=100;
  maxImpFun=1000;
  maxExport=500;
  maxImpCALL=1000;
  maxDlgMem=32000;
  maxResMem=16000;
  maxModif=100;
  maxMDlg=100;
  maxBMP=100;
  maxRes=1000;
  maxResUndo=30;
  maxStrID=100;
  maxTxtFile=255;
  maxTxtTitle=255;
  maxButt=50;
  maxClass=40;
  maxSClass=30;
  maxClassMenu=15;
  maxFind=50;
  maxStep=10000;
  maxStackStep=50;
  maxStepActive=300;
  maxStackMet=200;
  maxClasses=5000;
  StatusFile="Sm.Sta";
  ConstFile="Sm.Con";
  ResFile="Sm.Res";
  HelpFile="Sm.hlp";
  envBUFSIZE=500;

//------------- Настраиваемые -----------------

const
  _ediTrackX  =10;
  _genBASECODE=0x400000;
  _genSTACKMAX=0x100000;
  _genSTACKMIN=0x2000;
  _genHEAPMAX=0x100000;
  _genHEAPMIN=0x1000;
  _genCLASSSIZE=512;
  _envEDITBK=0xFFFFFF;
  _envEDITSEL=0x808080;
  _envTRACKMAX=200;
  _envTRACKUP=4;
  _envWIN32="Win32.hlp";
  _envEXTM="m";
  _envEXTD="d";
  _envEXTI="i";
  _envBMPE="MSPaint.exe";
  _resWIN32="Win32.i";

//настройка языка интерфейса

type classER=(erRussian,erEnglish);
type stringER=array[classER]of pstr;

  const
    ProgName=stringER{"Странник Модула-Си-Паскаль","Strannik Modula-C-Pascal"};
    _Повторный_идентификатор=stringER{"Повторный идентификатор","Duplicate identifier"};
    _ОШИБКА_Идентификатор_без_имени=stringER{"ОШИБКА:Идентификатор без имени","ERROR:Identifier without name"};
    _Неверный_номер_модуля=stringER{"Неверный номер модуля","Incorrect module number"};
    _Не_найден_модуль_=stringER{"Не найден модуль:","Undefined module:"};
    _В_модуле_не_найден_идентификатор_=stringER{"В модуле не найден идентификатор:","Undefined identifier:"};
    _Системная_в_tabSubs_=stringER{"Системная в tabSubs:","System error in tabSubs:"};
    _Импорт_=stringER{"Импорт ","Import "};
    _Системная_ошибка_в_idRead=stringER{"Системная ошибка в idRead","System error in idRead"};
    _Неинициализирован_список_импорта=stringER{"Неинициализирован список импорта","Uninitial import list"};
    _Слишком_много_вызовов_DLL=stringER{"Слишком много вызовов DLL","Too much DLL calls"};
    _Слишком_много_экспортируемых_имен=stringER{"Слишком много экспортируемых имен","Too much export identifier"};
    _Переполнение_списка_строковых_констант=stringER{"Переполнение списка строковых констант","Too much string constant"};
    _Прекратить_обработку__=stringER{"Прекратить обработку ?","Abort process ?"};
    _Слишком_много_разделов_IF_или_CASE=stringER{"Слишком много разделов IF или CASE","Too much items in IF or CASE"};
    _Системная_в_genSetJamp_=stringER{"Системная в genSetJamp:","System error in genSetJamp:"};
    _Слишком_много_вызовов_процедур_в_модуле=stringER{"Слишком много вызовов процедур в модуле","Too much procedure calls"};
    _Не_определена_процедура_=stringER{"Не определена процедура:","Undefined procedure:"};
    _Системная_ошибка_в_GenSetCalls=stringER{"Системная ошибка в GenSetCalls","System error in GenSetCalls"};
    _Слишком_много_обращений_к_переменным_в_модуле=stringER{"Слишком много обращений к переменным в модуле","Too much variable calls"};
    _Слишком_много_вызовов_внешних_процедур_в_модуле=stringER{"Слишком много вызовов внешних процедур в модуле","Too much external procedure calls"};
    _Не_найден_идентификатор_=stringER{"Не найден идентификатор:","Undefined identifier:"};
    _Не_найдена_функция_=stringER{"Не найдена функция:","Undefined function:"};
    _Слишком_много_структурных_констант=stringER{"Слишком много структурных констант","Too much structured constant"};
    _Слишком_большой_код=stringER{"Слишком большой код","Too much code"};
    _genPref_Системная_ошибка=stringER{"genPref:Системная ошибка","System error in genPref"};
    _Место_ошибки_обнаружено=stringER{"Место ошибки обнаружено","Error located"};
    _Неверная_команда__genPost_=stringER{"Неверная команда (genPost)","Undefined command (genPost)"};
    _Неверные_операнды=stringER{"Неверные операнды","Operand error"};
    _Системная_в_GenSeg=stringER{"Системная в GenSeg","System error in GenSeg"};
    _Системная_в_GenRR=stringER{"Системная в GenRR","System error in GenRR"};
    _Системная_в_GenRD=stringER{"Системная в GenRD","System error in GenRD"};
    _Системная_в_GenMR_=stringER{"Системная в GenMR:","System error in GenMR:"};
    _Системная_в_GenMD=stringER{"Системная в GenMD","System error in GenMD"};
    _регистр=stringER{"регистр","register"};
    _Системная_в_GenR=stringER{"Системная в GenR","System error in GenR"};
    _память=stringER{"память","memory"};
    _Системная_в_GenM_=stringER{"Системная в GenM:","System error in GenM:"};
    _Системная_в_GenD=stringER{"Системная в GenD","System error in GenD"};
    _Системная_ошибка_в_genGen_=stringER{"Системная ошибка в genGen:","System error in genGen:"};
    _Системная_ошибка_в_genRCL=stringER{"Системная ошибка в genRCL","System error in genRCL"};
    _Системная_в_genSize=stringER{"Системная в genSize","System error in genSize"};
    _Системная_в_genSize_2=stringER{"Системная в genSize 2","System error in genSize 2"};
    _Системная_ошибка_в_genTrackResName=stringER{"Системная ошибка в genTrackResName","System error in genTrackResName"};
    _Не_определена_точка_входа_=stringER{"Не определена точка входа:","Undefined point enter:"};
    _EXE_файл_занят_другим_приложением_=stringER{"EXE-файл занят другим приложением:","EXE-file occupied:"};
    _Слишком_много_модулей=stringER{"Слишком много модулей","Too much modules"};
    _Слишком_длинное_константое_выражение=stringER{"Слишком длинное константое выражение","Too mach const expression"};
    _Деление_на_ноль=stringER{"Деление на ноль","Divide by zero"};
    _Слишком_длинная_строковая_константа=stringER{"Слишком длинная строковая константа","Too much string constant"};
    _Ожидалось_=stringER{"Ожидалось ","Expected "};
    _Слишком_много_меток=stringER{"Слишком много меток","Too mach labels"};
    _Метка_уже_имеется=stringER{"Метка уже имеется","Label already is present"};
    _Метка_уже_использована=stringER{"Метка уже использована","Label is already used"};
    _Слишком_много_команд_перехода=stringER{"Слишком много команд перехода","Too mach jamp"};
    _Неверный_размер_операндов=stringER{"Неверный размер операндов","Incorrect size of operands"};
    _Ожидалась_константа=stringER{"Ожидалась константа","Constant expected"};
    _Ожидалось_имя_переменной=stringER{"Ожидалось имя переменной","Variable name expected"};
    _Неверный_операнд=stringER{"Неверный операнд","Incorrect operand"};
    _Ожидалась_метка=stringER{"Ожидалась метка","Label expected"};
    _Системная_в_asmCommand=stringER{"Системная в asmCommand","System error in asmCommand"};
    _Неверный_номер_прерывания=stringER{"Неверный номер прерывания","Incorrect interrupt number"};
    _Ошибочный_операнд=stringER{"Ошибочный операнд","Incorrect operand"};
    _Неопределенная_метка=stringER{"Неопределенная метка","Undefined label"};
    _Слишком_длинный_переход_на_метку_=stringER{"Слишком длинный переход на метку ","Too long jamp to label "};
    _Отсутствует_описание_типа_=stringER{"Отсутствует описание типа:","Type definition expected:"};
    _Слишком_много_диалогов_в_модуле=stringER{"Слишком много диалогов в модуле","Too much dialogs in module"};
    _Слишком_много_элементов_в_диалоге=stringER{"Слишком много элементов в диалоге","Too much items in dialog"};
    _Слишком_много_bitmap_в_модуле=stringER{"Слишком много bitmap в модуле","Too much bitmap in module"};
    _Отсутствует_BMP_файл_=stringER{"Отсутствует BMP-файл:","BMP-file expected:"};
    _BMP_файл_неверного_формата_=stringER{"BMP-файл неверного формата:","Incorrect format of BMP-file:"};
    _Ожидалось_значение_константы=stringER{"Ожидалось значение константы","Constant value expected"};
    _Ожидалось_число=stringER{"Ожидалось число","Number expected"};
    _Ошибка_в_описании_типа=stringER{"Ошибка в описании типа","Type definition error"};
    _Ожидалось_описание_типа=stringER{"Ожидалось описание типа","Type definition expected"};
    _Ожидалось_целое_число=stringER{"Ожидалось целое число","Integer expected"};
    _Ожидался_символ=stringER{"Ожидался символ","Symbol expected"};
    _Ожидалась_константа_TRUE_или_FALSE=stringER{"Ожидалась константа TRUE или FALSE","TRUE or FALSE expected"};
    _Ожидалось_целое_или_nil=stringER{"Ожидалось целое или nil","Integer or nil expected"};
    _Ожидалась_строка_или_nil=stringER{"Ожидалась строка или nil","String or nil expected"};
    _Ожидалось_множество=stringER{"Ожидалось множество","Set expected"};
    _Неверный_тип_в_структурной_константе=stringER{"Неверный тип в структурной константе","Incorrect type"};
    _Ожидалась_строка=stringER{"Ожидалась строка","String expected"};
    _Слишком_длинная_строка=stringER{"Слишком длинная строка","Too long string"};
    _Ожидалась_константа_скалярного_типа_=stringER{"Ожидалась константа скалярного типа ","Constant expected "};
    _Неверный_тип_в_структурной_константе_=stringER{"Неверный тип в структурной константе:","Incorrect type:"};
    _Ожидалось__=stringER{"Ожидалось ]","] expected"};
    _Ожидался_тип_перечисления=stringER{"Ожидался тип перечисления","Scalar expected"};
    _Ожидалась_целая_константа=stringER{"Ожидалась целая константа","Integer constant expected"};
    _Неверный_тип_индекса=stringER{"Неверный тип индекса","Incorrect index type"};
    _Неверный_диапазон_индексов=stringER{"Неверный диапазон индексов","Incorrect index range"};
    _Повторное_имя_поля_=stringER{"Повторное имя поля:","Duplicate field name:"};
    _Ожидалось_новое_имя=stringER{"Ожидалось новое имя","New name expected"};
    _Неверная_операция_BYTE=stringER{"Неверная операция BYTE","Incorrect BYTE operation"};
    _Неверная_операция_WORD=stringER{"Неверная операция WORD","Incorrect WORD operation"};
    _Неверная_операция_LONG=stringER{"Неверная операция LONG","Incorrect LONG operation"};
    _Неверная_операция_REAL=stringER{"Неверная операция REAL","Incorrect REAL operation"};
    _Отсутствует_модуль_=stringER{"Отсутствует модуль:","Module expected:"};
    _Не_компилирован_модуль_=stringER{"Не компилирован модуль:","Module is not compiling:"};
    _Ожидался_definition_модуль=stringER{"Ожидался definition модуль","Definition module expected"};
    _Ожидался_программный_модуль=stringER{"Ожидался программный модуль","Program module expected"};
    _Ожидалось_имя_модуля_=stringER{"Ожидалось имя модуля:","Module name expected:"};
    _Ожидалось_имя_модуля=stringER{"Ожидалось имя модуля","Module name expected"};
    _ASCII_функция_допустима_только_в_def_модуле=stringER{"ASCII-функция допустима только в def-модуле","ASCII-function is admitted only in the def-module"};
    _Системная_ошибка_в_traPROC=stringER{"Системная ошибка в traPROC","System error in traPROC"};
    _Ожидалось_имя_процедуры_=stringER{"Ожидалось имя процедуры:","Procedure name expected:"};
    _Неверный_тип_результата_функции=stringER{"Неверный тип результата функции","Incorrect type of function result"};
    _Слишком_много_параметров=stringER{"Слишком много параметров","Too much parameters"};
    _Несоотвествие_количества_параметров=stringER{"Несоотвествие количества параметров","Incorrect amount of parameters"};
    _Несоотвествие_имени_параметра=stringER{"Несоотвествие имени параметра","Incorrect parameter name"};
    _Несоотвествие_класса_параметра=stringER{"Несоотвествие класса параметра","Incorrect parameter class"};
    _Слишком_много_вложенных_вызовов_функций=stringER{"Слишком много вложенных вызовов функций","Too much function calls"};
    __и_=stringER{" и "," and "};
    _Несоответствие_типов__=stringER{"Несоответствие типов: ","Type mismatch: "};
    _Системная_в_traCALL=stringER{"Системная в traCALL","System error in traCALL"};
    _Недопустимая_константа=stringER{"Недопустимая константа","Incorrect constant"};
    _Ожидалось_целое=stringER{"Ожидалось целое","Integer expected"};
    _Неверный_тип_переключателя=stringER{"Неверный тип переключателя","Incorrect type"};
    _Недопустимый_тип_счетчика_цикла=stringER{"Недопустимый тип счетчика цикла","Incorrect type"};
    _Ожидалась_переменная_запись=stringER{"Ожидалась переменная-запись","Record variable expected"};
    _Слишком_много_вложенных_WITH=stringER{"Слишком много вложенных WITH","Too much WITH"};
    _Директива_FROM_может_быть_только_в_def_модуле=stringER{"Директива FROM может быть только в def-модуле","FROM is admitted only in the def-module"};
    _Ожидалось_имя_DLL=stringER{"Ожидалось имя DLL","DLL name expected"};
    _Неверный_тип_переменной=stringER{"Неверный тип переменной","Incorrect type"};
    _Неверный_тип_выражения=stringER{"Неверный тип выражения","Incorrect type"};
    _Слишком_много_указателей=stringER{"Слишком много указателей","Too much pointers"};
    _Ожидалась_переменная=stringER{"Ожидалась переменная","Variable expected"};
    _Ожидался_тип_указатель=stringER{"Ожидался тип указатель","Pointer expected"};
    _Неопределенный_тип_указатель=stringER{"Неопределенный тип указатель","Undefined pointer"};
    _Ожидался_тип_запись=stringER{"Ожидался тип запись","Record expected"};
    _Ожидалось_имя_поля_=stringER{"Ожидалось имя поля:","Field name expected:"};
    _Ожидалось_имя_поля=stringER{"Ожидалось имя поля","Field name expected"};
    _Ожидался_массив=stringER{"Ожидался массив","Array expected"};
    _Системная_ошибка_в_traLOAD=stringER{"Системная ошибка в traLOAD","System error in traLOAD"};
    _Неверное_преобразование_типов=stringER{"Неверное преобразование типов","Incorrect typecast"};
    _переменная=stringER{"переменная","variable"};
    _Функция_не_возвращает_значения=stringER{"Функция не возвращает значения","The function does not return value"};
    _Ожидалось_int=stringER{"Ожидалось int","int expected"};
    _Ожидалось_выражение=stringER{"Ожидалось выражение","Expression expected"};
    _Ожидалось_имя_типа=stringER{"Ожидалось имя типа","Type name expected"};
    _Ожидалось_вещественное_число=stringER{"Ожидалось вещественное число","Float expected"};
    _Неверный_тип=stringER{"Неверный тип","Incorrect type"};
    _Неверный_тип_в_операциях_с_множеством=stringER{"Неверный тип в операциях с множеством","Incorrect type"};
    _Неверный_тип_в_операции_сравнения=stringER{"Неверный тип в операции сравнения","Incorrect type"};
    _Ожидался_тип_int=stringER{"Ожидался тип int","int expected"};
    _Ошибочный_тип=stringER{"Ошибочный тип","Incorrect type"};
    _Функция_main_не_должна_иметь_парамеров=stringER{"Функция main не должна иметь параметров","The main function should not have parameters"};
    _Системная_ошибка_в_tracPROC=stringER{"Системная ошибка в tracPROC","System error in tracPROC"};
    _Ожидался_список_переменных=stringER{"Ожидался список переменных","Variable list expected"};
    _Функция_main_не_должна_иметь_локальных_переменных=stringER{"Функция main не должна иметь локальных переменных","The main function should not have local variable"};
    _Ожидался_список_переменных_или_функция=stringER{"Ожидался список переменных или функция","Variable list or function expected"};
    _Системная_в_tracCALL=stringER{"Системная в tracCALL","System error in tracCALL"};
    _Ожидался_счетчик_цикла_=stringER{"Ожидался счетчик цикла:","The counter of a cycle was expected:"};
    _Ожидалось_условие_окончания_цикла=stringER{"Ожидалось условие окончания цикла","The condition of the termination of a cycle was expected"};
    _Ожидалось_имя_функции_=stringER{"Ожидалось имя функции:","Function name expected:"};
    _Ожидалось_имя_функции=stringER{"Ожидалось имя функции","Function name expected"};
    _Слишком_много_стилей=stringER{"Слишком много стилей","Too much styles"};
    _Текст_=stringER{"Текст:","Text:"};
    _Класс_=stringER{"Класс:","Class:"};
    _Ид_=stringER{"Ид:","Id:"};
    _Загрузка_списка_стилей_из_=stringER{"Загрузка списка стилей из ","Loading styles from "};
    _Нельзя_добавлять_пустой_стиль=stringER{"Нельзя добавлять пустой стиль","It is impossible to add empty style"};
    _Нельзя_добавлять_повторный_стиль=stringER{"Нельзя добавлять повторный стиль","It is impossible to add repeated style"};
    _ОШИБКА_Clipboard_занят_другим_приложением=stringER{"ОШИБКА:Clipboard занят другим приложением","ERROR:Clipboard is occupied in other application"};
    _ОШИБКА_Неверный_формат_данных_в_Clipboard=stringER{"ОШИБКА:Неверный формат данных в Clipboard","ERROR:Incorrect data format in Clipboard"};
    _Неверные_данные_в_Clipboard=stringER{"Неверные данные в Clipboard","Incorrect data in Clipboard"};
    _Системная_ошибка_Неверные_данные_в_буфере_отката_=stringER{"Системная ошибка:Неверные данные в буфере отката:","System error:Incorrect data in undo buffer:"};
    _Новый=stringER{"Новый","New"};
    _Правка=stringER{"Правка","Edit"};
    _Выровнять=stringER{"Выровнять","Align"};
    _Диалог=stringER{"Диалог","Dialog"};
    _Ок=stringER{"Ок","Ok"};
    _Отмена=stringER{"Отмена","Cancel"};
    _Ошибка_регистрации_класса_элемента=stringER{"Ошибка регистрации класса элемента","Error registration class"};
    _Ошибка_регистрации_класса_диалога=stringER{"Ошибка регистрации класса диалога","Error registration class"};
    _ОШИБКА=stringER{"ОШИБКА","ERROR"};
    _ИмяДиалога=stringER{"ИмяДиалога","DialogName"};
    _Слишком_много_классов=stringER{"Слишком много классов","Too much classes"};
    _Нет_классов_в_списке=stringER{"Нет классов в списке","No classes in the list"};
    _Заменить_все_значения_на_значения_по_умолчанию__=stringER{"Заменить все значения на значения по умолчанию ?","Set standard values ?"};
    _Константа_=stringER{"Константа:","Constant:"};
    _Базовый_тип_=stringER{"Базовый тип:","Base type:"};
    _Массив_=stringER{"Массив[","Array["};
    _Указатель_на_=stringER{"Указатель на ","Pointer to "};
    _Тип_перечисления=stringER{"Тип перечисления","Scalar type"};
    _Поле_записи=stringER{"Поле записи","Record field"};
    _Параметр_процедуры=stringER{"Параметр процедуры","Function parameter"};
    _Переменная=stringER{"Переменная","Variable"};
    _Переменная_процедуры=stringER{"Переменная процедуры","Local variable"};
    _Параметр_процедуры__VAR_=stringER{"Параметр процедуры (VAR)","Function parameter (VAR)"};
    _Имя_модуля=stringER{"Имя модуля","Module name"};
    _Зарезервированный_идентификатор=stringER{"Зарезервированный идентификатор","Reserved identificator"};
    _Системная_ошибка_Невозможно_получить_шрифт=stringER{"Системная ошибка:Невозможно получить шрифт","System error:impossible to receive the font"};
    _Изменен=stringER{"Изменен","Modified"};
    _Строка__li=stringER{"Стр %li","Line %li"};
    __Колонка__li=stringER{" Кол %li"," Col %li"};
    __Строк__li=stringER{" Строк %li"," Lines %li"};
    __Память__li_К=stringER{" Память %li К"," Memory %li K"};
    _Ошибка_в_ediStatusOtr_однострочный_блок=stringER{"Ошибка в ediStatusOtr,однострочный блок","System error in ediStatusOtr"};
    _Ошибка_в_envStatusOtr_многострочный_блок=stringER{"Ошибка в envStatusOtr,многострочный блок","System error in envStatusOtr"};
    _Вставка_блока=stringER{"Вставка блока","Вставка блока"};
    _Удаление_блока=stringER{"Удаление блока","Deleting text"};
    _Загрузка_файла_=stringER{"Загрузка файла:","Loading file:"};
    _Неудача_при_открытии_файла_=stringER{"Неудача при открытии файла:","Failure at opening the file:"};
    _Слишком_много_окон=stringER{"Слишком много окон","Too much windows"};
    _В_окне_несохраненный_текст__Сохранить__=stringER{"В окне несохраненный текст. Сохранить ?","Text was modified. Save it ?"};
    _Файл_уже_существует__Переписать__=stringER{"Файл уже существует. Переписать ?","The file already exists. Rewrite it ?"};
    _В_окне_несохраненный_текст__Сохранить_=stringER{"В окне несохраненный текст. Сохранить?","Text was modified. Save it ?"};
    _КОМПИЛЯЦИЯ=stringER{"КОМПИЛЯЦИЯ","COMPILING"};
    _Инициализация_таблиц=stringER{"Инициализация таблиц","Initialization of the tables"};
    _Генерация_i_файла=stringER{"Генерация i-файла","i-file created"};
    _Генерация_exe_dll__файла=stringER{"Генерация exe(dll)-файла","Exe(dll)-file created"};
    __13_10_Список_переменных=stringER{"\13\10 Список переменных","\13\10 Variable list"};
    __13_10_Список_функций=stringER{"\13\10 Список функций","\13\10 Function list"};
    __код__lx=stringER{":код %lx",":code %lx"};
    __строки__li=stringER{":строки %li",":line %li"};
    __13_10_Список_строк=stringER{"\13\10 Список строк","\13\10 Lines list"};
    _Место_ошибки_не_обнаружено=stringER{"Место ошибки не обнаружено","The place of an error is not revealed"};
    _Отсутствует_файл_=stringER{"Отсутствует файл:","File expected:"};
    _Ошибка_при_создании_диалога=stringER{"Ошибка при создании диалога","Create dialog error"};
    _Фрагмент_не_найден=stringER{"Фрагмент не найден","Text is not found"};
    _Не_установлен_фрагмент_для_поиска=stringER{"Не установлен фрагмент для поиска","Find text is not set"};
    _Заменить_фрагмент__=stringER{"Заменить фрагмент ?","Replace text ?"};
    _ОШИБКА_ПРИ_ЗАПУСКЕ_ПРОГРАММЫ=stringER{"ОШИБКА ПРИ ЗАПУСКЕ ПРОГРАММЫ","RUN ERROR"};
    _Создать_новый_диалог__=stringER{"Создать новый диалог ?","Create new dialog ?"};
    _Нет_файла=stringER{"Нет файла","File expected"};
    _Загрузка_списка_идентификаторов_из_=stringER{"Загрузка списка идентификаторов из ","Loading identifiers from "};
    _Нет_информации__Пожалуйста__произведите_компиляцию_=stringER{"Нет информации. Пожалуйста, произведите компиляцию.","Not information. Compiling, please."};
    _Неизвестный_идентификатор_=stringER{"Неизвестный идентификатор:","Indefined identifier:"};
    _В_карман=stringER{"В карман","Copy"};
    _Неверный_цвет=stringER{"Неверный цвет","Incorrect color"};
    _Английский_малый=stringER{"Английский малый","English small"};
    _Английский_большой=stringER{"Английский большой","English large"};
    _Русский_малый=stringER{"Русский малый","Russian small"};
    _Русский_большой=stringER{"Русский большой","Russian large"};
    _Неверный_цвет_=stringER{"Неверный цвет:","Incorrect color:"};
    _Ошибка_регистрации_класса_Stran32Env=stringER{"Ошибка регистрации класса Stran32Env","Class registration error:Stran32Env"};
    _Ошибка_при_создании_окна_editWnd=stringER{"Ошибка при создании окна editWnd","Create window error:editWnd"};
    _Ошибка_регистрации_класса_Stran32=stringER{"Ошибка регистрации класса Stran32","Class registration error:Stran32"};
    _Ошибка_открытия_окна=stringER{"Ошибка открытия окна","Create window error"};
    _Системная_ошибка_в_stepPop=stringER{"Системная ошибка в stepPop","System error in stepPop"};
    _Ошибка_получения_контекста_процесса=stringER{"Ошибка получения контекста процесса","Error get context process"};
    _Ошибка_чтения_данных_со_стека=stringER{"Ошибка чтения данных со стека","Error get stack process"};
    _Ошибка_чтения_данных_процесса=stringER{"Ошибка чтения данных процесса","Error get process data"};
    _Слишком_много_точек_останова=stringER{"Слишком много точек останова","Too many breakpoint"};
    _Системная_ошибка_в_отлУдалитьBreak=stringER{"Системная ошибка в отлУдалитьBreak","System error in otlDeleteBreak"};
    _Точка_прерывания_содержится_в_строке__li_в_модуле_=stringER{"Точка прерывания содержится в строке %li в модуле ","Breakpoint into %li line in module "};
    _Ошибка_процесса__lx_=stringER{"Ошибка процесса %lx ","Process error %li"};
    __по_адресу__lx_=stringER{" по адресу %lx "," in address %lx"};
    _Ошибка_определения_адреса_остановки=stringER{"Ошибка определения адреса остановки","Error of definition of the breakpoint"};
    _Ошибка_определения_адреса_остановки__2_=stringER{"Ошибка определения адреса остановки (2)","Error of definition of the breakpoint (2)"};
    _Системная_ошибка_в_отлИнициировать=stringER{"Системная ошибка в отлИнициировать","System error in otlInit"};
    _Неудача_создания_таймера_отладки=stringER{"Неудача создания таймера отладки","Failure of created debug timer"};
    _Неудача_запуска_файла_=stringER{"Неудача запуска файла:","Failure of run of file:"};
    _Системная_ошибка_в_отлЗакончить=stringER{"Системная ошибка в отлЗакончить","System error in otlEnd"};
    _Ошибка_поиска_точки_входа=stringER{"Ошибка поиска точки входа","Error of find of procedure enter"};
    _Ошибка_поиска_точки_возврата=stringER{"Ошибка поиска точки возврата","Error of find of procedure return"};
    _Системная_в_отлРасставитьBreak__1_=stringER{"Системная в отлРасставитьBreak (1)","System error in otlReasstavitBreak (1)"};
    _Системная_в_отлРасставитьBreak__2_=stringER{"Системная в отлРасставитьBreak (2)","System error in otlReasstavitBreak (2)"};
    _Системная_в_отлРасставитьBreak__3_=stringER{"Системная в отлРасставитьBreak (3)","System error in otlReasstavitBreak (3)"};
    _Системная_в_отлРасставитьBreak__4_=stringER{"Системная в отлРасставитьBreak (4)","System error in otlReasstavitBreak (4)"};
    _Отладчик_уже_запущен=stringER{"Отладчик уже запущен","Debugger already run"};
    _Отладчик_не_запущен=stringER{"Отладчик не запущен","Debugger not run"};
    _Нет_кода_для_текущей_строки=stringER{"Нет кода для текущей строки","No code for this line"};
    _Сеанс_отладки_завершен=stringER{"Сеанс отладки завершен","Debug stopped"};
    _Отладка=stringER{"Отладка","Debugged"};
    _Ожидание=stringER{"Ожидание","Running"};
    _Чтение_значения_переменной=stringER{"Чтение значения переменной","Reading variable value"};
    _Ожидалось_имя_класса=stringER{"Ожидалось имя класса","Class name expected"};
    _Ожидался_класс=stringER{"Ожидался класс","Class expected"};
    _Слишком_много_вложенных_переменных=stringER{"Слишком много вложенных переменных","Too many nested variables"};
    _Переполнение_списка_идентификаторов=stringER{"Переполнение списка идентификаторов","Too many names"};
    _Переполнение_списка_замен=stringER{"Переполнение списка замен","Too many substitutions"};
    _Превышение_размера_таблицы_классов=stringER{"Превышение размера таблицы классов","Class table overflow"};
    _Недопустимая_переменная=stringER{"Недопустимая переменная","Incorrect variable"};
    _Несовпадение_списка_параметров_виртуального_метода_=stringER{"Несовпадение списка параметров виртуального метода:","Incorrect parameter list of virtual method"};
    _Нарушение_прав_доступа=stringER{"Нарушение прав доступа","Violation of access rights"};
    _Повторное_имя_метода=stringER{"Повторное имя метода","Method name duplicated"};

//шрифты,зарезервированные идентификаторы,базовые типы

var
  ediTrackX:integer;
  genBASECODE:integer;
  genSTACKMAX:integer;
  genSTACKMIN:integer;
  genHEAPMAX:integer;
  genHEAPMIN:integer;
  genCLASSSIZE:integer;
  envEDITBK:integer;
  envEDITSEL:integer;
  envTRACKMAX:integer;
  envTRACKUP:integer;
  envWIN32:pstr;
  envEXTM:pstr;
  envEXTD:pstr;
  envEXTI:pstr;
  envBMPE:pstr;
  envExeFolder:pstr;
  resWIN32:pstr;

  type pinteger=pointer to integer;

//===============================================
//             ИНТЕГРИРОВАННАЯ СРЕДА
//===============================================

type classLANG=(langMODULA,langC,langPASCAL);

const
  ButtonStyle=WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON;
  StaticStyle=WS_CHILD | WS_VISIBLE | SS_CENTER;
  EditorStyle=WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP;
  ListboxStyle=WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER;

//---------------- Команды --------------------

type
  classComm=(comNULL,
    cFilNew,cFilOpen,cFilOpenCar,cFilSave,cFilSaveAs,cFilClose,cSEP1,cFilExit,
    cBlkUndo,cSEP2,cBlkCut,cBlkCopy,cBlkPaste,cBlkDel,cSEP3,cBlkAll,
    cFindFind,cFindNext,cFindRepl,
    cComComp,cComAll,cComDll,cSEP4,cComRun,
    cDebRun,cDebEnd,cDebRunEnd,cSEP41,cDebNextDown,cDebNext,cDebGoto,cSEP42,cDebView,
    cUtilId,cSEP5,cUtilRes,cUtilErr,
    cSetComp,cSetEnv,cSetDlg,cSEP6,cSetMain,cSetClear,
    cHlpCont,cHlpWin32,cSEP7,cHlpAbout,
    cLanguige,cExit);
  classGroup=(gNULL,gFil,gBlk,gFind,gCom,gDeb,gUtil,gSet,gHlp,gLanguige,gExit);

type arrCommand=array[classER]of array[classComm]of pstr;
const setCommand=arrCommand{{"",
    "&Новый","&Открыть","Открыть &перед текущим","&Сохранить\9F2","Сохранить &Как ...","&Закрыть\9Ctrl+F4","","&Выход\9Alt+F4",
    "&Отменить\9Ctrl+Backspace","","&Вырезать\9Shift+Delelte","&Копировать\9Ctrl+Insert","В&ставить\9Shift+Insert","&Удалить\9Delete","","В&ыделить все",
    "&Поиск\9Ctrl+F3","&Следующий поиск\9F3","Поиск и &замена\9Shift+F3",
    "&Компилировать\9Alt+F9","Компилировать &все\9F9","Компилировать &DLL","","&Запустить\9Ctrl+F9",
    "&Запустить под отладчиком","Закончить &отладку","Запустить &далее","","&Следующий шаг\9F7","Следующий шаг (&без входа в процедуру)\9F8","&Перейти в текущую строку\9F4","","Показать п&еременную",
    "&Идентификатор\9Ctrl+F1","","&Редактировать ресурс","&Поиск Ошибки",
    "Настройки &компилятора","Настройки &интегрированной среды","Настройки &редактора диалогов","","&Установить главный файл","&Сбросить главный файл",
    "&Интегрированная среда и языки программирования","Справочник по &Win32","","О &Программе",
    "&English","&Выход"},
   {"",
    "&New","&Open","Open &before","&Save\9F2","Save &As ...","&Close\9Ctrl+F4","","&Exit\9Alt+F4",
    "&Undo\9Ctrl+Backspace","","&Cut\9Shift+Delelte","&Copy\9Ctrl+Insert","&Paste\9Shift+Insert","C&lear\9Delete","","&Select all",
    "&Find\9Ctrl+F3","&Next find\9F3","Find and &repalce\9Shift+F3",
    "&Compile\9Alt+F9","&Make all\9F9","Compile &DLL","","&Run\9Ctrl+F9",
    "&Run debugger","Stop &debugged","Run to &end","","&Next step\9F7","Next step (&without proc enter)\9F8","&Go to current line\9F4","","&View variables",
    "&Identifier\9Ctrl+F1","","&Edit resurce","&Find error",
    "&Compiler options","&Editor options","&Dialog editor options","","&Set main file","&Reset main file",
    "&Editor and programming languages","Help on &Win32","","&About",
    "&Russian","&Exit"}};

//номера bitmap от 1
type arrButtons=array[classComm]of integer;
const setButtons=arrButtons{0,
    26,1,0,2,0,4,0,0,
    24,0,5,6,7,8,0,0,
    9,10,11,
    12,13,27,0,14,
    28,29,0,0,30,31,33,0,32,
    15,0,16,17,
    0,0,0,0,20,21,
    0,0,0,0,
    0,0};

type arrGroup=array[classER]of array[classGroup]of record
  grName:pstr;
  grLo,grHi:classComm;
end;
const setGroup=arrGroup{{
  {"",comNULL,comNULL},
  {"&Файл",cFilNew,cFilExit},
  {"&Правка",cBlkUndo,cBlkAll},
  {"&Поиск",cFindFind,cFindRepl},
  {"&Компилятор",cComComp,cComRun},
  {"&Отладка",cDebRun,cDebView},
  {"&Инструменты",cUtilId,cUtilErr},
  {"&Настройка",cSetComp,cSetClear},
  {"&Помощь",cHlpCont,cHlpAbout},
  {"&English",cLanguige,cLanguige},
  {"&Выход",cExit,cExit}},
{
  {"",comNULL,comNULL},
  {"&File",cFilNew,cFilExit},
  {"&Edit",cBlkUndo,cBlkAll},
  {"F&ind",cFindFind,cFindRepl},
  {"&Compile",cComComp,cComRun},
  {"&Debugged",cDebRun,cDebView},
  {"&Tools",cUtilId,cUtilErr},
  {"&Options",cSetComp,cSetClear},
  {"&Help",cHlpCont,cHlpAbout},
  {"&Russian",cLanguige,cLanguige},
  {"&Exit",cExit,cExit}}};

//-------------- Разделители ------------------

type classPARSE=(pNULL,
       pPlu,pMin,pDiv,pPro,pMul,pVer,pVos,pVol,pRes,pDol,pPoi,pAmp,pUg,pSob,
       pOvR,pOvL,pFiL,pFiR,pSem,pDup,pSqR,pSqL,pCol,
       pUgR,pEqv,pUgL,
       pPluPlu,pMinMin,pPluEqv,pMinEqv,pDivDiv,pVosEqv,pVerVer,pSobSob,pPoiPoi,pDolDol,pDupDup,pDupEqv,
       pDivMul,pMulDiv,
       pUgLUgL,pUgRUgR,pMinUgR,pEqvEqv,pUgREqv,pUgLUgR,pUgLEqv);

const loPARSE=pPlu; hiPARSE=pUgLEqv;
type arrPARSE=array[classPARSE]of pstr;
const namePARSE=arrPARSE{'',
      '+','-','/','%','*','|','!','~','#','$','.','@','^','&',
      ')',"(",'{','}',';',':',']','[',',',
      '>','=','<',
      '++','--','+=','-=','//','!=','||','&&','..','$$','::',':=',
      "/*","*/",
      '<<','>>','->','==','>=','<>','<='};

//------- Зарезервированные имена -------------

type classREZ=(rezNULL,
               rADDR,rAND,rARRAY,rASCII,rASM,rBEGIN,rBITMAP,rBREAK,rCASE,rCLASS,rCONST,rCONTROL,
               rDEC,rDEFINE,rDEFAULT,rDEFINITION,rDIALOG,rDIV,rDO,rDOWNTO,
               rELSE,rELSIF,rEND,rENUM,rEXIT,rEXPORT,rFALSE,rFOR,rFORWARD,rFROM,rFUNCTION,rHIBYTE,rHIWORD,
               rICON,rIF,rIMPLEMENTATION,rIMPORT,rIN,rINC,rINCLUDE,rLOBYTE,rLOWORD,
               rMOD,rMODULE,rNEW,rNIL,rNOT,rNULL,rOBJECT,rOF,rOFFS,rOR,rORD,rPOINTER,rPRIVATE,rPROCEDURE,rPROTECTED,rPROGRAM,rPUBLIC,
               rRECORD,rREPEAT,rRETURN,rSET,rSIZEOF,rSTRING,rSTRONG,rSTRUCT,rSWITCH,
               rTHEN,rTO,rTRUE,rTRUNC,rTYPE,rTYPEDEF,
               rUNION,rUNIT,rUNSIGNED,rUNTIL,rUSES,rVAR,rVIRTUAL,rVOID,rWITH,rWHILE);
type classSET=(setSmEn,setBiEn,setSmRu,setBiRu);
const loREZ=rADDR; hiREZ=rWHILE;
type arrREZ=array[classSET]of array[classREZ]of pstr;
const nameREZ=arrREZ{
              {'',
               'addr','and','array','ascii','asm','begin','bitmap','break','case','class','const','control',
               'dec','define','default','definition','dialog','div','do','downto',
               'else','elsif','end','enum','exit','export',
               'false','for','forward','from','function','hibyte','hiword',
               'icon','if','implementation','import','in','inc','include',
               'lobyte','loword','mod','module','new','nil','not','NULL',
               'object','of','offs','or','ord','pointer','private','procedure','protected','program','public',
               'record','repeat','return','set','sizeof','string','strong','struct','switch',
               'then','to','true','trunc','type','typedef',
               'union','unit','unsigned','until','uses','var','virtual','void','with','while'},
              {'',
               'ADDR','AND','ARRAY','ASCII','ASM','BEGIN','BITMAP','BREAK','CASE','CLASS','CONST','CONTROL',
               'DEC','DEFINE','DEFAULT','DEFINITION','DIALOG','DIV','DO','DOWNTO',
               'ELSE','ELSIF','END','ENUM','EXIT','EXPORT',
               'FALSE','FOR','FORWARD','FROM','FUNCTION','HIBYTE','HIWORD',
               'ICON','IF','IMPLEMENTATION','IMPORT','IN','INC','INCLUDE',
               'LOBYTE','LOWORD','MOD','MODULE','NEW','NIL','NOT','NULL',
               'OBJECT','OF','OFFS','OR','ORD','POINTER','PRIVATE','PROCEDURE','PROTECTED','PROGRAM','PUBLIC',
               'RECORD','REPEAT','RETURN','SET','SIZEOF','STRING','STRONG','STRUCT','SWITCH',
               'THEN','TO','TRUE','TRUNC','TYPE','TYPEDEF',
               'UNION','UNIT','UNSIGNED','UNTIL','USES','VAR','VIRTUAL','VOID','WITH','WHILE'},
              {'',
               'адр','и','массив','ascii','асм','начало','битмап','прервать','выбор','класс','конст','элемент',
               'уменьш','эквивал','умолч','опред','диалог','дел','вып','вниз',
               'иначе','инесли','кон','перечисл','выход','экспорт',
               'ложь','для','предв','извл','функция','стбайт','стслово',
               'иконка','если','реализ','импорт','в','увел','включить',
               'млбайт','млслово','ост','модуль','новый','ноль','не','нуль',
               'объект','из','смещ','или','порядок','указ','приватный','процедура','защищенный','программа','публичный',
               'запись','повтор','возврат','множ','разм','строка','строго','структ','переключ',
               'то','к','истина','цел','тип','типопр',
               'объед','блок','беззнак','до','использовать','пер','виртуал','пусто','с','пока'},
              {'',
               'АДР','И','МАССИВ','ASCII','АСМ','НАЧАЛО','БИТМАП','ПРЕРВАТЬ','ВЫБОР','КЛАСС','КОНСТ','ЭЛЕМЕНТ',
               'УМЕНЬШ','ЭКВИВАЛ','УМОЛЧ','ОПРЕД','ДИАЛОГ','ДЕЛ','ВЫП','ВНИЗ',
               'ИНАЧЕ','ИНЕСЛИ','КОН','ПЕРЕЧИСЛ','ВЫХОД','ЭКСПОРТ',
               'ЛОЖЬ','ДЛЯ','ПРЕДВ','ИЗВЛ','ФУНКЦИЯ','СТБАЙТ','СТСЛОВО',
               'ИКОНКА','ЕСЛИ','РЕАЛИЗ','ИМПОРТ','В','УВЕЛ','ВКЛЮЧИТЬ',
               'МЛБАЙТ','МЛСЛОВО','ОСТ','МОДУЛЬ','НОВЫЙ','НОЛЬ','НЕ','НУЛЬ',
               'ОБЪЕКТ','ИЗ','СМЕЩ','ИЛИ','ПОРЯДОК','УКАЗ','ПРИВАТНЫЙ','ПРОЦЕДУРА','ЗАЩИЩЕННЫЙ','ПРОГРАММА','ПУБЛИЧНЫЙ',
               'ЗАПИСЬ','ПОВТОР','ВОЗВРАТ','МНОЖ','РАЗМ','СТРОКА','СТРОГО','СТРУКТ','ПЕРЕКЛЮЧ',
               'ТО','К','ИСТИНА','ЦЕЛ','ТИП','ТИПОПР',
               'ОБЪЕД','БЛОК','БЕЗЗНАК','ДО','ИСПОЛЬЗОВАТЬ','ПЕР','ВИРТУАЛ','ПУСТО','С','ПОКА'}
               };
var carSet:classSET;

//-------- Предопределенные типы --------------

type
  classTYPE=(typeNULL,
             typeBYTE,typeCHAR,
             typeWORD,
             typeBOOL,typeINT,typeDWORD,
             typePOINT,typePSTR,
             typeSET,
             typeREAL32,
             typeREAL);
const loType=typeBYTE; hiType=typeREAL;
type arrTYPE=array[classLANG]of array[classTYPE]of pstr;
const nameTYPE=arrTYPE{
  {"","byte","char","word","boolean","integer","cardinal","address","pstr","setbyte","real32","real"},
  {"","byte","char","word","bool","int","uint","pvoid","pchar","setbyte","float32","float"},
  {"","byte","char","word","boolean","integer","dword","address","pstr","setbyte","real32","real"}};

//-------- Механизмы отката --------------

type
  classUNDO=(undoNULL,
    undoInsChar,undoDelChar,undoBackChar,
    undoInsStr,undoDelStr,
    undoInsBlock,undoDelBlock);
  arrSetUndo=array[classER]of array[classUNDO]of pstr;

const setUndo=arrSetUndo{{"Отмена невозможна",
    "Отмена вставки символа\9Ctrl+Backspace","Отмена удаления символа\9Ctrl+Backspace","Отмена удаления символа\9Ctrl+Backspace",
    "Отмена Enter\9Ctrl+Backspace","Отмена Delete\9Ctrl+Backspace",
    "Отмена вставки блока\9Ctrl+Backspace","Отмена удаления блока\9Ctrl+Backspace"},
   {"Undo is impossible",
    "Undo symbol insert\9Ctrl+Backspace","Undo symbol delete\9Ctrl+Backspace","Undo symbol delete\9Ctrl+Backspace",
    "Undo Enter\9Ctrl+Backspace","Undo Delete\9Ctrl+Backspace",
    "Undo text insert\9Ctrl+Backspace","Undo text delete\9Ctrl+Backspace"}};

type
  recUndo=record
    Class:classUNDO;
    undoTxt:integer; //модуль до операции
    undoExt:integer; //расширение до операции
    posX,posY,posTrackX,posTrackY:integer; //позиция курсора до операции
    blockX,blockY,blockTrackX,blockTrackY:integer; //позиция курсора после операции
    undoChar:char; //удаленный символ
    undoBlock:pstr; //удаленный блок
  end;
  arrUndo=array[1..maxUNDO]of recUndo;

//===============================================
//               ГЕНЕРАЦИЯ КОДА
//===============================================

//-------- код, переменные ----------

type
  arrCode=array[1..maxCode]of byte;
  arrData=array[1..maxData]of byte;

//------ Список вызовов внешних DLL ------------

type

  arrCALL=array[1..maxImpCALL]of integer; //адреса инструкций CALL (изменяемого dword)
  pCALL=pointer to arrCALL;

  recIMPFUN=record
              funName:pstr;
              funCALL:pCALL;
              funTop:integer;
              funRVA:integer;// RVA в таблице импорта
            end;
  arrIMPFUN=array[1..maxImpFun]of recIMPFUN;
  pIMPFUN=pointer to arrIMPFUN;

  recIMPORT=record
              impName:pstr;
              impFuns:pIMPFUN;
              impTop:integer;
            end;
  arrIMPORT=array[1..maxImpDLL]of recIMPORT;
  pIMPORT=pointer to arrIMPORT;

  arrEXPORT=array[1..maxExport]of pstr;
  pEXPORT=pointer to arrEXPORT;

var
  gloImport:pIMPORT;
  gloTop:integer;
  gloExport:pEXPORT;
  gloTopExp:integer;

//===============================================
//            МОДУЛЬ РЕСУРСОВ RES
//===============================================

const
  maxStyle=50;
  maxItem=100;
  maxListStyles=1000;
  maxBufClip=60000;
  idDlgBase=1000;
  idDlgBaseNew=1200;
  resDlgIniX=10;
  resDlgIniY=10;

type
//координаты
  recRect=record
    x,y:integer;
    dx,dy:integer;
  end;

//набор стилей
  arrStyles=array[1..maxStyle]of pstr;
  pStyles=pointer to arrStyles;

//характеристики элемента
  recItem=record
    iText:pstr;
    iClass:pstr;
    iId:pstr;
    iRect:recRect;
    iTop:integer;
    iStyles:pStyles;
    iWnd:HWND;
    iBlock:boolean;
    iFont:pstr;
    iSize:integer;
  end;
  pItem=pointer to recItem;
  arrItem=array[0..maxItem]of pItem; //0-диалог
  pItems=pointer to arrItem;

//диалог
  recDialog=record
    dMenu:pstr;
    dTop:integer;
    dItems:pItems;
  end;

//команды меню
type classDlgComm=(cdNULL,cdNew,
  cdEdit,cdEditUndo,cdEditCut,cdEditCopy,cdEditPaste,cdEditDel,cdEditAll,
  cdAlign,cdAlignLeft,cdAlignRight,cdAlignUp,cdAlignDown,cdAlignSizeX,cdAlignSizeY,
  cdParam,cdFont,cdOk,cdCancel);

type arrDlgCommand=array[classER]of array[classDlgComm]of record
  name:pstr;
  numTool:integer;
end;
const setDlgCommand=arrDlgCommand{{{"",0},{"&Новый элемент",0},
  {"&Правка",0},{"&Отменить",1},{"&Вырезать",2},{"&Копировать",3},{"В&ставить",4},{"&Удалить",5},{"В&ыделить все",0},
  {"&Выравнивание",0},{"Выровнять в&лево",6},{"Выровнять в&право",7},{"Выровнять в&верх",8},{"Выровнять в&низ",9},{"Выровнять размер по &X",10},{"Выровнять размер по &Y",11},
  {"&Свойства",12},{"&Шрифт",0},{"&Ок",0},{"О&тмена",0}},
  {{"",0},{"&New item",0},
  {"&Edit",0},{"&Undo",1},{"Cu&t",2},{"&Copy",3},{"&Insert",4},{"C&lear",5},{"&Select all",0},
  {"&Alignment",0},{"Align &left",6},{"Align &right",7},{"Align &up",8},{"Align &down",9},{"Align sizes to &X",10},{"Align sizes to &Y",11},
  {"&Options",12},{"&Font",0},{"&Ok",0},{"&Cancel",0}}};

//диалоги и BMP модулей
type
  recMItem=record
    miTxt:pstr;  //текст или заголовок
    miNam:pstr; //имя диалога
    miId:integer; //идентификатор элемента
    miCla:pstr; //класс
    miSty:integer; //стили
    miX,miY,miCX,miCY:integer; //координаты
    miFont:pstr; //фонт диалога
    miSize:integer; //высота диалога
  end;
  pMItem=pointer to recMItem;

  recMDialog=record
    mdTop:integer;
    mdCon:array[0..maxItem]of pMItem;
  end;
  pMDialog=pointer to recMDialog;

  arrDlg=array[1..maxMDlg]of pMDialog;
  pDlgs=pointer to arrDlg;

  recBMP=record
    bmpName:pstr;
    bmpFile:pstr;
    bmpSize:integer;
  end;

  arrBMP=array[1..maxBMP]of recBMP;
  pBMPs=pointer to arrBMP;

//параметры редактора диалогов
type
  arrClassMenu=array[1..maxClassMenu]of pstr;
  pClassMenu=pointer to arrClassMenu;
  recClass=record
    claMenu:string[maxSClass];
    claName:string[maxSClass];
    claStyle:string[maxSClass];
    claIniText:string[maxSClass];
    claIniDX:integer;
    claIniDY:integer;
    claTop:integer;
    claList:arrClassMenu;
  end;
  arrClass=array[1..maxClass]of recClass;
  pClass=pointer to arrClass;

type
  classDlgStatus=(dsTextE,dsClassE,dsIdE,dsXY,dsDXDY);
  arrDlgStatus=array[classDlgStatus]of integer;
const
  resStatusProc=arrDlgStatus{30,20,20,15,15};
  resFinStatus=dsDXDY;

type
  classIniClass=(iniStatic,iniButton,iniEdit,iniListbox,iniCombobox,
    iniScrollbar,iniRichEdit,iniListView,iniTreeView,iniTrackbar,iniProgressbar,iniAnimation,iniUpDown,iniHotKey,
    iniDateTimePick,iniCalendar);
  arrIniClass=array[classER]of array[classIniClass]of recClass;
const lastIniClass=iniCalendar;
const iniClass=arrIniClass{{
  {"Текст","Static","SS_","Текст",50,15,4,},
  {"Кнопка","Button","BS_","Кнопка",50,15,6,},
  {"Редактор","Edit","ES_","",50,15,3,},
  {"Список","Listbox","LBS_","",50,60,2,},
  {"Комбосписок","Combobox","CBS_","",50,60,2,},
  {"Линейка","Scrollbar","SBS_","",30,30,2,},
  {"Редактор RTF","RichEdit","ES_","",200,100,1,},
  {"Список ListView","SysListView32","LVS_","",70,100,4,},
  {"Дерево TreeView","SysTreeView32","TVS_","",70,100,1,},
  {"Движок Trackbar","msctls_trackbar32","TBS_","",30,40,2,},
  {"Индикатор Progressbar","msctls_progress32","","",70,40,1,},
  {"Видео Animation","SysAnimate32","ACS_","",200,100,3,},
  {"Кнопки Up-Down","","UDS_","",20,20,2,},
  {"Ввод клавиш Hotkey","msctls_hotkey32","","",50,20,1,},
  {"Дата и время DateTimePick","SysDateTimePick32","DTS_","",70,15,3,},
  {"Календарь","SysMonthCal32","MCS_","",100,100,2,}
},{
  {"Text","Static","SS_","Text",50,15,4,},
  {"Button","Button","BS_","Button",50,15,6,},
  {"Editor","Edit","ES_","",50,15,3,},
  {"Listbox","Listbox","LBS_","",50,60,2,},
  {"Combobox","Combobox","CBS_","",50,60,2,},
  {"Scrollbar","Scrollbar","SBS_","",30,30,2,},
  {"RTF Editor","RichEdit","ES_","",200,100,1,},
  {"ListView","SysListView32","LVS_","",70,100,4,},
  {"TreeView","SysTreeView32","TVS_","",70,100,1,},
  {"Trackbar","msctls_trackbar32","TBS_","",30,40,2,},
  {"Progressbar","msctls_progress32","","",70,40,1,},
  {"Animation","SysAnimate32","ACS_","",200,100,3,},
  {"Up-Down","","UDS_","",20,20,2,},
  {"Hotkey","msctls_hotkey32","","",50,20,1,},
  {"DateTimePick","SysDateTimePick32","DTS_","",70,15,3,},
  {"Calendar","SysMonthCal32","MCS_","",100,100,2,}
}};

const maxIniMenu=39;
type arrIniMenu=array[classER]of array[1..maxIniMenu]of pstr;
const iniMenu=arrIniMenu{{
  "Выравненный влево,WS_CHILD,WS_VISIBLE,SS_LEFT",
  "Выравненный вправо,WS_CHILD,WS_VISIBLE,SS_RIGHT",
  "Выравненный по центру,WS_CHILD,WS_VISIBLE,SS_CENTER",
  "Иконка,WS_CHILD,WS_VISIBLE,SS_ICON",

  "Обычная,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_PUSHBUTTON",
  "Главная,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_DEFPUSHBUTTON",
  "Трехпозиционная,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_3STATE",
  "Переключатель,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTOCHECKBOX",
  "Радиокнопка,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTORADIOBUTTON",
  "Рамка,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_GROUPBOX",

  "Однострочный,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL",
  "Для ввода пароля,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_PASSWORD",
  "Многострочный,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_MULTILINE",

  "Простой,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY",
  "Многоколоночный,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY,LBS_MULTICOLUMN",

  "Простой,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_SIMPLE",
  "Раскрывающийся,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_DROPDOWN",

  "Вертикальная,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_VERT",
  "Горизонтальная,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_HORZ",

  "Обычный,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_MULTILINE,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_NOHIDESEL,ES_SAVESEL,ES_SUNKEN",

  "Детальный отчет,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_REPORT",
  "Маленькие иконки,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_SMALLICON,LVS_EDITLABELS",
  "Маленькие иконки,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_SMALLICON,LVS_EDITLABELS",
  "Список с иконками,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_LIST,LVS_EDITLABELS",

  "Обычный,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TVS_HASLINES,TVS_HASBUTTONS,TVS_LINESATROOT",

  "Горизонтальный,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_BOTTOM",
  "Вертикальный,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_LEFT",

  "Обычный,WS_CHILD,WS_VISIBLE,WS_BORDER",

  "Простой,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER",
  "Прозрачный,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT",
  "Автомат,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT,ACS_AUTOPLAY",

  "Обычные,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS",
  "Горизонтальные,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS,UDS_HORZ",

  "Обычный,WS_CHILD,WS_VISIBLE",

  "Дата,WS_BORDER,WS_CHILD,WS_VISIBLE",
  "Дата длинная,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_LONGDATEFORMAT",
  "Время,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_TIMEFORMAT",

  "Обычный,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE",
  "Множественный выбор,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE,MCS_MULTISELECT"
},{
  "Align to left,WS_CHILD,WS_VISIBLE,SS_LEFT",
  "Align to right,WS_CHILD,WS_VISIBLE,SS_RIGHT",
  "Align to center,WS_CHILD,WS_VISIBLE,SS_CENTER",
  "Icon,WS_CHILD,WS_VISIBLE,SS_ICON",

  "Pushbutton,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_PUSHBUTTON",
  "Defpushbutton,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_DEFPUSHBUTTON",
  "3State,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_3STATE",
  "Checkbox,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTOCHECKBOX",
  "Radiobutton,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTORADIOBUTTON",
  "Groupbox,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_GROUPBOX",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL",
  "Password,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_PASSWORD",
  "Multiline,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_MULTILINE",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY",
  "Multicolumn,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY,LBS_MULTICOLUMN",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_SIMPLE",
  "Dropdown,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_DROPDOWN",

  "Vertical,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_VERT",
  "Horizontal,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_HORZ",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_MULTILINE,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_NOHIDESEL,ES_SAVESEL,ES_SUNKEN",

  "Report,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_REPORT",
  "SmallIcons,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_SMALLICON,LVS_EDITLABELS",
  "Icons,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_ICON,LVS_EDITLABELS",
  "List,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_LIST,LVS_EDITLABELS",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TVS_HASLINES,TVS_HASBUTTONS,TVS_LINESATROOT",

  "Horizontal,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_BOTTOM",
  "Vertical,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_LEFT",

  "Standard,WS_CHILD,WS_VISIBLE,WS_BORDER",

  "Simple,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER",
  "Transparent,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT",
  "Autoplay,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT,ACS_AUTOPLAY",

  "Standard,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS",
  "Horizontal,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS,UDS_HORZ",

  "Standard,WS_CHILD,WS_VISIBLE",

  "Date,WS_BORDER,WS_CHILD,WS_VISIBLE",
  "Date long,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_LONGDATEFORMAT",
  "Time,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_TIMEFORMAT",

  "Standard,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE",
  "Multiselect,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE,MCS_MULTISELECT"
}};

//--------- Списки стилей из Win32.i ------------

type
  arrListStyles=array[1..maxListStyles]of pstr;
  pListStyles=pointer to arrListStyles;

//--------- Переменные редактора диалогов ------------

var
  resClasses:pClass; //предопределенные классы
  resTopClass:integer;
  resCarClass:integer;
  resDlg:recDialog; //редактируемый диалог
  resDlgWnd:integer; //окно редактора диалогов
  resDlgItem:integer; //текущий выделенный элемент
  resDlgFocus:HWND; //текущий список стилей
  resStatus:HWND; //статус-строка редактора диалогов
  resStyles:pListStyles; //стили из файла Win32.i
  resTopStyles:integer;
  wndToolDlg:HWND; //окно линейки инструментов

var
  ресДлгБлокX:integer; //начальные координаты блока
  ресДлгБлокY:integer;
  ресДлгТекX:integer; //текущие координаты мыши
  ресДлгТекY:integer;

  ресЛексема:(лексНоль,лексИдент,лексСтрока,лексЦелое,лексСимвол);
  ресЛексОшибка:boolean;
  ресЛексСтрока:string[maxText];
  ресЛексЦелое:cardinal;
  ресЛексСимвол:char;

  ресОткат:array[1..maxResUndo]of pstr;
  ресВерхОткат:integer;

  ресБитНовыйДиалог:boolean;
  ресБитВПрограмму:boolean;
  ресБитТекстФункции:boolean;
  ресБитТекстВызова:boolean;

//------------------------- отладочная информация -----------------------------

type
  classStep=(stepNULL,
    stepSimple,
    stepCALL,stepRETURN,
    stepIF,stepVarIF,stepEndIF,
    stepCASE,stepVarCASE,stepEndCASE,
    stepFOR,stepBegFOR,stepModFOR,stepEndFOR,
    stepWHILE,stepBegWHILE,stepModWHILE,stepEndWHILE,
    stepREPEAT,stepModREPEAT,stepEndREPEAT);

  arrStep=array[1..maxStep]of record
    Class:classStep;
    source:integer; //код в genCode
    line:word; //номер строки в тексте
    frag:word; //номер фрагмента в строке
    level:byte; //topStack
    proc:address; //процедура в stepCALL
  end;

var
  stepStack:array[1..maxStackStep]of record
    Class:classStep;
    parent:integer;
  end;
  stepTopStack:integer;

  stepActive:array[1..maxStepActive]of record
    nom:integer; //в tbMod
    ind:integer; //в genStep
    buf:pstr; //буфер команд
  end;
  stepTopActive:integer;

  stepDebugged:boolean;
  stepTimer:HANDLE;
  stepProcess:HANDLE;
  stepThread:HANDLE;
  stepProcessId:HANDLE;
  stepThreadId:HANDLE;

  stepWnd:HWND;
  identWnd:HWND;
  stepLastWnd:HWND;
  stepLastLine:integer;
  stepHexdec:boolean;
  stepErrorRead:boolean;

  stepCarNom:integer;
  stepCarInd:integer;

//===============================================
//             ТАБЛИЦА ИДЕНТИФИКАТОРОВ
//===============================================

//--------- Классы идентификаторов ------------

type
  classID=(idNULL,
           idcCHAR,idcINT,idcSCAL,//целые константы
           idcREAL, //вещественная константа
           idcSTR,//строки
           idcSET,//множества
           idcSTRU, //структурные константы
           idtBAS,idtARR,idtREC,idtPOI,idtSET,idtSCAL,//типы
           idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR,//переменные
           idPROC,//процедура
           idMODULE,//модуль
           idREZ);//зарезервированный идент

const idBeg=idcCHAR; idEnd=idREZ; //общее поле идентификаторов

type
  classTab=(tabMods,tabMod,tabLoc,tabWith);
  classSub=(subNULL,subTYPE,subPROC,subMETHOD,subFIELD,subLOC,subPAR);
  classPRO=(proNULL,proPUBLIC,proPROTECTED,proPRIVATE,proPRIVATE_IMP);
  pID=pointer to recID;
  arrLIST=array[1..maxLIST]of pID;
  arrName=array[1..maxLIST]of pstr;
  arrSubs=array[1..maxSubs]of pID;
  pLIST=pointer to arrLIST;
  pName=pointer to arrName;
  pSubs=pointer to arrSubs;

  recID=record
    idName:pstr;
    idLeft:pID;
    idRight:pID;
    idOwn:pID;
    idTab:classTab;
    idNom:byte; //номер модуля
    idActiv:byte; //идентификатор активен
    idH:byte; //идентификатор находится в def-файле
    idSou:integer; //битовая карта модулей
    idPro:classPRO; //инкапсуляция
    idtSize:integer;
    idClass:classID;
    case of
      | idInt:integer; //idcCHAR,idcINT
      | idReal:real; //idcREAL
      | idStr:pstr; idStrAddr:integer; //idcSTR
      | idStruType:pID; idStruAddr:integer; //idcSTRU
      | idSet:pointer to setbyte; //idcSET
      | idScalVal:integer; idScalType:pID; //idcSCAL

      | idBasNom:classTYPE; //idtBAS
      | idArrItem,idArrInd:pID; extArrBeg,extArrEnd:integer; //idtARR
      | idRecList:pLIST; idRecMax:integer; //idtREC
        idRecCla:pID; idRecMet:pLIST; idRecTop:integer;
      | idPoiType:pID; idPoiBitForward:boolean; idPoiPred:pstr; //idtPOI
      | idSetType:pID; //idtSET
      | idScalList:pLIST; idScalMax:integer; //idtSCAL

      | idVarType:pID; idVarAddr:integer; //idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR

      | idProcList:pLIST; idProcMax:integer; //idPROC
        idLocList:pLIST; idLocMax:integer;
        idProcAddr,idProcPar,idProcLock,idProcCode:integer;
        idProcASCII:boolean;
        idProcDLL:pstr;
        idProcType,idProcCla:pID;

      | idModNom:integer; //idMODULE
      | idRezVal:classREZ; //idREZ
  end;

//----- списки call и var call ---------------

type
  lstCall=record
    top:integer;
    arr:array[1..maxCall]of record
      callSou:integer;
      callProc:pID;
    end;
  end;

  classVarCall=(vcCode,vcData,vcAddr,vcNew);
  arrVarCall=array[1..maxVarCall]of record
    track:integer; //адрес в genCode(genData) текущего модуля
    no:byte; //номер модуля genData
    cla:pstr; //имя класса для vcNew
    cl:classVarCall;
      //vcCode - track в genCode(+genBegData)
      //vcData - track в genData(+genBegData)
      //vcAddr - track в genCode(+genBegCode)
      //vcNew - track в genCode(+genBegCode)
  end;

  arrProCall=array[1..maxProCall]of record
    track:integer; //адрес call в genCode текущего модуля
    sou:pstr; //имя процедуры
    mo:pstr; //имя модуля
  end;

//------- Таблицы идентификаторов --------------

var
  tbMod:array[1..maxMod]of record //модули
    modNam:pstr; //имя модуля
    modTab:pID; //ТИ модуля
    modTxt:integer; //номер текста в txts
    modAct:boolean; //модуль активен в текущей компиляции
    modSbs:array[classSub]of pSubs; //таблицы замены ссылок ТИ
    modTop:array[classSub]of integer;
    modComp:boolean; //текст модуля компилирован
    modMain:boolean; //exe (dll) модуль

    modDlg:pDlgs; topMDlg:integer;
    modBMP:pBMPs; topBMP:integer;
    modICON:pstr;

    genBegCode:integer;
    genBegData:integer;
    genCode:pointer to arrCode; topCode:integer;
    genData:pointer to arrData; topData:integer;
    genImport:pIMPORT; topImport:integer;
    genExport:pEXPORT; topExport:integer;
    genVarCall:pointer to arrVarCall; topVarCall:integer;
    genProCall:pointer to arrProCall; topProCall:integer;

    genStep:pointer to arrStep; topGenStep:integer;
  end;
  topMod:integer;

  tbModImp:array[1..maxMod]of pstr; //имена импортируемых модулей
  topModImp:integer;

  tbWith:array[1..maxWith]of pID; //стек with
  topWith:integer;
  withGlo:integer; //побочный результат idFindGlo

  idTYPE:array[classTYPE]of pID;

//-------------- Списки строк -----------------

type
  arrSTRING=array[1..maxSTRING]of record
    stringSou:integer;
    stringPoi:pstr;
  end;
  pSTRING=pointer to arrSTRING;

var
  genSTRING:pSTRING;
  topSTRING:integer;

//===============================================
//             ЛЕКСИЧЕСКИЙ АНАЛИЗ
//===============================================

//------------- Входной поток -----------------

//классы лексем
type
  classLex=(lexNULL,
    lexEOF,   //конец файла
    lexCHAR,   //символ или его идент.: 'a',10C(восмеричное),13с(десятичное)
    lexINT,    //целое менее FFFFFFFFh или его идент.: 12,F90h,F90H,01110b,01110B
    lexREAL,   //вещественное или его идент.: 31., 31.02, .87, 43.2e10, .12E-4
    lexSTR,    //строка или ее идент.: "a", 'abc', "ab'cd"
    lexSTRU,   //структурная константа
    lexSET,    //идентификатор константы-множества
    lexNIL,    //константа NIL (NULL) или ее идент.:задается описанием
    lexFALSE,  //константа FALSE или ее идент.:задаются описанием
    lexTRUE,   //константа TRUE или ее идент.:задаются описанием
    lexID,     //любой идентификатор (в т.ч.квалифицированный)
    lexNEW,    //новый идентификатор
    lexSCAL,   //идентификатор константы скалярного типа
    lexREZ,    //зарезервированный идентификатор
    lexASM,    //команда ассемблера
    lexREG,    //регистр процессора
    lexPARSE,  //разделитель
    lexTYPE,   //имя типа
    lexFIELD,  //имя поля записи
    lexVAR,    //имя глобальной переменной
    lexLOC,    //имя локальной переменной
    lexPAR,    //имя параметра или локальной переменной
    lexVPAR,   //имя параметра класса VAR
    lexPROC,   //имя процедуры
    lexCOMM,   //комментарий
    lexMOD     //имя модуля
    );
  const setID=[lexNEW,lexSCAL,lexTYPE,lexVAR,lexLOC,lexPAR,lexVPAR,lexFIELD,lexPROC,lexMOD,lexSTR,lexSTRU,lexID];

//{имена лексем}
  type arrLex=array[classLex]of pstr;
  const nameLex=arrLex{
                 'СИСТЕМНАЯ',
                 'КОНЕЦ ФАЙЛА',
                 'СИМВОЛ',
                 'ЦЕЛОЕ',
                 'ВЕЩЕСТВЕННОЕ',
                 'СТРОКА',
                 'СТРУКТУРНАЯ КОНСТАНТА',
                 'МНОЖЕСТВО',
                 'КОНСТАНТА NIL',
                 'КОНСТАНТА FALSE',
                 'КОНСТАНТА TRUE',
                 'ИМЯ',
                 'НОВОЕ ИМЯ',
                 'СКАЛЯР',
                 'ЗАРЕЗЕРВИРОВАННОЕ ИМЯ',
                 'КОМАНДА АССЕМБЛЕРА',
                 'РЕГИСТР ПРОЦЕССОРА',
                 'РАЗДЕЛИТЕЛЬ',
                 'ИМЯ ТИПА',
                 'ИМЯ ПОЛЯ ЗАПИСИ',
                 'ИМЯ ГЛОБАЛЬНОЙ ПЕРЕМЕННОЙ',
                 'ИМЯ ЛОКАЛЬНОЙ ПЕРЕМЕННОЙ',
                 'ИМЯ ПАРАМЕТРА',
                 'ИМЯ ПАРАМЕТРА VAR',
                 'ИМЯ ПРОЦЕДУРЫ',
                 'КОММЕНТАРИЙ',
                 'ИМЯ МОДУЛЯ'};

type
//{позиция символа в тексте}
  recPos=record
    y:integer; //{номер строки}
    f:integer; //{номер фрагмента}
  end;

//{входной поток}
  recStream=record
    stFile:string[maxText]; //имя файла
    stPosLex:recPos; //позиция указателя лексем
    stPosPred:recPos; //предыдущая позиция указателя лексем
    stLex:classLex; //текущая лексема
    stLexID:pID; //лексема-идентификатор
    stLexInt:integer; //значение лексемы классов:
                             //lexCHAR,lexINT,lexREZ,
                             //lexNIL,lexFALSE,lexTRUE,
                             //lexSTRUCT,
                             //lexONE,lexDOUBLE,
                             //lexTYPE,lexVAR,lexPAR,lexVPAR,lexFIELD,lexPROC
    stLexStr:string[maxText]; //значение лексемы классов lexSTR,lexID,lexNEW
    stLexOld:string[maxText]; //предыдущее значение stLexStr
    stLexSet:setbyte; //значение лексемы lexSET
    stLexReal:real; //значение лексемы lexREAL
    stErr:boolean; //наличие ошибки
    stErrPos:recPos; //позиция ошибки
    stErrText:string[maxText]; //текст ошибки
    stErrExt:integer; //номер IMP/DEF ошибки
    stLoad:boolean; //признак загрузки текста при открытии потока
    stTxt:integer; //номер транслируемого текста
    stExt:integer; //номер IMP/DEF
  end;

//стек константного выражения
type
  classConOp=(conNULL,conAdd,conSub,conMul,conDiv,conMod,conOr,conAnd);

type arrConOp=array[classConOp]of classPARSE;
const lexConOp=arrConOp{pNULL,pPlu,pMin,pMul,pDiv,pPro,pVer,pAmp};

type
  recConExp=record
    conOp:classConOp;
    conLex:classLex;
    case of
      | conInt:integer; //lexINT
      | conReal:real; //lexREAL
      | conStr:pstr; //lexSTR
      | conChar:char; //lexCHAR
  end;

var
  lexStackCon:array[1..maxStackCon]of recConExp;
  topStackCon:integer;
  lexBitConst:boolean; //{внутри константного выражения}

//===============================================
//                ГЕНЕРАЦИЯ КОДА
//===============================================

//----------------- регистры ------------------

type classRegister=(regNULL,
                          rEAX,rEBX,rECX,rEDX,
                          rAX,rBX,rCX,rDX,rSP,rBP,rSI,rDI,
                          rAL,rBL,rCL,rDL,
                          rAH,rBH,rCH,rDH,
                          rESP,rEBP,rESI,rEDI,
                          rCS,rSS,rDS,rES,rFS,rGS,
                          rST0,rST1,rST2,rST3,rST4,rST5,rST6,rST7);
type arrRegs=array[classRegister]of record
        rNa:pstr;
        rCo:byte;
      end;
const asmRegs=arrRegs{
  {'',0},
  {'EAX',0},{'EBX',3},{'ECX',1},{'EDX',2},
  {'AX',0},{'BX',3},{'CX',1},{'DX',2},{'SP',4},{'BP',5},{'SI',6},{'DI',7},
  {'AL',0},{'BL',3},{'CL',1},{'DL',2},
  {'AH',4},{'BH',7},{'CH',5},{'DH',6},
  {'ESP',4},{'EBP',5},{'ESI',6},{'EDI',7},
  {'CS',1},{'SS',2},{'DS',3},{'ES',0},{'FS',4},{'GS',5},
  {'ST0',0},{'ST1',1},{'ST2',2},{'ST3',3},
  {'ST4',4},{'ST5',5},{'ST6',6},{'ST7',7}};

type classOperand=(oNULL,oE, //регистр
                         oS, //сегментный регистр
                         oM, //память
                         oD); //константа

//----------------- команды -------------------

type  classCommand=(cNULL,
  //класс RM/RD
       cADD,cSUB,cADC,cSBB,cAND,cOR,cXOR,
       cCMP,cTEST,cMOV,cLEA,cLDS,cLES,cXCHG,
       cBT,cBTC,cBTR,cBTS,
  //класс FM
       cFLD,cFST,cFSTP,cFCOM,cFCOMP,cFADD,cFSUB,cFSUBR,
       cFMUL,cFDIV,cFDIVR,
  //класс FIM
       cFILD,cFIST,cFISTP,cFICOM,cFICOMP,cFIADD,cFISUB,
       cFISUBR,cFIMUL,cFIDIV,cFIDIVR,cFBLD,cFBSTP,
  //класс FM
       cFSTENV,cFLDENV,cFLDCW,cFSTCW,cFSTSW,cFSAVE,cFRSTOR,
  //класс FR
       cFXCH,cFADDP,cFSUBP,cFSUBRP,cFMULP,cFDIVP,cFDIVRP,
       cFFREE,
  //класс F
       cFLDZ,cFLD1,cFLDPI,cFLDL2T,cFLDL2E,cFLDLG2,cFLDLN2,
       cFCOMPP,cFTST,cFXAM,cFSQRT,cFSCALE,cFPREM,cFRNDINT,
       cFXTRACT,cFABS,cFCHS,cFPTAN,cFPATAN,cF2FM1,cFYL2X,
       cFYL2XP1,cFINIT,cFENT,cFDISI,cFCLEX,cFINCSTP,
       cFDECSTP,cFNOP,
  //класс ROL
       cRCL,cRCR,cROL,cROR,cSAL,cSAR,cSHL,cSHR,
  //класс RM
       cMUL,cDIV,cIMUL,cIDIV,cINC,cDEC,cNEG,cNOT,
       cPOP,cPUSH,
  //класс L
       cJMP,cJCXZ,cLOOPE,cLOOPNE,cLOOP,
       cJL,cJLE,cJG,cJGE,cJE,cJNE,
       cJA,cJAE,cJB,cJBE,cJZ,cJNZ,
       cJC,cJO,cJP,cJS,cJNC,cJNO,cJNP,cJNS,cJPO,cJPE,
  //класс OTHER
       cIN,cOUT,cINT,cAAD,cAAM,
       cCALL,cCALLF,cRET,
  //класс NULL
       cCMPS,cMOVS,cSTOS,cSCAS,cLODS,
       cCLC,cCLD,cCLI,cSTC,cSTD,cSTI,cCMC,
       cAAA,cAAS,cDAA,cDAS,cHLT,cINT0,cINT3,cIRET,
       cREP,cREPE,cREPNE,cENTER,cLEAVE,
       cLAHF,cSAHF,cPOPF,cPUSHF,cNOP,cWAIT,cXLAT,cCBW,cCWD);

type arrCommands=array[classCommand]of record
    cNam:pstr;
    cPri:byte;  //признаки наличия: 1-w,2-d,4-dat,8-ext
    cCod:byte;  //код первого байта (вариант mr)
    cDat:byte;  //код первого байта (вариант md)
    cExt:byte;  //код расширения    (вариант md)
  end;
const asmCommands=arrCommands{
{'',0x00,0x00,0x00,0x00},

{'ADD' ,0x0F,0x00,0x80,0x00},
{'SUB' ,0x0F,0x28,0x80,0x28},
{'ADC' ,0x0F,0x10,0x80,0x10},
{'SBB' ,0x0F,0x18,0x80,0x18},
{'AND' ,0x0F,0x20,0x80,0x20},
{'OR'  ,0x0F,0x08,0x80,0x08},
{'XOR' ,0x0F,0x30,0x80,0x30},
{'CMP' ,0x0F,0x38,0x80,0x38},
{'TEST',0x0D,0x84,0xF6,0x00},
{'MOV' ,0x0F,0x88,0xC6,0x00},
{'LEA' ,0x00,0x8D,0x00,0x00},
{'LDS' ,0x00,0xC5,0x00,0x00},
{'LES' ,0x00,0xC4,0x00,0x00},
{'XCHG',0x01,0x86,0x00,0x00},
{'BT' ,0x0C,0xA3,0xBA,0x20},
{'BTC',0x0C,0xBB,0xBA,0x38},
{'BTR',0x0C,0xB3,0xBA,0x30},
{'BTS',0x0C,0xAB,0xBA,0x28},

{'FLD'  ,0x0C,0xDD,0x20,0x00},
{'FST'  ,0x0C,0xDD,0xA2,0x10},
{'FSTP' ,0x0C,0xDD,0xA3,0x18},
{'FCOM' ,0x0C,0xDC,0x02,0x10},
{'FCOMP',0x0C,0xDC,0x03,0x18},
{'FADD' ,0x0C,0xDC,0x00,0x00},
{'FSUB' ,0x0C,0xDC,0x04,0x20},
{'FSUBR',0x0C,0xDC,0x05,0x28},
{'FMUL' ,0x0C,0xDC,0x01,0x08},
{'FDIV' ,0x0C,0xDC,0x06,0x30},
{'FDIVR',0x0C,0xDC,0x07,0x38},

{'FILD'  ,0x08,0xDB,0x00,0x00},
{'FIST'  ,0x08,0xDB,0x00,0x10},
{'FISTP' ,0x08,0xDB,0x00,0x18},
{'FICOM' ,0x08,0xDA,0x00,0x10},
{'FICOMP',0x08,0xDA,0x00,0x18},
{'FIADD' ,0x08,0xDA,0x00,0x00},
{'FISUB' ,0x08,0xDA,0x00,0x20},
{'FISUBR',0x08,0xDA,0x00,0x28},
{'FIMUL' ,0x08,0xDA,0x00,0x08},
{'FIDIV' ,0x08,0xDA,0x00,0x30},
{'FIDIVR',0x08,0xDA,0x00,0x38},
{'FBLD'  ,0x08,0xDF,0x00,0x20},
{'FBSTP' ,0x08,0xDF,0x00,0x30},

{'FSTENV',0x08,0xD9,0x00,0x30},
{'FLDENV',0x08,0xD9,0x00,0x20},
{'FLDCW' ,0x08,0xD9,0x00,0x28},
{'FSTCW' ,0x08,0xD9,0x00,0x38},
{'FSTSW' ,0x08,0xDD,0x00,0x38},
{'FSAVE' ,0x08,0xDD,0x00,0x30},
{'FRSTOR',0x08,0xDD,0x00,0x20},

{'FXCH'  ,0x04,0x01,0x02,0x00},
{'FADDP' ,0x04,0x00,0xC0,0x00},
{'FSUBP' ,0x04,0x01,0xC5,0x00},
{'FSUBRP',0x04,0x01,0xC4,0x00},
{'FMULP' ,0x04,0x01,0xC1,0x00},
{'FDIVP' ,0x04,0x01,0xC7,0x00},
{'FDIVRP',0x04,0x01,0xC6,0x00},
{'FFREE' ,0x04,0xDD,0xC0,0x00},

{'FLDZ'   ,0x04,0xD9,0xEE,0x00},
{'FLD1'   ,0x04,0xD9,0xE8,0x00},
{'FLDPI'  ,0x04,0xD9,0xEB,0x00},
{'FLDL2T' ,0x04,0xD9,0xE9,0x00},
{'FLDL2E' ,0x04,0xD9,0xEA,0x00},
{'FLDLG2' ,0x04,0xD9,0xEC,0x00},
{'FLDLN2' ,0x04,0xD9,0xED,0x00},
{'FCOMPP' ,0x04,0xDE,0xD9,0x00},
{'FTST'   ,0x04,0xD9,0xE4,0x00},
{'FXAM'   ,0x04,0xD9,0xE5,0x00},
{'FSQRT'  ,0x04,0xD9,0xFA,0x00},
{'FSCALE' ,0x04,0xD9,0xFD,0x00},
{'FPREM'  ,0x04,0xD9,0xF8,0x00},
{'FRNDINT',0x04,0xD9,0xFC,0x00},
{'FXTRACT',0x04,0xD9,0xF4,0x00},
{'FABS'   ,0x04,0xD9,0xE1,0x00},
{'FCHS'   ,0x04,0xD9,0xE0,0x00},
{'FPTAN'  ,0x04,0xD9,0xF2,0x00},
{'FPATAN' ,0x04,0xD9,0xF3,0x00},
{'F2XM1'  ,0x04,0xD9,0xF0,0x00},
{'FYL2X'  ,0x04,0xD9,0xF1,0x00},
{'FYL2XP1',0x04,0xD9,0xF9,0x00},
{'FINIT'  ,0x04,0xDB,0xE3,0x00},
{'FENI'   ,0x04,0xDB,0xE0,0x00},
{'FDISI'  ,0x04,0xDB,0xE1,0x00},
{'FCLEX'  ,0x04,0xDB,0xE2,0x00},
{'FINCSTP',0x04,0xD9,0xF7,0x00},
{'FDECSTP',0x04,0xD9,0xF6,0x00},
{'FNOP'   ,0x04,0xD9,0xD0,0x00},

{'RCL',0x0D,0xD2,0xD0,0x10},
{'RCR',0x0D,0xD2,0xD0,0x18},
{'ROL',0x0D,0xD2,0xD0,0x00},
{'ROR',0x0D,0xD2,0xD0,0x08},
{'SAL',0x0D,0xD2,0xD0,0x20},
{'SAR',0x0D,0xD2,0xD0,0x38},
{'SHL',0x0D,0xD2,0xD0,0x20},
{'SHR',0x0D,0xD2,0xD0,0x28},

{'MUL'  ,0x09,0xF6,0x00,0x20},
{'DIV'  ,0x09,0xF6,0x00,0x30},
{'IMUL' ,0x09,0xF6,0x00,0x28},
{'IDIV' ,0x09,0xF6,0x00,0x38},
{'INC'  ,0x09,0xFE,0x00,0x00},
{'DEC'  ,0x09,0xFE,0x00,0x08},
{'NEG'  ,0x09,0xF6,0x00,0x18},
{'NOT'  ,0x09,0xF6,0x00,0x10},
{'POP'  ,0x08,0x8F,0x00,0x00},
{'PUSH' ,0x0C,0xFF,0x68,0x30},

{'JMP'   ,0x00,0xE9,0x00,0x00},
{'JCXZ'  ,0x00,0xE3,0x00,0x00},
{'LOOPE' ,0x00,0xE1,0x00,0x00},
{'LOOPNE',0x00,0xE0,0x00,0x00},
{'LOOP'  ,0x00,0xE2,0x00,0x00},

{'JL'    ,0x00,0x8C,0x00,0x00},
{'JLE'   ,0x00,0x8E,0x00,0x00},
{'JG'    ,0x00,0x8F,0x00,0x00},
{'JGE'   ,0x00,0x8D,0x00,0x00},
{'JE'    ,0x00,0x84,0x00,0x00},
{'JNE'   ,0x00,0x85,0x00,0x00},
{'JA'    ,0x00,0x87,0x00,0x00},
{'JAE'   ,0x00,0x83,0x00,0x00},
{'JB'    ,0x00,0x82,0x00,0x00},
{'JBE'   ,0x00,0x86,0x00,0x00},
{'JZ'    ,0x00,0x84,0x00,0x00},
{'JNZ'   ,0x00,0x85,0x00,0x00},
{'JC'    ,0x00,0x82,0x00,0x00},
{'JO'    ,0x00,0x80,0x00,0x00},
{'JP'    ,0x00,0x8A,0x00,0x00},
{'JS'    ,0x00,0x88,0x00,0x00},
{'JNC'   ,0x00,0x83,0x00,0x00},
{'JNO'   ,0x00,0x81,0x00,0x00},
{'JNP'   ,0x00,0x8B,0x00,0x00},
{'JNS'   ,0x00,0x89,0x00,0x00},
{'JPO'   ,0x00,0x8B,0x00,0x00},
{'JPE'   ,0x00,0x8A,0x00,0x00},

{'IN'   ,0x05,0xE4,0xEC,0x00},
{'OUT'  ,0x05,0xE6,0xEE,0x00},
{'INT'  ,0x00,0xCD,0xCD,0x00},
{'AAD'  ,0x04,0xD5,0x0A,0x00},
{'AAM'  ,0x04,0xD4,0x0A,0x00},
{'CALL' ,0x00,0xE8,0x00,0x00},
{'CALLF',0x08,0xFF,0x00,0x10},
{'RET'  ,0x00,0xC3,0xC2,0x00},

{'CMPS',0x01,0xA6,0x00,0x00},
{'MOVS',0x01,0xA4,0x00,0x00},
{'STOS',0x01,0xAA,0x00,0x00},
{'SCAS',0x01,0xAE,0x00,0x00},
{'LODS',0x01,0xAC,0x00,0x00},

{'CLC',0x00,0xF8,0x00,0x00},
{'CLD',0x00,0xFC,0x00,0x00},
{'CLI',0x00,0xFA,0x00,0x00},
{'STC',0x00,0xF9,0x00,0x00},
{'STD',0x00,0xFD,0x00,0x00},
{'STI',0x00,0xFB,0x00,0x00},
{'CMC',0x00,0xF5,0x00,0x00},

{'AAA',0x00,0x37,0x00,0x00},
{'AAS',0x00,0x3F,0x00,0x00},
{'DAA',0x00,0x27,0x00,0x00},
{'DAS',0x00,0x2F,0x00,0x00},

{'HLT'  ,0x00,0xF4,0x00,0x00},
{'INTO' ,0x00,0xCE,0x00,0x00},
{'INT3' ,0x00,0xCC,0x00,0x00},
{'IRET' ,0x00,0xCF,0x00,0x00},
{'REP'  ,0x00,0xF3,0x00,0x00},
{'REPE' ,0x00,0xF3,0x00,0x00},
{'REPNE',0x00,0xF2,0x00,0x00},
{'ENTER',0x00,0xC8,0x00,0x00},
{'LEAVE',0x00,0xC9,0x00,0x00},
{'LAHF' ,0x00,0x9F,0x00,0x00},
{'SAHF' ,0x00,0x9E,0x00,0x00},
{'POPF' ,0x00,0x9D,0x00,0x00},
{'PUSHF',0x00,0x9C,0x00,0x00},
{'NOP'  ,0x00,0x90,0x00,0x00},
{'WAIT' ,0x00,0x9B,0x00,0x00},
{'XLAT' ,0x00,0xD7,0x00,0x00},
{'CBW'  ,0x00,0x98,0x00,0x00},
{'CWD'  ,0x00,0x99,0x00,0x00}};

const
      loCom=cADD; hiCom=cCWD;
      loMDCom=cADD; hiMDCom=cBTS;
      loFMRCom=cFLD; hiFMRCom=cFDIVR;
      loFIMCom=cFILD; hiFIMCom=cFBSTP;
      loFMCom=cFSTENV; hiFMCom=cFRSTOR;
      loFRCom=cFXCH; hiFRCom=cFFREE;
      loFCom=cFLDZ; hiFCom=cFNOP;
      loRCom=cRCL; hiRCom=cSHR;
      loMCom=cMUL; hiMCom=cPUSH;
      loLCom=cJMP; hiLCom=cJPE;
      loOCom=cIN; hiOCom=cRET;
      loNCom=cCMPS; hiNCom=cCWD;

const setComFsize=[cFLD,cFST,cFSTP,cFCOM,cFCOMP,cFADD,cFSUB,cFSUBR,cFMUL,cFDIV,cFDIVR];

//----------- таблицы exe-файла ---------------

type
  classExe=(exeNULL,exeOld,exeHeader,exeSect,exeData,exeIData,exeEData,exeText,exeRsrc,exeDebug);
var
  genPushAX:integer;
  genPushSI:integer;
  genNameModule:string[maxText];
  genStack:integer;

//--------------- заголовок -------------------

type arrOldHeader=array[1..0x100]of byte;
const OldHeader=arrOldHeader{
  0x4D, 0x5A, 0x00, 0x01, 0x05, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x08, 0x00
, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0xBA, 0x10, 0x00, 0x0E, 0x1F, 0xB4, 0x09, 0xCD, 0x21, 0xB8, 0x01, 0x4C, 0xCD, 0x21, 0x90, 0x90
, 0x54, 0x68, 0x69, 0x73, 0x20, 0x70, 0x72, 0x6F, 0x67, 0x72, 0x61, 0x6D, 0x20, 0x72, 0x65, 0x71
, 0x75, 0x69, 0x72, 0x65, 0x73, 0x20, 0x4D, 0x69, 0x63, 0x72, 0x6F, 0x73, 0x6F, 0x66, 0x74, 0x20
, 0x57, 0x69, 0x6E, 0x64, 0x6F, 0x77, 0x73, 0x2E, 0x0D, 0x0A, 0x24, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20};

type
    recWinHeader=record
      signature:array[0..3]of char; //PE00
      machine:word; //$14C
      numSection:word; //4
      TimeDateStamp:integer; //напр.,$073924CA
      begSymbolTable:integer; //0
      numSymbolTable:integer; //0
      sizeOptionHeader:word; //$00E0
      flags:word; //$818E

      magic:word; //$010B
      linkerVersion:word; //$1902
      sizeOfCode:integer; //TopCode (округлено вверх до $1000)
      sizeOfIniData:integer; //TopData (вверх)
      sizeOfUnIniData:integer; //0
      entryPoint:integer; //$1000+смещение точки входа
      baseOfCode:integer; //$1000 (RVA секции .text)
      baseOfData:integer; //$1000 (RVA секции .data)
      imageBase:integer; //$400000
      sectionAlgnment :integer; //$1000
      fileAlgnment:integer; //$200
      osVersion:integer; //1
      imageVersion:integer; //0
      subsystVersion:integer; //$000A0003
      reserved1:integer; //0
      sizeofImage:integer; //RVA последней секции+ее размер-RVA первой секции
      sizeofHeaders:integer; //размер заголовка и таблицы секций (в proba - $400)
      checkSum:integer; //0
      subSystem:word;    //3
      dllFlags:word;    //0
      stackReserve:integer; //$100000
      stackCommit:integer; //$2000
      heapReserve:integer; //$100000
      heapCommit:integer; //$1000
      loaderFlags:integer; //0
      numRvaAndSizes:integer; //16
      dirs:array[0..15]of record
        //0-экспорт (proba:$10000,$CA)
        //1-импорт  (proba:$F000,$4C4)
        virtualAddress:integer;
        vsize:integer;
      end;
    end;

var WinHeader:recWinHeader;

type arrSection=array[exeData..exeDebug]of record
      name:array[0..7]of char; //имя секции
      virtualSize:integer; //размер секции (точное значение)
      virtualAddress:integer; //RVA секции ($1000 для .text и т.д.)
      sizeofRawData:integer; //размер секции (выравнено на $200)
      pointerRawData:integer; //адрес секции (от начала файла)
      pointerReloc:integer; //0
      pointerLineNum:integer; //0
      numReloc:word; //0
      numLineNum:word; //0
      flags:integer;
        //.text :$60000020
        //.data :$C0000040
        //.idata:$40000040
        //.edata:$40000040
        //.rsrc :$40000040
        //.debug :$40000040
    end;
var tbSection:arrSection;

//------------ секция импорта -----------------

type
  imageImportDesctriptor=record
    origFirstThunk:integer; //0
    timeDateStump:integer; //0
    forwardChain:integer; //0
    name:integer; //RVA сроки-имени файла DLL
    FirstThunk:integer; //RVA массива указателей на имп.функции
  end;
  //массив Thunk состоит из RVA указателей (zeroend)
  //каждый указывает на 0,0,имя функции zeroend
  //элементы из массива Thunk (их RVA-адреса
  //должны фигурировать в вызовах CALL PTR[]

//----------- секция экспорта -----------------

type
  imageExportDesctriptor=record
    Characteristics:integer; //0
    TimeDateStump:integer; //0
    MajorVersion:word; //0
    MinorVersion:word; //0
    Name:integer; //RVA строки с именем файла DLL
    Base:integer; //1
    NumberOfFunctions:integer; //gloTopExp
    NumberOfNames:integer; //gloTopExp
    AddressOfFunctions:integer; //RVA массива точек входа
    AddressOfNames:integer; //RVA массива указателей на имена
    AddressOfNameOrdinals:integer; //RVA массива слов (номеров экспорта) от 1 до gloTopExp
  end;

//----- списки переходов ---------------

type
  lstJamp=record
    top:integer;
    arr:array[1..maxJamp]of record
      jaddr:integer;
      jcomm:classCommand;
    end;
  end;

//----- структуры секции ресурсов -------------

type
  recSortRes=record
    resDLG:boolean;
    resMod:integer;
    resNom:integer;
    s:pstr;
  end;
  arrSortRes=array[1..maxRes]of recSortRes;

  image_resource_directory=record
    Characteristics:integer; //{0}
    TimeDateStamp:integer; //{дата и время}
    Version:integer; //{4}
    NumberOfNamedEntries:word; //{1 (только диалоги)}
    NumberOfIdEntries:word; //{0}
  end;
  image_resource_directory_entry=record
    Name:integer;
    OffsetToData:integer;
  end;
  image_resource_data_entry=record
    RVA:integer;
    Size:integer;
    CodePage:integer;
    Rezerved:integer;
  end;
  res_icon=record
    irReserved:word; //0
    irType:word; //1
    irCount:word; //1
    bWight:byte; //32
    bHeight:byte; //32
    bColorCount:byte; //16
    bReserved:byte; //0
    wReserved1:word; //1
    wReserved2:word; //4
    dwBytesInRes:cardinal; //2e8
    wOriginalNumber:word; //1
  end;

type arrClasses=array[1..maxClasses]of record
  claBas:pID;
  claList:pLIST;
  claListTop:integer;
  claName:pName;
  claNameTop:integer;
  claAddr:pLIST;
end;
type pClasses=pointer to arrClasses;

var
  genCall:pointer to lstCall;
  genSort:pointer to arrSortRes; topSortRes:integer;
  genRezTop,genRezMax:integer;
  envError:integer;
  envBitInit:boolean;

  genEntry:integer; //точка входа (адрес в genCode)
  genEntryNo:integer; //точка входа (номер модуля)
  genEntryStep:integer; //точка входа (номер брейка)
  genClasses:pClasses;
  genClassesTop:integer;
  genClassBegin:integer; //начало таблицы классов

//структуры отладочной информации
type IMAGE_COFF_SYMBOLS_HEADER=record
  NumberOfSymbols:cardinal;
  LvaToFirstSymbol:cardinal;
  NumberOfLinenumbers:cardinal;
  LvaToFirstLinenumber:cardinal;
  RvaToFirstByteOfCode:cardinal;
  RvaToLastByteOfCode:cardinal;
  RvaToFirstByteOfData:cardinal;
  RvaToLastByteOfData:cardinal;
end;

type IMAGE_LINENUMBER=record
  VirtualAddress:cardinal;
  Linenumber:cardinal;
end;

type IMAGE_SYMBOL=record
  ShortName:array[0..7]of char;
  Value:cardinal;
  SectionNumber:word;
  Type:word;
  StorageClass:byte;
  NumberOfAuxSymbols:byte;
end;

type AUX_SECTION=record
  Length:cardinal; // section length
  NumberOfRelocations:word; // number of relocation entries
  NumberOfLinenumbers:word; // number of line numbers
  CheckSum:cardinal; // checksum for communal
  Number:word; // section number to associate with
  Selection:byte; // communal selection type
  unused:array[0..2]of byte;
end;

type AUX_FUNCTION=record
  TagIndex:cardinal;
  TotalSize:cardinal;
  PointerToLinenumber:cardinal;
  PointerToNextFunction:cardinal;
  unused:array[0..1]of byte;
end;

type AUX_BF_EF=record
  unused:cardinal;
  Linenumber:word;
  unused2:array[0..5]of byte;
  PointerToNextFunction:cardinal;
  unused3:word;
end;

type IMAGE_DEBUG_DIRECTORY=record
  Characteristics:cardinal;
  TimeDateStamp:cardinal;
  MajorVersion:word;
  MinorVersion:word;
  Type:cardinal;
  SizeOfData:cardinal;
  AddressOfRawData:cardinal;
  PointerToRawData:cardinal;
  unused:cardinal; //не является частью IMAGE_DEBUG_DIRECTORY
end;

//===============================================
//            МОДУЛЬ ТРАНСЛЯЦИИ TRA
//===============================================

type
  classFor=(forNULL,forBYTE,forINT,forDWORD);
  classModif=(modifNULL,modifTO,modifTONE,modifDOWNTO,modifDOWNTONE);
  classOp=(opNULL,
    opADD,opSUB,opMUL,opMULZ,opDIV,opDIVZ,opMOD,opMODZ,
    opOR,opAND,opNOT,opORB,opANDB,opNOTB,
    opABS,opNEG,opINT,opRND,opFLO,opUgLUgL,opUgRUgR,
    opE,opNE,opL,opG,opLZ,opGZ,opLE,opGE,opLEZ,opGEZ,
    opSETADD,opSETSUB,opSETADDE,opSETSUBE,opSETIN);
type
  recPars=record
    arrPars:array[1..maxPars]of record
      parBeg:integer;
      parEnd:integer;
    end;
    carPar:integer;
  end;

  arrModif=array[1..maxModif]of record
    modAddr:pinteger;
    modNew:integer;
  end;

var
  traCarProc:pID;
  traModName:string[100];
  traBitIMP:boolean; //imp-модуль
  traBitDEF:boolean; //def-модуль
  traBitDEFmod:boolean; //def-модуль (текущий)
  traBitH:boolean; //файл-заголовок
  traBitLoadString:boolean; //параметр pstr
  traLastLoad:integer; //topCode при последнем вызове traLOAD
  traBitOptim:boolean; //был оптимизирован код в traLOAD
  traRecId:pID; //идентификатор типа записи
  traFromDLL:pstr; //текущий модуль DLL
  traListPre:pLIST; //список предописаний указателей
  traTopPre:integer;
  traBitAND:boolean; //признак использования короткой схемы в traEXPRESSION
  traLANG:classLANG;
  traIcon:pstr;
  traCarParam:integer; //номер параметра при проверке заголовка traTITLEtest
  traStackMet:array[1..maxStackMet]of integer; //начало traVARIABLE
  traStackTop:integer;
  traCarPro:classPRO; //текущий уровень инкапсуляции

//===============================================
//            МОДУЛЬ ПЕРЕВОДА PRE
//===============================================

const maxPreList=5000;
const maxInput=0xFFFF;

//---------------- Списки ----------------------

type
  preArrLIST=record
    listTop:integer;
    listArr:array[1..maxPreList]of address;
  end;
  preLIST=pointer to preArrLIST;

//---------------- Описания ----------------------

type
  classDEF=(defNULL,
    defCONST,defTYPE,defVAR,defPROCEDURE,defDIALOG,defBITMAP,defICON,defFROM);
  classPreTYPE=(ptypeNULL,
    ptypeDOUBLE,ptypeBASE,ptypeRECORD,ptypeARRAY,ptypePOINTER,ptypeSCAL);

  pTYPE=pointer to recTYPE;
  recTYPE=record
  case Class:classPreTYPE of
    |doubleType:pstr; //ptypeDOUBLE
    |baseType:pstr; //ptypeBASE
    |recordList,recordCase:preLIST; //ptypeRECORD (recordList,recordCase - списки типа pDEF)
    |arrayBeg,arrayEnd:pstr; arrayType:pTYPE; //ptypeARRAY
    |pointerType:pTYPE; //ptypePOINTER
    |scalLIST:preLIST; //ptypeSCAL (scalLIST - список типа pstr)
  end;

  recPARAM=record
    paramVar:boolean;
    paramName:pstr;
    paramType:pTYPE;
  end;
  pPARAM=pointer to recPARAM;

  recDEF=record
  case Class:classDEF of
    |constName:pstr; constVal:pstr; //defCONST
    |typeName:pstr; typeType:pTYPE; //defTYPE *
    |varName:pstr; varType:pTYPE; //defVAR
    |procName:pstr; procRez:pTYPE; procPar,procVar,procStat:preLIST; //defPROC (списки типов pPARAM,pDEF и pSTAT)
    |defStr:pstr; //defDIALOG,defBITMAP,defICON,defFROM
  end;
  pDEF=pointer to recDEF;

//---------------- Операторы и модуль ----------------------

type
  classSTAT=(statNULL,
    statEQUAL,statPROC,statRETURN,statIF,statCASE,
    statWHILE,statREPEAT,statFOR,statASM,statWITH,
    statINC,statDEC);

  recELSIF=record
    elsifEXP:pstr;
    elsifLIST:preLIST;
  end;
  pELSIF=pointer to recELSIF;

  recCASECOND=record
    condCONST:pstr;
    condCONST2:pstr;
  end;
  pCASECOND=pointer to recCASECOND;

  recCASESEL=record
    caseCOND:preLIST; //список типа pCASECOND
    caseLIST:preLIST;
  end;
  pCASESEL=pointer to recCASESEL;

  recCALL=record
    callPROC:pstr;
    callLIST:preLIST; //список типа pEXP
  end;

  recSTAT=record
  case Class:classSTAT of
    |equalVAR:pstr; equalEXP:pstr; //statEQUAL
    |procCALL:pCALL; //statPROC
    |returnEXP:pstr; //statRETURN
    |ifEXP:pstr; ifTHEN,ifELSIF,ifELSE:preLIST; //statIF (ifELSIF - список типа pELSIF)
    |caseEXP:pstr; caseLIST,caseELSE:preLIST; //statCASE (caseLIST - список типа pCASESEL)
    |whileEXP:pstr; whileLIST:preLIST; //statWHILE
    |repeatEXP:pstr; repeatLIST:preLIST; //statREPEAT
    |forClass:classFor; forVAR:pstr; forBEG,forEND:pstr; forLIST:preLIST; //statFOR
    |asmLIST:preLIST; //statASM
    |withEXP:pstr; withLIST:preLIST; //statWITH
    |incdecVAR:pstr; incdecEXP:pstr; //statINC,statDEC
  end;
  pSTAT=pointer to recSTAT;

  recMODULE=record
    moduleName:pstr;
    moduleImport:preLIST; //список типа pstr
    moduleExport:preLIST; //список типа pstr
    moduleDef:preLIST; //список типа pDEF
    moduleStat:preLIST; //список типа pSTAT
  end;

//---------------- Входной поток ----------------------

  preStream=record
    stFile:string[maxText]; //имя модуля
    stTxt:integer; //номер модуля
    stPosLex:recPos; //позиция указателя лексем
    stPosPred:recPos; //предыдущая позиция указателя лексем
    stLex:classLex; //текущая лексема
    stLexStr:string[maxText]; //значение лексемы классов lexSTR,lexID,lexNEW
    stLexOld:string[maxText]; //предыдущее значение stLexStr
    stLexInt:cardinal;
    stInput:pstr; //текст программы
    stComment:pstr; //тексты комментариев
    stErr:boolean; //наличие ошибки
    stErrPos:recPos; //позиция ошибки
    stErrText:string[maxText]; //текст ошибки
  end;

//===============================================
//             ИНТЕГРИРОВАННАЯ СРЕДА ENV
//===============================================

//---------------- Тексты ----------------------

type classFrag=(fNULL, //нераспознанный фрагмент
                fINT,  //целое
                fREAL, //вещественное
                fCEP,  //цепочка
                fPARSE,//разделитель
                fREZ,  //зарезервированный идентификатор
                fID,   //идентификатор пользователя
                fASM,  //команда ассемблера
                fREG,  //регистр процессора
                fCOMM);//комментарий

//фрагмент строки
type recFrag=record
       tab:integer;
       txt:pstr;
       beg,len:integer;
       cla:classFrag;
     case of
       | iv:integer; //fINT
       | fv:real; //fREAL
       | rv:classREZ; //fREZ
       | pv:classPARSE; //fPARSE
       | av:classCommand; //fASM
       | mv:classRegister; //fREG
     end;
     pFrag=pointer to recFrag;

type listFrag=record
       topf:integer;
       arrf:array[1..maxFrag]of pFrag;
     end;
     pFrags=pointer to listFrag;
     listStr=record
       tops:integer;
       arrs:array[1..maxStr]of pFrags;
     end;
     pStrs=pointer to listStr;

//текст модуля
type recTxt=record
       txtFile:string[maxTxtFile];
       txtTitle:string[maxTxtTitle];
       txtStrs:pStrs;

       txtTrackX:integer;
       txtTrackY:integer;
       txtCarX:integer;
       txtCarY:integer;

       txtMod:boolean; //текст изменен
       txtLoad:boolean; //текст загружен

       blkSet:boolean;
       blkX:integer;
       blkY:integer;
     end;

var
    txts:array[0..1]of array[1..maxTxt]of recTxt;
    txtn:array[1..maxTxt]of integer; //0-imp, 1-def
    topt:integer;
    tekt:integer;
    mait:integer;
    envER:classER;

//----------- шрифты редактора ----------------

type classOtr=(oW,oB,oWB,oBW,oWBW);

  recFont=record
    fFace:string[maxStrID];
    fSize:integer;
    fBold:boolean;
    fItal:boolean;
    fCol:cardinal;
    foID:HFONT;
    fY:byte;
    fABC:array['\0'..'\255']of byte;
  end;
  arrFont=array[classFrag]of recFont;

const _stFont=arrFont{
  {"Arial Cyr",10,true,false,0x0000FF,,,},
  {"Arial Cyr",10,false,false,0xFF0000,,,},
  {"Arial Cyr",10,false,false,0xFF0000,,,},
  {"Arial Cyr",10,false,false,0xFF0000,,,},
  {"Arial Cyr",10,false,false,0x000000,,,},
  {"Arial Cyr",10,true,false,0x000000,,,},
  {"Arial Cyr",10,false,false,0x000000,,,},
  {"Courier New Cyr",10,false,true,0x000000,,,},
  {"Courier New Cyr",10,false,true,0x000000,,,},
  {"Arial Cyr",10,true,false,0x8F008F,,,}};

var stFont:arrFont; carFont:recFont;

//-------------- Статус-строка --------------------

type classStatus=(staMod,staStr,staSto,staDeb,staIdent);

//-------------- Переменные --------------------

var //mainWnd:HWND; перенесено в win32ext
    editWnd:HWND;
    wndToolbar:HWND;
    wndTabs:HWND;
    wndExt:HWND;
    wndStatus:HWND;
    infDlg:HWND;
    infCancel:boolean;

    errTxt:integer;
    errExt:integer;
    modVarCallAsm:integer;

    findBeg,findReg:boolean;
    findStr,findRep:pstr;
    findArr:array[0..maxFind]of pstr; findTop:integer;

    blkBegX,blkBegY:integer;
    blkEndX,blkEndY:integer;

    envErrPos:pstr;
    envIdName:pstr;
    lastIdName:pstr;
    envIdVal:pstr;
    envIdMod:pstr;
    envIdMods:pstr;
    envBitSaveFiles:boolean;
    envSelectMouse:boolean;
    envUndo:pointer to arrUndo;
    envTopUndo:integer;
    envMenuH:array[classGroup]of HMENU;
    traMakeDLL:boolean;
    envOldFolder:string[300];

    time:integer;

    buffer:boolean;

//--------------- Процедуры --------------------

procedure datInitial();
procedure datDestroy();
procedure datDefaultComp();
procedure datDefaultEnv();
procedure datLoadConst();
procedure datSaveConst();
procedure lexError(var Stream:recStream; errText,errMes:pstr);
procedure lexTest(bitTest:boolean; var Stream:recStream; errText,errMes:pstr);
procedure okREZ(var S:recStream; rez:classREZ):boolean;
procedure okPARSE(var S:recStream; par:classPARSE):boolean;
procedure okASM(var S:recStream; instr:classCommand):boolean;

//end SmDat.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TAB (таблица идентификаторов)
//Файл SMTAB.D

//definition module SmTab;
//import Win32,SmDat;

//работа с таблицей идентификаторов
  procedure idInitial(var tab:pID; no:integer);
  procedure idDestroy(var tab:pID);
  procedure idDestroys();
  procedure idInsert(var tab:pID; name:pstr; Class:classID; ta:classTab; no:integer):pID;
  procedure idInsertGlo(name:pstr; Class:classID):pID;
  procedure idFind(var tab:pID; name:pstr):pID;
  procedure idFindGlo(name:pstr; bitFix:boolean):pID;
  procedure idWriteS(fil:integer; s:pstr);
  procedure idReadS(fil:integer; var s:pstr);
  procedure tabGetImpNo(var S:recStream; oldNo:integer; bitMess:boolean):integer;
  procedure tabGetImpId(var S:recStream; no:integer; name:pstr; bitMess:boolean):pID;
  procedure idWrite(var tab:pID; fil:integer);
  procedure idRead(var S:recStream; var tab:pID; fil:integer; no:integer);
  procedure idChangeMod(tab:pID; old,New:integer);
  procedure idViewMod0(filName:pstr);

//работа со списками идентификаторов и имен
  procedure listAdd(addLIST:pLIST; addID:pID; var addTop:integer);
  procedure listFind(list:pLIST; top:integer; name:pstr):pID;
  procedure subAdd(addSUB:pSubs; addID:pID; var addTop:integer);
  procedure nameAdd(list:pName; name:pstr; var top:integer);
  procedure nameFind(list:pName; top:integer; name:pstr):integer;

//работа со списками импорта и экспорта
  procedure impFind(addIMP:pIMPORT; addDLL,addFun:pstr; var addTop,nomDLL,nomFun:integer);
  procedure impAdd(addIMP:pIMPORT; addDLL,addFun:pstr; addAddr:integer; var addTop:integer):address;
  procedure impDestroy(addIMP:pIMPORT; addTop:integer);
  procedure impWrite(addIMP:pIMPORT; addTop:integer; fil:integer);
  procedure impRead(addIMP:pIMPORT; addTop:integer; fil:integer);
  procedure expAdd(expo:pEXPORT; name:pstr; var top:integer);
  procedure expDestroy(expo:pEXPORT; top:integer);
  procedure expWrite(expo:pEXPORT; top:integer; fil:integer);
  procedure expRead(expo:pEXPORT; top:integer; fil:integer);

//работа со списками строк
  procedure stringAdd(addSTRING:pSTRING; addStr:pstr; addSou:integer; var addTop:integer);
  procedure stringFree(addSTRING:pSTRING; var addTop:integer);

//работа со списком брейков
  procedure stepAdd(var S:recStream; nom:integer; addClass:classStep);
  procedure stepPush(pushClass:classStep; pushParent:integer);
  procedure stepPop();

//информационное окно
  procedure envInfBegin(title,title2:pstr);
  procedure envInfEnd();
  procedure envInf(s1,s2:pstr; pro:integer);

//end SmTab.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль GEN (генерация кода)
//Файл SMGEN.D

//definition module SmGen;
//import Win32,SmDat;

  procedure genInitial();
  procedure genDestroy();

  procedure genAddJamp(var S:recStream; var aList:lstJamp; aVal:integer; aCom:classCommand);
  procedure genSetJamps(var S:recStream; var aList:lstJamp; aVal:integer);
  procedure genSetJamp(var S:recStream; aJamp,aLab:integer; aCom:classCommand);
  procedure genAddCall(var S:recStream; aSou:integer; aProc:pID);
  procedure genSetCalls(var S:recStream; var calls:lstCall; nom:integer; bitMessage:boolean);
  procedure genAddVarCall(var S:recStream; tekno,no,track:integer; cl:classVarCall; cla:pstr);
  procedure genAddProCall(var S:recStream; tekno,no,track:integer; sou:pstr);

  procedure genPutByte(var Stream:recStream; putByte:byte):integer;
  procedure genPutStr(var Stream:recStream; putStr:pstr):integer;
  procedure genPutVar(var Stream:recStream; putVar:pstr; putLen:integer):integer;

  procedure genByte(var Stream:recStream; b:byte);
  procedure genCard(var Stream:recStream; w:cardinal; bitW:boolean);
  procedure genLong(var Stream:recStream; l:integer; W:cardinal);
  procedure genPref(var Stream:recStream; prefReg:classRegister);
  procedure genFirst(var Stream:recStream; firstCod,firstPri:byte; D,W:cardinal);
  procedure genPost(var S:recStream; PostExt:byte; Base,Indx:classRegister; Dist:integer);
  procedure genSeg(var Stream:recStream; Instr:classCommand; Reg1,Reg2:classRegister);
  procedure genRR(var Stream:recStream; Instr:classCommand; Reg1,Reg2:classRegister);
  procedure genRD(var Stream:recStream; Instr:classCommand; Reg:classRegister; Data:integer);
  procedure genMR(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx,Reg:classRegister; Dist,D:integer);
  procedure genMD(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx:classRegister; Dist,Data:integer; W:cardinal);
  procedure genST(var Stream:recStream; Instr:classCommand; Reg:classRegister);
  procedure genR(var Stream:recStream; Instr:classCommand; Reg:classRegister);
  procedure genM(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx:classRegister; Dist:integer; W:cardinal);
  procedure genD(var Stream:recStream; Instr:classCommand; D:integer);
  procedure genGen(var Stream:recStream; Instr:classCommand; W:integer);
  procedure genRegCL(var Stream:recStream; Instr:classCommand; Reg:classRegister);
  procedure genPOP(var Stream:recStream; Reg:classRegister; bitAND:boolean);

  procedure genBaseCla(cla:pID):pID;
  procedure genFindMetod(Class:pID; name:pstr):pID;
  procedure genAlign(siz,align:integer):integer;
  procedure genSize(sTab:classExe; align:integer):integer;
  procedure genExeName(sou,folder,res:pstr; bitDLL:boolean);
  procedure genExe(var S:recStream; gName:pstr; no:integer);
  procedure genDef(var S:recStream; gName:pstr; no:integer);
  procedure genImp(var S:recStream; gName:pstr; no:integer):boolean;

  procedure genSizeDlg(m,d:integer):integer;
  procedure genFreeRes(no:integer);
  procedure genLoadMod(var S:recStream; name:pstr; no:integer; bitLoadFile:boolean):boolean;
  procedure genCloseMod(no:integer);
  procedure genCloseMods();

//end SmGen.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль LEX (лексический анализ)
//Файл SMLEX.D

//definition module SmLex;
//import Win32,SmDat;

  var lexZEROSTR:string[4]; //'\0'

  procedure lexNextLex(var Stream:recStream; bitID:boolean);
  procedure lexOpen(var Stream:recStream; opFile:pstr; opTxt,opExt:integer);
  procedure lexClose(var Stream:recStream);
  procedure lexGetLex0(var Stream:recStream);
  procedure lexGetLex1(var Stream:recStream);
  procedure lexLexName(var Stream:recStream; lex:classLex; val:integer; name:pstr):pstr;
  procedure lexLexVal(var Stream:recStream; lex:classLex; val:integer; res :pstr):pstr;
  procedure lexAccept00(var Stream:recStream; lex:classLex; val:integer);
  procedure lexAccept0(var Stream:recStream; lex:classLex; val:integer);
  procedure lexAccept1(var Stream:recStream; lex:classLex; val:integer);

//end SmLex.
///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль ASM (встроенный ассемблер)
//Файл SMASM.D

//definition module SmAsm;
//import Win32,SmDat;

procedure asmInitial();
procedure asmDestroy();
procedure asmAssembly(var S:recStream);

//end SmAsm.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TRA (трансляция модуля, язык Модула-2)
//Файл SMTRA.D

//definition module SmTra;
//import Win32,SmDat;

procedure traCall32(var S:recStream; mo,pr:pstr);
procedure traEqv(var S:recStream; e1,e2:pID; eErr:boolean):boolean;
procedure traFinish(var S:recStream);
procedure traAddModule(var S:recStream; name:pstr):integer;
procedure traGenEqv(S:recStream; eTypeVar,eTypeExp:pID);
procedure traCorrCall(var S:recStream; var modif:arrModif; var topModif:integer; oldBeg,oldEnd,newBeg,begCode:integer);
procedure traVarWITH(var S:recStream);
procedure traTITLEtest(var S:recStream; procId:pID);
procedure traMetNom(cla,own:pID):integer;

procedure traMODULE(var S:recStream);
procedure traSTRUCT(var S:recStream; typId:pID);
procedure traVARIABLE(var S:recStream; bitOnlyName,bitOnlyVar,bitStatMetod:boolean):pID;
procedure traEXPRESSION(var S:recStream):pID;
procedure traRETURN(var S:recStream);
procedure traDIALOG(var S:recStream);
procedure traBITMAP(var S:recStream);
procedure traICON(var S:recStream);
procedure traFROM(var S:recStream);
procedure traTEST(var S:recStream; cla:classFor; modif:classModif):integer;
procedure traMODIF(var S:recStream; cla:classFor; modif:classModif; forType:pID; labBeg,jmpEnd:cardinal);
procedure traPROTECTED(var S:recStream; bitDup:boolean);
procedure traSTRING(var S:recStream; typId:pID);
procedure traSET(var S:recStream; typId:pID);
procedure traSCALAR(var S:recStream; typId:pID);
procedure traCONSTs(var S:recStream);
procedure traSELECT(var S:recStream; sType:pID);
procedure traEQUAL(var S:recStream);
procedure traCALL(var S:recStream; bitStat:boolean; cProc:pID):pID;
procedure traREPEAT(var S:recStream);
procedure traASM(var S:recStream);
procedure traINCDEC(var S:recStream);
procedure traNEW(var S:recStream);
procedure traFORMAL(var S:recStream; procId:pID);
procedure traIMPORT(var S:recStream); forward;

//end SmTra.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TRAC (трансляция модуля, язык Си)
//Файл SMTRAC.D

//definition module SmTraC;
//import Win32,SmDat;

procedure tracMODULE(var S:recStream; modName:pstr);

//end SmTraC.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TRAP (трансляция модуля, язык Паскаль)
//Файл SMTRAP.D

//definition module SmTraP;
//import Win32,SmDat;

procedure trapMODULE(var S:recStream);

//end SmTraP.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль RES (редакторы ресурсов)
//Файл SMRES.D

//definition module SmRes;
//import Win32,SmDat;

const классЭлемента="Str32DlgItem";
const классДиалога="Str32DlgMain";

procedure envCorrFont(f:classFrag);
procedure resTxtToDlg(cart:integer; var начY,конY:integer):boolean;
procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean;
procedure ресКоррДиалог(битНовый:boolean):pstr;
procedure ресНастройки();
procedure ресИницКлассы();
procedure ресЗагрПарам();

//end SmRes.

///////////////////////////////////////////////////////////////////////////////
//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль ENV (утилиты интегрированной среды)
//Файл SMENV.D

//definition module SmEnv;
//import Win32,SmDat;

procedure envCreateTitle(wnd:HWND);
procedure envDestroyTitle();
procedure envEnable();
procedure envUndoClear();
procedure envUndoPop(t:integer);
procedure envSetCaret(txt:integer);
procedure envEditCopy(t:integer);
procedure envUndoPush(cla:classUNDO; t:integer);
procedure envEditDel(t:integer);
procedure envUndoBlockEnd(t:integer);
procedure envEditIns(t:integer);
procedure envEditAll();
procedure envSetStatus(txt:integer);
procedure envButtonCreate();

procedure envNew();
procedure envOpen(iPath,iTitle:pstr; t:integer);
procedure envSelect(nom,ext:integer);
procedure envClose();
procedure envSave();
procedure envSaveAs();
procedure envSaveFiles(bitCancel:boolean):boolean;

procedure envStatusCreate(bitIni:boolean);
procedure envStatusLoad();
procedure envStatusSave();

procedure envTranslate();
procedure envTransAll(traFind,traDll:boolean):boolean;
procedure envExecute();
procedure envDebRun();
procedure envDebRunEnd();
procedure envDebEnd();
procedure envDebNextDown();
procedure envDebNext();
procedure envDebGoto();
procedure envDebView();
procedure envResource(cart:integer);
procedure envHelp(helpFile:pstr);
procedure envAbout();
procedure envIdentifier();
procedure envSetComp();
procedure envSetEnv();
procedure envInitClass();

procedure отлЗакончить();

//end SmEnv.
///////////////////////////////////////////////////////////////////////////////
end SmImp.
