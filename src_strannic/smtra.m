//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TRA (трансляция модуля, язык Модула-2)
//Файл SMTRA.M

implementation module SmTra;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm;

procedure traCONST(var S:recStream); forward;
procedure traTYPE(var S:recStream); forward;
procedure traSETCONST(var S:recStream); forward;
procedure traDefTYPE(var S:recStream; typName:pstr; bitNew:boolean):pID; forward;
procedure traARRAY(var S:recStream; typId:pID); forward;
procedure traRECORD(var S:recStream; typId:pID); forward;
procedure traPOINTER(var S:recStream; typId:pID); forward;
procedure traListVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST); forward;
procedure traDefVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST); forward;
procedure traPROC(var S:recStream); forward;
procedure traIMPORT(var S:recStream); forward;
procedure traListSTAT(var S:recStream); forward;
procedure traTITLEtest(var S:recStream; procId:pID); forward;
procedure traTITLE(var S:recStream; procId:pID); forward;
procedure traFORMALtest(var S:recStream; procId:pID); forward;

//--------- Описание блока констант -----------

procedure traCONSTs(var S:recStream);
//CONSTs="CONST" {CONST ";"}
begin
with S do
  lexAccept1(S,lexREZ,integer(rCONST));
  while not stErr and (stLex=lexNEW) do
    traCONST(S);
    lexAccept1(S,lexPARSE,ord(pSem));
  end
end
end traCONSTs;

//---------- Описание блока типов -------------

procedure traTYPEs(var S:recStream);
//TYPEs="TYPE" {TYPE ";"}
var i:integer;
begin
with S do
  traListPre:=memAlloc(sizeof(arrLIST));
  traTopPre:=0;
  lexAccept1(S,lexREZ,integer(rTYPE));
  while stLex=lexNEW do
    traTYPE(S);
    lexAccept1(S,lexPARSE,ord(pSem));
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
end traTYPEs;

//------------ Описание диалога ---------------

procedure traDIALOG(var S:recStream);
var bitMin:boolean;
begin
with S,tbMod[tekt] do
if topMDlg=maxMDlg then lexError(S,_Слишком_много_диалогов_в_модуле[envER],nil)
else
  lexAccept1(S,lexREZ,integer(rDIALOG));
  inc(topMDlg);
  modDlg^[topMDlg]:=memAlloc(sizeof(recMDialog));
with modDlg^[topMDlg]^ do
  mdTop:=0;
  mdCon[mdTop]:=memAlloc(sizeof(recMItem));
//заголовок диалога
  with mdCon[mdTop]^ do
    miNam:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miNam,addr(stLexStr));
    lexAccept1(S,lexNEW,0);
    miX:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miY:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miCX:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miCY:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miSty:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
//заголовок
    if okPARSE(S,pCol) then miTxt:=nil
    else
      miTxt:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miTxt,addr(stLexStr));
      lexAccept1(S,lexSTR,0);
    end;
//класс
    miCla:=nil;
    if okPARSE(S,pCol) then
      lexAccept1(S,lexPARSE,integer(pCol));
      if not okPARSE(S,pCol) then
        miCla:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miCla,addr(stLexStr));
        lexAccept1(S,lexSTR,0);
      end
    end;
//фонт
    if not okPARSE(S,pCol) then miFont:=nil
    else
      lexAccept1(S,lexPARSE,integer(pCol));
      miFont:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miFont,addr(stLexStr));
      lexAccept1(S,lexSTR,0);
      lexAccept1(S,lexPARSE,integer(pCol));
      miSize:=stLexInt; lexAccept1(S,lexINT,0);
    end
  end;
  if okREZ(S,rBEGIN) then
    lexAccept1(S,lexREZ,integer(rBEGIN));
    while okREZ(S,rCONTROL) do
    if mdTop=maxItem then lexError(S,_Слишком_много_элементов_в_диалоге[envER],nil)
    else
      inc(mdTop);
      mdCon[mdTop]:=memAlloc(sizeof(recMItem));
      RtlZeroMemory(mdCon[mdTop],sizeof(recMItem));
//элемент диалога
    with mdCon[mdTop]^ do
      lexAccept1(S,lexREZ,integer(rCONTROL));
      miTxt:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miTxt,addr(stLexStr));
      lexAccept1(S,lexSTR,0); lexAccept1(S,lexPARSE,integer(pCol));
      bitMin:=false;
      if okPARSE(S,pMin) then
        lexAccept1(S,lexPARSE,integer(pMin));
        bitMin:=true;
      end;
      if bitMin
        then miId:=-stLexInt
        else miId:=stLexInt;
      end;
      lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
      miCla:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miCla,addr(stLexStr));
      lexAccept1(S,lexSTR,0); lexAccept1(S,lexPARSE,integer(pCol));
      miNam:=nil;
      miSty:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
      miX:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
      miY:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
      miCX:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
      miCY:=stLexInt; lexAccept1(S,lexINT,0);
    end end end;
    lexAccept1(S,lexREZ,integer(rEND));
    lexAccept1(S,lexPARSE,ord(pSem));
  end;
end end end
end traDIALOG;

//------------ Описание bitmap ----------------

procedure traBITMAP(var S:recStream);
var f:integer;
begin
with S,tbMod[tekt] do
if topBMP=maxBMP then lexError(S,_Слишком_много_bitmap_в_модуле[envER],nil)
else
  lexAccept1(S,lexREZ,integer(rBITMAP));
  inc(topBMP);
  with modBMP^[topBMP] do
    bmpName:=memAlloc(lstrlen(stLexStr)+1); lstrcpy(bmpName,stLexStr);
    lexAccept1(S,lexNEW,0);
    lexAccept1(S,lexPARSE,integer(pEqv));
    bmpFile:=memAlloc(lstrlen(stLexStr)+1); lstrcpy(bmpFile,stLexStr);
    lexAccept1(S,lexSTR,0);
    lexAccept1(S,lexPARSE,ord(pSem));
    f:=_lopen(bmpFile,OF_READ);
    if f<=0 then lexError(S,_Отсутствует_BMP_файл_[envER],bmpFile)
    else
      if _lsize(f)<14 
        then lexError(S,_BMP_файл_неверного_формата_[envER],bmpFile)
        else bmpSize:=_lsize(f)-14;
      end;
      _lclose(f)
    end
  end;
end end
end traBITMAP;

//------------ Описание icon ----------------

procedure traICON(var S:recStream);
var f:integer;
begin
with S,tbMod[tekt] do
  lexAccept1(S,lexREZ,integer(rICON));
  modICON:=memAlloc(lstrlen(stLexStr)+1);
  lstrcpy(modICON,stLexStr);
  lexAccept1(S,lexSTR,0);
  lexAccept1(S,lexPARSE,ord(pSem));
  f:=_lopen(modICON,OF_READ);
  if f<=0 then lexError(S,_Отсутствует_BMP_файл_[envER],modICON)
  else
    if _lsize(f)<14+40+16*4+512 then
      lexError(S,_BMP_файл_неверного_формата_[envER],modICON)
    end;
    _lclose(f)
  end
end
end traICON;

//----------- Описание константы --------------

procedure traCONST;
//CONST=Имя "=" ["-"] Значение
var conId:pID; bitMin,bitGet:boolean;
begin
with S do
  lexAccept1(S,lexNEW,0);
  conId:=idInsertGlo(stLexOld,idNULL);
  lexBitConst:=true;
  lexAccept1(S,lexPARSE,integer(pEqv));
  bitMin:=(stLex=lexPARSE)and(stLexInt=integer(pMin));
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
      idClass  :=idcSTRU;
      idStruAddr:=topData;
      idStruType:=stLexID;
      lexAccept1(S,lexTYPE,0);
      traSTRUCT(S,idStruType);
    end;|
  else
    if okPARSE(S,pSqL) then //константа множество
      idClass:=idcSET;
      traSETCONST(S);
      idSet:=memAlloc(32);
      idSet^:=stLexSet;
    else lexError(S,_Ожидалось_значение_константы[envER],nil);
    end;
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
end traCONST;

//------------- Описание типа -----------------

procedure traTYPE;
//TYPE=Имя "=" DefTYPE
var typId:pID; typName:string[maxText];
begin
with S do
  lexAccept1(S,lexNEW,0);
  lstrcpy(typName,stLexOld);
  lexAccept1(S,lexPARSE,integer(pEqv));
  traDefTYPE(S,typName,true)
end
end traTYPE;

//----------- Определение типа ----------------

procedure traDefTYPE(var S:recStream; typName:pstr; bitNew:boolean):pID;
//DefTYPE=ARRAY|RECORD|POINTER|SCALAR|NEW|SET|STRING
var typId,oldFi:pID; str:string[maxText]; i:integer;
begin
with S do
  if (stLex<>lexTYPE)or bitNew then
    typId:=idInsertGlo(typName,idNULL);
  end;
  case stLex of
    lexREZ:
      case classREZ(stLexInt) of
        rARRAY:traARRAY(S,typId);|
        rSTRING:traSTRING(S,typId);|
        rRECORD:traRECORD(S,typId);|
        rPOINTER:traPOINTER(S,typId);|
        rSET:traSET(S,typId);|
      else lexError(S,_Ошибка_в_описании_типа[envER],nil);
      end;|
    lexPARSE:
      if classPARSE(stLexInt)=pOvL //{скаляр}
        then traSCALAR(S,typId)
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
end traDefTYPE;

//---- Размещение типизированной константы ----

procedure traDefSTRUCT(var S:recStream; typId:pID);
var i,l:integer; bitMin:boolean; trans:record case of |r:real; |l0,l1:integer; |s:setbyte; |b:array[0..31]of byte; end;
begin
with S,typId^ do
  case idClass of
    idtBAS:case idBasNom of
      typeBYTE,typeWORD,typeINT,typeDWORD:
        bitMin:=okPARSE(S,pMin);
        if bitMin then
          lexAccept1(S,lexPARSE,integer(pMin));
        end;
        if (stLex<>lexINT)and(stLex<>lexSCAL) then lexError(S,_Ожидалось_целое_число[envER],nil) else
          if bitMin then
            stLexInt:=-stLexInt;
          end;
          if (idBasNom=typeBYTE)and(stLexInt and 0xFFFFFF00<>0)or
             (idBasNom=typeWORD)and(stLexInt and 0xFFFF0000<>0) then
            lexError(S,'Слишком большое значение',nil);
          end;
          case idBasNom of
            typeBYTE:genPutByte(S,lobyte(loword(stLexInt)));|
            typeWORD:genPutByte(S,lobyte(loword(stLexInt))); genPutByte(S,hibyte(loword(stLexInt)));|
            typeINT,typeDWORD:
              genPutByte(S,lobyte(loword(stLexInt)));
              genPutByte(S,hibyte(loword(stLexInt)));
              genPutByte(S,lobyte(hiword(stLexInt)));
              genPutByte(S,hibyte(hiword(stLexInt)));|
          end;
          if stLex=lexSCAL
            then lexAccept1(S,lexSCAL,0)
            else lexAccept1(S,lexINT,0)
          end
        end;|
      typeREAL32:
        bitMin:=okPARSE(S,pMin);
        if bitMin then
          lexAccept1(S,lexPARSE,integer(pMin));
        end;
        if stLex<>lexREAL then lexError(S,_Ожидалось_число[envER],nil) else
          if bitMin then
            stLexReal:=-stLexReal;
          end;
          with trans do
            l0:=sysRealToReal32(stLexReal);
            genPutByte(S,lobyte(loword(l0)));
            genPutByte(S,hibyte(loword(l0)));
            genPutByte(S,lobyte(hiword(l0)));
            genPutByte(S,hibyte(hiword(l0)));
          end;
          lexAccept1(S,lexREAL,0)
        end;|
      typeREAL:
        bitMin:=okPARSE(S,pMin);
        if bitMin then
          lexAccept1(S,lexPARSE,integer(pMin));
        end;
        if stLex<>lexREAL then lexError(S,_Ожидалось_число[envER],nil) else
          if bitMin then
            stLexReal:=-stLexReal;
          end;
          with trans do
            r:=stLexReal;
            genPutByte(S,lobyte(loword(l0)));
            genPutByte(S,hibyte(loword(l0)));
            genPutByte(S,lobyte(hiword(l0)));
            genPutByte(S,hibyte(hiword(l0)));
            genPutByte(S,lobyte(loword(l1)));
            genPutByte(S,hibyte(loword(l1)));
            genPutByte(S,lobyte(hiword(l1)));
            genPutByte(S,hibyte(hiword(l1)));
          end;
          lexAccept1(S,lexREAL,0)
        end;|
      typeCHAR:if stLex<>lexCHAR then lexError(S,_Ожидался_символ[envER],nil) else
        genPutByte(S,lobyte(loword(stLexInt)));
        lexAccept1(S,lexCHAR,0);
      end;|
      typeBOOL:if (stLex<>lexFALSE)and(stLex<>lexTRUE) then lexError(S,_Ожидалась_константа_TRUE_или_FALSE[envER],nil) else
        genPutByte(S,lobyte(loword(stLexInt)));
        genPutByte(S,0);
        genPutByte(S,0);
        genPutByte(S,0);
        lexAccept1(S,stLex,0);
      end;|
      typePOINT:if (stLex<>lexNIL)and(stLex<>lexINT) then lexError(S,_Ожидалось_целое_или_nil[envER],nil) else
        genPutByte(S,lobyte(loword(stLexInt)));
        genPutByte(S,hibyte(loword(stLexInt)));
        genPutByte(S,lobyte(hiword(stLexInt)));
        genPutByte(S,hibyte(hiword(stLexInt)));
        lexAccept1(S,stLex,0);
      end;|
      typePSTR:if (stLex<>lexNIL)and(stLex<>lexCHAR)and(stLex<>lexSTR) then lexError(S,_Ожидалась_строка_или_nil[envER],nil) else
        if stLex=lexCHAR then
          stLexStr[0]:=char(stLexInt);
          stLexStr[1]:=char(0);
        end;
        stringAdd(genSTRING,addr(stLexStr),tbMod[tekt].topData,topSTRING);
        genPutByte(S,0xFF);
        genPutByte(S,0xFF);
        genPutByte(S,0xFF);
        genPutByte(S,0xFF);
        lexAccept1(S,stLex,0);
      end;|
      typeSET:if not(okPARSE(S,pSqL)or(stLex=lexSET)) then lexError(S,_Ожидалось_множество[envER],nil) else
        if okPARSE(S,pSqL) then
          traSETCONST(S);
        end;
        trans.s:=stLexSet;
        for i:=0 to 31 do
          genPutByte(S,trans.b[i]);
        end;
        lexGetLex1(S);
      end;|
      else lexError(S,_Неверный_тип_в_структурной_константе[envER],nil)
    end;|
    idtARR:
    if (idArrItem=idTYPE[typeCHAR])and //строка
      (idArrInd=idTYPE[typeINT])and
      (extArrBeg=0) then
      if stLex<>lexSTR then lexError(S,_Ожидалась_строка[envER],nil) else
      if lstrlen(addr(stLexStr))>extArrEnd then lexError(S,_Слишком_длинная_строка[envER],nil) else
        for i:=0 to lstrlen(addr(stLexStr)) do
          genPutByte(S,byte(stLexStr[i]));
        end;
        for i:=lstrlen(addr(stLexStr))+1 to extArrEnd do
          genPutByte(S,0);
        end;
        lexAccept1(S,lexSTR,0)
      end end;
    else //массив
      lexBitConst:=true;
      lexAccept1(S,lexPARSE,integer(pFiL));
      for i:=extArrBeg to extArrEnd do
      if stLex<>lexNULL then
        if okPARSE(S,pCol)or okPARSE(S,pFiR) then
          for l:=1 to idArrItem^.idtSize do
            genPutByte(S,0)
          end 
        else traDefSTRUCT(S,idArrItem);
        end;
        if i<>extArrEnd then
          lexAccept1(S,lexPARSE,integer(pCol));
        end
      end end;
      lexBitConst:=false;
      lexAccept1(S,lexPARSE,integer(pFiR));
    end;|
    idtREC:
      lexBitConst:=true;
      lexAccept1(S,lexPARSE,integer(pFiL));
      for i:=1 to idRecMax do
      if stLex<>lexNULL then
        if okPARSE(S,pCol)or okPARSE(S,pFiR) then
          for l:=1 to idRecList^[i]^.idVarType^.idtSize do
            genPutByte(S,0)
          end
        else traDefSTRUCT(S,idRecList^[i]^.idVarType);
        end;
        if i<>idRecMax then
          lexAccept1(S,lexPARSE,integer(pCol));
        end
      end end;
      lexBitConst:=false;
      lexAccept1(S,lexPARSE,integer(pFiR));|
    idtSCAL:
      if stLex<>lexSCAL then lexError(S,_Ожидалась_константа_скалярного_типа_[envER],idName)
      else
        if idScalMax<=255 then genPutByte(S,lobyte(loword(stLexInt)))
        else
          genPutByte(S,lobyte(loword(stLexInt)));
          genPutByte(S,hibyte(loword(stLexInt)));
          genPutByte(S,lobyte(hiword(stLexInt)));
          genPutByte(S,hibyte(hiword(stLexInt)));
        end
      end;
      lexAccept1(S,lexSCAL,0);|
    else lexError(S,_Неверный_тип_в_структурной_константе_[envER],idName)
  end
end
end traDefSTRUCT;

//---- Размещение константы множества -------

procedure traSETCONST;
var i,be,en:integer;
begin
with S do 
  stLexSet:=[];
  lexAccept1(S,lexPARSE,integer(pSqL));
  while (stLex=lexCHAR)or(stLex=lexINT)or(stLex=lexSCAL) do
    be:=stLexInt;
    en:=be;
    lexGetLex1(S);
    if okPARSE(S,pPoiPoi) then
      lexAccept1(S,lexPARSE,integer(pPoiPoi));
      en:=stLexInt;
      if  (stLex=lexCHAR)or(stLex=lexINT)or(stLex=lexSCAL) 
        then lexGetLex1(S);
        else lexAccept1(S,lexINT,0);
      end;
    end;
    for i:=be to en do
      stLexSet:=stLexSet+i;
    end;
    if not okPARSE(S,pSqR) then
      lexAccept1(S,lexPARSE,integer(pCol));
    end
  end;
  lexTest(not((stLex=lexPARSE)and(stLexInt=ord(pSqR))),S,_Ожидалось__[envER],nil);
end
end traSETCONST;

//---- Размещение структурной константы -------

procedure traSTRUCT(var S:recStream; typId:pID);
var i:integer; l:integer;
begin
  topSTRING:=0;
  traDefSTRUCT(S,typId);
  for i:=1 to topSTRING do
  with tbMod[tekt],genSTRING^[i] do
    l:=genBASECODE+0x1000+genPutStr(S,stringPoi);
    genData^[stringSou+1]:=lobyte(loword(l));
    genData^[stringSou+2]:=hibyte(loword(l));
    genData^[stringSou+3]:=lobyte(hiword(l));
    genData^[stringSou+4]:=hibyte(hiword(l));
    genAddVarCall(S,tekt,tekt,stringSou+1,vcData,nil);
  end end
end traSTRUCT;

//----------- Описание массива ----------------

procedure traARRAY;
//ARRAY="ARRAY" ["[" Низ ".." Верх "]"] "OF" Тип
begin
with S,typId^ do
  idClass:=idtARR;
  lexAccept1(S,lexREZ,integer(rARRAY));
  if not okREZ(S,rOF) then
    lexBitConst:=true;
    lexAccept1(S,lexPARSE,integer(pSqL));
    if stLex=lexTYPE then //{скаляр}
      if stLexID^.idClass<>idtSCAL then
        lexError(S,_Ожидался_тип_перечисления[envER],nil);
      end;
      idArrInd:=stLexID;
      extArrBeg:=0;
      extArrEnd:=stLexID^.idScalMax-1;
      lexGetLex1(S);
    else //{диапазон}
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
  idArrItem:=traDefTYPE(S,"#array_item_type",false);
  idtSize:=(extArrEnd-extArrBeg+1)*idArrItem^.idtSize;
  if extArrBeg>extArrEnd then
    lexError(S,_Неверный_диапазон_индексов[envER],nil)
  end
end
end traARRAY;

//----------- Описание строки -----------------

procedure traSTRING;
//STRING="STRING" ["[" Верх "]"] 
begin
with S,typId^ do
  idClass:=idtARR;
  lexAccept1(S,lexREZ,integer(rSTRING));
  idArrInd:=idTYPE[typeINT];
  extArrBeg:=0;
  extArrEnd:=255;
  if okPARSE(S,pSqL) then
    lexBitConst:=true;
    lexAccept1(S,lexPARSE,integer(pSqL));
    extArrEnd:=stLexInt;
    lexAccept1(S,lexINT,0);
    lexBitConst:=false;
    lexAccept1(S,lexPARSE,integer(pSqR));
  end;
  idArrItem:=idTYPE[typeCHAR];
  idtSize:=(extArrEnd-extArrBeg+1)*idArrItem^.idtSize
end
end traSTRING;

//----------- Переключение доступа -----------------

procedure traPROTECTED(var S:recStream; bitDup:boolean);
begin
  if okREZ(S,rPRIVATE) then traCarPro:=proPRIVATE; lexGetLex1(S); if bitDup then lexAccept1(S,lexPARSE,ord(pDup)) end;
  elsif okREZ(S,rPROTECTED) then traCarPro:=proPUBLIC; lexGetLex1(S); if bitDup then lexAccept1(S,lexPARSE,ord(pDup)) end;
  elsif okREZ(S,rPUBLIC) then traCarPro:=proPUBLIC; lexGetLex1(S); if bitDup then lexAccept1(S,lexPARSE,ord(pDup)) end;
  end;
end traPROTECTED;

//----------- Описание записи -----------------

procedure traRECORD(var S:recStream; typId:pID);
//RECORD="RECORD" ["(" [className] ")"] ListVAR [ "CASE" "OF" {"|" ListVAR} ] "END"
var recMax,recCase,recStart,i:integer; oldRec:pID; str:string[maxText];
begin
with S,typId^ do
  idClass:=idtREC;
  lexAccept1(S,lexREZ,integer(rRECORD));
  oldRec:=traRecId;
  traRecId:=typId;
  idRecCla:=nil;
  idRecMax:=0;
  idRecList:=memAlloc(sizeof(arrLIST));
  idRecTop:=0;
  idRecMet:=memAlloc(sizeof(arrLIST));
  idtSize:=0;
  if okPARSE(S,pOvL) then
    idtSize:=4;
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
  traListVAR(S,idvFIELD,0,idtSize,idRecMax,idRecList);
  if okREZ(S,rCASE) then //варианты
    lexAccept1(S,lexREZ,integer(rCASE));
    if not okREZ(S,rOF) then
      traDefVAR(S,idvFIELD,0,idtSize,idRecMax,idRecList);
    end;
    lexAccept1(S,lexREZ,integer(rOF));
    recMax:=0;
    recStart:=idtSize;
    while okPARSE(S,pVer) do
      lexAccept1(S,lexPARSE,integer(pVer));
      while (stLex=lexINT)or(stLex=lexCHAR)or(stLex=lexFALSE)or(stLex=lexTRUE)or(stLex=lexSCAL) do
        lexGetLex1(S);
        if okPARSE(S,pCol)
          then lexAccept1(S,lexPARSE,ord(pCol));
          else lexAccept1(S,lexPARSE,ord(pDup));
        end;
      end;
      recCase:=recStart;
      traListVAR(S,idvFIELD,0,recCase,idRecMax,idRecList);
      if recCase-recStart>recMax then
        recMax:=recCase-recStart
      end
    end;
    inc(idtSize,recMax)
  end;
  traRecId:=oldRec;
  lexAccept1(S,lexREZ,integer(rEND))
end
end traRECORD;

//----------- Описание указателя --------------

procedure traPOINTER;
//POINTER="POINTER" "TO" Тип
begin
with S,typId^ do
  idClass:=idtPOI;
  lexAccept1(S,lexREZ,integer(rPOINTER));
  lexAccept1(S,lexREZ,integer(rTO));
  idPoiBitForward:=(stLex=lexNEW);
  if stLex=lexNEW then
    idPoiType:=idTYPE[typeCHAR];
    idPoiPred:=memAlloc(lstrlen(stLexStr)+1);
    lstrcpy(pstr(idPoiPred),stLexStr);
    listAdd(traListPre,typId,traTopPre);
    lexAccept1(S,lexNEW,0);
  else idPoiType:=traDefTYPE(S,"#poi_base_type",false)
  end;
  idtSize:=4;
end
end traPOINTER;

//----------- Описание множества --------------

procedure traSET;
//SET="SET" "OF" Тип
begin
with S,typId^ do
  idClass:=idtSET;
  lexAccept1(S,lexREZ,integer(rSET));
  lexAccept1(S,lexREZ,integer(rOF));
  idSetType:=traDefTYPE(S,"#set_base_type",false);
  idtSize:=32;
end
end traSET;

//------------ Описание скаляра ---------------

procedure traSCALAR;
//SCALAR="(" Имя {"," Имя} ")"
var scalId:pID; scalVal:integer;
begin
with S,typId^ do
  idClass:=idtSCAL;
  scalVal:=0;
  idScalMax:=0;
  idScalList:=memAlloc(sizeof(arrLIST));
  lexAccept1(S,lexPARSE,integer(pOvL));
  while stLex=lexNEW do
    scalId:=idInsertGlo(addr(stLexStr),idcSCAL);
    scalId^.idScalVal:=scalVal;
    scalId^.idScalType:=typId;
    listAdd(idScalList,scalId,idScalMax);
    lexAccept1(S,lexNEW,0);
    if not okPARSE(S,pOvR) then
      lexAccept1(S,lexPARSE,integer(pCol));
    end;
    inc(scalVal)
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
  if idScalMax>255
    then idtSize:=4
    else idtSize:=1
  end
end
end traSCALAR;

//-------- Описание блока переменных ----------

procedure traVARs(var S:recStream);
//VARs="VAR" ListVAR
var varList:arrLIST; varTop:integer;
begin
with S do
  lexAccept1(S,lexREZ,integer(rVAR));
  varTop:=0;
  with tbMod[tekt] do
    traListVAR(S,idvVAR,0,topData,varTop,varList);
  end;
end
end traVARs;

//-------- Список описаний переменных ---------

procedure traListVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST);
//ListVAR={DefVAR ";"}
begin
with S do
  while ((stLex=lexNEW)or (vId=idvFIELD)and(traRecId<>nil)and(traRecId^.idRecCla<>nil)and okREZ(S,rPROCEDURE))and not stErr do
    if okREZ(S,rPROCEDURE) then traPROC(S)
    else
      traDefVAR(S,vId,vBeg,vMem,vTop,vList);
      lexAccept1(S,lexPARSE,ord(pSem));
    end
  end
end
end traListVAR;

//------------ Список переменных --------------

procedure traDefVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST);
//DefVAR=Имя ['*'|'-'] {"," Имя ['*'|'-']} ":" Тип
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
    if (traRecId<>nil)and(traRecId^.idRecCla<>nil) then
      varId^.idPro:=proPRIVATE;
    end;
    listAdd(vList,varId,vTop);
    lexAccept1(S,stLex,0);
    if okPARSE(S,pMul)or okPARSE(S,pMin) then
      varId^.idPro:=proPUBLIC;
      lexGetLex1(S);
    end;
    if not okPARSE(S,pDup) then
      lexAccept1(S,lexPARSE,integer(pCol));
    end
  end;
  lexTest(stLex<>lexPARSE,S,_Ожидалось_новое_имя[envER],nil);
  lexAccept1(S,lexPARSE,integer(pDup));
  varType:=traDefTYPE(S,"#var_type",false);

  for i:=varTop+1 to vTop do
  with vList^[i]^ do
    idVarType:=varType;
    idVarAddr:=vBeg+vMem;
    if vId=idvVPAR
      then inc(vMem,4)
      else inc(vMem,varType^.idtSize)
    end;
  end end;
end
end traDefVAR;

//------------- Список описаний ---------------

procedure traListDEF(var S:recStream);
//ListDEF={CONSTs|TYPEs|VARs|PROC|DIALOG|BITMAP|ICON|FROM}
begin
with S do
  while (stLex=lexREZ)and(
    (stLexInt=integer(rCONST))or
    (stLexInt=integer(rTYPE))or
    (stLexInt=integer(rVAR))or
    (stLexInt=integer(rPROCEDURE))or
    (stLexInt=integer(rDIALOG))or
    (stLexInt=integer(rBITMAP))or
    (stLexInt=integer(rICON))or
    (stLexInt=integer(rFROM))) do
  case classREZ(stLexInt) of 
    rCONST:traCONSTs(S);|
    rTYPE:traTYPEs(S);|
    rVAR:traVARs(S);|
    rPROCEDURE:traPROC(S);|
    rDIALOG:traDIALOG(S);|
    rBITMAP:traBITMAP(S);|
    rICON:traICON(S);|
    rFROM:traFROM(S);|
  end end
end
end traListDEF;

//===============================================
//                        КОДЫ ОПЕРАЦИЙ
//===============================================

//------- Проверка на операцию --------

  procedure traINo(o,oLo,oHi:classOp):boolean;
  begin
    return (ord(o)>=ord(oLo))and(ord(o)<=ord(oHi))
  end traINo;

//---------- Коды операций BYTE ---------------

procedure traBYTE(var S:recStream; op:classOp);
begin
  if (op=opUgLUgL)or(op=opUgRUgR) then genR(S,cPOP,rECX);
  elsif (op<>opNOT)and(op<>opNOTB) then genR(S,cPOP,rEBX);
  end;
  genPOP(S,rEAX,traBitAND);
  if traINo(op,opE,opGEZ) then
//    genRR(S,cCMP,rAL,rBL);
    genRR(S,cCMP,rEAX,rEBX);
    genRD(S,cMOV,rEAX,1);
  end;
  case op of
    opADD:genRR(S,cADD,rAL,rBL);|
    opSUB:genRR(S,cSUB,rAL,rBL);|
    opMUL:genR (S,cMUL,rBL);|
    opDIV:genR (S,cDIV,rBL);|
    opMOD:genR (S,cDIV,rBL);|
    opUgLUgL:genRegCL(S,cSHL,rAL);|
    opUgRUgR:genRegCL(S,cSHR,rAL);|
    opOR:genRR(S,cOR,rAL,rBL);|
    opAND:genRR(S,cAND,rAL,rBL);|
    opNOT:genR (S,cNOT,rEAX);|
    opE:genGen(S,cJE,2);|
    opNE:genGen(S,cJNE,2);|
    opL:genGen(S,cJB,2);|
    opG:genGen(S,cJA,2);|
    opLZ:genGen(S,cJL,2);|
    opGZ:genGen(S,cJG,2);|
    opLE:genGen(S,cJBE,2);|
    opGE:genGen(S,cJAE,2);|
    opLEZ:genGen(S,cJLE,2);|
    opGEZ:genGen(S,cJGE,2);|
  else lexError(S,_Неверная_операция_BYTE[envER],nil)
  end;
  if (op=opMOD)or(op=opMODZ) then
    genRR(S,cMOV,rAL,rAH);
  end;
  if traINo(op,opE,opGEZ) then genRR(S,cXOR,rEAX,rEAX)
  else
    genRR(S,cXOR,rAH,rAH);
    genRD(S,cAND,rEAX,0x000000FF);
  end;
  genR(S,cPUSH,rEAX);
end traBYTE;

//---------- Коды операций WORD ---------------

procedure traWORD(var S:recStream; op:classOp);
begin
  if (op=opUgLUgL)or(op=opUgRUgR) then genR(S,cPOP,rECX);
  elsif (op<>opNOT)and(op<>opNOTB) then genR(S,cPOP,rEBX);
  end;
  genPOP(S,rEAX,traBitAND);
  case op of
    opDIV,opMOD:genRR(S,cXOR,rDX,rDX);|
    opDIVZ,opMODZ:genGen(S,cCWD,0);|
  end;
  if traINo(op,opE,opGEZ) then
    genRR(S,cCMP,rAX,rBX);
    genRD(S,cMOV,rEAX,1);
  end;
  case op of
    opADD:genRR(S,cADD,rAX,rBX);|
    opSUB:genRR(S,cSUB,rAX,rBX);|
    opMUL:genR (S,cMUL,rBX);|
    opMULZ:genR (S,cIMUL,rBX);|
    opDIV:genR (S,cDIV,rBX);|
    opDIVZ:genR (S,cIDIV,rBX);|
    opMOD:genR (S,cDIV,rBX);|
    opMODZ:genR (S,cIDIV,rBX);|
    opUgLUgL:genRegCL(S,cSHL,rAX);|
    opUgRUgR:genRegCL(S,cSHR,rAX);|
    opOR:genRR(S,cOR,rAX,rBX);|
    opAND:genRR(S,cAND,rAX,rBX);|
    opNOT:genR (S,cNOT,rAX);|
    opORB:genRR(S,cOR,rAX,rBX);|
    opANDB:genRR(S,cAND,rAX,rBX);|
    opNOTB:genR (S,cNOT,rAX);|
    opE:genGen(S,cJE,2);|
    opNE:genGen(S,cJNE,2);|
    opL:genGen(S,cJB,2);|
    opG:genGen(S,cJA,2);|
    opLZ:genGen(S,cJL,2);|
    opGZ:genGen(S,cJG,2);|
    opLE:genGen(S,cJBE,2);|
    opGE:genGen(S,cJAE,2);|
    opLEZ:genGen(S,cJLE,2);|
    opGEZ:genGen(S,cJGE,2);|
  else lexError(S,_Неверная_операция_WORD[envER],nil)
  end;
  if (op=opMOD)or(op=opMODZ) then
    genRR(S,cMOV,rEAX,rEDX);
  end;
  if (op=opORB)or(op=opANDB)or(op=opNOTB) then
    genRD(S,cAND,rEAX,1);
  end;
  if traINo(op,opE,opGEZ) then
    genRR(S,cXOR,rEAX,rEAX);
  end;
  if op in [opADD..opMODZ] then
    genRD(S,cAND,rEAX,0xFFFF);
  end;
  genR(S,cPUSH,rEAX);
end traWORD;

//---------- Коды операций LONG ---------------

procedure traLONG(var S:recStream; op:classOp);
begin
  if (op=opUgLUgL)or(op=opUgRUgR) then genR(S,cPOP,rECX);
  elsif (op<>opNOT)and(op<>opNOTB) then genR(S,cPOP,rEBX);
  end;
  genPOP(S,rEAX,traBitAND);
  case op of
    opDIV,opMOD:genRR(S,cXOR,rEDX,rEDX);|
    opDIVZ,opMODZ:genRR(S,cMOV,rEDX,rEAX); genRD(S,cSAR,rEDX,31);|
  end;
  if traINo(op,opE,opGEZ) then
    genRR(S,cCMP,rEAX,rEBX);
    genRD(S,cMOV,rEAX,1);
  end;
  case op of
    opADD:genRR(S,cADD,rEAX,rEBX);|
    opSUB:genRR(S,cSUB,rEAX,rEBX);|
    opMUL:genR (S,cMUL,rEBX);|
    opMULZ:genR (S,cIMUL,rEBX);|
    opDIV:genR (S,cDIV,rEBX);|
    opDIVZ:genR (S,cIDIV,rEBX);|
    opMOD:genR (S,cDIV,rEBX);|
    opMODZ:genR (S,cIDIV,rEBX);|
    opUgLUgL:genRegCL(S,cSHL,rEAX);|
    opUgRUgR:genRegCL(S,cSHR,rEAX);|
    opOR:genRR(S,cOR,rEAX,rEBX);|
    opAND:genRR(S,cAND,rEAX,rEBX);|
    opNOT:genR (S,cNOT,rEAX);|
    opORB:genRR(S,cOR,rEAX,rEBX);|
    opANDB:genRR(S,cAND,rEAX,rEBX);|
    opNOTB:genR (S,cNOT,rEAX);|
    opE:genGen(S,cJE,2);|
    opNE:genGen(S,cJNE,2);|
    opL:genGen(S,cJB,2);|
    opG:genGen(S,cJA,2);|
    opLZ:genGen(S,cJL,2);|
    opGZ:genGen(S,cJG,2);|
    opLE:genGen(S,cJBE,2);|
    opGE:genGen(S,cJAE,2);|
    opLEZ:genGen(S,cJLE,2);|
    opGEZ:genGen(S,cJGE,2);|
  else lexError(S,_Неверная_операция_LONG[envER],nil)
  end;
  if (op=opMOD)or(op=opMODZ) then
    genRR(S,cMOV,rEAX,rEDX);
  end;
  if (op=opORB)or(op=opANDB)or(op=opNOTB) then
    genRD(S,cAND,rEAX,1);
  end;
  if traINo(op,opE,opGEZ) then
    genRR(S,cXOR,rEAX,rEAX);
  end;
  genR(S,cPUSH,rEAX);
end traLONG;

//---------- Коды операций REAL ---------------

const masEQV=0x0100; masL=0x4000;

procedure traREAL(var S:recStream; op:classOp; size:integer);
begin
//загрузка операндов
  case op of
    opADD,opSUB,opMUL,opDIV,opE..opGEZ:
//mov si,sp; wait; fld q/d [si+8/4]; wait
      genRR(S,cMOV,rESI,rESP);
      genGen(S,cWAIT,0);
      genM(S,cFLD,regNULL,regNULL,rESI,size,size);
      genGen(S,cWAIT,0);|
  end;
//операция
  case op of
    opADD:genM(S,cFADD,regNULL,regNULL,rESI,0,size);|
    opSUB:genM(S,cFSUB,regNULL,regNULL,rESI,0,size);|
    opMUL:genM(S,cFMUL,regNULL,regNULL,rESI,0,size);|
    opDIV:genM(S,cFDIV,regNULL,regNULL,rESI,0,size);|
    opE,opNE,opLZ,opGZ,opLEZ,opGEZ:genM(S,cFCOMP,regNULL,regNULL,rESI,0,size);|
  else mbI(integer(op),_Неверная_операция_REAL[envER])
  end;
//add sp,8/4; mov si,sp
  genRD(S,cADD,rESP,size);
  genRR(S,cMOV,rESI,rESP);
//выгрузка результата
  case op of
    opADD,opSUB,opMUL,opDIV:
//  wait; fstp q/d [si]
      genGen(S,cWAIT,0);
      genM(S,cFSTP,regNULL,regNULL,rESI,0,size);|
    opE..opGEZ:
//  fstsw [si{+4}]; {add sp,4;} pop bx
      case size of
        4:genM(S,cFSTSW,regNULL,regNULL,rESI,0,0);|
        0,8:genM(S,cFSTSW,regNULL,regNULL,rESI,4,0); genRD(S,cADD,rESP,4);|
      end;
      genR(S,cPOP,rEBX);
//  lahf; and ah,3F
      genGen(S,cLAHF,0);
      genRD(S,cAND,rAH,0x3F);
//  знак числа:mov al,bh; and al,40; or ah,al
      genRR(S,cMOV,rAL,rBH);
      genRD(S,cAND,rAL,0x40);
      genRR(S,cOR,rAH,rAL);
//  равенство:mov al,bh; mov cl,7; rol al,cl; and al,80; or ah,al
      genRR(S,cMOV,rAL,rBH);
      genRD(S,cMOV,rCL,7);
      genRegCL(S,cROL,rAL);
      genRD(S,cAND,rAL,0x80);
      genRR(S,cOR,rAH,rAL);
//  sahf; mov ax,1
      genGen(S,cSAHF,0);
      genRD(S,cMOV,rEAX,1);
//  jmp
      case op of
        opE:genGen(S,cJE,2);|
        opNE:genGen(S,cJNE,2);|
        opL:genGen(S,cJB,2);|
        opG:genGen(S,cJA,2);|
        opLZ:genGen(S,cJL,2);|
        opGZ:genGen(S,cJG,2);|
        opLE:genGen(S,cJBE,2);|
        opGE:genGen(S,cJAE,2);|
        opLEZ:genGen(S,cJLE,2);|
        opGEZ:genGen(S,cJGE,2);|
      end;
//xor ax,ax; push ax
      genRR(S,cXOR,rEAX,rEAX);
      genR(S,cPUSH,rEAX);|
  end
end traREAL;

//---------- Коды операций SET ---------------

procedure traGENSET(var S:recStream; op:classOp);
begin
  case op of
    opSETADD,opSETSUB:
      //mov cx,8;
      //mov si,sp;
      genRD(S,cMOV,rECX,8);
      genRR(S,cMOV,rESI,rESP);
      //rep:
      //  mov ax,[si+28];
      //  or/xor [si+60],ax;
      //  sub si,4;
      //loop rep;
      genMR(S,cMOV,regNULL,regNULL,rESI,rEAX,28,1);
      case op of
        opSETADD:genMR(S,cOR,regNULL,regNULL,rESI,rEAX,60,0);|
        opSETSUB:genMR(S,cXOR,regNULL,regNULL,rESI,rEAX,60,0);|
      end;
      genRD(S,cSUB,rESI,4);
      genGen(S,cLOOP,-14);
      //add sp,32;
      genRD(S,cADD,rESP,32);|
    opSETADDE,opSETSUBE:
      //pop ax;
      genR(S,cPOP,rEAX);
      //mov bx,8; xor dx,dx; div bx; --в ax номер байта, в dx - номер бита
      genRD(S,cMOV,rEBX,8);
      genRR(S,cXOR,rEDX,rEDX);
      genR(S,cDIV,rEBX);
      //mov si,sp; add si,ax;
      genRR(S,cMOV,rESI,rESP);
      genRR(S,cADD,rESI,rEAX);
      //bts/btr [si],dx
      case op of
        opSETADDE:genMR(S,cBTS,regNULL,regNULL,rESI,rEDX,0,0);|
        opSETSUBE:genMR(S,cBTR,regNULL,regNULL,rESI,rEDX,0,0);|
      end;|
    opSETIN:
      //mov si,sp; mov ax,[si+32];
      genRR(S,cMOV,rESI,rESP);
      genMR(S,cMOV,regNULL,regNULL,rESI,rEAX,32,1);
      //mov bx,8; xor dx,dx; div bx; --в ax номер байта, в dx - номер бита
      genRD(S,cMOV,rEBX,8);
      genRR(S,cXOR,rEDX,rEDX);
      genR(S,cDIV,rEBX);
      //add si,ax
      genRR(S,cADD,rESI,rEAX);
      //bt [si],dx
      genMR(S,cBT,regNULL,regNULL,rESI,rEDX,0,0);
      //mov ax,1; jc next; xor ax,ax; next:add sp,34; push ax;
      genRD(S,cMOV,rEAX,1);
      genGen(S,cJC,2);
      genRR(S,cXOR,rEAX,rEAX);
      genRD(S,cADD,rESP,36);
      genR(S,cPUSH,rEAX);|
  end;
end traGENSET;

//===============================================
//                 ТРАНСЛЯЦИЯ ОПИСАНИЙ
//===============================================

//----------- Добавить модуль -----------------

procedure traAddModule(var S:recStream; name:pstr):integer;
var no,i:integer; str:string[maxText];
begin
  lstrcpy(str,name);
  CharLower(str);
//поиск модуля в таблице модулей
  no:=0;
  for i:=1 to topMod do
    if lstrcmpi(tbMod[i].modNam,str)=0 then
      no:=i;
    end
  end;
//добавление нового модуля
  if no=0 then
    if topMod=maxMod
      then lexError(S,'Слишком много модулей',nil)
      else inc(topMod)
    end;
    no:=topMod;
    if not genLoadMod(S,name,topMod,true) then
      lexError(S,_Отсутствует_модуль_[envER],name);
      genCloseMod(topMod);
      dec(topMod);
    else tbMod[topMod].modAct:=true
    end
  elsif (no>topt)or tbMod[no].modComp then tbMod[no].modAct:=true
  elsif not genLoadMod(S,name,no,true) then lexError(S,_Не_компилирован_модуль_[envER],name);
  else tbMod[no].modAct:=true
  end;
  return no
end traAddModule;

//------------- Код вызова процедуры win32 ----------------

procedure traCall32(var S:recStream; mo,pr:pstr);
var procId:pID; no:integer;
begin
  procId:=nil;
  for no:=1 to topMod do
    procId:=idFind(tbMod[no].modTab,pr);
  end;
  if procId=nil then lexError(S,"Не обнаружена процедура:",pr)
  else
    with tbMod[tekt] do
      impAdd(genImport,mo,pr,topCode+3,topImport);
    end;
    genM(S,cCALLF,regNULL,regNULL,regNULL,0,0);
  end;
end traCall32;

//------------- Код завершения ----------------

procedure traFinish(var S:recStream);
var procId:pID; no:integer;
begin
//  no:=traAddModule(S,"Kernel32",false);
//  procId:=idFind(tbMod[no].modTab,"ExitProcess");
//  if procId=nil then
//    procId:=idInsert(tbMod[no].modTab,"ExitProcess",idPROC,tabMod,no);
//    with procId^ do
//      idNom:=no;
//      idProcAddr:=-1;
//      idProcPar :=0;
//      idProcType:=nil;
//      idProcMax :=0;
//      idProcDLL :=nil;
//      idProcList:=memAlloc(sizeof(arrLIST));
//    end
//  end;
//  genD(S,cPUSH,0);
//  with tbMod[tekt] do
//    impAdd(genImport,"Kernel32","ExitProcess",topCode+3,topImport);
//  end;
//  {callf _cProc}
//  genM(S,cCALLF,regNULL,regNULL,regNULL,0,0);
  genD(S,cRET,0)
end traFinish;

//---------------- Модуль ---------------------

procedure traMODULE(var S:recStream);
//MODULE=["DEFINITION"|"IMPLEMENTATION"] "MODULE" Имя ";"
//       ["IMPORT" Имя ("," Имя) ";"]
//       ["EXPORT" Имя ("," Имя) ";"]
//       ListDEF
//       ["BEGIN" ListSTAT] "END" Имя "."
var i,j:integer;
begin
with S do
  traBitDEFmod:=false;
  if okREZ(S,rDEFINITION) then
    traBitDEF:=true;
    traBitDEFmod:=true;
    lexAccept1(S,lexREZ,integer(rDEFINITION));
  end;
  if okREZ(S,rIMPLEMENTATION) then
    traBitIMP:=true;
    lexAccept1(S,lexREZ,integer(rIMPLEMENTATION));
  end;
  if traBitH and not traBitDEFmod then lexError(S,_Ожидался_definition_модуль[envER],nil) end;
  if not traBitH and traBitDEFmod then lexError(S,_Ожидался_программный_модуль[envER],nil) end;
  if not traBitH and not traBitDEFmod and not traBitIMP then
    tbMod[stTxt].modMain:=true;
  end;
  lexAccept1(S,lexREZ,integer(rMODULE));
  lexAccept1(S,lexNEW,0);
  lstrcpy(traModName,stLexOld);
  lexAccept1(S,lexPARSE,ord(pSem));
  //импорт
  if okREZ(S,rIMPORT) then
    lexAccept1(S,lexREZ,integer(rIMPORT));
    traIMPORT(S);
    while okPARSE(S,pCol) do
      lexAccept1(S,lexPARSE,integer(pCol));
      traIMPORT(S);
    end;
    lexAccept1(S,lexPARSE,ord(pSem))
  end;
  //тело модуля
  traListDEF(S);
  if okREZ(S,rBEGIN) then
    genStack:=0;
    with tbMod[tekt] do
      genEntry:=topCode;
      genEntryNo:=tekt;
      genEntryStep:=topGenStep;
    end;
    lexAccept1(S,lexREZ,integer(rBEGIN));
    traListSTAT(S);
  end;
  lexAccept1(S,lexREZ,integer(rEND));
  if not ((stLex=lexNEW)or(stLex=lexID)) then
    lexError(S,_Ожидалось_имя_модуля_[envER],traModName);
  end;
  lexGetLex1(S);
  if lstrcmp(traModName,stLexOld)<>0 then
    lexError(S,_Ожидалось_имя_модуля_[envER],traModName);
  end;
  lexAccept1(S,lexPARSE,integer(pPoi));
  lexAccept1(S,lexEOF,0);
end
end traMODULE;

//-------------- Импорт модуля ----------------

procedure traIMPORT(var S:recStream);
var impName:string[maxText]; no,i:integer;
begin
with S do
  lexTest(not (stLex=lexNEW),S,_Ожидалось_имя_модуля[envER],nil);
  lexGetLex1(S);
//имя файла модуля
  lstrcpy(impName,stLexOld);
//поиск модуля в таблице модулей
  no:=traAddModule(S,impName);
end
end traIMPORT;

//---------------- Процедура ------------------

procedure traPROC(var S:recStream);
//PROCEDURE="PROCEDURE" ["(" ИмяКласса ")"] Имя ["ASCII"] TITLE BODY|FORWARD
//BODY=["VAR" ListVAR] "BEGIN" [ListSTAT] "END" Имя
//FROM="FROM" Имя
var procId,modId,parId,procCla,virtId,id:pID; bitComp:boolean; i:integer; name,met:string[maxText];
begin
with S do
//заголовок
  lexAccept1(S,lexREZ,integer(rPROCEDURE));
  procCla:=nil;
  if (traRecId<>nil)and(traRecId^.idRecCla<>nil) then procCla:=traRecId
  elsif okPARSE(S,pOvL) then
    lexAccept1(S,lexPARSE,ord(pOvL));
    if stLex=lexNEW then
      lstrcpy(name,stLexStr);
      lexAccept1(S,lexNEW,0);
      lexAccept1(S,lexPARSE,ord(pDup));
    else lstrcpy(name,"self");
    end;
    if (stLex=lexTYPE)and(stLexID<>nil)and(stLexID^.idClass=idtREC)and(stLexID^.idRecCla<>nil)
      then procCla:=stLexID
      else lexError(S,_Ожидалось_имя_класса[envER],nil)
    end;
    lexAccept1(S,lexTYPE,0);
    lexAccept1(S,lexPARSE,ord(pOvR));
    if (stLex in setID)and(procCla<>nil) then
      lstrcpy(met,procCla^.idName);
      lstrcatc(met,'.');
      lstrcat(met,stLexStr);
      id:=idFindGlo(met,false);
      if id<>nil then
        stLex:=lexPROC;
        stLexID:=id;
        lstrcpy(stLexStr,met);
      end
    end
  end;
  if (stLex=lexPROC)and(procCla<>nil)and(stLexID^.idProcCla=nil) then
    stLex:=lexNEW;
  end;
  if (stLex=lexPROC)and((stLexID^.idProcAddr=-1)or(stLexID^.idNom<tekt)) then //было FORWARD-описание
    procId:=stLexID;
    lexAccept1(S,lexPROC,0);
    for i:=1 to procId^.idProcMax do
      procId^.idProcList^[i]^.idActiv:=byte(true);
    end;
    if okPARSE(S,pOvL) then
      traTITLEtest(S,procId);
    end
  else //новая процедура
    lexAccept1(S,lexNEW,0);
    if procCla<>nil then
      lstrinsc('.',stLexOld,0);
      lstrins(procCla^.idName,stLexOld,0);
    end;
    procId:=idFindGlo(stLexOld,false);
    lexTest((procId<>nil)and(procId^.idProcAddr<>-1),S,_Повторное_имя_метода[envER],nil);
    if procId<>nil then
      for i:=1 to procId^.idProcMax do
        procId^.idProcList^[i]^.idActiv:=byte(true);
      end;
      if okPARSE(S,pOvL) then
        traTITLEtest(S,procId);
      end;
    end;
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
    if traFromDLL[0]='\0' then procId^.idProcDLL:=nil
    else
      procId^.idProcDLL:=memAlloc(lstrlen(traFromDLL)+1);
      lstrcpy(procId^.idProcDLL,traFromDLL);
    end;
    with procId^ do
      idProcMax:=0;
      idProcList:=memAlloc(sizeof(arrLIST));
      idProcLock:=0;
      idLocMax:=0;
    end;
    if procCla<>nil then
    with procId^ do
      idProcCla:=procCla;
      parId:=idInsertGlo(name,idvVPAR);
      with parId^ do
        idVarType:=procCla;
        idVarAddr:=0;
      end;
      listAdd(idProcList,parId,idProcMax);
      inc(idProcPar,4);
      listAdd(idProcCla^.idRecMet,procId,idProcCla^.idRecTop);
    end end;
    if okPARSE(S,pMul)or okPARSE(S,pMin) then
      procId^.idPro:=proPUBLIC;
      lexGetLex1(S);
    elsif procCla<>nil then procId^.idPro:=proPRIVATE;
    end;
    traTITLE(S,procId);
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
  lexAccept1(S,lexPARSE,ord(pSem));
//FORWARD | DEF | BODY
  if okREZ(S,rFORWARD) then //FORWARD
    lexAccept1(S,lexREZ,integer(rFORWARD));
    lexAccept1(S,lexPARSE,ord(pSem))
  elsif (traRecId<>nil)and(traRecId^.idRecCla<>nil) then //метод внутри класса
  elsif traBitDEFmod then //DEF,вставка в список экспорта DLL
    if traMakeDLL then
    with tbMod[stTxt] do
      expAdd(genExport,procId^.idName,topExport);
    end end
  else with procId^ do //BODY
    if not traBitDEFmod then
      idLocList:=memAlloc(sizeof(arrLIST));
//    переменные
      if okREZ(S,rVAR) then
        lexAccept1(S,lexREZ,integer(rVAR));
        traListVAR(S,idvLOC,0,idProcLock,idLocMax,idLocList);
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
// push esi; push ebx
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
      lexAccept1(S,lexREZ,integer(rBEGIN));
      genStack:=0;
      traListSTAT(S);
      stepAdd(S,tekt,stepRETURN);
      lexAccept1(S,lexREZ,integer(rEND));
      lstrcpy(name,idName);
      if lstrposc('.',name)>=0 then
        lstrdel(name,0,lstrposc('.',name)+1)
      end;
      if (stLex in setID)and(lstrcmp(name,stLexStr)=0)
        then lexGetLex1(S)
        else lexError(S,_Ожидалось_имя_процедуры_[envER],idName)
      end;
      lexAccept1(S,lexPARSE,ord(pSem));
//    pop bx; pop si; leave; ret _ПамятьПар
      genR(S,cPOP,rEBX);
      genR(S,cPOP,rESI);
      genGen(S,cLEAVE,0);
      genD(S,cRET,idProcPar);
//чистка локальных переменных
      for i:=1 to procId^.idLocMax do
        procId^.idLocList^[i]^.idActiv:=byte(false);
      end;
//конец with self
      if idProcCla<>nil then
        dec(topWith)
      end
    end
  end end;
  procId^.idProcCode:=tbMod[tekt].topCode-procId^.idProcAddr;
//чистка параметров
  for i:=1 to procId^.idProcMax do
    procId^.idProcList^[i]^.idActiv:=byte(false);
  end;
  traCarProc:=nil
end
end traPROC;

//---------- Заголовок процедуры --------------

procedure traTITLE(var S:recStream; procId:pID);
//TITLE="(" [FORMAL {";"|"," FORMAL}] ")" [":" Тип] ";"
begin
with S,procId^ do
  idProcPar:=0;
  idProcType:=nil;
  lexAccept1(S,lexPARSE,integer(pOvL));
  if not okPARSE(S,pOvR) then
    traFORMAL(S,procId);
    while okPARSE(S,pSem) or okPARSE(S,pCol) do
      lexGetLex1(S);
      traFORMAL(S,procId);
    end
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
  if okPARSE(S,pDup) then
    lexAccept1(S,lexPARSE,integer(pDup));
    idProcType:=traDefTYPE(S,"#proc_rez_type",false);
    lexTest(idProcType^.idtSize>8,S,_Неверный_тип_результата_функции[envER],nil);
  end
end
end traTITLE;

//----- Блок формальных параметров ------------

procedure traFORMAL(var S:recStream; procId:pID);
//FORMAL=["VAR"] DefVAR|TYPE
var fId:classID; fPar:pID;
begin
with S,procId^ do
  fId:=idvPAR;
  if okREZ(S,rVAR) then
    lexAccept1(S,lexREZ,integer(rVAR));
    fId:=idvVPAR
  end;
  if stLex<>lexTYPE then traDefVAR(S,fId,0,idProcPar,idProcMax,idProcList)
  else //имя типа
    fPar:=idInsert(tbMod[tekt].modTab,"#proc_param",fId,tabMod,tekt);
    fPar^.idVarType:=stLexID;
    fPar^.idVarAddr:=idProcPar;
    if idProcMax=maxPars
      then lexError(S,_Слишком_много_параметров[envER],nil)
      else listAdd(idProcList,fPar,idProcMax);
    end;
    lexAccept1(S,lexTYPE,0);
    if fId=idvVPAR
      then inc(idProcPar,4)
      else inc(idProcPar,fPar^.idVarType^.idtSize);
    end
  end
end
end traFORMAL;

//---------- Заголовок процедуры (проверка) --------------

procedure traTITLEtest(var S:recStream; procId:pID);
//TITLE="(" [FORMAL {";"|"," FORMAL}] ")" [":" Тип] ";"
var procType:pID; bitPascalNull:boolean;
begin
with S,procId^ do
  if idProcCla=nil
    then traCarParam:=0;
    else traCarParam:=1;
  end;
  bitPascalNull:=(traLANG=langPASCAL)and not okPARSE(S,pOvL) and
    ((idProcCla=nil)and(idProcMax=0)or(idProcCla<>nil)and(idProcMax=1));
  if not bitPascalNull then
    lexAccept1(S,lexPARSE,integer(pOvL));
    if not okPARSE(S,pOvR) then
      traFORMALtest(S,procId);
      while okPARSE(S,pSem) or okPARSE(S,pCol) do
        lexGetLex1(S);
        traFORMALtest(S,procId);
      end
    end;
    lexAccept1(S,lexPARSE,integer(pOvR));
  end;
  if okPARSE(S,pDup) then
    lexAccept1(S,lexPARSE,integer(pDup));
    procType:=traDefTYPE(S,"#proc_rez_type",false);
    traEqv(S,procType,idProcType,true);
  end;
  lexTest(traCarParam<>idProcMax,S,_Несоотвествие_количества_параметров[envER],nil);
end
end traTITLEtest;

//----- Блок формальных параметров (проверка) ------------

procedure traFORMALtest;
//FORMAL=["VAR"] Имя {"," Имя} ":" Тип
var fId:classID; fPar:pID; fBeg,i:integer; fType:pID;
begin
with S,procId^ do
  fBeg:=traCarParam;
  fId:=idvPAR;
  if okREZ(S,rVAR) then
    lexAccept1(S,lexREZ,integer(rVAR));
    fId:=idvVPAR
  end;
  if stLex<>lexTYPE then
    while stLex in [lexPAR,lexVPAR] do
      inc(traCarParam);
      lexAccept1(S,stLex,0);
      if traCarParam>idProcMax
        then lexError(S,_Несоотвествие_количества_параметров[envER],nil)
        else lexTest(lstrcmp(stLexOld,idProcList^[traCarParam]^.idName)<>0,S,_Несоотвествие_имени_параметра[envER],nil);
      end;
      if not okPARSE(S,pDup) then
        lexAccept1(S,lexPARSE,integer(pCol));
      end
    end;
    lexAccept1(S,lexPARSE,integer(pDup));
    fType:=traDefTYPE(S,"#var_type",false);
    for i:=fBeg+1 to traCarParam do
      traEqv(S,idProcList^[i]^.idVarType,fType,true);
      lexTest(idProcList^[i]^.idClass<>fId,S,_Несоотвествие_класса_параметра[envER],nil);
    end
  else
    inc(traCarParam);
    lexAccept1(S,lexTYPE,0)
  end
end
end traFORMALtest;

//===============================================
//                ТРАНСЛЯЦИЯ ОПЕРАТОРОВ 
//===============================================

//------- Добавить адрес call --------------

procedure traAddCorrCall(var S:recStream; var modif:arrModif; var topModif:integer; addAddr:address; addNew:integer);
begin
  if topModif=maxModif
    then lexError(S,_Слишком_много_вложенных_вызовов_функций[envER],nil)
    else inc(topModif);
  end;
  with modif[topModif] do
    modAddr:=addAddr;
    modNew:=addNew;
  end
end traAddCorrCall;

//------- Коррекция адреса call --------------

procedure traCorrCall(var S:recStream; var modif:arrModif; var topModif:integer; oldBeg,oldEnd,newBeg,begCode:integer);
var i,j,k:integer;
begin
//адреса из genCall
  with tbMod[tekt],genCall^ do
    for i:=1 to top do
    with arr[i] do
      if (callSou-begCode+1>=oldBeg+1)and(callSou-begCode+1<=oldEnd) then
        traAddCorrCall(S,modif,topModif,addr(callSou),callSou-oldBeg+newBeg)
      end
    end end
  end;
//адреса из traImport
  with tbMod[tekt] do
    for i:=1 to topImport do with genImport^[i] do
      for j:=1 to impTop do with impFuns^[j] do
        for k:=1 to funTop do
        if (funCALL^[k]+1>=oldBeg+1)and(funCALL^[k]+1<=oldEnd) then
          traAddCorrCall(S,modif,topModif,addr(funCALL^[k]),funCALL^[k]-oldBeg+newBeg)
        end end
      end end
    end end
  end;
//адреса из genVarCall
  with tbMod[tekt] do
    for i:=1 to topVarCall do with genVarCall^[i] do
    if cl<>vcData then
      if (track>=oldBeg+1)and(track<=oldEnd) then
        traAddCorrCall(S,modif,topModif,addr(track),track-oldBeg+newBeg);
      end
    end end end
  end
end traCorrCall;

//--------- Количество методов в классе ----------------

procedure traMetNum(cla:pID):integer;
var i:integer;
begin
  if cla=nil then return 0
  elsif cla^.idRecCla=cla^.idOwn then return cla^.idRecTop
  else return traMetNum(cla^.idRecCla)+cla^.idRecTop
  end
end traMetNum;

//--------- Номер метода в классе ----------------

procedure traMetNom(cla,own:pID):integer;
var i:integer;
begin
  with cla^ do
    for i:=1 to idRecTop do
      if idRecMet^[i]=own then
      if idRecCla=idOwn
        then return i
        else return traMetNum(idRecCla)+i
      end end
    end;
    mbS("System error in traMetNom");
    return 0
  end
end traMetNom;

//--------- Соответствие типов ----------------

procedure traEqv(var S:recStream; e1,e2:pID; eErr:boolean):boolean;
var eRes:boolean; str:string[maxText];
begin
  eRes:=(e1<>nil)and(e2<>nil)and
        ((e1=e2)or

        (e1^.idClass=idtBAS)and((e1^.idBasNom=typePSTR)or(e1^.idBasNom=typePOINT))and
        (e2^.idClass=idtBAS)and((e2^.idBasNom=typePSTR)or(e2^.idBasNom=typePOINT))or

        (e1^.idClass=idtBAS)and((e1^.idBasNom=typeBYTE)or(e1^.idBasNom=typeWORD)or(e1^.idBasNom=typeINT)or(e1^.idBasNom=typeDWORD))and
        (e2^.idClass=idtBAS)and((e2^.idBasNom=typeBYTE)or(e2^.idBasNom=typeWORD)or(e2^.idBasNom=typeINT)or(e2^.idBasNom=typeDWORD))or

        (e1^.idClass=idtBAS)and(e1^.idBasNom=typeCHAR)and(e2^.idClass=idtBAS)and(e2^.idBasNom=typeCHAR)or
        (e1^.idClass=idtBAS)and(e1^.idBasNom=typeBOOL)and(e2^.idClass=idtBAS)and(e2^.idBasNom=typeBOOL)or
        (e1^.idClass=idtBAS)and(e1^.idBasNom=typeREAL32)and(e2^.idClass=idtBAS)and(e2^.idBasNom=typeREAL32)or
        (e1^.idClass=idtBAS)and(e1^.idBasNom=typeREAL)and(e2^.idClass=idtBAS)and(e2^.idBasNom=typeREAL)or

        (e1^.idClass=idtPOI)and(e2^.idClass=idtBAS)and(e2^.idBasNom=typePOINT)or
        (e2^.idClass=idtPOI)and(e1^.idClass=idtBAS)and(e1^.idBasNom=typePOINT)or

        ((e1^.idClass=idtSET)or(e1^.idClass=idtBAS)and(e1^.idBasNom=typeSET))and
        ((e2^.idClass=idtSET)or(e2^.idClass=idtBAS)and(e2^.idBasNom=typeSET))or

//        (e1^.idClass=idtREC)and(e2^.idClass=idtREC)and(e1^.idRecCla<>nil)and(e2^.idRecCla<>nil)and
//        (genBaseCla(e1)=genBaseCla(e2))or

        (e1^.idClass=idtPOI)and(e2^.idClass=idtPOI)and
        (e1^.idPoiType^.idClass=idtREC)and(e2^.idPoiType^.idClass=idtREC)and
        (e1^.idPoiType^.idRecCla<>nil)and(e2^.idPoiType^.idRecCla<>nil)and
        (genBaseCla(e1^.idPoiType)=genBaseCla(e2^.idPoiType)) );

  if eErr and not eRes then
    str[0]:=char(0);
    if not((e1<>nil)and(e1^.idClass=idtPOI)and e1^.idPoiBitForward)and
       not((e2<>nil)and(e2^.idClass=idtPOI)and e2^.idPoiBitForward) then
      if (e1<>nil)and(e1^.idName<>nil)and(e1^.idName[0]<>'#') then
        lstrcat(str,e1^.idName);
      end;
      if (e1<>nil)and(e1^.idName<>nil)and(e1^.idName[0]<>'#')and
         (e2<>nil)and(e2^.idName<>nil)and(e2^.idName[0]<>'#') then
        lstrcat(str,__и_[envER]);
      end;
      if (e2<>nil)and(e2^.idName<>nil)and(e2^.idName[0]<>'#') then
        lstrcat(str,e2^.idName);
      end;
    end;
    lexError(S,_Несоответствие_типов__[envER],str);
  end;
  return eRes
end traEqv;

//------------ Код присваивания ----------------

procedure traGenEqv(S:recStream; eTypeVar,eTypeExp:pID);
begin
  case eTypeVar^.idtSize of
    1://pop ax; pop si; mov [si],al
      genPOP(S,rEAX,traBitAND);
      genR(S,cPOP,rESI);
      genMR(S,cMOV,regNULL,regNULL,rESI,rAL,0,0);|
    2://pop ax; pop si; (xor ah,ah;) mov [si],al; mov [si+1],ah
      genPOP(S,rEAX,traBitAND);
      genR(S,cPOP,rESI);
      if eTypeExp^.idtSize=1 then
        genRR(S,cXOR,rAH,rAH);
      end;
      genMR(S,cMOV,regNULL,regNULL,rESI,rAL,0,0);
      genMR(S,cMOV,regNULL,regNULL,rESI,rAH,1,0);|
    4://pop ax; pop si; mov [si],ax
      genPOP(S,rEAX,traBitAND);
      genR(S,cPOP,rESI);
      genMR(S,cMOV,regNULL,regNULL,rESI,rEAX,0,0);|
    8://pop ax; pop dx; pop si; mov [si+4],dx; mov [si],ax
      genPOP(S,rEAX,traBitAND);
      genR(S,cPOP,rEDX);
      genR(S,cPOP,rESI);
      genMR(S,cMOV,regNULL,regNULL,rESI,rEDX,4,0);
      genMR(S,cMOV,regNULL,regNULL,rESI,rEAX,0,0);|
  else with eTypeVar^ do
//   mov bx,di;
    genRR(S,cMOV,rEBX,rEDI);
//   mov si,sp; mov di,[si+_tSize align 4]
    genRR(S,cMOV,rESI,rESP);
    genMR(S,cMOV,regNULL,regNULL,rESI,rEDI,genAlign(idtSize,4),1);
//   mov cx,_tSize; rep movsb; add sp,_tSize align 4+4
    genRD(S,cMOV,rECX,idtSize);
    genGen(S,cREP,1); genGen(S,cMOVS,1);
    genRD(S,cADD,rESP,genAlign(idtSize,4)+4);
//   mov di,bx;
    genRR(S,cMOV,rEDI,rEBX);
  end end
end traGenEqv;

//------------ Присваивание ----------------

procedure traEQUAL(var S:recStream);
//EQUAL=VARIABLE ":=" EXPRESSION
var eTypeVar,eTypeExp:pID;
begin
with S do
  eTypeVar:=traVARIABLE(S,false,false,true);
  if eTypeVar^.idClass<>idPROC then
    lexAccept1(S,lexPARSE,integer(pDupEqv));
    traBitAND:=false;
    eTypeExp:=traEXPRESSION(S);
    traEqv(S,eTypeVar,eTypeExp,true);
    traGenEqv(S,eTypeVar,eTypeExp);
  end;
end
end traEQUAL;

//------------ Вызов процедуры ----------------

procedure traCALL(var S:recStream; bitStat:boolean; cProc:pID):pID;
//CALL=Имя "(" [EXPRESSION {"," EXPRESSION}] ")"
var cFact:pID; i,j:integer; str:string[maxText]; pl:pointer to integer;
    cPars:pointer to recPars; cCode:pointer to arrCode; cTop:integer;
    modif:pointer to arrModif; topModif:integer;
    oldStack:integer; bitPoint,bitPascalNull:boolean; siz:cardinal;
    begSaveWith,endSaveWith:integer; bufWith:pstr;
begin
with S do
  if cProc=nil then
    cProc:=stLexID;
    lexAccept1(S,lexPROC,0);
  end;
  oldStack:=genStack;
if not stErr then
with cProc^ do
  lexTest((traCarProc<>nil)and(traCarProc^.idProcCla<>nil)and
    (idProcCla<>nil)and(idPro=proPRIVATE)and(traCarProc^.idProcCla<>idProcCla),S,
    _Нарушение_прав_доступа[envER],nil);
  modif:=memAlloc(sizeof(arrModif));
  topModif:=0;
  bitPascalNull:=(traLANG=langPASCAL)and not okPARSE(S,pOvL) and
    ((idProcCla=nil)and(idProcMax=0)or(idProcCla<>nil)and(idProcMax=1));
  if not bitPascalNull then
    lexAccept1(S,lexPARSE,integer(pOvL));
  end;
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
    if idProcList^[i]^.idClass=idvVPAR then cFact:=traVARIABLE(S,false,true,false);
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
        if traLastLoad=-1 then lexError(S,_Системная_в_traCALL[envER],nil)
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
  if not bitPascalNull then
    lexAccept1(S,lexPARSE,integer(pOvR));
  end;
//обратный порядок параметров
  with tbMod[tekt] do
  if idProcMax>0 then
    cCode:=memAlloc(cPars^.arrPars[idProcMax].parEnd-cPars^.arrPars[1].parBeg);
    cTop:=0;
    for i:=idProcMax downto 1 do
    with cPars^.arrPars[i] do
//    перекачка кода параметра
      if (i=1)and(idProcCla<>nil)
        then traCorrCall(S,modif^,topModif,parBeg-(endSaveWith-begSaveWith),parEnd-(endSaveWith-begSaveWith),cPars^.arrPars[1].parBeg+cTop,0)
        else traCorrCall(S,modif^,topModif,parBeg,parEnd,cPars^.arrPars[1].parBeg+cTop,0)
      end;
      for j:=parBeg+1 to parEnd do
        inc(cTop);
        cCode^[cTop]:=genCode^[j];
      end
    end end;
    for i:=1 to topModif do  with modif^[i] do
      modAddr^:=modNew;
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
//  push dx; push ax; для функций
  genStack:=oldStack;
  if (idProcType<>nil) and not bitStat then
    lexTest(idProcType^.idtSize>8,S,_Неверный_тип_результата_функции[envER],nil);
    if idProcType^.idtSize>4 then
      genR(S,cPUSH,rEDX);
    end;
    genR(S,cPUSH,rEAX);
  end;
  memFree(modif);
  return idProcType
end end end
end traCALL;

//---------------- Возврат --------------------

procedure traRETURN(var S:recStream);
//RETURN [EXPRESSION]
var cRes:pID;
begin
if traCarProc=nil then return end;
with S,traCarProc^ do
  lexAccept1(S,lexREZ,integer(rRETURN));
  if idProcType<>nil then
    traBitAND:=false;
    cRes:=traEXPRESSION(S);
    traEqv(S,idProcType,cRes,true);
    lexTest(idProcType^.idtSize>8,S,_Неверный_тип_результата_функции[envER],nil);
//pop ax
    genPOP(S,rEAX,traBitAND);
//and ax,?????? для 1-3 байт
    with idProcType^ do
    if idtSize=1 then genRD(S,cAND,rEAX,0x000000FF)
    elsif idtSize=2 then genRD(S,cAND,rEAX,0x0000FFFF)
    elsif idtSize=3 then genRD(S,cAND,rEAX,0x00FFFFFF)
    end end;
//pop dx
    if idProcType^.idtSize>4 then
      genR(S,cPOP,rEDX);
    end;
//and dx,?????? для 5-7 байт
    with idProcType^ do
    if idtSize=5 then genRD(S,cAND,rEDX,0x000000FF)
    elsif idtSize=6 then genRD(S,cAND,rEDX,0x0000FFFF)
    elsif idtSize=7 then genRD(S,cAND,rEDX,0x00FFFFFF)
    end end
  end;
//mov si,[bp-_Память-4]; mov bx,[bp-_Память-8]; leave; retf _ПамятьПар
  genMR(S,cMOV,regNULL,rEBP,regNULL,rESI,-genAlign(idProcLock,4)-4,1);
  genMR(S,cMOV,regNULL,rEBP,regNULL,rEBX,-genAlign(idProcLock,4)-8,1);
  genGen(S,cLEAVE,0);
  genD(S,cRET,idProcPar);
end
end traRETURN;

//----------- Условный оператор ---------------

procedure traIF(var S:recStream);
//"IF" EXPRESSION THEN ListSTAT
//{"ELSIF" EXPRESSION THEN ListSTAT}
//["ELSE" ListSTAT] "END"
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
//  {pop ax; or ax,ax; je _ifEndThen}
    genPOP(S,rEAX,traBitAND);
    genRR(S,cOR,rEAX,rEAX);
    ifEndThen:=topCode;
    genGen(S,cJE,0);
    lexAccept1(S,lexREZ,integer(rTHEN));
    stepAdd(S,tekt,stepVarIF);
    traListSTAT(S);
//  {jmp _ifEnd; _ifEndThen:}
    genAddJamp(S,ifEnd^,topCode,cJMP);
    genGen(S,cJMP,0);
    genSetJamp(S,ifEndThen,topCode,cJE)
  end;
  if okREZ(S,rELSE) then
    lexAccept1(S,lexREZ,integer(rELSE));
    stepAdd(S,tekt,stepVarIF);
    traListSTAT(S);
  end;
  lexAccept1(S,lexREZ,integer(rEND));
  genSetJamps(S,ifEnd^,topCode);
  memFree(ifEnd);
end
end traIF;

//------------- Селектор выбора ---------------

procedure traSELECT(var S:recStream; sType:pID);
//{Const [".." Const] ","}
var caseBeg:pointer to lstJamp; bitMin:boolean;
begin
with S,sType^,tbMod[tekt] do
  caseBeg:=memAlloc(sizeof(lstJamp));
  caseBeg^.top:=0;
  while (stLex=lexCHAR)or(stLex=lexINT)or(stLex=lexSCAL)or(stLex=lexFALSE)or(stLex=lexTRUE)or okPARSE(S,pMin) do
    if (idClass=idtSCAL)and((stLex<>lexSCAL)or(stLexID^.idScalType<>sType)) then
      lexError(S,_Недопустимая_константа[envER],nil);
    end;
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
//jae next1; jmp next2; next1:cmp ax,_wEval; jbe _caseBeg; next2:
      genGen(S,cJAE,5);
      genGen(S,cJMP,12);
      genRD(S,cCMP,rEAX,stLexInt);
      genAddJamp(S,caseBeg^,topCode,cJBE);
      genGen(S,cJBE,0);
      lexGetLex1(S);
    end;
    if not okPARSE(S,pDup) then
      lexAccept1(S,lexPARSE,integer(pCol));
    end;
    genGen(S,cJMP,0);
    genSetJamps(S,caseBeg^,topCode);
  end;
  memFree(caseBeg);
end
end traSELECT;

//------------- Оператор выбора ---------------

procedure traCASE(var S:recStream);
//"CASE" EXPRESSION "OF" {SELECT ":" ListSTAT "|"} ["ELSE" ListSTAT] "END"
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
    traListSTAT(S);
    lexBitConst:=true;
    lexAccept1(S,lexPARSE,integer(pVer));
    genAddJamp(S,caseEnd^,topCode,cJMP);
    genGen(S,cJMP,0);
    genSetJamp(S,caseEndSel,topCode,cJMP);
  end;
  lexBitConst:=false;
  if okREZ(S,rELSE) then
    lexAccept1(S,lexREZ,integer(rELSE));
    stepAdd(S,tekt,stepVarCASE);
    traListSTAT(S);
  end;
  lexAccept1(S,lexREZ,integer(rEND));
  genSetJamps(S,caseEnd^,topCode);
  genR(S,cPOP,rEAX);
  memFree(caseEnd);
end
end traCASE;

//-------------- Цикл WHILE -------------------

procedure traWHILE(var S:recStream);
//"WHILE" EXPRESSION "DO" ListSTAT "END"
var whileCond:pID; labBeg,jmpEnd:integer;
begin
with S,tbMod[tekt] do
  lexAccept1(S,lexREZ,integer(rWHILE));
  labBeg:=topCode;
  traBitAND:=false;
  whileCond:=traEXPRESSION(S);
  traEqv(S,idTYPE[typeBOOL],whileCond,true);
//  {pop ax; or ax,ax; je _whileEnd}
  genPOP(S,rEAX,traBitAND);
  genRR(S,cOR,rEAX,rEAX);
  jmpEnd:=topCode;
  genGen(S,cJE,0);
  lexAccept1(S,lexREZ,integer(rDO));
  stepAdd(S,tekt,stepBegWHILE);
  traListSTAT(S);
  stepAdd(S,tekt,stepModWHILE);
  lexAccept1(S,lexREZ,integer(rEND));
//  {jmp _whileBeg; _whileEnd:}
  genGen(S,cJMP,0);
  genSetJamp(S,topCode-5,labBeg,cJMP);
  genSetJamp(S,jmpEnd,topCode,cJE);
end
end traWHILE;

//-------------- Цикл REPEAT ------------------

procedure traREPEAT(var S:recStream);
//"REPEAT" ListSTAT "UNTIL" EXPRESSION
var repCond:pID; labBeg:integer;
begin
with S,tbMod[tekt] do
  lexAccept1(S,lexREZ,integer(rREPEAT));
  labBeg:=topCode;
  traListSTAT(S);
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
end traREPEAT;

//------------ Тест границы FOR ---------------

procedure traTEST(var S:recStream; cla:classFor; modif:classModif):integer;
var jmpEnd:integer;
begin
//pop ax; pop si
  genR(S,cPOP,rEAX);
  genR(S,cPOP,rESI);
//cmp [si],ax(al)
  case cla of
    forBYTE:genMR(S,cCMP,regNULL,regNULL,rESI,rAL,0,0);|
    forINT:genMR(S,cCMP,regNULL,regNULL,rESI,rEAX,0,0);|
    forDWORD:genMR(S,cCMP,regNULL,regNULL,rESI,rEAX,0,0);|
  end;
//jg/jl(ja/jb)
  jmpEnd:=tbMod[tekt].topCode;
  case cla of
    forBYTE:case modif of
      modifTO:genGen(S,cJA,0);|
      modifDOWNTO:genGen(S,cJB,0);|
      modifTONE:genGen(S,cJAE,0);|
      modifDOWNTONE:genGen(S,cJBE,0);|
    end;|
    forINT:case modif of
      modifTO:genGen(S,cJG,0);|
      modifDOWNTO:genGen(S,cJL,0);|
      modifTONE:genGen(S,cJGE,0);|
      modifDOWNTONE:genGen(S,cJLE,0);|
    end;|
    forDWORD:case modif of
      modifTO:genGen(S,cJA,0);|
      modifDOWNTO:genGen(S,cJB,0);|
      modifTONE:genGen(S,cJAE,0);|
      modifDOWNTONE:genGen(S,cJBE,0);|
    end;|
  end;
//push si; push ax
  genR(S,cPUSH,rESI);
  genR(S,cPUSH,rEAX);
  return jmpEnd
end traTEST;

//------------ Модификация FOR ----------------

procedure traMODIF(var S:recStream; cla:classFor; modif:classModif; forType:pID; labBeg,jmpEnd:cardinal);
var jmpFin:cardinal;
begin
if not S.stErr then
//pop ax; pop si
  genR(S,cPOP,rEAX);
  genR(S,cPOP,rESI);
  if (modif=modifTO)or(modif=modifDOWNTO) then
//cmp ax/al,[si]
    case forType^.idtSize of
      1:genMR(S,cCMP,regNULL,regNULL,rESI,rAL,0,0);|
      4:genMR(S,cCMP,regNULL,regNULL,rESI,rEAX,0,0);|
    end;
//je _forFin
    jmpFin:=tbMod[tekt].topCode;
    genGen(S,cJE,0);
  end;
//inc/dec [si]
  case cla of
    forBYTE:case modif of
      modifTO,modifTONE:genM(S,cINC,regNULL,regNULL,rESI,0,1);|
      modifDOWNTO,modifDOWNTONE:genM(S,cDEC,regNULL,regNULL,rESI,0,1);|
    end;|
    forINT,forDWORD:case modif of
      modifTO,modifTONE:genM(S,cINC,regNULL,regNULL,rESI,0,4);|
      modifDOWNTO,modifDOWNTONE:genM(S,cDEC,regNULL,regNULL,rESI,0,4);|
    end;|
  end;
  if (modif=modifTONE)or(modif=modifDOWNTONE) then
//cmp ax/al,[si]
    case forType^.idtSize of
      1:genMR(S,cCMP,regNULL,regNULL,rESI,rAL,0,0);|
      4:genMR(S,cCMP,regNULL,regNULL,rESI,rEAX,0,0);|
    end;
//je _forFin
    jmpFin:=tbMod[tekt].topCode;
    genGen(S,cJE,0);
  end;
//push esi; push eax
  genR(S,cPUSH,rESI);
  genR(S,cPUSH,rEAX);
//jmp _forBeg
  genGen(S,cJMP,0);
  genSetJamp(S,tbMod[tekt].topCode-5,labBeg,cJMP);
//_forFin:_forEnd:
  genSetJamp(S,jmpFin,tbMod[tekt].topCode,cJE);
  genSetJamp(S,jmpEnd,tbMod[tekt].topCode,cJG);
end
end traMODIF;

//---------------- Цикл FOR -------------------

procedure traFOR(var S:recStream);
//"FOR" VARIABLE ":=" EXPRESSION "TO"|"DOWNTO" ["STRONG"] EXPRESSION ListSTAT "END"
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
  traListSTAT(S);
  stepAdd(S,tekt,stepModFOR);
  lexAccept1(S,lexREZ,integer(rEND));
  traMODIF(S,Class,modif,forType,labBeg,jmpEnd);
end
end traFOR;

//-------- Оператор ассемблера ----------------

procedure traASM(var S:recStream);
//"ASM" Инструкции "END"
begin
with S do
  lexAccept1(S,lexREZ,integer(rASM));
  asmInitial();
  asmAssembly(S);
  asmDestroy();
  lexAccept1(S,lexREZ,integer(rEND));
end
end traASM;

//---------- Переменная WITH ------------------

procedure traVarWITH(var S:recStream);
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
end traVarWITH;

//---------- Оператор WITH --------------------

procedure traWITH(var S:recStream);
//"WITH" Переменная {"," Переменная} "DO" Операторы "END"
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
  traListSTAT(S);
  lexAccept1(S,lexREZ,integer(rEND));
  topWith:=oldTop;
end
end traWITH;

//---------- Оператор FROM --------------------

procedure traFROM(var S:recStream);
//"FROM" ИмяМодуля
begin
with S do
  lexAccept1(S,lexREZ,integer(rFROM));
  if not traBitDEF then
    lexError(S,_Директива_FROM_может_быть_только_в_def_модуле[envER],nil);
  end;
  if not (stLex in setID) then
    lexError(S,_Ожидалось_имя_DLL[envER],nil);
  end;
  lstrcpy(traFromDLL,stLexStr);
  if stLex<>lexSTR then
    lstrcat(traFromDLL,".dll");
  end;
  lexAccept1(S,stLex,0);
  lexAccept1(S,lexPARSE,ord(pSem));
end
end traFROM;

//-------- Операторы INC и DEC ----------------

procedure traINCDEC(var S:recStream);
//"INC"|"DEC" "(" Переменная ["," Выражение] ")"
var bitINC:boolean; varType,expType:pID; comm:classCommand;
begin
with S do
  bitINC:=(classREZ(stLexInt)=rINC);
  lexAccept1(S,lexREZ,stLexInt);
  lexAccept1(S,lexPARSE,integer(pOvL));
  varType:=traVARIABLE(S,false,true,false);
  with varType^ do
  if not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeCHAR,typeWORD,typeINT,typeDWORD])or
           (idClass=idtSCAL)) then
    lexError(S,_Неверный_тип_переменной[envER],nil);
  end end;
  if bitINC
    then comm:=cADD
    else comm:=cSUB
  end;
  if okPARSE(S,pCol) then
    lexAccept1(S,lexPARSE,integer(pCol));
    traBitAND:=false;
    expType:=traEXPRESSION(S);
    with expType^ do
    if not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeCHAR,typeWORD,typeINT,typeDWORD])or
             (idClass=idtSCAL)) then
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
  lexAccept1(S,lexPARSE,integer(pOvR));
end
end traINCDEC;

//-------- Оператор NEW ----------------

procedure traNEW(var S:recStream);
//"NEW" "(" Переменная ")"
var varType:pID;
begin
with S do
  lexAccept1(S,lexREZ,ord(rNEW));
  lexAccept1(S,lexPARSE,integer(pOvL));
  varType:=traVARIABLE(S,false,true,false);
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
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
end
end traNEW;

//----------- Список операторов ---------------

procedure traListSTAT(var S:recStream);
//ListSTAT={STATEMENT ";"}
var r:classREZ;
begin
with S do
  if stLex=lexREZ then r:=classREZ(stLexInt) else r:=rezNULL end;
  while 
    ((stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC)or(stLex=lexVPAR)or
    (stLex=lexFIELD)or(stLex=lexSTRU)or(stLex=lexPROC)or
    (stLex=lexREZ)and(r in [rRETURN,rIF,rCASE,rWHILE,rREPEAT,rFOR,rASM,rWITH,rINC,rDEC,rNEW]))and 
    not stErr do
    stepAdd(S,tekt,stepSimple);
    with tbMod[tekt],genStep^[topGenStep] do
    case stLex of
      lexVAR,lexPAR,lexLOC,lexVPAR,lexFIELD,lexSTRU:traEQUAL(S);|
      lexPROC:Class:=stepCALL; proc:=stLexID; traCALL(S,true,nil);|
      lexREZ:case classREZ(stLexInt) of
        rRETURN:Class:=stepRETURN; traRETURN(S);|
        rIF:Class:=stepIF; stepPush(Class,topGenStep); traIF(S); stepPop(); stepAdd(S,tekt,stepEndIF);|
        rCASE:Class:=stepCASE; stepPush(Class,topGenStep); traCASE(S); stepPop(); stepAdd(S,tekt,stepEndCASE);|
        rWHILE:Class:=stepWHILE; stepPush(Class,topGenStep); traWHILE(S); stepPop(); stepAdd(S,tekt,stepEndWHILE);|
        rREPEAT:Class:=stepREPEAT; stepPush(Class,topGenStep); traREPEAT(S); stepPop(); stepAdd(S,tekt,stepEndREPEAT);|
        rFOR:Class:=stepFOR; stepPush(Class,topGenStep); traFOR(S); stepPop(); stepAdd(S,tekt,stepEndFOR);|
        rASM:traASM(S);|
        rWITH:traWITH(S);|
        rINC:traINCDEC(S);|
        rDEC:traINCDEC(S);|
        rNEW:traNEW(S);|
      end;|
    end end;
    if not(okREZ(S,rEND)or okREZ(S,rELSIF)or okREZ(S,rELSE)or okREZ(S,rUNTIL)) then
      lexAccept1(S,lexPARSE,ord(pSem));
//  pVer отключен из-за соовпадения разделителя вариантов и
//  операции ИЛИ в константных выражениях
    end;
    if stLex=lexREZ then r:=classREZ(stLexInt) else r:=rezNULL end;
  end
end
end traListSTAT;

//===============================================
//                 ТРАНСЛЯЦИЯ ВЫРАЖЕНИЯ
//===============================================

//-------------- Проверка на тип множество -------------------

procedure traOkSET(typ:pID; bitInt:boolean):boolean;
begin
with typ^ do
  if bitInt 
    then return (idClass=idtBAS)and(idBasNom in [typeBYTE,typeCHAR,typeWORD,typeBOOL,typeINT,typeDWORD])or(idClass=idtSCAL)
    else return (idClass=idtSET)or(idClass=idtBAS)and(idBasNom=typeSET)
  end
end
end traOkSET;

//-------------- Переменная -------------------

procedure traVARIABLE(var S:recStream; bitOnlyName,bitOnlyVar,bitStatMetod:boolean):pID;
//VARIABLE={{"*"} "("} {"*"} Имя { "^" | "." Имя | "->" | ")" | "[" EXPRESSION "]" }
var varType,varInd,varField,varMetod:pID; varTrack,i,j:integer; str:string[maxText];
  varPoiC:array[0..maxPoiC]of integer; topPoiC,carPoiC:integer;
begin
with S do
  if traStackTop=maxStackMet then mbS(_Слишком_много_вложенных_переменных[envER])
  else
    inc(traStackTop);
    traStackMet[traStackTop]:=tbMod[tekt].topCode;
  end;
//разименования указателей Си
  topPoiC:=0;
  varPoiC[0]:=0;
  while okPARSE(S,pMul) do
    varPoiC[0]:=0;
    while okPARSE(S,pMul) do
      inc(varPoiC[0]);
      lexAccept1(S,lexPARSE,integer(pMul));
    end;
    if okPARSE(S,pOvL) then
    if topPoiC=maxPoiC then lexError(S,_Слишком_много_указателей[envER],nil); lexGetLex1(S)
    else
      inc(topPoiC);
      varPoiC[topPoiC]:=varPoiC[0];
      varPoiC[0]:=0;
      lexAccept1(S,lexPARSE,integer(pOvL));
    end end;
  end;
//имя переменной
  if not ((stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC)or(stLex=lexVPAR)or(stLex=lexFIELD)or(stLex=lexSTRU)) then
    lexError(S,_Ожидалась_переменная[envER],nil);
    return idTYPE[typeBYTE];
  end;
  if stLex=lexSTRU
    then varType:=stLexID^.idStruType
    else varType:=stLexID^.idVarType
  end;
  with stLexID^ do
  case stLex of
    lexVAR:varTrack:=idVarAddr;|
    lexPAR:varTrack:=idVarAddr;|
    lexLOC:varTrack:=idVarAddr;|
    lexVPAR:varTrack:=idVarAddr;|
    lexFIELD:varTrack:=idVarAddr;|
    lexSTRU:varTrack:=genBASECODE+0x1000+stLexInt;|
  end end;
  case stLex of
    lexVAR:
//push _Track
      genD(S,cPUSH,genBASECODE+0x1000+varTrack);
      genAddVarCall(S,tekt,stLexID^.idNom,tbMod[tekt].topCode-3,vcCode,nil);|
    lexPAR,lexLOC:
//lea si,[bp+_Track]; push si
      genMR(S,cLEA,regNULL,rEBP,regNULL,rESI,varTrack,1);
      genR(S,cPUSH,rESI);|
    lexVPAR:
//push [bp+_Track]
      genM(S,cPUSH,regNULL,rEBP,regNULL,varTrack,4);|
    lexFIELD:
      lexTest((traCarProc<>nil)and(traCarProc^.idProcCla<>nil)and(stLexID^.idPro=proPRIVATE_IMP),S,
        _Нарушение_прав_доступа[envER],nil);
//mov ax,[401000+with]
      genMR(S,cMOV,regNULL,regNULL,regNULL,rEAX,genBASECODE+0x1000+(withGlo-1)*4,1);
//add ax,смещение; push ax
      genRD(S,cADD,rEAX,varTrack);
      genR(S,cPUSH,rEAX);|
    lexSTRU:
//push _Addr
      genD(S,cPUSH,varTrack);
      genAddVarCall(S,tekt,stLexID^.idNom,tbMod[tekt].topCode-3,vcCode,nil);|
  else lexError(S,_Ожидалась_переменная[envER],nil)
  end;
  lexGetLex1(S);
//только имя
  if bitOnlyName then return varType end;

//разименования Си
  for i:=1 to varPoiC[0] do
  if varType^.idClass<>idtPOI then lexError(S,_Ожидался_тип_указатель[envER],nil)
  else
    varType:=varType^.idPoiType;
//pop si; push [si]
    genPOP(S,rESI,traBitAND);
    genM(S,cPUSH,regNULL,regNULL,rESI,0,4);
  end end;

//хвост переменной
  while (okPARSE(S,pUg)or okPARSE(S,pPoi)or okPARSE(S,pSqL)or okPARSE(S,pMinUgR)or
    okPARSE(S,pOvR)and(topPoiC>0))and(varType^.idClass<>idPROC)and not stErr do
  case classPARSE(stLexInt) of
    pUg:if varType^.idClass<>idtPOI then lexError(S,_Ожидался_тип_указатель[envER],nil)
    elsif varType^.idPoiBitForward then lexError(S,_Неопределенный_тип_указатель[envER],nil)
    else
      varType:=varType^.idPoiType;
      lexAccept1(S,lexPARSE,integer(pUg));
//pop si; push [si]
      genPOP(S,rESI,traBitAND);
      genM(S,cPUSH,regNULL,regNULL,rESI,0,4);
    end;|
    pPoi,pMinUgR:
      if okPARSE(S,pMinUgR)or(varType^.idClass=idtPOI)and(varType^.idPoiType^.idClass=idtREC) then
        if okPARSE(S,pMinUgR) and(varType^.idClass<>idtPOI) then lexError(S,_Ожидался_тип_указатель[envER],nil)
        else
          varType:=varType^.idPoiType;
          if okPARSE(S,pMinUgR)
            then lexAccept1(S,lexPARSE,integer(pMinUgR));
            else lexAccept1(S,lexPARSE,integer(pPoi));
          end;
//pop si; push [si]
          genPOP(S,rESI,traBitAND);
          genM(S,cPUSH,regNULL,regNULL,rESI,0,4);
        end
      else lexAccept1(S,lexPARSE,integer(pPoi));
      end;
      if varType^.idClass<>idtREC then lexError(S,_Ожидался_тип_запись[envER],nil)
      else
        if stLex in setID then
        with varType^ do
          lstrcpy(str,idName);
          lstrcatc(str,'.');
          lstrcat(str,stLexStr);
          varField:=listFind(idRecList,idRecMax,str);
          if varField<>nil then
            lexTest((traCarProc<>nil)and(traCarProc^.idProcCla<>nil)and
              (varField^.idPro=proPRIVATE_IMP),S,
              _Нарушение_прав_доступа[envER],nil);
            varType:=varField^.idVarType;
//pop ax; add ax,_pField; push ax
            genPOP(S,rEAX,traBitAND);
            genRD(S,cADD,rEAX,varField^.idVarAddr);
            genR(S,cPUSH,rEAX);
            lexAccept1(S,stLex,0);
          else
            varMetod:=genFindMetod(varType,stLexStr);
            if varMetod<>nil then
              lexGetLex1(S);
              traCALL(S,bitStatMetod,varMetod);
              varType:=varMetod;
            else lexError(S,_Ожидалось_имя_поля_[envER],stLexStr)
            end
          end;
        end
        else lexError(S,_Ожидалось_имя_поля[envER],nil)
        end;
      end;|
    pSqL:if not ((varType^.idClass=idtARR)or((varType^.idClass=idtBAS)and(varType^.idBasNom=typePSTR))) then lexError(S,_Ожидался_массив[envER],nil)
    elsif varType^.idClass=idtARR then //массив
      lexAccept1(S,lexPARSE,integer(pSqL));
      varInd:=traEXPRESSION(S);
      traEqv(S,varInd,varType^.idArrInd,true);
      lexAccept1(S,lexPARSE,integer(pSqR));
//pop ax; sub ax,_loArr; mov bx,_tSize; mul bx; pop bx; add ax,bx; push ax
      genR (S,cPOP,rEAX);
      if varType^.extArrBeg<>0 then
        genRD(S,cSUB,rEAX,varType^.extArrBeg);
      end;
      if varType^.idArrItem^.idtSize<>1 then
        genRD(S,cMOV,rEBX,varType^.idArrItem^.idtSize);
        genR(S,cMUL,rEBX);
      end;
      genR(S,cPOP,rEBX);
      genRR(S,cADD,rEAX,rEBX);
      genR(S,cPUSH,rEAX);
      varType:=varType^.idArrItem;
    else //PSTR
      lexAccept1(S,lexPARSE,integer(pSqL));
      varInd:=traEXPRESSION(S);
      traEqv(S,varInd,idTYPE[typeDWORD],true);
      lexAccept1(S,lexPARSE,integer(pSqR));
//pop bx; pop si; push [si]; pop ax; add ax,bx; push ax
      genR(S,cPOP,rEBX);
      genR(S,cPOP,rESI);
      genM(S,cPUSH,regNULL,regNULL,rESI,0,4);
      genR (S,cPOP,rEAX);
      genRR(S,cADD,rEAX,rEBX);
      genR (S,cPUSH,rEAX);
      varType:=idTYPE[typeCHAR];
    end;|
    pOvR://разименования Си
      for i:=1 to varPoiC[topPoiC] do
      if varType^.idClass<>idtPOI then lexError(S,_Ожидался_тип_указатель[envER],nil)
      else
        varType:=varType^.idPoiType;
//pop si; push [si]
        genPOP(S,rESI,traBitAND);
        genM(S,cPUSH,regNULL,regNULL,rESI,0,4);
      end end;
      dec(topPoiC);|
  end end;
  if topPoiC>0 then
    lexAccept1(S,lexPARSE,integer(pOvR))
  end;
  if traStackTop=0
    then mbS("System error in traVARIABLE")
    else dec(traStackTop);
  end;
  lexTest(bitOnlyVar and(varType^.idClass=idPROC),S,_Недопустимая_переменная[envER],nil);
  return varType
end
end traVARIABLE;

//------ Загрузка значения переменной ---------

procedure traLOAD(var S:recStream; uniType:pID);
begin
  traLastLoad:=tbMod[tekt].topCode;
  if uniType=nil then mbS(_Системная_ошибка_в_traLOAD[envER]) end;
  if (uniType^.idtSize<=4)or(uniType^.idtSize=8) then
//  pop si
    genPOP(S,rESI,traBitAND);
    if traLastLoad>tbMod[tekt].topCode then
      traBitOptim:=true;
      traLastLoad:=tbMod[tekt].topCode;
    end
  end;
  case uniType^.idtSize of
    1,2,3:// xor ax,ax; mov al,[si]; push ax
      genRR(S,cXOR,rEAX,rEAX);
      case uniType^.idtSize of
        1:genMR(S,cMOV,regNULL,regNULL,rESI,rAL,0,1);|
        2:genMR(S,cMOV,regNULL,regNULL,rESI,rAL,0,1); genMR(S,cMOV,regNULL,regNULL,rESI,rAH,1,1);|
        3:// mov al,[si+1]; mov ah,[si+2]; rol ax,8; mov al,[si];
          genMR(S,cMOV,regNULL,regNULL,rESI,rAL,1,1);
          genMR(S,cMOV,regNULL,regNULL,rESI,rAH,2,1);
          genRD(S,cROL,rEAX,8);
          genMR(S,cMOV,regNULL,regNULL,rESI,rAL,0,1);|
      end;
      genR(S,cPUSH,rEAX);|
    4:genM(S,cPUSH,regNULL,regNULL,rESI,0,4);| //push [si]
    8:// push [si+4]; push [si]
      genM(S,cPUSH,regNULL,regNULL,rESI,4,4);
      genM(S,cPUSH,regNULL,regNULL,rESI,0,4);|
  else with uniType^ do
//pop si;
    genPOP(S,rESI,traBitAND);
    if traLastLoad>tbMod[tekt].topCode then
      traBitOptim:=true;
      traLastLoad:=tbMod[tekt].topCode;
    end;
//mov bx,di;
    genRR(S,cMOV,rEBX,rEDI);
//mov di,sp; sub di,_tSize align 4
    genRR(S,cMOV,rEDI,rESP);
    genRD(S,cSUB,rEDI,genAlign(idtSize,4));
//mov cx,_tSize; sub sp,_tSize align 4;
//rep movsb;
    genRD(S,cMOV,rECX,idtSize);
    genRD(S,cSUB,rESP,genAlign(idtSize,4));
    genGen(S,cREP,1); genGen(S,cMOVS,1);
//mov di,bx;
    genRR(S,cMOV,rEDI,rEBX);
  end end
end traLOAD;

//-------------- Преобразования типов --------------------

procedure traMODTYPE(var S:recStream; uniType,uniExp:pID):pID;
begin
with S do
//int(real/real32)
  if (uniType^.idClass=idtBAS)and(uniType^.idBasNom=typeINT)and
     (uniExp^ .idClass=idtBAS)and(uniExp^ .idBasNom in [typeREAL32,typeREAL]) then 
//mov si,sp; wait; fld q/d [si]; {add sp,4}
    genRR(S,cMOV,rESI,rESP);
    genGen(S,cWAIT,0);
    case uniExp^.idBasNom of
      typeREAL32:genM(S,cFLD,regNULL,regNULL,rESI,0,4);|
      typeREAL:genM(S,cFLD,regNULL,regNULL,rESI,0,8); genRD(S,cADD,rESP,4);|
    end;    
//wait; fistp [si{+4}]
    case uniExp^.idBasNom of
      typeREAL32:genGen(S,cWAIT,0); genM(S,cFISTP,regNULL,regNULL,rESI,0,0);|
      typeREAL:genGen(S,cWAIT,0); genM(S,cFISTP,regNULL,regNULL,rESI,4,0);|
    end;
    uniExp:=uniType
//real/real32(int)
  elsif (uniType^.idClass=idtBAS)and(uniType^.idBasNom in [typeREAL32,typeREAL])and
    (uniExp^.idClass=idtBAS)and((uniExp^.idBasNom=typeINT)or(uniExp^.idBasNom=typeDWORD)) then
//mov si,sp; wait; fild [si]; {sub sp,4;} mov si,sp
    genRR(S,cMOV,rESI,rESP);
    genGen(S,cWAIT,0);
    genM(S,cFILD,regNULL,regNULL,rESI,0,0);
    if uniType^.idBasNom=typeREAL then
      genRD(S,cSUB,rESP,4);
    end;
    genRR(S,cMOV,rESI,rESP);
//wait; fstp q/d [si]
    genGen(S,cWAIT,0);
    case uniType^.idBasNom of
      typeREAL32:genM(S,cFSTP,regNULL,regNULL,rESI,0,4);|
      typeREAL:genM(S,cFSTP,regNULL,regNULL,rESI,0,8);|
    end;
    uniExp:=uniType
//real32(real)
  elsif (uniType^.idClass=idtBAS)and(uniType^.idBasNom=typeREAL32)and
     (uniExp^.idClass=idtBAS)and(uniExp^.idBasNom=typeREAL) then 
//mov si,sp; wait; fld q [si]; add sp,4
    genRR(S,cMOV,rESI,rESP);
    genGen(S,cWAIT,0);
    genM(S,cFLD,regNULL,regNULL,rESI,0,8);
    genRD(S,cADD,rESP,4);
//wait; fstp d [si+4]
    genGen(S,cWAIT,0); genM(S,cFSTP,regNULL,regNULL,rESI,4,4);
    uniExp:=uniType
//real(real32)
  elsif (uniType^.idClass=idtBAS)and(uniType^.idBasNom=typeREAL)and
    (uniExp^.idClass=idtBAS)and(uniExp^.idBasNom=typeREAL32) then
//mov si,sp; wait; fld d [si]; sub sp,4; mov si,sp
    genRR(S,cMOV,rESI,rESP);
    genGen(S,cWAIT,0);
    genM(S,cFLD,regNULL,regNULL,rESI,0,4);
    genRD(S,cSUB,rESP,4);
    genRR(S,cMOV,rESI,rESP);
//wait; fstp q [si]
    genGen(S,cWAIT,0);
    genM(S,cFSTP,regNULL,regNULL,rESI,0,8);
    uniExp:=uniType
  else with uniExp^ do
    lexTest(not ((uniType^.idtSize=idtSize)or(uniType^.idtSize<=4)and(idtSize<=4)),
      S,_Неверное_преобразование_типов[envER],nil)
  end end;
  return uniExp
end
end traMODTYPE;

//-------------- Первичное _переменная[envER]--------------------

procedure traVARLOAD(var S:recStream):pID;
var varType:pID;
begin
  with S do
    varType:=traVARIABLE(S,false,false,false);
    with varType^ do
    if idClass=idPROC then varType:=idProcType
    elsif not traBitLoadString and
          ((idClass=idtARR)and
           (idArrItem^.idClass=idtBAS)and
           (idArrItem^.idBasNom=typeCHAR)) then varType:=idTYPE[typePSTR]
    else traLOAD(S,varType);
    end end
   end;
   return varType;
 end traVARLOAD;

//-------------- Первичное --------------------

procedure traUNIT(var S:recStream):pID;
//UNIT=VARIABLE | CALL | "(" EXPRESSION ")" | CONST | TYPE | ADDR | SIZE | ABS
var uniType,uniExp:pID; rez:classREZ; oldBitAND:boolean; i:integer;
  trans:record case of |r:real; |l0,l1:integer; |s:setbyte; |l:array[0..7]of integer; end;
begin
with S do
  uniType:=idTYPE[typeBYTE];
  case stLex of
    lexVAR,lexPAR,lexLOC,lexVPAR,lexFIELD,lexSTRU:uniType:=traVARLOAD(S);|
    lexPROC:
      oldBitAND:=traBitAND;
      uniType:=traCALL(S,false,nil);
      traBitAND:=oldBitAND;
      if uniType=nil then
        lexError(S,_Функция_не_возвращает_значения[envER],nil);
        uniType:=idTYPE[typeBYTE]
      end;|
    lexPARSE:case classPARSE(stLexInt) of
      pMul:uniType:=traVARLOAD(S);|
      pOvL:
        lexAccept1(S,lexPARSE,integer(pOvL));
        if (traLANG=langC)and((stLex=lexTYPE)or okREZ(S,rVOID)or okREZ(S,rUNSIGNED)) then
        //преобразование типа Си
          if stLex=lexTYPE then //тип или char*
            uniType:=stLexID;
            lexAccept1(S,lexTYPE,0);
            if (uniType=idTYPE[typeCHAR])and okPARSE(S,pMul) then
              uniType:=idTYPE[typePSTR];
              lexAccept1(S,lexPARSE,integer(pMul));
            end
          elsif okREZ(S,rVOID) then //void*
            uniType:=idTYPE[typePOINT];
            lexAccept1(S,lexREZ,integer(rVOID));
            lexAccept1(S,lexPARSE,integer(pMul));
          elsif okREZ(S,rUNSIGNED) then //unsigned int
            uniType:=idTYPE[typeDWORD];
            lexAccept1(S,lexREZ,integer(rUNSIGNED));
            lexTest((stLex=lexTYPE)and(stLexID=idTYPE[typeINT]),S,_Ожидалось_int[envER],nil);
            lexAccept1(S,lexTYPE,0);
          end;
          lexAccept1(S,lexPARSE,integer(pOvR));
          if okPARSE(S,pOvL) then
            lexAccept1(S,lexPARSE,integer(pOvL));
            uniExp:=traEXPRESSION(S);
            lexAccept1(S,lexPARSE,integer(pOvR));
          else uniExp:=traEXPRESSION(S);
          end;
          uniExp:=traMODTYPE(S,uniType,uniExp);
        else //вложенное выражение
          uniType:=traEXPRESSION(S);
          lexAccept1(S,lexPARSE,integer(pOvR));
        end;|
      pSob: //адрес
        uniType:=idTYPE[typePOINT];
        lexAccept1(S,lexPARSE,integer(pSob));
        if okPARSE(S,pOvL) then
          lexAccept1(S,lexPARSE,integer(pOvL));
          traVARIABLE(S,false,true,false);
          lexAccept1(S,lexPARSE,integer(pOvR));
        elsif stLex=lexPROC then //процедура
// mov ax,[BaseOfCode]; add ax,_Addr; push ax
          genMR(S,cMOV,regNULL,regNULL,regNULL,rEAX,genBASECODE+genSize(exeOld,1)+44,1);
          genRD(S,cADD,rEAX,genBASECODE+stLexID^.idProcAddr);
          genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode-3,vcAddr,nil);
          genR(S,cPUSH,rEAX);
          lexAccept1(S,lexPROC,0);
        else traVARIABLE(S,true,true,false)
        end;|
      pSqL://константа-множество
        uniType:=idTYPE[typeSET];
        traSETCONST(S);
        //push _Val0 push _Val1 push _Val2 push _Val3 push _Val4 push _Val5 push _Val6 push _Val7
        trans.s:=stLexSet;
        for i:=7 downto 0 do
          genD(S,cPUSH,trans.l[i]);
        end;
        lexGetLex1(S);|
      else
        lexError(S,_Ожидалось_выражение[envER],nil);
        uniType:=idTYPE[typeBYTE]
      end;|
    lexCHAR://push _Val
      uniType:=idTYPE[typeCHAR];
      genD(S,cPUSH,stLexInt);
      lexAccept1(S,lexCHAR,0);|
    lexINT://push _Val
      uniType:=idTYPE[typeDWORD];
      genD(S,cPUSH,stLexInt);
      lexAccept1(S,lexINT,0);|
    lexREAL://push _hiVal; push _loVal
      uniType:=idTYPE[typeREAL];
      trans.r:=stLexReal;
      genD(S,cPUSH,trans.l1);
      genD(S,cPUSH,trans.l0);
      lexAccept1(S,lexREAL,0);|
    lexSTR://push _Addr
      uniType:=idTYPE[typePSTR];
      if stLexID=nil
        then stLexInt:=genPutStr(S,addr(stLexStr))
        else stLexInt:=stLexID^.idStrAddr;
      end;
      genD(S,cPUSH,genBASECODE+0x1000+stLexInt);
      if stLexID=nil
        then genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode-3,vcCode,nil);
        else genAddVarCall(S,tekt,stLexID^.idNom,tbMod[tekt].topCode-3,vcCode,nil);
      end;      
      lexAccept1(S,lexSTR,0);|
    lexNIL://push 0
      uniType:=idTYPE[typePOINT];
      genD(S,cPUSH,0);
      lexAccept1(S,lexNIL,0);|
    lexFALSE,lexTRUE://push _Val
      uniType:=idTYPE[typeBOOL];
      genD(S,cPUSH,stLexInt);
      lexAccept1(S,stLex,0);|
    lexSCAL://push _Val
      uniType:=stLexID^.idScalType;
      genD(S,cPUSH,stLexInt);
      lexAccept1(S,lexSCAL,0);|
    lexSET://push Val0 push Val1 push Val2 push Val3 push Val4 push Val5 push Val6 push Val7
      uniType:=idTYPE[typeSET];
      trans.s:=stLexSet;
      for i:=7 downto 0 do
        genD(S,cPUSH,trans.l[i]);
      end;
      lexAccept1(S,lexSET,0);|
    lexTYPE:
      uniType:=stLexID;
      lexAccept1(S,lexTYPE,0);
      if okPARSE(S,pFiL) then //структурная константа push _Addr
        with tbMod[tekt] do
          genD(S,cPUSH,genBASECODE+0x1000+topData);
          genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode-3,vcCode,nil);
        end;
        traLOAD(S,uniType);
        traSTRUCT(S,uniType);
      else //преобразование типа
        lexAccept1(S,lexPARSE,integer(pOvL));
        uniExp:=traEXPRESSION(S);
        lexAccept1(S,lexPARSE,integer(pOvR));
        uniExp:=traMODTYPE(S,uniType,uniExp);
      end;|
    lexREZ:case classREZ(stLexInt) of
      rSIZEOF:
        uniType:=idTYPE[typeDWORD];
        lexAccept1(S,lexREZ,integer(rSIZEOF));
        lexAccept1(S,lexPARSE,integer(pOvL));
        if stLexID=nil then lexError(S,_Ожидалось_имя_типа[envER],nil)
        else
          uniExp:=stLexID;
          lexAccept1(S,lexTYPE,0);
          lexAccept1(S,lexPARSE,integer(pOvR));
//push _Size
          genD(S,cPUSH,uniExp^.idtSize);
        end;|
      rADDR:
        uniType:=idTYPE[typePOINT];
        lexAccept1(S,lexREZ,integer(rADDR));
        lexAccept1(S,lexPARSE,integer(pOvL));
        case stLex of
          lexPROC://mov ax,[BaseOfCode]; add ax,_Addr; push ax
            genMR(S,cMOV,regNULL,regNULL,regNULL,rEAX,genBASECODE+genSize(exeOld,1)+44,1);
            genRD(S,cADD,rEAX,genBASECODE+stLexID^.idProcAddr);
            genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode-3,vcAddr,nil);
            genR(S,cPUSH,rEAX);
            lexAccept1(S,lexPROC,0);|
          else traVARIABLE(S,false,true,false)
        end;
        lexAccept1(S,lexPARSE,integer(pOvR));|
      rTRUNC:
        uniType:=idTYPE[typeREAL];
        lexAccept1(S,lexREZ,integer(rTRUNC));
        lexAccept1(S,lexPARSE,integer(pOvL));
        uniExp:=traEXPRESSION(S);
        lexAccept1(S,lexPARSE,integer(pOvR));
        with uniExp^ do
        if not((uniExp<>nil)and(idClass=idtBAS)and(idBasNom in [typeREAL32,typeREAL])) then
          lexError(S,_Ожидалось_вещественное_число[envER],nil)
        else
          genRR(S,cMOV,rEBX,rEDI);
//mov si,sp
          genRR(S,cMOV,rESI,rESP);
//push ax; mov di,sp; fstcw [di]
          genR(S,cPUSH,rEAX);
          genRR(S,cMOV,rEDI,rESP);
          genM(S,cFSTCW,regNULL,regNULL,rEDI,0,0);
//or [di],0x0C1F; fldcw [di]
          genMD(S,cOR,regNULL,regNULL,rEDI,0,0x0C1F,4);
          genM(S,cFLDCW,regNULL,regNULL,rEDI,0,0);
//wait; fld q/d [si]; wait; frndint; wait; fstp q/d [si]
          genGen(S,cWAIT,0);
          case uniExp^.idBasNom of
            typeREAL32:genM(S,cFLD,regNULL,regNULL,rESI,0,4);|
            typeREAL:genM(S,cFLD,regNULL,regNULL,rESI,0,8);|
          end;
          genGen(S,cWAIT,0); genGen(S,cFRNDINT,0);
          genGen(S,cWAIT,0);
          case uniExp^.idBasNom of
            typeREAL32:genM(S,cFSTP,regNULL,regNULL,rESI,0,4);|
            typeREAL:genM(S,cFSTP,regNULL,regNULL,rESI,0,8);|
          end;
//fstcw [di]
          genM(S,cFSTCW,regNULL,regNULL,rEDI,0,0);
//and [di],0xF3FF; fldcw [di]; pop ax; pop di
          genMD(S,cAND,regNULL,regNULL,rEDI,0,0xF3FF,4);
          genM(S,cFLDCW,regNULL,regNULL,rEDI,0,0);
          genR(S,cPOP,rEAX);
          genRR(S,cMOV,rEDI,rEBX);
        end end;|
      rLOBYTE,rLOWORD,rHIBYTE,rHIWORD:
        rez:=classREZ(stLexInt);
        lexAccept1(S,lexREZ,stLexInt);
        lexAccept1(S,lexPARSE,integer(pOvL));
        uniType:=traEXPRESSION(S);
        lexAccept1(S,lexPARSE,integer(pOvR));
        if uniType^.idtSize>4 then
          lexError(S,'Неверный тип выражения',nil);
        end;
        genPOP(S,rEAX,traBitAND);
        case rez of
          rLOWORD:genRD(S,cAND,rEAX,0x0000FFFF);|
          rHIWORD:genRD(S,cSHR,rEAX,16);|
          rLOBYTE:genRD(S,cAND,rEAX,0x000000FF);|
          rHIBYTE:genRD(S,cAND,rEAX,0x0000FF00); genRD(S,cSHR,rEAX,8);|
        end;
        genR(S,cPUSH,rEAX);
        uniType:=idTYPE[typeDWORD];|
      rORD:
        rez:=classREZ(stLexInt);
        lexAccept1(S,lexREZ,stLexInt);
        lexAccept1(S,lexPARSE,integer(pOvL));
        uniType:=traEXPRESSION(S);
        lexAccept1(S,lexPARSE,integer(pOvR));
        if not ((uniType^.idClass=idtSCAL)or
          (uniType^.idClass=idtBAS)and(uniType^.idBasNom=typeBOOL)or
          (uniType^.idClass=idtBAS)and(uniType^.idBasNom=typeCHAR))
          then lexError(S,'Ожидался тип перечисления',nil)
          else uniType:=idTYPE[typeDWORD]
        end;|
      else
        lexError(S,_Ожидалось_выражение[envER],nil);
        uniType:=idTYPE[typeBYTE]
    end;|
  else
    lexError(S,_Ожидалось_выражение[envER],nil);
    return idTYPE[typeBYTE]; //на случай ошибки
  end;
  return uniType
end
end traUNIT;

//------------- Операция NOT ------------------

procedure traUNITNOT(var S:recStream):pID;
//UNITNOT=["NOT"|"!"|"~"] UNIT
var notType:pID; bitNot:boolean;
begin
with S do
  bitNot:=okREZ(S,rNOT) or okPARSE(S,pVos) or okPARSE(S,pVol);
  if bitNot then lexGetLex1(S) end;
  notType:=traUNIT(S);
  if bitNot then
    lexTest(not ((notType^.idClass=idtBAS)and(notType^.idBasNom in [typeBOOL,typeBYTE,typeWORD,typeDWORD,typeINT])),S,_Неверный_тип[envER],nil);
    case notType^.idBasNom of
      typeBYTE:traBYTE(S,opNOT);|
      typeBOOL:traLONG(S,opNOTB);|
      typeWORD:traWORD(S,opNOT);|
      typeDWORD:traLONG(S,opNOT);|
      typeINT:traLONG(S,opNOT);|
    end
  end;
  return notType
end
end traUNITNOT;

//------- Операции * / div mod and ------------

procedure traUNITMUL(var S:recStream):pID;
//UNITMUL=UNITNOT {"*"|"/"|"DIV"|"MOD"|"<<"|">>"|"%"|"AND"|"&"|"&&" UNITNOT}
var mulType,mulType2:pID; mulOp:classOp; expEnd:lstJamp;
begin
with S do
  expEnd.top:=0;
  mulType:=traUNITNOT(S);
  with mulType^ do
  while not stErr and(
    okPARSE(S,pMul)or 
    okPARSE(S,pDiv)or
    okPARSE(S,pPro)or
    okPARSE(S,pSob)or
    okPARSE(S,pSobSob)or
    okPARSE(S,pUgLUgL)or
    okPARSE(S,pUgRUgR)or
    okREZ(S,rDIV)or 
    okREZ(S,rMOD)or 
    okREZ(S,rAND)) do
    lexTest(not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeWORD,typeBOOL,typeINT,typeDWORD,typeREAL32,typeREAL])),S,_Неверный_тип[envER],nil);
    lexTest((idBasNom=typeBOOL)and not (okREZ(S,rAND)or okPARSE(S,pSob)or okPARSE(S,pSobSob)),S,_Неверный_тип[envER],nil);
    case stLex of
      lexPARSE:case classPARSE(stLexInt) of
        pMul:mulOp:=opMUL; lexAccept1(S,lexPARSE,integer(pMul));|
        pDiv:mulOp:=opDIV; lexAccept1(S,lexPARSE,integer(pDiv));|
        pPro:mulOp:=opMOD; lexAccept1(S,lexPARSE,integer(pPro));|
        pUgLUgL:mulOp:=opUgLUgL; lexAccept1(S,lexPARSE,integer(pUgLUgL));|
        pUgRUgR:mulOp:=opUgRUgR; lexAccept1(S,lexPARSE,integer(pUgRUgR));|
        pSob,pSobSob:mulOp:=opAND; lexGetLex1(S);
//pop ax; push ax; or ax,ax; je _expEnd;
          genPOP(S,rEAX,traBitAND);
          genR(S,cPUSH,rEAX);
          genRR(S,cOR,rEAX,rEAX);
          genAddJamp(S,expEnd,tbMod[tekt].topCode,cJE);
          genGen(S,cJE,0);
          traBitAND:=true;|
      end;|
      lexREZ:case classREZ(stLexInt) of
        rDIV:mulOp:=opDIV; lexAccept1(S,lexREZ,integer(rDIV));|
        rMOD:mulOp:=opMOD; lexAccept1(S,lexREZ,integer(rMOD));|
        rAND:mulOp:=opAND; lexAccept1(S,lexREZ,integer(rAND));
//pop ax; push ax; or ax,ax; je _expEnd;
          genPOP(S,rEAX,traBitAND);
          genR(S,cPUSH,rEAX);
          genRR(S,cOR,rEAX,rEAX);
          genAddJamp(S,expEnd,tbMod[tekt].topCode,cJE);
          genGen(S,cJE,0);
          traBitAND:=true;|
      end;|
    end;
    mulType2:=traUNITNOT(S);
    traEqv(S,mulType,mulType2,true);
    if (idBasNom=typeBOOL)and(mulOp=opAND) then mulOp:=opANDB;
    elsif (idBasNom=typeINT)and(mulOp=opMUL) then mulOp:=opMULZ;
    elsif (idBasNom=typeINT)and(mulOp=opDIV) then mulOp:=opDIVZ;
    end;
    case idtSize of
      1:traBYTE(S,mulOp);|
      2:traWORD(S,mulOp);|
      4:if idBasNom=typeREAL32 then traREAL(S,mulOp,4) else traLONG(S,mulOp) end;|
      8:traREAL(S,mulOp,8);|
    end
  end end;
  genSetJamps(S,expEnd,tbMod[tekt].topCode);
  return mulType
end
end traUNITMUL;

//----------- Операции + - or -----------------

procedure traUNITADD(var S:recStream):pID;
//EXPRESSION=["-"] UNITMUL {"+"|"-"|"OR"|"|"|"||" UNITMUL}
var expType,expType2:pID; expOp:classOp; bitMin:boolean;
begin
with S do
  bitMin:=okPARSE(S,pMin);
  if okPARSE(S,pMin) then
    lexAccept1(S,lexPARSE,integer(pMin));
  end;
  expType:=traUNITMUL(S);
  if bitMin then with expType^ do
    lexTest(not((idClass=idtBAS)and(idBasNom in [typeINT,typeDWORD,typeREAL32,typeREAL])),S,_Ожидалось_число[envER],nil);
    case idBasNom of
      typeINT,typeDWORD:genPOP(S,rEAX,traBitAND); genR(S,cNEG,rEAX); genR(S,cPUSH,rEAX);|
      typeREAL32,typeREAL://mov si,sp; wait; fld q/d [si]; wait; fchs; wait; fstp q/d [si]
        genRR(S,cMOV,rESI,rESP);
        genGen(S,cWAIT,0); genM(S,cFLD,regNULL,regNULL,rESI,0,idtSize);
        genGen(S,cWAIT,0); genGen(S,cFCHS,0);
        genGen(S,cWAIT,0); genM(S,cFSTP,regNULL,regNULL,rESI,0,idtSize);|
    end
  end end;
  with expType^ do
  while not stErr and(okPARSE(S,pPlu)or okPARSE(S,pMin)or okREZ(S,rOR)or okPARSE(S,pVer)or okPARSE(S,pVerVer)) do
    lexTest(not(traOkSET(expType,false)or(idClass=idtBAS)and(idBasNom in [typeBYTE,typeWORD,typeBOOL,typeINT,typeDWORD,typeREAL32,typeREAL])),S,_Неверный_тип[envER],nil);
    lexTest((idBasNom=typeBOOL)and not (okREZ(S,rOR)or okPARSE(S,pVer)or okPARSE(S,pVerVer)),S,_Неверный_тип[envER],nil);
    lexTest(traOkSET(expType,false)and not (okPARSE(S,pPlu)or okPARSE(S,pMin)),S,_Неверный_тип[envER],nil);
    case stLex of
      lexPARSE:case classPARSE(stLexInt) of
        pPlu:expOp:=opADD; lexAccept1(S,lexPARSE,integer(pPlu));|
        pMin:expOp:=opSUB; lexAccept1(S,lexPARSE,integer(pMin));|
        pVer:expOp:=opOR; lexAccept1(S,lexPARSE,integer(pVer));|
        pVerVer:expOp:=opOR; lexAccept1(S,lexPARSE,integer(pVerVer));|
      end;|
      lexREZ:case classREZ(stLexInt) of
        rOR:expOp:=opOR;lexAccept1(S,lexREZ,integer(rOR));|
      end;|
    end;
    expType2:=traUNITMUL(S);
    if traOkSET(expType,false) then
      lexTest(not(traOkSET(expType2,false)or traOkSET(expType2,true)),S,_Неверный_тип_в_операциях_с_множеством[envER],nil);
      case expOp of
        opADD:if traOkSET(expType2,true) then expOp:=opSETADDE else expOp:=opSETADD end;|
        opSUB:if traOkSET(expType2,true) then expOp:=opSETSUBE else expOp:=opSETSUB end;|
      end;
    else traEqv(S,expType,expType2,true);
    end;
    if (idBasNom=typeBOOL)and(expOp=opOR) then
      expOp:=opORB;
    end;
    case idtSize of
      1:traBYTE(S,expOp);|
      2:traWORD(S,expOp);|
      4:if idBasNom=typeREAL32 then traREAL(S,expOp,4) else traLONG(S,expOp) end;|
      8:traREAL(S,expOp,8);|
      32:traGENSET(S,expOp);|
    end
  end end;
  return expType
end
end traUNITADD;

//------- Операции сравнения ---------------

procedure traEXPRESSION;
//UNITEQV=UNITADD ["="|"=="|"<>"|"!="|"<"|">"|"<="|">="|"IN" UNITADD]
var eqvType,eqvType2:pID; eqvOp:classOp;
begin
with S do
  eqvType:=traUNITADD(S);
  with eqvType^ do
  if okPARSE(S,pEqv)or okPARSE(S,pEqvEqv)or okPARSE(S,pUgLUgR)or okPARSE(S,pVosEqv)or
    okPARSE(S,pUgL)or okPARSE(S,pUgR)or okPARSE(S,pUgLEqv)or okPARSE(S,pUgREqv)or
    okREZ(S,rIN) then
    if (okPARSE(S,pUgL)or okPARSE(S,pUgR)or okPARSE(S,pUgLEqv)or okPARSE(S,pUgREqv))and
      not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeWORD,typeINT,typeDWORD,typeREAL32,typeREAL])) then
      lexError(S,_Неверный_тип_в_операции_сравнения[envER],nil);
    end;
    lexTest(okREZ(S,rIN) and not traOkSET(eqvType,true),S,_Неверный_тип[envER],nil);
    if okREZ(S,rIN) then eqvOp:=opSETIN;
    else
    case classPARSE(stLexInt) of
      pEqv:eqvOp:=opE;|
      pEqvEqv:eqvOp:=opE;|
      pUgLUgR:eqvOp:=opNE;|
      pVosEqv:eqvOp:=opNE;|
      pUgL:eqvOp:=opLZ;|
      pUgR:eqvOp:=opGZ;|
      pUgLEqv:eqvOp:=opLEZ;|
      pUgREqv:eqvOp:=opGEZ;|
    end end;
    lexGetLex1(S);
    eqvType2:=traUNITADD(S);
    if (eqvOp in [opLZ,opGZ,opLEZ,opGEZ])and
      (eqvType^.idClass=idtBAS)and(eqvType^.idBasNom in [typeBYTE,typeWORD,typeDWORD])and
      (eqvType2^.idClass=idtBAS)and(eqvType2^.idBasNom in [typeBYTE,typeWORD,typeDWORD]) then
      case eqvOp of
        opLZ:eqvOp:=opL;|
        opGZ:eqvOp:=opG;|
        opLEZ:eqvOp:=opLE;|
        opGEZ:eqvOp:=opGE;|
      end
    end;
    if eqvOp=opSETIN
      then lexTest(not (traOkSET(eqvType,true)and traOkSET(eqvType2,false)),S,_Неверный_тип[envER],nil);
      else traEqv(S,eqvType,eqvType2,true);
    end;
    if eqvOp=opSETIN then traGENSET(S,eqvOp)
    else
    case idtSize of
      1:traBYTE(S,eqvOp);|
      2:traWORD(S,eqvOp);|
      4:if idBasNom=typeREAL32 then traREAL(S,eqvOp,4) else traLONG(S,eqvOp) end;|
      8:traREAL(S,eqvOp,8);|
    else lexError(S,_Неверный_тип_в_операции_сравнения[envER],nil);
    end end;
    eqvType:=idTYPE[typeBOOL]
  end end;
  return eqvType
end
end traEXPRESSION;

end SmTra.
