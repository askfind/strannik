//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль DAT (структуры данных)
//Файл SMDAT.M

implementation module SmDat;
import Win32,Win32Ext,SmSys;

//===============================================
//                 Инициализация
//===============================================

//--------- Сохранение констант ---------------

procedure datSaveConst();
var fil:integer;
begin
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;
  fil:=_lcreat(ConstFile,0);
  if fil>0 then 
    _lwrite(fil,addr(genBASECODE),4);
    _lwrite(fil,addr(genSTACKMAX),4);
    _lwrite(fil,addr(genSTACKMIN),4);
    _lwrite(fil,addr(genHEAPMAX),4);
    _lwrite(fil,addr(genHEAPMIN),4);
    _lwrite(fil,envEXTM,40);
    _lwrite(fil,envEXTD,40);
    _lwrite(fil,envEXTI,40);
    _lwrite(fil,addr(ediTrackX),4);
    _lwrite(fil,addr(envEDITBK),4);
    _lwrite(fil,addr(envEDITSEL),4);
    _lwrite(fil,addr(envTRACKMAX),4);
    _lwrite(fil,addr(envTRACKUP),4);
    _lwrite(fil,envWIN32,40);
    _lwrite(fil,envBMPE,80);
    _lwrite(fil,addr(stFont),sizeof(arrFont));
    _lwrite(fil,addr(buffer),4);
    _lwrite(fil,addr(envER),1);
    _lwrite(fil,addr(genCLASSSIZE),4);
    _lwrite(fil,envExeFolder,270);
    _lclose(fil)
  end
end datSaveConst;

//---------- Загрузка констант ----------------

procedure datLoadConst();
var fil:integer;
begin
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;
  fil:=_lopen(ConstFile,0);
  if fil>0 then
    _lread(fil,addr(genBASECODE),4);
    _lread(fil,addr(genSTACKMAX),4);
    _lread(fil,addr(genSTACKMIN),4);
    _lread(fil,addr(genHEAPMAX),4);
    _lread(fil,addr(genHEAPMIN),4);
    _lread(fil,envEXTM,40);
    _lread(fil,envEXTD,40);
    _lread(fil,envEXTI,40);
    _lread(fil,addr(ediTrackX),4);
    _lread(fil,addr(envEDITBK),4);
    _lread(fil,addr(envEDITSEL),4);
    _lread(fil,addr(envTRACKMAX),4);
    _lread(fil,addr(envTRACKUP),4);
    _lread(fil,envWIN32,40);
    _lread(fil,envBMPE,80);
    _lread(fil,addr(stFont),sizeof(arrFont));
    _lread(fil,addr(buffer),4);
    _lread(fil,addr(envER),1);
    _lread(fil,addr(genCLASSSIZE),4);
    _lread(fil,envExeFolder,270);
    _lclose(fil)
  end
end datLoadConst;

//-------- Инициализация констант -------------

procedure datDefaultComp();
begin
  genBASECODE:=_genBASECODE;
  genSTACKMAX:=_genSTACKMAX;
  genSTACKMIN:=_genSTACKMIN;
  genHEAPMAX:=_genHEAPMAX;
  genCLASSSIZE:=_genCLASSSIZE;
  genHEAPMIN:=_genHEAPMIN;
  envEXTM:=memAlloc(40); lstrcpy(envEXTM,_envEXTM);
  envEXTD:=memAlloc(40); lstrcpy(envEXTD,_envEXTD);
  envEXTI:=memAlloc(40); lstrcpy(envEXTI,_envEXTI);
end datDefaultComp;

procedure datDefaultEnv();
begin
  ediTrackX :=_ediTrackX;
  envEDITBK:=_envEDITBK;
  envEDITSEL:=_envEDITSEL;
  envTRACKMAX:=_envTRACKMAX;
  envTRACKUP:=_envTRACKUP;
  envWIN32:=memAlloc(maxText); lstrcpy(envWIN32,_envWIN32);
  envBMPE:=memAlloc(maxText); lstrcpy(envBMPE,_envBMPE);
  envExeFolder:=memAlloc(maxText); lstrcpy(envExeFolder,"");
  stFont:=_stFont;
  resWIN32:=memAlloc(maxText); lstrcpy(resWIN32,_resWIN32);
end datDefaultEnv;

//-------- Инициализация переменных------------

procedure datInitial();
var i:integer;
begin
  carSet:=setSmEn;

  datDefaultComp();
  datDefaultEnv();
  datLoadConst();

  time:=0;
  topt:=0;
  tekt:=1;
  mait:=0;

  topMod:=0;
  topModImp:=0;
  topWith:=0;

  envError:=0;
  envBitInit:=false;
  findBeg:=true;
  findReg:=false;
  findStr:=memAlloc(maxText); findStr[0]:=char(0);
  findRep:=memAlloc(maxText); findRep[0]:=char(0);

  genEntry:=0;
  genEntryNo:=0;
  genEntryStep:=0;
  gloImport:=nil; gloTop:=0;
  gloExport:=nil; gloTopExp:=0;

  genSTRING:=memAlloc(sizeof(arrSTRING));
  topSTRING:=0;

  traRecId:=nil;
  traFromDLL:=memAlloc(maxText);
  traFromDLL[0]:=char(0);
  traLANG:=langMODULA;
  traIcon:=memAlloc(maxText);
  traIcon[0]:=char(0);
  traMakeDLL:=false;
  traCarPro:=proNULL;
  stepTopActive:=0;
  stepDebugged:=false;
  stepWnd:=0;
  identWnd:=0;
  stepLastWnd:=0;
  stepLastLine:=0;

  resClasses:=memAlloc(sizeof(arrClass));
  resTopClass:=0;
  resStyles:=nil;
  resTopStyles:=0;

  envErrPos:=memAlloc(maxText);
  lstrcpy(envErrPos,"0x403000");
  envIdName:=memAlloc(maxText);
  lastIdName:=memAlloc(maxText); lastIdName[0]:='\0';
  envIdVal:=memAlloc(5000);
  envIdMod:=memAlloc(maxText);
  envIdMods:=memAlloc(maxText);
  envBitSaveFiles:=false;
  envSelectMouse:=false;
  envUndo:=memAlloc(sizeof(arrUndo));
  envTopUndo:=0;
  envOldFolder[0]:='\0';
//  envER:=erRussian;
  errTxt:=0;
  findTop:=0;  

  for i:=1 to maxTxt do
    txtn[i]:=0;
  end;

  lexBitConst:=false;

end datInitial;

//-------------- освобождение -----------------

procedure datDestroy();
var i:integer;
begin
  memFree(findStr);
  memFree(findRep);
  memFree(genSTRING);
  memFree(traFromDLL);
  memFree(traIcon);
  memFree(resClasses);
  memFree(resWIN32);
  for i:=1 to resTopStyles do
    memFree(resStyles^[i])
  end;
  memFree(resStyles);
  memFree(envErrPos);
  memFree(envIdName);
  memFree(lastIdName);
  memFree(envIdVal);
  memFree(envIdMod);
  memFree(envIdMods);
  memFree(envUndo);

  memFree(envWIN32);
  memFree(envBMPE);
  memFree(envExeFolder);
  memFree(envEXTM);
  memFree(envEXTD);
  memFree(envEXTI);
end datDestroy;

//----------- Сообщение об ошибке -------------

procedure lexError(var Stream:recStream; errText,errMes:pstr);
begin
  with Stream do
    if not stErr then
      stErr:=true;
      stErrPos:=stPosPred;
      lstrcpy(stErrText,errText);
      lstrcat(stErrText,errMes);
      stErrExt:=stExt;
      stLex:=lexNULL;
    end
  end
end lexError;

//----------- Проверка на ошибку --------------

procedure lexTest(bitTest:boolean; var Stream:recStream; errText,errMes:pstr);
begin
  if bitTest then 
    lexError(Stream,errText,errMes) 
  end
end lexTest;

//- Проверка на зарезервированный идентификатор -

procedure okREZ(var S:recStream; rez:classREZ):boolean;
begin
  with S do
    return (stLex=lexREZ)and(stLexInt=integer(rez))
  end
end okREZ;

//--------- Проверка на разделитель -----------

procedure okPARSE(var S:recStream; par:classPARSE):boolean;
begin
  with S do
    return (stLex=lexPARSE)and(stLexInt=integer(par))
  end
end okPARSE;

//------ Проверка на команду ассемблера -------

procedure okASM(var S:recStream; instr:classCommand):boolean;
begin
  with S do
    return (stLex=lexASM)and(stLexInt=integer(instr))
  end
end okASM;

end SmDat.

