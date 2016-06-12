//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TAB (таблица идентификаторов)
//Файл SMTAB.D

definition module SmTab;
import Win32,SmDat;

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

end SmTab.

