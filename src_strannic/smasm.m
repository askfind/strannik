//�������� ������-��-������� ��� Win32
//������ ASM (���������� ���������)
//���� SMASM.M

implementation module SmAsm;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex;

//------------- ���� � ������ -----------------

const MaxName=30;
      MaxTab =50;
      MaxJamp=50;

type transtype=record case of
      |ww,ww2:word;
      |b1,b2,b3,b4:byte;
      |i:integer;
    end;

    TypeTab=record
      Name:string[MaxName];
      Eval:integer;
    end;

var
  Tabs:array[1..MaxTab]of pointer to TypeTab; TopTab:integer;
  Jamps:array[1..MaxJamp]of record
    Lab  :integer;
    Track:integer; //{�������� ������ �������}
    Size :byte;
    Def  :boolean; //{������� ��������� ��������}
  end;
  TopJamp:integer;

//----- ������������� � ������������ ----------

procedure asmInitial;
var i:integer;
begin
  for i:=1 to MaxTab do
    Tabs[i]:=nil;
  end;
  TopTab :=0;
  TopJamp:=0;
end asmInitial;

procedure asmDestroy;
var i:integer;
begin
  for i:=1 to TopTab do
    memFree(Tabs[i]);
  end;
  TopTab :=0;
  TopJamp:=0;
end asmDestroy;

//----------- ����� �������������� ------------

  procedure TabFind(Name:pstr):integer;
  var i:integer;
  begin
    for i:=1 to TopTab do
    if lstrcmp(Tabs[i]^.Name,Name)=0 then
      return i
    end end;
    return 0
  end TabFind;

//--------- ������� �������������� ------------

  procedure TabInsert(var S:recStream; Nam:pstr; Eval:integer);
  begin
    if TopTab=MaxTab then lexError(S,_�������_�����_�����[envER],nil)
    elsif TabFind(Nam)<>0 then lexError(S,_�����_���_�������[envER],nil)
    else
      inc(TopTab);
      Tabs[TopTab]:=memAlloc(sizeof(TypeTab));
      lstrcpy(Tabs[TopTab]^.Name,Nam);
      Tabs[TopTab]^.Eval :=Eval;
    end
  end TabInsert;

//------------- ������� ����� -----------------

  procedure TabDefLabel(var S:recStream; Nam:pstr; Define:boolean; var My:integer);
  begin
    My:=TabFind(Nam);
    if (My<>0) and Define and (Tabs[My]^.Eval<>0) then lexError(S,_�����_���_������������[envER],nil) end;
    if My=0 then
      TabInsert(S,Nam,0);
      My:=TopTab
    end;
    with Tabs[My]^ do
      lstrcpy(Name,Nam);
      if Define
        then Eval:=tbMod[tekt].topCode
        else Eval:=0;
      end
    end
  end TabDefLabel;

//----------- ������� �������� ----------------

  procedure TabDefJamp(var S:recStream; Lab:pstr; Instr:classCommand);
  var My:integer;
  begin
    if TopJamp=MaxJamp 
      then lexError(S,_�������_�����_������_��������[envER],nil)
      else inc(TopJamp);
    end;
    My:=TabFind(Lab);
    if My=0 then TabDefLabel(S,Lab,false,My) end;
    with Jamps[TopJamp] do
      Lab:=My;
      Track:=tbMod[tekt].topCode;
      Def:=false;
      case Instr of
        cJCXZ,cLOOP,
        cLOOPE,cLOOPNE:Size:=2;|
        cCALL,cJMP:Size:=5;|
        else Size:=6;
      end
    end
  end TabDefJamp;

//----------- ��������� �������� --------------

  procedure asmEqv(var S:recStream; var W:cardinal; W1:cardinal; BitSel:boolean);
  begin
    if (W<>0)and(W1<>0)and(W<>W1) 
      then lexError(S,_��������_������_���������[envER],nil)
      else if W=0 then W:=W1 end
    end;
    if BitSel and (W=0) then lexError(S,_��������_������_���������[envER],nil) end
  end asmEqv;

//----------- �������-��������� ---------------

  procedure asmConst(var S:recStream; var Data:integer);
  var BitMin:boolean; Car:integer; Ope:classLex;
  begin
  with S do
    BitMin:=okPARSE(S,pMin);
    if BitMin then lexGetLex1(S) end;
    case stLex of
      lexINT,lexCHAR:Data:=stLexInt; lexGetLex1(S);|
    else lexError(S,_���������_���������[envER],nil)
    end;
    if BitMin then
      Data:=-Data;
    end
  end
  end asmConst;

//------------- �������-������ ----------------

 procedure asmMemory(var S:recStream;
                     PrefReg:classRegister;
                     var Class:classOperand;
                     var PrefS,Base,Indx:classRegister;
                     var Dist:integer; var W:cardinal);
  var MyR:classRegister; My,IntDist:integer; trans:transtype;
  begin
  with S do
    lexAccept1(S,lexPARSE,integer(pSqL));
    Class:=oM;
    W:=0;
//  {�������}
    PrefS:=PrefReg;

//  {����}
    Base:=regNULL;
    MyR:=regNULL;
    if stLex=lexREG then
      MyR:=classRegister(stLexInt)
    end;
    case MyR of
      rEBX,rBX:Base:=rEBX;|
      rEBP,rBP:Base:=rEBP;|
    end;
    if Base<>regNULL then lexAccept1(S,lexREG,0) end;
    if okPARSE(S,pPlu) then lexAccept1(S,lexPARSE,integer(pPlu)) end;

//  {������}
    Indx:=regNULL;
    if stLex=lexREG then
      MyR:=classRegister(stLexInt)
    end;
    case MyR of
      rSI,rESI:Indx:=rESI;|
      rDI,rEDI:Indx:=rEDI;|
    end;
    if Indx<>regNULL then lexAccept1(S,lexREG,0) end;
    if okPARSE(S,pPlu) then lexAccept1(S,lexPARSE,integer(pPlu)) end;

//  {��������}
    IntDist:=0;
    if (stLex=lexINT)or(stLex=lexCHAR) then
      asmConst(S,IntDist)
    end;
    if okPARSE(S,pPlu) then lexAccept1(S,lexPARSE,integer(pPlu)) end;

//  {����������}
    if okREZ(S,rOFFS) then
      lexAccept1(S,lexREZ,integer(rOFFS));
      lexAccept1(S,lexPARSE,integer(pOvL));
      if (stLex=lexFIELD)or(stLex=lexVAR)or(stLex=lexLOC)or(stLex=lexPAR)or(stLex=lexVPAR) then
        if stLex=lexVAR then
          inc(IntDist,genBASECODE+0x1000+tbMod[stLexID^.idNom].genBegData);
          modVarCallAsm:=stLexID^.idNom;
        end;
        inc(IntDist,stLexID^.idVarAddr);
        lexGetLex1(S)
      else lexError(S,_���������_���_����������[envER],nil)
      end;
      lexAccept1(S,lexPARSE,integer(pOvR));
    end;

    lexAccept1(S,lexPARSE,integer(pSqR));
    Dist:=IntDist
  end
  end asmMemory;

//------------ ������� ������� ----------------

  procedure asmOperand(var S:recStream;
                       var Class:classOperand;
                       var Reg,PrefS,Base,Indx:classRegister;
                       var Dist,Data:integer; var W:cardinal);
  var My:integer; MyR:classRegister; MyL:integer;
  begin
  with S do
    W:=0;
//���������
    if (stLex=lexINT)or(stLex=lexCHAR)or
       okPARSE(S,pPlu)or okPARSE(S,pMin)then
      Class:=oD;
      asmConst(S,MyL);
      Data:=MyL;
//������
    elsif okPARSE(S,pSqL) then asmMemory(S,regNULL,Class,PrefS,Base,Indx,Dist,W)
//�������� ����������
    elsif okREZ(S,rOFFS) then
      lexAccept1(S,lexREZ,integer(rOFFS));
      lexAccept1(S,lexPARSE,integer(pOvL));
      if (stLex=lexFIELD)or(stLex=lexVAR)or(stLex=lexLOC)or(stLex=lexPAR)or(stLex=lexVPAR) then
        Class:=oD;
        Data:=stLexID^.idVarAddr;
        lexGetLex1(S)
      else lexError(S,_���������_���_����������[envER],nil)
      end;
      lexAccept1(S,lexPARSE,integer(pOvR));
//�������
    elsif stLex=lexREG then
      MyR:=classRegister(stLexInt);
      case MyR of
        rEAX..rEDI,rST0..rST7://�������
          Class:=oE;
          Reg:=MyR;
          if Reg in[rAL..rDH] then W:=1
          elsif Reg in[rAX..rDI] then W:=2
          else W:=4
          end;
          lexAccept1(S,lexREG,0);|
        rCS..rGS://���������� ������� ��� ������
          Reg:=classRegister(stLexInt);
          Class:=oE;
          W:=2;
          lexAccept1(S,lexREG,0);
          if okPARSE(S,pDup) then
            lexAccept1(S,lexPARSE,integer(pDup));
            asmMemory(S,Reg,Class,PrefS,Base,Indx,Dist,W)
          end;|
      end
    else lexError(S,_��������_�������[envER],nil)
    end
  end
  end asmOperand;

//----------- �������� ������� --------------

  procedure asmLexOk(lex:classLex):boolean;
  begin
    return 
      (lex=lexNEW)or(lex=lexID)or(lex=lexSCAL)or(lex=lexREZ)or(lex=lexASM)or(lex=lexREG)or
      (lex=lexTYPE)or(lex=lexFIELD)or(lex=lexVAR)or(lex=lexLOC)or(lex=lexPAR)or
      (lex=lexVPAR)or(lex=lexPROC)
  end asmLexOk;

//----------- ���������� ������� --------------

  procedure asmCommand(var S:recStream);
  var BitParam:boolean; MyS:string[maxText]; My:integer;
      Instr,MyC:classCommand;
      Op,Op2:classOperand;
      PrefS,Base,Indx,Reg,Reg2:classRegister;
      Dist,Data:integer; W,W1:cardinal;
      trans:transtype;
  begin
  with S do
    modVarCallAsm:=0;

//  �����
    if stLex=lexNEW then
      lstrcpy(MyS,stLexStr);
      lexAccept1(S,lexNEW,0);
      lexAccept1(S,lexPARSE,integer(pDup));
      TabDefLabel(S,MyS,true,My);
    end;

//  ���������������� ��������
    if stLex=lexINT then
      W:=cardinal(stLexInt);
      if W>0xFFFFFF then genByte(S,(W>>24)& 0xFF); genByte(S,(W>>16)& 0xFF); genByte(S,(W>>8)& 0xFF); genByte(S,(W>>0)& 0xFF);
      elsif W>0xFFFF then genByte(S,(W>>16)& 0xFF); genByte(S,(W>>8)& 0xFF); genByte(S,(W>>0)& 0xFF);
      elsif W>0xFF then genByte(S,(W>>8)& 0xFF); genByte(S,(W>>0)& 0xFF);
      else genByte(S,(W>>0)& 0xFF);
      end;
      lexAccept1(S,lexINT,0);
//  ����������
    elsif (stLex<>lexEOF) and not okREZ(S,rEND) and not okPARSE(S,pFiR) then

//    ���������
      Instr:=classCommand(stLexInt);
      lexAccept1(S,lexASM,0);

//    ������
      W:=0;
      if asmLexOk(stLex) then
        if (lstrcmp("b",stLexStr)=0)or(lstrcmp("byte",stLexStr)=0) then W:=1; lexGetLex1(S)
        elsif (lstrcmp("w",stLexStr)=0)or(lstrcmp("word",stLexStr)=0) then W:=2; lexGetLex1(S)
        elsif (lstrcmp("d",stLexStr)=0)or(lstrcmp("dword",stLexStr)=0) then W:=4; lexGetLex1(S)
        elsif (lstrcmp("q",stLexStr)=0)or(lstrcmp("qword",stLexStr)=0) then W:=8; lexGetLex1(S)
        end        
      end;
      if asmLexOk(stLex)and(lstrcmp("ptr",stLexStr)=0) then
        lexGetLex1(S)
      end;

//    ���������
      case Instr of
        loMDCom..hiMDCom:
          asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,false);
          lexAccept1(S,lexPARSE,integer(pCol));
          asmOperand(S,Op2,Reg2,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,true);
          if (Op2=oD)and(asmCommands[Instr].cPri and 4=0) then lexError(S,_��������_�������[envER],nil)
          elsif (Op=oE)and(Op2=oE) then genRR(S,Instr,Reg,Reg2)
          elsif (Op=oE)and(Op2=oD) then genRD(S,Instr,Reg,Data)
          elsif (Op=oM)and(Op2=oE) then genMR(S,Instr,PrefS,Base,Indx,Reg2,Dist,0)
          elsif (Op=oE)and(Op2=oM) then genMR(S,Instr,PrefS,Base,Indx,Reg, Dist,1)
          elsif (Op=oM)and(Op2=oD) then genMD(S,Instr,PrefS,Base,Indx,Dist,Data,W)
          else lexError(S,_��������_�������[envER],nil)
          end;|
        loFMRCom..hiFMRCom:
          asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,false);
          if (Op=oM) then genM(S,Instr,PrefS,Base,Indx,Dist,W)
          elsif (Op=oE)and(Reg in [rST0..rST7]) then genST(S,Instr,Reg)
          else lexError(S,_��������_�������[envER],nil)
          end;|
        loFIMCom..hiFIMCom:
          asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,false);
          if (Op=oM) 
            then genM(S,Instr,PrefS,Base,Indx,Dist,W)
            else lexError(S,_��������_�������[envER],nil)
          end;|
        loFMCom..hiFMCom:
          asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,false);
          if (Op=oM) 
            then genM(S,Instr,PrefS,Base,Indx,Dist,W)
            else lexError(S,_��������_�������[envER],nil)
          end;|
        loFRCom..hiFRCom:
          asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,false);
          if (Op=oE)and(integer(Reg)>=integer(rST0))and(integer(Reg)<=integer(rST7))
            then genST(S,Instr,Reg)
            else lexError(S,_��������_�������[envER],nil)
          end;|
        loFCom..hiFCom:
          genByte(S,asmCommands[Instr].cCod);
          genByte(S,asmCommands[Instr].cDat);|
        loRCom..hiRCom:
          asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,true);
          lexAccept1(S,lexPARSE,integer(pCol));
          asmOperand(S,Op2,Reg2,PrefS,Base,Indx,Dist,Data,W1);
          if not((Op2=oD)or(Op2=oE)and(Reg2=rCL)) then lexError(S,_��������_�������[envER],nil)
          elsif (Op=oE)and(Op2=oD)and(Data=1) then genR(S,Instr,Reg)
          elsif (Op=oE)and(Op2=oD)and(Data<>1) then genRD(S,Instr,Reg,Data)
          elsif (Op=oM)and(Op2=oD) then with asmCommands[Instr] do
            if W=2 then genByte(S,0x66) end;
            genFirst(S,cDat,cPri,1,W);
            genPost(S,cExt,Base,Indx,Dist);
          end
          elsif (Op=oE)and(Op2=oE) then genRegCL(S,Instr,Reg)
          elsif (Op=oM)and(Op2=oE) then genM(S,Instr,PrefS,Base,Indx,Dist,W)
          else lexError(S,_��������_�������[envER],nil)
          end;|
        loMCom..hiMCom:
          if (Instr=cPOP)or(Instr=cPUSH) then W:=4 end;
          asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,true);
          if Op=oE then genR(S,Instr,Reg)
          elsif Op=oM then genM(S,Instr,PrefS,Base,Indx,Dist,W)
          else lexError(S,_��������_�������[envER],nil)
          end;|
        loLCom..hiLCom:
          lstrcpy(MyS,stLexStr);
          if asmLexOk(stLex)
            then lexGetLex1(S)
            else lexError(S,_���������_�����[envER],nil)
          end;
          TabDefJamp(S,MyS,Instr);
          genGen(S,Instr,1);|
        loOCom..hiOCom:case Instr of
          cIN:
            asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1);
            lexAccept1(S,lexPARSE,integer(pCol));
            asmOperand(S,Op2,Reg2,PrefS,Base,Indx,Dist,Data,W1);
            if not (
              (Op=oE)and(Reg=rAL)and
              ((Op2=oE)and(Reg2=rDX)or(Op2=oE)and(Reg2=rAX))) then lexError(S,_��������_�������[envER],nil)
            elsif Op=oE then with asmCommands[Instr] do genFirst(S,cDat,cPri,0,W) end
            else lexError(S,_���������_�_asmCommand[envER],nil)
            end;|
          cOUT:
            asmOperand(S,Op ,Reg, PrefS,Base,Indx,Dist,Data,W1);
            trans.ww:=Data;
            lexAccept1(S,lexPARSE,integer(pCol));
            asmOperand(S,Op2,Reg2,PrefS,Base,Indx,Dist,Data,W1);
            if not (
              ((Op=oD)and(Data<256)or(Op=oE)and(Reg=rDX)or(Op=oE)and(Reg=rAX))and
              ((Op2=oE)and(Reg2=rAL))) then lexError(S,_��������_�������[envER],nil)
            elsif Op=oD then with asmCommands[Instr] do genFirst(S,cCod,cPri,0,W); genByte(S,trans.b1) end
            elsif Op=oE then with asmCommands[Instr] do genFirst(S,cDat,cPri,0,W) end
            else lexError(S,_���������_�_asmCommand[envER],nil)
            end;|
          cINT:
            asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1); asmEqv(S,W,W1,false);
            if (Op<>oD)or(integer(W)>1) then lexError(S,_��������_�����_����������[envER],nil) end;
            trans.ww:=Data;
            with asmCommands[Instr] do genFirst(S,cCod,cPri,1,W) end;
            genByte(S,trans.b1);|
          cAAD,cAAM:
            genByte(S,asmCommands[Instr].cCod);
            genByte(S,asmCommands[Instr].cDat);|
          cCALL:
//          �����
            if asmLexOk(stLex)and(stLex<>lexREG) then
              lstrcpy(MyS,stLexStr);
              lexGetLex1(S);
              TabDefJamp(S,MyS,cCALL);
              genByte(S,asmCommands[Instr].cCod);
              genLong(S,0,4);
//          �������
            elsif stLex=lexREG then
            with asmCommands[cCALLF] do
              asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1);
              genFirst(S,cCod,cPri,0,W);
              case Op of
                oE:genByte(S,0xC0 + cExt + asmRegs[Reg].rCo);|
                oM:lexError(S,_���������_�������[envER],nil);|
              end
            end
//          ������
            elsif okPARSE(S,pSqL) then
            with asmCommands[cCALLF] do
              asmOperand(S,Op,Reg,PrefS,Base,Indx,Dist,Data,W1);
              genFirst(S,cCod,cPri,0,W);
              genPost(S,cExt,Base,Indx,Dist);
            end
            else lexError(S,_���������_�������[envER],nil);
            end;|
          cRET:
          if stLex<>lexINT then genD(S,Instr,0)
          else
            if Instr=cRET
              then genByte(S,0xC2)
              else genByte(S,0xCA)
            end;
            if stLex=lexINT then
              trans.ww:=stLexInt;
              genByte(S,trans.b1);
              genByte(S,trans.b2);
            end;
            lexGetLex1(S)
          end;|
        end;|
        loNCom..hiNCom:genGen(S,Instr,W);|
      else lexError(S,_���������_�_asmCommand[envER],nil);
      end;
      if modVarCallAsm>0 then
        genAddVarCall(S,tekt,modVarCallAsm,tbMod[tekt].topCode-3,vcCode,nil);
      end
    end
  end
  end asmCommand;

//---------- ����������� ��������� ------------

  procedure asmJamps(var S:recStream);
  var i:integer; trans:transtype;
  begin
    for i:=1 to TopJamp do with Jamps[i] do
      if not Def then
        if Tabs[Lab]^.Eval=0 then lexError(S,_��������������_�����[envER],nil) end;
        trans.i:=Tabs[Lab]^.Eval-Track-Size;
        case Size of
          2:if (trans.i<-128)or(trans.i>127) 
            then lexError(S,_�������_�������_�������_��_�����_[envER],nil)
            else tbMod[tekt].genCode^[Track+2]:=trans.b1
            end;|
          5:with tbMod[tekt] do
            genCode^[Track+2+0]:=trans.b1;
            genCode^[Track+2+1]:=trans.b2;
            genCode^[Track+2+2]:=trans.b3;
            genCode^[Track+2+3]:=trans.b4;
          end;|
          6:with tbMod[tekt] do
            genCode^[Track+3+0]:=trans.b1;
            genCode^[Track+3+1]:=trans.b2;
            genCode^[Track+3+2]:=trans.b3;
            genCode^[Track+3+3]:=trans.b4;
          end;|
        end;
        Def:=true;
      end
    end end;
  end asmJamps;

//---------- �������� ���������� --------------

  procedure asmAssembly;
  var bitREP:boolean;
  begin
  with S do
    while not ((stLex=lexEOF)or(stLex=lexNULL)or okREZ(S,rEND)or okPARSE(S,pFiR)) do
      bitREP:=okASM(S,cREP)or okASM(S,cREPE)or okASM(S,cREPNE);
      asmCommand(S);
      if not bitREP and not okREZ(S,rEND) then
        lexAccept1(S,lexPARSE,integer(pSem))
      end
    end;
    asmJamps(S);
  end
  end asmAssembly;

end SmAsm.
