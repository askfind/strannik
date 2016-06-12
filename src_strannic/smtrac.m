//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TRAC (трансляция модуля, язык Си)
//Файл SMTRAC.M

implementation module SmTraC;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra;

procedure tracDefTYPE(var S:recStream):pID; forward;
procedure tracListVAR(var S:recStream; vId:classID; vBeg:integer; typ:pID; name:pstr; var vMem,vTop:integer; vList:pLIST); forward;
procedure tracPROC(var S:recStream; typ,procId:pID; name:pstr); forward;
procedure tracBlockSTAT(var S:recStream); forward;
procedure tracListSTAT(var S:recStream); forward;
procedure tracINCDEC(var S:recStream; varType:pID); forward;

//----------- Проверка на тип --------------

procedure tracTYPEOK(var S:recStream):boolean;
begin
  return
    okREZ(S,rVOID)or
    okREZ(S,rUNSIGNED)or
    okREZ(S,rSTRUCT)or
    okREZ(S,rENUM)or
    okREZ(S,rSET)or
    (S.stLex=lexTYPE);
end tracTYPEOK;

//----------- Описание константы --------------

procedure tracCONST(var S:recStream);
//CONST="DEFINE" Имя ["-"] Значение
var conId:pID; bitMin,bitGet:boolean;
begin
with S do
  lexAccept1(S,lexREZ,integer(rDEFINE));
  lexBitConst:=true;
  lexAccept1(S,lexNEW,0);
  conId:=idInsertGlo(stLexOld,idNULL);
  bitMin:=okPARSE(S,pMin);
  if bitMin then
    lexAccept1(S,lexPARSE,integer(pMin));
  end;
  bitGet:=stLex<>lexTYPE;
  with conId^ do
  case stLex of
    lexCHAR:idClass:=idcCHAR; idInt:=stLexInt;|
    lexINT:idClass:=idcINT;  idInt:=stLexInt;|
    lexREAL:idClass:=idcREAL; idReal:=stLexReal;|
    lexSCAL:idClass:=idcSCAL; idScalVal:=stLexInt; idScalType:=stLexID^.idScalType;|
    lexSTR:
      idClass:=idcSTR;
      idStr:=memAlloc(lstrlen(addr(stLexStr))+1);
      lstrcpy(idStr,addr(stLexStr));
      idStrAddr:=genPutStr(S,idStr);|
    lexTYPE:with tbMod[tekt] do
      idClass:=idcSTRU;
      idStruAddr:=genBegData+topData;
      idStruType:=stLexID;
      lexAccept1(S,lexTYPE,0);
      traSTRUCT(S,idStruType);
    end;|
  else lexError(S,_Ожидалось_значение_константы[envER],nil);
  end end;
  if bitMin then
  with conId^ do
  case stLex of
    lexINT:idInt :=-idInt;|
    lexREAL:idReal:=-idReal;|
  else lexError(S,_Ожидалось_число[envER],nil);
  end end end;
  lexBitConst:=false;
  if bitGet then
    lexGetLex1(S);
  end
end
end tracCONST;

//----------- Описание записи -----------------

procedure tracRECORD(var S:recStream; typId:pID):pID;
//RECORD="STRUCT"|"CLASS" ИмяТипа [":" ИмяКласса]
// "{" ListVAR [ "UNION" "{" {"{" ListVAR "}"} "}" ] "}"
var recMax,recCase,recStart,i:integer; oldRec,typ:pID; str:string[maxText];
begin
with S do
  if okREZ(S,rCLASS) then
    lexAccept1(S,lexREZ,integer(rCLASS));
    lexAccept1(S,lexNEW,0);
    typId:=idInsertGlo(stLexOld,idtREC);
    with typId^ do
      idtSize:=4;
      idRecMax:=0;
      idRecTop:=0;
    if okPARSE(S,pDup) then
      lexGetLex1(S);
      traPROTECTED(S,false);
      idRecList:=memAlloc(sizeof(arrLIST));
      idRecMet:=memAlloc(sizeof(arrLIST));
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
    else idRecCla:=typId
    end end
  else lexAccept1(S,lexREZ,integer(rSTRUCT));
  end;
with typId^ do
  idClass:=idtREC;
  lexAccept1(S,lexPARSE,integer(pFiL));
  oldRec:=traRecId;
  traRecId:=typId;
  traCarPro:=proNULL;
  if idName=nil then
    idName:=memAlloc(lstrlen("#record_type")+1);
    lstrcpy(idName,"#record_type");
  end;
  if idRecList=nil then idRecList:=memAlloc(sizeof(arrLIST)) end;
  if idRecMet=nil then idRecMet:=memAlloc(sizeof(arrLIST)) end;
  while tracTYPEOK(S)or okREZ(S,rPRIVATE)or okREZ(S,rPROTECTED)or okREZ(S,rPUBLIC)or okREZ(S,rVIRTUAL) do
    traPROTECTED(S,true);
    if okREZ(S,rVIRTUAL) then lexGetLex1(S) end;
    typ:=tracDefTYPE(S);
    lexAccept1(S,lexNEW,0);
    if okPARSE(S,pOvL) then tracPROC(S,typ,nil,stLexOld);
    else
      tracListVAR(S,idvFIELD,0,typ,stLexOld,idtSize,idRecMax,idRecList);
      lexAccept1(S,lexPARSE,integer(pSem));
    end;
  end;
  if okREZ(S,rUNION) then //варианты
    lexAccept1(S,lexREZ,integer(rUNION));
    lexAccept1(S,lexPARSE,integer(pFiL));
    recMax:=0;
    recStart:=idtSize;
    while okPARSE(S,pFiL) do
      lexAccept1(S,lexPARSE,integer(pFiL));
      recCase:=recStart;
      while tracTYPEOK(S)or okREZ(S,rPRIVATE)or okREZ(S,rPROTECTED)or okREZ(S,rPUBLIC) do
        traPROTECTED(S,true);
        typ:=tracDefTYPE(S);
        tracListVAR(S,idvFIELD,0,typ,nil,recCase,idRecMax,idRecList);
        lexAccept1(S,lexPARSE,integer(pSem));
      end;
      if recCase>recMax then
        recMax:=recCase
      end;
      lexAccept1(S,lexPARSE,integer(pFiR));
    end;
    inc(idtSize,recMax);
    lexAccept1(S,lexPARSE,integer(pFiR));
  end;
  traRecId:=oldRec;
  lexAccept1(S,lexPARSE,integer(pFiR));
  return typId
end end
end tracRECORD;

//----------- Описание множества --------------

procedure tracSET(var S:recStream; typId:pID);
//SET="SET" "[" Тип "]"
begin
with S,typId^ do
  idClass:=idtSET;
  lexAccept1(S,lexREZ,integer(rSET));
  lexAccept1(S,lexPARSE,integer(pSqL));
  idSetType:=tracDefTYPE(S);
  lexAccept1(S,lexPARSE,integer(pSqR));
  idtSize:=32;
end
end tracSET;

//------------ Описание скаляра ---------------

procedure tracSCALAR(var S:recStream; typId:pID);
//SCALAR="ENUM" ИмяТипа "{" Имя {"," Имя} "}" ";"
var scalId:pID; scalVal:integer;
begin
with S do
  lexAccept1(S,lexREZ,integer(rENUM));
  if typId=nil then
    lexAccept1(S,lexNEW,0);
    typId:=idInsertGlo(stLexOld,idtSCAL);
  end;
with typId^ do
  idClass:=idtSCAL;
  scalVal:=0;
  idScalMax:=0;
  idScalList:=memAlloc(sizeof(arrLIST));
  lexAccept1(S,lexPARSE,integer(pFiL));
  while stLex=lexNEW do
    scalId:=idInsertGlo(addr(stLexStr),idcSCAL);
    scalId^.idScalVal:=scalVal;
    scalId^.idScalType:=typId;
    listAdd(idScalList,scalId,idScalMax);
    lexAccept1(S,lexNEW,0);
    if not okPARSE(S,pFiR) then
      lexAccept1(S,lexPARSE,integer(pCol));
    end;
    inc(scalVal)
  end;
  lexAccept1(S,lexPARSE,integer(pFiR));
  lexAccept1(S,lexPARSE,integer(pSem));
  if idScalMax>255
    then idtSize:=4
    else idtSize:=1
  end
end end
end tracSCALAR;

//----------- Квалификатор массива ----------------

procedure tracArrTYPE(var S:recStream; typId:pID):pID;
var typNext:pID;
begin
with S do
  lexBitConst:=true;
  lexAccept1(S,lexPARSE,integer(pSqL));
  lexBitConst:=false;
  typNext:=idInsertGlo("#array_type",idtARR);
  with typNext^ do
    idArrItem:=typId;
    if stLex=lexTYPE then //скаляр
      if stLexID^.idClass<>idtSCAL then
        lexError(S,_Ожидался_тип_перечисления[envER],nil);
      end;
      idArrInd:=stLexID;
      extArrBeg:=0;
      extArrEnd:=stLexID^.idScalMax-1;
      lexGetLex1(S);
    else //диапазон
      idArrInd:=idTYPE[typeDWORD];
      case stLex of
        lexCHAR:idArrInd:=idTYPE[typeCHAR]; extArrBeg:=stLexInt;|
        lexINT:idArrInd:=idTYPE[typeINT]; extArrBeg:=stLexInt;|
        lexSCAL:idArrInd:=stLexID^.idScalType; extArrBeg:=stLexInt;|
      else lexError(S,_Ожидалась_целая_константа[envER],nil)
      end;
      lexGetLex1(S);
      if not okPARSE(S,pPoiPoi) then extArrEnd:=extArrBeg-1; extArrBeg:=0;
      else
        lexBitConst:=true;
        lexAccept1(S,lexPARSE,integer(pPoiPoi));
        lexBitConst:=false;
        case stLex of
          lexCHAR:if idArrInd<>idTYPE[typeCHAR] then lexError(S,_Неверный_тип_индекса[envER],nil) else extArrEnd:=stLexInt end;|
          lexINT:if idArrInd<>idTYPE[typeINT] then lexError(S,_Неверный_тип_индекса[envER],nil) else extArrEnd:=stLexInt end;|
          lexSCAL:if idArrInd<>stLexID^.idScalType then lexError(S,_Неверный_тип_индекса[envER],nil) else extArrEnd:=stLexInt end;|
        else lexError(S,_Ожидалась_целая_константа[envER],nil)
        end;
        lexGetLex1(S);
        if extArrBeg>extArrEnd then
          lexError(S,_Неверный_диапазон_индексов[envER],nil)
        end
      end
    end;
    idtSize:=(extArrEnd-extArrBeg+1)*idArrItem^.idtSize;
  end;
  typId:=typNext;
  lexAccept1(S,lexPARSE,integer(pSqR));
  return typId
end
end tracArrTYPE;

//----------- Хвост типа ----------------

procedure tracNextTYPE(var S:recStream; typId:pID):pID;
var typNext:pID;
begin
with S do
  while okPARSE(S,pMul) or okPARSE(S,pSqL) do
    case classPARSE(stLexInt) of
      pMul://указатель
        if (typId^.idClass=idtBAS)and(typId^.idBasNom=typeCHAR) then typId:=idTYPE[typePSTR]
        else
          typNext:=idInsertGlo("#pointer_type",idtPOI);
          typNext^.idPoiType:=typId;
          typNext^.idtSize:=4;
          typNext^.idPoiBitForward:=false;
          typId:=typNext;
        end;
        lexGetLex1(S);|
      pSqL://массив
        typId:=tracArrTYPE(S,typId);|
    end
  end;
  return typId
end
end tracNextTYPE;

//----------- Определение типа ----------------

procedure tracDefTYPE(var S:recStream):pID;
//DefTYPE=STRUCT|ENUM|VOID|UNISIGNED|NEW
var typId,typNext:pID;
begin
with S do
  case stLex of
    lexREZ:
      case classREZ(stLexInt) of
        rCLASS:typId:=tracRECORD(S,nil);|
        rSTRUCT:typId:=idInsertGlo("#record_type",idtREC); tracRECORD(S,typId); typId:=tracNextTYPE(S,typId);|
        rENUM:typId:=idInsertGlo("#scalar_type",idtSCAL); tracSCALAR(S,typId); typId:=tracNextTYPE(S,typId);|
        rSET:typId:=idInsertGlo("#set_type",idtSET); tracSET(S,typId); typId:=tracNextTYPE(S,typId);|
        rVOID:
          lexAccept1(S,lexREZ,integer(rVOID));
          if okPARSE(S,pMul) then
            lexAccept1(S,lexPARSE,integer(pMul));
            typId:=idTYPE[typePOINT]
          else typId:=nil
          end;|
        rUNSIGNED:
          lexAccept1(S,lexREZ,integer(rUNSIGNED));
          if not ((stLex=lexTYPE)and(stLexID^.idBasNom=typeINT)) then lexError(S,_Ожидался_тип_int[envER],nil)
          else
            typId:=idTYPE[typeDWORD];
            lexGetLex1(S);
            typId:=tracNextTYPE(S,typId);
          end;|
      else lexError(S,_Ошибка_в_описании_типа[envER],nil);
      end;|
    lexTYPE:
      typId:=stLexID;
      lexGetLex1(S);
      typId:=tracNextTYPE(S,typId);|
  else lexError(S,_Ожидалось_описание_типа[envER],nil)
  end;
  return typId
end
end tracDefTYPE;
//
//------------- Описание типа -----------------

procedure tracTYPE(var S:recStream);
//TYPE="TYPEDEF" DefTYPE Имя ";"
var newId,typId,newField,oldFi:pID; i,j:integer; str,name:string[maxText];
begin
with S do
  lexAccept1(S,lexREZ,integer(rTYPEDEF));
  typId:=tracDefTYPE(S);
  if typId=nil then lexError(S,_Ошибочный_тип[envER],nil)
  else
    lexAccept1(S,lexNEW,0);
    newId:=idInsertGlo(stLexOld,typId^.idClass);
//новый тип
    with newId^ do
      idNom:=typId^.idNom;
      idtSize:=typId^.idtSize;
      case idClass of
        idtBAS:idBasNom:=typId^.idBasNom;|
        idtARR:
           idArrItem:=typId^.idArrItem;
           idArrInd:=typId^.idArrInd;
           extArrBeg:=typId^.extArrBeg;
           extArrEnd:=typId^.extArrEnd;|
        idtREC:
          idRecList :=memAlloc(sizeof(arrLIST));
          idRecList^:=stLexID^.idRecList^;
          idRecMax  :=stLexID^.idRecMax;
          for i:=1 to idRecMax do
            oldFi:=idRecList^[i];
            lstrcpy(str,oldFi^.idName);
            idRecList^[i]:=idInsertGlo(str,idvFIELD);
            idRecList^[i]^.idVarType:=oldFi^.idVarType;
            idRecList^[i]^.idVarAddr:=oldFi^.idVarAddr;
            idRecList^[i]^.idPro:=oldFi^.idPro;
          end;|
        idtPOI:idPoiType:=typId^.idPoiType; idPoiBitForward:=false;|
        idtSCAL:
          idScalList:=memAlloc(sizeof(arrLIST));
          idScalList^:=typId^.idScalList^;
          idScalMax:=typId^.idScalMax;|
      end
    end;
//коррекция имен полей записи
    with newId^ do
    if idClass=idtREC then
      for i:=1 to idRecMax do
        lstrcpy(name,idName);
        lstrcatc(name,'.');
        for j:=lstrposc('.',idRecList^[i]^.idName)+1 to lstrlen(idRecList^[i]^.idName)-1 do
          lstrcatc(name,idRecList^[i]^.idName[j]);
        end;
        if lstrcmp(name,idRecList^[i]^.idName)<>0 then
          newField:=idInsertGlo(name,idRecList^[i]^.idClass);
          with idRecList^[i]^ do
            newField^.idVarType:=idVarType;
            newField^.idVarAddr:=idVarAddr;
          end;
          idRecList^[i]:=newField;
        end;
      end
    end end;
  end;
  lexAccept1(S,lexPARSE,integer(pSem));
end
end tracTYPE;

//------------ Список переменных --------------

procedure tracListVAR(var S:recStream; vId:classID; vBeg:integer; typ:pID; name:pstr; var vMem,vTop:integer; vList:pLIST);
//ListVAR=Имя [Массив] {"," Имя [Массив]}
var i,varTop:integer; varId:pID; str:string[maxText];
begin
with S do
  varTop:=vTop;
  while (stLex=lexNEW)or(name<>nil) do
    if vId<>idvFIELD then //переменная
      if name=nil
        then lstrcpy(str,stLexStr)
        else lstrcpy(str,name)
      end
    else //имя поля
      lstrcpy(str,traRecId^.idName);
      lstrcatc(str,'.');
      if name=nil
        then lstrcat(str,stLexStr)
        else lstrcat(str,name)
      end;
      with traRecId^ do
      if listFind(idRecList,idRecMax,str)<>nil then
        lexError(S,_Повторное_имя_поля_[envER],stLexStr)
      end end
    end;
    if stErr then return end;
    varId:=idInsertGlo(str,vId);
    listAdd(vList,varId,vTop);
    if name=nil
      then lexAccept1(S,stLex,0)
      else name:=nil
    end;
    vList^[vTop]^.idVarType:=typ;
    if okPARSE(S,pSqL) then
      vList^[vTop]^.idVarType:=tracArrTYPE(S,typ);
    end;
    if (stLex<>lexNEW)and not okPARSE(S,pSem) then
      lexAccept1(S,lexPARSE,integer(pCol));
    end
  end;
  lexTest(stLex<>lexPARSE,S,_Ожидалось_новое_имя[envER],nil);

  for i:=varTop+1 to vTop do
  with vList^[i]^ do
    idVarAddr:=vBeg+vMem;
    if vId=idvVPAR
      then inc(vMem,4)
      else inc(vMem,idVarType^.idtSize)
    end;
    idPro:=traCarPro;
  end end;
end
end tracListVAR;

//-------- Описание блока переменных ----------

procedure tracVARs(var S:recStream; typ:pID; name:pstr; Class:classID);
//VARs=ListVAR ";"
var varList:arrLIST; varTop:integer;
begin
with S do
  if typ=nil then lexError(S,_Неверный_тип[envER],nil)
  else
    varTop:=0;
    with tbMod[tekt] do
      tracListVAR(S,Class,0,typ,name,topData,varTop,varList);
      lexAccept1(S,lexPARSE,integer(pSem));
    end
  end
end
end tracVARs;

//----- Блок формальных параметров ------------

procedure tracFORMAL(var S:recStream; procId:pID);
//FORMAL=DefTYPE ["&"] [Имя]
var fId:classID; fType,fPar:pID;
begin
with S,procId^ do
  fType:=tracDefTYPE(S);
  if not stErr and(fType<>nil) then
    fId:=idvPAR;
    if okPARSE(S,pSob) then
      lexAccept1(S,lexPARSE,integer(pSob));
      fId:=idvVPAR
    end;
    if stLex=lexNEW
      then fPar:=idInsert(tbMod[tekt].modTab,stLexStr,fId,tabMod,tekt); lexAccept1(S,lexNEW,0);
      else fPar:=idInsert(tbMod[tekt].modTab,"#proc_param",fId,tabMod,tekt);
    end;
    fPar^.idVarType:=fType;
    fPar^.idVarAddr:=idProcPar;
    if idProcMax=maxPars
      then lexError(S,_Слишком_много_параметров[envER],nil)
      else listAdd(idProcList,fPar,idProcMax);
    end;
    if fId=idvVPAR
      then inc(idProcPar,4)
      else inc(idProcPar,fPar^.idVarType^.idtSize);
    end;

//список параметров
//    while okPARSE(S,pCol) do
//      lexAccept1(S,lexPARSE,integer(pCol));
//      fId:=idvPAR;
//      if okPARSE(S,pSob) then
//        lexAccept1(S,lexPARSE,integer(pSob));
//        fId:=idvVPAR
//      end;
//      lexAccept1(S,lexNEW,0);
//      fPar:=idInsert(tbMod[tekt].modTab,stLexOld,fId,tabMod,0); 
//      fPar^.idVarType:=fType;
//      fPar^.idVarAddr:=idProcPar;
//      if idProcMax=maxPars
//        then lexError(S,_Слишком_много_параметров[envER],nil)
//        else listAdd(idProcList,fPar,idProcMax);
//      end;
//      if fId=idvVPAR
//        then inc(idProcPar,4)
//        else inc(idProcPar,fPar^.idVarType^.idtSize);
//      end
//    end
  end
end
end tracFORMAL;

//---------- Заголовок процедуры --------------

procedure tracTITLE(var S:recStream; procId:pID);
//TITLE="(" [FORMAL ("," FORMAL)] ")" ";"
begin
with S,procId^ do
  lexAccept1(S,lexPARSE,integer(pOvL));
  if not okPARSE(S,pOvR) then
    tracFORMAL(S,procId);
    if (idProcMax=1)and(idProcList^[1]^.idVarType=nil) then dec(idProcMax) //void
    else
      while okPARSE(S,pCol) do
        lexAccept1(S,lexPARSE,integer(pCol));
        tracFORMAL(S,procId);
      end
    end
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
end
end tracTITLE;

//----- Блок формальных параметров (проверка) ------------

procedure tracFORMALtest(var S:recStream; procId:pID);
//FORMAL=DefTYPE ["&"] [Имя]
var fId:classID; fType,fPar:pID;
begin
with S,procId^ do
  inc(traCarParam);
  fType:=tracDefTYPE(S);
  if not stErr and(fType<>nil) then
    fId:=idvPAR;
    if okPARSE(S,pSob) then
      lexAccept1(S,lexPARSE,integer(pSob));
      fId:=idvVPAR
    end;
    if stLex in [lexPAR,lexVPAR] then
      traEqv(S,idProcList^[traCarParam]^.idVarType,fType,true);
      lexTest(idProcList^[traCarParam]^.idClass<>fId,S,_Несоотвествие_класса_параметра[envER],nil);
      if traCarParam>idProcMax
        then lexError(S,_Несоотвествие_количества_параметров[envER],nil)
        else lexTest(lstrcmp(stLexStr,idProcList^[traCarParam]^.idName)<>0,S,_Несоотвествие_имени_параметра[envER],nil)
      end;
      lexAccept1(S,stLex,0);
    end;
  end
end
end tracFORMALtest;

//---------- Заголовок процедуры (проверка) --------------

procedure tracTITLEtest(var S:recStream; procId:pID);
//TITLE="(" [FORMAL ("," FORMAL)] ")" ";"
begin
with S,procId^ do
  if idProcCla=nil
    then traCarParam:=0;
    else traCarParam:=1;
  end;
  lexAccept1(S,lexPARSE,integer(pOvL));
  if not okPARSE(S,pOvR) then
    tracFORMALtest(S,procId);
    if (idProcMax=1)and(idProcList^[1]^.idVarType=nil) then dec(idProcMax) //void
    else
      while okPARSE(S,pCol) do
        lexAccept1(S,lexPARSE,integer(pCol));
        tracFORMALtest(S,procId);
      end
    end
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
  lexTest(traCarParam<>idProcMax,S,_Несоотвествие_количества_параметров[envER],nil);
end
end tracTITLEtest;

//---------------- Процедура ------------------

procedure tracPROC(var S:recStream; typ,procId:pID; name:pstr);
//PROCEDURE=[ИмяКласса "::" ИмяПроц]["ASCII"] TITLE BODY|FORWARD
//BODY="{" [ListVAR] [ListSTAT] "}"
//FORWARD=";"
var modId,virtId,procCla,parId:pID; i:integer; bitComp:boolean; str:string[maxText];
begin
with S do
//главная процедура
  if lstrcmp(name,"main")=0 then
    traBitIMP:=false;
    genStack:=0;
    with tbMod[tekt] do
      genEntry:=topCode;
      genEntryNo:=tekt;
      genEntryStep:=topGenStep;
      modMain:=true;
    end
  end;
//заголовок
  if (stLex=lexPROC)and(procCla<>nil)and(stLexID^.idProcCla=nil) then
    stLex:=lexNEW;
  end;
  if (procId<>nil)and((procId^.idProcAddr=-1)or(procId^.idNom<tekt)) then //FORWARD
    for i:=1 to procId^.idProcMax do
      procId^.idProcList^[i]^.idActiv:=byte(true);
    end;
    if okPARSE(S,pOvL) then
      tracTITLEtest(S,procId);
    end;
  else //новая процедура
    procCla:=nil;
    if (stLex=lexTYPE)or(traRecId<>nil)and(traRecId^.idRecCla<>nil) then //метод
      if stLex=lexTYPE then //метод вне класса
        lexTest(stLexID^.idRecCla=nil,S,_Ожидался_класс[envER],nil);
        procCla:=stLexID;
        lexGetLex1(S);
        lexAccept1(S,lexPARSE,ord(pDupDup));
        lstrcpy(str,procCla^.idName);
        lstrcatc(str,'.');
        lstrcat(str,stLexStr);
        lexTest(not (stLex in setID),S,_Ожидалось_новое_имя[envER],nil);
        lexGetLex1(S);
      else //метод внутри класса
        procCla:=traRecId;
        lstrcpy(str,procCla^.idName);
        lstrcatc(str,'.');
        lstrcat(str,name);
      end;
      procId:=idFindGlo(str,false);
      lexTest((procId<>nil)and(procId^.idProcAddr<>-1),S,_Повторное_имя_метода[envER],nil);
      if procId=nil then procId:=idInsertGlo(str,idPROC) end;
    end;
    if procId=nil then procId:=idInsertGlo(name,idPROC) end;
    with procId^ do
      idProcAddr:=-1;
      idProcType:=typ;
      idProcPar:=0;
      idProcMax:=0;
      idProcList:=memAlloc(sizeof(arrLIST));
      if typ<>nil then
        lexTest(idProcType^.idtSize>8,S,_Неверный_тип_результата_функции[envER],nil);
      end;
      idProcASCII:=okREZ(S,rASCII);
      if idProcASCII then
        if not traBitDEF then
          lexError(S,_ASCII_функция_допустима_только_в_def_модуле[envER],nil);
        end;
        lexAccept1(S,lexREZ,integer(rASCII));
      end;
      if traFromDLL[0]=char(0) then idProcDLL:=nil
      else
        idProcDLL:=memAlloc(lstrlen(traFromDLL)+1);
        lstrcpy(idProcDLL,traFromDLL);
      end
    end;
    if procCla<>nil then
    with procId^ do
      idProcCla:=procCla;
      idPro:=traCarPro;
      parId:=idInsertGlo("this",idvVPAR);
      with parId^ do
        idVarType:=procCla;
        idVarAddr:=0;
      end;
      listAdd(idProcList,parId,idProcMax);
      inc(idProcPar,4);
      listAdd(idProcCla^.idRecMet,procId,idProcCla^.idRecTop);
    end end;
    tracTITLE(S,procId);
    lexTest((lstrcmp(procId^.idName,"main")=0)and(procId^.idProcMax>0),
      S,_Функция_main_не_должна_иметь_парамеров[envER],nil);      
    with procId^ do //проверка на совпадение параметров виртуального метода
    if idProcCla<>nil then
      lstrcpy(str,idName);
      lstrdel(str,0,lstrposc('.',str)+1);
      virtId:=genFindMetod(idProcCla,str);
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
  if traCarProc<>nil then mbS(_Системная_ошибка_в_tracPROC[envER]) end;
  traCarProc:=procId;
//BODY|FORWARD
  if okPARSE(S,pSem) then //FORWARD
    lexAccept1(S,lexPARSE,integer(pSem))
  elsif (traRecId<>nil)and(traRecId^.idRecCla<>nil) then //метод внутри класса
  else with procId^ do //BODY
    idProcLock:=0;
    idLocMax:=0;
    if not traBitDEFmod then
      idLocList:=memAlloc(sizeof(arrLIST));
//with self
      if idProcCla<>nil then
        inc(topWith);
        tbWith[topWith]:=idProcCla;
      end;
//переменные
      lexAccept1(S,lexPARSE,ord(pFiL));
      while tracTYPEOK(S) do
        typ:=tracDefTYPE(S);
        lexAccept1(S,lexNEW,0);
        if okPARSE(S,pCol) or okPARSE(S,pSem) or okPARSE(S,pSqL) then
          tracListVAR(S,idvLOC,0,typ,stLexOld,idProcLock,idLocMax,idLocList);
          lexAccept1(S,lexPARSE,integer(pSem));
        else lexError(S,_Ожидался_список_переменных[envER],nil)
        end;
        lexTest(lstrcmp(procId^.idName,"main")=0,
          S,_Функция_main_не_должна_иметь_локальных_переменных[envER],nil);      
      end;
//смещения
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
//операторы
      with tbMod[tekt] do
        idProcAddr:=topCode;
        if lstrcmp(procId^.idName,"main")<>0 then
          stepAdd(S,tekt,stepSimple);
          with genStep^[topGenStep] do
            dec(line);
            frag:=1;
          end
        end
      end;
//enter _Память
      if lstrcmp(procId^.idName,"main")<>0 then
        if genAlign(idProcLock,4)<=0x1000-4 then genGen(S,cENTER,genAlign(idProcLock,4))
        else
//  push bp; mov bp,sp
          genR(S,cPUSH,rEBP);
          genRR(S,cMOV,rEBP,rESP);
//  mov cx,_stack div 0x1000;
//  rep:sub sp,0x1000-4;
//  push ax;
//  loop rep;
//  sub sp,_stack mod 0x1000;
          genRD(S,cMOV,rECX,genAlign(idProcLock,4) div 0x1000);
          genRD(S,cSUB,rESP,0x1000-4);
          genR(S,cPUSH,rEAX);
          genGen(S,cLOOP,-9);
          genRD(S,cSUB,rESP,genAlign(idProcLock,4) mod 0x1000);
        end;
// push esi; push ebx
        genR(S,cPUSH,rESI);
        genR(S,cPUSH,rEBX);
//with self
        if idProcCla<>nil then
//  mov eax,[ebp+_track]
//  mov [topWith],ax
          genMR(S,cMOV,regNULL,rEBP,regNULL,rEAX,idProcList^[1]^.idVarAddr,1);
          genMR(S,cMOV,regNULL,regNULL,regNULL,regNULL,genBASECODE+0x1000+(topWith-1)*4,0);
        end;
        genStack:=0;
      end;
      tracListSTAT(S);
      if lstrcmp(procId^.idName,"main")<>0 then
        stepAdd(S,tekt,stepRETURN);
      end;
      lexAccept1(S,lexPARSE,ord(pFiR));
// pop bx; pop si; leave; ret _ПамятьПар
      if lstrcmp(procId^.idName,"main")<>0 then
        genR(S,cPOP,rEBX);
        genR(S,cPOP,rESI);
        genGen(S,cLEAVE,0);
        genD(S,cRET,idProcPar);
      else
        if not traBitDEFmod then
          traFinish(S);
        end
      end;
//конец with self
      if idProcCla<>nil then
        dec(topWith)
      end;
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
end tracPROC;

//===============================================
//                 ТРАНСЛЯЦИЯ ОПИСАНИЙ
//===============================================

//------------- Список описаний ---------------

procedure tracListDEF(var S:recStream);
//ListDEF={CONSTs|TYPEs|ENUM|VARs|PROC|DIALOG|BITMAP|FROM}
var typ,pProc:pID;
begin
with S do
  while tracTYPEOK(S)or
    okREZ(S,rVIRTUAL)or okREZ(S,rCLASS)or
    okREZ(S,rDEFINE)or okREZ(S,rTYPEDEF)or
    okREZ(S,rDIALOG)or okREZ(S,rBITMAP)or okREZ(S,rICON)or okREZ(S,rFROM)or
    okPARSE(S,pRes)or okPARSE(S,pMul) do
  if (tracTYPEOK(S)and not okREZ(S,rENUM))or okREZ(S,rVIRTUAL) then //переменные или функция
    if okREZ(S,rVIRTUAL) then lexGetLex1(S) end;
    typ:=tracDefTYPE(S);
    if stLex=lexPROC then
      pProc:=stLexID;
      lexAccept1(S,lexPROC,0);
      tracPROC(S,typ,pProc,stLexOld);
    elsif stLex=lexTYPE then tracPROC(S,typ,nil,nil) //метод
    else
      lexAccept1(S,lexNEW,0);
      if okPARSE(S,pOvL)or okPARSE(S,pFiL) or okPARSE(S,pDupDup)or okREZ(S,rASCII)or tracTYPEOK(S) then tracPROC(S,typ,nil,stLexOld)
      elsif okPARSE(S,pCol)or okPARSE(S,pSem)or okPARSE(S,pSqL) then tracVARs(S,typ,stLexOld,idvVAR)
      else lexError(S,_Ожидался_список_переменных_или_функция[envER],nil)
      end
    end;
  else //прочие описания
    case stLex of
      lexREZ:case classREZ(stLexInt) of
        rDEFINE:tracCONST(S);|
        rTYPEDEF:tracTYPE(S);|
        rENUM:tracSCALAR(S,nil);|
        rDIALOG:traDIALOG(S);|
        rBITMAP:traBITMAP(S);|
        rICON:traICON(S);|
        rFROM:traFROM(S);|
        rCLASS:tracRECORD(S,nil);|
      end;|
      lexPARSE:
        lexAccept1(S,lexPARSE,integer(pRes));
        if stLex=lexREZ then
          case classREZ(stLexInt) of
            rDEFINE:tracCONST(S);|          
          end
        end;|
    end end
  end
end
end tracListDEF;

//-------------- Имя модуля ----------------

procedure tracImpName(var S:recStream; impName:pstr);
begin
with S do
  if stLex=lexNEW then //идентификатор
    lstrcpy(impName,stLexStr);
    lexAccept1(S,lexNEW,0);
  elsif stLex=lexSTR then //имя файла в кавычках
    lstrcpy(impName,stLexStr);
    if lstrposc('.',impName)>=0 then
      lstrdel(impName,lstrposc('.',impName),99)
    end;
    lexAccept1(S,lexSTR,0);
  elsif okPARSE(S,pUgL) then //имя файла в скобках
    lexAccept1(S,lexPARSE,integer(pUgL));
    lexAccept1(S,lexNEW,0);
    lstrcpy(impName,stLexOld);
    if okPARSE(S,pPoi) then
      lexAccept1(S,lexPARSE,integer(pPoi));
      lexGetLex1(S);
    end;
    lexAccept1(S,lexPARSE,integer(pUgR));
  else lexError(S,_Ожидалось_имя_модуля[envER],nil)
  end;
end
end tracImpName;

//-------------- Импорт модуля ----------------

procedure tracIMPORT(var S:recStream);
//IMPORT="INCLIDE" ИмяМодуля {","ИмяМодуля}
var impName:string[maxText];
begin
with S do
  lexAccept1(S,lexREZ,integer(rINCLUDE));
  tracImpName(S,impName);
  traAddModule(S,impName);
  while okPARSE(S,pCol) do
    lexAccept1(S,lexPARSE,integer(pCol));
    tracImpName(S,impName);
    traAddModule(S,impName);
  end
end
end tracIMPORT;

//---------------- Модуль ---------------------

procedure tracMODULE(var S:recStream; modName:pstr);
//{["#"] "INCLUDE" ИмяМодуля {"," ИмяМодуля}}
//["EXPORT" ИмяФункции {"," ИмяФункции}]
//ListDEF
var i,j:integer;
begin
with S do
  if traBitH then traBitDEF:=true end;
  if not traBitH then traBitIMP:=true end;
  traCarPro:=proNULL;
  lstrcpy(traModName,modName);
  lstrdel(traModName,lstrposc('.',traModName),99);
  while okPARSE(S,pRes) or okREZ(S,rINCLUDE) do
    if okPARSE(S,pRes) then
      lexAccept1(S,lexPARSE,integer(pRes));
    end;
    if okREZ(S,rINCLUDE) then
      tracIMPORT(S)
    end
  end;
  tracListDEF(S);
  lexAccept1(S,lexEOF,0);
end
end tracMODULE;

//===============================================
//                ТРАНСЛЯЦИЯ ОПЕРАТОРОВ 
//===============================================

//-------- Операция NEW ----------------

procedure tracNEW(var S:recStream; varType:pID);
//Переменная "=" "NEW" ИмяТипа
begin
with S do
  if stLex=lexTYPE then
    if (varType<>nil)and(varType^.idClass=idtPOI)
      then traEqv(S,varType^.idPoiType,stLexID,true)
      else traEqv(S,varType,stLexID,true)
    end
  end;
  lexAccept1(S,lexTYPE,0);
  if (varType<>nil)and(varType^.idClass=idtPOI)and(varType^.idPoiType^.idClass=idtREC)and(varType^.idPoiType^.idRecCla<>nil) then
// push mem; push 0; //обратный порядок параметров !
    genD(S,cPUSH,varType^.idPoiType^.idtSize);
    genD(S,cPUSH,0);
// call GlobalAlloc;
    traCall32(S,"Kernel32.dll","GlobalAlloc");
// pop esi; mov [esi],eax;
    genR(S,cPOP,rESI);
    genMR(S,cMOV,regNULL,regNULL,rESI,rEAX,0,0);
// mov [eax],addrtype
    genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode+3,vcNew,varType^.idPoiType^.idName);
    genMD(S,cMOV,regNULL,regNULL,rEAX,0,0,4);
  elsif (varType<>nil)and(varType^.idClass=idtREC)and(varType^.idRecCla<>nil) then
// pop eax;
    genR(S,cPOP,rESI);
// mov [esi],addrtype
    genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode+3,vcNew,varType^.idName);
    genMD(S,cMOV,regNULL,regNULL,rESI,0,0,4);
  else lexError(S,_Ожидался_класс[envER],nil)
  end
end
end tracNEW;

//------------ Присваивание ----------------

procedure tracEQUAL(var S:recStream);
//EQUAL=VARIABLE "=" EXPRESSION | "++" "--" "+=" "-=" INCDEC | "NEW" ИмяТипа
var eTypeVar,eTypeExp:pID;
begin
with S do
  eTypeVar:=traVARIABLE(S,false,false,true);
  if eTypeVar^.idClass<>idPROC then
    if okPARSE(S,pPluPlu) or okPARSE(S,pMinMin) or okPARSE(S,pPluEqv) or okPARSE(S,pMinEqv) then
      tracINCDEC(S,eTypeVar)
    else
      lexAccept1(S,lexPARSE,integer(pEqv));
      if okREZ(S,rNEW) then lexGetLex1(S); tracNEW(S,eTypeVar)
      else
        traBitAND:=false;
        eTypeExp:=traEXPRESSION(S);
        traEqv(S,eTypeVar,eTypeExp,true);
        traGenEqv(S,eTypeVar,eTypeExp);
      end
    end
  end;
  lexAccept1(S,lexPARSE,integer(pSem));
end
end tracEQUAL;

//------------ Вызов процедуры ----------------

procedure tracCALL(var S:recStream; bitStat:boolean):pID;
//CALL=Имя "(" [EXPRESSION {"," EXPRESSION}] ")"
var cProc,cFact:pID; i,j:integer; str:pstr; pl:pointer to integer;
    cPars:pointer to recPars; cCode:pointer to arrCode; cTop:integer;
    modif:pointer to arrModif; topModif:integer;
    oldStack:integer; bitPoint:boolean; siz:cardinal;
    begSaveWith,endSaveWith:integer; bufWith:pstr;
begin
with S do
  cProc:=stLexID;
  oldStack:=genStack;
with cProc^ do
  lexTest((traCarProc<>nil)and(traCarProc^.idProcCla<>nil)and
    (idProcCla<>nil)and(idPro=proPRIVATE)and(traCarProc^.idProcCla<>idProcCla),S,
    _Нарушение_прав_доступа[envER],nil);
  str:=memAlloc(maxText);
  modif:=memAlloc(sizeof(arrModif));
  topModif:=0;
  lexAccept1(S,lexPROC,0);
  lexAccept1(S,lexPARSE,integer(pOvL));
//сохранить адреса with
  begSaveWith:=tbMod[tekt].topCode;
  for i:=1 to topWith do
    genM(S,cPUSH,regNULL,regNULL,regNULL,genBASECODE+0x1000+(i-1)*4,4);
  end;
  endSaveWith:=tbMod[tekt].topCode;
  if idProcCla<>nil then //передвинуть код save with
  if traStackTop=0 then mbS("System error in traCALL")
  else with tbMod[tekt] do
    bufWith:=memAlloc(endSaveWith-begSaveWith);
    for i:=0 to endSaveWith-begSaveWith-1 do
      bufWith[i]:=char(genCode^[begSaveWith+i+1]);
    end;
    for i:=begSaveWith-traStackMet[traStackTop] downto 1 do
      genCode^[traStackMet[traStackTop]+i+endSaveWith-begSaveWith]:=genCode^[traStackMet[traStackTop]+i]
    end;
    for i:=0 to endSaveWith-begSaveWith-1 do
      genCode^[traStackMet[traStackTop]+i+1]:=byte(bufWith[i]);
    end;
    memFree(bufWith);
  end end end;
//параметры
  cPars:=memAlloc(sizeof(recPars));
  for i:=1 to idProcMax do
  if (i=1)and(idProcCla<>nil) then
    cPars^.arrPars[i].parBeg:=traStackMet[traStackTop]+endSaveWith-begSaveWith;
    cPars^.arrPars[i].parEnd:=tbMod[tekt].topCode;
  else
    cPars^.arrPars[i].parBeg:=tbMod[tekt].topCode;
    if idProcList^[i]^.idClass=idvVPAR then cFact:=traVARIABLE(S,false,true,false)
    else
      with idProcList^[i]^.idVarType^ do
        traBitLoadString:=not((idClass=idtBAS)and(idBasNom=typePSTR));
        bitPoint:=(idClass=idtPOI);
        traLastLoad:=-1;
        traBitOptim:=false;
      end;
      traBitAND:=false;
//параметр на стек
      cFact:=traEXPRESSION(S);
//обработка параметра-указателя
      if bitPoint and (cFact=idProcList^[i]^.idVarType^.idPoiType) then
        cFact:=idProcList^[i]^.idVarType;
        if traLastLoad=-1 then lexError(S,_Системная_в_tracCALL[envER],nil)
        else
          tbMod[tekt].topCode:=traLastLoad;
          if traBitOptim then
            genR(S,cPUSH,rESI);
          end
        end
      end;
      bitPoint:=false;
    end;
    if not stErr then
      traEqv(S,idProcList^[i]^.idVarType,cFact,true);
    end;
    if i<idProcMax then
      lexAccept1(S,lexPARSE,integer(pCol));
    end;
    cPars^.arrPars[i].parEnd:=tbMod[tekt].topCode
  end end;
  traBitLoadString:=true;
  lexAccept1(S,lexPARSE,integer(pOvR));
//обратный порядок параметров
  with tbMod[tekt] do
  if idProcMax>0 then
    cCode:=memAlloc(cPars^.arrPars[idProcMax].parEnd-cPars^.arrPars[1].parBeg);
    cTop:=0;
    for i:=idProcMax downto 1 do
    with cPars^.arrPars[i] do
//перекачка кода параметра
      traCorrCall(S,modif^,topModif,parBeg,parEnd,cPars^.arrPars[1].parBeg+cTop,0);
      for j:=parBeg+1 to parEnd do
        inc(cTop);
        cCode^[cTop]:=genCode^[j];
      end
    end end;
    for i:=1 to topModif do  with modif^[i] do
      modAddr^:=modNew
    end end;
    for j:=1 to cPars^.arrPars[idProcMax].parEnd-cPars^.arrPars[1].parBeg do
      genCode^[cPars^.arrPars[1].parBeg+j]:=cCode^[j];
    end;
    memFree(cCode)
  end end;
  memFree(cPars);
//список импорта
  with tbMod[tekt] do
  if (idNom=0)or(idNom>topt)and(tbMod[idNom].topCode=0) then
    lstrcpy(str,idName);
    if idProcASCII then
      lstrcatc(str,'A');
    end;
    if idProcCla=nil then
    if idProcDLL=nil
      then pl:=impAdd(genImport,tbMod[idNom].modNam,str,topCode+3,topImport)
      else pl:=impAdd(genImport,idProcDLL,str,topCode+3,topImport)
    end end
  else genAddCall(S,topCode,cProc)
  end end;
//вызов
  if idProcCla<>nil then
    genR(S,cPOP,rESI); genR(S,cPUSH,rESI); //  pop esi; push esi;
    genMR(S,cMOV,regNULL,regNULL,rESI,rESI,0,1); //  mov esi,[esi];
  end;
  if (idProcCla<>nil)and((idNom=0)or(idNom>topt)and(tbMod[idNom].topCode=0)) then //метод внешнего COM-объекта
    genM(S,cCALLF,regNULL,regNULL,rESI,(traMetNom(idProcCla,idOwn)-1)*4,0); //callf [esi+_nomMethod*4]
  elsif idProcCla<>nil then //метод объекта
    genMR(S,cMOV,regNULL,regNULL,rESI,rESI,0,1); //  mov esi,[esi];
    genM(S,cCALLF,regNULL,regNULL,rESI,0xFFFFFF00,0); //callf [esi+_trackProcTab]
  elsif (idNom=0)or(idNom>topt)and(tbMod[idNom].topCode=0) then //функция внешнего DLL
    genM(S,cCALLF,regNULL,regNULL,regNULL,0,0); //callf [_trackProc]
  else //обычная процедура
    genGen(S,cCALL,0); //callf _cProc
  end;
//восстановить адреса with
  for i:=topWith downto 1 do
    genM(S,cPOP,regNULL,regNULL,regNULL,genBASECODE+0x1000+(i-1)*4,4);
  end;
//push dx; push ax; для функций
  genStack:=oldStack;
  if (idProcType<>nil) and not bitStat then
    lexTest(idProcType^.idtSize>8,S,_Неверный_тип_результата_функции[envER],nil);
    if idProcType^.idtSize>4 then
      genR(S,cPUSH,rEDX);
    end;
    genR(S,cPUSH,rEAX);
  end;
  memFree(modif);
  memFree(str);
  lexAccept1(S,lexPARSE,integer(pSem));
  return idProcType
end end
end tracCALL;

//---------------- Возврат --------------------

procedure tracRETURN(var S:recStream);
//RETURN [EXPRESSION]
begin
  traRETURN(S);
  lexAccept1(S,lexPARSE,integer(pSem));
end tracRETURN;

//----------- Условный оператор ---------------

procedure tracIF(var S:recStream);
//"IF" "(" EXPRESSION ")" BlockSTAT
//{"ELSIF" EXPRESSION THEN BlockSTAT} 
//["ELSE" BlockSTAT]
var bitIf:boolean; ifCond:pID; ifEndThen:integer; ifEnd:lstJamp;
begin
with S,tbMod[tekt] do
  ifEnd.top:=0;
  bitIf:=true;
  while bitIf and okREZ(S,rIF) or okREZ(S,rELSIF) do
    if not bitIf then stepAdd(S,tekt,stepVarIF) end;
    if bitIf
      then lexAccept1(S,lexREZ,integer(rIF))
      else lexAccept1(S,lexREZ,integer(rELSIF))
    end;
    bitIf:=false;
    lexAccept1(S,lexPARSE,integer(pOvL));
    traBitAND:=false;
    ifCond:=traEXPRESSION(S);
    lexAccept1(S,lexPARSE,integer(pOvR));
    traEqv(S,idTYPE[typeBOOL],ifCond,true);
//  {pop ax; or ax,ax; je _ifEndThen}
    genPOP(S,rEAX,traBitAND);
    genRR(S,cOR,rEAX,rEAX);
    ifEndThen:=topCode;
    genGen(S,cJE,0);
    stepAdd(S,tekt,stepVarIF);
    tracBlockSTAT(S);
//  {jmp _ifEnd; _ifEndThen:}
    genAddJamp(S,ifEnd,topCode,cJMP);
    genGen(S,cJMP,0);
    genSetJamp(S,ifEndThen,topCode,cJE)
  end;
  if okREZ(S,rELSE) then
    lexAccept1(S,lexREZ,integer(rELSE));
    stepAdd(S,tekt,stepVarIF);
    tracBlockSTAT(S);
  end;
  genSetJamps(S,ifEnd,topCode);
end
end tracIF;

//------------- Селектор выбора ---------------

procedure tracSELECT(var S:recStream; sType:pID);
//{"CASE" Const [".." Const] ":"}
var caseBeg:pointer to lstJamp; bitMin:boolean;
begin
with S,sType^,tbMod[tekt] do
  caseBeg:=memAlloc(sizeof(lstJamp));
  caseBeg^.top:=0;
  while okREZ(S,rCASE) do
    lexGetLex1(S);
    lexTest((idClass=idtSCAL)and((stLex<>lexSCAL)or(stLexID^.idScalType<>sType)),S,_Недопустимая_константа[envER],nil);
    bitMin:=okPARSE(S,pMin);
    if bitMin then
      lexGetLex1(S);
      lexTest(stLex<>lexINT,S,_Ожидалось_целое[envER],nil);
      stLexInt:=-stLexInt;
    end;
//pop ax; push ax; cmp ax,_wEval; je _caseBeg
    genR(S,cPOP,rEAX);
    genR(S,cPUSH,rEAX);
    genRD(S,cCMP,rEAX,stLexInt);
    genAddJamp(S,caseBeg^,topCode,cJE);
    genGen(S,cJE,0);
    lexGetLex1(S);
    if okPARSE(S,pPoiPoi) then
      lexAccept1(S,lexPARSE,integer(pPoiPoi));
      lexTest(
        (idClass=idtSCAL)and((stLex<>lexSCAL)or(stLexID^.idScalType<>sType))or
        not ((stLex=lexCHAR)or(stLex=lexINT)or(stLex=lexSCAL)or(stLex=lexFALSE)or(stLex=lexTRUE)or okPARSE(S,pMin)),
        S,_Недопустимая_константа[envER],nil);
      bitMin:=okPARSE(S,pMin);
      if bitMin then
        lexGetLex1(S);
        lexTest(stLex<>lexINT,S,_Ожидалось_целое[envER],nil);
        stLexInt:=-stLexInt;
      end;
//  {jae next1; jmp next2; next1:cmp ax,_wEval; jbe _caseBeg; next2:}
      genGen(S,cJAE,5);
      genGen(S,cJMP,12);
      genRD(S,cCMP,rEAX,stLexInt);
      genAddJamp(S,caseBeg^,topCode,cJBE);
      genGen(S,cJBE,0);
      lexGetLex1(S);
    end;
    genGen(S,cJMP,0);
    genSetJamps(S,caseBeg^,topCode);
    lexAccept1(S,lexPARSE,integer(pDup));
  end;
  memFree(caseBeg);
end
end tracSELECT;

//--------------- Оператор выбора ---------------

procedure tracCASE(var S:recStream);
//{"SWITCH" "(" EXPRESSION ")" "{" 
//{{SELECT} BlockSTAT | ListSTAT "break" ";"}
//["DEFAULT" ":" BlockSTAT | ListSTAT "break" ";"] "}"
var caseCond:pID; caseEndSel:integer; caseEnd:lstJamp;
begin
with S,tbMod[tekt] do
  caseEnd.top:=0;
  lexAccept1(S,lexREZ,integer(rSWITCH));
  lexAccept1(S,lexPARSE,integer(pOvL));
  traBitAND:=false;
  caseCond:=traEXPRESSION(S);
  lexAccept1(S,lexPARSE,integer(pOvR));
  with caseCond^ do
  if not ((idClass=idtSCAL)or(idClass=idtBAS)and
    (ord(idBasNom)>=ord(typeBYTE))and(ord(idBasNom)<=ord(typeDWORD))) then
    lexError(S,_Неверный_тип_переключателя[envER],nil);
  end end;
  lexBitConst:=true;
  lexAccept1(S,lexPARSE,integer(pFiL));
  while okREZ(S,rCASE) do
    tracSELECT(S,caseCond);
    caseEndSel:=topCode-5;
    lexBitConst:=false;
    stepAdd(S,tekt,stepVarCASE);
    if okPARSE(S,pFiL) then tracBlockSTAT(S);
    else
      tracListSTAT(S); 
      lexAccept1(S,lexREZ,integer(rBREAK));
      lexAccept1(S,lexPARSE,integer(pSem));
    end;
    lexBitConst:=true;
    genAddJamp(S,caseEnd,topCode,cJMP);
    genGen(S,cJMP,0);
    genSetJamp(S,caseEndSel,topCode,cJMP);
  end;
  lexBitConst:=false;
  if okREZ(S,rDEFAULT) then
    lexAccept1(S,lexREZ,integer(rDEFAULT));
    lexAccept1(S,lexPARSE,integer(pDup));
    stepAdd(S,tekt,stepVarCASE);
    if okPARSE(S,pFiL) then tracBlockSTAT(S);
    else
      tracListSTAT(S); 
      lexAccept1(S,lexREZ,integer(rBREAK));
      lexAccept1(S,lexPARSE,integer(pSem));
    end;
  end;
  lexAccept1(S,lexPARSE,integer(pFiR));
  genSetJamps(S,caseEnd,topCode);
  genR(S,cPOP,rEAX);
end
end tracCASE;

//-------------- Цикл WHILE -------------------

procedure tracWHILE(var S:recStream);
//"WHILE" "(" EXPRESSION ")" BlockSTAT
var whileCond:pID; labBeg,jmpEnd:integer;
begin
with S,tbMod[tekt] do
  lexAccept1(S,lexREZ,integer(rWHILE));
  labBeg:=topCode;
  lexAccept1(S,lexPARSE,integer(pOvL));
  traBitAND:=false;
  whileCond:=traEXPRESSION(S);
  lexAccept1(S,lexPARSE,integer(pOvR));
  traEqv(S,idTYPE[typeBOOL],whileCond,true);
//  {pop ax; or ax,ax; je _whileEnd}
  genPOP(S,rEAX,traBitAND);
  genRR(S,cOR,rEAX,rEAX);
  jmpEnd:=topCode;
  genGen(S,cJE,0);
  stepAdd(S,tekt,stepBegWHILE);
  tracBlockSTAT(S);
  stepAdd(S,tekt,stepModWHILE);
//  {jmp _whileBeg; _whileEnd:}
  genGen(S,cJMP,0);
  genSetJamp(S,topCode-5,labBeg,cJMP);
  genSetJamp(S,jmpEnd,topCode,cJE);
  stepAdd(S,tekt,stepBegWHILE);
end
end tracWHILE;

//-------------- Цикл DO ------------------

procedure tracREPEAT(var S:recStream);
//"DO" BlockSTAT "WHILE" "(" EXPRESSION ")"
var repCond:pID; labBeg:integer;
begin
with S,tbMod[tekt] do
  lexAccept1(S,lexREZ,integer(rDO));
  labBeg:=topCode;
  tracBlockSTAT(S);
  stepAdd(S,tekt,stepModREPEAT);
  lexAccept1(S,lexREZ,integer(rWHILE));
  lexAccept1(S,lexPARSE,integer(pOvL));
  traBitAND:=false;
  repCond:=traEXPRESSION(S);
  lexAccept1(S,lexPARSE,integer(pOvR));
  traEqv(S,idTYPE[typeBOOL],repCond,true);
//  {pop ax; or ax,ax; jne _repBeg}
  genPOP(S,rEAX,traBitAND);
  genRR(S,cOR,rEAX,rEAX);
  genGen(S,cJNE,0);
  genSetJamp(S,topCode-6,labBeg,cJNE);
  lexAccept1(S,lexPARSE,integer(pSem));
end
end tracREPEAT;

//---------------- Цикл FOR -------------------

procedure tracFOR(var S:recStream);
//"FOR" "(" Имя "=" EXPRESSION ";"
//Имя "<"|"<="|">"|">=" EXPRESSION ";"
//Имя "++"|"--" ")"
//BlockSTAT
var forType,expType:pID; modif:classModif; labBeg,jmpEnd:integer; Class:classFor; name:string[maxText];
begin
with S,tbMod[tekt] do
//заголовок цикла
  lexAccept1(S,lexREZ,integer(rFOR));
  lexAccept1(S,lexPARSE,integer(pOvL));
  lstrcpy(name,stLexStr);
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
  lexAccept1(S,lexPARSE,integer(pEqv));
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
  lexAccept1(S,lexPARSE,integer(pSem));
  if (stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC) then
    lexTest(lstrcmp(stLexStr,name)<>0,S,_Ожидался_счетчик_цикла_[envER],name);
    lexGetLex1(S);
  else lexError(S,_Ожидался_счетчик_цикла_[envER],name)
  end;
  if stLex=lexPARSE then
    case classPARSE(stLexInt) of
      pUgL:modif:=modifTONE;|
      pUgLEqv:modif:=modifTO;|
      pUgR:modif:=modifDOWNTONE;|
      pUgREqv:modif:=modifDOWNTO;|
    else lexError(S,_Ожидалось_условие_окончания_цикла[envER],nil)
    end
  else lexError(S,_Ожидалось_условие_окончания_цикла[envER],nil)
  end;
  lexGetLex1(S);
  traBitAND:=false;
  expType:=traEXPRESSION(S);
  traEqv(S,forType,expType,true);
  lexAccept1(S,lexPARSE,integer(pSem));
  if (stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC) then
    lexTest(lstrcmp(stLexStr,name)<>0,S,_Ожидался_счетчик_цикла_[envER],name);
    lexGetLex1(S);
  else lexError(S,_Ожидался_счетчик_цикла_[envER],name)
  end;
  case modif of
    modifTO,modifTONE:lexAccept1(S,lexPARSE,integer(pPluPlu));|
    modifDOWNTO,modifDOWNTONE:lexAccept1(S,lexPARSE,integer(pMinMin));|
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
  jmpEnd:=traTEST(S,Class,modif);
//тело цикла
  labBeg:=topCode;
  stepAdd(S,tekt,stepBegFOR);
  tracBlockSTAT(S);
  stepAdd(S,tekt,stepModFOR);
  traMODIF(S,Class,modif,forType,labBeg,jmpEnd);
end
end tracFOR;

//-------- Оператор ассемблера ----------------

procedure tracASM(var S:recStream);
//"ASM" "{" Инструкции "}"
begin
with S do
  lexAccept1(S,lexREZ,integer(rASM));
  lexAccept1(S,lexPARSE,integer(pFiL));
  asmInitial();
  asmAssembly(S);
  asmDestroy();
  lexAccept1(S,lexPARSE,integer(pFiR));
end
end tracASM;

//---------- Переменная WITH ------------------

procedure tracVarWITH(var S:recStream);
var recType:pID;
begin
with S do
  recType:=traVARIABLE(S,false,true,false);
  if recType^.idClass<>idtREC then lexError(S,_Ожидалась_переменная_запись[envER],nil)
  elsif topWith=maxWith then lexError(S,_Слишком_много_вложенных_WITH[envER],nil)
  else
    inc(topWith);
    tbWith[topWith]:=recType;
    genM(S,cPOP,regNULL,regNULL,regNULL,genBASECODE+0x1000+(topWith-1)*4,0);
  end
end
end tracVarWITH;

//---------- Оператор WITH --------------------

procedure tracWITH(var S:recStream);
//"WITH" "(" Переменная {"," Переменная} ")" BlockSTAT
var oldTop:integer;
begin
with S do
  lexAccept1(S,lexREZ,integer(rWITH));
  lexAccept1(S,lexPARSE,integer(pOvL));
  oldTop:=topWith;
  tracVarWITH(S);
  while okPARSE(S,pCol) do
    lexAccept1(S,lexPARSE,integer(pCol));
    tracVarWITH(S);
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
  tracBlockSTAT(S);
  topWith:=oldTop;
end
end tracWITH;

//-------- Операторы INC и DEC ----------------

procedure tracINCDEC(var S:recStream; varType:pID);
//"++"|"--" [Выражение] | "+="|"-=" Выражение
var bitINC:boolean; expType:pID; comm:classCommand;
begin
with S do
  bitINC:=okPARSE(S,pPluPlu) or okPARSE(S,pPluEqv);
  lexAccept1(S,lexPARSE,stLexInt);
  with varType^ do
  if not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeCHAR,typeINT,typeWORD,typeDWORD])or(idClass=idtSCAL)) then
    lexError(S,_Неверный_тип_переменной[envER],nil);
  end end;
  if bitINC
    then comm:=cADD
    else comm:=cSUB
  end;
  if not okPARSE(S,pSem) then
    traBitAND:=false;
    expType:=traEXPRESSION(S);
    with expType^ do
    if not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeCHAR,typeWORD,typeINT,typeDWORD])) then
      lexError(S,_Неверный_тип_выражения[envER],nil);
    end end;
//  {pop ax; pop si; add/sub [si],ax/al}
    genPOP(S,rEAX,traBitAND);
    genR(S,cPOP,rESI);
    case varType^.idtSize of
      1:genMR(S,comm,regNULL,regNULL,rESI,rAL,0,0);|
      2:genMR(S,comm,regNULL,regNULL,rESI,rAX,0,0);|
      4:genMR(S,comm,regNULL,regNULL,rESI,rEAX,0,0);|
    end;
  else
//  {pop si; add/sub [si],1}
    genPOP(S,rESI,traBitAND);
    case varType^.idtSize of
      1:genMD(S,comm,regNULL,regNULL,rESI,0,1,1);|
      2:genMD(S,comm,regNULL,regNULL,rESI,0,1,2);|
      4:genMD(S,comm,regNULL,regNULL,rESI,0,1,4);|
    end
  end;
//  lexAccept1(S,lexPARSE,integer(pSem));
end
end tracINCDEC;

//----------- Список операторов ---------------

procedure tracSTATEMENT(var S:recStream);
begin
  with tbMod[tekt],genStep^[topGenStep] do
  case S.stLex of
    lexVAR,lexPAR,lexLOC,lexVPAR,lexFIELD,lexSTRU:tracEQUAL(S);|
    lexPROC:Class:=stepCALL; proc:=S.stLexID; tracCALL(S,true);|
    lexREZ:case classREZ(S.stLexInt) of
      rRETURN:Class:=stepRETURN; tracRETURN(S);|
      rIF:Class:=stepIF; stepPush(Class,topGenStep); tracIF(S); stepPop(); stepAdd(S,tekt,stepEndIF);|
      rSWITCH:Class:=stepCASE; stepPush(Class,topGenStep); tracCASE(S); stepPop(); stepAdd(S,tekt,stepEndCASE);|
      rWHILE:Class:=stepWHILE; stepPush(Class,topGenStep); tracWHILE(S); stepPop(); stepAdd(S,tekt,stepEndWHILE);|
      rDO:Class:=stepREPEAT; stepPush(Class,topGenStep); tracREPEAT(S); stepPop(); stepAdd(S,tekt,stepEndREPEAT);|
      rFOR:Class:=stepFOR; stepPush(Class,topGenStep); tracFOR(S); stepPop(); stepAdd(S,tekt,stepEndFOR);|
      rASM:tracASM(S);|
      rWITH:tracWITH(S);|
    end;|
    lexPARSE:case classPARSE(S.stLexInt) of
      pMul:tracEQUAL(S);|
    end;|
  end end
end tracSTATEMENT;

//----------- Список операторов ---------------

procedure tracListSTAT(var S:recStream);
//{STATEMENT ";"}
var r:classREZ;
begin
with S do
  if stLex=lexREZ then r:=classREZ(stLexInt) else r:=rezNULL end;
  while 
    ((stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC)or(stLex=lexVPAR)or
    (stLex=lexFIELD)or(stLex=lexSTRU)or(stLex=lexPROC)or
    (stLex=lexPARSE)and(classPARSE(stLexInt)=pMul)or
    (stLex=lexREZ)and(
      (r=rRETURN)or(r=rIF)or(r=rSWITCH)or(r=rWHILE)or
      (r=rDO)or(r=rFOR)or(r=rASM)or(r=rWITH)))and 
    not stErr do
    stepAdd(S,tekt,stepSimple);
    tracSTATEMENT(S);
    if stLex=lexREZ then r:=classREZ(stLexInt) else r:=rezNULL end;
  end;
end
end tracListSTAT;

//----------- Блок операторов ---------------

procedure tracBlockSTAT;
//STATEMENT | "{" {STATEMENT ";"} "}"
var r:classREZ;
begin
with S do
  if okPARSE(S,pFiL) then
    lexAccept1(S,lexPARSE,integer(pFiL));
    tracListSTAT(S);
    lexAccept1(S,lexPARSE,integer(pFiR));
  else tracSTATEMENT(S)
  end
end
end tracBlockSTAT;

end SmTraC.
