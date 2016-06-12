//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль LEX (лексический анализ)
//Файл SMLEX.M

implementation module SmLex;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen;

//=============================================
//          ФУНКЦИИ РАБОТЫ С ПОТОКОМ
//=============================================

//----------- Открытие потока ---------------

  procedure lexOpen(var Stream:recStream; opFile:pstr; opTxt,opExt:integer);
  var opSou:integer; siz:integer;
  begin
  with Stream do
    lexZEROSTR[0]:=char(0x27);
    lexZEROSTR[1]:=char(0x5C);
    lexZEROSTR[2]:=char(0x30);
    lexZEROSTR[3]:=char(0x27);
    lexZEROSTR[4]:=char(0x00);
    lstrcpy(stFile,opFile);
    with stPosLex do f:=1; y:=1 end;
    with stPosPred do f:=1; y:=1 end;
    stLex:=lexNULL;
    stLexInt:=0;
    stLexStr[0]:=char(0);
    stLexOld[0]:=char(0);
    stLexReal:=0.0;
    stErr:=false;
    with stErrPos do f:=1; y:=1 end;
    stErrText[0]:=char(0);
    stLoad:=false;
    stTxt:=opTxt;
    stExt:=opExt;
    lexNextLex(Stream,true);
    while stLex=lexCOMM do
      lexGetLex1(Stream)
    end
  end
  end lexOpen;

//----------- Закрытие потока ---------------

  procedure lexClose;
  begin
//    if Stream.stLoad then
//      memFree(Stream.stText);
  end lexClose;

//=================================================}
//=============== ЛЕКСИЧЕСКИЙ АНАЛИЗ ==============}
//=================================================}

//------- Проверка на символ --------

  procedure lexIN(c,cLo,cHi:char):boolean;
  begin
    return (ord(c)>=ord(cLo))and(ord(c)<=ord(cHi))
  end lexIN;

//----------- Разбор строки ---------------

  procedure lexParseStr(s:pstr);
  var i,j:integer;
  begin
    i:=0;
    while i<lstrlen(s) do
      while (i<lstrlen(s))and(s[i]<>'\') do
        inc(i)
      end;
      if i<lstrlen(s) then
        case s[i+1] of
          '\':lstrdel(s,i,1); inc(i);|
          '"':lstrdel(s,i,1); inc(i);|
          'n':s[i]:='\13'; s[i+1]:='\10'; inc(i,2);|
          '0'..'9':
          if (s[i+1]<>'0')or lexIN(s[i+2],'0','9') then
            j:=0;
            while (i<lstrlen(s))and lexIN(s[i+1],'0','9') do
              j:=j*10+ord(s[i+1])-ord('0');
              lstrdel(s,i+1,1);
            end;
            lstrinsc(char(j),s,i+1);
            lstrdel(s,i,1);
            inc(i)
          else inc(i)
          end;|
        else inc(i)
        end
      end
    end
  end lexParseStr;

//------- Лексема из фрагмента --------------

  procedure lexFromFrag(var Stream:recStream; stTxt,y,f:integer; bitID:boolean);
  var s:pstr;
  begin
  with Stream do
    stLex:=lexNULL;
    stLexID:=nil;
    if (stTxt<=topt)and(txts[stExt][stTxt].txtStrs<>nil) then
    with txts[stExt][stTxt].txtStrs^ do
      if (y>tops)or(y=tops)and(f>arrs[y]^.topf) then stLex:=lexEOF
      else with arrs[y]^.arrf[f]^ do
      case cla of
        fNULL:lexError(Stream,'Неверный символ',nil);|
        fCOMM:stLex:=lexCOMM; stLexInt:=ord(pv);|
        fINT:stLex:=lexINT; stLexInt:=iv; lstrcpy(stLexStr,txt);|
        fREAL:stLex:=lexREAL; stLexReal:=fv; lstrcpy(stLexStr,txt);|
        fPARSE:stLex:=lexPARSE; stLexInt:=integer(pv);|
        fREZ:case rv of
                 rNIL:stLex:=lexNIL; stLexInt:=0;|
                 rNULL:stLex:=lexNIL; stLexInt:=0;|
                 rTRUE:stLex:=lexTRUE; stLexInt:=1;|
                 rFALSE:stLex:=lexFALSE; stLexInt:=0;|
               else stLex:=lexREZ; stLexInt:=integer(rv);
               end;|
        fASM:stLex:=lexASM; stLexInt:=integer(av);|
        fREG:stLex:=lexREG; stLexInt:=integer(mv);|
        fCEP:
          s:=memAlloc(lstrlen(txt)+1);
          lstrcpy(s,txt);
          lstrdel(s,0,1);
          lstrdel(s,lstrlen(s)-1,1);
          lexParseStr(s);
          if txt[0]='"' then stLex:=lexSTR; lstrcpy(stLexStr,s)
          elsif lstrcmp(txt,lexZEROSTR)=0 then stLex:=lexCHAR; stLexInt:=0
          elsif (txt[0]=char(39))and(lstrlen(s)=1) then stLex:=lexCHAR; stLexInt:=integer(s[0])
          else stLex:=lexSTR; lstrcpy(stLexStr,s)
          end;
          memFree(s);|
        fID:
          lstrcpy(stLexStr,txt);
          if bitID
            then stLexID:=idFindGlo(txt,true);
            else stLexID:=nil
          end;
          if stLexID=nil then stLex:=lexNEW
          else with stLexID^ do case idClass of
            idcCHAR:stLex:=lexCHAR; stLexInt :=idInt;|
            idcINT:stLex:=lexINT;  stLexInt :=idInt;|
            idcREAL:stLex:=lexREAL; stLexReal:=idReal;|
            idcSTR:stLex:=lexSTR; stLexInt:=idStrAddr; lstrcpy(stLexStr,idStr);|
            idcSET:stLex:=lexSET; stLexSet:=idSet^;|
            idcSTRU:stLex:=lexSTRU; stLexInt:=idStruAddr;|
            idcSCAL:stLex:=lexSCAL; stLexInt:=idInt;|
            idtBAS..idtSCAL:stLex:=lexTYPE;|
            idvFIELD:stLex:=lexFIELD;|
            idvPAR:stLex:=lexPAR;|
            idvLOC:stLex:=lexPAR;|
            idvVPAR:stLex:=lexVPAR;|
            idvVAR:stLex:=lexVAR;|
            idPROC:stLex:=lexPROC;|
            idMODULE:stLex:=lexMOD;|
          end end end;|
      end end end
    end end
  end
  end lexFromFrag;

//------------- Следующая лексема ---------------

  procedure lexNextLex(var Stream:recStream; bitID:boolean);
  begin
  with Stream do
    if txts[stExt][stTxt].txtStrs<>nil then
    with txts[stExt][stTxt].txtStrs^,stPosLex do
      lexFromFrag(Stream,stTxt,y,f,bitID);
      if y>tops then stLex:=lexEOF
      elsif f<arrs[y]^.topf then inc(f)
      else 
        inc(y);
        f:=1;
        envInf(txts[stExt][tekt].txtFile,nil,y*100 div (tops+1)); 
      end
    end end
  end
  end lexNextLex;

//-------- Выборка пробелов ---------

  procedure lexComment(var Stream:recStream; bitID:boolean);
  var parse:classPARSE;
  begin
  with Stream do
    while stLex=lexCOMM do
    case stLexInt of
      pDivMul:
        parse:=classPARSE(stLexInt);
        lexNextLex(Stream,bitID);
        while not((stLex=lexEOF)or
          (stLex=lexCOMM)and(stLexInt=ord(pMulDiv))and(parse=pDivMul)) do
          lexNextLex(Stream,bitID);
        end;
        lexTest(stLex=lexEOF,Stream,"Незакрытый комментарий",nil);|
      pMulDiv:lexNextLex(Stream,bitID);|
    else lexNextLex(Stream,bitID);
    end end
  end
  end lexComment;

//-------- Анализ сверхнизкого уровня ---------

  procedure lexGetLex00(var Stream:recStream);
  var buf,bufVal:pstr;
  begin
  with Stream do
    lstrcpy(stLexOld,stLexStr);
    stLexStr[0]:=char(0);
    stLexInt:=0;
    stPosPred:=stPosLex;

    if txts[stExt][stTxt].txtStrs<>nil then
    with txts[stExt][stTxt].txtStrs^,stPosLex do
      lexNextLex(Stream,false);
      lexComment(Stream,false);
    end end;
    if stErr then stLex:=lexNULL end;

  end
  end lexGetLex00;

//----------- Анализ нижнего уровня -------------

  procedure lexGetLex0;
  var buf,bufVal:pstr; old:string[maxText];
  begin
  with Stream do
    lstrcpy(old,stLexStr);
    stLexStr[0]:=char(0);
    stLexInt:=0;
    stPosPred:=stPosLex;
    
    if not stErr and (txts[stExt][stTxt].txtStrs<>nil) then
    with txts[stExt][stTxt].txtStrs^,stPosLex do
      lexNextLex(Stream,true);
      lexComment(Stream,true);
    end end;
    if stErr then stLex:=lexNULL end;
    lstrcpy(stLexOld,old);    
  end
  end lexGetLex0;

//----- Анализ уровня 1 (определение операции) ----------

  procedure lexFindOp(findPars:integer):classConOp;
  var findOp,findMy:classConOp;
  begin
    findOp:=conNULL;
    for findMy:=conAdd to conAnd do
      if lexConOp[findMy]=classPARSE(findPars) then
        findOp:=findMy
      end
    end;
    return findOp
  end lexFindOp;

//----- Анализ уровня 1 (заполнитель фрагмента стека констант) ----------

  procedure lexFillVal(var Stream:recStream; valOp:classConOp);
  begin
  with Stream do
    if topStackCon=maxStackCon
      then lexError(Stream,_Слишком_длинное_константое_выражение[envER],nil)
      else inc(topStackCon)
    end;
    with lexStackCon[topStackCon] do
      conOp:=valOp;
      conLex:=stLex;
      case conLex of
        lexINT:conInt:=stLexInt;|
        lexSCAL:conInt:=stLexInt;|
        lexREAL:conReal:=stLexReal;|
        lexSTR:conStr:=memAlloc(lstrlen(stLexStr)+1); lstrcpy(conStr,stLexStr);|
        lexCHAR:conChar:=char(stLexInt);|
      end
    end
  end
  end lexFillVal;

//----- Анализ уровня 1 (заполнитель стека констант) ----------

  procedure lexFillCon(var Stream:recStream):boolean;
  var 
    fillStream:pointer to recStream; 
    fillLex:classLex; 
    fillStop,rez:boolean;
    fillOp:classConOp; 
  begin
  with Stream do
    fillStream:=memAlloc(sizeof(recStream));
    topStackCon:=0;
    rez:=false;
    fillLex:=stLex;
    if fillLex=lexSCAL then
      fillLex:=lexINT
    end;
    lexFillVal(Stream,conNULL);
    fillStop:=false;
    repeat
      fillStream^:=Stream;
      lexGetLex0(Stream);
      if not ((stLex=lexPARSE)and(
              (fillLex=lexINT)and lexBitConst and (stLexInt>=ord(conAdd))and(stLexInt<=ord(conAnd))or
              (fillLex=lexINT)and (stLexInt>=ord(conOr))and(stLexInt<=ord(conAnd))or
              (fillLex=lexREAL)and lexBitConst and (stLexInt>=ord(conAdd))and(stLexInt<=ord(conDiv))or
              (fillLex=lexSTR)and lexBitConst and(stLexInt=ord(conAdd))))
      then fillStop:=true
      else
        fillOp:=lexFindOp(stLexInt);
        lexGetLex0(Stream);
        case fillLex of
          lexINT:fillStop:=(stLex<>lexINT)and(stLex<>lexSCAL);|
          lexREAL:fillStop:=(stLex<>lexREAL);|
          lexSTR:fillStop:=(stLex<>lexSTR)and(stLex<>lexCHAR);|
        end;
        if not fillStop then
          lexFillVal(Stream,fillOp)
        end;
        rez:=true;
      end
    until fillStop;
    if lexStackCon[1].conLex<>lexSTR then
      stLex:=lexStackCon[1].conLex;
      stLexInt:=0;
      stLexReal:=0.0;
      lexFillVal(Stream,conAdd)
    end;
    Stream:=fillStream^;
    memFree(fillStream);
    return rez
  end
  end lexFillCon;

//----- Анализ уровня 1 (вычислитель стека констант) ----------

  procedure lexEvalCon(var Stream:recStream);
  var evalOp:classConOp; evalLong:integer; evalReal:real; evalCo:integer;
  begin
  with Stream do
    case lexStackCon[1].conLex of
      lexINT:stLexInt:=0;|
      lexSCAL:stLexInt:=0;|
      lexREAL:stLexReal:=0.0;|
      lexSTR:stLexStr[0]:=char(0);|
    end;
    evalOp:=conAdd;
    for evalCo:=1 to topStackCon do
      with lexStackCon[evalCo] do
      case lexStackCon[1].conLex of
        lexINT,lexSCAL:
          case conOp of
            conNULL:evalLong:=conInt;|
            conAnd:evalLong:=evalLong and conInt;|
            conMul:evalLong:=evalLong*conInt;|
            conDiv:if conInt=0 then lexError(Stream,_Деление_на_ноль[envER],nil) else evalLong:=evalLong div conInt end;|
            conMod:if conInt=0 then lexError(Stream,_Деление_на_ноль[envER],nil) else evalLong:=evalLong mod conInt end;|
            conAdd,conSub,conOr:
              case evalOp of
                conAdd:stLexInt:=stLexInt+evalLong;|
                conSub:stLexInt:=stLexInt-evalLong;|
                conOr:stLexInt:=stLexInt or evalLong;|
              end;
              evalOp:=conOp;
              evalLong:=conInt;|
          end;|
        lexREAL:case conOp of
          conNULL:evalReal:=conReal;|
          conMul:evalReal:=evalReal*conReal;|
          conDiv:if conReal=0.0 then lexError(Stream,_Деление_на_ноль[envER],nil) else evalReal:=evalReal/conReal end;|
          conAdd,conSub:
            case evalOp of
              conAdd:stLexReal:=stLexReal+evalReal;|
              conSub:stLexReal:=stLexReal-evalReal;|
            end;
            evalOp:=conOp;
            evalReal:=conReal;|
        end;|
        lexSTR:case conLex of
          lexSTR:
            if lstrlen(stLexStr)+lstrlen(conStr)>=maxText
              then lexError(Stream,_Слишком_длинная_строковая_константа[envER],nil)
              else lstrcat(stLexStr,conStr)
            end;|
          lexCHAR:
            if lstrlen(stLexStr)+1>=maxText
              then lexError(Stream,_Слишком_длинная_строковая_константа[envER],nil)
              else lstrcatc(stLexStr,conChar)
            end;|
        end;|
    end end end;
    if not stErr then
      stLex:=lexStackCon[1].conLex
    end;
    for evalCo:=1 to topStackCon do
      with lexStackCon[evalCo] do
        if conLex=lexSTR then
          memFree(conStr)
        end
      end
    end
  end
  end lexEvalCon;

//----- Анализ уровня 1 (константные выражения) ----------

  procedure lexGetLex1;
  var getOk:boolean; old:string[maxText];
  begin
  with Stream do
    lstrcpy(old,stLexStr);
    lexGetLex0(Stream);
    if (stLex=lexINT)or(stLex=lexSCAL)or(stLex=lexREAL)or(stLex=lexSTR) then
      getOk:=lexFillCon(Stream);
      lexEvalCon(Stream);
    end;
    lstrcpy(stLexOld,old);
  end
  end lexGetLex1;

//=================================================
//                ВНЕШНИЙ ЛЕКСИЧЕСКИЙ АНАЛИЗ
//=================================================

//----------- Получение имени лексемы -----------

  procedure lexLexName;
  begin
  with Stream do
    case lex of
      lexPARSE:lstrcpy(name,namePARSE[classPARSE(val)]);|
      lexREZ:lstrcpy(name,nameREZ  [carSet][classREZ(val)]);|
    else lstrcpy(name,nameLex[lex])
    end;
    return name
  end
  end lexLexName;

//----------- Получение значения лексемы -----------

//  procedure lexLexVal;
//  var s:string[30];
//      trans:record case byte of
//        0:(w0,w1:word);
//        1:(se:set of byte)
//      end;
//  begin
//  with Stream do begin
//    res[0]:=char(0);
//    case lex of
//      lexCHAR:begin res[0]:=char(stLexInt); res[1]:=#0 end;
//      lexSTR,lexID,lexNEW:lstrcpy(res,addr(stLexStr));
//      lexINT,lexNIL,lexFALSE,lexTRUE:wvsprintf(res,'%li',stLexInt);
//      lexTYPE,lexVAR,lexPAR,lexVPAR,lexFIELD,
//      lexPROC :if stLexID<>nil then lstrcpy(res,stLexID^.idName);
//      lexREAL :begin
//        str(stLexReal,s);
//        s[length(s)+1]:=char(0);
//        lstrcpy(res,addr(s[1]))
//      end;
//    else res[0]:=#0
//    end;
//    lexLexVal:=res
//  end
//  end {lexLexVal};

//----------- Внешний анализ уровня 00 ----------

  procedure lexAccept00;
  var s:string[80];
  begin
  with Stream do
    if not ((stLex=lex)and((val=0)or(val=stLexInt))) then
      lexLexName(Stream,lex,val,s);
      lexError(Stream,_Ожидалось_[envER],s)
    end;
    if not stErr then
      lexGetLex00(Stream)
    end
  end
  end lexAccept00;

//----------- Внешний анализ уровня 0 -----------

  procedure lexAccept0;
  var s:string[80];
  begin
  with Stream do
    if not ((stLex=lex)and((val=0)or(val=stLexInt))) then
      lexLexName(Stream,lex,val,s);
      lexError(Stream,_Ожидалось_[envER],s)
    end;
    if not stErr then
      lexGetLex0(Stream)
    end
  end
  end lexAccept0;

//---------- Внешний анализ уровня 1 -------------

  procedure lexAccept1;
  var s:string[80];
  begin
  with Stream do
    if not ((stLex=lex)and((val=0)or(val=stLexInt))) then
      lexLexName(Stream,lex,val,s);
//      lexLexName(Stream,stLex,stLexInt,s);
      lexError(Stream,_Ожидалось_[envER],s);
    end;
    if not stErr then
      lexGetLex1(Stream)
    end
  end
  end lexAccept1;

end SmLex.
