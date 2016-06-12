//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль GEN (генерация кода)
//Файл SMGEN.D

definition module SmGen;
import Win32,SmDat;

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

end SmGen.

