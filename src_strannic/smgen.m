//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль GEN (генерация кода)
//Файл SMGEN.M

implementation module SmGen;
import Win32,Win32Ext,SmSys,SmDat,SmTab;

//===============================================
//           ИНИЦИАЛИЗАЦИЯ И РАЗРУШЕНИЕ
//===============================================

//------------ Инициализация ------------------

  procedure genInitial();
  var i:integer;
  begin
    genPushAX:=-1;
    genPushSI:=-1;
    genCall:=memAlloc(sizeof(lstCall)); genCall^.top:=0;
    genSort:=memAlloc(sizeof(arrSortRes)); topSortRes:=0;
  end genInitial;

//--------------- Закрытие --------------------

  procedure genDestroy();
  begin
    memFree(genCall);
    memFree(genSort);
  end genDestroy;

//===============================================
//             РАБОТА СО СПИСКАМИ
//===============================================
//*
//----- Добавление в список переходов ---------

  procedure genAddJamp;
  begin
  with aList do
    if top=maxJamp then
      lexError(S,_Слишком_много_разделов_IF_или_CASE[envER],nil)
    else inc(top)
    end;
    arr[top].jaddr:=aVal;
    arr[top].jcomm:=aCom;
  end
  end genAddJamp;

//----------- Установка переходов -------------

  procedure genSetJamps;
  var i:integer; l:integer;
  begin
  with aList do
    for i:=1 to top do
      genSetJamp(S,arr[i].jaddr,aVal,arr[i].jcomm)
    end
  end
  end genSetJamps;

//----------- Установка перехода --------------

  procedure genSetJamp;
  var i:integer; l,siz:integer;
  begin
  with tbMod[tekt] do
    case aCom of
      cJL..cJPE:siz:=6;|
      cJMP:siz:=5;|
    else lexError(S,_Системная_в_genSetJamp_[envER],addr(asmCommands[aCom].cNam));
    end;
    l:=aLab-aJamp-siz;
    genCode^[aJamp+siz-3+0]:=lobyte(loword(l));
    genCode^[aJamp+siz-3+1]:=hibyte(loword(l));
    genCode^[aJamp+siz-3+2]:=lobyte(hiword(l));
    genCode^[aJamp+siz-3+3]:=hibyte(hiword(l));
  end
  end genSetJamp;

//----- Добавление в список вызовов -----------

  procedure genAddCall(var S:recStream; aSou:integer; aProc:pID);
  begin
  with genCall^ do
    if top=maxCall
      then lexError(S,_Слишком_много_вызовов_процедур_в_модуле[envER],nil)
      else inc(top)
    end;
    arr[top].callSou:=aSou;
    arr[top].callProc:=aProc;
  end
  end genAddCall;

//--------- Установка вызовов -----------------

  procedure genSetCalls(var S:recStream; var calls:lstCall; nom:integer; bitMessage:boolean);
  var i,l,f:integer;
  begin
  with tbMod[nom],calls do
    topProCall:=0;
    for i:=1 to top do
    with arr[i],callProc^ do
      if (idProcAddr=-1)and(idNom=nom) then if bitMessage then lexError(S,_Не_определена_процедура_[envER],idName) end
      elsif (callSou+2+0<=0)or(callSou+2+3>topCode) then lexError(S,_Системная_ошибка_в_GenSetCalls[envER],nil)
      elsif (idNom<>nom)or(idProcCla<>nil) then genAddProCall(S,nom,idNom,callSou+2,idName);
      else
        l:=idProcAddr-callSou-5;
        genCode^[callSou+2+0]:=lobyte(loword(l));
        genCode^[callSou+2+1]:=hibyte(loword(l));
        genCode^[callSou+2+2]:=lobyte(hiword(l));
        genCode^[callSou+2+3]:=hibyte(hiword(l));
      end;
    end end
  end
  end genSetCalls;

//--------- Вызов глобальной переменной -----------------

  procedure genAddVarCall(var S:recStream; tekno,no,track:integer; cl:classVarCall; cla:pstr);
  begin
    with tbMod[tekno] do
      if topVarCall=maxVarCall then lexError(S,_Слишком_много_обращений_к_переменным_в_модуле[envER],nil)
      else
        inc(topVarCall);
        genVarCall^[topVarCall].track:=track;
        genVarCall^[topVarCall].no:=no;
        genVarCall^[topVarCall].cl:=cl;
        if cla=nil then genVarCall^[topVarCall].cla:=nil
        else
          genVarCall^[topVarCall].cla:=memAlloc(lstrlen(cla)+1);
          lstrcpy(genVarCall^[topVarCall].cla,cla);
        end
      end
    end
  end genAddVarCall;

//--------- Вызов процедуры из другого модуля -----------------

  procedure genAddProCall(var S:recStream; tekno,no,track:integer; sou:pstr);
  begin
    with tbMod[tekno] do
      if topProCall=maxProCall then lexError(S,_Слишком_много_вызовов_внешних_процедур_в_модуле[envER],nil)
      else
        inc(topProCall);
        genProCall^[topProCall].track:=track;
        genProCall^[topProCall].sou:=memAlloc(lstrlen(sou)+1); lstrcpy(genProCall^[topProCall].sou,sou);
        genProCall^[topProCall].mo:=memAlloc(lstrlen(tbMod[no].modNam)+1); lstrcpy(genProCall^[topProCall].mo,tbMod[no].modNam);
      end
    end
  end genAddProCall;

//--------- Определение смещения процедуры -----------------

  procedure genGetProcTrack(var S:recStream; mo,sou:pstr):integer;
  var i,no:integer; id:pID;
  begin
    no:=0;
    id:=nil;
    for i:=1 to topMod do
      if lstrcmp(tbMod[i].modNam,mo)=0 then
        no:=i;
      end
    end;
    if no>0 then
      id:=idFind(tbMod[no].modTab,sou);
    end;
    if no=0 then lexError(S,_Не_найден_модуль_[envER],mo)
    elsif id=nil then lexError(S,_Не_найден_идентификатор_[envER],sou)
    elsif id^.idClass<>idPROC then lexError(S,_Не_найдена_функция_[envER],sou)
    else return tbMod[no].genBegCode+id^.idProcAddr
    end;
    return 0
  end genGetProcTrack;

//===============================================
//             РАЗМЕЩЕНИЕ КОНСТАНТ
//===============================================

//----------- Размещение байта ----------------

  procedure genPutByte;
  begin
  with tbMod[tekt] do
    if topData=maxData then lexError(Stream,_Слишком_много_структурных_констант[envER],nil)
    else
      inc(topData);
      genData^[topData]:=putByte;
      return topData-1
    end
  end
  end genPutByte;

//----------- Размещение строки ---------------

  procedure genPutStr;
  var i,res:integer;
  begin
  with tbMod[tekt] do
    res:=topData;
    for i:=0 to lstrlen(putStr) do
      case putStr[i] of
       '\':if putStr[i+1]<>'0' then genPutByte(Stream,byte(putStr[i])) end;|
       '0':if (i>0)and(putStr[i-1]='\')and not((i>1)and(putStr[i-2]='\'))
             then genPutByte(Stream,0)
             else genPutByte(Stream,byte(putStr[i]))
           end;|
      else genPutByte(Stream,byte(putStr[i]))
      end
    end;
    return res
  end
  end genPutStr;

//----------- Размещение массива --------------

  procedure genPutVar;
  var i,res:integer;
  begin
  with tbMod[tekt] do
    res:=topData;
    for i:=1 to putLen do
      genPutByte(Stream,byte(putVar[i-1]))
    end;
    return res
  end
  end genPutVar;

//===============================================
//                РАЗМЕЩЕНИЕ КОДА
//===============================================

//----------- Размещение байта ----------------

  procedure genByte(var Stream:recStream; b:byte);
  begin
  with tbMod[tekt] do
    if topCode=maxCode
      then lexError(Stream,_Слишком_большой_код[envER],"")
      else inc(topCode)
    end;
    genCode^[topCode]:=b
  end
  end genByte;

//----------- Размещение слова ----------------

  procedure genCard(var Stream:recStream; w:cardinal; bitW:boolean);
  begin
    genByte(Stream,lobyte(loword(w)));
    if bitW then
      genByte(Stream,hibyte(loword(w)))
    end
  end genCard;

//------- Размещение двойного слова -----------

  procedure genLong(var Stream:recStream; l:integer; W:cardinal);
  begin
    genByte(Stream,lobyte(loword(l)));
    if W>1 then
      genByte(Stream,hibyte(loword(l)));
      if W>2 then
        genByte(Stream,lobyte(hiword(l)));
        genByte(Stream,hibyte(hiword(l)));
      end
    end
  end genLong;

//----------- Префикс сегмента ----------------

  procedure genPref;
  begin
    case prefReg of
      regNULL:|
      rCS:genByte(Stream,0x2E);|
      rSS:genByte(Stream,0x36);|
      rDS:genByte(Stream,0x3E);|
      rES:genByte(Stream,0x26);|
    else mbS(_genPref_Системная_ошибка[envER])
    end
  end genPref;

//----------- Байт команды --------------------

  procedure genFirst(var Stream:recStream; firstCod,firstPri:byte; D,W:cardinal);
  begin
  with tbMod[tekt] do
    lexTest((envError>0)and(genBegCode+topCode>=envError),Stream,_Место_ошибки_обнаружено[envER],nil);
    if firstPri and 2<>0 then if D<>0 then firstCod:=firstCod or 2 end end;
    if firstPri and 1<>0 then if (W=2)or(W=4) then firstCod:=firstCod or 1 end end;
    genByte(Stream,firstCod);
  end
  end genFirst;

//-------- Постбайт и смещение команды --------

  procedure genPost(var S:recStream; PostExt:byte; Base,Indx:classRegister; Dist:integer);
  var md,rm:byte;
  begin
//только BP
    if (Base=rEBP)and(Indx=regNULL)and(Dist=0) then
      genByte(S,0x45 or PostExt);
      genByte(S,0)
//только смещение
    elsif (Base=regNULL)and(Indx=regNULL) then
      genByte(S,0x05 or PostExt);
      genLong(S,Dist,4)
//без смещения
    elsif Dist=0 then
      case Base of
        regNULL:case Indx of
          rEAX:genByte(S,0x00 or PostExt);|
          rESI:genByte(S,0x06 or PostExt);|
          rEDI:genByte(S,0x07 or PostExt);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        rEBX:case Indx of
          regNULL:genByte(S,0x03 or PostExt);|
          rESI:genByte(S,0x04 or PostExt); genByte(S,0x33);|
          rEDI:genByte(S,0x04 or PostExt); genByte(S,0x3B);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        rEBP:case Indx of
          rESI:genByte(S,0x44 or PostExt); genByte(S,0x33); genByte(S,0x00);|
          rEDI:genByte(S,0x44 or PostExt); genByte(S,0x3B); genByte(S,0x00);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        else lexError(S,_Неверная_команда__genPost_[envER],"");
      end
//со смещением байт
    elsif (Dist<=127)and(Dist>=-128) then
      case Base of
        regNULL:case Indx of
          rEAX:genByte(S,0x40 or PostExt);|
          rESI:genByte(S,0x46 or PostExt);|
          rEDI:genByte(S,0x47 or PostExt);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        rEBX:case Indx of
          regNULL:genByte(S,0x43 or PostExt);|
          rESI:genByte(S,0x44 or PostExt); genByte(S,0x33);|
          rEDI:genByte(S,0x44 or PostExt); genByte(S,0x3B);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        rEBP:case Indx of
          regNULL:genByte(S,0x45 or PostExt);|
          rESI:genByte(S,0x44 or PostExt); genByte(S,0x35);|
          rEDI:genByte(S,0x44 or PostExt); genByte(S,0x3D);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
      end;
      genByte(S,Dist)
//со смещением long
    else
      case Base of
        regNULL:case Indx of
          rEAX:genByte(S,0x80 or PostExt);|
          rESI:genByte(S,0x86 or PostExt);|
          rEDI:genByte(S,0x87 or PostExt);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        rEBX:case Indx of
          regNULL:genByte(S,0x83 or PostExt);|
          rESI:genByte(S,0x84 or PostExt); genByte(S,0x33);|
          rEDI:genByte(S,0x84 or PostExt); genByte(S,0x3B);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        rEBP:case Indx of
          regNULL:genByte(S,0x85 or PostExt);|
          rESI:genByte(S,0x84 or PostExt); genByte(S,0x35); genByte(S,0x00);|
          rEDI:genByte(S,0x84 or PostExt); genByte(S,0x3D); genByte(S,0x00);|
          else lexError(S,_Неверная_команда__genPost_[envER],"");
        end;|
        else lexError(S,_Неверная_команда__genPost_[envER],"");
      end;
      genLong(S,Dist,4)
    end
  end genPost;

//------- Команды сегментных регистров --------

  procedure genSeg;
  begin
    case Instr of
      cMOV:
        if (Reg1 in [rCS..rGS]) and (Reg2 in [rCS..rGS]) then
          lexError(Stream,_Неверные_операнды[envER],"")
        end;
        if Reg1 in [rCS..rGS] then
          if Reg1 in [rFS,rGS] then
            genByte(Stream,0x66)
          end;
          genByte(Stream,0x8E);
          if Reg1 in [rFS..rGS]
            then genByte(Stream,0xC0 or asmRegs[Reg1].rCo*8 or asmRegs[Reg2].rCo)
            else genByte(Stream,0xD0 or asmRegs[Reg1].rCo*8 or asmRegs[Reg2].rCo)
          end
        else
          if Reg2 in [rFS..rGS] then
            genByte(Stream,0x66)
          end;
          genByte(Stream,0x8C);
          if Reg2 in [rFS..rGS]
            then genByte(Stream,0xC0 or asmRegs[Reg2].rCo*8 or asmRegs[Reg1].rCo)
            else genByte(Stream,0xD0 or asmRegs[Reg2].rCo*8 or asmRegs[Reg1].rCo)
          end
        end;|
      cPOP:case Reg1 of
        rCS..rES:genByte(Stream,0x00 or asmRegs[Reg1].rCo*8 or 7);|
        rFS:genByte(Stream,0x0F); genByte(Stream,0xA1);|
        rGS:genByte(Stream,0x0F); genByte(Stream,0xA9);|
      end;|
      cPUSH:case Reg1 of
        rCS..rES:genByte(Stream,0x00 or asmRegs[Reg1].rCo*8 or 6);|
        rFS:genByte(Stream,0x0F); genByte(Stream,0xA0);|
        rGS:genByte(Stream,0x0F); genByte(Stream,0xA8);|
      end;|
    else lexError(Stream,_Системная_в_GenSeg[envER],"");
    end
  end genSeg;

//-------- Команды регистр-регистр ------------

  procedure genRR;
  begin
  with asmCommands[Instr] do
    if not (Instr in [loMDCom..hiMDCom]) then
      lexError(Stream,_Системная_в_GenRR[envER],"")
    end;
    if (Instr=cMOV) and ((Reg1 in [rCS..rGS])or (Reg2 in [rCS..rGS])) then
      genSeg(Stream,Instr,Reg1,Reg2)
    else
      if Reg1 in [rAX..rDI] then genByte(Stream,0x66) end;
      if Instr in [cBT..cBTS] then
        genByte(Stream,0x0F);
      end;
      if Reg1 in [rAL..rDH] then genFirst(Stream,cCod,cPri,1,1)
      elsif Reg1 in [rAX..rDI] then genFirst(Stream,cCod,cPri,1,2)
      else genFirst(Stream,cCod,cPri,1,4)
      end;
      genByte(Stream,0xC0 or asmRegs[Reg1].rCo*8 or asmRegs[Reg2].rCo);
    end
  end
  end genRR;

//------- Команды регистр-константа -----------

  procedure genRD;
  var W:cardinal;
  begin
  with asmCommands[Instr] do
    if not ((Instr in [loMDCom..hiMDCom]) or (Instr in [loRCom..hiRCom])) then
      lexError(Stream,_Системная_в_GenRD[envER],"")
    end;
    if Reg in [rAL..rDH] then W:=1
    elsif Reg in [rAX..rDI] then W:=2
    else W:=4
    end;
    if W=2 then genByte(Stream,0x66) end;
    if Instr in [cBT..cBTS] then
      genByte(Stream,0x0F);
    end;
    if Instr in [loMDCom..hiMDCom] then
      genFirst(Stream,cDat,cPri,0,W);
      genByte(Stream,0xC0 or cExt or asmRegs[Reg].rCo);
      if Instr in [cBT..cBTS]
        then genLong(Stream,Data,1)
        else genLong(Stream,Data,W)
      end
    else //rol
      genFirst(Stream,cDat and 0xEF,cPri,1,W);
      genByte(Stream,0xC0 or cExt or asmRegs[Reg].rCo);
      if Data>31 then
        lexError(Stream,'В команде сдвига операнд должен быть меньше 32',nil)
      end;
      genByte(Stream,Data)
    end
  end
  end genRD;

//----------- Команды регистр-память ----------

  procedure genMR;
//  {D: 0-MR, 1-RM}
  begin
  with asmCommands[Instr] do
    if not (Instr in [loMDCom..hiMDCom]) then
      lexError(Stream,_Системная_в_GenMR_[envER],addr(cNam))
    end;
    if Reg in [rAX..rDI] then genByte(Stream,0x66) end;
    if Instr in [cBT..cBTS] then
      genByte(Stream,0x0F);
    end;
    genPref(Stream,PrefS);
    if Reg in [rAL..rDH] then genFirst(Stream,cCod,cPri,D,1)
    elsif Reg in [rAX..rDI] then genFirst(Stream,cCod,cPri,D,2)
    else genFirst(Stream,cCod,cPri,D,4)
    end;
    genPost(Stream,asmRegs[Reg].rCo*8,Base,Indx,Dist);
  end
  end genMR;

//----------- Команды память-константа --------

  procedure genMD(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx:classRegister; Dist,Data:integer; W:cardinal);
  begin
  with asmCommands[Instr] do
    if not (Instr in [loMDCom..hiMDCom]) then
      lexError(Stream,_Системная_в_GenMD[envER],"")
    end;
    if W=2 then genByte(Stream,0x66) end;
    if Instr in [cBT..cBTS] then
      genByte(Stream,0x0F);
    end;
    genPref(Stream,PrefS);
    genFirst(Stream,cDat,cPri,0,W);
    genPost(Stream,cExt,Base,Indx,Dist);
    if Instr in [cBT..cBTS]
      then genLong(Stream,Data,1)
      else genLong(Stream,Data,W)
    end
  end
  end genMD;

//----------- Команды сопроцессора ------------

  procedure genST;
  begin
  with asmCommands[Instr] do
    genByte(Stream,0xD8 or (cDat div 32));
    genByte(Stream,0xC0 or (cDat mod 8) or asmRegs[Reg].rCo);
  end
  end genST;

//----------- Команды _регистр[envER] ---------------

  procedure genR;
  var Cod:byte;
  begin
  with tbMod[tekt] do
//оптимизация
    if (Instr=cPUSH)and(Reg=rEAX) then genPushAX:=topCode+1 end;
    if (Instr=cPUSH)and(Reg=rESI) then genPushSI:=topCode+1 end;
//обработка команды
  with asmCommands[Instr] do
    Cod:=cCod;
    if not ((Instr in [loMCom..hiMCom]) or (Instr in [loRCom..hiRCom]) or (Instr in [loFRCom..hiFRCom])) then
      lexError(Stream,_Системная_в_GenR[envER],"")
    end;
    if Reg in [rCS..rGS] then genSeg(Stream,Instr,Reg,regNULL)
    elsif Instr=cPUSH then genByte(Stream,0x50 or asmRegs[Reg].rCo)
    elsif Instr=cPOP then genByte(Stream,0x58 or asmRegs[Reg].rCo)
    elsif Instr=cFFREE then
      genByte(Stream,cCod);
      genByte(Stream,cDat or asmRegs[Reg].rCo);
    else
      if Instr in [loRCom..hiRCom] then
        Cod:=cDat
      end;
      if Reg in [rAL..rDH] then genFirst(Stream,Cod,cPri,1,1)
      elsif Reg in [rAX..rDI] then genByte(Stream,0x66); genFirst(Stream,Cod,cPri,1,2)
      else genFirst(Stream,Cod,cPri,1,4)
      end;
      genByte(Stream,0xC0 or cExt or asmRegs[Reg].rCo);
    end;
    if Instr=cPOP then dec(genStack,4) end;
    if Instr=cPUSH then inc(genStack,4) end;
  end
  end
  end genR;

//----------- Команды _память[envER] ----------------

  procedure genM;
  var Cod:byte;
  begin
  with asmCommands[Instr] do
    Cod:=cCod;
    if (Instr in setComFsize)and(W=4) then
      Cod:=Cod and not 0x04;
    end;
    if not (
      (Instr in [cCALLF]) or
      (Instr in [loMCom..hiMCom]) or
      (Instr in [loRCom..hiRCom]) or
      (Instr in [loFMRCom..hiFMRCom]) or
      (Instr in [loFIMCom..hiFIMCom]) or
      (Instr in [loFMCom..hiFMCom])) then
        lexError(Stream,_Системная_в_GenM_[envER],addr(asmCommands[Instr].cNam))
    end;
    genPref(Stream,PrefS);
    if W=2 then genByte(Stream,0x66) end;
    genFirst(Stream,Cod,cPri,1,W);
    genPost(Stream,cExt,Base,Indx,Dist);
    if Instr=cPOP then dec(genStack,4) end;
    if Instr=cPUSH then inc(genStack,4) end;
  end
  end genM;

//- Команды с непосредственным операндом ------

  procedure genD;
  begin
  with asmCommands[Instr],tbMod[tekt] do
    if not ((Instr=cRET)or(Instr=cINT)or(Instr=cPUSH)) then
      lexError(Stream,_Системная_в_GenD[envER],"")
    end;
    case Instr of
      cINT:genFirst(Stream,cDat,cPri,0,1); genByte(Stream,D);|
      cPUSH:
        if (D>=-128)and(D<=127)
          then genFirst(Stream,0x6A,cPri,0,1)
          else genFirst(Stream,cDat,cPri,0,1)
        end;
        if (D>=-128)and(D<=127)
          then genByte(Stream,byte(D))
          else genLong(Stream,D,4)
        end;|
      cRET:
        if D=0
          then genFirst(Stream,cCod,cPri,0,1)
          else genFirst(Stream,cDat,cPri,0,1)
        end;
        if D<>0 then
          genCard(Stream,D,true)
        end;|
    end;
    if Instr=cPUSH then
      inc(genStack,4)
    end
  end
  end genD;

//--------- Команды без параметров ------------

  procedure genGen(var Stream:recStream; Instr:classCommand; W:integer);
  begin
  with asmCommands[Instr] do
    if not (
      Instr in [loNCom..hiNCom,loLCom..hiLCom,loFCom..hiFCom,
        cAAM,cAAD,cCALL,cENTER,cLEAVE]) then
        lexError(Stream,_Системная_ошибка_в_genGen_[envER],addr(asmCommands[Instr].cNam))
    end;
    if Instr in [cJL..cJPE] then
      genByte(Stream,0x0F)
    end;
    genFirst(Stream,cCod,cPri,0,0);
    case Instr of
      cCALL,cJMP:genLong(Stream,W,4);|
      cJCXZ..cLOOP:genByte(Stream,W);|
      cJL..cJPE:genLong(Stream,W,4);|
      cENTER:genCard(Stream,W,true); genByte(Stream,0);|
      loFCom..hiFCom:genByte(Stream,cDat);|
    end
  end
  end genGen;

//--------- Генерация ROL REG,CL --------------

  procedure genRegCL;
  begin
  with asmCommands[Instr] do
    if not (Instr in [loRCom..hiRCom]) then
      lexError(Stream,_Системная_ошибка_в_genRCL[envER],nil)
    end;
    if Reg in [rAL..rDH] then genFirst(Stream,cDat or 2,cPri,1,1)
    elsif Reg in [rAX..rDI] then genByte(Stream,0x66); genFirst(Stream,cDat or 2,cPri,1,1)
    else genFirst(Stream,cDat or 2,cPri,1,4)
    end;
    genByte(Stream,0xC0 or cExt or asmRegs[Reg].rCo);
  end
end genRegCL;

//----------- Оптимизация POP -----------------

  procedure genPOP;
  begin
  with tbMod[tekt] do
    if not bitAND and(Reg=rEAX)and(genPushAX=topCode) then dec(topCode)
    elsif not bitAND and(Reg=rESI)and(genPushSI=topCode) then dec(topCode)
    else genR(Stream,cPOP,Reg)
    end
//    genR(Stream,cPOP,Reg)
  end
  end genPOP;

//===============================================
//             ГЕНЕРАЦИЯ И ИМПОРТ I-ФАЙЛА
//===============================================

//------------- Запись BMP в файл ------------------

procedure genBmpWrite(fil:integer; modBMP:pBMPs; topBMP:integer);
var i,j:integer;
begin
  for i:=1 to topBMP do
  with modBMP^[i] do
    _lwrite(fil,addr(modBMP^[i]),sizeof(recBMP));
    idWriteS(fil,bmpName);
    idWriteS(fil,bmpFile);
  end end;
end genBmpWrite;

//------------- Чтение BMP из файла ------------------

procedure genBmpRead(fil:integer; modBMP:pBMPs; topBMP:integer);
var i,j:integer;
begin
  for i:=1 to topBMP do
  with modBMP^[i] do
    _lread(fil,addr(modBMP^[i]),sizeof(recBMP));
    idReadS(fil,bmpName);
    idReadS(fil,bmpFile);
  end end;
end genBmpRead;

//------------- Запись DLG в файл ------------------

procedure genDlgWrite(fil:integer; modDlg:pDlgs; topMDlg:integer);
var i,j,k:integer;
begin
  for i:=1 to topMDlg do
  with modDlg^[i]^ do
    _lwrite(fil,addr(modDlg^[i]^),sizeof(recMDialog));
    for k:=0 to mdTop do
    with mdCon[k]^ do
      _lwrite(fil,addr(mdCon[k]^),sizeof(recMItem));
      idWriteS(fil,miTxt);
      idWriteS(fil,miNam);
      idWriteS(fil,miCla);
      idWriteS(fil,miFont);
    end end;
  end end;
end genDlgWrite;

//------------- Чтение DLG из файла ------------------

procedure genDlgRead(fil:integer; modDlg:pDlgs; topMDlg:integer);
var i,j,k:integer;
begin
  for i:=1 to topMDlg do
    modDlg^[i]:=memAlloc(sizeof(recMDialog));
  with modDlg^[i]^ do
    _lread(fil,addr(modDlg^[i]^),sizeof(recMDialog));
    for k:=0 to mdTop do
      mdCon[k]:=memAlloc(sizeof(recMItem));
    with mdCon[k]^ do
      _lread(fil,addr(mdCon[k]^),sizeof(recMItem));
      idReadS(fil,miTxt);
      idReadS(fil,miNam);
      idReadS(fil,miCla);
      idReadS(fil,miFont);
    end end;
  end end;
end genDlgRead;

//===============================================
//             ГЕНЕРАЦИЯ EXE-ФАЙЛА
//===============================================

//------------- Выравнивание ------------------

procedure genAlign;
begin
  if align=0 then return siz
  elsif siz mod align=0 then return siz
  else return siz - siz mod align + align
  end
end genAlign;

//------------- Размеры таблиц ----------------

procedure genSize(sTab:classExe; align:integer):integer;
var sSize:integer; i,j,globalICON:integer; f:pID;
begin
  sSize:=0;
  case sTab of
    exeOld:sSize:=sizeof(arrOldHeader);|
    exeHeader:sSize:=sizeof(recWinHeader);|
    exeSect:sSize:=sizeof(arrSection);|
    exeData:
      for i:=1 to topMod do
        inc(sSize,tbMod[i].topData);
      end;|
    exeIData:if gloImport=nil then mbS(_Системная_в_genSize[envER])
    else
      sSize:=0;
      for i:=1 to gloTop do
      with gloImport^[i] do
        inc(sSize,sizeof(imageImportDesctriptor));
        inc(sSize,lstrlen(impName)+1);
        for j:=1 to impTop do
        with impFuns^[j] do
          inc(sSize,4);
          inc(sSize,lstrlen(funName)+3)
        end end;
        inc(sSize,4) //{0 элемент}
      end end;
      inc(sSize,sizeof(imageImportDesctriptor)) //{0 элемент}
    end;|
    exeEData:if gloExport=nil then mbS(_Системная_в_genSize_2[envER])
    else
      sSize:=sizeof(imageExportDesctriptor)+gloTopExp*4+gloTopExp*4+gloTopExp*2;
      for i:=1 to gloTopExp do
        inc(sSize,lstrlen(gloExport^[i])+1);
      end;
      inc(sSize,lstrlen(genNameModule)+1); //имя файла
    end;|
    exeText:
      for i:=1 to topMod do
        inc(sSize,tbMod[i].topCode)
      end;|
    exeRsrc:
//    заголовок секции
      sSize:=0x30+0x10+0x10+0x10+0x10+0x10+0x28;
      for i:=1 to topMod do
      with tbMod[i] do
        for j:=1 to topMDlg do
//        directory_entry и data_entry
          inc(sSize,16+8);
//        имя ресурса
          inc(sSize,genAlign((lstrlen(modDlg^[j]^.mdCon[0]^.miNam)+1)*2,4));
//        размер диалога
          inc(sSize,genSizeDlg(i,j))
        end;
        for j:=1 to topBMP do
//        directory_entry и data_entry
          inc(sSize,16+8);
//        имя ресурса
          inc(sSize,genAlign((lstrlen(modBMP^[j].bmpName)+1)*2,4));
//        размер bmp
          inc(sSize,modBMP^[j].bmpSize)
        end;
      end end;
//    иконка
      globalICON:=0;
      for i:=1 to topMod do
      with tbMod[i] do
        if modICON<>nil then
          globalICON:=1;
        end
      end end;
      if globalICON>0 then
      //каталоги icon и group
        inc(sSize,8+16+8);
        inc(sSize,8+16+8);
      //входы и образы icon и group
        inc(sSize,16);
        inc(sSize,16);
        inc(sSize,sizeof(res_icon)+0x2e8);
      end;|
  end;
  return genAlign(sSize,align)
end genSize;

//------ Генерация списка импорта -------------

procedure genGloImport();
var m,i,j:integer;
begin
  impDestroy(gloImport,gloTop);
  gloImport:=memAlloc(sizeof(arrIMPORT));
  gloTop:=0;
  for m:=1 to topMod do
  with tbMod[m] do
    for i:=1 to topImport do
    with genImport^[i] do
      for j:=1 to impTop do
      with impFuns^[j] do
        impAdd(gloImport,impName,funName,0,gloTop);
      end end
    end end
  end end
end genGloImport;

//------ Генерация списка экспорта -------------

procedure genGloExport();
var m,i:integer;
begin
  expDestroy(gloExport,gloTopExp);
  gloExport:=memAlloc(sizeof(arrEXPORT));
  gloTopExp:=0;
  for m:=1 to topMod do
  with tbMod[m] do
    for i:=1 to topExport do
      expAdd(gloExport,genExport^[i],gloTopExp);
    end
  end end
end genGloExport;

//--------- Поиск базового класса ----------------

procedure genBaseCla(cla:pID):pID;
begin
  while (cla^.idRecCla<>cla^.idOwn)and(cla^.idRecCla<>nil) do
    cla:=cla^.idRecCla
  end;
  return cla
end genBaseCla;

//-------------- Поиск метода -------------------

procedure genFindMetod(Class:pID; name:pstr):pID;
var car,res:pID; s:string[maxText];
begin
  res:=nil;
  car:=Class;
  repeat
  with car^ do
    lstrcpy(s,idName);
    lstrcatc(s,'.');
    lstrcat(s,name);
    res:=listFind(idRecMet,idRecTop,s);
    if idRecCla<>idOwn
      then car:=idRecCla
      else car:=nil
    end
  end
  until (res<>nil)or(car=nil);
  return res
end genFindMetod;

//------ размещение элемента в таблице классов -------------

procedure genClassAlloc(var S:recStream; met:integer; var top:integer; main:integer);
begin
  with tbMod[main] do
  if top+4>genCLASSSIZE then lexError(S,_Превышение_размера_таблицы_классов[envER],nil);
  else
    genData^[maxWith*4+top+1]:=lobyte(loword(met));
    genData^[maxWith*4+top+2]:=hibyte(loword(met));
    genData^[maxWith*4+top+3]:=lobyte(hiword(met));
    genData^[maxWith*4+top+4]:=hibyte(hiword(met));
    inc(top,4)
  end end;
end genClassAlloc;

//------ Генерация списка классов -------------

procedure genClassCreate(var S:recStream; id:pID; cla:pClasses; var top:integer);
var no,i:integer; bas:pID; s:pstr; //не менять на string !
begin
  if id=nil then //начальный вызов
    top:=0;
    for no:=1 to topMod do
      if tbMod[no].modTab<>nil then
        genClassCreate(S,tbMod[no].modTab,cla,top);
      end
    end
  else //рекурсивный вызов
  with id^ do
    if (idClass=idtREC)and(idRecCla<>nil)and(idNom>0)and(idNom<=topt) then
      bas:=genBaseCla(id);
      no:=0;
      for i:=1 to top do
      if cla^[i].claBas=bas then
        no:=i
      end end;
      if no=0 then
        if top=maxClasses
          then lexError(S,_Слишком_много_классов[envER],nil)
          else inc(top)
        end;
        no:=top;
        with cla^[no] do
          claBas:=bas;
          claList:=memAlloc(sizeof(arrLIST));
          claListTop:=0;
          claName:=memAlloc(sizeof(arrName));
          claNameTop:=0;
          claAddr:=memAlloc(sizeof(arrLIST));
        end
      end;
      with cla^[no] do
        listAdd(claList,id,claListTop);
        for i:=1 to idRecTop do
          s:=memAlloc(maxText);
          lstrcpy(s,idRecMet^[i]^.idName);
          lstrdel(s,0,lstrposc('.',s)+1);
          if nameFind(claName,claNameTop,s)=0 then
            nameAdd(claName,s,claNameTop)
          end;
          memFree(s)
        end
      end
    end;
    if idLeft<>nil then genClassCreate(S,idLeft,cla,top) end;
    if idRight<>nil then genClassCreate(S,idRight,cla,top) end;
  end end
end genClassCreate;

//------ очистка списка классов -------------

procedure genClassFree(cla:pClasses; top:integer);
var i,j:integer;
begin
  for i:=1 to top do
  with cla^[i] do
    memFree(claList);
    memFree(claAddr);
    for j:=1 to claNameTop do
      memFree(claName^[j])
    end;
    memFree(claName);
  end end
end genClassFree;

//------ генерация таблицы классов -------------

procedure genClassTable(var S:recStream; cla:pClasses; top,main:integer);
var topTable,gru,nom,add,i:integer; s:string[maxText]; met:pID;
begin
  topTable:=0;
//адреса методов
  for gru:=1 to top do
  with cla^[gru] do
    for nom:=1 to claListTop do
    with claList^[nom]^ do
      claAddr^[nom]:=address(genBASECODE+0x1000+tbMod[main].genBegData+maxWith*4+topTable);
      for i:=1 to claNameTop do
        met:=genFindMetod(claList^[nom],claName^[i]);
        if met=nil
          then add:=0
          else add:=genBASECODE+WinHeader.baseOfCode+tbMod[met^.idNom].genBegCode+met^.idProcAddr;
        end;
        genClassAlloc(S,add,topTable,main);
      end
    end end
  end end;
//адреса классов
  genClassBegin:=genBASECODE+0x1000+tbMod[main].genBegData+maxWith*4+topTable;
  for gru:=1 to top do
  with cla^[gru] do
    for nom:=1 to claListTop do
      genClassAlloc(S,integer(claAddr^[nom]),topTable,main);
    end
  end end
end genClassTable;

//------ поиск класса в таблице классов -------------

procedure genClassFind(cla:pClasses; top:integer; name:pstr):integer;
var nom,gru,car:integer;
begin
  car:=0;
  for gru:=1 to top do
  with cla^[gru] do
    for nom:=1 to claListTop do
      inc(car);
      if lstrcmp(name,claList^[nom]^.idName)=0 then
        return car
      end
    end
  end end;
  mbS("System error in genClassFind");
  return 0
end genClassFind;

//------ поиск метода в таблице классов -------------

procedure genClassMet(cla:pClasses; top:integer; name:pstr):integer;
var nom,gru,car,i:integer; s:string[maxText];
begin
  for gru:=1 to top do
  with cla^[gru] do
    for nom:=1 to claListTop do
    with claList^[nom]^ do
      for i:=1 to idRecTop do
      if lstrcmp(name,idRecMet^[i]^.idName)=0 then
        lstrcpy(s,name);
        lstrdel(s,0,lstrposc('.',s)+1);
        car:=nameFind(claName,claNameTop,s);
        if car>0 then
          return car
        end
      end end
    end end
  end end;
  mbS("System error in genClassMet");
  return 0
end genClassMet;

//------------ Заголовок файла ----------------

procedure genWinHeader();
var i:integer;
begin with WinHeader do
  signature[0]:='P'; 
  signature[1]:='E'; 
  signature[2]:='\0';
  signature[3]:='\0';
  machine:=0x14C;
  numSection:=5;
  TimeDateStamp:=0x073924CA;
  begSymbolTable:=0;
  numSymbolTable:=0;
  sizeOptionHeader:=0x00E0;
  if not traMakeDLL then flags:=0x010e else flags:=0x210e end;

  magic:=0x010B;
  linkerVersion:=3;//0x1902;
  sizeOfCode:=genSize(exeText,0x1000);
  sizeOfIniData:=genSize(exeData,0x1000);
  sizeOfUnIniData:=0;
  entryPoint:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000)+tbMod[genEntryNo].genBegCode+genEntry;
  baseOfCode:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000);
  baseOfData:=0x1000;
  imageBase:=genBASECODE;
  sectionAlgnment:=0x1000;
  fileAlgnment:=0x200;
  osVersion:=4;//1;
  imageVersion:=0;
  subsystVersion:=4;
  reserved1:=0;
  sizeofImage:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000)+genSize(exeText,0x1000)+genSize(exeRsrc,0x1000);
  sizeofHeaders:=genAlign(sizeof(arrOldHeader)+sizeof(recWinHeader)+sizeof(arrSection),0x200);
  checkSum:=0;
  subSystem:=2;
  dllFlags:=0;
  if not traMakeDLL then stackReserve:=genSTACKMAX else stackReserve:=0 end;
  if not traMakeDLL then stackCommit:=genSTACKMIN else stackCommit:=0 end;
  heapReserve:=genHEAPMAX;
  heapCommit:=genHEAPMIN;
  loaderFlags:=0;
  numRvaAndSizes:=16;
  for i:=0 to 15 do
  with dirs[i] do
    case i of
      0://экспорт
        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000);
        vsize:=genSize(exeEData,0);|
      1://импорт
        virtualAddress:=0x1000+genSize(exeData,0x1000);
        vsize:=genSize(exeIData,0);|
      2://ресурсы
        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000)+genSize(exeText,0x1000);
        vsize:=genSize(exeRsrc,0);|
      else
        virtualAddress:=0;
        vsize:=0;
    end
  end end
end
end genWinHeader;

//------------ Утилиты генерации --------------

procedure genWriteB(gFile:integer; b:byte);
begin
  _lwrite(gFile,addr(b),1);
end genWriteB;

procedure genWriteW(gFile:integer; w:word);
begin
  _lwrite(gFile,addr(w),2);
end genWriteW;

procedure genWriteL(gFile:integer; l:integer);
begin
  _lwrite(gFile,addr(l),4);
end genWriteL;

procedure genWriteS(gFile:integer; s:pstr);
begin
  _lwrite(gFile,s,lstrlen(s))
end genWriteS;

procedure genWriteAlign(gFile,align:integer);
begin
  while (align<>0)and(_lsize(gFile) mod align<>0) do
    genWriteB(gFile,0);
  end
end genWriteAlign;

//--- Размеры элементов таблицы импорта -------

procedure genTrackDLL(dll:integer):integer;
var res,i:integer;
begin
  res:=0;
  for i:=1 to dll-1 do
  with gloImport^[i] do
    inc(res,lstrlen(impName)+1);
  end end;
  return res
end genTrackDLL;

procedure genTrackFun(dll,fun:integer):integer;
var res,i:integer;
begin
with gloImport^[dll] do
  res:=0;
  for i:=1 to fun-1 do
  with impFuns^[i] do
    inc(res,lstrlen(funName)+3)
  end end;
  return res
end
end genTrackFun;

procedure genTrackThunk(dll:integer):integer;
var res,i:integer;
begin
  res:=0;
//массив imageImportDesctriptor
  inc(res,(gloTop+1)*sizeof(imageImportDesctriptor));
//массив имен DLL
  inc(res,genTrackDLL(gloTop+1));
//предыдущие Thunk
  for i:=1 to dll-1 do
  with gloImport^[i] do
//  массив указателей
    inc(res,(impTop+1)*4);
//  массив имен функций
    inc(res,genTrackFun(i,impTop+1))
  end end;
  return res
end genTrackThunk;

//--- Смещение элементов таблицы экспорта -------

procedure genTrackExp(nom:integer):integer;
var res,i:integer;
begin
  res:=0;
  for i:=1 to nom-1 do
    inc(res,lstrlen(gloExport^[i])+1);
  end;
  return res
end genTrackExp;

//------- Сортировка имен ресурсов ------------

procedure genSortResource();
var i,j,k:integer; res:recSortRes;
begin
  topSortRes:=0;
//инициализация
  for i:=1 to topMod do
  with tbMod[i] do
    for j:=1 to topMDlg do
      if topSortRes<maxRes then
        inc(topSortRes)
      end;
      with genSort^[topSortRes] do
        resDLG:=true;
        resMod:=i;
        resNom:=j;
        s:=tbMod[i].modDlg^[j]^.mdCon[0]^.miNam;
        CharUpper(s)
      end
    end;
    for j:=1 to topBMP do
      if topSortRes<maxRes then
        inc(topSortRes)
      end;
      with genSort^[topSortRes] do
        resDLG:=false;
        resMod:=i;
        resNom:=j;
        s:=tbMod[i].modBMP^[j].bmpName;
        CharUpper(s)
      end
    end
  end end;
//сортировка
  for i:=1 to topSortRes do
    res:=genSort^[i];
    k:=0;
    for j:=1 to i-1 do
    if (k=0)and(lstrcmp(genSort^[j].s,res.s)>=0) then
      k:=j
    end end;
    if k>0 then
      for j:=i downto k+1 do
        genSort^[j]:=genSort^[j-1]
      end;
      genSort^[k]:=res
    end
  end
end genSortResource;

//------ Смещения элементов ресурсов ----------

procedure genTrackResName(m,d:integer; bitDlg:boolean):integer;
//0,0 - общий размер секции имен
var res:integer; i:integer; ok:boolean;
begin
  ok:=false;
  res:=0;
  for i:=1 to topSortRes do
  if not ok then
  with genSort^[i] do 
    ok:=(resDLG=bitDlg)and(resMod=m)and(resNom=d);
    if not ok then
      inc(res,genAlign((lstrlen(s)+1)*2,4))
    end
  end end end;
  if not ok and not((m=0)and(d=0)) then
    mbS(_Системная_ошибка_в_genTrackResName[envER])
  end;
  return res
end genTrackResName;

procedure genTrackResMem(m,d:integer; bitDlg:boolean):integer;
var res:integer; i,j:integer;
begin
  if bitDlg
    then res:=0
    else res:=genTrackResMem(topMod,tbMod[topMod].topMDlg+1,true)
  end;
  for i:=1 to topMod do
  if bitDlg then
    for j:=1 to tbMod[i].topMDlg do
      if (i<m)or(i=m)and(j<d) then
        inc(res,genSizeDlg(i,j))
    end end
  else
    for j:=1 to tbMod[i].topBMP do
      if (i<m)or(i=m)and(j<d) then
        inc(res,tbMod[i].modBMP^[j].bmpSize)
    end end
  end end;
  return res
end genTrackResMem;

//----------- Генерация диалога ---------------

procedure genDlgCHAR(pDlg:pstr; var topDlg:integer; chrDlg:char);
begin
  if topDlg<maxDlgMem then
    inc(topDlg);
    pDlg[topDlg-1]:=chrDlg
  end
end genDlgCHAR;

procedure genDlgWORD(pDlg:pstr; var topDlg:integer; wordDlg:word);
begin
  genDlgCHAR(pDlg,topDlg,char(lobyte(wordDlg)));
  genDlgCHAR(pDlg,topDlg,char(hibyte(wordDlg)));
end genDlgWORD;

procedure genDlgDWORD(pDlg:pstr; var topDlg:integer; dwordDlg:integer);
begin
  genDlgWORD(pDlg,topDlg,loword(dwordDlg));
  genDlgWORD(pDlg,topDlg,hiword(dwordDlg));
end genDlgDWORD;

procedure genDlgSTR(pDlg:pstr; var topDlg:integer; strDlg:pstr);
var i:integer;
begin
  if strDlg=nil then genDlgWORD(pDlg,topDlg,0)
  else
    for i:=0 to lstrlen(strDlg) do
      genDlgWORD(pDlg,topDlg,sysAnsiToUnicode(strDlg[i]))
    end
  end
end genDlgSTR;

procedure genMakeDlg(m,d:integer; pDlg:pstr; var topDlg:integer);
var i:integer;
begin
with tbMod[m].modDlg^[d]^ do
  topDlg:=0;
//генерация заголовка
  with mdCon[0]^ do
    genDlgDWORD(pDlg,topDlg,miSty); //style
    genDlgDWORD(pDlg,topDlg,0); //ext style
    genDlgWORD(pDlg,topDlg,mdTop); //Nitems
    genDlgWORD(pDlg,topDlg,miX);
    genDlgWORD(pDlg,topDlg,miY);
    genDlgWORD(pDlg,topDlg,miCX);
    genDlgWORD(pDlg,topDlg,miCY);
    genDlgSTR(pDlg,topDlg,nil); //menu
    genDlgSTR(pDlg,topDlg,miCla); //class
    genDlgSTR(pDlg,topDlg,miTxt); //caption
    if miFont<>nil then //шрифт
      genDlgWORD(pDlg,topDlg,miSize);
      genDlgSTR(pDlg,topDlg,miFont);
    end;
    while topDlg mod 4<>0 do //выравнивание конца диалога на dword
      genDlgCHAR(pDlg,topDlg,char(0))
    end
  end;
//генерация элементов
  for i:=1 to mdTop do
  with mdCon[i]^ do
    genDlgDWORD(pDlg,topDlg,miSty); //style
    genDlgDWORD(pDlg,topDlg,0); //ext style
    genDlgWORD(pDlg,topDlg,miX);
    genDlgWORD(pDlg,topDlg,miY);
    genDlgWORD(pDlg,topDlg,miCX);
    genDlgWORD(pDlg,topDlg,miCY);
    genDlgWORD(pDlg,topDlg,miId); //ID
    genDlgSTR(pDlg,topDlg,miCla); //class
    genDlgSTR(pDlg,topDlg,miTxt); //text
    genDlgWORD(pDlg,topDlg,0); //create data
    while topDlg mod 4<>0 do //выравнивание конца элемента на dword
      genDlgCHAR(pDlg,topDlg,char(0))
    end
  end end
end
end genMakeDlg;

procedure genSizeDlg;
var i:integer; topDlg:integer;
begin
with tbMod[m].modDlg^[d]^ do
  topDlg:=0;
//генерация заголовка
  with mdCon[0]^ do 
    inc(topDlg,4); //style
    inc(topDlg,4); //ext style
    inc(topDlg,2); //Nitems
    inc(topDlg,8); //X,Y,CX,CY
    inc(topDlg,2); //menu
    inc(topDlg,(lstrlen(miCla)+1)*2); //class
    inc(topDlg,(lstrlen(miTxt)+1)*2); //caption
    if miFont<>nil then //font
      inc(topDlg,(lstrlen(miFont)+1)*2);
      inc(topDlg,6);
    end;
    if topDlg mod 4<>0 then
      inc(topDlg,2)
    end
  end;
//генерация элементов
  for i:=1 to mdTop do
  with mdCon[i]^ do
    inc(topDlg,4); //style
    inc(topDlg,4); //ext style
    inc(topDlg,8);
    inc(topDlg,2); //ID
    inc(topDlg,(lstrlen(miCla)+1)*2); //class
    inc(topDlg,(lstrlen(miTxt)+1)*2); //caption
    inc(topDlg,2); //create data !НЕ ВЫРАВНИВАТЬ НА DWORD!
    while topDlg mod 4<>0 do //выравнивание конца элемента на dword
      inc(topDlg)
    end
  end end;
  return topDlg
end
end genSizeDlg;

//------------ формирование байта маски иконки ---------------

procedure genIconMas(nom:integer; pIcon:pstr):char;
var бит,номерТочки,номерБайта:integer; рез,байт:byte; маска:boolean;
begin
  рез:=0;
  return char(рез);//заглушка
  for бит:=0 to 7 do //цикл по битам результата
    номерТочки:=nom*8+бит;
    номерБайта:=номерТочки div 2;
    байт:=byte(pIcon[40+16*4+номерБайта]);
    if номерБайта mod 2=1
      then маска:=(байт and 0x0F)=0x0F;
      else маска:=(байт and 0xF0)=0xF0;
    end;
    if маска then
      case бит of
        0:рез:=рез or 0x01;|
        1:рез:=рез or 0x02;|
        2:рез:=рез or 0x04;|
        3:рез:=рез or 0x08;|
        4:рез:=рез or 0x10;|
        5:рез:=рез or 0x20;|
        6:рез:=рез or 0x40;|
        7:рез:=рез or 0x80;|
      end
    end
  end;
  return char(рез);
end genIconMas;

//------------ Генерация таблиц ---------------

type transrec=record case of
      |b0,b1,b2,b3:byte;
      |i:integer;
    end;

procedure genConstruct(var S:recStream; gFile,main:integer);
var m,i,j,k,l,w,dll,fun,topDlg,f:integer; s,pDlg,pMas:pstr;
    rva,siz,globalICON:integer;
    id:pID; track:integer;
    globalDLGs,globalDlgCar:integer;
    globalBMPs,globalBmpCar:integer;
    sect:classExe; imp:imageImportDesctriptor;
    ird:image_resource_directory;
    irde:image_resource_directory_entry;
    de:image_resource_data_entry;
    ied:imageExportDesctriptor;
    ri:res_icon;
    ep,carBegData,carBegCode:cardinal;
    icsh:IMAGE_COFF_SYMBOLS_HEADER;
    iln:IMAGE_LINENUMBER;
    is:IMAGE_SYMBOL; aux:array[0..17]of char; aux_s:AUX_SECTION; aux_f:AUX_FUNCTION; aux_bf_ef:AUX_BF_EF;
    idd:IMAGE_DEBUG_DIRECTORY;
    trans:transrec; code:pointer to arrCode; data:pointer to arrData;
begin

//инициализация начальных адресов модулей
  carBegCode:=0;
  for i:=1 to topMod do
  with tbMod[i] do
    genBegCode:=carBegCode; inc(carBegCode,topCode);
  end end;
  carBegData:=0;
  for i:=1 to topMod do
  with tbMod[i] do
    genBegData:=carBegData; inc(carBegData,topData);
  end end;

//старый и новый заголовки
  _lwrite(gFile,addr(OldHeader),genSize(exeOld,0));
  genGloImport();
  genGloExport();
  genWinHeader();
  if traMakeDLL then ep:=WinHeader.entryPoint; WinHeader.entryPoint:=0 end;
  _lwrite(gFile,addr(WinHeader),genSize(exeHeader,0));
  if traMakeDLL then WinHeader.entryPoint:=ep end;

//таблица секций
  for sect:=exeData to exeRsrc do
  with tbSection[sect] do //код
    case sect of
      exeData:
        lstrcpy(addr(name),'.data'); name[6]:=char(0); name[7]:=char(0);
        virtualAddress:=0x1000;
        pointerRawData:=genAlign(genSize(exeOld,0)+genSize(exeHeader,0)+genSize(exeSect,0),0x200);
        flags:=0xC0000040;|
      exeIData:
        lstrcpy(addr(name),'.idata'); name[7]:=char(0);
        virtualAddress:=0x1000+genSize(exeData,0x1000);
        pointerRawData:=tbSection[exeData].pointerRawData+genSize(exeData,0x200);
        flags:=0x40000040;|
      exeEData:
        lstrcpy(addr(name),'.edata'); name[7]:=char(0);
        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000);
        pointerRawData:=tbSection[exeIData].pointerRawData+genSize(exeIData,0x200);
        flags:=0x40000040;|
      exeText:
        lstrcpy(addr(name),'.text'); name[6]:=char(0); name[7]:=char(0);
        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000);
        pointerRawData:=tbSection[exeEData].pointerRawData+genSize(exeEData,0x200);
        flags:=0x60000020;|
      exeRsrc:
        lstrcpy(addr(name),'.rsrc'); name[6]:=char(0); name[7]:=char(0);
        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000)+genSize(exeText,0x1000);
        pointerRawData:=tbSection[exeText].pointerRawData+genSize(exeText,0x200);
        flags:=0x40000040;|
//      exeDebug:
//        lstrcpy(addr(name),'.rdata'); name[6]:=char(0); name[7]:=char(0);
//        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000)+genSize(exeText,0x1000)+genSize(exeRsrc,0x1000);
//        pointerRawData:=tbSection[exeRsrc].pointerRawData+genSize(exeRsrc,0x200);
//        flags:=0x50000040;|
    end;
    virtualSize:=genSize(sect,0);
    sizeofRawData:=genSize(sect,0x200);
    pointerReloc:=0;
    pointerLineNum:=0;
    numReloc:=0;
    numLineNum:=0;
  end end;
  _lwrite(gFile,addr(tbSection),genSize(exeSect,0));
  genWriteAlign(gFile,0x200);

//генерация таблицы классов
  genClasses:=memAlloc(sizeof(arrClasses));
  genClassesTop:=0;
  genClassCreate(S,nil,genClasses,genClassesTop);
  genClassTable(S,genClasses,genClassesTop,main);

//секция данных
  for i:=1 to topMod do
  with tbMod[i] do
    data:=memAlloc(topData);
    RtlMoveMemory(data,genData,topData);
    for j:=1 to topVarCall do //вызовы переменных
    if genVarCall^[j].cl=vcData then
      trans.b0:=data^[genVarCall^[j].track+0];
      trans.b1:=data^[genVarCall^[j].track+1];
      trans.b2:=data^[genVarCall^[j].track+2];
      trans.b3:=data^[genVarCall^[j].track+3];
      inc(trans.i,tbMod[genVarCall^[j].no].genBegData);
      data^[genVarCall^[j].track+0]:=trans.b0;
      data^[genVarCall^[j].track+1]:=trans.b1;
      data^[genVarCall^[j].track+2]:=trans.b2;
      data^[genVarCall^[j].track+3]:=trans.b3;
    end end;
    _lwrite(gFile,pstr(data),topData);
    memFree(data);
  end end;
  genWriteAlign(gFile,0x200);

//секция импорта (массив imageImportDesctriptor)
  for i:=1 to gloTop do
  with gloImport^[i],imp do
    origFirstThunk:=0;
    timeDateStump:=0;
    forwardChain:=0;
    name:=tbSection[exeIData].virtualAddress+(gloTop+1)*(sizeof(imageImportDesctriptor))+genTrackDLL(i);
    FirstThunk:=tbSection[exeIData].virtualAddress+genTrackThunk(i);
    _lwrite(gFile,addr(imp),sizeof(imageImportDesctriptor));
  end end;
  with imp do
    origFirstThunk:=0;
    timeDateStump:=0;
    forwardChain:=0;
    name:=0;
    FirstThunk:=0;
    _lwrite(gFile,addr(imp),sizeof(imageImportDesctriptor));
  end;
 
//секция импорта (массив имен модулей)
  for i:=1 to gloTop do
  with gloImport^[i] do
    genWriteS(gFile,impName);
    genWriteB(gFile,0);
  end end;

//секция импорта (наборы имен функций)
  for i:=1 to gloTop do
  with gloImport^[i] do
//массив указателей
    for j:=1 to impTop do
    with impFuns^[j] do
      genWriteL(gFile,tbSection[exeIData].virtualAddress+
                      genTrackThunk(i)+
                      (impTop+1)*4+
                      genTrackFun(i,j));
      funRVA:=tbSection[exeIData].virtualAddress+
                      genTrackThunk(i)+
                      (j-1)*4;
    end end;
    genWriteL(gFile,0);
//массив имен функций
    for j:=1 to impTop do
    with impFuns^[j] do
      genWriteB(gFile,0);
      genWriteB(gFile,0);
      genWriteS(gFile,funName);
      genWriteB(gFile,0);
    end end
  end end;
  genWriteAlign(gFile,0x200);

//секция экспорта
  with ied do
    Characteristics:=0;
    TimeDateStump:=0;
    MajorVersion:=0;
    MinorVersion:=0;
    Name:=tbSection[exeEData].virtualAddress+sizeof(imageExportDesctriptor)+gloTopExp*4+gloTopExp*4+gloTopExp*2+genTrackExp(gloTopExp+1);
    Base:=1;
    NumberOfFunctions:=gloTopExp;
    NumberOfNames:=gloTopExp;
    AddressOfFunctions:=tbSection[exeEData].virtualAddress+sizeof(imageExportDesctriptor);
    AddressOfNames:=tbSection[exeEData].virtualAddress+sizeof(imageExportDesctriptor)+gloTopExp*4;
    AddressOfNameOrdinals:=tbSection[exeEData].virtualAddress+sizeof(imageExportDesctriptor)+gloTopExp*4+gloTopExp*4;
    _lwrite(gFile,addr(ied),sizeof(imageExportDesctriptor));
  end;
  for i:=1 to gloTopExp do
    id:=idFindGlo(gloExport^[i],false);
    if (id<>nil)and(id^.idClass=idPROC)
      then track:=WinHeader.entryPoint-(tbMod[genEntryNo].genBegCode+genEntry)+id^.idProcAddr;
      else track:=0; MessageBox(0,_Не_определена_точка_входа_[envER],gloExport^[i],0);
    end;
    genWriteL(gFile,track);
  end;
  for i:=1 to gloTopExp do
    track:=tbSection[exeEData].virtualAddress+sizeof(imageExportDesctriptor)+gloTopExp*4+gloTopExp*4+gloTopExp*2+genTrackExp(i);
    genWriteL(gFile,track);
  end;
  for i:=1 to gloTopExp do
    genWriteW(gFile,i-1);
  end;
  for i:=1 to gloTopExp do
    genWriteS(gFile,gloExport^[i]);
    genWriteB(gFile,0);
  end;
  genWriteS(gFile,genNameModule);
  genWriteB(gFile,0);
  genWriteAlign(gFile,0x200);

//секция кода
  for m:=1 to topMod do
  with tbMod[m] do
    code:=memAlloc(topCode);
    RtlMoveMemory(code,genCode,topCode);
    for i:=1 to topImport do //вызовы внешних функций
    with genImport^[i] do
      for j:=1 to impTop do
      with impFuns^[j] do
        impFind(gloImport,impName,funName,gloTop,dll,fun);
        rva:=genBASECODE+gloImport^[dll].impFuns^[fun].funRVA;
        for k:=1 to funTop do
          code^[funCALL^[k]+0]:=lobyte(loword(rva));
          code^[funCALL^[k]+1]:=hibyte(loword(rva));
          code^[funCALL^[k]+2]:=lobyte(hiword(rva));
          code^[funCALL^[k]+3]:=hibyte(hiword(rva));
        end
      end end
    end end;
    for j:=1 to topProCall do //вызовы внешних процедур и методов
    with genProCall^[j] do
      if lstrposc('.',sou)=-1 then //обычная процедура
        l:=genGetProcTrack(S,mo,sou)-(tbMod[m].genBegCode+track)-3;
        code^[track+0]:=lobyte(loword(l));
        code^[track+1]:=hibyte(loword(l));
        code^[track+2]:=lobyte(hiword(l));
        code^[track+3]:=hibyte(hiword(l));
      else //метод
        l:=(genClassMet(genClasses,genClassesTop,sou)-1)*4;
        code^[track+7]:=lobyte(loword(l));
        code^[track+8]:=hibyte(loword(l));
        code^[track+9]:=lobyte(hiword(l));
        code^[track+10]:=hibyte(hiword(l));
      end
    end end;
    for j:=1 to topVarCall do //вызовы переменных и адресов процедур
    if genVarCall^[j].cl in [vcCode,vcAddr,vcNew] then
      trans.b0:=code^[genVarCall^[j].track+0];
      trans.b1:=code^[genVarCall^[j].track+1];
      trans.b2:=code^[genVarCall^[j].track+2];
      trans.b3:=code^[genVarCall^[j].track+3];
      case genVarCall^[j].cl of
        vcCode:inc(trans.i,tbMod[genVarCall^[j].no].genBegData);|
        vcAddr:inc(trans.i,tbMod[genVarCall^[j].no].genBegCode);|
        vcNew:trans.i:=genClassBegin+(genClassFind(genClasses,genClassesTop,genVarCall^[j].cla)-1)*4;|
      end;
      code^[genVarCall^[j].track+0]:=trans.b0;
      code^[genVarCall^[j].track+1]:=trans.b1;
      code^[genVarCall^[j].track+2]:=trans.b2;
      code^[genVarCall^[j].track+3]:=trans.b3;
    end end;
    _lwrite(gFile,pstr(code),topCode);
    memFree(code);
  end end;
  genWriteAlign(gFile,0x200);

//секция ресурсов (заголовок)
  genSortResource();
  globalDLGs:=0;
  for i:=1 to topMod do
    inc(globalDLGs,tbMod[i].topMDlg)
  end;
  globalBMPs:=0;
  for i:=1 to topMod do
    inc(globalBMPs,tbMod[i].topBMP)
  end;
  globalICON:=0;
  for i:=1 to topMod do
    if tbMod[i].modICON<>nil then
      globalICON:=1;
      lstrcpy(traIcon,tbMod[i].modICON)
    end
  end;
  with ird do
    Characteristics:=0;
    TimeDateStamp:=0x32419555;
    Version:=0;//4
    NumberOfNamedEntries:=0;
    NumberOfIdEntries:=0;
    if globalDLGs>0 then NumberOfIdEntries:=integer(NumberOfIdEntries)+1 end;
    if globalBMPs>0 then NumberOfIdEntries:=integer(NumberOfIdEntries)+1 end;
    if globalICON>0 then NumberOfIdEntries:=integer(NumberOfIdEntries)+2 end;
  end;
  _lwrite(gFile,addr(ird),sizeof(image_resource_directory));
  if globalBMPs>0 then //bitmap
  with irde do
    Name:=0x00000002;
    OffsetToData:=0x80000000+0x30+(0x10+globalDLGs*8);
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;
  if globalICON>0 then //иконка
  with irde do
    Name:=0x00000003;
    OffsetToData:=0x80000000+0x30+(0x10+globalDLGs*8)+(0x10+globalBMPs*8);
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;
  if globalDLGs>0 then //диалоги
  with irde do
    Name:=0x00000005;
    OffsetToData:=0x80000000+0x30;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;
  if globalICON>0 then //группы иконок
  with irde do
    Name:=0x0000000E;
    OffsetToData:=0x80000000+0x30+(0x10+globalDLGs*8)+(0x10+globalBMPs*8)+0x30;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;
  for i:=3 downto ird.NumberOfIdEntries do //заглушки
  with irde do
    Name:=0x00000000;
    OffsetToData:=0x00000000;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;

//секция ресурсов (элементы DLG)
  with ird do
    Characteristics:=0;
    TimeDateStamp:=0x32419555;
    Version:=0;//4
    NumberOfNamedEntries:=globalDLGs;
    NumberOfIdEntries:=0;
  end;
  _lwrite(gFile,addr(ird),sizeof(image_resource_directory));
  globalDlgCar:=0;
  for k:=1 to topSortRes do with genSort^[k] do
  if resDLG then with irde do
    inc(globalDlgCar);
    Name:=0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      genTrackResName(resMod,resNom,true);
    Name:=Name or 0x80000000;
    OffsetToData:=0x30+
      0x10+globalDLGs*8+
      0x10+globalBMPs*8+
      0x28+globalICON*8+
      0x28+globalICON*8+
      (globalDlgCar-1)*sizeof(image_resource_data_entry);
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end end end;

//секция ресурсов (элементы BMP)
  with ird do
    Characteristics:=0;
    TimeDateStamp:=0x32419555;
    Version:=0;//4
    NumberOfNamedEntries:=globalBMPs;
    NumberOfIdEntries:=0;
  end;
  _lwrite(gFile,addr(ird),sizeof(image_resource_directory));
  globalBmpCar:=0;
  for k:=1 to topSortRes do with genSort^[k] do
  if not resDLG then with irde do
    inc(globalBmpCar);
    Name:=0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      genTrackResName(resMod,resNom,false);
    Name:=Name or 0x80000000;
    OffsetToData:=0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*8+
      0x28+globalICON*8+
      0x28+globalICON*8+
      (globalBmpCar-1)*sizeof(image_resource_data_entry);
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end end end;

//секция ресурсов (элемент ICON)
  with ird do
    Characteristics:=0;
    TimeDateStamp:=0x32419555;
    Version:=0;//4
    NumberOfNamedEntries:=0;
    NumberOfIdEntries:=globalICON;
    _lwrite(gFile,addr(ird),sizeof(image_resource_directory));
  end;
  with irde do
    Name:=0x1;
    OffsetToData:=0x30+
      0x10+globalDLGs*8+
      0x10+globalBMPs*8+
      0x18;
    OffsetToData:=OffsetToData or 0x80000000;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end;
  with ird do
    Characteristics:=0;
    TimeDateStamp:=0x32419555;
    Version:=0;//4
    NumberOfNamedEntries:=0;
    NumberOfIdEntries:=globalICON;
    _lwrite(gFile,addr(ird),sizeof(image_resource_directory));
  end;
  if globalICON>0 then
  with irde do
    Name:=0x409;
    OffsetToData:=0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*8+
      0x28+globalICON*8;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;

//секция ресурсов (элемент GROUP)
  with ird do
    Characteristics:=0;
    TimeDateStamp:=0x32419555;
    Version:=0;//4
    NumberOfNamedEntries:=0;
    NumberOfIdEntries:=globalICON;
    _lwrite(gFile,addr(ird),sizeof(image_resource_directory));
  end;
  with irde do
    Name:=0x0000;
    OffsetToData:=0x30+
      0x10+globalDLGs*8+
      0x10+globalBMPs*8+
      0x28+globalICON*8+
      0x18;
    OffsetToData:=OffsetToData or 0x80000000;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end;
  with ird do
    Characteristics:=0;
    TimeDateStamp:=0x32419555;
    Version:=0;//4
    NumberOfNamedEntries:=0;
    NumberOfIdEntries:=globalICON;
    _lwrite(gFile,addr(ird),sizeof(image_resource_directory));
  end;
  if globalICON>0 then
  with irde do
    Name:=0x409;
    OffsetToData:=0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*8;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;

//секция ресурсов (входы DLG)
  globalDlgCar:=0;
  for k:=1 to topSortRes do with genSort^[k] do
  if resDLG then with de do
    inc(globalDlgCar);
    RVA:=tbSection[exeRsrc].virtualAddress+0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      genAlign(genTrackResName(0,0,false),4)+
      genTrackResMem(resMod,resNom,true);
    Size:=genSizeDlg(resMod,resNom);
    CodePage:=0x00000000;
    Rezerved:=0x00000000;
    _lwrite(gFile,addr(de),sizeof(image_resource_data_entry));
  end end end end;

//секция ресурсов (входы BMP)
  globalBmpCar:=0;
  for k:=1 to topSortRes do with genSort^[k] do
  if not resDLG then with de do
    inc(globalBmpCar);
    RVA:=tbSection[exeRsrc].virtualAddress+0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      genAlign(genTrackResName(0,0,false),4)+
      genTrackResMem(resMod,resNom,false);
    Size:=tbMod[resMod].modBMP^[resNom].bmpSize;
    CodePage:=0x00000000;
    Rezerved:=0x00000000;
    _lwrite(gFile,addr(de),sizeof(image_resource_data_entry));
  end end end end;

//секция ресурсов (вход ICON)
  if globalICON>0 then
  with de do
    inc(globalBmpCar);
    RVA:=tbSection[exeRsrc].virtualAddress+0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      genAlign(genTrackResName(0,0,false),4)+
      genTrackResMem(topMod,tbMod[topMod].topBMP+1,false);
    Size:=0x2e8;
    CodePage:=0x0;
    Rezerved:=0x00000000;
    _lwrite(gFile,addr(de),sizeof(image_resource_data_entry));
  end end;

//секция ресурсов (вход GROUP)
  if globalICON>0 then
  with de do
    inc(globalBmpCar);
    RVA:=tbSection[exeRsrc].virtualAddress+0x30+
      0x10+globalDLGs*(8+sizeof(image_resource_data_entry))+
      0x10+globalBMPs*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      0x28+globalICON*(8+sizeof(image_resource_data_entry))+
      genAlign(genTrackResName(0,0,false),4)+
      genTrackResMem(topMod,tbMod[topMod].topBMP+1,false)+
      0x2e8;
    Size:=sizeof(res_icon);
    CodePage:=0x0;
    Rezerved:=0x00000000;
    _lwrite(gFile,addr(de),sizeof(image_resource_data_entry));
  end end;

//секция ресурсов (имена DLG и BMP)
  for i:=1 to topSortRes do
  with genSort^[i] do
    CharUpper(s);
    w:=lstrlen(s);
    _lwrite(gFile,addr(w),2);
    for k:=0 to lstrlen(s)-1 do
      w:=sysAnsiToUnicode(s[k]);
      _lwrite(gFile,addr(w),2);
    end;
    l:=0;
    _lwrite(gFile,addr(l),genAlign((lstrlen(s)+1)*2,4)-(lstrlen(s)+1)*2);
  end end;

//секция ресурсов (образы DLG)
  pDlg:=memAlloc(maxDlgMem);
  for i:=1 to topMod do
  for j:=1 to tbMod[i].topMDlg do
  with tbMod[i] do
    genMakeDlg(i,j,pDlg,topDlg);
    _lwrite(gFile,pDlg,topDlg);
  end end end;
  memFree(pDlg);

//секция ресурсов (образы BMP)
  pDlg:=memAlloc(maxDlgMem);
  for i:=1 to topMod do
  for j:=1 to tbMod[i].topBMP do
  with tbMod[i].modBMP^[j] do
    f:=_lopen(bmpFile,OF_READ);
    _lread(f,pDlg,14);
    for k:=1 to bmpSize div maxDlgMem + 1 do
      siz:=_lread(f,pDlg,maxDlgMem);
      _lwrite(gFile,pDlg,siz);
    end;
    _lclose(f)
  end end end;
  memFree(pDlg);

//секция ресурсов (образ ICON)
  pDlg:=memAlloc(maxDlgMem);
  pMas:=memAlloc(128);
  if globalICON>0 then
    f:=_lopen(traIcon,OF_READ);
    _lread(f,pDlg,14);
    _lread(f,pDlg,40+16*4+512);
    pDlg[8]:=char(0x40);
    _lwrite(gFile,pDlg,40+16*4+512);
    for i:=0 to 127 do
      pMas[i]:=genIconMas(i,pDlg);
    end;
    _lwrite(gFile,pMas,128);
    _lclose(f)
//    f:=_lopen("icon",OF_READ);
//    _lread(f,pDlg,0x2e8);
//    _lwrite(gFile,pDlg,0x2e8);
//    _lclose(f)
  end;
  memFree(pDlg);
  memFree(pMas);

//секция ресурсов (образ GROUP)
  if globalICON>0 then
  with ri do
    irReserved:=0;
    irType:=1;
    irCount:=1;
    bWight:=32;
    bHeight:=32;
    bColorCount:=16;
    bReserved:=0;
    wReserved1:=1;
    wReserved2:=4;
    dwBytesInRes:=0x2e8;
    wOriginalNumber:=0x1;
    _lwrite(gFile,addr(ri),sizeof(res_icon));
  end end;
  genWriteAlign(gFile,0x200);

  genClassFree(genClasses,genClassesTop);
  memFree(genClasses);
end genConstruct;

//-------- Установка размера файла ------------

procedure genSizeFile(gFile:integer);
var w:integer;
begin
  _llseek(gFile,2,0);
  w:=_lsize(gFile) mod 512; _lwrite(gFile,addr(w),2);
  w:=_lsize(gFile) div 512;
  if _lsize(gFile) mod 512<>0 then inc(w) end;
  _lwrite(gFile,addr(w),2)
end genSizeFile;

//---------- Создание имени EXE-файла --------------

procedure genExeName(sou,folder,res:pstr; bitDLL:boolean);
begin
  lstrcpy(res,sou);
  if lstrposc('.',res)>=0 then
    lstrdel(res,lstrposc('.',res),999);
  end;
  if not bitDLL
    then lstrcat(res,".exe")
    else lstrcat(res,".dll")
  end;
  if folder[0]<>'\0' then
    while lstrposc('\',res)>=0 do
      lstrdel(res,0,1)
    end;
    lstrins(folder,res,0);
    if folder[lstrlen(folder)-1]<>'\' then
      lstrinsc('\',res,lstrlen(folder));
    end
  end
end genExeName;

//---------- Генерация EXE-файла --------------

procedure genExe(var S:recStream; gName:pstr; no:integer);
var gFile,i,j:integer; gTab:classExe;
begin
  if lstrposc(':',gName)=-1 then
    genExeName(gName,envExeFolder,genNameModule,traMakeDLL);
    gFile:=_lcreat(genNameModule,0);
    if gFile<=0 then mbS(_EXE_файл_занят_другим_приложением_[envER])
    else
      genConstruct(S,gFile,no);
      genSizeFile(gFile);
      _lclose(gFile);
    end;
    lstrdel(genNameModule,lstrposc('.',genNameModule),255);
  end
end genExe;

//---------- Генерация I-файла ----------------

procedure genDef(var S:recStream; gName:pstr; no:integer);
var gFile,i,j:integer; gId:pID;
begin
with tbMod[no] do
if lstrposc(':',gName)=-1 then
  lstrcpy(genNameModule,gName);
  if lstrposc('.',genNameModule)>=0 then
    lstrdel(genNameModule,lstrposc('.',genNameModule),255)
  end;
  lstrcatc(genNameModule,'.');
  lstrcat(genNameModule,_envEXTI);
  gFile:=_lcreat(genNameModule,0);
  lstrdel(genNameModule,lstrposc('.',genNameModule),255);
//код
  _lwrite(gFile,addr(genEntry),4);
  _lwrite(gFile,addr(genBegCode),4);
  _lwrite(gFile,addr(topCode),4);
  _lwrite(gFile,pstr(genCode),topCode);
//данные
  _lwrite(gFile,addr(genBegData),4);
  _lwrite(gFile,addr(topData),4);
  _lwrite(gFile,pstr(genData),topData);
//модули
  _lwrite(gFile,addr(topMod),4);
  for i:=1 to topMod do
  with tbMod[i] do
    idWriteS(gFile,modNam);
  end end;
//идентификаторы
  idWrite(modTab,gFile);
  gId:=memAlloc(sizeof(recID));
  gId^.idClass:=idNULL;
  _lwrite(gFile,pstr(gId),sizeof(recID));
  memFree(gId);
//таблица импорта
  _lwrite(gFile,addr(topImport),4);
  impWrite(genImport,topImport,gFile);
//таблица экспорта
  _lwrite(gFile,addr(topExport),4);
  expWrite(genExport,topExport,gFile);
//вызовы переменных
  _lwrite(gFile,addr(topVarCall),4);
  _lwrite(gFile,pstr(genVarCall),topVarCall*(sizeof(arrVarCall) div maxVarCall));
    for i:=1 to topVarCall do
      if genVarCall^[i].cla<>nil then
        idWriteS(gFile,genVarCall^[i].cla);
      end;
    end;
//вызовы процедур
  _lwrite(gFile,addr(topProCall),4);
  for i:=1 to topProCall do
  with genProCall^[i] do
    _lwrite(gFile,addr(genProCall^[i]),sizeof(arrProCall) div maxProCall);
    idWriteS(gFile,mo);
    idWriteS(gFile,sou);
  end end;
//ресурсы
  _lwrite(gFile,addr(topMDlg),4);
  genDlgWrite(gFile,modDlg,topMDlg);
  _lwrite(gFile,addr(topBMP),4);
  genBmpWrite(gFile,modBMP,topBMP);
  idWriteS(gFile,modICON);
//отладочная информация
  _lwrite(gFile,addr(topGenStep),4);
  _lwrite(gFile,pstr(genStep),topGenStep*(sizeof(arrStep) div maxStep));
  _lclose(gFile);
end end
end genDef;

//----------- Чтение I-файла ------------------

procedure genImp(var S:recStream; gName:pstr; no:integer):boolean;
var gFile,i,j:integer; pass:integer; buf:array[1..64]of byte;
begin
with tbMod[no] do
  lstrcpy(genNameModule,gName);
  if lstrposc('.',genNameModule)>=0 then
    lstrdel(genNameModule,lstrposc('.',genNameModule),255)
  end;
  lstrcatc(genNameModule,'.');
  lstrcat(genNameModule,_envEXTI);
  gFile:=_lopen(genNameModule,OF_READ);
  lstrdel(genNameModule,lstrposc('.',genNameModule),255);
  if gFile>0 then
//код
    if no=tekt
      then _lread(gFile,addr(genEntry),4)
      else _lread(gFile,addr(pass),4)
    end;
    _lread(gFile,addr(genBegCode),4);
    _lread(gFile,addr(topCode),4);
    _lread(gFile,genCode,topCode);
//данные
    _lread(gFile,addr(genBegData),4);
    _lread(gFile,addr(topData),4);
    _lread(gFile,genData,topData);
//модули
  _lread(gFile,addr(topModImp),4);
  lexTest(topModImp>maxMod,S,_Слишком_много_модулей[envER],genNameModule);
  for i:=1 to topModImp do
    idReadS(gFile,tbModImp[i])
  end;
//идентификаторы
    idRead(S,modTab,gFile,no);
//таблица импорта
    _lread(gFile,addr(topImport),4);
    impRead(genImport,topImport,gFile);
//таблица экспорта
    _lread(gFile,addr(topExport),4);
    expRead(genExport,topExport,gFile);
//вызовы переменных
    _lread(gFile,addr(topVarCall),4);
    _lread(gFile,pstr(genVarCall),topVarCall*(sizeof(arrVarCall) div maxVarCall));
    for i:=1 to topVarCall do
      genVarCall^[i].no:=tabGetImpNo(S,genVarCall^[i].no,true);
      if genVarCall^[i].cla<>nil then
        idReadS(gFile,genVarCall^[i].cla);
      end;
    end;
//вызовы процедур
    _lread(gFile,addr(topProCall),4);
    for i:=1 to topProCall do
    with genProCall^[i] do
      _lread(gFile,addr(genProCall^[i]),sizeof(arrProCall) div maxProCall);
      idReadS(gFile,mo);
      idReadS(gFile,sou);
    end end;
//ресурсы
    _lread(gFile,addr(topMDlg),4);
    genDlgRead(gFile,modDlg,topMDlg);
    _lread(gFile,addr(topBMP),4);
    genBmpRead(gFile,modBMP,topBMP);
    idReadS(gFile,modICON);
//отладочная информация
    _lread(gFile,addr(topGenStep),4);
    _lread(gFile,pstr(genStep),topGenStep*(sizeof(arrStep) div maxStep));
    _lclose(gFile);
    return true
  else return false
  end
end
end genImp;

//===============================================
//                    МОДУЛИ
//===============================================

procedure genFreeRes;
var i,j:integer;
begin
with tbMod[no] do
  for i:=1 to topMDlg do with modDlg^[i]^ do
    for j:=0 to mdTop do with mdCon[j]^ do
      memFree(miTxt);
      memFree(miNam);
      memFree(miCla);
      memFree(miFont);
      memFree(mdCon[j])
    end end;
    memFree(modDlg^[i])
  end end;
  topMDlg:=0;
  for i:=1 to topBMP do with modBMP^[i] do
    memFree(bmpName);
    memFree(bmpFile);
  end end;
  topBMP:=0;
  memFree(modICON);
end
end genFreeRes;

//--------------- Загрузить -------------------

  procedure genLoadMod(var S:recStream; name:pstr; no:integer; bitLoadFile:boolean):boolean;
  var res:boolean; sub:classSub;
  begin
  with tbMod[no] do
    modNam:=memAlloc(lstrlen(name)+1);
    lstrcpy(modNam,name);
    modTab:=nil;
    modTxt:=no;
    modAct:=false;
    modComp:=false;
    modMain:=false;
    for sub:=subNULL to subPAR do
      modSbs[sub]:=nil;
      modTop[sub]:=0;
    end;

    modDlg:=memAlloc(sizeof(arrDlg));
    topMDlg:=0;
    modBMP:=memAlloc(sizeof(arrBMP));
    topBMP:=0;
    modICON:=nil;

    genBegCode:=0;
    genBegData:=0;
    genCode:=nil; topCode:=0;
    genData:=nil; topData:=0;
    genCode:=memAlloc(sizeof(arrCode));
    genData:=memAlloc(sizeof(arrData));
    RtlZeroMemory(address(genData),sizeof(arrData));
    genImport:=memAlloc(sizeof(arrIMPORT)); topImport:=0;
    genExport:=memAlloc(sizeof(arrEXPORT)); topExport:=0;
    genVarCall:=memAlloc(sizeof(arrVarCall)); topVarCall:=0;
    genProCall:=memAlloc(sizeof(arrProCall)); topProCall:=0;
    genStep:=memAlloc(sizeof(arrStep)); topGenStep:=0;
    res:=false;
    if bitLoadFile then
      res:=genImp(S,modNam,no);
    end;
    return res
  end
  end genLoadMod;

//--------------- Освободить ------------------

  procedure genCloseMod(no:integer);
  var sub:classSub; i,j:integer;
  begin
  with tbMod[no] do
    memFree(modNam);
    idDestroy(modTab);
    for sub:=subNULL to subPAR do
      memFree(modSbs[sub])
    end;
    genFreeRes(no);
    memFree(modDlg);
    memFree(modBMP);
    memFree(genCode);
    memFree(genData);
    impDestroy(genImport,topImport);
    expDestroy(genExport,topExport);
    memFree(genVarCall);
    memFree(genProCall);
    memFree(genStep);
  end
  end genCloseMod;

//------------- Освободить все ----------------

  procedure genCloseMods();
  var i:integer;
  begin
    for i:=1 to topMod do
      genCloseMod(i)
    end
  end genCloseMods;

end SmGen.
