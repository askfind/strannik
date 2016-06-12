//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TRA (трансляция модуля, язык Модула-2)
//Файл SMTRA.D

definition module SmTra;
import Win32,SmDat;

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

end SmTra.

