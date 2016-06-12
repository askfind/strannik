//�������� ������-��-������� ��� Win32
//������ ENV (������� ��������������� �����)
//���� SMENV.M

implementation module SmEnv;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra,SmTraC,SmTraP,SmRes;

procedure envGetIdent(name:pstr; txt,X,Y:integer); forward;
procedure envBlockBound(t:integer); forward;

//===============================================
//                   ��������
//===============================================

//---------------- ������� �������� -------------------

procedure envCreateTitle(wnd:HWND);
var cy,dx,dy,x,y,len,i,lenExt,lenFree:integer; r,rTool:RECT; item:TC_ITEM; s:string[100];
begin
  InitCommonControls();
  GetClientRect(wnd,r);
  GetWindowRect(wndToolbar,rTool);
  dx:=loword(GetDialogBaseUnits());
  dy:=hiword(GetDialogBaseUnits());
  y:=rTool.bottom-rTool.top+1;
  cy:=dy*5 div 4;
  lenExt:=(r.right-r.left-1)*15 div 100;
  lenFree:=(r.right-r.left-1)*5 div 100;
  wndTabs:=CreateWindowEx(0,"SysTabControl32",nil,
    WS_CHILD | WS_VISIBLE | TCS_FOCUSNEVER,
    1,rTool.bottom-rTool.top,r.right-r.left-1-lenExt-lenFree,cy,wnd,0,hINSTANCE,nil);
  SendMessage(wndTabs,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
  for i:=1 to topt do
  with item do
    RtlZeroMemory(addr(item),sizeof(TC_ITEM));
    mask:=TCIF_TEXT;
    pszText:=addr(txts[0][i].txtTitle);
    SendMessage(wndTabs,TCM_INSERTITEM,i-1,cardinal(addr(item)));
  end end;
  SendMessage(wndTabs,TCM_SETCURSEL,tekt-1,0);
  wndExt:=CreateWindowEx(0,"SysTabControl32",nil,
    WS_CHILD | WS_VISIBLE | TCS_FOCUSNEVER,
    r.right-r.left-lenExt,rTool.bottom-rTool.top,lenExt,cy,wnd,0,hINSTANCE,nil);
  SendMessage(wndExt,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
  if topt>0 then
  with item do
    RtlZeroMemory(addr(item),sizeof(TC_ITEM));
    mask:=TCIF_TEXT;
    lstrcpy(s,"."); lstrcat(s,envEXTM); pszText:=addr(s); SendMessage(wndExt,TCM_INSERTITEM,0,cardinal(addr(item)));
    lstrcpy(s,"."); lstrcat(s,envEXTD); pszText:=addr(s); SendMessage(wndExt,TCM_INSERTITEM,1,cardinal(addr(item)));
    SendMessage(wndExt,TCM_SETCURSEL,txtn[tekt],0);
  end end;
end envCreateTitle;

//---------------- ���������� �������� -------------------

procedure envDestroyTitle();
var i:integer;
begin
  DestroyWindow(wndTabs);
  DestroyWindow(wndExt)
end envDestroyTitle;

//===============================================
//                  �������
//===============================================

//------------ ������� ������� ----------------

procedure envFragCEP(str:pstr; var pos:integer; var f:recFrag);
var s:string[maxText]; c:char;
begin
with f do
  s[0]:=char(0);
  cla:=fCEP;
  c:=str[pos];
  lstrcatc(s,str[pos]);
  inc(pos);
  while (lstrlen(s)<maxText)and(str[pos]<>char(0))and(str[pos]<>c) do
    lstrcatc(s,str[pos]);
    inc(pos);
  end;
  if str[pos]=c then
    lstrcatc(s,str[pos]);
    inc(pos);
  end;
  txt:=memAlloc(lstrlen(s)+1);
  lstrcpy(txt,s);
end
end envFragCEP;

//--------- �������� ������� �������������� ---------------

procedure envId(c:char):boolean;
begin
  return 
    (byte(c)>=byte('A'))and(byte(c)<=byte('Z'))or
    (byte(c)>=byte('a'))and(byte(c)<=byte('z'))or
    (byte(c)>=byte('�'))and(byte(c)<=byte('�'))or
    (byte(c)>=byte('�'))and(byte(c)<=byte('�'))or
    (byte(c)>=byte('0'))and(byte(c)<=byte('9'))or
    (c='_')or(c='$')or(c='@')
end envId;

//--------- �������� ������� ����� ---------------

procedure envNum(c:char; bitHex:boolean):boolean;
begin
  return 
    (byte(c)>=byte('0'))and(byte(c)<=byte('9'))or
    bitHex and(
    (byte(c)>=byte('A'))and(byte(c)<=byte('F'))or
    (byte(c)>=byte('a'))and(byte(c)<=byte('f')))
end envNum;

//--------- ������� �������������� ------------

procedure envFragID(str:pstr; var pos:integer; var f:recFrag);
var s:string[maxText]; rez:classREZ; comm:classCommand; reg:classRegister;
begin
with f do
  s[0]:=char(0);
  cla:=fID;

  while (lstrlen(s)<maxText)and envId(str[pos]) do
    lstrcatc(s,str[pos]);
    inc(pos);
  end;

//����������������� �������������
  rv:=rezNULL;
  for rez:=loREZ to hiREZ do
    if rv=rezNULL then
      if lstrcmp(nameREZ[carSet][rez],s)=0 then
        rv:=rez
  end end end;
  if rv<>rezNULL then
    cla:=fREZ
  end;

//������� ����������
  if cla=fID then
    av:=cNULL;
    for comm:=loCom to hiCom do
      if av=cNULL then
        if lstrcmp(asmCommands[comm].cNam,s)=0 then
          av:=comm
    end end end;

    if av<>cNULL then
      cla:=fASM
    end
  end;

//������� ����������
  if cla=fID then
    mv:=regNULL;
    for reg:=rEAX to rST7 do
      if mv=regNULL then
        if lstrcmp(asmRegs[reg].rNa,s)=0 then
          mv:=reg
    end end end;
    if mv<>regNULL then
      cla:=fREG
    end
  end;

//�����
  txt:=memAlloc(lstrlen(s)+1);
  lstrcpy(txt,s);
end
end envFragID;

//--------- ������� ����������� ---------------

procedure envFragPARSE(str:pstr; var pos:integer; var f:recFrag);
var p:classPARSE; s:string[maxText];
begin
with f do
  cla:=fNULL;
  txt:=nil;
  pv:=pNULL;
  for p:=loPARSE to hiPARSE do
    if (lstrlen(namePARSE[p])=1)and(namePARSE[p][0]=str[pos])or
       (lstrlen(namePARSE[p])=2)and(namePARSE[p][0]=str[pos])and(namePARSE[p][1]=str[pos+1]) then
      pv:=p;
  end end;
  if pv<>pNULL then
    cla:=fPARSE;
  end;
  if pv=pNULL then
    cla:=fNULL;
    txt:=memAlloc(2);
    txt[0]:=str[pos];
    txt[1]:=char(0);
    inc(pos)
  else if lstrlen(namePARSE[pv])=2 then inc(pos,2) else inc(pos) end
  end;
//�����������
  if pv=pDivDiv then
    cla:=fCOMM;
    lstrcpy(s,"//");
    lstrcat(s,addr(str[pos]));
    pos:=lstrlen(str);
    txt:=memAlloc(lstrlen(s)+1);
    lstrcpy(txt,s);
  end
end
end envFragPARSE;

//------------ ������� ����� ------------------

procedure envFragNUM(str:pstr; var pos:integer; var f:recFrag);
var s:string[maxText]; i,j:integer; bit:boolean; expo:real;
begin
with f do
  s[0]:=char(0);
  cla:=fINT;
  iv:=0;
//�����������������
  if (str[pos]='0')and((str[pos+1]='x')or(str[pos+1]='X')) then
    lstrcatc(s,str[pos]);
    lstrcatc(s,str[pos+1]);
    inc(pos,2);
    while envNum(str[pos],true) do
      case str[pos] of
        '0'..'9':iv:=iv*16+(integer(str[pos])-integer('0'));|
        'A','a' :iv:=iv*16+10;|
        'B','b' :iv:=iv*16+11;|
        'C','c' :iv:=iv*16+12;|
        'D','d' :iv:=iv*16+13;|
        'E','e' :iv:=iv*16+14;|
        'F','f' :iv:=iv*16+15;|
      end;
      lstrcatc(s,str[pos]);
      inc(pos)
    end
//����������
  else
    while envNum(str[pos],false) do
      iv:=iv*10+(integer(str[pos])-integer('0'));
      lstrcatc(s,str[pos]);
      inc(pos)
    end;
//������� �����
    if (str[pos]='.')and envNum(str[pos+1],false) then
      cla:=fREAL;
      fv:=real(iv);
      lstrcatc(s,str[pos]);
      inc(pos);
      expo:=1e-1;
      while envNum(str[pos],false) do
        fv:=fv+real(integer(str[pos])-integer('0'))*expo;
        expo:=expo/10.0;
        lstrcatc(s,str[pos]);
        inc(pos)
      end
    end;
//������� ��� �����
    if ((str[pos]='e')or(str[pos]='E'))and envNum(str[pos+1],false) then
      if cla=fINT then
        cla:=fREAL;
        fv:=real(iv);
      end;
      lstrcatc(s,str[pos]);
      inc(pos);
      i:=0;
      while (i*10+(integer(str[pos])-integer('0'))<308)and envNum(str[pos],false) do
        i:=i*10+(integer(str[pos])-integer('0'));
        lstrcatc(s,str[pos]);
        inc(pos)
      end;
      for j:=1 to i do
        fv:=fv*10.0;
      end
//������� �� ������
    elsif ((str[pos]='e')or(str[pos]='E'))and((str[pos+1]='+')or(str[pos+1]='-'))and envNum(str[pos+2],false) then
      if cla=fINT then
        cla:=fREAL;
        fv:=real(iv);
      end;
      bit:=str[pos+1]='-';
      lstrcatc(s,str[pos]);
      lstrcatc(s,str[pos+1]);
      inc(pos,2);
      i:=0;
      while (i*10+(integer(str[pos])-integer('0'))<308)and envNum(str[pos],false) do
        i:=i*10+(integer(str[pos])-integer('0'));
        lstrcatc(s,str[pos]);
        inc(pos)
      end;
      for j:=1 to i do
        if bit
          then fv:=fv/10.0
          else fv:=fv*10.0
      end end
    end
  end;
//������� �����
  if (cla=fINT)and(str[pos]='L') then
    lstrcatc(s,str[pos]);
    inc(pos)
  end;

  txt:=memAlloc(lstrlen(s)+1);
  lstrcpy(txt,s);
end
end envFragNUM;

//---------- ������� ��������� ----------------

procedure envNextFrag(str:pstr; var pos:integer; var f:recFrag);
var s:string[maxText];
begin
with f do
  cla:=fNULL;
  pv:=pNULL;
//������� ��������
  tab:=0;
  while str[pos] in [' ','\9','\11'] do
    inc(tab);
    inc(pos);
  end;
//��������
  case str[pos] of
    '"','\39':envFragCEP(str,pos,f);|
    '0'..'9':envFragNUM(str,pos,f);|
    'A'..'Z','a'..'z','�'..'�','�'..'�','_','$','@':envFragID(str,pos,f);|
    '\0':cla:=fCOMM; txt:=nil;|
  else envFragPARSE(str,pos,f)
  end;
  case cla of
    fREZ:len:=tab+lstrlen(nameREZ[carSet][rv]);|
    fPARSE:len:=tab+lstrlen(namePARSE[pv]);|
  else len:=tab+lstrlen(txt);
  end;
  if (cla=fPARSE)and(pv in [pDivMul,pMulDiv]) then
    cla:=fCOMM;
  end;
end
end envNextFrag;

//------------ ������ ������ ------------------

procedure envToFrag(str:pstr; f:pFrags);
var pos:integer;
begin
with f^ do
  pos:=0;
  topf:=0;
  while (str[pos]<>char(0))and(topf<maxFrag) do
    inc(topf);
    arrf[topf]:=memAlloc(sizeof(recFrag));
    envNextFrag(str,pos,arrf[topf]^);
  end;
//������ ������
  if topf=0 then
    inc(topf);
    arrf[topf]:=memAlloc(sizeof(recFrag));
    with arrf[topf]^ do
      cla:=fCOMM;
      tab:=0;
      txt:=nil
    end
  end
end
end envToFrag;

//---------- ��������� � ������ ---------------

procedure envFromFrag(str:pstr; f:pFrags);
var i,j:integer;
begin
with f^ do
  str[0]:='\0';
  for i:=1 to topf do
  with arrf[i]^ do
    beg:=lstrlen(str);
    for j:=1 to tab do
      lstrcatc(str,' ');
    end;
    case cla of
      fNULL:lstrcat(str,txt);|
      fINT:lstrcat(str,txt);|
      fREAL:lstrcat(str,txt);|
      fCEP:lstrcat(str,txt);|
      fPARSE:lstrcat(str,namePARSE[pv]);|
      fREZ:lstrcat(str,nameREZ[carSet][rv]);|
      fASM:lstrcat(str,asmCommands[av].cNam);|
      fREG:lstrcat(str,asmRegs[mv].rNa);|
      fID:lstrcat(str,txt);|
      fCOMM:if pv in [pDivMul,pMulDiv] then lstrcat(str,namePARSE[pv]) else lstrcat(str,txt) end;|
    end;
    len:=lstrlen(str)-beg;
  end end
end
end envFromFrag;

//------------ �������� ����� -----------------

procedure envcati(s:pstr; l:integer; bitHex:boolean);
var val:string[maxText];
begin
  wvsprintf(val,"%li",addr(l));
  lstrcat(s,val);
  if bitHex then
    lstrcatc(s,'(');
    wvsprintf(val,"%#lx",addr(l));
    lstrcat(s,val);
    lstrcatc(s,')');
  end;
end envcati;

//------- ������������� � ������ --------------

procedure envIdToStr(id:pID; val:pstr; bitStr:boolean);
var val2,val3:string[maxText]; i,:integer;
begin
with id^ do
  case idClass of
    idcCHAR,idcINT,idcSCAL,idcREAL:
      lstrcpy(val,_���������_[envER]);
      case idClass of
        idcCHAR:lstrcat(val,nameTYPE[traLANG][typeCHAR]);|
        idcINT:lstrcat(val,nameTYPE[traLANG][typeINT]);|
        idcSCAL:lstrcat(val,idScalType^.idName);|
        idcREAL:lstrcat(val,nameTYPE[traLANG][typeREAL]);|
        idcSTR:lstrcat(val,nameTYPE[traLANG][typePSTR]);|
      end;
      lstrcatc(val,'=');
      case idClass of
        idcCHAR:lstrcatc(val,'"'); lstrcatc(val,char(idInt)); lstrcatc(val,'"');|
        idcINT:envcati(val,idInt,true);|
        idcSCAL:envcati(val,idScalVal,false);|
        idcREAL:wvsprintr(idReal,5,val2); lstrcat(val,val2);|
        idcSTR:lstrcatc(val,'"'); lstrcat(val,idStr); lstrcatc(val,'"');|
      end;|
    idtBAS:
      lstrcpy(val,_�������_���_[envER]);
      lstrcat(val,nameTYPE[traLANG][idBasNom]);|
    idtARR:
      lstrcpy(val,_������_[envER]);
      envcati(val,extArrBeg,false);
      lstrcat(val,"..");
      envcati(val,extArrEnd,false);
      lstrcat(val,"]of ");
      lstrcat(val,idArrItem^.idName);|
    idtREC:
      lstrcpy(val,"record");
      for i:=1 to idRecMax do
        if bitStr then lstrcatc(val,' ') else lstrcat(val,"\13\10     ") end;
        if (idRecList^[i]^.idName[0]<>'#') then //mbS(idRecList^[i]^.idName);
          lstrcpy(val3,idRecList^[i]^.idName);
          if lstrposc('.',val3)>0 then
            lstrdel(val3,0,lstrposc('.',val3)+1)
          end;
          lstrcat(val,val3);
          if bitStr then lstrcatc(val,':') else lstrcat(val,"\9:") end;
        end;
        lstrcat(val,idRecList^[i]^.idVarType^.idName);
        lstrcatc(val,';');
      end;
      if bitStr then lstrcat(val," end") else lstrcat(val,"\13\10end") end;|
    idtPOI:val[0]:='\0';
      lstrcpy(val,_���������_��_[envER]);
      if idPoiBitForward
        then lstrcat(val,idPoiPred)
        else lstrcat(val,idPoiType^.idName)
      end;|
    idtSCAL:lstrcpy(val,_���_������������[envER]);|
    idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR:
      case idClass of
        idvFIELD:lstrcpy(val,_����_������[envER]);|
        idvPAR:lstrcpy(val,_��������_���������[envER]);|
        idvVAR:lstrcpy(val,_����������[envER]);|
        idvLOC:lstrcpy(val,_����������_���������[envER]);|
        idvVPAR:lstrcpy(val,_��������_���������__VAR_[envER]);|
      end;
      lstrcatc(val,':');
      lstrcat(val,idVarType^.idName);|
    idPROC:
      lstrcpy(val,idName);
      lstrcatc(val,'(');
      for i:=1 to idProcMax do
        if bitStr then lstrcatc(val,' ') else lstrcat(val,"\13\10      ") end;
        with idProcList^[i]^ do
          if idClass=idvVPAR then
            lstrcat(val,"var ");
          end;
          if (idName[0]<>char(0))and(idName[0]<>'#') then
            lstrcat(val,idName);
            if bitStr then lstrcatc(val,':') else lstrcat(val,"\9:") end;
          end;
          lstrcat(val,idVarType^.idName);
        end;
        if i<idProcMax then
          with idProcList^[i]^ do
          if (idName[0]<>char(0))and(idName[0]<>'#')
            then lstrcat(val,"; ")
            else lstrcat(val,", ")
          end end
        end
      end;
      if idProcMax>0 then
        if bitStr then lstrcatc(val,' ') else lstrcat(val,"\13\10") end
      end;
      lstrcatc(val,')');
      if idProcType<>nil then
        lstrcatc(val,':');
        lstrcat(val,idProcType^.idName);
      end;|
    idMODULE:lstrcpy(val,_���_������[envER]);|
    idREZ:lstrcpy(val,_�����������������_�������������[envER]);|
  end
end
end envIdToStr;

//===============================================
//              ������ �� ��������
//===============================================

//----------- �������� ������ -----------------

procedure envCreateFont(f:classFrag; cDC:HDC; bitPrint:boolean);
var fontX,fontY,cWeight:integer; cABC:ABC; c:char; oldF:HFONT;
begin
  with stFont[f] do
    if fBold
      then cWeight:=FW_BOLD
      else cWeight:=FW_NORMAL
    end;
    case bitPrint of
      false:fontY:=hiword(GetDialogBaseUnits()) * fSize div 10;|
      true :fontY:=integer(integer(GetDeviceCaps(cDC,VERTRES))* integer(fSize)/50/12);|
    end;
    if fontY=0 then fontY:=1 end;
    fontX:=0;
    foID:=CreateFont(fontY,fontX,0,0,cWeight,byte(fItal),0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,addr(fFace));
    if foID=0 then mbS(_���������_������_����������_��������_�����[envER]) end;
    sysSelectObject(cDC,foID,oldF);
    fY:=fontY;
    for c:=char(0) to char(255) do
      GetCharABCWidths(cDC,word(c),word(c),cABC);
      fABC[c]:=cABC.abcA+cABC.abcB+cABC.abcC;
    end;
    SelectObject(cDC,oldF);
  end;
end envCreateFont;

//----------- �������� ������� ----------------

procedure envCreateFonts(cDC:HDC; bitPrint:boolean);
var f:classFrag;
begin
  for f:=fNULL to fCOMM do
    envCreateFont(f,cDC,bitPrint)
  end;
end envCreateFonts;

//----------- �������� ������� ----------------

procedure envDestroyFonts();
var f:classFrag;
begin
  for f:=fNULL to fCOMM do
    DeleteObject(stFont[f].foID);
  end
end envDestroyFonts;

//===============================================
//                 ������� ������
//===============================================

//------------- ������ ������ -----------------

procedure envHeight(txt,nom:integer):integer;
var i,hRes:integer;
begin
with txts[txtn[txt]][txt].txtStrs^.arrs[nom]^ do
  hRes:=0;
  for i:=1 to topf do
  with arrf[i]^ do
    if stFont[cla].fY>hRes then
      hRes:=stFont[cla].fY;
  end end end;
  return hRes
end
end envHeight;

//------------- ������ ������ -----------------

procedure envWeight(txt,nom,fin:integer; trackChar:char):integer;
var i,j,hRes,hOtr,wOtr:integer; s:string[maxText];
begin
with txts[txtn[txt]][txt].txtStrs^.arrs[nom]^ do
  envFromFrag(s,txts[txtn[txt]][txt].txtStrs^.arrs[nom]);
  hRes:=0;
  for i:=0 to fin do
//����� �������
    hOtr:=0;
    for j:=1 to topf do with arrf[j]^ do
    if (i>=beg)and(i<=beg+len-1) then
      hOtr:=j
    end end end;
//������ �������
    if hOtr=0
      then with arrf[topf]^ do inc(hRes,stFont[fID].fABC[trackChar]) end
      else with arrf[hOtr]^ do inc(hRes,stFont[cla].fABC[s[i]]) end
    end
  end;
  if trackChar<>'\0' then
  with txts[txtn[txt]][txt] do
    dec(hRes,envWeight(txt,txtTrackY+1,txtTrackX-1,'\0'))
  end end;
  return hRes
end
end envWeight;

//----------- �������� ������ -----------------

procedure envTrack(txt:integer):integer;
begin
  with txts[txtn[txt]][txt] do
    return envWeight(txt,txtTrackY+1,txtTrackX-1,'\0')
  end
end envTrack;

//--------------- ������� ���� ----------------

procedure txtWndX():integer;
var r:RECT;
begin
  GetClientRect(editWnd,r);
  return r.right-r.left
end txtWndX;

procedure txtWndY():integer;
var r:RECT;
begin
  GetClientRect(editWnd,r);
  return r.bottom-r.top
end txtWndY;

//-------- ���������� ������-������ -----------

procedure envSetStatus(txt:integer);
var s:string[maxText]; i:integer; sta:classStatus; gms:MEMORYSTATUS; id:pID; buf:pstr;
begin
if topt=0 then
  for sta:=staMod to staIdent do
    SendMessage(wndStatus,SB_SETTEXT,ord(sta),0)
  end
else with txts[txtn[txt]][txt] do
//staMod
  if txtMod
    then SendMessage(wndStatus,SB_SETTEXT,ord(staMod),cardinal(_�������[envER]))
    else SendMessage(wndStatus,SB_SETTEXT,ord(staMod),0)
  end;
//staStr
  i:=txtTrackY+txtCarY; wvsprintf(s, _������__li[envER],addr(i));
  SendMessage(wndStatus,SB_SETTEXT,ord(staStr),cardinal(addr(s)));
//staSto
  i:=txtTrackX+txtCarX; wvsprintf(s,__�������__li[envER],addr(i));
  SendMessage(wndStatus,SB_SETTEXT,ord(staSto),cardinal(addr(s)));
//staDeb
  if stepDebugged
    then SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_�������[envER]))
    else SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(""))
  end;
//staIdent
  envGetIdent(envIdName,tekt,txtTrackX+txtCarX,txtTrackY+txtCarY);
  if (topMod>=tekt)and(tbMod[tekt].modTab<>nil) then
    if (envIdName[0]<>'\0')and(lstrcmpi(envIdName,lastIdName)<>0) then
      id:=idFindGlo(envIdName,false);
      if id<>nil then
        lstrcpy(lastIdName,envIdName);
        buf:=memAlloc(5000);
        envIdToStr(id,buf,true);
        SendMessage(wndStatus,SB_SETTEXT,ord(staIdent),cardinal(buf));
        memFree(buf);
      end
    end
  end;
//staMax
//  i:=txtStrs^.tops; wvsprintf(s,__�����__li[envER],addr(i));
//  SendMessage(wndStatus,SB_SETTEXT,cardinal(staMax),cardinal(addr(s)));
//staMem
//  GlobalMemoryStatus(gms);
//  i:=gms.dwAvailPageFile div 1024; wvsprintf(s,__������__li_�[envER],addr(i));
//  SendMessage(wndStatus,SB_SETTEXT,cardinal(staMem),cardinal(addr(s)));
end end
end envSetStatus;

//----------- ��������� ������� ---------------

procedure envSetCaret(txt:integer);
var i,cX,cY:integer;
begin
if topt>0 then
with txts[txtn[txt]][txt] do
  cY:=0;
  cX:=0;
  if txtStrs<>nil then if txtStrs^.tops>0 then
    for i:=1 to txtCarY do
      inc(cY,envHeight(txt,txtTrackY+i))
    end;
    dec(cY,GetSystemMetrics(SM_CYCAPTION));
    inc(cX,envWeight(txt,txtTrackY+txtCarY,txtTrackX+txtCarX-2,' '))
  end end;
  SetCaretPos(cX,cY);
  envSetStatus(txt)
end end
end envSetCaret;

//----------- ��������� �������� ----------------

procedure envScrSet(txt:integer);
begin
if txt>0 then
with txts[txtn[txt]][txt] do
if txtStrs<>nil then
  SetScrollRange(editWnd,SB_VERT,0,txtStrs^.tops-1,true);
  SetScrollPos(editWnd,SB_VERT,txtTrackY,true);
  SetScrollRange(editWnd,SB_HORZ,0,200,true);
  SetScrollPos(editWnd,SB_HORZ,txtTrackX,true);
end end end
end envScrSet;

//------------ ���������� ���� ----------------

procedure envUpdate(Wnd:HWND);
begin
  InvalidateRect(Wnd,nil,true);
  UpdateWindow(Wnd)
end envUpdate;

//------------- ������������ ------------------

procedure envInitial(var txt:recTxt; col,nom:integer; path,name:pstr);
begin
with txt do
  lstrcpy(txtFile,path);
  lstrcpy(txtTitle,name);
  txtStrs:=memAlloc(sizeof(listStr));
  txtStrs^.tops:=0;

  txtTrackX:=0;
  txtTrackY:=nom-1;
  txtCarX:=col;
  txtCarY:=1;
  txtMod:=false;
  txtLoad:=false;

  blkSet:=false;
  blkX:=1;
  blkY:=1;
end
end envInitial;

//----------- ���������� ������ ---------------

procedure envDestroyFrags(f:pFrags);
var j:integer;
begin
with f^ do
  for j:=1 to topf do with arrf[j]^ do
    if txt<>nil then
      memFree(txt)
  end end end
end
end envDestroyFrags;

//--------------- ���������� ------------------

procedure envDestroy(txt:integer);
var i,j:integer;
begin
with txts[txtn[txt]][txt],txtStrs^ do
if txtStrs<>nil then
  for i:=1 to tops do
    envDestroyFrags(arrs[i]);
    memFree(arrs[i])
  end;
  memFree(txtStrs);
end end
end envDestroy;

procedure envDestroys();
var i:integer;
begin
  for i:=1 to topt do
    envDestroy(i)
  end
end envDestroys;

//=======================================
//                    �����
//=======================================

//--------- ������ ��������� ������ -----------

procedure envFragW(txt:integer; s:pstr; beg,len:integer; otrFont:classFrag):integer;
var i,j:integer;
begin
with stFont[otrFont] do
  j:=0;
  for i:=beg to beg+len-1 do
    inc(j,fABC[s[i]]);
  end;
  return j
end
end envFragW;

//----- ����������� ��������� ������ ----------

procedure envViewFrag(txt:integer; dc:HDC; s:pstr; beg,len:integer; bitBlk:boolean;
                      var track:integer; r:RECT; otrFont:classFrag;
                      bitEnd:boolean);
begin
if (len>0)or(s=nil) then
  SetTextColor(dc,stFont[otrFont].fCol);
  if bitBlk
    then SetBkColor(dc,envEDITSEL)
    else SetBkColor(dc,envEDITBK)
  end;
  with r do
    inc(r.left,track);
    if not bitEnd and(r.left+envFragW(txt,s,beg,len,otrFont)<r.right) then
      r.right:=r.left+envFragW(txt,s,beg,len,otrFont)
    end
  end;
  ExtTextOut(dc,r.left,r.top,ETO_CLIPPED or ETO_OPAQUE,addr(r),addr(s[beg]),len,nil);
  inc(track,envFragW(txt,s,beg,len,otrFont))
end
end envViewFrag;

//------ ����������� ������ ������� -----------

procedure envStatusOtr(txt,vOtr,vStr:integer):classOtr;
var oBeg,oEnd:integer;
begin
with txts[txtn[txt]][txt],txtStrs^.arrs[vStr]^.arrf[vOtr]^ do
  oBeg:=beg+1;
  oEnd:=beg+len-1+1;
//{����� ���}
  if not blkSet then return oW
//{������������ ����}
  elsif blkBegY=blkEndY then
    if vStr=blkBegY then
      if oEnd<blkBegX then return oW //{������� �����}
      elsif oBeg>=blkEndX then return oW //{������� ������}
      elsif (oBeg>=blkBegX)and(oEnd<blkEndX) then return oB //{������� ������ �����}
      elsif (oBeg<blkBegX)and(oEnd>=blkEndX) then return oWBW //{���� ������ �������}
      elsif oBeg<blkBegX then return oWB //{������� �����-������}
      elsif oEnd>=blkEndX then return oBW //{������� ������-������}
      else mbS(_������_�_ediStatusOtr_������������_����[envER])
      end
    else return oW //{������ ��� �����}
    end
//{������������� ����}
  elsif vStr<blkBegY then return oW //{������ ���� �����}
  elsif vStr>blkEndY then return oW //{������ ���� �����}
  elsif (vStr>blkBegY)and(vStr<blkEndY) then return oB //{������ ������ �����}
//{������������� ����,������� �������}
  elsif vStr=blkBegY then
    if oEnd<blkBegX then return oW //{������� ����� �� �������}
    elsif oBeg>=blkBegX then return oB //{������� ������ �� �������}
    else return oWB //{������� �� �������}
    end
//{������������� ����,������ �������}
  elsif vStr=blkEndY then
    if oEnd<blkEndX-1 then return oB //{������� ����� �� �������}
    elsif oBeg>=blkEndX then return oW //{������� ������ �� �������}
    else return oBW //{������� �� �������}
    end
  else mbS(_������_�_envStatusOtr_�������������_����[envER])
  end
end
end envStatusOtr;

//------ ����������� ������ ������� -----------

procedure envViewTxt(t:integer; str:pstr; vDC:HDC; vOtr,vStr:integer;
                     vCarX,vCarY,vHeight:integer; vBuf:pstr);
var i,j,vCX,length:integer; vRect,r:RECT; s:pstr; st:classOtr;
begin
with txts[txtn[t]][t],txtStrs^.arrs[vStr]^.arrf[vOtr]^ do
//{����������� ����� �������}
  vCX:=0;
  for i:=beg to beg+len-1 do
    inc(vCX,stFont[cla].fABC[str[i]]);
  end;
//{����� ������}
  with vRect do
    left:=vCarX+1;
    top:=vCarY+1;
    right:=left+vCX;
    bottom:=top+vHeight;
  end;
  s:=addr(str[beg]);
  st:=envStatusOtr(t,vOtr,vStr);
  length:=0;
  case st of
    oW:envViewFrag(t,vDC,s,0,len,false,length,vRect,cla,false);|
    oB:envViewFrag(t,vDC,s,0,len,true,length,vRect,cla,false);|
    oWB:
      i:=blkBegX-beg-1;
      envViewFrag(t,vDC,s,0,i,false,length,vRect,cla,false);
      envViewFrag(t,vDC,s,i,len-i,true,length,vRect,cla,true);|
    oBW:
      i:=blkEndX-beg-1;
      envViewFrag(t,vDC,s,0,i,true,length,vRect,cla,false);
      envViewFrag(t,vDC,s,i,len-i,false,length,vRect,cla,true);|
    oWBW:
      i:=blkBegX-beg-1;
      j:=blkEndX-1-beg-i;
      envViewFrag(t,vDC,s,0,i,false,length,vRect,cla,false);
      envViewFrag(t,vDC,s,i,j,true,length,vRect,cla,false);
      envViewFrag(t,vDC,s,i+j,len-(i+j),false,length,vRect,cla,true);|
  end
end
end envViewTxt;

//---------- ����������� ������� --------------

procedure envViewOtr(t:integer; str:pstr; vDC:HDC; vOtr,vStr:integer;
                    vCarX,vCarY,vHeight:integer):integer;
var i,vCX,begX,begY,endX,endY:integer; vBuf:string[maxText]; oldF:HANDLE; bitGr:boolean;
begin
with txts[txtn[t]][t],txtStrs^.arrs[vStr]^.arrf[vOtr]^ do
//{������������ ������}
  lstrcpy(vBuf,str);
  lstrdel(vBuf,0,beg);
  vBuf[len]:=char(0);
//{������������� ������}
  sysSelectObject(vDC,stFont[cla].foID,oldF);
//{����������� ����� �������}
  vCX:=0;
  for i:=beg to beg+len-1 do
    inc(vCX,stFont[cla].fABC[str[i]])
  end;
//{����� ������}
  envViewTxt(t,str,vDC,vOtr,vStr,vCarX,vCarY,vHeight,vBuf);
//{������������ ������}
  SelectObject(vDC,oldF);
//{���������}
  return vCX
end
end envViewOtr;

//---------- ����������� ������ ---------------

procedure envViewStr(txt:integer; vNom:integer; vDC:HDC; var vCarX,vCarY:integer);
var j,vHeight,track:integer; str:string[maxText]; vRect:RECT;
begin
with txts[txtn[txt]][txt] do
  envFromFrag(str,txtStrs^.arrs[vNom]);
  vHeight:=envHeight(txt,vNom);
  envBlockBound(txt);
//{���� �� ��������}
  with txtStrs^.arrs[vNom]^ do
  for j:=1 to topf do
    inc(vCarX,envViewOtr(txt,str,vDC,j,vNom,vCarX,vCarY,vHeight))
  end end;
//{����� ������}
  with vRect do
    left:=vCarX+1;
    top:=vCarY+1;
    right:=txtWndX();
    bottom:=top+vHeight;
  end;
  track:=0;
  envViewFrag(txt,vDC,nil,0,0,false,track,vRect,fID,true);
//{����������}
  inc(vCarY,vHeight);
end
end envViewStr;

//---------- ����������� ������ ---------------

procedure envView(txt:integer; vDC:HDC);
var vCarY,vCarX,vHeight,track,i,j:integer; r:RECT;
begin
with txts[txtn[txt]][txt] do
  HideCaret(editWnd);
  GetClientRect(editWnd,r);
  vCarY:=-1;
  i:=txtTrackY+1;
  while (vCarY<r.bottom)and(txtStrs<>nil)and(i<=txtStrs^.tops) do
//{���������� ������ i}
    vCarX:=-envTrack(txt)-1;
    envViewStr(txt,i,vDC,vCarX,vCarY);
    inc(i)
  end;
//{������ ������}
  with r do
    top:=vCarY+1;
  end;
  track:=0;
  envViewFrag(txt,vDC,nil,0,0,false,track,r,fID,true);

  ShowCaret(editWnd)
end
end envView;

//===============================================
//               ��������� �������
//===============================================

//------------- ������ ����� ------------------

procedure envEvalKeyUp(txt:integer);
begin
with txts[txtn[txt]][txt] do
  if txtTrackY+txtCarY>1 then
    if txtCarY>1 then dec(txtCarY)
    else
      dec(txtTrackY);
      envScrSet(txt);
      envUpdate(editWnd)
    end
  end
end
end envEvalKeyUp;

//------------- ������ ���� -------------------

procedure envEvalKeyDown(txt:integer; bitUpd:boolean);
var i,j:integer;
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtTrackY+txtCarY<tops then
    j:=0;
    for i:=txtTrackY+1 to txtTrackY+txtCarY do
      inc(j,envHeight(txt,i))
    end;
    if j<=txtWndY() then inc(txtCarY)
    else
      inc(txtTrackY);
      envScrSet(txt);
      if bitUpd then
        envUpdate(editWnd)
      end
    end
  end
end
end envEvalKeyDown;

//------------- ������ ����� ------------------

procedure envEvalKeyLeft(txt:integer);
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtTrackX+txtCarX>1 then
    if envWeight(txt,txtTrackY+txtCarY,txtTrackX+txtCarX-2,' ')>1 then dec(txtCarX)
    else
      dec(txtTrackX,ediTrackX);
      inc(txtCarX,ediTrackX-1);
      if txtTrackX<0 then
        txtTrackX:=0
      end;
      envScrSet(txt);
      envUpdate(editWnd)
    end
  end
end
end envEvalKeyLeft;

//------------- ������ ������ -----------------

procedure envEvalKeyRight(txt:integer; bitUpd:boolean);
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtTrackX+txtCarX<maxText then
    if envWeight(txt,txtTrackY+txtCarY,txtTrackX+txtCarX+1,' ')<txtWndX() then inc(txtCarX)
    else
      inc(txtTrackX,ediTrackX);
      dec(txtCarX,ediTrackX-1);
      if bitUpd then
        envScrSet(txt);
        envUpdate(editWnd)
      end
    end
  end
end
end envEvalKeyRight;

//------------ �������� ����� -----------------

procedure envEvalScrollUp(txt:integer; bitPage,bitScroll:boolean);
var track:integer;
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtTrackY+txtCarY>1 then
    if bitPage
      then track:=(txtWndY() div stFont[fID].fY)-1
      else track:=1
    end;
    dec(txtTrackY,track);
    if txtTrackY<0 then
      dec(txtCarY,-txtTrackY);
      if txtCarY<1 then
        txtCarY:=1
      end;
      txtTrackY:=0;
    end;
    if bitScroll then
      blkSet:=false
    end;
    envScrSet(txt);
    envUpdate(editWnd)
  end
end
end envEvalScrollUp;

//------------ �������� ���� ------------------

procedure envEvalScrollDown(txt:integer; bitPage,bitScroll:boolean);
var track:integer;
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtTrackY+txtCarY<tops then
    if bitPage
      then track:=(txtWndY() div stFont[fID].fY)-1
      else track:=1
    end;
    inc(txtTrackY,track);
    if txtTrackY>tops-1 then
      txtTrackY:=tops-1;
      txtCarY:=1
    elsif txtTrackY+txtCarY>tops then
      txtCarY:=tops-txtTrackY;
    end;
    if bitScroll then
      blkSet:=false;
    end;
    envScrSet(txt);
    envUpdate(editWnd)
  end
end
end envEvalScrollDown;

//---------- ��������� ������� Y --------------

procedure envEvalPosY(txt:integer; newPos:cardinal);
begin
with txts[txtn[txt]][txt],txtStrs^ do
  txtTrackY:=newPos;
  if txtTrackY+txtCarY>tops then
    txtCarY:=tops-txtTrackY
  end;
  blkSet:=false;
  envScrSet(txt);
  envUpdate(editWnd)
end
end envEvalPosY;

//------------ �������� ����� -----------------

procedure envEvalScrollLeft(txt:integer; bitPage:boolean);
var track:integer;
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtTrackX>0 then
    if bitPage
      then track:=ediTrackX
      else track:=1
    end;
    dec(txtTrackX,track);
    if txtTrackX<0 then
      txtTrackX:=0
    end;
    envScrSet(txt);
    envUpdate(editWnd)
  end
end
end envEvalScrollLeft;

//------------ �������� ������ ----------------

procedure envEvalScrollRight(txt:integer; bitPage:boolean);
var track:integer;
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtTrackX<envTRACKMAX then
    if bitPage
      then track:=ediTrackX
      else track:=1
    end;
    inc(txtTrackX,track);
    if txtTrackX>envTRACKMAX then
      txtTrackX:=envTRACKMAX
    end;
    envScrSet(txt);
    envUpdate(editWnd)
  end
end
end envEvalScrollRight;

//---------- ��������� ������� X --------------

procedure envEvalPosX(txt,newPos:integer);
begin
with txts[txtn[txt]][txt],txtStrs^ do
  txtTrackX:=newPos;
  envScrSet(txt);
  envUpdate(editWnd)
end
end envEvalPosX;

//------------- ������ ������ -----------------

procedure envEvalKeyHome(txt:integer; bitUpd:boolean);
var b:boolean;
begin
with txts[txtn[txt]][txt],txtStrs^ do
  if txtCarX>1 then
    b:=txtTrackX<>0;
    txtCarX:=1;
    txtTrackX:=0;
    envScrSet(txt);
    if bitUpd and b then
      envUpdate(editWnd)
    end
  end
end
end envEvalKeyHome;

//-------------- ����� ������ -----------------

procedure envEvalKeyEnd(txt:integer);
var bitUpd:boolean; s:string[maxText];
begin
with txts[txtn[txt]][txt],txtStrs^ do
  bitUpd:=false;
  envFromFrag(s,arrs[txtTrackY+txtCarY]);
  if txtCarX<lstrlen(s)+2 then
    txtCarX:=lstrlen(s)+1-txtTrackX;
    while envWeight(txt,txtTrackY+txtCarY,lstrlen(s)-1,'0')>txtWndX() do
      inc(txtTrackX,ediTrackX);
      dec(txtCarX,ediTrackX);
      bitUpd:=true
    end;
  else
    txtCarX:=lstrlen(s)+1-txtTrackX;
    while envWeight(txt,txtTrackY+txtCarY,lstrlen(s)-1,'0')<0 do
      dec(txtTrackX,ediTrackX);
      inc(txtCarX,ediTrackX);
      bitUpd:=true
    end;
  end;
  if bitUpd then
    envScrSet(txt);
    envUpdate(editWnd)
  end;
end
end envEvalKeyEnd;

//------------- ����� ���� -------------

procedure envMouseWheel(txt:integer; wParam:cardinal);
var i,trackWheel:integer;
begin
  trackWheel:=integer(wParam) div 0x10000 div WHEEL_DELTA;
  if trackWheel>0
    then for i:=1 to trackWheel do envEvalScrollUp(txt,false,true) end
    else for i:=trackWheel downto -1 do envEvalScrollDown(txt,false,true) end
  end
end envMouseWheel;

//------------ ���������� �������� --------------

procedure envAbs(i:integer):integer;
begin
  if i>=0 
    then return i
    else return -i
  end
end envAbs;

//------------ ��������� ������� --------------

procedure envSetCursor(txt:integer; x,y:integer; bitBlock:boolean);
var newX,newY,cy,oldcy,i:integer; s:string[maxText];
begin
with txts[txtn[txt]][txt],txtStrs^ do
  inc(x,stFont[fID].fABC['0'] div 2);
  dec(y,stFont[fID].fY div 2);
  cy:=0;
  oldcy:=0;
  for i:=txtTrackY+1 to tops do
  if cy-y<stFont[fID].fY then
    if envAbs(cy-y)<=envAbs(oldcy-y) then
      newY:=i;
    end;
    oldcy:=cy;
    inc(cy,envHeight(txt,i))
  end end;
  newX:=1;
  envFromFrag(s,arrs[newY]);
  for i:=1 to lstrlen(s) do
    if envAbs(envWeight(txt,newY,i-1,' ')-x)<=
       envAbs(envWeight(txt,newY,newX-1,' ')-x) then
      newX:=i;
    end
  end;
  if (s[0]<>char(0))and(envWeight(txt,newY,newX,' ')<x) then
    inc(newX);
  end;
  if not bitBlock then //��������� �������
    txtCarX:=newX-txtTrackX;
    txtCarY:=newY-txtTrackY;
    if blkSet then
      blkSet:=false;
      envUpdate(editWnd)
    end;
    envScrSet(txt);
  else //��������� �����
    blkX:=newX;
    blkY:=newY;
    blkSet:=true;
    envUpdate(editWnd)
  end
end
end envSetCursor;

//------------ ����� ������������ ���� ----------------

procedure envContextMenu(txt,lParam:integer);
var r:POINT; menu:HMENU;
begin
  r.x:=loword(lParam);
  r.y:=hiword(lParam);
  ClientToScreen(editWnd,r);
  menu:=GetSubMenu(GetMenu(mainWnd),1);
  TrackPopupMenu(menu,TPM_LEFTALIGN | TPM_LEFTBUTTON,r.x, r.y,0,mainWnd,nil);
end envContextMenu;

//------------ ������� ������� ----------------

procedure envSetPosition(txt:integer; x,y,len:integer);
var i:integer;
begin
with txts[txtn[txt]][txt],txtStrs^.arrs[y]^ do
  txtCarX:=x;
  txtTrackX:=0;
  txtCarY:=1+envTRACKUP;
  txtTrackY:=y-1-envTRACKUP;
  if txtTrackY<0 then
    txtCarY:=txtCarY+txtTrackY;
    txtTrackY:=0;
  end;
  while envWeight(txt,txtTrackY+txtCarY,x,' ')>txtWndX() do
    inc(txtTrackX,ediTrackX);
    dec(txtCarX,ediTrackX);
  end;
  blkX:=txtTrackX+txtCarX+len;
  blkY:=txtTrackY+txtCarY;
  blkSet:=true;
  envScrSet(txt);
end
end envSetPosition;

//----------- ������-����� ������ -------------

procedure envEditBegin(txt:integer);
begin
with txts[txtn[txt]][txt],txtStrs^ do
  txtTrackY:=0;
  txtCarY:=1;
  envScrSet(txt);
  envSetStatus(txt);
  envUpdate(editWnd)
end
end envEditBegin;

procedure envEditEnd(txt:integer);
begin
with txts[txtn[txt]][txt],txtStrs^ do
  txtTrackY:=tops-1;
  txtCarY:=1;
  envScrSet(txt);
  envSetStatus(txt);
  envUpdate(editWnd)
end
end envEditEnd;

//===============================================
//           �������-�������� ��������
//===============================================

//------------- ������� ������� ---------------

procedure envKeyChar(t:integer; insChar:char; bitUpd:boolean);
var insStr:string[maxText]; i:integer;
begin
with txts[txtn[t]][t],txtStrs^ do
  if txtTrackX+txtCarX<maxText then
    txtMod:=true;
    envFromFrag(insStr,arrs[txtTrackY+txtCarY]);
    while lstrlen(insStr)<txtTrackX+txtCarX-1 do
      lstrcatc(insStr,' ');
    end;
    if lstrlen(insStr)=txtTrackX+txtCarX-1 then
      insStr[lstrlen(insStr)+1]:=char(0);
      insStr[lstrlen(insStr)]:=insChar;
    else lstrinsc(insChar,insStr,txtTrackX+txtCarX-1)
    end;
    envDestroyFrags(arrs[txtTrackY+txtCarY]);
    envToFrag(insStr,arrs[txtTrackY+txtCarY]);
    envEvalKeyRight(t,bitUpd);
    if bitUpd then
      envUpdate(editWnd)
    end
  end
end
end envKeyChar;

//------------- �������� ������� --------------

procedure envKeyDelete(t:integer);
var i:integer; s1,s2:string[maxText];
begin
with txts[txtn[t]][t],txtStrs^ do
  envFromFrag(s1,arrs[txtTrackY+txtCarY]);
  if txtTrackX+txtCarX<=lstrlen(s1) then
    txtMod:=true;
    lstrdel(s1,txtTrackX+txtCarX-1,1);
    envDestroyFrags(arrs[txtTrackY+txtCarY]);
    envToFrag(s1,arrs[txtTrackY+txtCarY]);
    envUpdate(editWnd);
  elsif txtTrackY+txtCarY<tops then //�������� ������
    txtMod:=true;
//������� ������
    envFromFrag(s2,arrs[txtTrackY+txtCarY+1]);
    lstrcat(s1,s2);
//�������� ������
    envDestroyFrags(arrs[txtTrackY+txtCarY]);
    envDestroyFrags(arrs[txtTrackY+txtCarY+1]);
    memFree(arrs[txtTrackY+txtCarY+1]);
    envToFrag(s1,arrs[txtTrackY+txtCarY]);
    for i:=txtTrackY+txtCarY+1 to tops-1 do
      arrs[i]:=arrs[i+1];
    end;
    dec(tops);
    envUpdate(editWnd)
  end;
end
end envKeyDelete;

//-------------- ����� ������� ----------------

procedure envKeyBackspace(t:integer);
var i:integer; s:string[maxText];
begin
with txts[txtn[t]][t],txtStrs^ do
  envFromFrag(s,arrs[txtTrackY+txtCarY]);
  if (txtTrackX+txtCarX>1)and(txtTrackX+txtCarX-1<=lstrlen(s)) then
    envEvalKeyLeft(t);
    envKeyDelete(t);
  else envEvalKeyLeft(t)
  end
end
end envKeyBackspace;

//------------- ������� �������� --------------

procedure envTrackRight(t:integer):integer;
begin
with txts[txtn[t]][t],txtStrs^ do
  if(txtTrackY+txtCarY>1)and(arrs[txtTrackY+txtCarY-1]^.topf>=1)
    then return arrs[txtTrackY+txtCarY-1]^.arrf[1]^.tab
    else return 0
  end
end
end envTrackRight;

//-------------- ������� ������ ---------------

procedure envKeyEnter(t:integer; bitUpd,bitTr:boolean);
var i,j:integer; str:string[maxText]; bitRight:boolean;
begin
with txts[txtn[t]][t],txtStrs^ do
if tops<maxStr then
  txtMod:=true;
//������� ������ ������
  for i:=tops+1 downto txtTrackY+txtCarY+2 do
    arrs[i]:=arrs[i-1];
  end;
  inc(tops);
//���������� ����� ������
  envFromFrag(str,arrs[txtTrackY+txtCarY]);
  lstrdel(str,0,txtTrackX+txtCarX-1);
  arrs[txtTrackY+txtCarY+1]:=memAlloc(sizeof(listFrag));
  envToFrag(str,arrs[txtTrackY+txtCarY+1]);
  bitRight:=lstrlen(str)=0;
//�������� ������ ������
  envFromFrag(str,arrs[txtTrackY+txtCarY]);
  lstrdel(str,txtTrackX+txtCarX-1,maxText);
  envDestroyFrags(arrs[txtTrackY+txtCarY]);
  envToFrag(str,arrs[txtTrackY+txtCarY]);
//������������� �������
  envEvalKeyHome(t,bitUpd);
  envEvalKeyDown(t,bitUpd);
  if bitTr and bitRight then
  for i:=1 to envTrackRight(t) do
    envEvalKeyRight(t,bitUpd)
  end end;
  if bitUpd then
    envUpdate(editWnd)
  end
end end
end envKeyEnter;

//===============================================
//                ������ � �������
//===============================================

//------------ �������� ������� ---------------

procedure envDelChar(t,carX,carY:integer);
var i,otr:integer; s:string[maxText];
begin
with txts[txtn[t]][t],txtStrs^ do
  envFromFrag(s,arrs[carY]);
  lstrdel(s,carX,1);
  envDestroyFrags(arrs[carY]);
  envToFrag(s,arrs[carY]);
end
end envDelChar;

//-------------- ������� ����� ----------------

procedure envBlockBound(t:integer);
var s:string[maxText];
begin
with txts[txtn[t]][t],txtStrs^ do
  if blkSet then
    if (blkY<txtTrackY+txtCarY)or
       (blkY=txtTrackY+txtCarY)and(blkX<=txtTrackX+txtCarX) then
      blkBegX:=blkX;
      blkBegY:=blkY;
      blkEndX:=txtTrackX+txtCarX;
      blkEndY:=txtTrackY+txtCarY;
    else
      blkBegX:=txtTrackX+txtCarX;
      blkBegY:=txtTrackY+txtCarY;
      blkEndX:=blkX;
      blkEndY:=blkY;
    end;
    envFromFrag(s,arrs[blkBegY]);
    if blkBegX>lstrlen(s)+1 then
      blkBegX:=lstrlen(s)+1;
    end;
    envFromFrag(s,arrs[blkEndY]);
    if blkEndX>lstrlen(s)+1 then
      blkEndX:=lstrlen(s)+1;
    end
  end
end
end envBlockBound;

//-------------- ������� ����-----------------

procedure envBlockSet(t:integer; var setBuf:pstr):boolean;
var setText,s:string[maxText]; i,setMem:integer; setBit:boolean;
begin
with txts[txtn[t]][t],txtStrs^ do
  setBit:=false;
  envBlockBound(t);
//{������������ ����}
  if blkBegY=blkEndY then
    setBit:=true;
    setBuf:=memAlloc(blkEndX-blkBegX+2);
    envFromFrag(setText,arrs[blkBegY]);
    setText[blkEndX-1]:=char(0);
    lstrcpy(setBuf,addr(setText[blkBegX-1]));
//{������������� ����}
  else
//{������� ����������}
    setMem:=0;
    envFromFrag(s,arrs[blkBegY]);
    inc(setMem,lstrlen(s)-blkBegX+1+2);
    for i:=blkBegY+1 to blkEndY-1 do
      envFromFrag(s,arrs[i]);
      inc(setMem,lstrlen(s)+2);
    end;
    envFromFrag(s,arrs[blkEndY]);
    inc(setMem,lstrlen(s)+1+2);
//{���������� �����}
    setBit:=true;
    setBuf:=memAlloc(setMem);
    setBuf[0]:=char(0);
    envFromFrag(setText,arrs[blkBegY]);
    lstrcat(setBuf,addr(setText[blkBegX-1]));
    lstrcat(setBuf,"\13\10");
    for i:=blkBegY+1 to blkEndY-1 do
      envFromFrag(s,arrs[i]);
      lstrcat(setBuf,s);
      lstrcat(setBuf,"\13\10");
    end;
    envFromFrag(setText,arrs[blkEndY]);
    setText[blkEndX-1]:=char(0);
    lstrcat(setBuf,setText)
  end;
  return setBit
end
end envBlockSet;

//-------------- �������� ����-----------------

procedure envBlockIns(t:integer; insBuf:pstr);
var insText:string[maxText]; w:integer;
begin
with txts[txtn[t]][t],txtStrs^ do
  w:=0;
  envInfBegin(_�������_�����[envER],nil);
  while insBuf[w]<>char(0) do
    envInf(nil,nil,w*100 div lstrlen(insBuf));
    case insBuf[w] of
      '\13':envKeyEnter(t,false,false);|
      '\27','\32'..'\255':envKeyChar(t,insBuf[w],false);|
    end;
    inc(w)
  end;
  envInfEnd();
  txtMod:=true;
  envUpdate(editWnd);
end
end envBlockIns;

//-------------- ���������� ����-----------------

procedure envEditCopy(t:integer);
var copyBuf:pstr;
begin
with txts[txtn[t]][t],txtStrs^ do
  if blkSet then
    if envBlockSet(t,copyBuf) then //������ �����
      if OpenClipboard(editWnd) then
        EmptyClipboard();
        SetClipboardData(CF_TEXT,HANDLE(copyBuf));
        CloseClipboard()
      else
        memFree(copyBuf);
        mbS(_������_Clipboard_�����_������_�����������[envER])
      end
    end
  end
end
end envEditCopy;

//---------------- �������� ���� -------------------

procedure envEditIns(t:integer);
var insHandle:HANDLE;
begin
with txts[txtn[t]][t],txtStrs^ do
  if not OpenClipboard(editWnd) then
    mbS(_������_Clipboard_�����_������_�����������[envER])
  else
    if (IsClipboardFormatAvailable(CF_TEXT)=false)and(IsClipboardFormatAvailable(CF_OEMTEXT)=false) then
      mbI(GetPriorityClipboardFormat(nil,0),_������_��������_������_������_�_Clipboard[envER])
    else
      insHandle:=GetClipboardData(CF_TEXT);
      if insHandle<>0 then
        envBlockIns(t,GlobalLock(insHandle));
      end
    end;
    CloseClipboard()
  end
end
end envEditIns;

//-------------- ������� ���� -----------------

procedure envEditDel(t:integer);
var i:integer; delText,s:string[maxText];
begin
with txts[txtn[t]][t],txtStrs^ do
  if blkSet then
    envBlockBound(t);
    txtMod:=true;
    blkSet:=false;
    if blkBegY=blkEndY then //������������ ����
      for i:=blkEndX-2 downto blkBegX-1 do
        envDelChar(t,i,blkBegY);
      end;
      txtCarX:=blkBegX-txtTrackX;
      if txtCarX<1 then
        txtTrackX:=0;
        txtCarX:=blkBegX-txtTrackX;
      end;
      envSetCaret(t);
      envUpdate(editWnd)
    else //������������� ����
      envInfBegin(_��������_�����[envER],nil);
//  ������� ������
      if blkBegX=1 then
        dec(blkBegY)
      end;
      for i:=blkBegY+1 to blkEndY-1 do
        envDestroyFrags(arrs[i])
      end;
      for i:=blkBegY+1 to tops-(blkEndY-blkBegY-1) do
        arrs[i]:=arrs[i+blkEndY-blkBegY-1]
      end;
      dec(tops,blkEndY-blkBegY-1);
      blkEndY:=blkBegY+1;
      if blkBegX=1 then
        inc(blkBegY)
      end;
//  ������ ������
      if blkBegX>1 then
        envFromFrag(s,arrs[blkBegY]);
        for i:=lstrlen(s)-1 downto blkBegX-1 do
          envDelChar(t,i,blkBegY)
        end
      end;
//  ��������� ������
      envFromFrag(s,arrs[blkEndY]);
      for i:=blkEndX-2 downto 0 do
        envDelChar(t,i,blkEndY)
      end;
//  ������� �������
      if (txtTrackX+txtCarX<>blkBegX)or(txtTrackY+txtCarY<>blkBegY) then
//    x
        txtCarX:=blkBegX-txtTrackX;
        if txtCarX<1 then
          txtTrackX:=0;
          txtCarX:=blkBegX-txtTrackX;
        end;
//    y
        txtCarY:=blkBegY-txtTrackY;
        if txtCarY<1 then
          txtTrackY:=blkBegY-1;
          txtCarY:=1;
        end
      end;
      envSetCaret(t);
      envInfEnd();
      envUpdate(editWnd);
      if txtTrackX+txtCarX>1 then
        envKeyDelete(t)
      end
    end
  end
end
end envEditDel;

procedure envEditAll();
var s:string[maxText];
begin
with txts[txtn[tekt]][tekt],txtStrs^ do
if tops>0 then
  txtTrackX:=0;
  txtCarX:=1;
  txtTrackY:=0;
  txtCarY:=1;
  envFromFrag(s,arrs[tops]);
  blkSet:=true;
  blkX:=lstrlen(s);
  blkY:=tops;
  envScrSet(tekt);
  envSetStatus(tekt);
  envUpdate(editWnd)
end end
end envEditAll;

//===============================================
//                    �������� ������
//===============================================

//--------------- �������� � ���� ������ -------------------

procedure envUndoPush(cla:classUNDO; t:integer);
var i:integer; str:string[maxText];
begin
//��������� �����
  if envTopUndo<maxUNDO then inc(envTopUndo)
  else
    memFree(envUndo^[1].undoBlock);
    for i:=1 to maxUNDO-1 do
      envUndo^[i]:=envUndo^[i+1]
    end
  end;
//���������� ����������
  with txts[txtn[t]][t] do
  with envUndo^[envTopUndo] do
    Class:=cla;
    undoTxt:=tekt;
    undoExt:=txtn[tekt];
    posX:=txtCarX;
    posY:=txtCarY;
    posTrackX:=txtTrackX;
    posTrackY:=txtTrackY;    
    undoBlock:=nil;
    undoChar:=char(0);
    case Class of
      undoDelChar,undoBackChar: //��������� ������
        if (txtStrs<>nil)and(txtStrs^.tops>0) then 
          envFromFrag(str,txtStrs^.arrs[txtTrackY+txtCarY]);
          case Class of
            undoDelChar:if txtTrackX+txtCarX-1<lstrlen(str) then undoChar:=str[txtTrackX+txtCarX-1] end;|
            undoBackChar:if (txtTrackX+txtCarX-2<lstrlen(str))and(txtTrackX+txtCarX-2>=0) then undoChar:=str[txtTrackX+txtCarX-2] end;|
          end;
        end;|
      undoDelBlock: //��������� ����
        if not (blkSet and envBlockSet(t,undoBlock))  then undoBlock:=nil end;|
    end
  end end;
end envUndoPush;

//--------------- ����������� ������� ����� �������� -------------------

procedure envUndoBlockEnd(t:integer);
begin
with txts[txtn[t]][t] do
  if envTopUndo>0 then
  with envUndo^[envTopUndo] do
    blockX:=txtCarX;
    blockY:=txtCarY;
    blockTrackX:=txtTrackX;
    blockTrackY:=txtTrackY;    
  end end
end
end envUndoBlockEnd;

//--------------- ����� ������� ����� -------------------

procedure envUndoInsBlock(var undo:recUndo; t:integer);
begin
  with txts[txtn[t]][t],undo do
    blkX:=blockTrackX+blockX;
    blkY:=blockTrackY+blockY;
    blkSet:=true;
    envEditDel(t);
  end
end envUndoInsBlock;

//--------------- ����� �������� ����� -------------------

procedure envUndoDelBlock(var undo:recUndo; t:integer);
begin
  with txts[txtn[t]][t],undo do
  if undoBlock<>nil then
    txtCarX:=blockX;
    txtCarY:=blockY;
    txtTrackX:=blockTrackX;
    txtTrackY:=blockTrackY;
    blkSet:=false;
    envBlockIns(t,undoBlock);
  end end
end envUndoDelBlock;

//--------------- ��������� ����� -------------------

procedure envUndoPop(t:integer);
var bitUndoInsChar:boolean;
begin
  bitUndoInsChar:=(envTopUndo>0)and(envUndo^[envTopUndo].Class=undoInsChar);
  repeat
    if envTopUndo>0 then
    with envUndo^[envTopUndo] do
    //����� �������
      if undoTxt<>t then
        envSelect(undoTxt,undoExt);
      end;
      with txts[undoExt][undoTxt] do
        txtCarX:=posX;
        txtCarY:=posY;
        txtTrackX:=posTrackX;
        txtTrackY:=posTrackY;
        blkSet:=false;
      end;
    //����� ��������
      with envUndo^[envTopUndo] do
        case Class of
          undoInsChar:envKeyDelete(undoTxt);|
          undoDelChar:if undoChar<>char(0) then envKeyChar(undoTxt,undoChar,true) end;|
          undoBackChar:if undoChar<>char(0) then envEvalKeyLeft(undoTxt); envKeyChar(undoTxt,undoChar,true) end;|
          undoInsStr:envKeyDelete(undoTxt);|
          undoDelStr:envKeyEnter(undoTxt,true,false);|
          undoInsBlock:envUndoInsBlock(envUndo^[envTopUndo],undoTxt);|
          undoDelBlock:envUndoDelBlock(envUndo^[envTopUndo],undoTxt);|
        end;
        if undoBlock<>nil then
          memFree(undoBlock);
        end;
        txts[undoExt][undoTxt].txtMod:=true;
      end;
      dec(envTopUndo);
//���������� ������
      envUpdate(editWnd);
      envSetStatus(tekt);
      SetFocus(editWnd);
    end end;
  until (not bitUndoInsChar)or(envTopUndo=0)or(envUndo^[envTopUndo].Class<>undoInsChar);
end envUndoPop;

//--------------- ������� ����� ������� -------------------

procedure envUndoClear();
var i:integer;
begin
  for i:=1 to envTopUndo do
    memFree(envUndo^[i].undoBlock);
  end;
  envTopUndo:=0;
end envUndoClear;

//===============================================
//                    �����
//===============================================

//--------------- ��������� -------------------

procedure envLoadFile(path:pstr; strs:pStrs):boolean;
var s,my:string[maxText]; fil:integer; bit:boolean; nom,car,siz:integer; res:boolean;
begin
with strs^ do
  tops:=0;
  fil:=_lopen(path,OF_READ);
  res:=fil>0;
  if fil>0 then
    nom:=0;
    car:=0;
    siz:=_lsize(fil);
    envInfBegin(_��������_�����_[envER],nil);
    repeat
      bit:=_lreads(fil,s,envBUFSIZE);
      inc(car,lstrlen(s)+2);
      inc(nom);
      if (siz>0)and(nom mod 22=0) then
        envInf(path,nil,car*100 div siz);
      end;
      if (tops<maxStr) then
        inc(tops);
        arrs[tops]:=memAlloc(sizeof(listFrag));
        envToFrag(s,arrs[tops]);
      end;
    until bit;
    envInfEnd();
    _lclose(fil);
  end;
//����� ����
  if tops=0 then
    inc(tops);
    arrs[tops]:=memAlloc(sizeof(listFrag));
    with arrs[tops]^ do
      topf:=1;
      arrf[topf]:=memAlloc(sizeof(recFrag));
      with arrf[topf]^ do
        cla:=fCOMM;
        tab:=0;
        txt:=nil
      end
    end
  end;
  return res
end
end envLoadFile;

//--------------- ��������� -------------------

procedure envSaveFile(path:pstr; strs:pStrs);
var fil,i:integer; s:string[maxText];
begin
with strs^ do
  fil:=_lcreat(path,0);
  if fil>0 then
    for i:=1 to tops do
      envFromFrag(s,arrs[i]);
      lstrcat(s,"\13\10");
      _lwrite(fil,s,lstrlen(s));
    end;
    _lclose(fil);
  else MessageBox(0,path,_�������_���_��������_�����_[envER],0)
  end
end
end envSaveFile;

//------------- ����� ���� ------------------

procedure envNew();
var oPath,oTitle,oMas:string[maxText]; i,j:integer; S:recStream;
begin
  if topt>=maxTxt then mbS(_�������_�����_����[envER])
  else
    envDestroyTitle();
    lstrcpy(oPath,"noname.");
    lstrcat(oPath,envEXTM);
    lstrcpy(oTitle,oPath);
    i:=0;
    for j:=1 to topt do
      if lstrcmp(addr(txts[0][j].txtFile),oPath)=0 then
        inc(i)
    end end;
    inc(topt);
    tekt:=topt;
    with txts[0][topt] do
      CharLower(oTitle);
      if lstrposc('.',oTitle)<>-1 then
        lstrdel(oTitle,lstrposc('.',oTitle),maxText);
      end;
      envInitial(txts[0][topt],1,1,oPath,oTitle);
      if (i>0)and(lstrposc(':',txtTitle)=-1) then
        lstrcatc(txtTitle,':');
        lstrcatc(txtTitle,char(integer('0')+i+1));
      end;
      txtStrs:=memAlloc(sizeof(listStr));
      txtLoad:=envLoadFile(oPath,txtStrs);
    end;
    lstrcpy(oPath,"noname.");
    lstrcat(oPath,envEXTD);
    lstrcpy(oTitle,oPath);
    with txts[1][topt] do
      CharLower(oTitle);
      if lstrposc('.',oTitle)<>-1 then
        lstrdel(oTitle,lstrposc('.',oTitle),maxText);
      end;
      envInitial(txts[1][topt],1,1,oPath,oTitle);
      if (i>0)and(lstrposc(':',txtTitle)=-1) then
        lstrcatc(txtTitle,':');
        lstrcatc(txtTitle,char(integer('0')+i+1));
      end;
      txtStrs:=memAlloc(sizeof(listStr));
      txtLoad:=envLoadFile(oPath,txtStrs);
    end;
    if not IsWindowVisible(editWnd) then
      ShowWindow(editWnd,SW_SHOW);
    end;
    inc(topMod);
    for i:=topMod downto topt+1 do
      tbMod[i]:=tbMod[i-1];
      idChangeMod(tbMod[i].modTab,i-1,i);
    end;
    genLoadMod(S,oTitle,topt,false);
    envUpdate(editWnd);
    envSetCaret(tekt);
    envScrSet(tekt);
    envSetStatus(tekt);
    envCreateTitle(mainWnd);
  end;
  SetFocus(editWnd)
end envNew;

//------------- ������� ������ �� ������ ������ ------------------

procedure envPointMod(tab:pID; setdel:setbyte):boolean;
var j:integer;
begin
  if tab=nil then return false end;
  with tab^ do
    case idClass of
      idcSTRU:if idStruType^.idNom in setdel then return true end;|
      idcSCAL:if idScalType^.idNom in setdel then return true end;|
      idtARR:
        if idArrItem^.idNom in setdel then return true end;
        if idArrInd^.idNom in setdel then return true end;|
      idtREC:for j:=1 to idRecMax do if idRecList^[j]^.idNom in setdel then return true end end;|
      idtSCAL:for j:=1 to idScalMax do if idScalList^[j]^.idNom in setdel then return true end end;|
      idtPOI:if idPoiType^.idNom in setdel then return true end;|
      idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR:if idVarType^.idNom in setdel then return true end;|
      idPROC:
        for j:=1 to idProcMax do
          if idProcList^[j]^.idNom in setdel then return true end;
        end;
        if idProcType<>nil then
          if idProcType^.idNom in setdel then return true end;
        end;|
    end;
    if envPointMod(idLeft,setdel) then return true end;
    if envPointMod(idRight,setdel) then return true end;
    return false
  end
end envPointMod;

//------------�������� def-������, ������� ������ �� ������ ������------------

procedure envDeleteDef();
var i,j:integer; setdel:setbyte;
begin
  for j:=topMod downto topt+1 do
    setdel:=[];
    for i:=1 to topMod do
    if i<>j then
      setdel:=setdel+i
    end end;
    if envPointMod(tbMod[j].modTab,setdel) then
      genCloseMod(j);
      for i:=j to topMod-1 do
        tbMod[i]:=tbMod[i+1];
        idChangeMod(tbMod[i].modTab,i+1,i);
      end;
      dec(topMod);
    end;
    for i:=1 to topt do
    if not tbMod[i].modMain then
      tbMod[i].modComp:=false
    end end
  end;
end envDeleteDef;

//------------- ������� ���� ------------------

procedure envOpen(iPath,iTitle:pstr; t:integer);
var oPath,oTitle,oMas:string[maxText]; i,j,k:integer; S:recStream; setdel:setbyte;
begin
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;
//����� �����
  lstrcpy(oMas,"*.");
  lstrcat(oMas,envEXTM);
  lstrcat(oMas,";*.");
  lstrcat(oMas,envEXTD);
  oMas[lstrlen(oMas)+1]:='\0';
  if topt>=maxTxt then mbS(_�������_�����_����[envER])
  elsif not((iPath=nil)and not sysGetFileName(true,oMas,oPath,oTitle)) then
  //��������� ��������
    envDestroyTitle();
    if iPath<>nil then
      lstrcpy(oPath,iPath);
      lstrcpy(oTitle,iTitle);
    end;
    i:=0;
    for j:=1 to topt do
      if lstrcmp(addr(txts[0][j].txtFile),oPath)=0 then
        inc(i)
    end end;
    inc(topt);
    tekt:=t;
//����� def-�������
    inc(topMod);
    for i:=topMod downto topt+1 do
      tbMod[i]:=tbMod[i-1];
      idChangeMod(tbMod[i].modTab,i-1,i);
    end;
//����� �������
    for i:=topt downto t+1 do
      txts[0][i]:=txts[0][i-1];
      txts[1][i]:=txts[1][i-1];
    end;
    for i:=topt downto t+1 do
      tbMod[i]:=tbMod[i-1];
      idChangeMod(tbMod[i].modTab,i-1,i);
    end;
    if t<topt then
      envDeleteDef();
    end;
    if (mait>=t)and(mait<topt) then inc(mait) end;
//���������� ������
    lstrcpy(oMas,".");
    lstrcat(oMas,envEXTD);
    if lstrpos(oMas,oPath)>=0 then i:=1 else i:=0 end;
    with txts[i][t] do
      CharLower(oTitle);
      if lstrposc('.',oTitle)>=0 then
        lstrdel(oTitle,lstrposc('.',oTitle),maxText);
      end;
      envInitial(txts[i][t],1,1,oPath,oTitle);
      if (i>0)and(lstrposc(':',txtTitle)=-1) then
        lstrcatc(txtTitle,':');
        lstrcatc(txtTitle,char(integer('0')+i+1));
      end;
      txtStrs:=memAlloc(sizeof(listStr));
      txtLoad:=envLoadFile(oPath,txtStrs);
    end;
    if i=0 then i:=1 else i:=0 end;
    if lstrposc('.',oTitle)>=0 then lstrdel(oTitle,lstrposc('.',oTitle),maxText); lstrcatc(oTitle,'.'); if i=0 then lstrcat(oTitle,envEXTM) else lstrcat(oTitle,envEXTD) end end;
    if lstrposc('.',oPath)>=0 then lstrdel(oPath,lstrposc('.',oPath),maxText); lstrcatc(oPath,'.'); if i=0 then lstrcat(oPath,envEXTM) else lstrcat(oPath,envEXTD) end end;
    with txts[i][t] do
      CharLower(oTitle);
      if lstrposc('.',oTitle)>=0 then
        lstrdel(oTitle,lstrposc('.',oTitle),maxText);
      end;
      envInitial(txts[i][t],1,1,oPath,oTitle);
      if (i>0)and(lstrposc(':',txtTitle)=-1) then
        lstrcatc(txtTitle,':');
        lstrcatc(txtTitle,char(integer('0')+i+1));
      end;
      txtStrs:=memAlloc(sizeof(listStr));
      txtLoad:=envLoadFile(oPath,txtStrs);
    end;
    if txts[0][t].txtLoad then txtn[t]:=0 else txtn[t]:=1 end;
//���������� ������
    genLoadMod(S,oTitle,t,false);
//���� � ������
    if not IsWindowVisible(editWnd) then
      ShowWindow(editWnd,SW_SHOW);
    end;
    if iPath=nil then
      envUpdate(editWnd);
      envSetCaret(tekt);
      envScrSet(tekt);
      envSetStatus(tekt);
    end;
    envDeleteDef();
    envCreateTitle(mainWnd);
  end;
  SetFocus(editWnd)
end envOpen;

//----------- ����������� ���� ----------------

procedure envSelect(nom,ext:integer);
var bitT,bitE:boolean;
begin
  bitT:=(nom<>tekt);
  bitE:=(ext<>txtn[nom]);
  if bitT then
    tekt:=nom;
    SendMessage(wndTabs,TCM_SETCURSEL,tekt-1,0);
  end;
  if bitE then
    txtn[tekt]:=ext;
    SendMessage(wndExt,TCM_SETCURSEL,txtn[tekt],0);
  end;
  if bitT or bitE then
    envUpdate(editWnd);
    envSetCaret(tekt);
    envScrSet(tekt);
    envSetStatus(tekt);
  end;
  SetFocus(editWnd);
end envSelect;

//------------- ������� ���� ------------------

procedure envClose();
var i,j,answ:integer; setdel:setbyte;
begin
if topt>=1 then
  answ:=IDNO;
  if txts[0][tekt].txtMod or txts[1][tekt].txtMod then
    answ:=MessageBox(mainWnd,_�_����_�������������_�����__���������__[envER],txts[0][tekt].txtFile,MB_YESNOCANCEL | MB_ICONSTOP);
  end;
  if answ=IDYES then
    with txts[0][tekt]  do envSaveFile(txtFile,txtStrs) end;
    with txts[1][tekt]  do envSaveFile(txtFile,txtStrs) end;
  end;
  if answ<>IDCANCEL then
    envDestroyTitle();
    for i:=tekt to topt-1 do
      txts[0][i]:=txts[0][i+1];
      txts[1][i]:=txts[1][i+1];
    end;
    genCloseMod(tekt);
    dec(topt);
    for i:=tekt to topMod-1 do
      tbMod[i]:=tbMod[i+1];
      idChangeMod(tbMod[i].modTab,i+1,i);
    end;
    dec(topMod);
    if mait=tekt then mait:=0
    elsif mait>tekt then dec(mait) end;
    if tekt>topt then tekt:=topt end;
    envDeleteDef();
    envCreateTitle(mainWnd);
    if topt=0 then
      ShowWindow(editWnd,SW_HIDE);
    end;
    envSetStatus(tekt);
    envUpdate(editWnd)
  end;
  SetFocus(editWnd)
end
end envClose;

//--------------- ��������� -------------------

procedure envSave();
var i,j:integer;
begin
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;
  if topt>0 then
  with txts[txtn[tekt]][tekt] do
    envSaveFile(txtFile,txtStrs);
    txtMod:=false;
    envSetStatus(tekt)
  end end;
  SetFocus(editWnd)
end envSave;

//------------- ��������� ��� -----------------

procedure envSaveAs();
var oPath,oTitle,oMas:string[maxText]; i,j:integer; item:TC_ITEM;
begin
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;
  lstrcpy(oMas,"*.");
  lstrcat(oMas,envEXTM);
  lstrcat(oMas,";*.");
  lstrcat(oMas,envEXTD);
  oMas[lstrlen(oMas)+1]:='\0';
  oMas[lstrlen(oMas)+2]:='\0';
  if sysGetFileName(false,oMas,oPath,oTitle) then
  if not(_fileok(oPath) and
     (MessageBox(0,oPath,_����_���_����������__����������__[envER],
        MB_YESNOCANCEL | MB_ICONSTOP)<>IDYES)) then
    with txts[txtn[tekt]][tekt] do
      lstrcpy(txtTitle,oTitle);
      lstrcpy(txtFile,oPath);
      CharLower(txtTitle);
      with item do
        RtlZeroMemory(addr(item),sizeof(TC_ITEM));
        mask:=TCIF_TEXT;
        pszText:=addr(txts[0][tekt].txtTitle);
        SendMessage(wndTabs,TCM_SETITEM,tekt-1,cardinal(addr(item)));
        SendMessage(wndExt,TCM_SETITEM,txtn[tekt],cardinal(addr(item)));
      end;
      envSaveFile(txtFile,txtStrs);
      txtMod:=false;
      envSetStatus(tekt)
    end
  end end;
  SetFocus(editWnd)
end envSaveAs;

//----------- ��������� � ��������� ------------

procedure envSaveFiles;
var i,saveMB:integer; saveBit:boolean; mode:integer;
begin
  if bitCancel
    then mode:=MB_YESNOCANCEL | MB_ICONSTOP
    else mode:=MB_YESNO | MB_ICONSTOP
  end;
  envBitSaveFiles:=true;
  saveBit:=true;
  for i:=1 to topt do
  with txts[txtn[i]][i] do
  if saveBit then
  if txtMod then
    saveMB:=MessageBox(0,txtFile,_�_����_�������������_�����__���������_[envER],mode);
    if saveMB=IDCANCEL then saveBit:=false; envBitSaveFiles:=false;
    elsif saveMB=IDYES then
      envSaveFile(txtFile,txtStrs);
      txtMod:=false;
    end
  end end end end;
  if not saveBit then
    SetFocus(editWnd)
  end;
  return saveBit
end envSaveFiles;

//===============================================
//               ������-����
//===============================================

//---------- ������ ������-����� --------------

procedure envStatusLoad();
var i,num,car,fil,staTrackX,staTrackY,staCarX,staCarY:integer; iFile,iTitle:string[maxText];
begin
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;
  fil:=_lopen(StatusFile,OF_READ);
  if fil>0 then
    _lread(fil,addr(num),4);
    _lread(fil,addr(car),4);
    _lread(fil,addr(mait),4);
    _lread(fil,addr(staTrackX),4);
    _lread(fil,addr(staTrackY),4);
    _lread(fil,addr(staCarX),4);
    _lread(fil,addr(staCarY),4);
    _lread(fil,addr(traLANG),1);
    _lread(fil,addr(WinHeader.baseOfCode),4);
    for i:=1 to num do
      _lread(fil,addr(iFile),maxTxtFile+1);
      _lread(fil,addr(iTitle),maxTxtFile+1);
      envOpen(iFile,iTitle,topt+1);
      _lread(fil,addr(tbMod[i].modComp),4);
      tbMod[i].modComp:=false;
    end;
    if num>0 then
    with txts[txtn[car]][car] do
    if (txtStrs<>nil)and(staTrackY+staCarY<=txtStrs^.tops) then
       txtTrackX:=staTrackX;
       txtTrackY:=staTrackY;
       txtCarX:=staCarX;
       txtCarY:=staCarY;
    end end end;
    for i:=1 to topMod do
    with tbMod[i] do
      _lread(fil,addr(genBegCode),4);
    end end;
    envSelect(car,txtn[car]);
    _lclose(fil)
  end;
end envStatusLoad;

//---------- ������ ������-����� --------------

procedure envStatusSave();
var i,fil:integer;
begin
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;
  fil:=_lcreat(StatusFile,0);
  if fil>0 then
    _lwrite(fil,addr(topt),4);
    _lwrite(fil,addr(tekt),4);
    _lwrite(fil,addr(mait),4);
    _lwrite(fil,addr(txts[0][tekt].txtTrackX),4);
    _lwrite(fil,addr(txts[0][tekt].txtTrackY),4);
    _lwrite(fil,addr(txts[0][tekt].txtCarX),4);
    _lwrite(fil,addr(txts[0][tekt].txtCarY),4);
    _lwrite(fil,addr(traLANG),1);
    _lwrite(fil,addr(WinHeader.baseOfCode),4);
    for i:=1 to topt do
    with txts[0][i] do
      _lwrite(fil,addr(txtFile),maxTxtFile+1);
      _lwrite(fil,addr(txtTitle),maxTxtTitle+1);
      _lwrite(fil,addr(tbMod[i].modComp),4);
    end end;
    for i:=1 to topMod do
    with tbMod[i] do
      _lwrite(fil,addr(genBegCode),4);
    end end;
    _lclose(fil)
  end
end envStatusSave;

//===============================================
//           ���������� � ������
//===============================================

//----------------------���������� ������----------------------------

procedure traTranslate(var Stream:recStream; traName:pstr; traTxt:integer; onlyDef:boolean);
var i,j,oldTek,traExt,ext:integer; carBegCode:cardinal;
begin
  oldTek:=tekt;
  tekt:=traTxt;
  genEntry:=-1;
  traCarProc:=nil;
  traBitIMP:=false;
  traBitDEF:=false;
  traBitLoadString:=true;
  traFromDLL[0]:='\0';
  envInfBegin(_����������[envER],"");
  envInf(_�������������_������[envER],nil,0);
  genInitial();
  idDestroy(tbMod[traTxt].modTab);
  idInitial(tbMod[traTxt].modTab,traTxt);
  with tbMod[traTxt] do
    modMain:=false;
    impDestroy(genImport,topImport);
    genImport:=memAlloc(sizeof(arrIMPORT));
    topImport:=0;
    expDestroy(genExport,topExport);
    genExport:=memAlloc(sizeof(arrEXPORT));
    topExport:=0;
    topData:=0;
    topCode:=0;
    topVarCall:=0;
    topProCall:=0;
    topGenStep:=0;
  end;
  for i:=1 to topMod do
    tbMod[i].modAct:=false;
  end;
  tbMod[traTxt].modAct:=true;
  genFreeRes(traTxt);

  if txts[0][traTxt].txtLoad then
    for i:=1 to maxWith do
    for j:=1 to 4 do
      genPutByte(Stream,0);
    end end;
    for i:=1 to genCLASSSIZE do
      genPutByte(Stream,0);
    end;
  end;
  traBitDEF:=false;
  traBitIMP:=false;
  Stream.stErr:=false;
  for traExt:=1 downto 0 do
  if not Stream.stErr and txts[traExt][traTxt].txtLoad and (not onlyDef or(traExt=1)) then
    traStackTop:=0;
    stepTopStack:=0;
    ext:=traExt;
    traBitH:=(traExt=1);
    lexOpen(Stream,traName,traTxt,traExt);
    case traLANG of
      langMODULA:traMODULE(Stream);|
      langC:tracMODULE(Stream,txts[traExt][traTxt].txtFile);|
      langPASCAL:trapMODULE(Stream);|
    end;
  end end;
  if not traBitDEF and not traBitIMP then
    traFinish(Stream);
  end;

  if not Stream.stErr then
    genSetCalls(Stream,genCall^,traTxt,true);
    if traBitDEF or traBitIMP then
      envInf(_���������_i_�����[envER],nil,0);
      genDef(Stream,traName,traTxt);
    end;
    if (not traBitDEF or traMakeDLL) and not traBitIMP then
      envInf(_���������_exe_dll__�����[envER],nil,0);
      genExe(Stream,traName,traTxt);
    end
  end;

  if Stream.stErr then
    errTxt:=traTxt;
    errExt:=ext;
  else tbMod[traTxt].modComp:=true
  end;

  lexClose(Stream);
  genDestroy();
  envInfEnd();
  tekt:=oldTek
end traTranslate;

//------------- ������� ������ ----------------

procedure envSetError(txt,ext:integer; f,y:integer);
var i,x:integer;
begin
  if y>txts[ext][txt].txtStrs^.tops then
    y:=txts[ext][txt].txtStrs^.tops;
  end;
  with txts[ext][txt],txtStrs^.arrs[y]^ do
    x:=1;
    for i:=1 to f-1 do
      inc(x,arrf[i]^.len);
    end;
    inc(x,arrf[f]^.tab);
    envSetPosition(txt,x,y,arrf[f]^.len);
  end
end envSetError;

//--------------- ������ ������ ----------------

const DLG_ERR=stringER{"DLG_ERR_R","DLG_ERR_E"};
dialog DLG_ERR_R 89, 62, 151, 64,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "����� ������"
begin
  control "�������� ������ (����������������):", -1, "Static", 1 | WS_CHILD | WS_VISIBLE, 2, 12, 147, 9
  control "", 710, "Edit", ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP, 41, 28, 70, 10
  control "������", 550, "Button", 0 | WS_CHILD | WS_VISIBLE, 32, 47, 45, 12
  control "��������", 560, "Button", 0 | WS_CHILD | WS_VISIBLE, 84, 47, 45, 12
end;
dialog DLG_ERR_E 89, 62, 151, 64,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Error find"
begin
  control "Code address (hex):", -1, "Static", 1 | WS_CHILD | WS_VISIBLE, 2, 12, 147, 9
  control "", 710, "Edit", ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP, 41, 28, 70, 10
  control "Begin", 550, "Button", 0 | WS_CHILD | WS_VISIBLE, 32, 47, 45, 12
  control "Cancal", 560, "Button", 0 | WS_CHILD | WS_VISIBLE, 84, 47, 45, 12
end;

//--------------- ����� ������ ----------------

const
  idc_Error=710;
  idc_OkButton=550;
  idc_NoButton=560;

procedure envErrorDlg(Wnd:HWND; Message,wParam,lParam:integer):boolean;
var code:integer;
begin
  case Message of
    WM_INITDIALOG:
      SetDlgItemText(Wnd,idc_Error,envErrPos);
      SetFocus(GetDlgItem(Wnd,idc_Error));
      SendDlgItemMessage(Wnd,idc_Error,EM_SETSEL,0,-1*0x10000);|
    WM_COMMAND:case loword(wParam) of
      idc_Error:
        GetDlgItemText(Wnd,idc_Error,envErrPos,maxText);
        if (lstrposc('x',envErrPos)=-1)and(lstrposc('X',envErrPos)=-1) then
          lstrinsc('x',envErrPos,0);
          lstrinsc('0',envErrPos,0);
        end;
        envError:=wvscani(envErrPos);|
      idc_OkButton:EndDialog(Wnd,1);|
      idc_NoButton:EndDialog(Wnd,0);|
      IDOK:EndDialog(Wnd,1);|
      IDCANCEL:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true;
end envErrorDlg;

//--------------- ������ ������� ------------------

procedure envSteps(nom:integer);
var ����,���,���:integer; ������,���:string[1000];
begin
with tbMod[nom] do
  ����:=_lcreat("steps.txt",0);
  for ���:=1 to topGenStep do
  with genStep^[���] do
    wvsprintf(addr(������),"%li:",addr(���)); _lwrite(����,addr(������),lstrlen(������));
    case Class of
      stepNULL:lstrcpy(������,"stepNULL");|
      stepSimple:lstrcpy(������,"stepSimple");|
      stepCALL:lstrcpy(������,"stepCALL");|
      stepRETURN:lstrcpy(������,"stepRETURN");|
      stepIF:lstrcpy(������,"stepIF");|
      stepVarIF:lstrcpy(������,"stepVarIF");|
      stepEndIF:lstrcpy(������,"stepEndIF");|
      stepCASE:lstrcpy(������,"stepCASE");|
      stepVarCASE:lstrcpy(������,"stepVarCASE");|
      stepEndCASE:lstrcpy(������,"stepEndCASE");|
      stepFOR:lstrcpy(������,"stepFOR");|
      stepBegFOR:lstrcpy(������,"stepBegFOR");|
      stepModFOR:lstrcpy(������,"stepModFOR");|
      stepEndFOR:lstrcpy(������,"stepEndFOR");|
      stepWHILE:lstrcpy(������,"stepWHILE");|
      stepBegWHILE:lstrcpy(������,"stepBegWHILE");|
      stepModWHILE:lstrcpy(������,"stepModWHILE");|
      stepEndWHILE:lstrcpy(������,"stepEndWHILE");|
      stepREPEAT:lstrcpy(������,"stepREPEAT");|
      stepModREPEAT:lstrcpy(������,"stepModREPEAT");|
      stepEndREPEAT:lstrcpy(������,"stepEndREPEAT");|
    end;
    lstrcat(������," "); _lwrite(����,addr(������),lstrlen(������));
    wvsprintf(addr(������),"���:%lx ",addr(source)); _lwrite(����,addr(������),lstrlen(������));
    ���:=integer(line); wvsprintf(addr(������),"������:%li ",addr(���)); _lwrite(����,addr(������),lstrlen(������));
    ���:=integer(level); wvsprintf(addr(������),"�������:%li ",addr(���)); _lwrite(����,addr(������),lstrlen(������));
    lstrcpy(������,"\13\10"); _lwrite(����,addr(������),lstrlen(������));
  end end;
  _lclose(����);
end
end envSteps;

//--------------- ���������� ------------------

procedure envTranslate();
var Stream:recStream;
begin
with Stream,tbMod[tekt] do
  traTranslate(Stream,txts[0][tekt].txtTitle,tekt,txtn[tekt]=1);// envSteps(tekt);
  with Stream do
  if stErr then
    if txtn[errTxt]<>errExt then
      envSelect(errTxt,errExt);
    end;
    envSetError(tekt,stErrExt,stErrPos.f,stErrPos.y);
    envUpdate(editWnd);
    MessageBox(editWnd,stErrText,_������[envER],MB_ICONSTOP);
    SetFocus(editWnd);
  elsif txtn[tekt]=0 then modComp:=true
  end end;
  SetFocus(editWnd)
end
end envTranslate;

//----------- ���������� ����� ----------------

procedure envTransAll(traFind,traDll:boolean):boolean;
var Stream:recStream; errBox,i,main:integer; bitC:boolean;
begin
with Stream do
  traMakeDLL:=traDll;
  if traMakeDLL
    then genBASECODE:=0x10000000
    else genBASECODE:=0x400000
  end;
  if traFind then
    errBox:=DialogBoxParam(hINSTANCE,DLG_ERR[envER],editWnd,addr(envErrorDlg),0);
    if errBox=0 then return false end
  else envError:=0
  end;
  if envError>0 then
    if envError>=genBASECODE then
      dec(envError,genBASECODE)
    end;
    if envError>WinHeader.baseOfCode then
      dec(envError,WinHeader.baseOfCode)
    end
  end;
  errTxt:=0;
  errExt:=0;

//����� ����������
  bitC:=true;
  for i:=1 to topt do
  with tbMod[i] do
    if bitC and not modComp then
      bitC:=false;
    end;
    if not bitC then
      modComp:=false
    end
  end end;
  if envOldFolder[0]<>'\0' then
    SetCurrentDirectory(envOldFolder);
    envOldFolder[0]:='\0'
  end;

//���������� ������
  if mait=0
    then main:=tekt
    else main:=mait
  end;
  for i:=1 to topt do
  with tbMod[i] do
  if (errTxt=0)and(i<>main)and((not modComp)or(envError>0)) then
    traTranslate(Stream,txts[0][i].txtTitle,i,false);
  end end end;
  if (errTxt=0)and(topt>0) then
  with tbMod[main] do
    traTranslate(Stream,txts[0][main].txtTitle,main,false);
  end end;

//������
  if (envError>0)and(errTxt=0) then
    lexError(Stream,_�����_������_��_����������[envER],nil);
    errTxt:=tekt;
  end;
  if errTxt<>0 then
  with Stream do
    if (errTxt<>tekt)or(txtn[errTxt]<>errExt) then
      envSelect(errTxt,errExt);
    end;
    envSetError(tekt,stErrExt,stErrPos.f,stErrPos.y);
    envUpdate(editWnd);
    MessageBox(editWnd,stErrText,_������[envER],MB_ICONSTOP);
    SetFocus(editWnd);
    return false
  end end;
//  �������������(tekt);
  envSetStatus(tekt);
  SetFocus(editWnd);
  return true
end
end envTransAll;

//------------- ���������� ----------------

procedure envExecute();
var execPath,carFolder:string[maxText]; mai:integer;
begin
  if envTransAll(false,false) then
    if mait=0
      then mai:=tekt
      else mai:=mait
    end;
    genExeName(txts[txtn[mai]][mai].txtTitle,envExeFolder,execPath,false);
    if envExeFolder[0]<>'\0' then
      lstrcpy(carFolder,execPath);
      while (lstrlen(carFolder)>0)and(carFolder[lstrlen(carFolder)-1]<>'\') do
        lstrdel(carFolder,lstrlen(carFolder)-1,1)
      end;
      GetCurrentDirectory(300,envOldFolder);
      SetCurrentDirectory(carFolder);
    end;
    if lstrposc(':',txts[txtn[mai]][mai].txtTitle)=-1 then
    if WinExec(execPath,SW_SHOW)<=32 then
      MessageBox(0,execPath,_�����������_����_[envER],MB_ICONSTOP)
    end end
  end;
end envExecute;

//===============================================
//             ���������� ��������
//===============================================

const
  �������������=200;
  �������������=100;

var
  ���������DebugBreak:boolean; //������ DebugBreak ��������
  ���DebugBreak1:boolean; //������ DebugBreak � ����
  �������DebugBreak1,�������DebugBreak2,�������Jmp:string[5];

procedure ������������(); forward;

//---------------------- �������� � ��� ����� DebugBreak ��� Jmp ----------------------

type ��������=(���DebugBreak,���Jmp15);

procedure ����������������������(�����:��������; �������:HANDLE; �����:address; �����:pstr):boolean;
var �����DebugBreak,�����,l:integer; �������:array[0..4]of byte;
begin
  case ����� of
    ���DebugBreak:
      �����DebugBreak:=integer(GetProcAddress(GetModuleHandle("kernel32"),"DebugBreak"));
      if �����DebugBreak=0 then return false end;
      l:=�����DebugBreak-integer(�����)-5;
      �������[0]:=0xe8;
      �������[1]:=lobyte(loword(l));
      �������[2]:=hibyte(loword(l));
      �������[3]:=lobyte(hiword(l));
      �������[4]:=hibyte(hiword(l));|
    ���Jmp15:
      �������[0]:=0xe9;
      �������[1]:=0xF1;
      �������[2]:=0xFF;
      �������[3]:=0xFF;
      �������[4]:=0xFF;|
  end;
  if not ReadProcessMemory(�������,�����,�����,5,addr(�����)) then return false end;
  if �����<>5 then return false end;
  if not WriteProcessMemory(�������,�����,addr(�������),5,addr(�����)) then return false end;
  if �����<>5 then return false end;
  if not FlushInstructionCache(�������,�����,5) then return false end;
  return true
end ����������������������;

//---------------------- �������� ����� �� ����� ----------------------

procedure ������������������������(�������,�������:HANDLE; ��������:cardinal):cardinal;
var ���������,�����,�����:cardinal; ��������:CONTEXT;
begin
  RtlZeroMemory(addr(��������),sizeof(CONTEXT));
  ��������.ContextFlags:=CONTEXT_FULL;
  if not GetThreadContext(�������,��������) then mbS(_������_���������_���������_��������[envER]) end;
  �����:=��������.Esp+��������;
  ReadProcessMemory(�������,address(�����),addr(���������),4,addr(�����));
  if �����<>4 then mbS(_������_������_������_��_�����[envER]) end;
  return ���������
end ������������������������;

//---------------------- �������� �������� �������� bp ----------------------

procedure �������������������BP(�������,�������:HANDLE):cardinal;
var ��������:CONTEXT;
begin
  RtlZeroMemory(addr(��������),sizeof(CONTEXT));
  ��������.ContextFlags:=CONTEXT_FULL;
  if not GetThreadContext(�������,��������) then mbS(_������_���������_���������_��������[envER]) end;
  return ��������.Ebp;
end �������������������BP;

//---------------------- �������� ����� �������� �� ��������� ----------------------

procedure ������������������������(�������,�������:HANDLE):cardinal;
var ���������,�����,�����:cardinal;
begin
  �����:=�������������������BP(�������,�������)+4;
  ReadProcessMemory(�������,address(�����),addr(���������),4,addr(�����));
  if �����<>4 then mbS(_������_������_������_��_�����[envER]) end;
  return ���������
end ������������������������;

//------------- ������ �������� ����� ������ -----------------

procedure ������������Break(���,source:integer):integer;
begin
  return genBASECODE+WinHeader.baseOfCode+tbMod[���].genBegCode+source
end ������������Break;

//------------- ����� ���������, � ������� ��������� break -----------------

procedure ������������(���:pID; ���:integer):pID;
var ���:pID;
begin
  if ���=nil then return nil end;
  with ���^ do
    if (idClass=idPROC)and(idProcAddr<=���)and(idProcAddr+idProcCode>=���) then
      return ���
    end;
    ���:=������������(idLeft,���);
    if ���=nil
      then return ������������(idRight,���);
      else return ���
    end
  end
end ������������;

//------------- ���������� Break � �������� � stepActive -----------------

procedure �������������Break(���,���:integer);
var ���:integer;
begin
  for ���:=1 to stepTopActive do
  with stepActive[���] do
    if (���=nom)and(���=ind) then return end;
  end end;
  if stepTopActive=maxStepActive
    then mbS(_�������_�����_�����_��������[envER])
    else inc(stepTopActive)
  end;
  with stepActive[stepTopActive] do
    nom:=���;
    ind:=���;
    buf:=memAlloc(5);
    with WinHeader,tbMod[���] do
      ����������������������(���DebugBreak,stepProcess,
        address(������������Break(���,genStep^[���].source)),buf);
    end
  end;
end �������������Break;

//------------- ������ Break �� stepActive -----------------

procedure ����������Break(���:integer);
var ���,�����,�����:integer;
begin
  if ���>stepTopActive then mbS(_���������_������_�_����������Break[envER])
  else with stepActive[���],tbMod[nom].genStep^[ind] do
    �����:=������������Break(nom,source);
    WriteProcessMemory(stepProcess,address(�����),buf,5,addr(�����));
    FlushInstructionCache(stepProcess,address(�����),5);
    memFree(buf);
    for ���:=��� to stepTopActive-1 do
      stepActive[���]:=stepActive[���+1];
    end;
    dec(stepTopActive)
  end end
end ����������Break;

//------------- ���������� Break (�� stepActive) �� ������ -----------------

procedure �������������Break(���������:boolean):integer;
var ���,���:integer;
begin
  if ���������
    then ���:=������������������������(stepProcess,stepThread,0)
    else ���:=������������������������(stepProcess,stepThread,0)-5
  end;
  for ���:=1 to stepTopActive do
  with stepActive[���],tbMod[nom].genStep^[ind] do
  if ������������Break(nom,source)=��� then
    return ���
  end end end;
  return 0
end �������������Break;

//------------- ���������� ����� �������� -----------------

procedure �������������Break(���,���:integer; �������:boolean);
var ���,���,�������,�������,�����:integer; p:pID;
begin
  with tbMod[���],genStep^[���] do
  case Class of
    stepSimple:if ���+1<=topGenStep then �������������Break(���,���+1) end;| //������� ��������
    stepCALL: //����� ���������
    p:=proc;
    with p^ do
      if not(������� and(idNom<=topt)) then
        if ���<topGenStep then �������������Break(���,���+1) end;
      else
        if ������� and(idNom<=topt) then
          �������:=0;
          for ���:=1 to tbMod[idNom].topGenStep do
          if tbMod[idNom].genStep^[���].source=idProcAddr then
            �������:=���;
          end end;
          if �������=0 then mbS(_������_������_�����_�����[envER]) end;
          �������������Break(idNom,�������)
        end
      end
    end;|
    stepRETURN://������� �� ���������
      with tbMod[stepCarNom] do
        p:=������������(modTab,genStep^[stepCarInd].source);
        for ���:=stepTopActive downto 1 do
        with stepActive[���] do
        if (p<>nil)and(source>=p^.idProcAddr)and(source<p^.idProcAddr+p^.idProcCode) then
          ����������Break(���)
        end end end;
      end;
      �����:=������������������������(stepProcess,stepThread);
      �������:=0;
      for ���:=1 to topMod do
      for ���:=1 to tbMod[���].topGenStep do
      if ������������Break(���,tbMod[���].genStep^[���].source)=����� then
        �������:=���;
        �������:=���;
      end end end;
      if �������=0
        then mbS(_������_������_�����_��������[envER])
        else �������������Break(�������,�������);
      end;|
    stepIF://�������� ��������
      ���:=���+1;
      while (���<=topGenStep)and not((genStep^[���].Class=stepEndIF)and(genStep^[���].level=level)) do
        if (genStep^[���].Class=stepVarIF)and(genStep^[���].level=level+1) then
          �������������Break(���,���);
        end;
        inc(���)
      end;
      if (genStep^[���].Class=stepEndIF)and(genStep^[���].level=level)
        then �������������Break(���,���)
        else mbS(_���������_�_�������������Break__1_[envER])
      end;|
    stepCASE://�������� ������
      ���:=���+1;
      while (���<=topGenStep)and not((genStep^[���].Class=stepEndCASE)and(genStep^[���].level=level)) do
        if (genStep^[���].Class=stepVarCASE)and(genStep^[���].level=level+1) then
          �������������Break(���,���)
        end;
        inc(���)
      end;
      if (genStep^[���].Class=stepEndCASE)and(genStep^[���].level=level)
        then �������������Break(���,���)
        else mbS(_���������_�_�������������Break__2_[envER])
      end;|
    stepFOR://���� FOR
      ���:=���+1;
      while (���<=topGenStep)and not((genStep^[���].Class=stepEndFOR)and(genStep^[���].level=level)) do
        if (genStep^[���].Class in [stepBegFOR,stepModFOR])and(genStep^[���].level=level+1) then
          �������������Break(���,���)
        end;
        inc(���)
      end;
      if (genStep^[���].Class=stepEndFOR)and(genStep^[���].level=level)
        then �������������Break(���,���)
        else mbS(_���������_�_�������������Break__3_[envER])
      end;|
    stepBegFOR:if ���+2<=topGenStep then �������������Break(���,���+2) end;
      ���:=���+1;
      while (���<=topGenStep)and not((genStep^[���].Class=stepModFOR)and(genStep^[���].level=level)) do
        inc(���)
      end;
      if (genStep^[���].Class=stepModFOR)and(genStep^[���].level=level)
        then �������������Break(���,���)
        else mbS(_���������_�_�������������Break__3_[envER])
      end;|
    stepModFOR:
      ���:=���-1;
      while (���>0)and not((genStep^[���].Class=stepBegFOR)and(genStep^[���].level=level)) do
        dec(���)
      end;
      if (genStep^[���].Class=stepBegFOR)and(genStep^[���].level=level) then
        �������������Break(���,���)
      end;|
    stepWHILE://���� WHILE
      ���:=���+1;
      while (���<=topGenStep)and not((genStep^[���].Class=stepEndWHILE)and(genStep^[���].level=level)) do
        if (genStep^[���].Class in [stepBegWHILE,stepModWHILE])and(genStep^[���].level=level+1) then
          �������������Break(���,���)
        end;
        inc(���)
      end;
      if (genStep^[���].Class=stepEndWHILE)and(genStep^[���].level=level)
        then �������������Break(���,���)
        else mbS(_���������_�_�������������Break__4_[envER])
      end;|
    stepBegWHILE:if ���+2<=topGenStep then �������������Break(���,���+2) end;
      ���:=���+1;
      while (���<=topGenStep)and not((genStep^[���].Class=stepModWHILE)and(genStep^[���].level=level)) do
        inc(���)
      end;
      if (genStep^[���].Class=stepModWHILE)and(genStep^[���].level=level)
        then �������������Break(���,���)
        else mbS(_���������_�_�������������Break__4_[envER])
      end;|
    stepModWHILE:
      ���:=���-1;
      while (���>0)and not((genStep^[���].Class=stepBegWHILE)and(genStep^[���].level=level)) do
        dec(���)
      end;
      if (genStep^[���].Class=stepBegWHILE)and(genStep^[���].level=level)
        then �������������Break(���,���)
        else mbS(_���������_�_�������������Break__4_[envER])
      end;|
    stepREPEAT:if ���+2<=topGenStep then �������������Break(���,���+2) end;|//���� REPEAT
    stepModREPEAT:
      �������������Break(���,���+1);
      ���:=���-1;
      while (���>0)and not((genStep^[���].Class=stepREPEAT)and(genStep^[���].level=level)) do
        if (genStep^[���].Class=stepREPEAT)and(genStep^[���].level=level-1) then
          �������������Break(���,���)
        end;
        dec(���)
      end;|
  end end
end �������������Break;

//------------- ���������� ����� �������� (� ��������� �������) -----------------

procedure �������������Breaks(���,���:integer; �������:boolean);
begin
  with tbMod[���],genStep^[���] do
    if (���>1)and(genStep^[���-1].source=source) then
      �������������Break(���,���-1,�������)
    end;
    �������������Break(���,���,�������);
    if (���<topGenStep)and(genStep^[���+1].source=source) then
      �������������Break(���,���+1,�������)
    end;
  end
end �������������Breaks;

//------------- ������� �������������� ����� �������� -----------------

procedure ����������������Break(���,���:integer);
var ���:integer;
begin
  with tbMod[���],genStep^[���] do
  case Class of
    stepEndIF:
      for ���:=stepTopActive downto 1 do
      with stepActive[���] do
      if (nom=���)and(genStep^[ind].Class in[stepVarIF])and(level=genStep^[ind].level+1)or
        (nom=���)and(genStep^[ind].Class in[stepIF])and(level=genStep^[ind].level) then
        ����������Break(���)
      end end end;|
    stepEndCASE:
      for ���:=stepTopActive downto 1 do
      with stepActive[���] do
      if (nom=���)and(genStep^[ind].Class in[stepVarCASE])and(level=genStep^[ind].level+1)or
        (nom=���)and(genStep^[ind].Class in[stepCASE])and(level=genStep^[ind].level) then
        ����������Break(���)
      end end end;|
    stepEndFOR:
      for ���:=stepTopActive downto 1 do
      with stepActive[���] do
      if (nom=���)and(genStep^[ind].Class in[stepBegFOR,stepModFOR])and(level=genStep^[ind].level+1)or
        (nom=���)and(genStep^[ind].Class in[stepFOR])and(level=genStep^[ind].level) then
        ����������Break(���)
      end end end;|
    stepEndWHILE:
      for ���:=stepTopActive downto 1 do
      with stepActive[���] do
      if (nom=���)and(genStep^[ind].Class in[stepBegWHILE,stepModWHILE])and(level=genStep^[ind].level+1)or
        (nom=���)and(genStep^[ind].Class in[stepWHILE])and(level=genStep^[ind].level) then
        ����������Break(���)
      end end end;|
    stepEndREPEAT:
      for ���:=stepTopActive downto 1 do
      with stepActive[���] do
      if (nom=���)and(genStep^[ind].Class in[stepModREPEAT])and(level=genStep^[ind].level+1)or
        (nom=���)and(genStep^[ind].Class in[stepREPEAT])and(level=genStep^[ind].level) then
        ����������Break(���)
      end end end;|
  end end
end ����������������Break;

//------------- ������� �������������� ����� �������� (� ������ �������) -----------------

procedure ����������������Breaks(���,���:integer);
begin
  with tbMod[���],genStep^[���] do
    if (���>1)and(genStep^[���-1].source=source) then
      ����������������Break(���,���-1)
    end;
    ����������������Break(���,���);
    if (���<topGenStep)and(genStep^[���+1].source=source) then
      ����������������Break(���,���+1)
    end;
  end
end ����������������Breaks;

//------------- ���������� ������ � ������ Break -----------------

procedure ��������������������Break(���,���:integer);
var ���:string[1000]; ���:integer;
begin
  with tbMod[���],genStep^[���] do
  if ���>topt then
    lstrcpy(���,_�����_����������_����������_�_������__li_�_������_[envER]);
    lstrcat(���,modNam);
    ���:=integer(line);
    wvsprintf(���,���,addr(���));
    mbS(���);
  else
    if (���<>tekt) then
      envSelect(���,0);
    end;
    if frag>1
      then envSetError(���,0,frag-1,line);
      else envSetError(���,0,frag,line);
    end;
    envUpdate(editWnd);
    envSetCaret(tekt);
    envScrSet(tekt);
    envSetStatus(tekt);
    SetActiveWindow(mainWnd);
    EnableWindow(mainWnd,true);
    SetFocus(mainWnd)
  end end;
end ��������������������Break;

//------------- ���������� ������ �������� -----------------

procedure �����������������(code,adr:integer);
var ���,���,������,������,������:integer; ������,�����:string[1000];
begin
//����� ������ �� ������
  ������:=0;
  ������:=0;
  for ���:=1 to topMod do 
  with tbMod[���] do
    for ���:=1 to topGenStep do
    with genStep^[���] do
      if ���=topGenStep
        then ������:=topCode-source
        else ������:=genStep^[���+1].source-source
      end;
      if (adr>=������������Break(���,source))and
        (adr<������������Break(���,source)+������) then
        ������:=���;
        ������:=���;
      end
    end end
  end end;
//���������� ������
  if ������>0 then
    ��������������������Break(������,������);
  end;
//������ ���������
  wvsprintf(������,_������_��������__lx_[envER],addr(code));
  case code of
    EXCEPTION_ACCESS_VIOLATION:lstrcat(������,"(EXCEPTION_ACCESS_VIOLATION)");|
    EXCEPTION_DATATYPE_MISALIGNMENT:lstrcat(������,"(EXCEPTION_DATATYPE_MISALIGNMENT)");|
    EXCEPTION_BREAKPOINT:lstrcat(������,"(EXCEPTION_BREAKPOINT)");|
    EXCEPTION_SINGLE_STEP:lstrcat(������,"(EXCEPTION_SINGLE_STEP)");|
    EXCEPTION_ARRAY_BOUNDS_EXCEEDED:lstrcat(������,"(EXCEPTION_ARRAY_BOUNDS_EXCEEDED)");|
    EXCEPTION_FLT_DENORMAL_OPERAND:lstrcat(������,"(EXCEPTION_FLT_DENORMAL_OPERAND)");|
    EXCEPTION_FLT_DIVIDE_BY_ZERO:lstrcat(������,"(EXCEPTION_FLT_DIVIDE_BY_ZERO)");|
    EXCEPTION_FLT_INEXACT_RESULT:lstrcat(������,"(EXCEPTION_FLT_INEXACT_RESULT)");|
    EXCEPTION_FLT_INVALID_OPERATION:lstrcat(������,"(EXCEPTION_FLT_INVALID_OPERATION)");|
    EXCEPTION_FLT_OVERFLOW:lstrcat(������,"(EXCEPTION_FLT_OVERFLOW)");|
    EXCEPTION_FLT_STACK_CHECK:lstrcat(������,"(EXCEPTION_FLT_STACK_CHECK)");|
    EXCEPTION_FLT_UNDERFLOW:lstrcat(������,"(EXCEPTION_FLT_UNDERFLOW)");|
    EXCEPTION_INT_DIVIDE_BY_ZERO:lstrcat(������,"(EXCEPTION_INT_DIVIDE_BY_ZERO)");|
    EXCEPTION_INT_OVERFLOW:lstrcat(������,"(EXCEPTION_INT_OVERFLOW)");|
    EXCEPTION_PRIV_INSTRUCTION:lstrcat(������,"(EXCEPTION_PRIV_INSTRUCTION)");|
    EXCEPTION_IN_PAGE_ERROR:lstrcat(������,"(EXCEPTION_IN_PAGE_ERROR)");|
    EXCEPTION_ILLEGAL_INSTRUCTION:lstrcat(������,"(EXCEPTION_ILLEGAL_INSTRUCTION)");|
    EXCEPTION_NONCONTINUABLE_EXCEPTION:lstrcat(������,"(EXCEPTION_NONCONTINUABLE_EXCEPTION)");|
    EXCEPTION_STACK_OVERFLOW:lstrcat(������,"(EXCEPTION_STACK_OVERFLOW)");|
    EXCEPTION_INVALID_DISPOSITION:lstrcat(������,"(EXCEPTION_INVALID_DISPOSITION)");|
    EXCEPTION_GUARD_PAGE:lstrcat(������,"(EXCEPTION_GUARD_PAGE)");|
    EXCEPTION_INVALID_HANDLE:lstrcat(������,"(EXCEPTION_INVALID_HANDLE)");|
  end;
  wvsprintf(�����,__��_������__lx_[envER],addr(adr));
  lstrcat(������,�����);
  mbS(������);
end �����������������;

//------------- ���������� ���������� ��������� -----------------

procedure �����������������������();
begin
  SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_��������[envER]));
  ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
end �����������������������;

//------------- �������� � ���������� ������� ������� -----------------

procedure �������������(����:HWND; msg,idTimer,dwTime:cardinal);
var
  de:DEBUG_EVENT;
  �����DebugBreak1:cardinal;
  ���,�����:integer;
begin
  if stepDebugged and WaitForDebugEvent(de,�������������) then
    case de.dwDebugEventCode of
      CREATE_PROCESS_DEBUG_EVENT://������ ������� ��������
        ���������DebugBreak:=true;
        ���DebugBreak1:=true;
        �����������������������();|
      EXIT_PROCESS_DEBUG_EVENT://����� ������� ��������
        ������������();
        ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
        CloseHandle(stepThread);
        CloseHandle(stepProcess);
        if envOldFolder[0]<>'\0' then
          SetCurrentDirectory(envOldFolder);
          envOldFolder[0]:='\0'
        end;|
      EXCEPTION_DEBUG_EVENT://������� �������
        case de.Exception.ExceptionRecord.ExceptionCode of
          EXCEPTION_BREAKPOINT://����� DebugBreak
//            mbX(������������������������(stepProcess,stepThread,0)-5,"������������ Break");
            if ���������DebugBreak then //������� ������� DebugBreak
              ���������DebugBreak:=false;
              SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_��������[envER]));
              ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
            elsif ���DebugBreak1 then //���������� ���������
              ���:=�������������Break(false);
              if ���=0 then /*mbS(_������_�����������_������_���������[envER]);*/ �����������������������();
              else with stepActive[���] do
                �����DebugBreak1:=������������������������(stepProcess,stepThread,0)-5;
                ����������������������(���DebugBreak,stepProcess,address(�����DebugBreak1-5),addr(�������DebugBreak2));
                ����������������������(���Jmp15,stepProcess,address(�����DebugBreak1+5),addr(�������Jmp));
                ���DebugBreak1:=false;
                SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_��������[envER]));
                ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
              end end
            else //������������ ��� (������ DebugBreak � ����)
              ���:=�������������Break(true);
              if ���=0 then /*mbS(_������_�����������_������_���������__2_[envER]);*/ �����������������������();
              else with stepActive[���] do
                FlashWindow(mainWnd,true); Sleep(100); FlashWindow(mainWnd,false); Sleep(100); FlashWindow(mainWnd,false);
                �����DebugBreak1:=������������������������(stepProcess,stepThread,0);
                WriteProcessMemory(stepProcess,address(�����DebugBreak1-5),addr(�������DebugBreak2),5,addr(�����));
                WriteProcessMemory(stepProcess,address(�����DebugBreak1+5),addr(�������Jmp),5,addr(�����));
                FlushInstructionCache(stepProcess,address(�����DebugBreak1-5),15);
                stepCarNom:=nom;
                stepCarInd:=ind;
                ����������Break(���);
                ����������������Breaks(stepCarNom,stepCarInd);
                ��������������������Break(stepCarNom,stepCarInd);
                SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_�������[envER]));
              end end;
              ���DebugBreak1:=true;
            end;|
        else with de.Exception.ExceptionRecord do �����������������(ExceptionCode,integer(ExceptionAddress)) end; //������ ��������
        end;|
    else ContinueDebugEvent(stepProcessId,stepThreadId,DBG_EXCEPTION_NOT_HANDLED); //������ �������
    end
  end
end �������������;

//------------- ������������ ������� -----------------

procedure ���������������(��������:pstr);
var si:STARTUPINFO; pi:PROCESS_INFORMATION;
begin
  if stepDebugged then mbS(_���������_������_�_���������������[envER]) end;
  with si do
    RtlZeroMemory(addr(si),sizeof(STARTUPINFO));
    cb:=sizeof(STARTUPINFO);
  end;
  if CreateProcess(nil,��������,nil,nil,false,DEBUG_PROCESS,nil,nil,si,pi) then
    stepDebugged:=true;
    stepProcess:=pi.hProcess;
    stepThread:=pi.hThread;
    stepProcessId:=pi.dwProcessId;
    stepThreadId:=pi.dwThreadId;
    stepTopActive:=0;
    DebugActiveProcess(stepProcessId);
    stepTimer:=SetTimer(0,0,�������������,addr(�������������));
    if stepTimer=0 then mbS(_�������_��������_�������_�������[envER]) end;
  else MessageBox(mainWnd,��������,_�������_�������_�����_[envER],0)
  end;
end ���������������;

//------------- ��������� ������� -----------------

procedure ������������();
var si:STARTUPINFO; ���:integer;
begin
  if not stepDebugged then mbS(_���������_������_�_������������[envER]) end;
  KillTimer(0,stepTimer);
  for ���:=stepTopActive downto 1 do
    ����������Break(���);
  end;
  if stepWnd<>0 then DestroyWindow(stepWnd) end;
  stepDebugged:=false;
  SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),0);
//  mbS(_�����_�������_��������[envER])
end ������������;

//------------- ������ ������� -----------------

procedure ���������();
var execPath,carFolder:string[maxText]; mai:integer;
begin
  if envTransAll(false,false) then
    if mait=0
      then mai:=tekt
      else mai:=mait
    end;
    genExeName(txts[txtn[mai]][mai].txtTitle,envExeFolder,execPath,false);
    if envExeFolder[0]<>'\0' then
      lstrcpy(carFolder,execPath);
      while (lstrlen(carFolder)>0)and(carFolder[lstrlen(carFolder)-1]<>'\') do
        lstrdel(carFolder,lstrlen(carFolder)-1,1)
      end;
      GetCurrentDirectory(300,envOldFolder);
      SetCurrentDirectory(carFolder);
    end;
    if lstrposc(':',txts[txtn[mai]][mai].txtTitle)=-1 then
      ���������������(execPath);
    end
  end
end ���������;

//------------- �������� ������ � ���������� -----------------

procedure �����������(���,������:pstr; ����:integer);
var ���:integer;
begin
  for ���:=0 to lstrlen(������)-1 do
  if lstrlen(���)<���� then
    lstrcatc(���,������[���])
  end end
end �����������;

//------------- ��������� ������ �� ������ �������� -----------------

procedure �����������������(�������:HANDLE; �����:address; ��������:pstr; ������:integer);
//var �:integer; ���,���2:string[100];
begin
//  �:=_lopen("ReadPro.txt",OF_WRITE);
//  _llseek(�,0,2);
//  wvsprintf(���,"%lx",addr(�����));
//  wvsprintf(���2,":%li\13\10",addr(������));
//  lstrcat(���,���2);
//  _lwrite(�,addr(���),lstrlen(���));
//  _lclose(�);
  if (integer(�����)=0)or((integer(�����) and 0xFF000000)<>0) then stepErrorRead:=true end;
  if stepErrorRead then RtlZeroMemory(��������,������)
  else
    if not ReadProcessMemory(�������,�����,��������,������,nil) then
      RtlZeroMemory(��������,������);
      stepErrorRead:=true
    end
  end
end �����������������;

//------------- ��������� �������� ��������� -----------------

procedure ����������������(���:pID; �����:integer; ���:pstr);
var ���������:boolean; ���:integer;
begin
with ���^ do
  if (idClass=idtBAS)and(idBasNom=typePSTR) then //PSTR
    ���������:=false;
    for ���:=0 to maxLoadPSTR do
    if not ��������� then
      �����������������(stepProcess,address(�����+���),addr(���[���]),1);
      ���������:=���[���]='\0'
    end end;
    if not ��������� then
      ���[maxLoadPSTR-1]:='\0';
    end
  elsif idClass=idtPOI then //POINTER TO
    �����������������(stepProcess,address(�����),���,idPoiType^.idtSize);
  else mbS("System error in otlZagrUkazatel")
  end;
end
end ����������������;

//------------- ������������� �������� � ����� -----------------

procedure ������������(���:pID; ��������:pstr; ���:pstr; ����,�������:integer);
var ���:string[100]; ���,���,���:integer; ���:real; ���32:real32; ���:pstr; ���������:boolean;
begin
with ���^ do
  if �������>maxDebLevel then
    ���[0]:='\0';
    return
  end;
  ���:=memAlloc(����);
  case idClass of
    idtBAS:case idBasNom of
      typeBYTE:���:=0; RtlMoveMemory(addr(���),��������,1); if stepHexdec then wvsprintf(���,"%lx",addr(���)) else wvsprintf(���,"%lu",addr(���)) end;|
      typeCHAR:if stepHexdec then ���:=0; RtlMoveMemory(addr(���),��������,1); wvsprintf(���,"%lx",addr(���)) else lstrcpy(���,"'"); lstrcatc(���,��������[0]); lstrcat(���,"'") end;|
      typeWORD:���:=0; RtlMoveMemory(addr(���),��������,2); if stepHexdec then wvsprintf(���,"%lx",addr(���)) else wvsprintf(���,"%lu",addr(���)) end;|
      typeBOOL:if integer(��������[0])=0 then lstrcpy(���,"false") else lstrcpy(���,"true") end;|
      typeINT:RtlMoveMemory(addr(���),��������,4); if stepHexdec then wvsprintf(���,"%lx",addr(���)) else wvsprintf(���,"%li",addr(���)) end;|
      typeDWORD:RtlMoveMemory(addr(���),��������,4); if stepHexdec then wvsprintf(���,"%lx",addr(���)) else wvsprintf(���,"%lu",addr(���)) end;|
      typePOINT:RtlMoveMemory(addr(���),��������,4); wvsprintf(���,"%lx",addr(���));|
      typePSTR:if stepHexdec then RtlMoveMemory(addr(���),��������,4); wvsprintf(���,"%lx",addr(���));
      else
        envInf("pstr",nil,0);
        RtlMoveMemory(addr(���),��������,4);
        ����������������(���,���,���);
        lstrcpy(���,""); lstrcatc(���,'"'); lstrcat(���,���); lstrcatc(���,'"');
      end;|
      typeSET:
        envInf("setbyte",nil,0);
        lstrcpy(���,"[");
        for ���:=0 to 7 do
        for ���:=0 to 7 do
        if ((integer(��������[���])<<���)and 0x1)<>0 then
          ���:=���*8+���;
          wvsprintf(���,"%lu ",addr(���));
          lstrcat(���,���);
        end end end;
        lstrcat(���,"]");|
      typeREAL32:RtlMoveMemory(addr(���32),��������,4); wvsprinte(real(���32),���);|
      typeREAL:RtlMoveMemory(addr(���),��������,8); wvsprinte(���,���);|
    end;|
    idtARR:
    if (idArrItem^.idClass=idtBAS)and(idArrItem^.idBasNom=typeCHAR) then
      envInf("string",nil,0);
      lstrcpyn(���,��������,extArrEnd-extArrBeg);
      ���[extArrEnd-extArrBeg]:='\0';
      lstrinsc('"',���,0);
      lstrcatc(���,'"');
    else
      envInf("array",nil,0);
      lstrcpy(���,"");
      ���������:=true;
      for ���:=extArrBeg to extArrEnd do
      if ��������� then
        �����������(���,"\13\10",����);
        for ���:=1 to ������� do
          �����������(���,"  ",����);
        end;
        wvsprintf(���,"%lu:",addr(���));
        �����������(���,���,����);
        ������������(idArrItem,addr(��������[idArrItem^.idtSize*(���-extArrBeg)]),���,����,�������+1);
        ���������:=lstrlen(���)+lstrlen(���)<����;
        �����������(���,���,����);
      end end
    end;|
    idtREC:
      envInf("record",nil,0);
      lstrcpy(���,"");
      for ���:=1 to idRecMax do
        �����������(���,"\13\10",����);
        for ���:=1 to ������� do
          �����������(���,"  ",����);
        end;
        lstrcpy(���,idRecList^[���]^.idName);
        lstrdel(���,0,lstrposc('.',���)+1);
        lstrcatc(���,':');
        �����������(���,���,����);
        ������������(idRecList^[���]^.idVarType,addr(��������[idRecList^[���]^.idVarAddr]),���,����,�������+1);
        �����������(���,���,����);
      end;|
    idtPOI:if stepHexdec then RtlMoveMemory(addr(���),��������,4); wvsprintf(���,"%lx",addr(���));
    else
      envInf("pointer",nil,0);
      RtlMoveMemory(addr(���),��������,4);
      ���:=memAlloc(idPoiType^.idtSize);
      ����������������(���,���,���);
      ������������(idPoiType,���,���,����,�������+1);
      memFree(���);
    end;|
    idtSET:
      envInf("set",nil,0);
      lstrcpy(���,"[");
      for ���:=0 to 7 do
      for ���:=0 to 7 do
      if ((integer(��������[���])<<���)and 0x1)<>0 then
        ���:=���*8+���;
        if idSetType^.idClass=idtSCAL
          then wvsprintf(���,"%s ",idScalList^[���+1]^.idName);
          else wvsprintf(���,"%lu ",addr(���));
        end;
        lstrcat(���,���);
      end end end;
      lstrcat(���,"]");|
    idtSCAL:
      envInf("scalar",nil,0);
      ���:=0;
      if idtSize=1
        then RtlMoveMemory(addr(���),��������,1)
        else RtlMoveMemory(addr(���),��������,4)
      end;
      if stepHexdec then wvsprintf(���,"%lx",addr(���));
      else
        if (���+1>=1)and(���+1<=idScalMax)
          then lstrcpy(���,idScalList^[���+1]^.idName);
          else wvsprintf(���,"%lu",addr(���));
        end;
      end;|
  end;
  memFree(���)
end
end ������������;

//------------- ������ � �������� ���������� -----------------

procedure ���������(var ���:pID; var �����:integer; ������:pstr):boolean;
var ����,���,���:integer; ������:boolean; ������:integer; ����:string[1000];
begin
  ����:=0;
  ������:=false;
  while not ������ and(������[����] in ['[','^','.']) do
  case ������[����] of
    '[':if ���^.idClass<>idtARR then return false end;
      ������:=0;
      inc(����);
      while ������[����] in ['0'..'9'] do
        ������:=������*10+integer(������[����])-integer('0');
        inc(����);
      end;
      ������:=������[����]<>']';
      inc(����);
      �����:=�����+(������-���^.extArrBeg)*���^.idArrItem^.idtSize;
      ���:=���^.idArrItem;|
    '^':if ���^.idClass<>idtPOI then return false end;
      inc(����);
      ���:=���^.idPoiType;
      �����������������(stepProcess,address(�����),addr(�����),4);
      ������:=stepErrorRead;|
    '.':if ���^.idClass<>idtREC then return false end;
      ����[0]:='\0';
      inc(����);
      while ������[����] in ['0'..'9','A'..'Z','a'..'z','�'..'�','�'..'�','_','$'] do
        lstrcatc(����,������[����]);
        inc(����);
      end;
      lstrinsc('.',����,0);
      lstrins(���^.idName,����,0);
      ���:=0;
      for ���:=1 to ���^.idRecMax do
      if lstrcmpi(����,���^.idRecList^[���]^.idName)=0 then
        ���:=���
      end end;
      if ���=0 then ������:=true
      else
        �����:=�����+���^.idRecList^[���]^.idVarAddr;
        ���:=���^.idRecList^[���]^.idVarType;
      end;|
  end end;
  return not ������ and(������[����]='\0')
end ���������;

//------------- �������� ���������� � ����� -----------------

procedure ��������������(���,���:pstr; ����:integer; ����:pID; ������:pstr);
var ��,���:pID; �����,���:integer; ��������:pstr;
begin
  ���[0]:='\0';
  with tbMod[stepCarNom] do
  if ����<>nil then
    ��:=nil;
    for ���:=1 to ����^.idLocMax do
      if lstrcmpi(���,����^.idLocList^[���]^.idName)=0 then
        ��:=����^.idLocList^[���]
      end
    end;
    for ���:=1 to ����^.idProcMax do
      if lstrcmpi(���,����^.idProcList^[���]^.idName)=0 then
        ��:=����^.idProcList^[���]
      end
    end;
    if ��=nil then mbS("������ ������ ��������� ����������"); return end;
    �����:=��^.idVarAddr+�������������������BP(stepProcess,stepThread);
  else
    ��:=idFindGlo(���,false);
    if ��=nil then mbS("������ ������ ���������� ����������"); return end;
    �����:=genBASECODE+0x1000+tbMod[��^.idNom].genBegData+��^.idVarAddr;
  end end;
  ���:=��^.idVarType;
  envInfBegin(_������_��������_����������[envER],"");
  stepErrorRead:=false;
  if ���������(���,�����,������) then
    ��������:=memAlloc(���^.idtSize);
    �����������������(stepProcess,address(�����),��������,���^.idtSize);
    ������������(���,��������,���,����,0);
    memFree(��������);
  end;
  envInfEnd();
  if stepErrorRead then mbS(_������_������_������_��������[envER]) end;
end ��������������;

//------------- ��������� ���������� � listbox -----------------

procedure �����������������(���:pID; listbox:HWND);
begin
  if ���=nil then return end;
  with ���^ do
    if idClass=idvVAR then
      SendMessage(listbox,LB_ADDSTRING,0,integer(idName));
    end;
    �����������������(idLeft,listbox);
    �����������������(idRight,listbox);
  end
end �����������������;

//------------- ��������� ������ ���������� � listbox -----------------

procedure �����������������(listbox:HWND; ���������:boolean);
var ���:integer; ����:pID;
begin
  SendMessage(listbox,LB_RESETCONTENT,0,0);
  if ��������� then
    for ���:=1 to topMod do
      �����������������(tbMod[���].modTab,listbox);
    end
  else with tbMod[stepCarNom] do
    ����:=������������(modTab,genStep^[stepCarInd].source);
    if ����<>nil then
      for ���:=1 to ����^.idProcMax do
        SendMessage(listbox,LB_ADDSTRING,0,integer(����^.idProcList^[���]^.idName));
      end;
      for ���:=1 to ����^.idLocMax do
        SendMessage(listbox,LB_ADDSTRING,0,integer(����^.idLocList^[���]^.idName));
      end;
    end
  end end
end �����������������;

//------------- ������ ������ ���������� -----------------

const
  �������������=100;
  ����������=101;
  �����������=102;
  ����������=103;
  �����������=104;
  �������������=105;
  �������=5;

const DLG_DEB=stringER{"DLG_DEB_R","DLG_DEB_E"};
dialog DLG_DEB_R 114,26,176,186,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_VISIBLE | WS_BORDER | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "�������� ����������"
begin
  control "",�������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_VSCROLL,76,2,93,180
  control "",�����������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY | LBS_SORT | WS_VSCROLL,8,42,52,66
  control "",����������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY | WS_VSCROLL | LBS_SORT,8,110,52,72
  control "��������",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,7,29,63,12
  control "",�����������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,7,16,63,12
  control "��������",�������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,7,2,63,12
end;
dialog DLG_DEB_E 114,26,176,186,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_VISIBLE | WS_BORDER | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "Variables value"
begin
  control "",�������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY | WS_VSCROLL,76,2,93,120
  control "",�����������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY | LBS_SORT | WS_VSCROLL,8,42,52,66
  control "",����������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY | WS_VSCROLL | LBS_SORT,8,110,52,72
  control "Hexdec",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,7,29,63,12
  control "",�����������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,7,16,63,12
  control "View",�������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,7,2,63,12
end;

procedure procDLG_DEB(wnd:HWND; message,wparam,lparam:integer):boolean;
var ���,������:string[1000]; ����:pID; ���:pstr; ���,���,����,����:integer; ����,���:RECT;
begin
  case message of
    WM_INITDIALOG:
      SendDlgItemMessage(wnd,�����������,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
      SendDlgItemMessage(wnd,����������,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
      SendDlgItemMessage(wnd,�������������,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);|
    WM_SIZE:
      ���:=loword(lparam);
      ����:=hiword(lparam);
      GetWindowRect(wnd,����);
      GetWindowRect(GetDlgItem(wnd,�����������),���);
      ����:=(����-(���.top-����.top)-2) div 2;
      SetWindowPos(GetDlgItem(wnd,�����������),0,0,0,���.right-���.left,����,SWP_NOMOVE);
      SetWindowPos(GetDlgItem(wnd,����������),0,���.left-����.left-1,���.top-����.top+����,���.right-���.left,����,0);
      GetWindowRect(GetDlgItem(wnd,�������������),���);
      SetWindowPos(GetDlgItem(wnd,�������������),0,0,0,���-(���.left-����.left)-�������*2,����-�������*2,SWP_NOMOVE);|
    WM_SETFOCUS:
      �����������������(GetDlgItem(wnd,�����������),true);
      �����������������(GetDlgItem(wnd,����������),false);
      SendMessage(stepLastWnd,LB_SETCURSEL,stepLastLine,0);|
    WM_COMMAND:case loword(wparam) of
      ����������:
        stepHexdec:=not stepHexdec;
        SendMessage(wnd,WM_COMMAND,BN_CLICKED*0x10000+�������������,0);|
      �����������,����������:if hiword(wparam)=LBN_SELCHANGE then
        stepLastWnd:=GetDlgItem(wnd,loword(wparam));
        stepLastLine:=SendMessage(stepLastWnd,LB_GETCURSEL,0,0);
        SendMessage(wnd,WM_COMMAND,BN_CLICKED*0x10000+�������������,0);
      end;|
      �������������:if hiword(wparam)=BN_CLICKED then
        SendMessage(stepLastWnd,LB_GETTEXT,stepLastLine,integer(addr(���)));
        if ���[0]<>'\0' then
          ���:=memAlloc(maxLoadVAR);
          if stepLastWnd=GetDlgItem(wnd,�����������)
            then ����:=nil
            else with tbMod[stepCarNom] do ����:=������������(modTab,genStep^[stepCarInd].source) end;
          end;
          if (����=nil)and(loword(wparam)=����������) then mbS("System error in procDLG_DEB")
          else
            GetDlgItemText(wnd,�����������,������,1000);
            ��������������(���,���,maxLoadVAR,����,������);
            SendDlgItemMessage(wnd,�������������,WM_SETTEXT,0,integer(���));
          end;
          memFree(���);
        end
      end;|
      IDOK:EndDialog(wnd,1); stepWnd:=0;|
      IDCANCEL:EndDialog(wnd,0); stepWnd:=0;|
    end;|
    WM_DESTROY:stepWnd:=0;|
  else return false
  end;
  return true
end procDLG_DEB;

//------------- ��������� ��� ���������� -----------------

procedure envDebRun();
var execPath:string[maxText]; mai:integer;
begin
  if stepDebugged then
    mbS(_��������_���_�������[envER]);
    return;
  end;
  ���������();
  stepCarNom:=genEntryNo;
  stepCarInd:=genEntryStep+1;
  �������������Break(stepCarNom,stepCarInd);
  SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_��������[envER]));
end envDebRun;

//------------- ��������� ����� -----------------

procedure envDebRunEnd();
var ���:integer;
begin
  if not stepDebugged then
    mbS(_��������_��_�������[envER]);
    return;
  end;
  for ���:=stepTopActive downto 1 do
    ����������Break(���);
  end;
  ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
end envDebRunEnd;

//------------- ��������� ������� -----------------

procedure envDebEnd();
begin
  if not stepDebugged then
    mbS(_��������_��_�������[envER]);
    return;    
  end;
  TerminateProcess(stepProcess,0);
  SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),0);
end envDebEnd;

//------------- ��������� ��� � ������ � ��������� -----------------

procedure envDebNextDown();
begin
  if not stepDebugged then envDebRun()
  else
    �������������Breaks(stepCarNom,stepCarInd,true);
    SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_��������[envER]));
    ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
    SendMessage(stepWnd,WM_COMMAND,BN_CLICKED*0x10000+�������������,0);
  end;
end envDebNextDown;

//------------- ��������� ��� ��� ����� � ��������� -----------------

procedure envDebNext();
begin
  if not stepDebugged then envDebRun()
  else
    �������������Breaks(stepCarNom,stepCarInd,false);
    SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_��������[envER]));
    ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
    SendMessage(stepWnd,WM_COMMAND,BN_CLICKED*0x10000+�������������,0);
  end;
end envDebNext;

//------------- ������� � ������� ������ -----------------

procedure envDebGoto();
var ���:integer;
begin
  if not stepDebugged then
    ���������();
    if not stepDebugged then
      mbS(_��������_��_�������[envER]);
      return;
    end;
  end;
  stepCarNom:=tekt;
  stepCarInd:=0;
  with tbMod[tekt],txts[0][tekt] do
  for ���:= topGenStep downto 1 do
  if (txtn[tekt]=0)and(txtTrackY+txtCarY=cardinal(genStep^[���].line)) then
    stepCarInd:=���;
  end end end;
  if stepCarInd=0 then mbS(_���_����_���_�������_������[envER])
  else
    for ���:=stepTopActive downto 1 do
      ����������Break(���)
    end;
    �������������Break(stepCarNom,stepCarInd);
    SendMessage(wndStatus,SB_SETTEXT,ord(staDeb),cardinal(_��������[envER]));
    ContinueDebugEvent(stepProcessId,stepThreadId,DBG_CONTINUE);
    SendMessage(stepWnd,WM_COMMAND,BN_CLICKED*0x10000+�������������,0);
  end
end envDebGoto;

//------------- �������� �������� ���������� -----------------

procedure envDebView();
begin
  if stepDebugged then
    if stepWnd=0 then
      stepWnd:=CreateDialogParam(hINSTANCE,DLG_DEB[envER],mainWnd,addr(procDLG_DEB),0);
    end;
    SetFocus(stepWnd)
  end
end envDebView;

//===============================================
//             ���� ����� � ������
//===============================================

const
  idc_FindStr=510;
  idc_ReplStr=520;
  idc_BegCheck=530;
  idc_RegCheck=540;
  idc_RegUp=541;
  idc_RegDn=542;

//------------- ������ ������ -----------------

const DLG_FIND=stringER{"DLG_FIND_R","DLG_FIND_E"};
dialog DLG_FIND_R 73,45,170,67,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "�����"
begin
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,10,6,27,9
  control "",510,"Combobox",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | CBS_DROPDOWN,39,4,126,100
  control "",530,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,24,6,7
  control "����� � ������ ������",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,24,85,7
  control "",540,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,34,6,7
  control "��������� ������� ����",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,34,85,7
  control "������",550,"Button",0 | WS_CHILD | WS_VISIBLE,34,52,45,11
  control "��������",560,"Button",0 | WS_CHILD | WS_VISIBLE,89,52,45,11
end;
dialog DLG_FIND_E 73,45,170,67,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Find"
begin
  control "Text:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,10,6,27,9
  control "",510,"Combobox",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | CBS_DROPDOWN,39,4,126,100
  control "",530,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,24,6,7
  control "Search from a beginning of the text",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,24,85,7
  control "",540,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,34,6,7
  control "Case sensitive",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,34,85,7
  control "Begin",550,"Button",0 | WS_CHILD | WS_VISIBLE,34,52,45,11
  control "Cancel",560,"Button",0 | WS_CHILD | WS_VISIBLE,89,52,45,11
end;

//------------- ������ ������ � ������ -----------------

const DLG_REPL=stringER{"DLG_REPL_R","DLG_REPL_E"};
dialog DLG_REPL_R 73,45,170,83,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "����� � ������"
begin
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,25,7,27,9
  control "",510,"Combobox",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | CBS_DROPDOWN,54,6,112,100
  control "",530,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,40,6,7
  control "����� � ������ ������",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,40,85,7
  control "",540,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,50,6,7
  control "��������� ������� ����",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,50,85,7
  control "������",550,"Button",0 | WS_CHILD | WS_VISIBLE,34,68,45,11
  control "��������",560,"Button",0 | WS_CHILD | WS_VISIBLE,89,68,45,11
  control "",520,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,55,19,109,10
  control "�������� ��:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,6,20,46,8
  control "� ������",idc_RegDn,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,120,46,40,12
  control "� �������",idc_RegUp,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,120,32,40,12
end;
dialog DLG_REPL_E 73,45,170,83,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Find and replace"
begin
  control "Text:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,25,7,27,9
  control "",510,"Combobox",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | CBS_DROPDOWN,54,6,112,100
  control "",520,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,55,19,109,10
  control "Replace to:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,6,20,46,8
  control "",530,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,40,6,7
  control "Search from a beginning of the text",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,40,85,7
  control "",540,"Button",BS_AUTOCHECKBOX | WS_CHILD | WS_VISIBLE | WS_TABSTOP,18,50,6,7
  control "Case sensitive",-1,"Static",0 | WS_CHILD | WS_VISIBLE,28,50,85,7
  control "Begin",550,"Button",0 | WS_CHILD | WS_VISIBLE,34,68,45,11
  control "Cancel",560,"Button",0 | WS_CHILD | WS_VISIBLE,89,68,45,11
  control "To lower",idc_RegDn,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,120,32,40,12
  control "To upper",idc_RegUp,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,120,46,40,12
end;

//------------- ������� ������� ������ -----------------

procedure envFindDlg(Wnd:HWND; Message,wParam,lParam:integer):boolean;
var i:integer; s:string[maxText];
begin
  case Message of
    WM_INITDIALOG:
      SetDlgItemText(Wnd,idc_FindStr,findStr);
      for i:=1 to findTop do
        SendDlgItemMessage(Wnd,idc_FindStr,CB_ADDSTRING,0,integer(findArr[i]));
      end;
      SetDlgItemText(Wnd,idc_ReplStr,findRep);
      if findBeg
        then CheckDlgButton(Wnd,idc_BegCheck,1)
        else CheckDlgButton(Wnd,idc_BegCheck,0)
      end;
      if findReg
        then CheckDlgButton(Wnd,idc_RegCheck,1)
        else CheckDlgButton(Wnd,idc_RegCheck,0)
      end;
      SetFocus(GetDlgItem(Wnd,idc_FindStr));
      SendDlgItemMessage(Wnd,idc_FindStr,EM_SETSEL,0,maxText);|
    WM_COMMAND:case loword(wParam) of
      idc_FindStr:GetDlgItemText(Wnd,idc_FindStr,findStr,maxText);|
      idc_ReplStr:GetDlgItemText(Wnd,idc_ReplStr,findRep,maxText);|
      idc_BegCheck:findBeg:=not findBeg;|
      idc_RegCheck:findReg:=not findReg;|
      idc_RegUp:GetDlgItemText(Wnd,idc_FindStr,s,maxText); CharUpper(s); SetDlgItemText(Wnd,idc_ReplStr,s);|
      idc_RegDn:GetDlgItemText(Wnd,idc_FindStr,s,maxText); CharLower(s); SetDlgItemText(Wnd,idc_ReplStr,s);|
      idc_OkButton:EndDialog(Wnd,1);|
      idc_NoButton:EndDialog(Wnd,0);|
      IDOK:EndDialog(Wnd,1);|
      IDCANCEL:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true
end envFindDlg;

//------------- ����� ��������� ---------------

procedure envEditFind(bitDialog,bitRepl:boolean);
var findObr,findText:string[maxText]; findBox,findBegY,findBegX,i:integer;
begin
  if not bitDialog then findBox:=1
  else with txts[txtn[tekt]][tekt] do
    envGetIdent(findObr,tekt,txtTrackX+txtCarX,txtTrackY+txtCarY);
    if findObr[0]<>char(0) then
      lstrcpy(findStr,findObr);
    end;
    if bitRepl
      then findBox:=DialogBoxParam(hINSTANCE,DLG_REPL[envER],mainWnd,addr(envFindDlg),0)
      else findBox:=DialogBoxParam(hINSTANCE,DLG_FIND[envER],mainWnd,addr(envFindDlg),0)
    end;
    if findBox=-1 then mbS(_������_���_��������_�������[envER]) end
  end end;
  with txts[txtn[tekt]][tekt],txtStrs^ do
    if (findBox=1)and(findStr[0]<>char(0)) then
//���������� ������ ������
      if ((findTop=0)or(lstrcmpi(findStr,findArr[1])<>0))and(findTop<maxFind) then
        for i:=findTop+1 downto 2 do
          findArr[i]:=findArr[i-1];
        end;
        findArr[1]:=memAlloc(lstrlen(findStr)+1);
        lstrcpy(findArr[1],findStr);
        inc(findTop);
      end;
//�������������
      if findBeg and bitDialog
        then findBegX:=1
        else findBegX:=txtTrackX+txtCarX+1
      end;
      if findBeg and bitDialog
        then findBegY:=1
        else findBegY:=txtTrackY+txtCarY
      end;
      lstrcpy(findObr,findStr);
      envFromFrag(findText,arrs[findBegY]);
      if not findReg then
        CharUpper(findObr);
        CharUpper(findText)
      end;
//�����
      while (findBegY<tops)and(lstrposi(findObr,findText,findBegX-1)=-1) do
        inc(findBegY);
        if findBegY<=tops then
          envFromFrag(findText,arrs[findBegY])
        end;
        if not findReg then
          CharUpper(findText)
        end;
        findBegX:=1
      end;
//��������
      if lstrposi(findObr,findText,findBegX-1)=-1 then
        blkSet:=false;
        MessageBox(editWnd,_��������_��_������[envER],"��������:",MB_OK | MB_ICONSTOP)
      else
        envSetPosition(tekt,lstrposi(findObr,findText,findBegX-1)+1,findBegY,lstrlen(findObr));
        envUpdate(editWnd);
      end
    elsif findBox=1 then MessageBox(editWnd,_��_����������_��������_���_������[envER],"��������:",MB_OK | MB_ICONSTOP) 
    end
  end
end envEditFind;

//------------- ����� � ������ -----------------

procedure envEditRepl();
var repText:string[maxText]; i,repMes:integer;
begin
  with txts[txtn[tekt]][tekt],txtStrs^ do
    envEditFind(true,true);
    repMes:=IDNO;
    while blkSet and (repMes<>IDCANCEL) do
      repMes:=MessageBox(editWnd,_��������_��������__[envER],"��������:",MB_YESNOCANCEL | MB_ICONQUESTION);
      if repMes=IDYES then
        envFromFrag(repText,arrs[txtTrackY+txtCarY]);
        lstrdel(repText,txtTrackX+txtCarX-1,blkX-(txtTrackX+txtCarX));
        if lstrlen(repText)+lstrlen(findRep)<maxText then
          for i:=0 to lstrlen(findRep)-1 do
            lstrinsc(findRep[i],repText,txtTrackX+txtCarX-1+i)
        end end;
        envDestroyFrags(arrs[txtTrackY+txtCarY]);
        envToFrag(repText,arrs[txtTrackY+txtCarY]);
        txtMod:=true;
        blkSet:=false;
        envSetPosition(tekt,blkX,blkY,lstrlen(findRep));
        envScrSet(tekt);
        envUpdate(editWnd)
      end;
      if repMes<>IDCANCEL then
        envEditFind(false,true)
      end
    end
  end
end envEditRepl;

//------- ������� ������� --------------

procedure envDlgIns(buf:pstr; begY,endY:integer);
begin
  if buf<>nil then
    if ���������������� then
  //�������� ������� �������
      if (begY>0)and(begY>0) then
      with txts[txtn[tekt]][tekt] do
        txtTrackX:=0;
        txtCarX:=1;
        txtCarY:=begY-txtTrackY;
        blkX:=1;
        blkY:=endY;
        blkSet:=true;
        envUndoPush(undoDelBlock,tekt);
        envEditDel(tekt);
        envUndoBlockEnd(tekt);
      end end;
  //������� ������ �������
      with txts[txtn[tekt]][tekt] do
        txtTrackX:=0;
        txtCarX:=1;
        blkSet:=false;
        envUndoPush(undoInsBlock,tekt);
        envBlockIns(tekt,buf);
        envUndoBlockEnd(tekt);
        txtMod:=true;
      end;
      memFree(buf)
    else
  //������� ������� � clipboard
      if OpenClipboard(editWnd) then
        EmptyClipboard();
        SetClipboardData(CF_TEXT,HANDLE(buf));
        CloseClipboard()
      else
        memFree(buf);
        mbS(_������_Clipboard_�����_������_�����������[envER])
      end
    end
  end
end envDlgIns;

//------- �������������� ������� --------------

procedure envResource(cart:integer);
var s:string[maxText]; i,begY,endY:integer; p:pstr;
begin
if cart<=topt then
with txts[txtn[cart]][cart] do
  with txts[txtn[cart]][cart].txtStrs^.arrs[txtTrackY+txtCarY]^.arrf[1]^ do
    if (cla=fREZ)and(rv=rDIALOG) then //������
      �����������������:=false;
      if not resTxtToDlg(cart,begY,endY)
        then p:=�������������(false); envDlgIns(p,begY,endY);
        else  SetFocus(editWnd)
      end
    elsif (cla=fREZ)and((rv=rBITMAP)or(rv=rICON)) then //bitmap ��� ������
      if resTxtToBmp(cart,s,rv=rBITMAP) then SetFocus(editWnd)
      else
        lstrinsc(' ',s,0);
        for i:=lstrlen(envBMPE)-1 downto 0 do
          lstrinsc(envBMPE[i],s,0)
        end;
        i:=WinExec(s,SW_SHOW);
        if i<=32 then
          MessageBox(0,s,_������_���_�������_���������[envER],MB_ICONSTOP);
          SetFocus(editWnd)
        end
      end
    else //����� ������
      if MessageBox(mainWnd,_�������_�����_������__[envER],"�������",MB_YESNO)=IDYES then
        �����������������:=true;
        p:=�������������(true);
        envDlgIns(p,0,0);
      end
    end
  end
end end
end envResource;

//===============================================
//                 ���� ������
//===============================================

//-------------- ������ � ��������� ------------------

const DLG_ABOUT=stringER{"DLG_ABOUT_R","DLG_ABOUT_E"};
dialog DLG_ABOUT_R 50,23,177,142,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "� ���������"
begin
  control "��",120,"Button",0 | WS_CHILD | WS_VISIBLE,66,129,46,11
  control "�������� ������-��-�������",130,"Static",1 | WS_CHILD | WS_VISIBLE,8,2,161,10
  control "������� 21",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,12,161,10
  control "Freeware",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,22,161,10
  control "��������� ����������� �������",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,41,161,10
  control "����������� ������� ������ �������",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,51,161,10
  control "���������� �� Win32 ������ �� ������ �����",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,62,161,10
  control "���� �������� �.�. � �.�.",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,72,161,10
  control "������, �����,1999-2002",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,88,161,10
  control "home.perm.ru/~strannik",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,104,161,10
  control "e-mail:strannik@mail.perm.ru",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,115,161,10
end;
dialog DLG_ABOUT_E 50,23,177,142,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "About"
begin
  control "Ok",120,"Button",0 | WS_CHILD | WS_VISIBLE,66,129,46,11
  control "STRANNIK Modula-C-Pascal",130,"Static",1 | WS_CHILD | WS_VISIBLE,8,2,161,10
  control "Variant 21",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,12,161,10
  control "Freeware",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,22,161,10
  control "author's software product",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,41,161,10
  control "The programmer Andreev A",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,51,161,10
  control "Russia, Perm,1999-2002",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,88,161,10
  control "home.perm.ru/~strannik",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,104,161,10
  control "e-mail:strannik@mail.perm.ru",-1,"Static",1 | WS_CHILD | WS_VISIBLE,8,115,161,10
end;

//-------------- � ��������� ------------------

const idAboOk=120;

procedure envDlgAbout(Wnd:HWND; Message,wParam,lParam:integer):boolean;
begin
  case Message of
    WM_COMMAND:case loword(wParam) of
      IDOK,idAboOk:EndDialog(Wnd,1);|
      IDCANCEL:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true;
end envDlgAbout;

procedure envAbout();
begin
  DialogBoxParam(hINSTANCE,DLG_ABOUT[envER],mainWnd,addr(envDlgAbout),0);
  SetFocus(editWnd)
end envAbout;

//-------------- ���������� ------------------

procedure envHelp(helpFile:pstr);
begin
  if not WinHelp(mainWnd,helpFile,HELP_CONTENTS,0) then
    MessageBox(0,helpFile,_���_�����[envER],MB_ICONSTOP);
  end;
  SetFocus(editWnd)
end envHelp;

//---------- ����� ������������� --------------

procedure envGetIdent(name:pstr; txt,X,Y:integer);
var i:integer;
begin
with txts[txtn[txt]][txt],txtStrs^ do
  name[0]:='\0';
  if txt>0 then if txtStrs<>nil then if Y<=tops then
  with arrs[Y]^ do
    for i:=1 to topf do
    with arrf[i]^ do
      if (X>=beg)and(X<=beg+len+1)and(cla=fID) then
        lstrcpy(name,txt)
      end
    end end
  end end end end
end
end envGetIdent;

//===============================================
//               ��������������
//===============================================

const
  idc_IdComb=101;
  idc_IdHelp=102;
  idc_IdEdit=103;
  idc_IdLoad=104;
  idc_IdClip=105;
  idc_IdMod=106;
  idc_IdMods=107;
  idc_IdCancel=121;

//------- �������� �������������� ------------

procedure envAddCombo(p:pID; Wnd:HWND);
begin
  if p<>nil then
    envAddCombo(p^.idLeft,Wnd);
    case p^.idClass of
      idcCHAR..idcSTRU,idtBAS,idtARR,idtREC,idtPOI,idtSCAL,idvVAR,idPROC:
        if (p^.idName[0]<>'#')and not((p^.idClass=idtBAS)and
          (lstrcmp(p^.idName,nameTYPE[traLANG][p^.idBasNom])=0)) then
          SendDlgItemMessage(Wnd,idc_IdComb,CB_ADDSTRING,0,integer(p^.idName));
        end;|
    end;
    envAddCombo(p^.idRight,Wnd);
  end
end envAddCombo;

//------- �������� ��������������� ------------

procedure envDlgLoad(Wnd:HWND);
var i:integer;
begin
  if (topMod>=tekt)and(tbMod[tekt].modTab<>nil) then
    envInfBegin(_��������_������_���������������_��_[envER],envWIN32);
    SendDlgItemMessage(Wnd,idc_IdComb,CB_RESETCONTENT,0,0);
    for i:=1 to topMod do
      envAddCombo(tbMod[i].modTab,Wnd);
      envInf(nil,nil,i*100 div topMod);
    end;
    envInfEnd();
  end
end envDlgLoad;

//---- ������������ ������ ������� ------------

procedure envSetModList(id:pID; val:pstr);
var i,j,l:integer;
begin
  val[0]:=char(0);
  for i:=1 to 32 do
    l:=1;
    for j:=1 to i-1 do
      l:=l*2;
    end;
    if l and id^.idSou<>0 then
      lstrcatc(val,' ');
      lstrcat(val,tbMod[i].modNam);
    end
  end
end envSetModList;

//--------- ����� �������������� --------------

procedure envDlgShow(Wnd:HWND);
var name,val:string[maxText]; id:pID; i:cardinal;
begin
  if (topMod<tekt)or(tbMod[tekt].modTab=nil) then
    MessageBox(0,_���_����������__����������__�����������_����������_[envER],"������:",0)
  else
    i:=SendDlgItemMessage(Wnd,idc_IdComb,CB_GETCURSEL,0,0);
    SendDlgItemMessage(Wnd,idc_IdComb,CB_GETLBTEXT,i,integer(addr(name)));
    if name[0]<>char(0) then
      id:=idFindGlo(name,false);
      if id=nil
        then lstrcpy(val,_�����������_�������������_[envER])
        else envIdToStr(id,val,false)
      end
    end;
    SendDlgItemMessage(Wnd,idc_IdEdit,WM_SETTEXT,0,integer(addr(val)));
    if id=nil
      then SetDlgItemText(Wnd,idc_IdMod,nil)
      else SetDlgItemText(Wnd,idc_IdMod,tbMod[id^.idNom].modNam);
    end;
    if id=nil then SetDlgItemText(Wnd,idc_IdMods,nil)
    else
      envSetModList(id,val);
      SetDlgItemText(Wnd,idc_IdMods,val)
    end
  end
end envDlgShow;

//-------------- ������ �������������� ------------------

const DLG_IDENT=stringER{"DLG_IDENT_R","DLG_IDENT_E"};
dialog DLG_IDENT_R 110,18,187,159,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_VISIBLE | WS_BORDER | WS_MINIMIZEBOX,
  "�������������"
begin
  control "",idc_IdComb,"COMBOBOX",CBS_SIMPLE | CBS_SORT | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,6,3,62,141
  control "",idc_IdEdit,"Edit",ES_LEFT | ES_READONLY | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,72,26,111,117
  control "Win32",idc_IdHelp,"Button",0 | WS_CHILD | WS_VISIBLE,7,145,35,11
  control "���������",idc_IdLoad,"Button",0 | WS_CHILD | WS_VISIBLE,46,145,36,11
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,70,3,40,11
  control "",idc_IdMod,"Static",0 | WS_CHILD | WS_VISIBLE,127,4,56,10
  control "",idc_IdMods,"Static",0 | WS_CHILD | WS_VISIBLE,70,15,113,10
  control "�������",idc_IdCancel,"Button",0 | WS_CHILD | WS_VISIBLE,108,145,75,11
end;
dialog DLG_IDENT_E 110,18,187,159,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_VISIBLE | WS_BORDER | WS_MINIMIZEBOX,
  "Identifier"
begin
  control "",idc_IdComb,"COMBOBOX",CBS_SIMPLE | CBS_SORT | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,6,3,62,141
  control "",idc_IdEdit,"Edit",ES_LEFT | ES_READONLY | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,72,26,111,117
  control "Win32",idc_IdHelp,"Button",0 | WS_CHILD | WS_VISIBLE,7,145,35,11
  control "Load",idc_IdLoad,"Button",0 | WS_CHILD | WS_VISIBLE,46,145,36,11
  control "Module:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,70,3,40,11
  control "",idc_IdMod,"Static",0 | WS_CHILD | WS_VISIBLE,127,4,56,10
  control "",idc_IdMods,"Static",0 | WS_CHILD | WS_VISIBLE,70,15,113,10
  control "Close",idc_IdCancel,"Button",0 | WS_CHILD | WS_VISIBLE,108,145,75,11
end;

//-------------- ������� ���� ������� ------------------

procedure envIdntDlg(Wnd:HWND; Message,wParam,lParam:integer):boolean;
var s:string[maxText]; i:integer; s2:pstr;
begin
  case Message of
    WM_INITDIALOG:
      SetDlgItemText(Wnd,idc_IdComb,envIdName); SendDlgItemMessage(Wnd,idc_IdComb,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
      SetDlgItemText(Wnd,idc_IdEdit,envIdVal); SendDlgItemMessage(Wnd,idc_IdEdit,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
      SetDlgItemText(Wnd,idc_IdMod,envIdMod); SendDlgItemMessage(Wnd,idc_IdMod,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
      SetDlgItemText(Wnd,idc_IdMods,envIdMods); SendDlgItemMessage(Wnd,idc_IdMods,WM_SETFONT,SendMessage(wndStatus,WM_GETFONT,0,0),1);
      SetFocus(GetDlgItem(Wnd,idc_IdComb));|
    WM_COMMAND:case loword(wParam) of
      idc_IdLoad:
        SendDlgItemMessage(Wnd,idc_IdComb,WM_GETTEXT,maxText,integer(addr(s)));
        envDlgLoad(Wnd);
        i:=SendDlgItemMessage(Wnd,idc_IdComb,CB_FINDSTRING,0,integer(addr(s)));
        SendDlgItemMessage(Wnd,idc_IdComb,CB_SETCURSEL,i,0);
        SendDlgItemMessage(Wnd,idc_IdComb,WM_SETTEXT,0,integer(addr(s)));
        SetFocus(GetDlgItem(Wnd,idc_IdComb));|
      idc_IdComb:if hiword(wParam)=CBN_SELCHANGE then envDlgShow(Wnd) end;|
      idc_IdHelp:
        i:=SendDlgItemMessage(Wnd,idc_IdComb,CB_GETCURSEL,0,0);
        if i=-1
          then SendDlgItemMessage(Wnd,idc_IdComb,WM_GETTEXT,maxText,integer(addr(s)))
          else SendDlgItemMessage(Wnd,idc_IdComb,CB_GETLBTEXT,i,integer(addr(s)))
        end;
        WinHelp(mainWnd,envWIN32,HELP_KEY,integer(addr(s)));|
      idc_IdClip:
        GetDlgItemText(Wnd,idc_IdEdit,s,maxText);
        if OpenClipboard(editWnd) then
          EmptyClipboard();
          SetClipboardData(CF_TEXT,HANDLE(addr(s)));
          CloseClipboard();
        end;|
      IDOK,IDCANCEL,idc_IdCancel:EndDialog(Wnd,1); identWnd:=0;|
    end;|
    WM_DESTROY:identWnd:=0;|
  else return false
  end;
  return true;
end envIdntDlg;

//------------- ������������� -----------------

procedure envIdentifier();
var id:pID;
begin
with txts[txtn[tekt]][tekt] do
  envGetIdent(envIdName,tekt,txtTrackX+txtCarX,txtTrackY+txtCarY);
  envIdVal[0]:='\0';
  envIdMod[0]:='\0';
  envIdMods[0]:='\0';
  if (topMod>=tekt)and(tbMod[tekt].modTab<>nil) then
    if envIdName[0]<>'\0' then
      id:=idFindGlo(envIdName,false);
      if id=nil then lstrcpy(envIdVal,_�����������_�������������_[envER])
      else
        envIdToStr(id,envIdVal,false);
        lstrcpy(envIdMod,tbMod[id^.idNom].modNam);
        envSetModList(id,envIdMods);
      end
    end
  end;  
  if identWnd=0 then
    identWnd:=CreateDialogParam(hINSTANCE,DLG_IDENT[envER],mainWnd,addr(envIdntDlg),0);
  end;
  SetFocus(identWnd);
end
end envIdentifier;

//===============================================
//              ��������� �������
//===============================================

//--------- ������ �������� ����������� -------------

const
  idCmpBase=101;
  idCmpStackIni=102;
  idCmpStackMax=103;
  idCmpHeapIni=104;
  idCmpHeapMax=105;
  idCmpExtM=106;
  idCmpExtD=107;
  idCmpExtI=108;
  idCmpRes=109;
  idCmpMod=110;
  idCmpC=111;
  idCmpPas=112;
  idCmpDeb=113;
  idCmpClassSize=114;
  idCmpDefault=119;
  idCmpOk=120;
  idCmpCancel=121;

const DLG_SETCOMP=stringER{"DLG_SETCOMP_R","DLG_SETCOMP_E"};
dialog DLG_SETCOMP_R 28,10,220,162,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "���������"
begin
  control "����� �������� exe-�����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,24,4,98,8
  control "",idCmpBase,"Static",SS_LEFT | WS_CHILD | WS_VISIBLE,126,4,56,8
  control "������ �����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,32,18,58,8
  control "���������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,30,52,8
  control "",idCmpStackIni,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,62,30,40,8
  control "������������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,40,52,8
  control "",idCmpStackMax,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,62,40,40,8
  control "������ ����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,138,18,48,8
  control "���������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,116,30,52,8
  control "",idCmpHeapIni,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,172,30,40,8
  control "������������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,116,40,52,8
  control "",idCmpHeapMax,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,172,40,40,8
  control "������ ������� �������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,5,49,103,9
  control "",idCmpClassSize,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,109,49,40,9
  control "���������� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,119,64,82,8
  control "�������� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,104,77,73,8
  control "",idCmpExtM,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,178,77,40,8
  control "����� ����������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,103,87,74,9
  control "",idCmpExtD,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,178,87,40,8
  control "����� ���������������� ����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,2,104,114,8
  control "",idCmpRes,"Listbox",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,120,104,86,40
  control "���� ����������������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,4,59,90,10
  control "������-2",idCmpMod,"Button",WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,23,70,46,9
  control "��",idCmpC,"Button",WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,23,80,46,10
  control "�������",idCmpPas,"Button",WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,23,90,46,10
  control "���������",idCmpDefault,"Button",WS_CHILD | WS_VISIBLE,176,148,42,10
  control "��",idCmpOk,"Button",WS_CHILD | WS_VISIBLE,61,148,44,10
  control "��������",idCmpCancel,"Button",WS_CHILD | WS_VISIBLE,111,148,44,10
end;
dialog DLG_SETCOMP_E 28,10,220,162,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Options"
begin
  control "Exe-file load address:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,24,4,98,8
  control "",idCmpBase,"Static",SS_LEFT | WS_CHILD | WS_VISIBLE,126,4,56,8
  control "Stack size:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,32,18,58,8
  control "Initial:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,30,52,8
  control "",idCmpStackIni,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,62,30,40,8
  control "Maximal:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,40,52,8
  control "",idCmpStackMax,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,62,40,40,8
  control "Heap size:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,138,18,48,8
  control "Initial:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,116,30,52,8
  control "",idCmpHeapIni,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,172,30,40,8
  control "Maximal:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,116,40,52,8
  control "",idCmpHeapMax,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,172,40,40,8
  control "Class table size:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,6,49,103,9
  control "",idCmpClassSize,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,109,49,40,9
  control "File extensions:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,119,64,82,8
  control "Source texts:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,104,77,73,8
  control "",idCmpExtM,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,178,77,40,8
  control "Interface files:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,103,87,74,9
  control "",idCmpExtD,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,178,87,40,8
  control "Reserved names:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,2,104,114,8
  control "",idCmpRes,"Listbox",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,120,104,86,40
  control "Programming language:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,4,59,90,10
  control "Modula-2",idCmpMod,"Button",WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,23,70,46,9
  control "C",idCmpC,"Button",WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,23,80,46,10
  control "Pascal",idCmpPas,"Button",WS_CHILD | WS_VISIBLE | BS_AUTORADIOBUTTON,23,90,46,10
  control "By default",idCmpDefault,"Button",WS_CHILD | WS_VISIBLE,176,148,42,10
  control "Ok",idCmpOk,"Button",WS_CHILD | WS_VISIBLE,61,148,44,10
  control "Cancel",idCmpCancel,"Button",WS_CHILD | WS_VISIBLE,111,148,44,10
end;

//--------- ��������� ����������� -------------

procedure dlgSetComp(Wnd:HWND; Message,wParam,lParam:integer):boolean;
var i,j,code:integer; buf:string[maxText];
begin
  case Message of
    WM_INITDIALOG:
      SetDlgItemText(Wnd,idCmpBase,"0x400000");
      wvsprintf(buf,"%li",addr(genSTACKMIN)); SetDlgItemText(Wnd,idCmpStackIni,buf);
      wvsprintf(buf,"%li",addr(genSTACKMAX)); SetDlgItemText(Wnd,idCmpStackMax,buf);
      wvsprintf(buf,"%li",addr(genHEAPMIN)); SetDlgItemText(Wnd,idCmpHeapIni,buf);
      wvsprintf(buf,"%li",addr(genHEAPMAX)); SetDlgItemText(Wnd,idCmpHeapMax,buf);
      wvsprintf(buf,"%li",addr(genCLASSSIZE)); SetDlgItemText(Wnd,idCmpClassSize,buf);
      SetDlgItemText(Wnd,idCmpExtM,envEXTM);
      SetDlgItemText(Wnd,idCmpExtD,envEXTD);
      SetDlgItemText(Wnd,idCmpExtI,envEXTI);
      SendDlgItemMessage(Wnd,idCmpRes,LB_ADDSTRING,0,integer(pstr(_����������_�����[envER])));
      SendDlgItemMessage(Wnd,idCmpRes,LB_ADDSTRING,0,integer(pstr(_����������_�������[envER])));
      SendDlgItemMessage(Wnd,idCmpRes,LB_ADDSTRING,0,integer(pstr(_�������_�����[envER])));
      SendDlgItemMessage(Wnd,idCmpRes,LB_ADDSTRING,0,integer(pstr(_�������_�������[envER])));
      SendDlgItemMessage(Wnd,idCmpRes,LB_SETCURSEL,integer(carSet),0);
      case traLANG of
        langMODULA:SendDlgItemMessage(Wnd,idCmpMod,BM_SETCHECK,BST_CHECKED,0);|
        langC:SendDlgItemMessage(Wnd,idCmpC,BM_SETCHECK,BST_CHECKED,0);|
        langPASCAL:SendDlgItemMessage(Wnd,idCmpPas,BM_SETCHECK,BST_CHECKED,0);|
      end;
      SetFocus(GetDlgItem(Wnd,idCmpStackIni));|
    WM_COMMAND:case loword(wParam) of
      idCmpDefault:if boolean(MessageBox(0,
        _��������_���_��������_��_��������_��_���������__[envER],"�������� !",MB_YESNO)) then
        datDefaultComp();
        wvsprintf(buf,"%li",addr(genSTACKMIN)); SetDlgItemText(Wnd,idCmpStackIni,buf);
        wvsprintf(buf,"%li",addr(genSTACKMAX)); SetDlgItemText(Wnd,idCmpStackMax,buf);
        wvsprintf(buf,"%li",addr(genHEAPMIN)); SetDlgItemText(Wnd,idCmpHeapIni,buf);
        wvsprintf(buf,"%li",addr(genHEAPMAX)); SetDlgItemText(Wnd,idCmpHeapMax,buf);
        wvsprintf(buf,"%li",addr(genCLASSSIZE)); SetDlgItemText(Wnd,idCmpClassSize,buf);
        SetDlgItemText(Wnd,idCmpExtM,envEXTM);
        SetDlgItemText(Wnd,idCmpExtD,envEXTD);
        SendDlgItemMessage(Wnd,idCmpRes,LB_SETCURSEL,0,0);
        CheckDlgButton(Wnd,idCmpDeb,0);
      end;|
      idCmpMod:if hiword(wParam)=BN_CLICKED then
        SetDlgItemText(Wnd,idCmpExtM,"m");
        SetDlgItemText(Wnd,idCmpExtD,"d");
      end;|
      idCmpC:if hiword(wParam)=BN_CLICKED then
        SetDlgItemText(Wnd,idCmpExtM,"c");
        SetDlgItemText(Wnd,idCmpExtD,"h");
      end;|
      idCmpPas:if hiword(wParam)=BN_CLICKED then
        SetDlgItemText(Wnd,idCmpExtM,"pas");
        SetDlgItemText(Wnd,idCmpExtD,"def");
      end;|
      IDOK,idCmpOk:
        GetDlgItemText(Wnd,idCmpStackIni,buf,maxText); genSTACKMIN:=wvscani(buf);
        GetDlgItemText(Wnd,idCmpStackMax,buf,maxText); genSTACKMAX:=wvscani(buf);
        GetDlgItemText(Wnd,idCmpHeapIni,buf,maxText); genHEAPMIN:=wvscani(buf);
        GetDlgItemText(Wnd,idCmpHeapMax,buf,maxText); genHEAPMAX:=wvscani(buf);
        GetDlgItemText(Wnd,idCmpClassSize,buf,maxText); genCLASSSIZE:=wvscani(buf);
        GetDlgItemText(Wnd,idCmpExtM,envEXTM,40);
        GetDlgItemText(Wnd,idCmpExtD,envEXTD,40);
        carSet:=classSET(SendDlgItemMessage(Wnd,idCmpRes,LB_GETCURSEL,0,0));
        if IsDlgButtonChecked(Wnd,idCmpMod)=BST_CHECKED then traLANG:=langMODULA end;
        if IsDlgButtonChecked(Wnd,idCmpC)=BST_CHECKED then traLANG:=langC end;
        if IsDlgButtonChecked(Wnd,idCmpPas)=BST_CHECKED then traLANG:=langPASCAL end;
        EndDialog(Wnd,1);|
      IDCANCEL,idCmpCancel:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true;
end dlgSetComp;

//--------- ��������� ����������� -------------

procedure envSetComp();
begin
  if boolean(DialogBoxParam(hINSTANCE,DLG_SETCOMP[envER],GetFocus(),addr(dlgSetComp),0)) then
    datSaveConst();
    InvalidateRect(editWnd,nil,true);
    UpdateWindow(editWnd)
  end;
  SetFocus(editWnd);
end envSetComp;

//------------- ������ �������� ����� ---------------

const
  idEnvTrackX=101;
  idEnvTrackMax=102;
  idEnvTrackVer=103;
  idEnvColFone=104;
  idEnvColSel=105;
  idEnvFntBeg=106;
  idEnvFntEnd=114;
  idEnvHelp32=115;
  idEnvBmpE=116;
  idEnvExeFolder=117;
  idEnvExeBrowse=118;
  idEnvDefault=119;
  idEnvOk=120;
  idEnvCancel=121;

const DLG_SETENV=stringER{"DLG_SETENV_R","DLG_SETENV_E"};
dialog DLG_SETENV_R 30,18,220,177,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "���������"
begin
  control "��������� ������ �� �����������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,4,144,8
  control "",idEnvTrackX,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,150,4,40,10
  control "������������ ��������� �� �����������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,14,144,8
  control "",idEnvTrackMax,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,150,14,40,10
  control "��������� �� ���������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,24,144,8
  control "",idEnvTrackVer,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,150,24,40,10
  control "���� ���� ���������:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,114,40,96,8
  control "������� �����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,106,54,66,8
  control "",idEnvColFone,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,174,54,40,10
  control "���������� �����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,106,64,66,8
  control "",idEnvColSel,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,174,64,40,10
  control "����� �����",idEnvFntBeg,"Button",WS_CHILD | WS_VISIBLE,6,54,94,8
  control "������������ �����",107,"Button",WS_CHILD | WS_VISIBLE,6,64,94,8
  control "������ ��������",108,"Button",WS_CHILD | WS_VISIBLE,6,74,94,8
  control "�����������",109,"Button",WS_CHILD | WS_VISIBLE,6,84,94,8
  control "����������������� �����",110,"Button",WS_CHILD | WS_VISIBLE,6,94,94,8
  control "��������������",111,"Button",WS_CHILD | WS_VISIBLE,6,104,94,8
  control "������� ����������",112,"Button",WS_CHILD | WS_VISIBLE,6,114,94,8
  control "�������� ����������",113,"Button",WS_CHILD | WS_VISIBLE,6,124,94,8
  control "�����������",idEnvFntEnd,"Button",WS_CHILD | WS_VISIBLE,6,134,94,8
  control "���������� �� Win32:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,108,92,106,8
  control "",idEnvHelp32,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,126,102,74,10
  control "�������� BMP-������:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,110,120,106,8
  control "",idEnvBmpE,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,130,112,10
  control "���������� ������:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,10,40,84,8
  control "���������",idEnvDefault,"Button",WS_CHILD | WS_VISIBLE,176,164,40,10
  control "����� EXE ������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,6,144,66,10
  control "",idEnvExeFolder,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,73,144,111,10
  control "�����",idEnvExeBrowse,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,186,144,30,10
  control "��",idEnvOk,"Button",WS_CHILD | WS_VISIBLE,60,164,44,10
  control "��������",idEnvCancel,"Button",WS_CHILD | WS_VISIBLE,109,164,44,10
end;
dialog DLG_SETENV_E 30,18,220,177,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Options"
begin
  control "Scrolling of the screen on a horizontal:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,4,144,8
  control "",idEnvTrackX,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,150,4,40,10
  control "Maximum scrolling on a horizontal:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,14,144,8
  control "",idEnvTrackMax,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,150,14,40,10
  control "Scrolling on a vertical:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,4,24,144,8
  control "",idEnvTrackVer,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,150,24,40,10
  control "Background color:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,114,40,96,8
  control "The usual text:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,106,54,66,8
  control "",idEnvColFone,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,174,54,40,10
  control "Selected text:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,106,64,66,8
  control "",idEnvColSel,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,174,64,40,10
  control "Integers",idEnvFntBeg,"Button",WS_CHILD | WS_VISIBLE,6,54,94,8
  control "Floating",107,"Button",WS_CHILD | WS_VISIBLE,6,64,94,8
  control "Strings",108,"Button",WS_CHILD | WS_VISIBLE,6,74,94,8
  control "Parses",109,"Button",WS_CHILD | WS_VISIBLE,6,84,94,8
  control "Reserved names",110,"Button",WS_CHILD | WS_VISIBLE,6,94,94,8
  control "Identifiers",111,"Button",WS_CHILD | WS_VISIBLE,6,104,94,8
  control "Assembler commands",112,"Button",WS_CHILD | WS_VISIBLE,6,114,94,8
  control "Registers",113,"Button",WS_CHILD | WS_VISIBLE,6,124,94,8
  control "Comments",idEnvFntEnd,"Button",WS_CHILD | WS_VISIBLE,6,134,94,8
  control "Win32 Help:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,108,92,106,8
  control "",idEnvHelp32,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,126,102,74,10
  control "BMP-file editor:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,110,120,106,8
  control "",idEnvBmpE,"Edit",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,130,112,10
  control "Program text:",-1,"Static",SS_CENTER | WS_CHILD | WS_VISIBLE,10,40,84,8
  control "By default",idEnvDefault,"Button",WS_CHILD | WS_VISIBLE,178,152,40,10
  control "EXE (DLL) folder:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,6,144,66,10
  control "",idEnvExeFolder,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,73,144,111,10
  control "Browse",idEnvExeBrowse,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,186,144,30,10
  control "Ok",idEnvOk,"Button",WS_CHILD | WS_VISIBLE,60,152,44,10
  control "Cancel",idEnvCancel,"Button",WS_CHILD | WS_VISIBLE,110,152,44,10
end;

//------------- ��������� ����� ---------------

procedure dlgSetEnv(Wnd:HWND; Message,wParam,lParam:integer):boolean;
var i,j,code:integer; buf,title:string[maxText];
begin
  case Message of
    WM_INITDIALOG:
      SetDlgItemInt(Wnd,idEnvTrackX,ediTrackX,true);
      SetDlgItemInt(Wnd,idEnvTrackMax,envTRACKMAX,true);
      SetDlgItemInt(Wnd,idEnvTrackVer,envTRACKUP,true);
      wvsprintf(buf,"%.6lX",addr(envEDITBK)); SetDlgItemText(Wnd,idEnvColFone,buf);
      wvsprintf(buf,"%.6lX",addr(envEDITSEL)); SetDlgItemText(Wnd,idEnvColSel,buf);
      SetDlgItemText(Wnd,idEnvHelp32,envWIN32);
      SetDlgItemText(Wnd,idEnvBmpE,envBMPE);
      SetDlgItemText(Wnd,idEnvExeFolder,envExeFolder);
      SetFocus(GetDlgItem(Wnd,idEnvTrackX));|
    WM_COMMAND:case loword(wParam) of
      idCmpDefault:if boolean(MessageBox(0,
        _��������_���_��������_��_��������_��_���������__[envER],"�������� !",MB_YESNO)) then
        datDefaultEnv();
        SetDlgItemInt(Wnd,idEnvTrackX,ediTrackX,true);
        SetDlgItemInt(Wnd,idEnvTrackMax,envTRACKMAX,true);
        SetDlgItemInt(Wnd,idEnvTrackVer,envTRACKUP,true);
        wvsprintf(buf,"%.6lX",addr(envEDITBK)); SetDlgItemText(Wnd,idEnvColFone,buf);
        wvsprintf(buf,"%.6lX",addr(envEDITSEL)); SetDlgItemText(Wnd,idEnvColSel,buf);
        SetDlgItemText(Wnd,idEnvHelp32,envWIN32);
        SetDlgItemText(Wnd,idEnvBmpE,envBMPE);
        SetDlgItemText(Wnd,idEnvExeFolder,"");
      end;|
      idEnvColFone:if hiword(wParam)=BN_CLICKED then
        GetDlgItemText(Wnd,idEnvColFone,buf,maxText);
        lstrinsc('x',buf,0); lstrinsc('0',buf,0);
        i:=sysChooseColor(Wnd,wvscani(buf));
        wvsprintf(buf,"%.6lX",addr(i));
        SetDlgItemText(Wnd,idEnvColFone,buf);
      end;|
      idEnvColSel:if hiword(wParam)=BN_CLICKED then
        GetDlgItemText(Wnd,idEnvColSel,buf,maxText);
        lstrinsc('x',buf,0); lstrinsc('0',buf,0);
        i:=sysChooseColor(Wnd,wvscani(buf));
        wvsprintf(buf,"%.6lX",addr(i));
        SetDlgItemText(Wnd,idEnvColSel,buf);
      end;|
      idEnvExeBrowse:if hiword(wParam)=BN_CLICKED then
        GetDlgItemText(Wnd,idEnvExeFolder,buf,maxText);
        if sysGetFileName(true,"*.*",buf,title) then
          while (lstrlen(buf)>0)and(buf[lstrlen(buf)-1]<>'\') do
            lstrdel(buf,lstrlen(buf)-1,1);
          end;
          SetDlgItemText(Wnd,idEnvExeFolder,buf);
        end
      end;|
      idEnvFntBeg..idEnvFntEnd:envCorrFont(classFrag(wParam-idEnvFntBeg+1));|
      IDOK,idCmpOk:
        ediTrackX:=GetDlgItemInt(Wnd,idEnvTrackX,nil,true);
        envTRACKMAX:=GetDlgItemInt(Wnd,idEnvTrackMax,nil,true);
        envTRACKUP:=GetDlgItemInt(Wnd,idEnvTrackVer,nil,true);
        GetDlgItemText(Wnd,idEnvColFone,buf,maxText);
        lstrinsc('x',buf,0);
        lstrinsc('0',buf,0);
        envEDITBK:=wvscani(buf);
        if (envEDITBK<0)or(envEDITBK>0xFFFFFF) then
          MessageBox(0,buf,_��������_����_[envER],0)
        end;
        GetDlgItemText(Wnd,idEnvColSel,buf,maxText);
        lstrinsc('x',buf,0);
        lstrinsc('0',buf,0);
        envEDITSEL:=wvscani(buf);
        if (envEDITSEL<0)or(envEDITSEL>0xFFFFFF) then
          MessageBox(0,buf,_��������_����_[envER],0)
        end;
        GetDlgItemText(Wnd,idEnvHelp32,envWIN32,40);
        GetDlgItemText(Wnd,idEnvBmpE,envBMPE,80);
        GetDlgItemText(Wnd,idEnvExeFolder,envExeFolder,270);
        EndDialog(Wnd,1);|
      IDCANCEL,idCmpCancel:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true;
end dlgSetEnv;

//--------- ��������� ����������� -------------

procedure envSetEnv();
begin
  if boolean(DialogBoxParam(hINSTANCE,DLG_SETENV[envER],GetFocus(),addr(dlgSetEnv),0)) then
    datSaveConst();
  end;
  SetFocus(editWnd);
  envUpdate(editWnd)
end envSetEnv;

//===============================================
//          ������-������ � ������
//===============================================

//------- ������� (��������) ������-������ -------------

procedure envStatusCreate(bitIni:boolean);
var sizes:array[classStatus]of integer; reg:RECT; sta:classStatus; i:integer;
begin
  if bitIni then
    wndStatus:=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      nil,mainWnd,0);
  end;
  GetClientRect(mainWnd,reg);
  if not bitIni then
    SendMessage(wndStatus,WM_SIZE,reg.right-reg.left+1,reg.bottom-reg.top+1);
  end;
  i:=(reg.right-reg.left) div 10;
  for sta:=staMod to staIdent do
    sizes[sta]:=i+i*cardinal(sta);
  end;
  sizes[staIdent]:=-1;
  SendMessage(wndStatus,SB_SETPARTS,cardinal(staIdent)+1,cardinal(addr(sizes)));
end envStatusCreate;

//------- ������� ������ -------------

bitmap bmpToolbar="toolbar.bmp";

procedure envButtonCreate();
var
  i,num:integer; bmp:HBITMAP; gr:classGroup; comm:classComm; reg:RECT;
  envButt:array[1..maxButt]of TBBUTTON;
begin
  InitCommonControls();
  bmp:=LoadBitmap(hINSTANCE,"bmpToolbar");
  num:=0;
  for gr:=gFil to gHlp do
    for comm:=setGroup[envER][gr].grLo to setGroup[envER][gr].grHi do
    if (setButtons[comm]>0)and(num<maxButt) then
      inc(num);
      RtlZeroMemory(addr(envButt[num]),sizeof(TBBUTTON));
      with envButt[num] do
        iBitmap:=setButtons[comm]-1;
        idCommand:=idBaseComm+integer(comm);
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_BUTTON;
      end;
    end end;
    if num<maxButt then
      inc(num);
      RtlZeroMemory(addr(envButt[num]),sizeof(TBBUTTON));
      with envButt[num] do
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_SEP;
      end
    end
  end;
  wndToolbar:=CreateToolbarEx(
    mainWnd,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,num,0,bmp,addr(envButt),num,20,20,20,20,sizeof(TBBUTTON));
  with reg do
    GetWindowRect(wndToolbar,reg);
    inc(bottom,10);
    MoveWindow(wndToolbar,left,top,right-left+1,bottom-top+1,true);
  end;
end envButtonCreate;

//------- ���������� ������ � ���� -------------

procedure envEnable();
var gr:classGroup; comm:classComm; ok:boolean;
begin
  for gr:=gFil to gExit do
  for comm:=setGroup[envER][gr].grLo to setGroup[envER][gr].grHi do
    case comm of
    //�������� ������
      cFilNew,cFilOpen,cFilExit,cSetComp,cSetEnv,cSetDlg,cHlpCont,cHlpWin32,cHlpAbout,cExit:ok:=true;|
    //�������� ��� ������� ������
      cFilSave,cFilSaveAs,cFilClose,cBlkAll,cFindFind,cFindRepl,cComComp,cComAll,cComRun,
      cDebNextDown,cDebNext,cDebGoto,
      cUtilId,cUtilRes,cUtilErr,cUtilErr,cUtilId,cUtilRes,cBlkPaste:ok:=topt>0;|
    //������� ����
      cSetMain:ok:=(topt>0)and(mait=0);|
      cSetClear:ok:=(topt>0)and(mait>0);|
    //������ ������
      cBlkUndo:ok:=(topt>0)and(envTopUndo>0);|
      cBlkCut:ok:=(topt>0)and(txts[txtn[tekt]][tekt].blkSet);|
      cBlkCopy:ok:=(topt>0)and(txts[txtn[tekt]][tekt].blkSet);|
      cBlkDel:ok:=(topt>0)and(txts[txtn[tekt]][tekt].blkSet);|
      cFindNext:ok:=(topt>0)and(lstrcmp(findStr,"")<>0);|
//      cDebRunEnd,
      cDebEnd,cDebView:ok:=stepDebugged and(topt>0);|
      cDebRun:ok:=not stepDebugged and(topt>0);|
    end;
    if ok then
      EnableMenuItem(envMenuH[gr],idBaseComm+integer(comm),MF_BYCOMMAND | MF_ENABLED);
      SendMessage(wndToolbar,TB_CHECKBUTTON,idBaseComm+integer(comm),0);
      SendMessage(wndToolbar,TB_ENABLEBUTTON,idBaseComm+integer(comm),1);
    else
      EnableMenuItem(envMenuH[gr],idBaseComm+integer(comm),MF_BYCOMMAND | MF_GRAYED);
      SendMessage(wndToolbar,TB_CHECKBUTTON,idBaseComm+integer(comm),1);
      SendMessage(wndToolbar,TB_ENABLEBUTTON,idBaseComm+integer(comm),0);
    end
  end end;
end envEnable;

//===============================================
//          ������� ������� ���������
//===============================================

//------- ����� ���������� ������ -------------

procedure envShift():boolean;
begin
  return cardinal(GetKeyState(VK_SHIFT)) and 0x8000 <> 0
end envShift;

procedure envCtrl():boolean;
begin
  return cardinal(GetKeyState(VK_CONTROL)) and 0x8000 <> 0
end envCtrl;

procedure envAlt():boolean;
begin
  return cardinal(GetKeyState(VK_MENU)) and 0x8000 <> 0
end envAlt;

procedure envNone():boolean;
begin
  return not envShift() and not envCtrl() and not envAlt()
end envNone;

//------------ ������� ������� ----------------

procedure envProc(Wnd:HWND; Message,wParam,lParam:integer):integer;
var s:pstr; i,rezProc:integer; foc:HWND; dc:HDC; ps:PAINTSTRUCT; oldComp:boolean;
begin
  rezProc:=0;
  oldComp:=tbMod[tekt].modComp;
  case Message of
//�������� � ��������
    WM_CREATE:|
    WM_DESTROY:|
//����� �����
    WM_SETFOCUS:
      CreateCaret(Wnd,0,GetSystemMetrics(SM_CXBORDER)*2,GetSystemMetrics(SM_CYCAPTION));
      ShowCaret(Wnd);
      envSetCaret(tekt);|
    WM_KILLFOCUS:HideCaret(Wnd); DestroyCaret();|
    WM_SIZE:envUpdate(Wnd);|
    WM_ERASEBKGND:|
    WM_PAINT:
      dc:=BeginPaint(Wnd,ps);
      envCreateFonts(dc,false);
      envView(tekt,dc);
      envDestroyFonts();
      EndPaint(Wnd,ps);|
    WM_MOUSEWHEEL:envMouseWheel(tekt,wParam);|
    WM_LBUTTONDOWN:envSetCursor(tekt,loword(lParam),hiword(lParam),false); envSelectMouse:=true;|
    WM_LBUTTONUP:envSelectMouse:=false;|
    WM_MOUSEMOVE:if envSelectMouse then envSetCursor(tekt,loword(lParam),hiword(lParam),true) end;|
    WM_RBUTTONDOWN:envContextMenu(tekt,lParam);|
//������ ���������
    WM_VSCROLL:case loword(wParam) of
      SB_LINEUP:envEvalScrollUp(tekt,false,true);|
      SB_LINEDOWN:envEvalScrollDown(tekt,false,true);|
      SB_PAGEUP:envEvalScrollUp(tekt,true,true);|
      SB_PAGEDOWN:envEvalScrollDown(tekt,true,true);|
      SB_THUMBTRACK:envEvalPosY(tekt,hiword(wParam));|
    end;|
    WM_HSCROLL:case loword(wParam) of
      SB_LINELEFT:envEvalScrollLeft (tekt,false);|
      SB_LINERIGHT:envEvalScrollRight(tekt,false);|
      SB_PAGELEFT:envEvalScrollLeft (tekt,true);|
      SB_PAGERIGHT:envEvalScrollRight(tekt,true);|
      SB_THUMBTRACK:envEvalPosX(tekt,hiword(wParam));|
    end;|
    WM_KEYDOWN:
//��������� �����
      with txts[txtn[tekt]][tekt] do
      if envShift() then
        if not blkSet then case wParam of 
          VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN,VK_HOME,VK_END,VK_PRIOR,VK_NEXT:
            blkSet:=true;
            blkX:=txtTrackX+txtCarX;
            blkY:=txtTrackY+txtCarY;|
        end end;
//����� �����
      elsif blkSet then case wParam of
        VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN,VK_HOME,VK_END,VK_PRIOR,VK_NEXT,
        VK_BACK, VK_RETURN,VK_F2,VK_F3,VK_F4,VK_F7,VK_F8,VK_F9:
          blkSet:=false;
          envUpdate(Wnd);|
        end
      end;
//��������� ������
      case loword(wParam) of
        VK_LEFT:envEvalKeyLeft(tekt);|
        VK_RIGHT:envEvalKeyRight(tekt,true);|
        VK_UP:envEvalKeyUp(tekt);|
        VK_DOWN:envEvalKeyDown(tekt,true);|
        VK_PRIOR:envEvalScrollUp(tekt,true,false);|
        VK_NEXT:envEvalScrollDown(tekt,true,false);|
        VK_HOME:if envCtrl() then envEditBegin(tekt) else envEvalKeyHome(tekt,true) end;|
        VK_END:if envCtrl() then envEditEnd(tekt) else envEvalKeyEnd(tekt) end;|
        VK_BACK:if envCtrl() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cBlkUndo),0)
          else envUndoPush(undoBackChar,tekt); envKeyBackspace(tekt) end;|
        VK_RETURN:envUndoPush(undoInsStr,tekt); envKeyEnter(tekt,true,true);|
        VK_F1:
          if envNone() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cHlpCont),0)
          elsif envCtrl() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cUtilId),0) end;|
        VK_F2:if envNone() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cFilSave),0) end;|
        VK_F3:
          if envNone() then PostMessage(Wnd,WM_COMMAND,idBaseComm+integer(cFindNext),0)
          elsif envCtrl() then PostMessage(Wnd,WM_COMMAND,idBaseComm+integer(cFindFind),0)
          elsif envShift() then PostMessage(Wnd,WM_COMMAND,idBaseComm+integer(cFindRepl),0) end;|
        VK_F4:
          if envNone() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cDebGoto),0)
          elsif envCtrl() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cFilClose),0) end;|
        VK_F7:if envNone() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cDebNextDown),0) end;|
        VK_F8:if envNone() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cDebNext),0) end;|
        VK_F9:
          if envNone() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cComAll ),0)
          elsif envAlt() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cComComp),0)
          elsif envCtrl() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cComRun ),0)
          end;|
        VK_INSERT:
          if envCtrl() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cBlkCopy),0)
          elsif envShift() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cBlkPaste),0)
          end;|
        VK_DELETE:
          if envCtrl() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cBlkDel),0)
          elsif envShift() then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cBlkCut),0)
          elsif txts[txtn[tekt]][tekt].blkSet then PostMessage(mainWnd,WM_COMMAND,idBaseComm+integer(cBlkDel),0)
          else
            with txts[txtn[tekt]][tekt].txtStrs^ do
              s:=memAlloc(2048);
              envFromFrag(s,arrs[txtTrackY+txtCarY]);
              if txtTrackX+txtCarX<=lstrlen(s)
                then envUndoPush(undoDelChar,tekt)
                else envUndoPush(undoDelStr,tekt)
              end;
              memFree(s)
            end;
            envKeyDelete(tekt)
          end;|
      end;
//����������� �����
      if envShift() and txts[txtn[tekt]][tekt].blkSet then
      case wParam of VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN,VK_HOME,VK_END:
        envUpdate(Wnd);|
      end end
    end;|
//������� �������
    WM_CHAR:if (loword(wParam)>=32)and(loword(wParam)<>127) then
      if txts[txtn[tekt]][tekt].blkSet then
        envUndoPush(undoDelBlock,tekt);
        envEditDel(tekt);
        envUndoBlockEnd(tekt);
      end;
      envUndoPush(undoInsChar,tekt);
      envKeyChar(tekt,char(loword(wParam)),true);
    end;|
    WM_COMMAND:case loword(wParam) of
      idBaseComm+cFindFind:envEditFind(true,false);|
      idBaseComm+cFindNext:envEditFind(false,false);|
      idBaseComm+cFindRepl:envEditRepl();|
    end;|
  else rezProc:=integer(DefWindowProc(Wnd,Message,wParam,lParam))
  end;
  case Message of 
    WM_SIZE,WM_LBUTTONDOWN,WM_KEYDOWN,WM_CHAR,WM_COMMAND,
    WM_SETFOCUS,WM_VSCROLL,WM_HSCROLL:
      envSetCaret(tekt);|
  end;
  with tbMod[tekt] do
    if (txts[0][tekt].txtMod or txts[1][tekt].txtMod) and modComp then
      modComp:=false;
    end;
    if oldComp<>modComp then
      envSetStatus(tekt)
    end
  end;
  envEnable();
  return rezProc
end envProc;

//-------- ����������� ������ ----------

procedure envInitClass;
var initClass:WNDCLASS;
begin
  initClass.hInstance:=hINSTANCE;
  with initClass do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(envProc);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hIcon:=0;//LoadIcon(hINSTANCE,'ICON');
    hCursor:=LoadCursor(0,pstr(IDC_IBEAM));
    hbrBackground:=GetStockObject(WHITE_BRUSH);
    lpszMenuName:=nil;
    lpszClassName:="Stran32Env";
  end;
  if RegisterClass(initClass)=0 then
    mbS(_������_�����������_������_Stran32Env[envER]);
  end
end envInitClass;

end SmEnv.

