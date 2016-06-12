//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TRAP (трансляция модуля, язык Паскаль)
//Файл SMTRAP.M

implementation module SmTraP;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra;

procedure trapDefTYPE(var S:recStream; typName:pstr; bitNew:boolean):pID; forward;
procedure trapDefVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST); forward;
procedure trapListVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST); forward;
procedure trapPROC(var S:recStream); forward;
procedure trapSTATEMENT(var S:recStream); forward;
procedure trapListSTAT(var S:recStream; bitBeginEnd:boolean); forward;

//----------- Описание массива ----------------

procedure trapARRAY(var S:recStream; typId:pID);
//ARRAY="ARRAY" ["[" Низ ".." Верх "]"] "OF" Тип
begin
with S,typId^ do
  idClass:=idtARR;
  lexAccept1(S,lexREZ,integer(rARRAY));
  if not okREZ(S,rOF) then
    lexBitConst:=true;
    lexAccept1(S,lexPARSE,integer(pSqL));
    if stLex=lexTYPE then //скаляр
      if stLexID^.idClass<>idtSCAL then
        lexError(S,_Ожидался_тип_перечисления[envER],nil);
      end;
      idArrInd:=stLexID;
      extArrBeg:=0;
      extArrEnd:=stLexID^.idScalMax-1;
      lexGetLex1(S);
    else //диапазон
      case stLex of
        lexCHAR:idArrInd:=idTYPE[typeCHAR]; extArrBeg:=stLexInt;|
        lexINT:idArrInd:=idTYPE[typeINT ]; extArrBeg:=stLexInt;|
        lexSCAL:idArrInd:=stLexID^.idScalType; extArrBeg:=stLexInt;|
      else lexError(S,_Ожидалась_целая_константа[envER],nil)
      end;
      lexGetLex1(S);
      lexAccept1(S,lexPARSE,integer(pPoiPoi));
      case stLex of
        lexCHAR:if idArrInd<>idTYPE[typeCHAR] then lexError(S,_Неверный_тип_индекса[envER],nil) else extArrEnd:=stLexInt end;|
        lexINT:if idArrInd<>idTYPE[typeINT] then lexError(S,_Неверный_тип_индекса[envER],nil) else extArrEnd:=stLexInt end;|
        lexSCAL:if idArrInd<>stLexID^.idScalType then lexError(S,_Неверный_тип_индекса[envER],nil) else extArrEnd:=stLexInt end;|
      else lexError(S,_Ожидалась_целая_константа[envER],nil)
      end;
      lexGetLex1(S);
    end;
    lexBitConst:=false;
    lexAccept1(S,lexPARSE,integer(pSqR));
  else
    idArrInd:=idTYPE[typeINT];
    extArrBeg:=0;
    extArrEnd:=0;
  end;
  lexAccept1(S,lexREZ,integer(rOF));
  idArrItem:=trapDefTYPE(S,"#array_item_type",false);
  idtSize:=(extArrEnd-extArrBeg+1)*idArrItem^.idtSize;
  if extArrBeg>extArrEnd then
    lexError(S,_Неверный_диапазон_индексов[envER],nil)
  end
end
end trapARRAY;

//----------- Описание записи -----------------

procedure trapRECORD(var S:recStream; typId:pID);
//RECORD="RECORD" | "OBJECT" ["("ИмяТипа")"] ListVAR [ "CASE" [ListVAR] "OF" {[Константа ":"] "(" ListVAR ")"} ] "END"
var recMax,recCase,recStart,i:integer; oldRec:pID; str:string[maxText];
begin
with S,typId^ do
  idClass:=idtREC;
  case classREZ(stLexInt) of
    rRECORD:lexAccept1(S,lexREZ,integer(rRECORD)); idRecCla:=nil;|
    rOBJECT:lexAccept1(S,lexREZ,integer(rOBJECT)); idRecCla:=typId;|
  end;
  oldRec:=traRecId;
  traRecId:=typId;
  if idRecCla=nil
    then idtSize:=0;
    else idtSize:=4;
  end;
  idRecMax:=0;
  idRecList:=memAlloc(sizeof(arrLIST));
  idRecTop:=0;
  idRecMet:=memAlloc(sizeof(arrLIST));
  if okPARSE(S,pOvL) then
    lexAccept1(S,lexPARSE,integer(pOvL));
    if stLex<>lexTYPE then idRecCla:=typId
    else
      idRecCla:=stLexID;
      lexTest(not((idRecCla<>nil)and(idRecCla^.idClass=idtREC)and(idRecCla^.idRecCla<>nil)),S,
        _Ожидалось_имя_класса[envER],nil);
      if (idRecCla<>nil)and(idRecCla^.idClass=idtREC) then
        idtSize:=idRecCla^.idtSize;
        idRecMax:=idRecCla^.idRecMax;
        for i:=1 to idRecMax do
          lstrcpy(str,idRecCla^.idRecList^[i]^.idName);
          lstrdel(str,0,lstrposc('.',str));
          lstrins(idName,str,0);
          idRecList^[i]:=idInsertGlo(str,idvFIELD);
          idRecList^[i]^.idVarType:=idRecCla^.idRecList^[i]^.idVarType;
          idRecList^[i]^.idVarAddr:=idRecCla^.idRecList^[i]^.idVarAddr;
          idRecList^[i]^.idPro:=idRecCla^.idRecList^[i]^.idPro;
          if idRecList^[i]^.idPro=proPRIVATE then
            idRecList^[i]^.idPro:=proPRIVATE_IMP
          end;
        end;
      end;
      lexAccept1(S,lexTYPE,0);
    end;
    lexAccept1(S,lexPARSE,integer(pOvR));
  end;
  traCarPro:=proNULL;
  trapListVAR(S,idvFIELD,0,idtSize,idRecMax,idRecList);
  if okREZ(S,rCASE) then //варианты
    lexAccept1(S,lexREZ,integer(rCASE));
    if not okREZ(S,rOF) then
      trapDefVAR(S,idvFIELD,0,idtSize,idRecMax,idRecList);
    end;
    lexAccept1(S,lexREZ,integer(rOF));
    recMax:=0;
    recStart:=idtSize;
    while okPARSE(S,pOvL)or(stLex=lexCHAR)or(stLex=lexINT)or(stLex=lexFALSE)or(stLex=lexTRUE)or(stLex=lexSCAL) do
      while (stLex=lexINT)or(stLex=lexCHAR)or(stLex=lexFALSE)or(stLex=lexTRUE)or(stLex=lexSCAL) do
        lexGetLex1(S);
        if okPARSE(S,pCol)
          then lexAccept1(S,lexPARSE,ord(pCol));
          else lexAccept1(S,lexPARSE,ord(pDup));
        end;
      end;
      lexAccept1(S,lexPARSE,integer(pOvL));
      recCase:=recStart;
      trapDefVAR(S,idvFIELD,0,recCase,idRecMax,idRecList);
      if recCase>recMax then
        recMax:=recCase
      end;
      lexAccept1(S,lexPARSE,integer(pOvR));
      lexAccept1(S,lexPARSE,integer(pSem));
    end;
    inc(idtSize,recMax)
  end;
  traRecId:=oldRec;
  lexAccept1(S,lexREZ,integer(rEND))
end
end trapRECORD;

//----------- Описание указателя --------------

procedure trapPOINTER(var S:recStream; typId:pID);
//POINTER="^" Тип
begin
with S,typId^ do
  idClass:=idtPOI;
  lexAccept1(S,lexPARSE,integer(pUg));
  idPoiBitForward:=(stLex=lexNEW);
  if stLex=lexNEW then
    idPoiType:=idTYPE[typeCHAR];
    idPoiPred:=memAlloc(lstrlen(stLexStr)+1);
    lstrcpy(pstr(idPoiPred),stLexStr);
    listAdd(traListPre,typId,traTopPre);
    lexAccept1(S,lexNEW,0);
  else idPoiType:=trapDefTYPE(S,"#poi_base_type",false)
  end;
  idtSize:=4;
end
end trapPOINTER;

//----------- Определение типа ----------------

procedure trapDefTYPE(var S:recStream; typName:pstr; bitNew:boolean):pID;
//DefTYPE=ARRAY|RECORD|POINTER|SCALAR|NEW
var typId,oldFi:pID; str:string[maxText]; i:integer;
begin
with S do
  if (stLex<>lexTYPE)or bitNew then
    typId:=idInsertGlo(typName,idNULL);
  end;
  case stLex of
    lexREZ:
      case classREZ(stLexInt) of
        rARRAY:trapARRAY(S,typId);|
        rSTRING:traSTRING(S,typId);|
        rRECORD,rOBJECT:trapRECORD(S,typId);|
        rSET:traSET(S,typId);|
      else lexError(S,_Ошибка_в_описании_типа[envER],nil);
      end;|
    lexPARSE:
      if classPARSE(stLexInt)=pOvL then traSCALAR(S,typId) //скаляр
      elsif classPARSE(stLexInt)=pUg then trapPOINTER(S,typId) //указатель
      else lexError(S,_Ошибка_в_описании_типа[envER],nil)
      end;|
    lexTYPE:
      if bitNew then 
      with typId^ do //новый тип
        idClass:=stLexID^.idClass;
        idNom  :=stLexID^.idNom;
        idtSize:=stLexID^.idtSize;
        case idClass of
          idtBAS:idBasNom:=stLexID^.idBasNom;|
          idtARR:
             idArrItem:=stLexID^.idArrItem;
             idArrInd :=stLexID^.idArrInd;
             extArrBeg:=stLexID^.extArrBeg;
             extArrEnd:=stLexID^.extArrEnd;|
          idtREC:
            idRecList :=memAlloc(sizeof(arrLIST));
            idRecList^:=stLexID^.idRecList^;
            idRecMax  :=stLexID^.idRecMax;
            for i:=1 to idRecMax do
              oldFi:=idRecList^[i];
              lstrcpy(str,oldFi^.idName);
              lstrdel(str,0,lstrposc('.',str));
              lstrins(typName,str,0);
              idRecList^[i]:=idInsertGlo(str,idvFIELD);
              idRecList^[i]^.idVarType:=oldFi^.idVarType;
              idRecList^[i]^.idVarAddr:=oldFi^.idVarAddr;
              idRecList^[i]^.idPro:=oldFi^.idPro;
            end;|
          idtPOI:idPoiType:=stLexID^.idPoiType;|
          idtSCAL:
            idScalList :=memAlloc(sizeof(arrLIST));
            idScalList^:=stLexID^.idScalList^;
            idScalMax  :=stLexID^.idScalMax;|
        end
      end
      else typId:=stLexID
      end;
      lexGetLex1(S);|
  else lexError(S,_Ожидалось_описание_типа[envER],nil)
  end;
  return typId
end
end trapDefTYPE;

//------------- Описание типа -----------------

procedure trapTYPE(var S:recStream);
//TYPE=Имя "=" DefTYPE
var typId:pID; typName:string[maxText];
begin
with S do
  lexAccept1(S,lexNEW,0);
  lstrcpy(typName,stLexOld);
  lexAccept1(S,lexPARSE,integer(pEqv));
  trapDefTYPE(S,typName,true)
end
end trapTYPE;

//---------- Описание блока типов -------------

procedure trapTYPEs(var S:recStream);
//TYPEs="TYPE" {TYPE ";"}
var i:integer;
begin
with S do
  traListPre:=memAlloc(sizeof(arrLIST));
  traTopPre:=0;
  lexAccept1(S,lexREZ,integer(rTYPE));
  while stLex=lexNEW do
    trapTYPE(S);
    lexAccept1(S,lexPARSE,integer(pSem));
  end;
  for i:=1 to traTopPre do
  with traListPre^[i]^ do
    idPoiType:=idFindGlo(idPoiPred,false);
    if idPoiType=nil then
      lexError(S,_Отсутствует_описание_типа_[envER],idPoiPred);
    else idPoiBitForward:=false
    end;
//    idPoiPred:=nil
  end end;
  memFree(traListPre);
end
end trapTYPEs;

//------------ Список переменных --------------

procedure trapDefVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST);
//DefVAR=Имя {"," Имя} ":" Тип
var i,varTop:integer; varId,varType:pID; str:string[maxText];
begin
with S do
  varTop:=vTop;
  while stLex=lexNEW do
    if vId<>idvFIELD then lstrcpy(str,stLexStr)
    else
      lstrcpy(str,traRecId^.idName);
      lstrcatc(str,'.');
      lstrcat(str,stLexStr);
      with traRecId^ do
      if listFind(idRecList,idRecMax,str)<>nil then
        lexError(S,_Повторное_имя_поля_[envER],stLexStr)
      end end
    end;
    if stErr then return end;
    varId:=idInsertGlo(str,vId);
    listAdd(vList,varId,vTop);
    lexAccept1(S,stLex,0);
    if not okPARSE(S,pDup) then
      lexAccept1(S,lexPARSE,integer(pCol));
    end
  end;
  lexTest(stLex<>lexPARSE,S,_Ожидалось_новое_имя[envER],nil);
  lexAccept1(S,lexPARSE,integer(pDup));
  varType:=trapDefTYPE(S,"#var_type",false);

  for i:=varTop+1 to vTop do
  with vList^[i]^ do
    idVarType:=varType;
    idVarAddr:=vBeg+vMem;
    if vId=idvVPAR
      then inc(vMem,4)
      else inc(vMem,varType^.idtSize)
    end;
    idPro:=traCarPro;
  end end;
end
end trapDefVAR;

//-------- Список описаний переменных ---------

procedure trapListVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST);
//ListVAR={DefVAR ";"}
begin
with S do
  while ((stLex=lexNEW)or
    okREZ(S,rPRIVATE)or okREZ(S,rPROTECTED)or okREZ(S,rPUBLIC)or
    (vId=idvFIELD)and(traRecId<>nil)and(traRecId^.idRecCla<>nil)and
    (okREZ(S,rPROCEDURE)or okREZ(S,rFUNCTION)))and not stErr do
    traPROTECTED(S,false);
    if okREZ(S,rPROCEDURE) or okREZ(S,rFUNCTION) then trapPROC(S)
    else
      trapDefVAR(S,vId,vBeg,vMem,vTop,vList);
      lexAccept1(S,lexPARSE,integer(pSem));
    end
  end
end
end trapListVAR;

//-------- Описание блока переменных ----------

procedure trapVARs(var S:recStream);
//VARs="VAR" ListVAR
var varList:arrLIST; varTop:integer;
begin
with S do
  lexAccept1(S,lexREZ,integer(rVAR));
  varTop:=0;
  with tbMod[tekt] do
    trapListVAR(S,idvVAR,0,topData,varTop,varList);
  end;
end
end trapVARs;

//------------- Список описаний ---------------

procedure trapListDEF(var S:recStream);
//ListDEF={CONSTs|TYPEs|VARs|PROC|DIALOG|BITMAP|FROM}
begin
with S do
  while (stLex=lexREZ)and(
    (stLexInt=integer(rCONST))or
    (stLexInt=integer(rTYPE))or
    (stLexInt=integer(rVAR))or
    (stLexInt=integer(rPROCEDURE))or
    (stLexInt=integer(rFUNCTION))or
    (stLexInt=integer(rDIALOG))or
    (stLexInt=integer(rBITMAP))or
    (stLexInt=integer(rICON))or
    (stLexInt=integer(rFROM))) do
  case classREZ(stLexInt) of
    rCONST:traCONSTs(S);|
    rTYPE:trapTYPEs(S);|
    rVAR:trapVARs(S);|
    rPROCEDURE:trapPROC(S);|
    rFUNCTION:trapPROC(S);|
    rDIALOG:traDIALOG(S);|
    rBITMAP:traBITMAP(S);|
    rICON:traICON(S);|
    rFROM:traFROM(S);|
  end end
end
end trapListDEF;

//===============================================
//                ТРАНСЛЯЦИЯ ОПЕРАТОРОВ 
//===============================================

//---------------- Возврат --------------------

procedure trapRETURN(var S:recStream; proc:pID);
//"EXIT" | ":=" EXPRESSION
var cRes:pID;
begin
with S,traCarProc^ do
  if okREZ(S,rEXIT) then lexAccept1(S,lexREZ,integer(rEXIT));
  else
    lexTest(lstrcmp(proc^.idName,idName)<>0,S,_Ожидалось_имя_функции_[envER],stLexOld);
    lexAccept1(S,lexPARSE,integer(pDupEqv));
    if idProcType<>nil then
      traBitAND:=false;
      cRes:=traEXPRESSION(S);
      traEqv(S,idProcType,cRes,true);
      lexTest(idProcType^.idtSize>8,S,_Неверный_тип_результата_функции[envER],nil);
//  pop ax
      genPOP(S,rEAX,traBitAND);
//  and ax,?????? для 1-3 байт
      with idProcType^ do
      if idtSize=1 then genRD(S,cAND,rEAX,0x000000FF)
      elsif idtSize=2 then genRD(S,cAND,rEAX,0x0000FFFF)
      elsif idtSize=3 then genRD(S,cAND,rEAX,0x00FFFFFF)
      end end;
//  pop dx
      if idProcType^.idtSize>4 then
        genR(S,cPOP,rEDX);
      end;
//  and dx,?????? для 5-7 байт
      with idProcType^ do
      if idtSize=5 then genRD(S,cAND,rEDX,0x000000FF)
      elsif idtSize=6 then genRD(S,cAND,rEDX,0x0000FFFF)
      elsif idtSize=7 then genRD(S,cAND,rEDX,0x00FFFFFF)
      end end
    else lexError(S,_Ожидалось_имя_функции[envER],nil)
    end
  end;
//mov si,[bp-_Память-4]; mov bx,[bp-_Память-8]; leave; retf _ПамятьПар
  genMR(S,cMOV,regNULL,rEBP,regNULL,rESI,-genAlign(idProcLock,4)-4,1);
  genMR(S,cMOV,regNULL,rEBP,regNULL,rEBX,-genAlign(idProcLock,4)-8,1);
  genGen(S,cLEAVE,0);
  genD(S,cRET,idProcPar);
end
end trapRETURN;

//----------- Условный оператор ---------------

procedure trapIF(var S:recStream);
//"IF" EXPRESSION THEN STATEMENT
//{"ELSIF" EXPRESSION THEN STATEMENT}
//["ELSE" STATEMENT]
var bitIf:boolean; ifCond:pID; ifEndThen:integer; ifEnd:pointer to lstJamp;
begin
with S,tbMod[tekt] do
  ifEnd:=memAlloc(sizeof(lstJamp));
  ifEnd^.top:=0;
  bitIf:=true;
  while okREZ(S,rIF) or okREZ(S,rELSIF) do
    if bitIf
      then lexAccept1(S,lexREZ,integer(rIF))
      else lexAccept1(S,lexREZ,integer(rELSIF))
    end;
    bitIf:=false;
    traBitAND:=false;
    ifCond:=traEXPRESSION(S);
    traEqv(S,idTYPE[typeBOOL],ifCond,true);
//  pop ax; or ax,ax; je _ifEndThen
    genPOP(S,rEAX,traBitAND);
    genRR(S,cOR,rEAX,rEAX);
    ifEndThen:=topCode;
    genGen(S,cJE,0);
    lexAccept1(S,lexREZ,integer(rTHEN));
    stepAdd(S,tekt,stepVarIF);
    trapSTATEMENT(S);
//  jmp _ifEnd; _ifEndThen:
    genAddJamp(S,ifEnd^,topCode,cJMP);
    genGen(S,cJMP,0);
    genSetJamp(S,ifEndThen,topCode,cJE)
  end;
  if okREZ(S,rELSE) then
    lexAccept1(S,lexREZ,integer(rELSE));
    stepAdd(S,tekt,stepVarIF);
    trapSTATEMENT(S);
  end;
  genSetJamps(S,ifEnd^,topCode);
  memFree(ifEnd);
end
end trapIF;

//------------- Оператор выбора ---------------

procedure trapCASE(var S:recStream);
//"CASE" EXPRESSION "OF" {SELECT ":" STATEMENT ";"} ["ELSE" STATEMENT]
var caseCond:pID; caseEndSel:integer; caseEnd:pointer to lstJamp;
begin
with S,tbMod[tekt] do
  caseEnd:=memAlloc(sizeof(lstJamp));
  caseEnd^.top:=0;
  lexAccept1(S,lexREZ,integer(rCASE));
  traBitAND:=false;
  caseCond:=traEXPRESSION(S);
  with caseCond^ do
  if not ((idClass=idtSCAL)or(idClass=idtBAS)and
    (ord(idBasNom)>=ord(typeBYTE))and(ord(idBasNom)<=ord(typeDWORD))) then
    lexError(S,_Неверный_тип_переключателя[envER],nil);
  end end;
  lexBitConst:=true;
  lexAccept1(S,lexREZ,integer(rOF));
  while (stLex=lexCHAR)or(stLex=lexINT)or(stLex=lexSCAL)or(stLex=lexFALSE)or(stLex=lexTRUE)or okPARSE(S,pMin) do
    traSELECT(S,caseCond);
    caseEndSel:=topCode-5;
    lexBitConst:=false;
    lexAccept1(S,lexPARSE,integer(pDup));
    stepAdd(S,tekt,stepVarCASE);
    trapSTATEMENT(S);
    lexBitConst:=true;
    lexAccept1(S,lexPARSE,integer(pSem));
    genAddJamp(S,caseEnd^,topCode,cJMP);
    genGen(S,cJMP,0);
    genSetJamp(S,caseEndSel,topCode,cJMP);
  end;
  lexBitConst:=false;
  if okREZ(S,rELSE) then
    lexAccept1(S,lexREZ,integer(rELSE));
    stepAdd(S,tekt,stepVarCASE);
    trapSTATEMENT(S);
  end;
  lexAccept1(S,lexREZ,integer(rEND));
  genSetJamps(S,caseEnd^,topCode);
  genR(S,cPOP,rEAX);
  memFree(caseEnd);
end
end trapCASE;

//-------------- Цикл WHILE -------------------

procedure trapWHILE(var S:recStream);
//"WHILE" EXPRESSION "DO" STATEMENT
var whileCond:pID; labBeg,jmpEnd:integer;
begin
with S,tbMod[tekt] do
  lexAccept1(S,lexREZ,integer(rWHILE));
  labBeg:=topCode;
  traBitAND:=false;
  whileCond:=traEXPRESSION(S);
  traEqv(S,idTYPE[typeBOOL],whileCond,true);
//pop ax; or ax,ax; je _whileEnd
  genPOP(S,rEAX,traBitAND);
  genRR(S,cOR,rEAX,rEAX);
  jmpEnd:=topCode;
  genGen(S,cJE,0);
  lexAccept1(S,lexREZ,integer(rDO));
  stepAdd(S,tekt,stepBegWHILE);
  trapSTATEMENT(S);
  stepAdd(S,tekt,stepModWHILE);
//jmp _whileBeg; _whileEnd:
  genGen(S,cJMP,0);
  genSetJamp(S,topCode-5,labBeg,cJMP);
  genSetJamp(S,jmpEnd,topCode,cJE);
end
end trapWHILE;

//-------------- Цикл REPEAT ------------------

procedure trapREPEAT(var S:recStream);
//"REPEAT" ListSTAT "UNTIL" EXPRESSION
var repCond:pID; labBeg:integer;
begin
with S,tbMod[tekt] do
  lexAccept1(S,lexREZ,integer(rREPEAT));
  labBeg:=topCode;
  trapListSTAT(S,false);
  stepAdd(S,tekt,stepModREPEAT);
  lexAccept1(S,lexREZ,integer(rUNTIL));
  traBitAND:=false;
  repCond:=traEXPRESSION(S);
  traEqv(S,idTYPE[typeBOOL],repCond,true);
//  {pop ax; or ax,ax; je _repBeg}
  genPOP(S,rEAX,traBitAND);
  genRR(S,cOR,rEAX,rEAX);
  genGen(S,cJE,0);
  genSetJamp(S,topCode-6,labBeg,cJE);
end
end trapREPEAT;

//---------------- Цикл FOR -------------------

procedure trapFOR(var S:recStream);
//"FOR" VARIABLE ":=" EXPRESSION "TO"|"DOWNTO" ["STRONG"] EXPRESSION STATEMENT
var forType,expType:pID; modif:classModif; labBeg,jmpEnd:integer; Class:classFor;
begin
with S,tbMod[tekt] do
//заголовок цикла
  lexAccept1(S,lexREZ,integer(rFOR));
  forType:=traVARIABLE(S,true,true,false);
  Class:=forNULL;
  with forType^ do
  case idClass of
    idtBAS:case idBasNom of
             typeBYTE:Class:=forBYTE;|
             typeCHAR:Class:=forBYTE;|
             typeINT:Class:=forINT;|
             typeDWORD:Class:=forDWORD;|
           end;|
    idtSCAL:if idtSize=1 then Class:=forBYTE  else Class:=forDWORD end;|
  end end;
  lexTest(Class=forNULL,S,_Недопустимый_тип_счетчика_цикла[envER],nil);
  lexAccept1(S,lexPARSE,integer(pDupEqv));
  traBitAND:=false;
  expType:=traEXPRESSION(S);
  traEqv(S,forType,expType,true);
  case forType^.idtSize of
    1://pop ax; pop si; mov [si],al; push si
      genPOP(S,rEAX,traBitAND);
      genR(S,cPOP,rESI);
      genMR(S,cMOV,regNULL,regNULL,rESI,rAL,0,0);
      genR(S,cPUSH,rESI);|
    4://pop ax; pop si; mov [si],ax; push si
      genPOP(S,rEAX,traBitAND);
      genR(S,cPOP,rESI);
      genMR(S,cMOV,regNULL,regNULL,rESI,rEAX,0,0);
      genR(S,cPUSH,rESI);|
  end;
  if okREZ(S,rDOWNTO) then
    lexAccept1(S,lexREZ,integer(rDOWNTO));
    modif:=modifDOWNTO;
    if okREZ(S,rSTRONG) then
      lexAccept1(S,lexREZ,integer(rSTRONG));
      modif:=modifDOWNTONE;
    end
  else
    lexAccept1(S,lexREZ,integer(rTO));
    modif:=modifTO;
    if okREZ(S,rSTRONG) then
      lexAccept1(S,lexREZ,integer(rSTRONG));
      modif:=modifTONE;
    end
  end;
  traBitAND:=false;
  expType:=traEXPRESSION(S);
  traEqv(S,forType,expType,true);
  lexAccept1(S,lexREZ,integer(rDO));
  jmpEnd:=traTEST(S,Class,modif);
//тело цикла
  labBeg:=topCode;
  stepAdd(S,tekt,stepBegFOR);
  trapSTATEMENT(S);
  stepAdd(S,tekt,stepModFOR);
  traMODIF(S,Class,modif,forType,labBeg,jmpEnd);
end
end trapFOR;

//---------- Оператор WITH --------------------

procedure trapWITH(var S:recStream);
//"WITH" Переменная {"," Переменная} "DO" STATEMENT
var oldTop:integer;
begin
with S do
  lexAccept1(S,lexREZ,integer(rWITH));
  oldTop:=topWith;
  traVarWITH(S);
  while okPARSE(S,pCol) do
    lexAccept1(S,lexPARSE,integer(pCol));
    traVarWITH(S);
  end;
  lexAccept1(S,lexREZ,integer(rDO));
  trapSTATEMENT(S);
  topWith:=oldTop;
end
end trapWITH;

//----------- Список операторов ---------------

procedure trapListSTAT(var S:recStream; bitBeginEnd:boolean);
//ListSTAT="BEGIN" {STATEMENT ";"} "END"
var r:classREZ;
begin
with S do
  if bitBeginEnd then lexAccept1(S,lexREZ,integer(rBEGIN)) end;
  if stLex=lexREZ then r:=classREZ(stLexInt) else r:=rezNULL end;
  while 
    ((stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC)or(stLex=lexVPAR)or
    (stLex=lexFIELD)or(stLex=lexSTRU)or(stLex=lexPROC)or
    (stLex=lexREZ)and(r in [rRETURN,rIF,rCASE,rWHILE,rBEGIN,rREPEAT,rFOR,rASM,rWITH,rINC,rDEC,rNEW]))and 
    not stErr do
    stepAdd(S,tekt,stepSimple);
    trapSTATEMENT(S);
    if not(okREZ(S,rEND)or okREZ(S,rELSIF)or okREZ(S,rELSE)or okREZ(S,rUNTIL)) then
      lexAccept1(S,lexPARSE,integer(pSem));
    end;
    if stLex=lexREZ then r:=classREZ(stLexInt) else r:=rezNULL end;
  end;
  if bitBeginEnd then lexAccept1(S,lexREZ,integer(rEND)) end;
end
end trapListSTAT;

//--------------------- Оператор -------------------

procedure trapSTATEMENT(var S:recStream);
var r:classREZ; oldS:recStream; proc:pID;
begin
  with S do
    with tbMod[tekt],genStep^[topGenStep] do
    case stLex of
      lexVAR,lexPAR,lexLOC,lexVPAR,lexFIELD,lexSTRU:traEQUAL(S);|
      lexPROC:
        proc:=stLexID;
        lexAccept1(S,lexPROC,0);
        if okPARSE(S,pDupEqv)
          then Class:=stepRETURN; trapRETURN(S,proc)
          else Class:=stepCALL; traCALL(S,true,proc)
        end;|
      lexREZ:case classREZ(stLexInt) of
        rRETURN:Class:=stepRETURN; traRETURN(S);|
        rIF:Class:=stepIF; stepPush(Class,topGenStep); trapIF(S); stepPop(); stepAdd(S,tekt,stepEndIF);|
        rCASE:Class:=stepCASE; stepPush(Class,topGenStep); trapCASE(S); stepPop(); stepAdd(S,tekt,stepEndCASE);|
        rWHILE:Class:=stepWHILE; stepPush(Class,topGenStep); trapWHILE(S); stepPop(); stepAdd(S,tekt,stepEndWHILE);|
        rREPEAT:Class:=stepREPEAT; stepPush(Class,topGenStep); trapREPEAT(S); stepPop(); stepAdd(S,tekt,stepEndREPEAT);|
        rFOR:Class:=stepFOR; stepPush(Class,topGenStep); trapFOR(S); stepPop(); stepAdd(S,tekt,stepEndFOR);|
        rASM:traASM(S);|
        rWITH:trapWITH(S);|
        rINC:traINCDEC(S);|
        rDEC:traINCDEC(S);|
        rNEW:traNEW(S);|
        rEXIT:Class:=stepRETURN; trapRETURN(S,nil);|
        rBEGIN:trapListSTAT(S,true);|
      end;|
    end end
  end
end trapSTATEMENT;

//===============================================
//                 ТРАНСЛЯЦИЯ ОПИСАНИЙ
//===============================================

//---------- Заголовок процедуры --------------

procedure trapTITLE(var S:recStream; procId:pID; bitFunc:boolean);
//TITLE="(" [FORMAL {";"|"," FORMAL}] ")" [":" Тип] ";"
begin
with S,procId^ do
  if okPARSE(S,pOvL) then
    lexAccept1(S,lexPARSE,integer(pOvL));
    if not okPARSE(S,pOvR) then
      traFORMAL(S,procId);
      while okPARSE(S,pSem) or okPARSE(S,pCol) do
        lexGetLex1(S);
        traFORMAL(S,procId);
      end
    end;
    lexAccept1(S,lexPARSE,integer(pOvR));
  end;
  if bitFunc then
    lexAccept1(S,lexPARSE,integer(pDup));
    idProcType:=trapDefTYPE(S,"#proc_rez_type",false);
    lexTest(idProcType^.idtSize>8,S,_Неверный_тип_результата_функции[envER],nil);
  end
end
end trapTITLE;

//---------------- Процедура ------------------

procedure trapPROC(var S:recStream);
//PROCEDURE="PROCEDURE" | "FUNCTION" Имя ["ASCII"] TITLE BODY|FORWARD
//BODY=["VAR" ListVAR] "BEGIN" [ListSTAT] "END"
//FROM="FROM" Имя
var procId,procCla,parId,virtId,modId:pID; i:integer; bitFunc,bitComp:boolean; met,name:string[maxText];
begin
with S do
//заголовок
  bitFunc:=okREZ(S,rFUNCTION);
  if bitFunc
    then lexAccept1(S,lexREZ,integer(rFUNCTION));
    else lexAccept1(S,lexREZ,integer(rPROCEDURE));
  end;
  procCla:=nil;
  if (traRecId<>nil)and(traRecId^.idRecCla<>nil) then procCla:=traRecId
  elsif (stLex=lexTYPE)and(stLexID<>nil)and(stLexID^.idClass=idtREC)and(stLexID^.idRecCla<>nil) then
    procCla:=stLexID;
    lexAccept1(S,lexTYPE,0);
    lexAccept1(S,lexPARSE,ord(pPoi));
    if (stLex in setID)and(procCla<>nil) then
      lstrcpy(met,procCla^.idName);
      lstrcatc(met,'.');
      lstrcat(met,stLexStr);
      stLexID:=idFindGlo(met,false);
      if stLexID<>nil then
        stLex:=lexPROC;
        lstrcpy(stLexStr,met);
      end
    end
  end;
  if (stLex=lexPROC)and(procCla<>nil)and(stLexID^.idProcCla=nil) then
    stLex:=lexNEW;
  end;
  if (stLex=lexPROC)and((stLexID^.idProcAddr=-1)or(stLexID^.idNom<tekt)) then //FORWARD
    procId:=stLexID;
    lexAccept1(S,lexPROC,0);
    for i:=1 to procId^.idProcMax do
      procId^.idProcList^[i]^.idActiv:=byte(true);
    end;
    if okPARSE(S,pOvL)or okPARSE(S,pDup) then
      traTITLEtest(S,procId);
    end;
  else //новая процедура
    lexAccept1(S,lexNEW,0);
    if procCla<>nil then
      lstrinsc('.',stLexOld,0);
      lstrins(procCla^.idName,stLexOld,0);
    end;
    procId:=idFindGlo(stLexOld,false);
    lexTest((procId<>nil)and(procId^.idProcAddr<>-1),S,_Повторное_имя_метода[envER],nil);
    if procId=nil then
      procId:=idInsertGlo(stLexOld,idPROC);
      procId^.idProcAddr:=-1;
    end;
    procId^.idProcASCII:=okREZ(S,rASCII);
    if procId^.idProcASCII then
      if not traBitDEF then
        lexError(S,_ASCII_функция_допустима_только_в_def_модуле[envER],nil);
      end;
      lexAccept1(S,lexREZ,integer(rASCII));
    end;
    if traFromDLL[0]=char(0) then procId^.idProcDLL:=nil
    else
      procId^.idProcDLL:=memAlloc(lstrlen(traFromDLL)+1);
      lstrcpy(procId^.idProcDLL,traFromDLL);
    end;
    with procId^ do
      idProcMax:=0;
      idProcList:=memAlloc(sizeof(arrLIST));
      idProcLock:=0;
      idLocMax:=0;
      idProcPar:=0;
      idProcType:=nil;
    end;
    if procCla<>nil then
    with procId^ do
      idProcCla:=procCla;
      idPro:=traCarPro;
      parId:=idInsertGlo("self",idvVPAR);
      with parId^ do
        idVarType:=procCla;
        idVarAddr:=0;
      end;
      listAdd(idProcList,parId,idProcMax);
      inc(idProcPar,4);
      listAdd(idProcCla^.idRecMet,procId,idProcCla^.idRecTop);
    end end;
    trapTITLE(S,procId,bitFunc);
    with procId^ do //проверка на совпадение параметров виртуального метода
    if idProcCla<>nil then
      lstrcpy(name,idName);
      lstrdel(name,0,lstrposc('.',name)+1);
      virtId:=genFindMetod(idProcCla,name);
      if (virtId<>nil)and(virtId<>procId) then
        bitComp:=(idProcMax=virtId^.idProcMax)and(idProcType=virtId^.idProcType);
        for i:=1 to idProcMax do
        if bitComp then
          bitComp:=(idProcList^[i]^.idClass=virtId^.idProcList^[i]^.idClass)and(idProcList^[i]^.idVarType=virtId^.idProcList^[i]^.idVarType);
        end end;
        lexTest(not bitComp,S,_Несовпадение_списка_параметров_виртуального_метода_[envER],virtId^.idName);
      end
    end end
  end;
  if traCarProc<>nil then mbS(_Системная_ошибка_в_traPROC[envER]) end;
  traCarProc:=procId;
  lexAccept1(S,lexPARSE,integer(pSem));
//BODY | DEF | FORWARD
  if okREZ(S,rFORWARD) then //FORWARD
    lexAccept1(S,lexREZ,integer(rFORWARD));
    lexAccept1(S,lexPARSE,integer(pSem))
  elsif (traRecId<>nil)and(traRecId^.idRecCla<>nil) then //метод внутри класса
  else with procId^ do //BODY
    idProcLock:=0;
    idLocMax:=0;
    if not traBitDEFmod then
      idLocList:=memAlloc(sizeof(arrLIST));
//    переменные
      if okREZ(S,rVAR) then
        lexAccept1(S,lexREZ,integer(rVAR));
        trapListVAR(S,idvLOC,0,idProcLock,idLocMax,idLocList);
      end;
//    смещения
      procId^.idProcPar:=0;
      for i:=1 to idProcMax do
      with idProcList^[i]^ do
        idVarAddr:=procId^.idProcPar+8;
        if idClass=idvVPAR
          then inc(procId^.idProcPar,4)
          else inc(procId^.idProcPar,genAlign(idVarType^.idtSize,4))
        end
      end end;
      for i:=1 to idLocMax do
      with idLocList^[i]^ do
        idVarAddr:=0-idVarAddr-idVarType^.idtSize;
      end end;
//  операторы
      with tbMod[tekt] do
        idProcAddr:=topCode;
        stepAdd(S,tekt,stepSimple);
        with genStep^[topGenStep] do
          line:=word(S.stPosPred.y);
          frag:=word(S.stPosPred.f);
        end
      end;
//  enter _Память
      if genAlign(idProcLock,4)<=0x1000-4 then genGen(S,cENTER,genAlign(idProcLock,4))
      else
//      push bp; mov bp,sp
        genR(S,cPUSH,rEBP);
        genRR(S,cMOV,rEBP,rESP);
//      mov cx,_stack div 0x1000;
//      rep:sub sp,0x1000-4;
//      push ax;
//      loop rep;
//      sub sp,_stack mod 0x1000;
        genRD(S,cMOV,rECX,genAlign(idProcLock,4) div 0x1000);
        genRD(S,cSUB,rESP,0x1000-4);
        genR(S,cPUSH,rEAX);
        genGen(S,cLOOP,-9);
        genRD(S,cSUB,rESP,genAlign(idProcLock,4) mod 0x1000);
      end;
// push si; push bx
      genR(S,cPUSH,rESI);
      genR(S,cPUSH,rEBX);
//with self
      if idProcCla<>nil then
        inc(topWith);
        tbWith[topWith]:=idProcCla;
//  mov eax,[ebp+_track]
//  mov [topWith],ax
        genMR(S,cMOV,regNULL,rEBP,regNULL,rEAX,idProcList^[1]^.idVarAddr,1);
        genMR(S,cMOV,regNULL,regNULL,regNULL,regNULL,genBASECODE+0x1000+(topWith-1)*4,0);
      end;
      genStack:=0;
      trapListSTAT(S,true);
      stepAdd(S,tekt,stepRETURN);
      lexAccept1(S,lexPARSE,integer(pSem));
//    pop bx; pop si; leave; ret _ПамятьПар
      genR(S,cPOP,rEBX);
      genR(S,cPOP,rESI);
      genGen(S,cLEAVE,0);
      genD(S,cRET,idProcPar);
//конец with self
      if idProcCla<>nil then
        dec(topWith)
      end
    else //traBitDEF,вставка в список экспорта DLL
      if traMakeDLL then
      with tbMod[stTxt] do
        expAdd(genExport,procId^.idName,topExport);
      end end
    end
  end end;
  procId^.idProcCode:=tbMod[tekt].topCode-procId^.idProcAddr;
//чистка параметров и локальных переменных
  for i:=1 to procId^.idProcMax do
    procId^.idProcList^[i]^.idActiv:=byte(false);
  end;
  for i:=1 to procId^.idLocMax do
    procId^.idLocList^[i]^.idActiv:=byte(false);
  end;
  traCarProc:=nil
end
end trapPROC;

//---------------- Модуль ---------------------

procedure trapMODULE(var S:recStream);
//MODULE=["DEFINITION"] "UNIT" | "PROGRAM" Имя ";"
//       ["USES" Имя ("," Имя) ";"] ListDEF
//       ListSTAT | "END" "."
var i,j:integer;
begin
with S do
  traBitDEFmod:=okREZ(S,rDEFINITION);
  if okREZ(S,rDEFINITION) then
    traBitDEF:=true;
    lexAccept1(S,lexREZ,integer(rDEFINITION));
  end;
  if okREZ(S,rUNIT)and not traBitDEFmod then
    traBitIMP:=true;
  end;
  if traBitH and not traBitDEFmod then lexError(S,_Ожидался_definition_модуль[envER],nil) end;
  if not traBitH and traBitDEFmod then lexError(S,_Ожидался_программный_модуль[envER],nil) end;
  if traBitDEFmod then lexAccept1(S,lexREZ,integer(rUNIT));
  elsif traBitIMP then lexAccept1(S,lexREZ,integer(rUNIT));
  else lexAccept1(S,lexREZ,integer(rPROGRAM)); tbMod[stTxt].modMain:=true;
  end;
  lexAccept1(S,lexNEW,0);
  lstrcpy(traModName,stLexOld);
  lexAccept1(S,lexPARSE,integer(pSem));
  if okREZ(S,rUSES) then
    lexAccept1(S,lexREZ,integer(rUSES));
    traIMPORT(S);
    while okPARSE(S,pCol) do
      lexAccept1(S,lexPARSE,integer(pCol));
      traIMPORT(S);
    end;
    lexAccept1(S,lexPARSE,integer(pSem))
  end;
  trapListDEF(S);
  if okREZ(S,rBEGIN) then
    genStack:=0;
    with tbMod[tekt] do
      genEntry:=topCode;
      genEntryNo:=tekt;
      genEntryStep:=topGenStep;
    end;
    trapListSTAT(S,true);
  else lexAccept1(S,lexREZ,integer(rEND))
  end;
  lexAccept1(S,lexPARSE,integer(pPoi));
  lexAccept1(S,lexEOF,0);
end
end trapMODULE;

end SmTraP.
