//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль TAB (таблица идентификаторов)
//Файл SMTAB.M

implementation module SmTab;
import Win32,Win32Ext,SmSys,SmDat;

//===============================================
//           ТАБЛИЦА ИДЕНТИФИКАТРОВ
//===============================================

//----- Инициализация основного модуля --------

  procedure idInitial(var tab:pID; no:integer);
  var i:integer; initID:pID; carType:classTYPE;
  begin
//  базовые типы
    for carType:=loType to hiType do 
      initID:=idInsert(tab,nameTYPE[traLANG][carType],idtBAS,tabMod,no);
      idTYPE[carType]:=initID;
      with initID^ do
        idBasNom:=carType;
        case carType of
          typeBYTE,typeCHAR:idtSize:=1;|
          typeWORD:idtSize:=2;|
          typeBOOL,typeINT,typeDWORD:idtSize:=4;|
          typePOINT,typePSTR:idtSize:=4;|
          typeREAL32:idtSize:=4;|
          typeREAL:idtSize:=8;|
          typeSET:idtSize:=32;|
        end
      end
    end
  end idInitial;

//-------- Освобождение таблицы ---------------

  procedure idDestroy(var tab:pID);
  begin
    if tab<>nil then
    with tab^ do
      idDestroy(idLeft);
      idDestroy(idRight);
      memFree(idName);
      case idClass of
        idcSTR:memFree(idStr);|
        idcSET:memFree(idSet);|
        idtREC:memFree(idRecList); memFree(idRecMet);|
        idtSCAL:memFree(idScalList);|
        idPROC:memFree(idProcList); memFree(idLocList); memFree(idProcDLL);|
      end
    end end;
    memFree(tab);
    tab:=nil
  end idDestroy;

//------------ Чистка таблиц ------------------

  procedure idDestroys();
  var i:integer;
  begin
    for i:=1 to topMod do
      with tbMod[i] do
        idDestroy(modTab);
      end
    end;
    for i:=1 to topWith do
      idDestroy(tbWith[i]);
    end
  end idDestroys;

//-------- Вставка идентификатора -------------

  procedure idInsert(var tab:pID; name:pstr; Class:classID; ta:classTab; no:integer):pID;
  var p,own:pID;
  begin
//заполнение
    own:=memAlloc(sizeof(recID));
    RtlZeroMemory(own,sizeof(recID));
    with own^ do
      idName:=memAlloc(lstrlen(name)+1); lstrcpy(idName,name);
      idClass:=Class;
      idLeft:=nil;
      idRight:=nil;
      idOwn:=own;
      idTab:=ta;
      idNom:=no;
      idActiv:=byte(true);
      idH:=byte(traBitH);
      idSou:=0;
    end;
//вставка идентификатора
    if tab=nil then tab:=own //пустая таблица
    else //поиск в таблице
      p:=tab;
      while (lstrcmp(name,p^.idName)<>0)and(
            (lstrcmp(name,p^.idName)> 0)and(p^.idRight<>nil)or
            (lstrcmp(name,p^.idName)<=0)and(p^.idLeft <>nil)) do
        if lstrcmp(name,p^.idName)>0
          then p:=p^.idRight
          else p:=p^.idLeft;
        end
      end;
//добавление в таблицу
      if (name<>nil)and(name[0]<>char(0))and(name[0]<>'#')and
         (Class<>idvPAR)and(Class<>idvVPAR)and
         boolean(p^.idActiv) and (lstrcmp(name,p^.idName)=0) then //ошибка
        memFree(own^.idName);
        memFree(own);
        own:=nil
      else //вставка
        if lstrcmp(name,p^.idName)>0
          then own^.idRight:=p^.idRight; p^.idRight:=own
          else own^.idLeft :=p^.idLeft;  p^.idLeft :=own 
        end
      end
    end;
    if own=nil then
      mbS(_Повторный_идентификатор[envER]); mbI(ord(ta),name)
    end;
    return own
  end idInsert;

// Вставка идентификатора в текущий контекст --

  procedure idInsertGlo(name:pstr; Class:classID):pID;
  begin
    return idInsert(tbMod[tekt].modTab,name,Class,tabMod,tekt)
  end idInsertGlo;

//----------- Поиск в таблице -----------------

  procedure idFind(var tab:pID; name:pstr):pID;
  var p:pID;
  begin
    if tab=nil then return nil //пустая таблица
    else //поиск в таблице
      p:=tab;
      if boolean(p^.idActiv) and(lstrcmp(name,p^.idName)=0) then return p end;
      while
        (lstrcmp(name,p^.idName)>0)and(p^.idRight<>nil)or
        (lstrcmp(name,p^.idName)<=0)and(p^.idLeft<>nil) do
        if lstrcmp(name,p^.idName)>0
          then p:=p^.idRight
          else p:=p^.idLeft
        end;
        if boolean(p^.idActiv) and(lstrcmp(name,p^.idName)=0) then return p end;
      end;
    end;
    return nil
  end idFind;

//-------- Поиск во всех таблицах -------------

  procedure idFindGlo(name:pstr; bitFix:boolean):pID;
  var p:pID; i:integer; s:string[maxText]; l:integer;
  begin
    p:=nil;
//стек with
    withGlo:=0;
    for i:=topWith downto 1 do
    with tbWith[i]^ do
      lstrcpy(s,idName);
      lstrcatc(s,'.');
      lstrcat(s,name);
      if p=nil then
        p:=listFind(idRecList,idRecMax,s);
        if p<>nil then
          withGlo:=i
        end
      end
    end end;
//текущий модуль
    if p=nil then
      p:=idFind(tbMod[tekt].modTab,name);
    end;
//модули
    for i:=1 to topMod do
      if tbMod[i].modAct then
        if p=nil then
          p:=idFind(tbMod[i].modTab,name);
        end
      end
    end;
//модернизация idMods
    if bitFix and(p<>nil) then
      l:=1;
      for i:=1 to tekt-1 do
        l:=l*2;
      end;
      p^.idSou:=p^.idSou or l;
    end;
    return p
  end idFindGlo;

//------ Запись строки в файл --------

  procedure idWriteS(fil:integer; s:pstr);
  var j:integer;
  begin
    if s<>nil then
      j:=1; _lwrite(fil,addr(j),1);
      j:=lstrlen(s);
      _lwrite(fil,addr(j),4);
      _lwrite(fil,s,j+1);
    else
      j:=0; _lwrite(fil,addr(j),1);
    end
  end idWriteS;

//------ Чтение строки из файла --------

  procedure idReadS(fil:integer; var s:pstr);
  var j:integer;
  begin
    j:=0; _lread(fil,addr(j),1);
    if j<>0 then
      _lread(fil,addr(j),4);
      s:=memAlloc(j+1);
      _lread(fil,s,j+1);
    end
  end idReadS;

//------ Замена ссылки на другой модуль (запись) --------

  procedure idSubsFFFF(var id:pID; car:pID);
  begin
    if (id<>nil)and(id^.idNom<>car^.idNom) then
      id:=address(-1)
    end;
  end idSubsFFFF;

//------ Замена ссылок на другой модуль в списке (запись) --------

  procedure idSubsLIST(list:pLIST; max:integer; car:pID):pLIST;
  var j:integer; res:pLIST;
  begin
    res:=memAlloc(max*4);
    RtlMoveMemory(res,list,max*4);
    for j:=1 to max do
      idSubsFFFF(res^[j],car);
    end;
    return res
  end idSubsLIST;

//------ Запись ссылки на другой модуль --------

  procedure idWriteFFFF(fil:integer; id,org:pID);
  begin
    if id=address(-1) then
      _lwrite(fil,addr(org^.idNom),1);
      idWriteS(fil,org^.idName);
    end;
  end idWriteFFFF;

//------ Запись ссылок на другой модуль в списке --------

  procedure idWriteLIST(fil:integer; list,org:pLIST; max:integer);
  var j:integer;
  begin
    for j:=1 to max do
      idWriteFFFF(fil,list^[j],org^[j]);
    end
  end idWriteLIST;

//------ Замена ссылки на другой модуль (чтение) --------

  procedure idReadFFFF(var S:recStream; fil:integer; var id:pID);
  var s:pstr; nom:integer;
  begin
    if id=address(-1) then
      nom:=0; _lread(fil,addr(nom),1); nom:=tabGetImpNo(S,nom,true);
      idReadS(fil,s);
      id:=tabGetImpId(S,nom,s,true);
      memFree(s);
    elsif id<>nil then id:=pID(cardinal(id) or 0x80000000)
    end;
  end idReadFFFF;

//------ Замена ссылок на другой модуль в списке (чтение) --------

  procedure idReadLIST(var S:recStream; fil:integer; list:pLIST; max:integer);
  var j:integer;
  begin
    for j:=1 to max do
      idReadFFFF(S,fil,list^[j]);
    end
  end idReadLIST;

//------ Запись идентификатора на диск --------

  procedure idWriteID(id:pID; fil:integer);
  var i:integer; buf:recID; list,list2:pLIST;
  begin
    buf:=id^;
    list:=nil;
    list2:=nil;
  with buf do
  //замена ссылок на внешние модули
    case idClass of
      idcSTRU:idSubsFFFF(idStruType,id);|
      idcSCAL:idSubsFFFF(idScalType,id);|
      idtARR:idSubsFFFF(idArrItem,id); idSubsFFFF(idArrInd,id);|
      idtREC:idSubsFFFF(idRecCla,id); list:=idSubsLIST(idRecList,idRecMax,id); list2:=idSubsLIST(idRecMet,idRecTop,id);|
      idtSCAL:list:=idSubsLIST(idScalList,idScalMax,id);|
      idtPOI:idSubsFFFF(idPoiType,id);|
      idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR:idSubsFFFF(idVarType,id);|
      idPROC:
        list:=idSubsLIST(idProcList,idProcMax,id);
        list2:=idSubsLIST(idLocList,idLocMax,id);
        idSubsFFFF(idProcType,id);
        idSubsFFFF(idProcCla,id);|
    end;
  //запись идентификатора
    _lwrite(fil,addr(buf),sizeof(recID));
    i:=lstrlen(idName);
    _lwrite(fil,addr(i),4);
    if i>0
      then _lwrite(fil,idName,i)
      else mbI(integer(idClass),_ОШИБКА_Идентификатор_без_имени[envER])
    end;
  //запись списков
    case idClass of
      idcSTR:idWriteS(fil,idStr);|
      idtREC:
        if idRecMax>0 then _lwrite(fil,addr(list^),idRecMax*4) end;
        if idRecTop>0 then _lwrite(fil,addr(list2^),idRecTop*4) end;|
      idtSCAL:if idScalMax>0 then _lwrite(fil,addr(list^),idScalMax*4) end;|
      idPROC:
        if idProcMax>0 then _lwrite(fil,addr(list^),idProcMax*4) end;
        if idLocMax>0 then _lwrite(fil,addr(list2^),idLocMax*4) end;
        if idProcDLL<>nil then
          i:=lstrlen(idProcDLL);
          _lwrite(fil,addr(i),4);
          _lwrite(fil,idProcDLL,i);
        end;|
    end;
  //запись ссылок на внешние модули
    case idClass of
      idcSTRU:idWriteFFFF(fil,idStruType,id^.idStruType);|
      idcSCAL:idWriteFFFF(fil,idScalType,id^.idScalType);|
      idtARR:idWriteFFFF(fil,idArrItem,id^.idArrItem); idWriteFFFF(fil,idArrInd,id^.idArrInd);|
      idtREC:idWriteFFFF(fil,idRecCla,id^.idRecCla); idWriteLIST(fil,list,id^.idRecList,idRecMax); idWriteLIST(fil,idRecMet,id^.idRecMet,idRecTop);|
      idtSCAL:idWriteLIST(fil,list,id^.idScalList,idScalMax);|
      idtPOI:idWriteFFFF(fil,idPoiType,id^.idPoiType);|
      idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR:idWriteFFFF(fil,idVarType,id^.idVarType);|
      idPROC:
        idWriteLIST(fil,list,id^.idProcList,idProcMax);
        idWriteLIST(fil,list2,id^.idLocList,idLocMax);
        idWriteFFFF(fil,idProcCla,id^.idProcCla);
        idWriteFFFF(fil,idProcType,id^.idProcType);|
    end;
    if list<>nil then memFree(list) end;
    if list2<>nil then memFree(list2) end;
  end
  end idWriteID;

//------ Чтение идентификатора с диска --------

  procedure idReadID(var S:recStream; id:pID; fil:integer):boolean;
  var i:integer;
  begin
  with id^ do
  //чтение идентификатора
    RtlZeroMemory(id,sizeof(recID));
    _lread(fil,id,sizeof(recID));
    if idClass=idNULL then return false end;
    _lread(fil,addr(i),4);
    if i>0 then
      idName:=memAlloc(i+1);
      _lread(fil,idName,i);
      idName[i]:='\0';
    else idName:=nil
    end;
  //чтение списков
    case idClass of
      idcSTR:idReadS(fil,idStr);|
      idtREC:
        if idRecMax>0 then idRecList:=memAlloc(idRecMax *4); _lread(fil,addr(idRecList^),idRecMax *4) end;
        if idRecTop>0 then idRecMet:=memAlloc(idRecTop *4); _lread(fil,addr(idRecMet^),idRecTop *4) end;|
      idtSCAL:if idScalMax>0 then idScalList:=memAlloc(idScalMax*4); _lread(fil,addr(idScalList^),idScalMax*4) end;|
      idPROC:
        if idProcMax>0 
          then idProcList:=memAlloc(idProcMax*4); _lread(fil,addr(idProcList^),idProcMax*4)
          else idProcList:=nil
        end;
        if idLocMax>0 
          then idLocList:=memAlloc(idLocMax*4); _lread(fil,addr(idLocList^),idLocMax*4)
          else idLocList:=nil
        end;
        if idProcDLL<>nil then
          _lread(fil,addr(i),4);
          idProcDLL:=memAlloc(i+1);
          _lread(fil,idProcDLL,i);
          idProcDLL[i]:='\0';
        end;|
    end;
    //замена ссылок на внешние модули
    case idClass of
      idcSTRU:idReadFFFF(S,fil,idStruType);|
      idcSCAL:idReadFFFF(S,fil,idScalType);|
      idtARR:idReadFFFF(S,fil,idArrItem); idReadFFFF(S,fil,idArrInd);|
      idtREC:idReadFFFF(S,fil,idRecCla); idReadLIST(S,fil,idRecList,idRecMax); idReadLIST(S,fil,idRecMet,idRecTop);|
      idtSCAL:idReadLIST(S,fil,idScalList,idScalMax);|
      idtPOI:idReadFFFF(S,fil,idPoiType);|
      idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR:idReadFFFF(S,fil,idVarType);|
      idPROC:
        idReadLIST(S,fil,idProcList,idProcMax);
        idReadLIST(S,fil,idLocList,idLocMax);
        idReadFFFF(S,fil,idProcType);
        idReadFFFF(S,fil,idProcCla);|
    end;
    return true
  end
  end idReadID;

//--------- Запись таблицы на диск ------------

  procedure idWrite(var tab:pID; fil:integer);
  begin
  if tab<>nil then
    idWriteID(tab,fil);
    idWrite(tab^.idLeft,fil);
    idWrite(tab^.idRight,fil);
  end
  end idWrite;

//----------- Замена номера модуля при импорте ------------------

procedure tabGetImpNo(var S:recStream; oldNo:integer; bitMess:boolean):integer;
var i:integer;
begin
  if oldNo>topModImp then lexTest(bitMess,S,_Неверный_номер_модуля[envER],nil);
  else
    for i:=1 to topMod do
    if lstrcmpi(tbMod[i].modNam,tbModImp[oldNo])=0 then
      return i
    end end
  end;
  lexTest(bitMess,S,_Не_найден_модуль_[envER],tbModImp[oldNo]);
  return 0
end tabGetImpNo;

//----------- Поиск идентификатора при импорте ------------------

procedure tabGetImpId(var S:recStream; no:integer; name:pstr; bitMess:boolean):pID;
var res:pID;
begin
  if no=0 then return nil end;
  res:=idFind(tbMod[no].modTab,name);
  lexTest(bitMess and(res=nil),S,_В_модуле_не_найден_идентификатор_[envER],name);
  return res
end tabGetImpId;

//-------------- Замена ссылки ----------------

  procedure tabSub(ids:pSubs; top:integer; var id:pID):boolean;
  var i:integer;
  begin
    if id=nil then return false end;
    for i:=1 to top do
    if pID(cardinal(ids^[i]^.idOwn) or 0x80000000)=id then
      id:=ids^[i];
      return true
    end end;
    return false
  end tabSub;

//-------------- Замена ссылок ----------------

  procedure tabSubs(sub:classSub; var id:pID; baseId:pID; no:integer);
  var s:string[maxText];
  begin
  if (cardinal(id) and 0x80000000)<>0 then
    with tbMod[no] do
      if tabSub(modSbs[sub],modTop[sub],id) then return end
    end;
    lstrcpy(s,_Системная_в_tabSubs_[envER]);
    lstrcat(s,baseId^.idName);
    mbI(ord(sub),s)
  end
  end tabSubs;

//---------- Замена идентификатора ------------

  procedure tabSubsID(id:pID; no:integer);
  var i,j:integer;
  begin
  with id^ do
    case idClass of
      idcSTRU:tabSubs(subTYPE,idStruType,id,no);|
      idcSCAL:tabSubs(subTYPE,idScalType,id,no);|
      idtARR:tabSubs(subTYPE,idArrItem,id,no); tabSubs(subTYPE,idArrInd,id,no);|
      idtREC:tabSubs(subTYPE,idRecCla,id,no);
        for j:=1 to idRecMax do tabSubs(subFIELD,idRecList^[j],id,no) end;
        for j:=1 to idRecTop do tabSubs(subMETHOD,idRecMet^[j],id,no) end;|
      idtSCAL:for j:=1 to idScalMax do tabSubs(subNULL,idScalList^[j],id,no) end;|
      idtPOI:tabSubs(subTYPE,idPoiType,id,no);|
      idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR:tabSubs(subTYPE,idVarType,id,no);|
      idPROC:
        for j:=1 to idProcMax do
          tabSubs(subPAR,idProcList^[j],id,no);
        end;
        for j:=1 to idLocMax do
          tabSubs(subLOC,idLocList^[j],id,no);
        end;
        tabSubs(subTYPE,idProcType,id,no);
        tabSubs(subTYPE,idProcCla,id,no);|
    end
  end
  end tabSubsID;

//--------- Чтение таблицы с диска ------------

  procedure idRead(var S:recStream; var tab:pID; fil:integer; no:integer);
  var id:recID; p,own,left,right:pID; i,j,newNom:integer; sub:classSub;
  begin
  with tbMod[no] do
//инициализация таблицы замены ссылок
    for sub:=subNULL to subPAR do
      if modSbs[sub]=nil then
        modSbs[sub]:=memAlloc(sizeof(arrSubs))
      end;
      modTop[sub]:=0;
    end;
//чтение идентификаторов
    p:=memAlloc(sizeof(recID));
    while idReadID(S,p,fil) do
      envInf(_Импорт_[envER],genNameModule,_llseek(fil,0,1)*100 div _lsize(fil));
      own:=idInsert(modTab,p^.idName,p^.idClass,tabMod,no);
      if own<>nil then
        left:=own^.idLeft;
        right:=own^.idRight;
        own^:=p^;
        own^.idLeft:=left;
        own^.idRight:=right;
        own^.idNom:=no;
        if  not (own^.idClass in [idvFIELD,idvPAR,idvLOC,idvVPAR]) then
          own^.idActiv:=own^.idH;
        end;
        own^.idH:=byte(false);
        case own^.idClass of
          idtBAS,idtARR,idtREC,idtPOI,idtSCAL:sub:=subTYPE;|
          idvFIELD:sub:=subFIELD;|
          idvPAR,idvVPAR:sub:=subPAR;|
          idvLOC:sub:=subLOC;|
          idPROC:if own^.idProcCla=nil then sub:=subPROC else  sub:=subMETHOD end;|
        else sub:=subNULL;
        end;
        subAdd(modSbs[sub],own,modTop[sub])
      else mbS(_Системная_ошибка_в_idRead[envER])
      end
    end;
    memFree(p);
//переназначение указателей
    for sub:=subNULL to subPAR do
    for i:=1 to modTop[sub] do
      tabSubsID(modSbs[sub]^[i],no)
    end end;
//присвоение собственных адресов
    for sub:=subNULL to subPAR do
    for i:=1 to modTop[sub] do
      modSbs[sub]^[i]^.idOwn:=modSbs[sub]^[i];
    end end;
  end
  end idRead;

//--------- Смена номера модуля ------------

  procedure idChangeMod(tab:pID; old,New:integer);
  begin
  if tab<>nil then
    with tab^ do
      if idNom=old then
        idNom:=New
      end
    end;
    idChangeMod(tab^.idLeft,old,New);
    idChangeMod(tab^.idRight,old,New);
  end
  end idChangeMod;

//---- Запись таблицы в файл (отладочная) -----

  procedure idView(var tab:pID; fil:integer);
  var s:pstr;
  begin
    s:=memAlloc(maxText);
    if tab<>nil then 
    with tab^ do
      lstrcpy(s,idName);
      lstrcat(s,' left: ' ); if idLeft <>nil then lstrcat(s,idLeft ^.idName) end;
      lstrcat(s,' right: '); if idRight<>nil then lstrcat(s,idRight^.idName) end;
      _lwrite(fil,s,lstrlen(s));
      _lwrite(fil,"\13\10",2);
      idView(idLeft,fil);
      idView(idRight,fil);
    end end;
    memFree(s)
  end idView;

  procedure idViewMod0;
  var fil:integer;
  begin
    fil:=_lcreat(filName,0);
    idView(tbMod[1].modTab,fil);
    _lclose(fil)
  end idViewMod0;

//===============================================
//            СПИСКИ ИДЕНТИФИКАТРОВ
//===============================================

//---------- Вставка в список -----------------

  procedure listAdd(addLIST:pLIST; addID:pID; var addTop:integer);
  begin
    if addTop<maxLIST then
      inc(addTop);
      addLIST^[addTop]:=addID
    else mbS(_Переполнение_списка_идентификаторов[envER])
    end
  end listAdd;

//----------- Поиск в списке -----------------

  procedure listFind(list:pLIST; top:integer; name:pstr):pID;
  var i:integer;
  begin
    if list<>nil then
      for i:=1 to top do
      with list^[i]^ do
        if boolean(idActiv) and(lstrcmp(name,idName)=0) then
          return list^[i];
        end
      end end
    end;
    return nil
  end listFind;

//--------- Вставка в список замен ------------

  procedure subAdd(addSUB:pSubs; addID:pID; var addTop:integer);
  begin
    if addTop<maxSubs then
      inc(addTop);
      addSUB^[addTop]:=addID
    else mbS(_Переполнение_списка_замен[envER])
    end
  end subAdd;

//----------- Добавить в список имен -----------------

  procedure nameAdd(list:pName; name:pstr; var top:integer);
  begin
    if top<maxLIST then
      inc(top);
      list^[top]:=memAlloc(lstrlen(name)+1);
      lstrcpy(list^[top],name);
    else mbS(_Переполнение_списка_идентификаторов[envER])
    end
  end nameAdd;

//----------- Поиск в списке имен -----------------

  procedure nameFind(list:pName; top:integer; name:pstr):integer;
  var i:integer;
  begin
    if list<>nil then
    for i:=1 to top do
      if lstrcmp(name,list^[i])=0 then
        return i
      end
    end end;
    return 0
  end nameFind;

//===============================================
//               СПИСКИ ИМПОРТА
//===============================================

//--------- Поиск в списке импорта -----------

  procedure impFind(addIMP:pIMPORT; addDLL,addFun:pstr; var addTop,nomDLL,nomFun:integer);
  var i:integer;
  begin
    nomDLL:=0;
    nomFun:=0;
    if addIMP<>nil then
//поиск DLL
      for i:=1 to addTop do
      if lstrcmp(addDLL,addIMP^[i].impName)=0 then
        nomDLL:=i
      end end;
      if nomDLL<>0 then
      with addIMP^[nomDLL] do
//поиск функции
        for i:=1 to impTop do
        if lstrcmp(addFun,impFuns^[i].funName)=0 then
          nomFun:=i
        end end
      end end
    end
  end impFind;

//-------- Вставка в список импорта ------------

  procedure impAdd(addIMP:pIMPORT; addDLL,addFun:pstr; addAddr:integer; var addTop:integer):address;
  var i,nomDLL,nomFun:integer;
  begin
  if addIMP=nil then mbS(_Неинициализирован_список_импорта[envER])
  else
//определение DLL
    impFind(addIMP,addDLL,addFun,addTop,nomDLL,nomFun);
    if nomDLL=0 then
    if addTop=maxImpDLL then mbS(_Слишком_много_вызовов_DLL[envER])
    else
      inc(addTop);
      with addIMP^[addTop] do
        impName:=memAlloc(lstrlen(addDLL)+1); lstrcpy(impName,addDLL);
        impFuns:=memAlloc(sizeof(arrIMPFUN));
        impTop:=0;
      end;
      nomDLL:=addTop
    end end;
//определение функции
    if nomFun=0 then
    with addIMP^[nomDLL] do
    if impTop=maxImpFun then mbS(_Слишком_много_вызовов_DLL[envER])
    else
      inc(impTop);
      with impFuns^[impTop] do
        funName:=memAlloc(lstrlen(addFun)+1); lstrcpy(funName,addFun);
        funCALL:=nil;
        funRVA :=0;
        funTop :=0;
      end;
      nomFun:=impTop
    end end end;
//добавление вызова функции
    if addAddr<>0 then
    with addIMP^[nomDLL].impFuns^[nomFun] do
    if funTop=maxImpCALL then mbS(_Слишком_много_вызовов_DLL[envER])
    else
      inc(funTop);
      if funCALL=nil then
        funCALL:=memAlloc(sizeof(arrCALL))
      end;
      funCALL^[funTop]:=addAddr;
      return addr(funCALL^[funTop])
    end end end
  end;
  return nil
  end impAdd;

//--------- Очистка списка импорта ------------

  procedure impDestroy(addIMP:pIMPORT; addTop:integer);
  var i,j:integer;
  begin
    for i:=1 to addTop do
    with addIMP^[i] do
      memFree(impName);
      for j:=1 to impTop do
      with impFuns^[j] do
        memFree(funName);
        memFree(funCALL);
      end end;
      memFree(impFuns)
    end end;
    memFree(addIMP)
  end impDestroy;

//------ Запись в файл списка импорта ---------

  procedure impWrite(addIMP:pIMPORT; addTop:integer; fil:integer);
  var i,j,l:integer;
  begin
    for i:=1 to addTop do
    with addIMP^[i] do
      l:=lstrlen(impName);
      _lwrite(fil,addr(l),4);
      _lwrite(fil,impName,lstrlen(impName));
      _lwrite(fil,addr(impTop),4);
      for j:=1 to impTop do
      with impFuns^[j] do
        l:=lstrlen(funName);
        _lwrite(fil,addr(l),4);
        _lwrite(fil,funName,lstrlen(funName));
        _lwrite(fil,addr(funTop),4);
        _lwrite(fil,addr(funRVA),4);
        _lwrite(fil,addr(funCALL^),integer(funTop)*4);
      end end
    end end
  end impWrite;

//----- Чтение из файла списка импорта --------

  procedure impRead(addIMP:pIMPORT; addTop:integer; fil:integer);
  var i,j,l:integer;
  begin
    for i:=1 to addTop do
    with addIMP^[i] do
      _lread(fil,addr(l),4); impName:=memAlloc(l+1);
      _lread(fil,impName,l); impName[l]:=char(0);
      _lread(fil,addr(impTop),4);
      impFuns:=memAlloc(sizeof(arrIMPFUN));
      for j:=1 to impTop do
      with impFuns^[j] do
        _lread(fil,addr(l),4); funName:=memAlloc(l+1);
        _lread(fil,funName,l); funName[l]:=char(0);
        _lread(fil,addr(funTop),4);
        _lread(fil,addr(funRVA),4);
        if funTop>0 then
          funCALL:=memAlloc(sizeof(arrCALL));
          _lread(fil,addr(funCALL^),integer(funTop)*4);
        else funCALL:=nil
        end
      end end
    end end
  end impRead;

//--------- Добавить в список экспорта ------------

  procedure expAdd(expo:pEXPORT; name:pstr; var top:integer);
  var pos,i:integer;
  begin
    if top=maxExport then mbS(_Слишком_много_экспортируемых_имен[envER])
    else
      pos:=1;
      while (pos<top)and(lstrcmp(name,expo^[pos])>0) do
        inc(pos)
      end;
      if (pos=top)and(lstrcmp(name,expo^[pos])>0) then
        inc(pos)
      end;
      for i:=top+1 downto pos+1 do
        expo^[i]:=expo^[i-1];
      end;
      inc(top);
      expo^[pos]:=memAlloc(lstrlen(name)+1);
      lstrcpy(expo^[pos],name);
    end
  end expAdd;

//--------- Очистка списка экспорта ------------

  procedure expDestroy(expo:pEXPORT; top:integer);
  var i:integer;
  begin
    for i:=1 to top do
      memFree(expo^[i]);
    end;
    memFree(expo)
  end expDestroy;

//------ Запись в файл списка экспорта ---------

  procedure expWrite(expo:pEXPORT; top:integer; fil:integer);
  var i,j,l:integer;
  begin
    for i:=1 to top do
      l:=lstrlen(expo^[i]);
      _lwrite(fil,addr(l),4);
      _lwrite(fil,expo^[i],lstrlen(expo^[i]));
    end
  end expWrite;

//----- Чтение из файла списка экспорта --------

  procedure expRead(expo:pEXPORT; top:integer; fil:integer);
  var i,j,l:integer;
  begin
    for i:=1 to top do
      _lread(fil,addr(l),4); expo^[i]:=memAlloc(l+1);
      _lread(fil,expo^[i],l); expo^[i][l]:=char(0);
    end
  end expRead;

//===============================================
//               СПИСКИ СТРОК
//===============================================

//---------- Вставка в список -----------------

  procedure stringAdd;
  begin
    if addTop<maxSTRING then
      inc(addTop);
      with addSTRING^[addTop] do
        stringSou:=addSou;
        stringPoi:=memAlloc(lstrlen(addStr)+1);
        lstrcpy(stringPoi,addStr);
      end;
    else mbS(_Переполнение_списка_строковых_констант[envER])
    end
  end stringAdd;

//----------- Очистка списка ------------------

  procedure stringFree;
  var i:integer;
  begin
    for i:=1 to addTop do
      memFree(addSTRING^[i].stringPoi)
    end;
    addTop:=0
  end stringFree;


//===============================================
//            РАБОТА СО СПИСКОМ БРЕЙКОВ
//===============================================

//----------- Добавить в список брейков ------------------

  procedure stepAdd(var S:recStream; nom:integer; addClass:classStep);
  begin
    with tbMod[nom] do
    if topGenStep<maxStep then
      inc(topGenStep);
      with genStep^[topGenStep] do
        Class:=addClass;
        source:=topCode;
        level:=byte(stepTopStack);
        line:=word(S.stPosLex.y);
        frag:=word(S.stPosLex.f);
      end
    end end
  end stepAdd;

//----------- Поместить брейк в стек ------------------

  procedure stepPush(pushClass:classStep; pushParent:integer);
  begin
    if stepTopStack<maxStackStep then
      inc(stepTopStack);
      with stepStack[stepTopStack] do
        Class:=pushClass;
        parent:=pushParent;
      end
    end
  end stepPush;

//----------- Извлечь брейк из стека ------------------

  procedure stepPop();
  begin
    if stepTopStack=0
      then mbS(_Системная_ошибка_в_stepPop[envER])
      else dec(stepTopStack);
    end
  end stepPop;

//===============================================
//            ИНФОРМАЦИОННОЕ ОКНО
//===============================================

//------------ Диалог Progress --------------

const DIALOGINFO=stringER{"DIALOGINFO_R","DIALOGINFO_E"};

dialog DIALOGINFO_R 65, 55, 200, 47,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "ИНФОРМАЦИЯ"
begin
  control "Сообщение", 101, "Static", 0 | WS_CHILD | WS_VISIBLE, 12, 6, 174, 10
  control "", 102, "msctls_progress32", WS_CHILD | WS_VISIBLE | WS_BORDER, 12, 19, 174, 10
  control "", 103, "Static", 2 | WS_CHILD | WS_VISIBLE, 149, 34, 37, 10
end;
dialog DIALOGINFO_E 65, 55, 200, 47,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "INFORMATION"
begin
  control "Message", 101, "Static", 0 | WS_CHILD | WS_VISIBLE, 12, 6, 174, 10
  control "", 102, "msctls_progress32", WS_CHILD | WS_VISIBLE | WS_BORDER, 12, 19, 174, 10
  control "", 103, "Static", 2 | WS_CHILD | WS_VISIBLE, 149, 34, 37, 10
end;

//-------- Диалоговая функция Progress --------

  procedure winDlgProg(Wnd:HWND; Message,wParam,lParam:integer):boolean;
  begin
    case Message of
      WM_INITDIALOG:|
      WM_COMMAND:case wParam of
        121:if MessageBox(0,_Прекратить_обработку__[envER],"ВНИМАНИЕ:",MB_YESNO)=IDYES then
          infCancel:=true
        end;|
      end;|
    else return false
    end;
    return true
  end winDlgProg;

//------------ Создание Progress --------------

  procedure envInfBegin;
  var s:string[maxText];
  begin
    lstrcpy(s,title);
    if title2<>nil then
      lstrcat(s,title2)
    end;
    infDlg:=CreateDialogParam(hINSTANCE,DIALOGINFO[envER],mainWnd,addr(winDlgProg),0);
    SetWindowText(infDlg,s);
    SetWindowText(GetDlgItem(infDlg,101),nil);
    SendDlgItemMessage(infDlg,102,PBM_SETSTEP,1,0);
  end envInfBegin;

//------------ Удаление Progress --------------

  procedure envInfEnd;
  begin
    DestroyWindow(infDlg);
  end envInfEnd;

//---------- Сообщение в Progress -------------

  procedure envInf;
  var i:integer; my:string[15]; te,te2:pstr;
  begin
    te:=memAlloc(maxText); te[0]:=char(0);
    te2:=memAlloc(maxText);
    if s1<>nil then lstrcpy(te,s1) end;
    if s1<>nil then lstrcat(te,s2) end;
    if pro<0 then pro:=0 end;
    if pro>100 then pro:=100 end;
    wvsprintf(my,"%li %%",addr(pro));
    GetWindowText(GetDlgItem(infDlg,101),te2,maxText);
    if lstrcmp(te,te2)<>0 then
      SetWindowText(GetDlgItem(infDlg,101),te)
    end;
    SendDlgItemMessage(infDlg,102,PBM_SETPOS,pro,0);
    GetWindowText(GetDlgItem(infDlg,103),te2,maxText);
    if lstrcmp(my,te2)<>0 then
      SetWindowText(GetDlgItem(infDlg,103),my)
    end;
    memFree(te);
    memFree(te2)
  end envInf;

end SmTab.
