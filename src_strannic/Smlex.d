//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль LEX (лексический анализ)
//Файл SMLEX.D

definition module SmLex;
import Win32,SmDat;

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

end SmLex.

