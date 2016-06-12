//СТРАННИК Модула-Си для Win32
//Модуль PRE (модуль межязыкового перевода)
//Файл SMPRE.M

implementation module SmPre;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra,SmTraC;

procedure preNextLex(var S:preStream); forward;
procedure preGetLex(var S:preStream); forward;

//===============================================
//                 ЛЕКСИЧЕСКИЙ АНАЛИЗ
//===============================================

//----------------- Открытие потока -----------------------

procedure preOpen(var S:preStream; opModule:pstr; opTxt:integer);
begin
with S do
  lstrcpy(stFile,opModule);
  stTxt:=opTxt;
  with stPosLex do f:=1; y:=1 end;
  with stPosPred do f:=1; y:=1 end;
  stLex:=lexNULL;
  stLexStr[0]:=char(0);
  stLexOld[0]:=char(0);
  stInput:=memAlloc(maxInput); stInput[0]:=char(0);
  stComment:=memAlloc(maxInput); stComment[0]:=char(0);
  stErr:=false;
  with stErrPos do f:=1; y:=1 end;
  stErrText[0]:=char(0);
  preNextLex(S);
  while stLex=lexCOMM do
    preGetLex(S)
  end
end
end preOpen;

//------------------- Закрытие потока -----------------------

procedure preClose(var S:preStream);
begin
with S do
  memFree(stInput);
  memFree(stComment);
end
end preClose;

//----------------- Ошибка трансляции ----------------------

procedure preError(var S:preStream; errText,errMes:pstr);
begin
  with S do
    if not stErr then
      stErr:=true;
      stErrPos:=stPosPred;
      lstrcpy(stErrText,errText);
      lstrcat(stErrText,errMes);
      stLex:=lexNULL
    end
  end
end preError;

//------------------ Лексема из фрагмента ------------------------

procedure preFromFrag(var S:preStream; stTxt,y,f:integer);
begin
with S do
  stLex:=lexNULL;
  if (stTxt<=topt)and(txts[stTxt].txtStrs<>nil) then
  with txts[stTxt].txtStrs^ do
    if (y>tops)or(y=tops)and(f>arrs[y]^.topf) then stLex:=lexEOF
    else with arrs[y]^.arrf[f]^ do
      lstrcpy(stLexStr,txt);
      case cla of
        fNULL:preError(S,"Неверный символ",nil);|
        fCOMM:stLex:=lexCOMM;|
        fINT:stLex:=lexINT;|
        fREAL:stLex:=lexREAL;|
        fPARSE:stLex:=lexPARSE; stLexInt:=integer(pv);|
        fREZ:case rv of
          rNIL:stLex:=lexNIL;|
          rNULL:stLex:=lexNIL;|
          rTRUE:stLex:=lexTRUE;|
          rFALSE:stLex:=lexFALSE;|
        else stLex:=lexREZ;  stLexInt:=integer(rv);
        end;|
        fASM:stLex:=lexASM;|
        fREG:stLex:=lexREG;|
        fCEP:stLex:=lexSTR;|
        fID:stLex:=lexNEW;|
      end
    end end
  end end
end
end preFromFrag;

//------------------ Следующая лексема ----------------------

procedure preNextLex;
begin
with S do
  if txts[stTxt].txtStrs<>nil then
  with txts[stTxt].txtStrs^,stPosLex do
    preFromFrag(S,stTxt,y,f);
    if y>tops then stLex:=lexEOF
    elsif f<arrs[y]^.topf then inc(f)
    else inc(y); f:=1; //envInf(txts[tekt].txtFile,nil,y*100 div (tops+1));
    end
  end end
end
end preNextLex;

//-------- Выборка лексемы ---------

procedure preGetLex;
begin
with S do
  lstrcpy(stLexOld,stLexStr);
  stLexStr[0]:=char(0);
  stPosPred:=stPosLex;
  if txts[stTxt].txtStrs<>nil then
  with txts[stTxt].txtStrs^,stPosLex do
    if lstrlen(stInput)+lstrlen(txt)+2<maxInput then
      lstrcat(stInput,txt);
    end;
    preNextLex(S);
    while stLex=lexCOMM do
      if lstrlen(stComment)+lstrlen(txt)+2<maxInput then
        lstrcat(stComment,txt);
      end;
      preNextLex(S);
    end
  end end;
  if stErr then stLex:=lexNULL end;
end
end preGetLex;

//--------------- Получение имени лексемы ---------------

procedure preLexName(var S:preStream; lex:classLex; val:integer; name:pstr);
begin
with S do
  case lex of
    lexPARSE:lstrcpy(name,namePARSE[classPARSE(val)]);|
    lexREZ:lstrcpy(name,nameREZ[carSet][classREZ(val)]);|
  else lstrcpy(name,nameLex[lex])
  end
end
end preLexName;

//------------------ Проверить лексему ---------------------

procedure preAccept(var S:preStream; lex:classLex; val:integer);
var str:string[80];
begin
with S do
  if not ((stLex=lex)and((val=0)or(val=stLexInt))) then
    preLexName(S,lex,val,str);
    preError(S,"Ожидалось ",str)
  end;
  if not stErr then
    preGetLex(S)
  end
end
end preAccept;

//- Проверка на зарезервированный идентификатор -

procedure preREZ (var S:preStream; rez:classREZ):boolean;
begin
  with S do
    return (stLex=lexREZ)and(stLexInt=integer(rez))
  end
end preREZ;

//--------- Проверка на разделитель -----------

procedure prePARSE(var S:preStream; par:classPARSE):boolean;
begin
  with S do
    return (stLex=lexPARSE)and(stLexInt=integer(par))
  end
end prePARSE;

//===============================================
//                 РАЗБОР МОДУЛЯ (МОДУЛА)
//===============================================

procedure traUNIT(var S:preStream; var unit:pUNIT);
//UNIT=VARIABLE | CALL | "(" EXPRESSION ")" | CONST | TYPE | ADDR | SIZE | ABS
begin
  unit:=memAlloc(sizeof(recUNIT));
  with S,unit^ do
    unitNot:=preREZ(S,rNOT) or prePARSE(S,pVos) or prePARSE(S,pVol);
    if unitNot then
      preGetLex(S)
    end;
    case stLex of
      lexVAR,lexPAR,lexLOC,lexVPAR,lexFIELD,lexSTRU:class:=uVAR; preVARIABLE(S,unitVAR);|
      lexPROC:class:=uPROC; preCALL(S,unitPROC);|
      lexPARSE:case classPARSE(stLexInt) of
        pMul:class:=uVAR; preVARIABLE(S,unitVAR);|
        pOvL:class:=uEXP;
          preAccept(S,lexPARSE,integer(pOvL));
          preEXPRESSION(S,unitEXP);
          preAccept(S,lexPARSE,integer(pOvR));|
        else preError(S,"Ожидалось выражение",nil);
        end;|
      lexCHAR,lexINT,lexREAL,lexSTR,lexSCAL:class:=uCONST; preCopy(unitSTR,stLexStr); preGetLex(S);|
      lexNIL:class:=uNIL; preGetLex(S);|
      lexFALSE:class:=uFALSE; preGetLex(S);|
      lexTRUE:class:=uTRUE; preGetLex(S);|
      lexTYPE:
        preGetLex(S);
        if okPARSE(S,pFiL) then preSTRUCT(S,stLexOld,unitSTR);
        else
          preCopy(unitSTR,stLexOld);
          preAccept(S,lexPARSE,integer(pOvL));
          preEXPRESSION(S,unitEXP);
          preAccept(S,lexPARSE,integer(pOvR));
        end;|
      lexREZ:case classREZ(stLexInt) of
        rSIZEOF:
          preAccept(S,lexREZ,integer(rSIZEOF));
          preAccept(S,lexPARSE,integer(pOvL));
          preAccept(S,lexNEW,0);
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
            genMR(S,cMOV,regNULL,regNULL,regNULL,rAX,genBASECODE+genSize(exeOld,1)+44,1);
            genRD(S,cADD,rAX,genBASECODE+stLexID^.idProcAddr);
            genR(S,cPUSH,rAX);
            lexAccept1(S,lexPROC,0);|
          else traVARIABLE(S,false)
        end;
        lexAccept1(S,lexPARSE,integer(pOvR));|
      rTRUNC:
        uniType:=idTYPE[typeREAL];
        lexAccept1(S,lexREZ,integer(rTRUNC));
        lexAccept1(S,lexPARSE,integer(pOvL));
        uniExp:=traEXPRESSION(S);
        lexAccept1(S,lexPARSE,integer(pOvR));
        with uniExp^ do
        if not((uniExp<>nil)and(idClass=idtBAS)and(idBasNom=typeREAL)) then
          lexError(S,"Ожидалось вещественное число",nil)
        else
//mov si,sp
          genRR(S,cMOV,rSI,rSP);
//push ax; mov di,sp; fstcw [di]
          genR(S,cPUSH,rAX);
          genRR(S,cMOV,rDI,rSP);
          genM(S,cFSTCW,regNULL,regNULL,rDI,0,0);
//or ss:[di],0x0C1F; fldcw [di]
          genMD(S,cOR,rSS,regNULL,rDI,0,0x0C1F,2);
          genM(S,cFLDCW,regNULL,regNULL,rDI,0,0);
//wait; fld [si]; wait; frndint; wait; fstp [si]
          genGen(S,cWAIT,0); genM(S,cFLD,regNULL,regNULL,rSI,0,0);
          genGen(S,cWAIT,0); genGen(S,cFRNDINT,0);
          genGen(S,cWAIT,0); genM(S,cFSTP,regNULL,regNULL,rSI,0,0);
//fstcw [di]
          genM(S,cFSTCW,regNULL,regNULL,rDI,0,0);
//and [di],0xF3FF; fldcw [di]; pop ax
          genMD(S,cAND,regNULL,regNULL,rDI,0,0xF3FF,2);
          genM(S,cFLDCW,regNULL,regNULL,rDI,0,0);
          genR(S,cPOP,rAX);
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
        genPOP(S,rAX,traBitAND);
        case rez of
          rLOWORD:genRD(S,cAND,rAX,0x0000FFFF);|
          rHIWORD:genRD(S,cSHR,rAX,16);|
          rLOBYTE:genRD(S,cAND,rAX,0x000000FF);|
          rHIBYTE:genRD(S,cAND,rAX,0x0000FF00); genRD(S,cSHR,rAX,8);|
        end;
        genR(S,cPUSH,rAX);
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
        lexError(S,"Ожидалось выражение",nil);
        uniType:=idTYPE[typeBYTE]
    end;|
  else
    lexError(S,"Ожидалось выражение",nil);
    return idTYPE[typeBYTE]; //на случай ошибки
  end;
  return uniType
end
end preUNIT;

//----------- Операции + - or -----------------

procedure preUNITMUL(var S:preStream; var add:pPreAdd);
//UNITMUL=UNITNOT {"*"|"/"|"DIV"|"MOD"|"%"|"AND"|"&"|"&&" UNITNOT}
var unit:pUnit; mulOp:ClassOp;
begin
  add:=memAlloc(sizeof(recPreAdd));
  add^.addList:=memAlloc(sizeof(preArrList));
  with S,add^,addList^ do
    listTop:=0;
    while not stErr and((listTop=0)or
      okPARSE(S,pMul)or okPARSE(S,pDiv)or okPARSE(S,pPro)or okPARSE(S,pSob)or
      okPARSE(S,pSobSob)or okREZ(S,rDIV)or okREZ(S,rMOD)or okREZ(S,rAND)) do
      expOp:=opNULL;
      if listTop>0 then
        case stLex of
          lexPARSE:case classPARSE(stLexInt) of
            pMul:mulOp:=opMUL;|
            pDiv:mulOp:=opDIV;|
            pPro:mulOp:=opMOD;|
            pSob,pSobSob:mulOp:=opAND;|
          end;|
          lexREZ:case classREZ(stLexInt) of
            rDIV:mulOp:=opDIV;|
            rMOD:mulOp:=opMOD;|
            rAND:mulOp:=opAND;|
          end;|
        end;
        preGetLex(S);
      end;
      preUNIT(S,unit);
      unit^.unitOp:=mulOp;
      preADD(addList,address(unit));
    end;
  end;
end preUNITMUL;

//----------- Операции + - or -----------------

procedure preUNITADD(var S:preStream; var list:preLIST);
//UNITADD=UNITMUL {"+"|"-"|"OR"|"|"|"||" UNITMUL}
var add:pPreAdd; expOp:ClassOp;
begin
  list:=memAlloc(sizeof(preArrList));
  with S,list^ do
    listTop:=0;
    while not stErr and((listTop=0)or okPARSE(S,pPlu)or okPARSE(S,pMin)or okREZ(S,rOR)or okPARSE(S,pVer)or okPARSE(S,pVerVer)) do
      expOp:=opNULL;
      if listTop>0 then
        case stLex of
          lexPARSE:case classPARSE(stLexInt) of
            pPlu:expOp:=opADD;|
            pMin:expOp:=opSUB;|
            pVer:expOp:=opOR;|
            pVerVer:expOp:=opOR;|
          end;|
          lexREZ:case classREZ(stLexInt) of
            rOR:expOp:=opOR;|
          end;|
        end;
        preGetLex(S);
      end;
      traUNITMUL(S,add);
      add^.addOp:=expOp;
      preADD(list,address(add));
    end;
  end;
end preUNITADD;

//----------------- Выражение -----------------------

procedure preEXPRESSION(var S:preStream; var exp:pEXP);
//UNITEQV=["-"] UNITADD ["="|"=="|"<>"|"!="|"<"|">"|"<="|">=" ["-"] UNITADD]
begin
  exp:=memAlloc(sizeof(recEXP));
  with S,exp^ do
    expMin:=prePARSE(S,pMin);
    if expMin then
      preGetLex(S);
    end;
    preUNITADD(S,expAdd);
    expOp:classOp;
    expAdd2:pPreAdd; expMin2:boolean;
    if okPARSE(S,pEqv)or okPARSE(S,pEqvEqv)or okPARSE(S,pUgLUgR)or okPARSE(S,pVosEqv)or
      okPARSE(S,pUgL)or okPARSE(S,pUgR)or okPARSE(S,pUgLEqv)or okPARSE(S,pUgREqv) then
      case classPARSE(stLexInt) of
        pEqv:expOp:=opE;|
        pEqvEqv:expOp:=opE;|
        pUgLUgR:expOp:=opNE;|
        pVosEqv:expOp:=opNE;|
        pUgL:expOp:=opL;|
        pUgR:expOp:=opG;|
        pUgLEqv:expOp:=opLE;|
        pUgREqv:expOp:=opGE;|
      end;
      lexGetLex(S);
      expMin2:=prePARSE(S,pMin);
      if expMin2 then
        preGetLex(S);
      end;
      preUNITADD(S,expAdd2);
    end
  end
end preEXPRESSION;

end SmPre.


