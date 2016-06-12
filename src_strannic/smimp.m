///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//��� ������
//���� SmImp.M

implementation module SmImp;
import Win32,Win32Ext;

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ SYS (��������������� �������)
//���� SMSYS.M

//implementation module SmSys;
//import Win32,Win32Ext;

//===============================================
//            ������������� ��������
//===============================================

  procedure sysSelectObject(dc:HDC; h:HANDLE; var old:HANDLE);
  begin
    old:=SelectObject(dc,h);
  end sysSelectObject;

  procedure sysDeleteObject(dc:HDC; h:HANDLE; old:HANDLE);
  begin
    SelectObject(dc,old);
    if not DeleteObject(h) then
      mbS("sysDeleteObject");
    end
  end sysDeleteObject;

//===============================================
//                     ������
//===============================================

  procedure listFill(fillLen:integer; fillStr,fillBuf:pstr):pstr;
// ������������� fillLen ����������� ������
  var i,top:integer;
  begin
    if fillLen<0
      then top:=-fillLen
      else top:=fillLen
    end;
    lstrcpy(fillBuf,fillStr);
    for i:=lstrlen(fillBuf) to top-1 do
      if fillLen>0
        then lstrcatc(fillBuf,' ')
        else lstrinsc(' ',fillBuf,0);
      end
    end;
    if lstrlen(fillBuf)>top then
      fillBuf[top]:=char(0);
    end;
    return fillBuf
  end listFill;

  procedure SetDlgItemReal(Dlg:HWND; idDlgItem:integer; Value:real; Pre:integer);
  var s:string[60];
  begin
    wvsprintr(Value,Pre,s);
    SetDlgItemText(Dlg,idDlgItem,s);
  end SetDlgItemReal;

  procedure GetDlgItemReal(Dlg:HWND; idDlgItem:integer):real;
  var s:string[60];
  begin
    GetDlgItemText(Dlg,idDlgItem,s,60);
    return wvscanr(s)
  end GetDlgItemReal;

//===============================================
//           ����������� �������
//===============================================

  procedure sysGetFileName(bitOpen:boolean; getMas:pstr; getPath,getTitle:pstr):boolean;
  var getVar:OPENFILENAME;
  begin
    lstrcpy(getPath,getMas);
    getTitle[0]:=char(0);
//    if getMas[lstrlen(getMas)+1]<>char(0) then
//      mbS("sysGetFileName")
//    end;
    RtlZeroMemory(addr(getVar),sizeof(OPENFILENAME));
    with getVar do
      lStructSize:=sizeof(OPENFILENAME);
      lpstrFilter:=getMas;
      nFilterIndex:=1;
      lpstrFile:=getPath;
      nMaxFile:=128;
      lpstrFileTitle:=getTitle;
      nMaxFileTitle:=128;
      Flags:=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    end;
    if bitOpen
      then return GetOpenFileName(getVar)
      else return GetSaveFileName(getVar)
    end
end sysGetFileName;

procedure sysChooseFont(chFace:pstr; var chStyle,chSize:integer):boolean;
var chBuf:CHOOSEFONT; chFont:LOGFONT; ���:boolean;
begin
  RtlZeroMemory(addr(chBuf), sizeof(CHOOSEFONT));
  RtlZeroMemory(addr(chFont),sizeof(LOGFONT));
  with chBuf,chFont do
    lStructSize:=sizeof(CHOOSEFONT);
    lpLogFont:=addr(chFont);
    Flags:=CF_SCREENFONTS;
    if chSize=0 then
      Flags:=Flags or CF_NOSIZESEL;
    end;
    ���:=false;
    if ChooseFont(chBuf) then
      ���:=true;
      lstrcpy(chFace,addr(chFont.lfFaceName));
      chStyle:=nFontType;
      if chSize<>0 then
        chSize:=iPointSize
      end
    end;
    return ���
  end
end sysChooseFont;

procedure sysEnumFontProc(eLF:pLOGFONT; eTM:pNEWTEXTMETRIC; eType:word; eRes:pSysFonts):boolean;
begin
  if cardinal(eType)=TRUETYPE_FONTTYPE then
    with eRes^ do
      inc(top);
      fnts[top]:=memAlloc(lstrlen(eLF^.lfFaceName)+1);
      lstrcpy(fnts[top],eLF^.lfFaceName);
      return top<maxFonts
    end
  else return true
  end
end sysEnumFontProc;

procedure sysGetFamilies(DC:HDC; res:pSysFonts);
begin
  res^.top:=0;
  EnumFontFamilies(DC,nil,addr(sysEnumFontProc),cardinal(res))
end sysGetFamilies;

procedure sysPrintDlg(var prnCopies:integer):HDC;
var prnBuf:PRINTDLG; pDevMode:pointer to DEVMODE;
begin
  RtlZeroMemory(addr(prnBuf),sizeof(PRINTDLG));
  with prnBuf do
    lStructSize:=sizeof(PRINTDLG);
    Flags:=PD_RETURNDC | PD_PRINTSETUP | PD_USEDEVMODECOPIES;
    if not PrintDlg(prnBuf) then return 0
    else
      GlobalFree(hDevMode);
      GlobalFree(hDevNames);
      return hDC
    end
  end
end sysPrintDlg;

procedure sysChooseColor(wnd:HWND; col:cardinal):cardinal;
var cc:CHOOSECOLOR;
begin
  RtlZeroMemory(addr(cc),sizeof(CHOOSECOLOR));
  with cc do
    lStructSize:=sizeof(CHOOSECOLOR);
    hwndOwner:=wnd;
    rgbResult:=col;
    Flags:=CC_RGBINIT;
    lpCustColors:=memAlloc(16*4);
    RtlZeroMemory(lpCustColors,16*4);
    if not ChooseColor(cc)
      then return col
      else return rgbResult
    end
  end;
end sysChooseColor;

//===============================================
//                   ���������
//===============================================

procedure sysDrawBitmap(drawDC:HDC; x,y:integer; drawBitmap:HBITMAP);
var hBM,hOldBM:HBITMAP; hMemDC:HDC; BM:BITMAP; ptSize,ptOrg:POINT;
begin
  hMemDC:=CreateCompatibleDC(drawDC);
  sysSelectObject(hMemDC,drawBitmap,hOldBM);
  if hOldBM<>0 then
    SetMapMode(hMemDC,GetMapMode(drawDC));
    GetObject(drawBitmap,sizeof(BITMAP),addr(BM));
    ptSize.x:=BM.bmWidth;
    ptSize.y:=BM.bmHeight;
    DPtoLP(drawDC,ptSize,1);
    ptOrg.x:=0;
    ptOrg.y:=0;
    DPtoLP(hMemDC,ptOrg,1);
    BitBlt(drawDC,x,y,ptSize.x,ptSize.y,
           hMemDC,ptOrg.x,ptOrg.y,SRCCOPY);
  end;
  SelectObject(hMemDC,hOldBM);
  DeleteDC(hMemDC)
end sysDrawBitmap;

//===============================================
//           �������������� �����
//===============================================


//�������������� �����
procedure sysAnsiToUnicode(c:char):word;
var s:string[1]; w:array[0..1]of word;
begin
  s[0]:=c;
  s[1]:=char(0);
  MultiByteToWideChar(0,0,s,2,addr(w),2);
  return w[0]
end sysAnsiToUnicode;

procedure sysRealToReal32(r:real):cardinal;
var res:cardinal;
begin
  asm
  FLD  [EBP+offs(r)];
  FSTP d [EBP+offs(res)];
  end;
  return res
end sysRealToReal32;

//end SmSys.


///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ DAT (��������� ������)
//���� SMDAT.M

//implementation module SmDat;
//import Win32,Win32Ext,SmSys;

//===============================================
//                 �������������
//===============================================

//--------- ���������� �������� ---------------

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

//---------- �������� �������� ----------------

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

//-------- ������������� �������� -------------

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

//-------- ������������� ����������------------

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

//-------------- ������������ -----------------

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

//----------- ��������� �� ������ -------------

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

//----------- �������� �� ������ --------------

procedure lexTest(bitTest:boolean; var Stream:recStream; errText,errMes:pstr);
begin
  if bitTest then
    lexError(Stream,errText,errMes)
  end
end lexTest;

//- �������� �� ����������������� ������������� -

procedure okREZ(var S:recStream; rez:classREZ):boolean;
begin
  with S do
    return (stLex=lexREZ)and(stLexInt=integer(rez))
  end
end okREZ;

//--------- �������� �� ����������� -----------

procedure okPARSE(var S:recStream; par:classPARSE):boolean;
begin
  with S do
    return (stLex=lexPARSE)and(stLexInt=integer(par))
  end
end okPARSE;

//------ �������� �� ������� ���������� -------

procedure okASM(var S:recStream; instr:classCommand):boolean;
begin
  with S do
    return (stLex=lexASM)and(stLexInt=integer(instr))
  end
end okASM;

//end SmDat.
///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TAB (������� ���������������)
//���� SMTAB.M

//implementation module SmTab;
//import Win32,Win32Ext,SmSys,SmDat;

//===============================================
//           ������� ��������������
//===============================================

//----- ������������� ��������� ������ --------

  procedure idInitial(var tab:pID; no:integer);
  var i:integer; initID:pID; carType:classTYPE;
  begin
//  ������� ����
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

//-------- ������������ ������� ---------------

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

//------------ ������ ������ ------------------

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

//-------- ������� �������������� -------------

  procedure idInsert(var tab:pID; name:pstr; Class:classID; ta:classTab; no:integer):pID;
  var p,own:pID;
  begin
//����������
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
//������� ��������������
    if tab=nil then tab:=own //������ �������
    else //����� � �������
      p:=tab;
      while (lstrcmp(name,p^.idName)<>0)and(
            (lstrcmp(name,p^.idName)> 0)and(p^.idRight<>nil)or
            (lstrcmp(name,p^.idName)<=0)and(p^.idLeft <>nil)) do
        if lstrcmp(name,p^.idName)>0
          then p:=p^.idRight
          else p:=p^.idLeft;
        end
      end;
//���������� � �������
      if (name<>nil)and(name[0]<>char(0))and(name[0]<>'#')and
         (Class<>idvPAR)and(Class<>idvVPAR)and
         boolean(p^.idActiv) and (lstrcmp(name,p^.idName)=0) then //������
        memFree(own^.idName);
        memFree(own);
        own:=nil
      else //�������
        if lstrcmp(name,p^.idName)>0
          then own^.idRight:=p^.idRight; p^.idRight:=own
          else own^.idLeft :=p^.idLeft;  p^.idLeft :=own
        end
      end
    end;
    if own=nil then
      mbS(_���������_�������������[envER]); mbI(ord(ta),name)
    end;
    return own
  end idInsert;

// ������� �������������� � ������� �������� --

  procedure idInsertGlo(name:pstr; Class:classID):pID;
  begin
    return idInsert(tbMod[tekt].modTab,name,Class,tabMod,tekt)
  end idInsertGlo;

//----------- ����� � ������� -----------------

  procedure idFind(var tab:pID; name:pstr):pID;
  var p:pID;
  begin
    if tab=nil then return nil //������ �������
    else //����� � �������
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

//-------- ����� �� ���� �������� -------------

  procedure idFindGlo(name:pstr; bitFix:boolean):pID;
  var p:pID; i:integer; s:string[maxText]; l:integer;
  begin
    p:=nil;
//���� with
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
//������� ������
    if p=nil then
      p:=idFind(tbMod[tekt].modTab,name);
    end;
//������
    for i:=1 to topMod do
      if tbMod[i].modAct then
        if p=nil then
          p:=idFind(tbMod[i].modTab,name);
        end
      end
    end;
//������������ idMods
    if bitFix and(p<>nil) then
      l:=1;
      for i:=1 to tekt-1 do
        l:=l*2;
      end;
      p^.idSou:=p^.idSou or l;
    end;
    return p
  end idFindGlo;

//------ ������ ������ � ���� --------

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

//------ ������ ������ �� ����� --------

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

//------ ������ ������ �� ������ ������ (������) --------

  procedure idSubsFFFF(var id:pID; car:pID);
  begin
    if (id<>nil)and(id^.idNom<>car^.idNom) then
      id:=address(-1)
    end;
  end idSubsFFFF;

//------ ������ ������ �� ������ ������ � ������ (������) --------

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

//------ ������ ������ �� ������ ������ --------

  procedure idWriteFFFF(fil:integer; id,org:pID);
  begin
    if id=address(-1) then
      _lwrite(fil,addr(org^.idNom),1);
      idWriteS(fil,org^.idName);
    end;
  end idWriteFFFF;

//------ ������ ������ �� ������ ������ � ������ --------

  procedure idWriteLIST(fil:integer; list,org:pLIST; max:integer);
  var j:integer;
  begin
    for j:=1 to max do
      idWriteFFFF(fil,list^[j],org^[j]);
    end
  end idWriteLIST;

//------ ������ ������ �� ������ ������ (������) --------

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

//------ ������ ������ �� ������ ������ � ������ (������) --------

  procedure idReadLIST(var S:recStream; fil:integer; list:pLIST; max:integer);
  var j:integer;
  begin
    for j:=1 to max do
      idReadFFFF(S,fil,list^[j]);
    end
  end idReadLIST;

//------ ������ �������������� �� ���� --------

  procedure idWriteID(id:pID; fil:integer);
  var i:integer; buf:recID; list,list2:pLIST;
  begin
    buf:=id^;
    list:=nil;
    list2:=nil;
  with buf do
  //������ ������ �� ������� ������
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
  //������ ��������������
    _lwrite(fil,addr(buf),sizeof(recID));
    i:=lstrlen(idName);
    _lwrite(fil,addr(i),4);
    if i>0
      then _lwrite(fil,idName,i)
      else mbI(integer(idClass),_������_�������������_���_�����[envER])
    end;
  //������ �������
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
  //������ ������ �� ������� ������
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

//------ ������ �������������� � ����� --------

  procedure idReadID(var S:recStream; id:pID; fil:integer):boolean;
  var i:integer;
  begin
  with id^ do
  //������ ��������������
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
  //������ �������
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
    //������ ������ �� ������� ������
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

//--------- ������ ������� �� ���� ------------

  procedure idWrite(var tab:pID; fil:integer);
  begin
  if tab<>nil then
    idWriteID(tab,fil);
    idWrite(tab^.idLeft,fil);
    idWrite(tab^.idRight,fil);
  end
  end idWrite;

//----------- ������ ������ ������ ��� ������� ------------------

procedure tabGetImpNo(var S:recStream; oldNo:integer; bitMess:boolean):integer;
var i:integer;
begin
  if oldNo>topModImp then lexTest(bitMess,S,_��������_�����_������[envER],nil);
  else
    for i:=1 to topMod do
    if lstrcmpi(tbMod[i].modNam,tbModImp[oldNo])=0 then
      return i
    end end
  end;
  lexTest(bitMess,S,_��_������_������_[envER],tbModImp[oldNo]);
  return 0
end tabGetImpNo;

//----------- ����� �������������� ��� ������� ------------------

procedure tabGetImpId(var S:recStream; no:integer; name:pstr; bitMess:boolean):pID;
var res:pID;
begin
  if no=0 then return nil end;
  res:=idFind(tbMod[no].modTab,name);
  lexTest(bitMess and(res=nil),S,_�_������_��_������_�������������_[envER],name);
  return res
end tabGetImpId;

//-------------- ������ ������ ----------------

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

//-------------- ������ ������ ----------------

  procedure tabSubs(sub:classSub; var id:pID; baseId:pID; no:integer);
  var s:string[maxText];
  begin
  if (cardinal(id) and 0x80000000)<>0 then
    with tbMod[no] do
      if tabSub(modSbs[sub],modTop[sub],id) then return end
    end;
    lstrcpy(s,_���������_�_tabSubs_[envER]);
    lstrcat(s,baseId^.idName);
    mbI(ord(sub),s)
  end
  end tabSubs;

//---------- ������ �������������� ------------

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

//--------- ������ ������� � ����� ------------

  procedure idRead(var S:recStream; var tab:pID; fil:integer; no:integer);
  var id:recID; p,own,left,right:pID; i,j,newNom:integer; sub:classSub;
  begin
  with tbMod[no] do
//������������� ������� ������ ������
    for sub:=subNULL to subPAR do
      if modSbs[sub]=nil then
        modSbs[sub]:=memAlloc(sizeof(arrSubs))
      end;
      modTop[sub]:=0;
    end;
//������ ���������������
    p:=memAlloc(sizeof(recID));
    while idReadID(S,p,fil) do
      envInf(_������_[envER],genNameModule,_llseek(fil,0,1)*100 div _lsize(fil));
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
      else mbS(_���������_������_�_idRead[envER])
      end
    end;
    memFree(p);
//�������������� ����������
    for sub:=subNULL to subPAR do
    for i:=1 to modTop[sub] do
      tabSubsID(modSbs[sub]^[i],no)
    end end;
//���������� ����������� �������
    for sub:=subNULL to subPAR do
    for i:=1 to modTop[sub] do
      modSbs[sub]^[i]^.idOwn:=modSbs[sub]^[i];
    end end;
  end
  end idRead;

//--------- ����� ������ ������ ------------

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

//---- ������ ������� � ���� (����������) -----

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
//            ������ ��������������
//===============================================

//---------- ������� � ������ -----------------

  procedure listAdd(addLIST:pLIST; addID:pID; var addTop:integer);
  begin
    if addTop<maxLIST then
      inc(addTop);
      addLIST^[addTop]:=addID
    else mbS(_������������_������_���������������[envER])
    end
  end listAdd;

//----------- ����� � ������ -----------------

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

//--------- ������� � ������ ����� ------------

  procedure subAdd(addSUB:pSubs; addID:pID; var addTop:integer);
  begin
    if addTop<maxSubs then
      inc(addTop);
      addSUB^[addTop]:=addID
    else mbS(_������������_������_�����[envER])
    end
  end subAdd;

//----------- �������� � ������ ���� -----------------

  procedure nameAdd(list:pName; name:pstr; var top:integer);
  begin
    if top<maxLIST then
      inc(top);
      list^[top]:=memAlloc(lstrlen(name)+1);
      lstrcpy(list^[top],name);
    else mbS(_������������_������_���������������[envER])
    end
  end nameAdd;

//----------- ����� � ������ ���� -----------------

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
//               ������ �������
//===============================================

//--------- ����� � ������ ������� -----------

  procedure impFind(addIMP:pIMPORT; addDLL,addFun:pstr; var addTop,nomDLL,nomFun:integer);
  var i:integer;
  begin
    nomDLL:=0;
    nomFun:=0;
    if addIMP<>nil then
//����� DLL
      for i:=1 to addTop do
      if lstrcmp(addDLL,addIMP^[i].impName)=0 then
        nomDLL:=i
      end end;
      if nomDLL<>0 then
      with addIMP^[nomDLL] do
//����� �������
        for i:=1 to impTop do
        if lstrcmp(addFun,impFuns^[i].funName)=0 then
          nomFun:=i
        end end
      end end
    end
  end impFind;

//-------- ������� � ������ ������� ------------

  procedure impAdd(addIMP:pIMPORT; addDLL,addFun:pstr; addAddr:integer; var addTop:integer):address;
  var i,nomDLL,nomFun:integer;
  begin
  if addIMP=nil then mbS(_�����������������_������_�������[envER])
  else
//����������� DLL
    impFind(addIMP,addDLL,addFun,addTop,nomDLL,nomFun);
    if nomDLL=0 then
    if addTop=maxImpDLL then mbS(_�������_�����_�������_DLL[envER])
    else
      inc(addTop);
      with addIMP^[addTop] do
        impName:=memAlloc(lstrlen(addDLL)+1); lstrcpy(impName,addDLL);
        impFuns:=memAlloc(sizeof(arrIMPFUN));
        impTop:=0;
      end;
      nomDLL:=addTop
    end end;
//����������� �������
    if nomFun=0 then
    with addIMP^[nomDLL] do
    if impTop=maxImpFun then mbS(_�������_�����_�������_DLL[envER])
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
//���������� ������ �������
    if addAddr<>0 then
    with addIMP^[nomDLL].impFuns^[nomFun] do
    if funTop=maxImpCALL then mbS(_�������_�����_�������_DLL[envER])
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

//--------- ������� ������ ������� ------------

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

//------ ������ � ���� ������ ������� ---------

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

//----- ������ �� ����� ������ ������� --------

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

//--------- �������� � ������ �������� ------------

  procedure expAdd(expo:pEXPORT; name:pstr; var top:integer);
  var pos,i:integer;
  begin
    if top=maxExport then mbS(_�������_�����_��������������_����[envER])
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

//--------- ������� ������ �������� ------------

  procedure expDestroy(expo:pEXPORT; top:integer);
  var i:integer;
  begin
    for i:=1 to top do
      memFree(expo^[i]);
    end;
    memFree(expo)
  end expDestroy;

//------ ������ � ���� ������ �������� ---------

  procedure expWrite(expo:pEXPORT; top:integer; fil:integer);
  var i,j,l:integer;
  begin
    for i:=1 to top do
      l:=lstrlen(expo^[i]);
      _lwrite(fil,addr(l),4);
      _lwrite(fil,expo^[i],lstrlen(expo^[i]));
    end
  end expWrite;

//----- ������ �� ����� ������ �������� --------

  procedure expRead(expo:pEXPORT; top:integer; fil:integer);
  var i,j,l:integer;
  begin
    for i:=1 to top do
      _lread(fil,addr(l),4); expo^[i]:=memAlloc(l+1);
      _lread(fil,expo^[i],l); expo^[i][l]:=char(0);
    end
  end expRead;

//===============================================
//               ������ �����
//===============================================

//---------- ������� � ������ -----------------

  procedure stringAdd;
  begin
    if addTop<maxSTRING then
      inc(addTop);
      with addSTRING^[addTop] do
        stringSou:=addSou;
        stringPoi:=memAlloc(lstrlen(addStr)+1);
        lstrcpy(stringPoi,addStr);
      end;
    else mbS(_������������_������_���������_��������[envER])
    end
  end stringAdd;

//----------- ������� ������ ------------------

  procedure stringFree;
  var i:integer;
  begin
    for i:=1 to addTop do
      memFree(addSTRING^[i].stringPoi)
    end;
    addTop:=0
  end stringFree;


//===============================================
//            ������ �� ������� �������
//===============================================

//----------- �������� � ������ ������� ------------------

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

//----------- ��������� ����� � ���� ------------------

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

//----------- ������� ����� �� ����� ------------------

  procedure stepPop();
  begin
    if stepTopStack=0
      then mbS(_���������_������_�_stepPop[envER])
      else dec(stepTopStack);
    end
  end stepPop;

//===============================================
//            �������������� ����
//===============================================

//------------ ������ Progress --------------

const DIALOGINFO=stringER{"DIALOGINFO_R","DIALOGINFO_E"};

dialog DIALOGINFO_R 65, 55, 200, 47,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "����������"
begin
  control "���������", 101, "Static", 0 | WS_CHILD | WS_VISIBLE, 12, 6, 174, 10
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

//-------- ���������� ������� Progress --------

  procedure winDlgProg(Wnd:HWND; Message,wParam,lParam:integer):boolean;
  begin
    case Message of
      WM_INITDIALOG:|
      WM_COMMAND:case wParam of
        121:if MessageBox(0,_����������_���������__[envER],"��������:",MB_YESNO)=IDYES then
          infCancel:=true
        end;|
      end;|
    else return false
    end;
    return true
  end winDlgProg;

//------------ �������� Progress --------------

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

//------------ �������� Progress --------------

  procedure envInfEnd;
  begin
    DestroyWindow(infDlg);
  end envInfEnd;

//---------- ��������� � Progress -------------

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

//end SmTab.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ GEN (��������� ����)
//���� SMGEN.M

//implementation module SmGen;
//import Win32,Win32Ext,SmSys,SmDat,SmTab;

//===============================================
//           ������������� � ����������
//===============================================

//------------ ������������� ------------------

  procedure genInitial();
  var i:integer;
  begin
    genPushAX:=-1;
    genPushSI:=-1;
    genCall:=memAlloc(sizeof(lstCall)); genCall^.top:=0;
    genSort:=memAlloc(sizeof(arrSortRes)); topSortRes:=0;
  end genInitial;

//--------------- �������� --------------------

  procedure genDestroy();
  begin
    memFree(genCall);
    memFree(genSort);
  end genDestroy;

//===============================================
//             ������ �� ��������
//===============================================

//----- ���������� � ������ ��������� ---------

  procedure genAddJamp;
  begin
  with aList do
    if top=maxJamp then
      lexError(S,_�������_�����_��������_IF_���_CASE[envER],nil)
    else inc(top)
    end;
    arr[top].jaddr:=aVal;
    arr[top].jcomm:=aCom;
  end
  end genAddJamp;

//----------- ��������� ��������� -------------

  procedure genSetJamps;
  var i:integer; l:integer;
  begin
  with aList do
    for i:=1 to top do
      genSetJamp(S,arr[i].jaddr,aVal,arr[i].jcomm)
    end
  end
  end genSetJamps;

//----------- ��������� �������� --------------

  procedure genSetJamp;
  var i:integer; l,siz:integer;
  begin
  with tbMod[tekt] do
    case aCom of
      cJL..cJPE:siz:=6;|
      cJMP:siz:=5;|
    else lexError(S,_���������_�_genSetJamp_[envER],addr(asmCommands[aCom].cNam));
    end;
    l:=aLab-aJamp-siz;
    genCode^[aJamp+siz-3+0]:=lobyte(loword(l));
    genCode^[aJamp+siz-3+1]:=hibyte(loword(l));
    genCode^[aJamp+siz-3+2]:=lobyte(hiword(l));
    genCode^[aJamp+siz-3+3]:=hibyte(hiword(l));
  end
  end genSetJamp;

//----- ���������� � ������ ������� -----------

  procedure genAddCall(var S:recStream; aSou:integer; aProc:pID);
  begin
  with genCall^ do
    if top=maxCall
      then lexError(S,_�������_�����_�������_��������_�_������[envER],nil)
      else inc(top)
    end;
    arr[top].callSou:=aSou;
    arr[top].callProc:=aProc;
  end
  end genAddCall;

//--------- ��������� ������� -----------------

  procedure genSetCalls(var S:recStream; var calls:lstCall; nom:integer; bitMessage:boolean);
  var i,l,f:integer;
  begin
  with tbMod[nom],calls do
    topProCall:=0;
    for i:=1 to top do
    with arr[i],callProc^ do
      if (idProcAddr=-1)and(idNom=nom) then if bitMessage then lexError(S,_��_����������_���������_[envER],idName) end
      elsif (callSou+2+0<=0)or(callSou+2+3>topCode) then lexError(S,_���������_������_�_GenSetCalls[envER],nil)
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

//--------- ����� ���������� ���������� -----------------

  procedure genAddVarCall(var S:recStream; tekno,no,track:integer; cl:classVarCall; cla:pstr);
  begin
    with tbMod[tekno] do
      if topVarCall=maxVarCall then lexError(S,_�������_�����_���������_�_����������_�_������[envER],nil)
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

//--------- ����� ��������� �� ������� ������ -----------------

  procedure genAddProCall(var S:recStream; tekno,no,track:integer; sou:pstr);
  begin
    with tbMod[tekno] do
      if topProCall=maxProCall then lexError(S,_�������_�����_�������_�������_��������_�_������[envER],nil)
      else
        inc(topProCall);
        genProCall^[topProCall].track:=track;
        genProCall^[topProCall].sou:=memAlloc(lstrlen(sou)+1); lstrcpy(genProCall^[topProCall].sou,sou);
        genProCall^[topProCall].mo:=memAlloc(lstrlen(tbMod[no].modNam)+1); lstrcpy(genProCall^[topProCall].mo,tbMod[no].modNam);
      end
    end
  end genAddProCall;

//--------- ����������� �������� ��������� -----------------

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
    if no=0 then lexError(S,_��_������_������_[envER],mo)
    elsif id=nil then lexError(S,_��_������_�������������_[envER],sou)
    elsif id^.idClass<>idPROC then lexError(S,_��_�������_�������_[envER],sou)
    else return tbMod[no].genBegCode+id^.idProcAddr
    end;
    return 0
  end genGetProcTrack;

//===============================================
//             ���������� ��������
//===============================================

//----------- ���������� ����� ----------------

  procedure genPutByte;
  begin
  with tbMod[tekt] do
    if topData=maxData then lexError(Stream,_�������_�����_�����������_��������[envER],nil)
    else
      inc(topData);
      genData^[topData]:=putByte;
      return topData-1
    end
  end
  end genPutByte;

//----------- ���������� ������ ---------------

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

//----------- ���������� ������� --------------

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
//                ���������� ����
//===============================================

//----------- ���������� ����� ----------------

  procedure genByte(var Stream:recStream; b:byte);
  begin
  with tbMod[tekt] do
    if topCode=maxCode
      then lexError(Stream,_�������_�������_���[envER],"")
      else inc(topCode)
    end;
    genCode^[topCode]:=b
  end
  end genByte;

//----------- ���������� ����� ----------------

  procedure genCard(var Stream:recStream; w:cardinal; bitW:boolean);
  begin
    genByte(Stream,lobyte(loword(w)));
    if bitW then
      genByte(Stream,hibyte(loword(w)))
    end
  end genCard;

//------- ���������� �������� ����� -----------

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

//----------- ������� �������� ----------------

  procedure genPref;
  begin
    case prefReg of
      regNULL:|
      rCS:genByte(Stream,0x2E);|
      rSS:genByte(Stream,0x36);|
      rDS:genByte(Stream,0x3E);|
      rES:genByte(Stream,0x26);|
    else mbS(_genPref_���������_������[envER])
    end
  end genPref;

//----------- ���� ������� --------------------

  procedure genFirst(var Stream:recStream; firstCod,firstPri:byte; D,W:cardinal);
  begin
  with tbMod[tekt] do
    lexTest((envError>0)and(genBegCode+topCode>=envError),Stream,_�����_������_����������[envER],nil);
    if firstPri and 2<>0 then if D<>0 then firstCod:=firstCod or 2 end end;
    if firstPri and 1<>0 then if (W=2)or(W=4) then firstCod:=firstCod or 1 end end;
    genByte(Stream,firstCod);
  end
  end genFirst;

//-------- �������� � �������� ������� --------

  procedure genPost(var S:recStream; PostExt:byte; Base,Indx:classRegister; Dist:integer);
  var md,rm:byte;
  begin
//������ BP
    if (Base=rEBP)and(Indx=regNULL)and(Dist=0) then
      genByte(S,0x45 or PostExt);
      genByte(S,0)
//������ ��������
    elsif (Base=regNULL)and(Indx=regNULL) then
      genByte(S,0x05 or PostExt);
      genLong(S,Dist,4)
//��� ��������
    elsif Dist=0 then
      case Base of
        regNULL:case Indx of
          rEAX:genByte(S,0x00 or PostExt);|
          rESI:genByte(S,0x06 or PostExt);|
          rEDI:genByte(S,0x07 or PostExt);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        rEBX:case Indx of
          regNULL:genByte(S,0x03 or PostExt);|
          rESI:genByte(S,0x04 or PostExt); genByte(S,0x33);|
          rEDI:genByte(S,0x04 or PostExt); genByte(S,0x3B);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        rEBP:case Indx of
          rESI:genByte(S,0x44 or PostExt); genByte(S,0x33); genByte(S,0x00);|
          rEDI:genByte(S,0x44 or PostExt); genByte(S,0x3B); genByte(S,0x00);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        else lexError(S,_��������_�������__genPost_[envER],"");
      end
//�� ��������� ����
    elsif (Dist<=127)and(Dist>=-128) then
      case Base of
        regNULL:case Indx of
          rEAX:genByte(S,0x40 or PostExt);|
          rESI:genByte(S,0x46 or PostExt);|
          rEDI:genByte(S,0x47 or PostExt);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        rEBX:case Indx of
          regNULL:genByte(S,0x43 or PostExt);|
          rESI:genByte(S,0x44 or PostExt); genByte(S,0x33);|
          rEDI:genByte(S,0x44 or PostExt); genByte(S,0x3B);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        rEBP:case Indx of
          regNULL:genByte(S,0x45 or PostExt);|
          rESI:genByte(S,0x44 or PostExt); genByte(S,0x35);|
          rEDI:genByte(S,0x44 or PostExt); genByte(S,0x3D);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
      end;
      genByte(S,Dist)
//�� ��������� long
    else
      case Base of
        regNULL:case Indx of
          rEAX:genByte(S,0x80 or PostExt);|
          rESI:genByte(S,0x86 or PostExt);|
          rEDI:genByte(S,0x87 or PostExt);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        rEBX:case Indx of
          regNULL:genByte(S,0x83 or PostExt);|
          rESI:genByte(S,0x84 or PostExt); genByte(S,0x33);|
          rEDI:genByte(S,0x84 or PostExt); genByte(S,0x3B);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        rEBP:case Indx of
          regNULL:genByte(S,0x85 or PostExt);|
          rESI:genByte(S,0x84 or PostExt); genByte(S,0x35); genByte(S,0x00);|
          rEDI:genByte(S,0x84 or PostExt); genByte(S,0x3D); genByte(S,0x00);|
          else lexError(S,_��������_�������__genPost_[envER],"");
        end;|
        else lexError(S,_��������_�������__genPost_[envER],"");
      end;
      genLong(S,Dist,4)
    end
  end genPost;

//------- ������� ���������� ��������� --------

  procedure genSeg;
  begin
    case Instr of
      cMOV:
        if (Reg1 in [rCS..rGS]) and (Reg2 in [rCS..rGS]) then
          lexError(Stream,_��������_��������[envER],"")
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
    else lexError(Stream,_���������_�_GenSeg[envER],"");
    end
  end genSeg;

//-------- ������� �������-������� ------------

  procedure genRR;
  begin
  with asmCommands[Instr] do
    if not (Instr in [loMDCom..hiMDCom]) then
      lexError(Stream,_���������_�_GenRR[envER],"")
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

//------- ������� �������-��������� -----------

  procedure genRD;
  var W:cardinal;
  begin
  with asmCommands[Instr] do
    if not ((Instr in [loMDCom..hiMDCom]) or (Instr in [loRCom..hiRCom])) then
      lexError(Stream,_���������_�_GenRD[envER],"")
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
        lexError(Stream,'� ������� ������ ������� ������ ���� ������ 32',nil)
      end;
      genByte(Stream,Data)
    end
  end
  end genRD;

//----------- ������� �������-������ ----------

  procedure genMR;
//  {D: 0-MR, 1-RM}
  begin
  with asmCommands[Instr] do
    if not (Instr in [loMDCom..hiMDCom]) then
      lexError(Stream,_���������_�_GenMR_[envER],addr(cNam))
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

//----------- ������� ������-��������� --------

  procedure genMD(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx:classRegister; Dist,Data:integer; W:cardinal);
  begin
  with asmCommands[Instr] do
    if not (Instr in [loMDCom..hiMDCom]) then
      lexError(Stream,_���������_�_GenMD[envER],"")
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

//----------- ������� ������������ ------------

  procedure genST;
  begin
  with asmCommands[Instr] do
    genByte(Stream,0xD8 or (cDat div 32));
    genByte(Stream,0xC0 or (cDat mod 8) or asmRegs[Reg].rCo);
  end
  end genST;

//----------- ������� _�������[envER] ---------------

  procedure genR;
  var Cod:byte;
  begin
  with tbMod[tekt] do
//�����������
    if (Instr=cPUSH)and(Reg=rEAX) then genPushAX:=topCode+1 end;
    if (Instr=cPUSH)and(Reg=rESI) then genPushSI:=topCode+1 end;
//��������� �������
  with asmCommands[Instr] do
    Cod:=cCod;
    if not ((Instr in [loMCom..hiMCom]) or (Instr in [loRCom..hiRCom]) or (Instr in [loFRCom..hiFRCom])) then
      lexError(Stream,_���������_�_GenR[envER],"")
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

//----------- ������� _������[envER] ----------------

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
        lexError(Stream,_���������_�_GenM_[envER],addr(asmCommands[Instr].cNam))
    end;
    genPref(Stream,PrefS);
    if W=2 then genByte(Stream,0x66) end;
    genFirst(Stream,Cod,cPri,1,W);
    genPost(Stream,cExt,Base,Indx,Dist);
    if Instr=cPOP then dec(genStack,4) end;
    if Instr=cPUSH then inc(genStack,4) end;
  end
  end genM;

//- ������� � ���������������� ��������� ------

  procedure genD;
  begin
  with asmCommands[Instr],tbMod[tekt] do
    if not ((Instr=cRET)or(Instr=cINT)or(Instr=cPUSH)) then
      lexError(Stream,_���������_�_GenD[envER],"")
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

//--------- ������� ��� ���������� ------------

  procedure genGen(var Stream:recStream; Instr:classCommand; W:integer);
  begin
  with asmCommands[Instr] do
    if not (
      Instr in [loNCom..hiNCom,loLCom..hiLCom,loFCom..hiFCom,
        cAAM,cAAD,cCALL,cENTER,cLEAVE]) then
        lexError(Stream,_���������_������_�_genGen_[envER],addr(asmCommands[Instr].cNam))
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

//--------- ��������� ROL REG,CL --------------

  procedure genRegCL;
  begin
  with asmCommands[Instr] do
    if not (Instr in [loRCom..hiRCom]) then
      lexError(Stream,_���������_������_�_genRCL[envER],nil)
    end;
    if Reg in [rAL..rDH] then genFirst(Stream,cDat or 2,cPri,1,1)
    elsif Reg in [rAX..rDI] then genByte(Stream,0x66); genFirst(Stream,cDat or 2,cPri,1,1)
    else genFirst(Stream,cDat or 2,cPri,1,4)
    end;
    genByte(Stream,0xC0 or cExt or asmRegs[Reg].rCo);
  end
end genRegCL;

//----------- ����������� POP -----------------

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
//             ��������� � ������ I-�����
//===============================================

//------------- ������ BMP � ���� ------------------

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

//------------- ������ BMP �� ����� ------------------

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

//------------- ������ DLG � ���� ------------------

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

//------------- ������ DLG �� ����� ------------------

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
//             ��������� EXE-�����
//===============================================

//------------- ������������ ------------------

procedure genAlign;
begin
  if align=0 then return siz
  elsif siz mod align=0 then return siz
  else return siz - siz mod align + align
  end
end genAlign;

//------------- ������� ������ ----------------

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
    exeIData:if gloImport=nil then mbS(_���������_�_genSize[envER])
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
        inc(sSize,4) //{0 �������}
      end end;
      inc(sSize,sizeof(imageImportDesctriptor)) //{0 �������}
    end;|
    exeEData:if gloExport=nil then mbS(_���������_�_genSize_2[envER])
    else
      sSize:=sizeof(imageExportDesctriptor)+gloTopExp*4+gloTopExp*4+gloTopExp*2;
      for i:=1 to gloTopExp do
        inc(sSize,lstrlen(gloExport^[i])+1);
      end;
      inc(sSize,lstrlen(genNameModule)+1); //��� �����
    end;|
    exeText:
      for i:=1 to topMod do
        inc(sSize,tbMod[i].topCode)
      end;|
    exeRsrc:
//    ��������� ������
      sSize:=0x30+0x10+0x10+0x10+0x10+0x10+0x28;
      for i:=1 to topMod do
      with tbMod[i] do
        for j:=1 to topMDlg do
//        directory_entry � data_entry
          inc(sSize,16+8);
//        ��� �������
          inc(sSize,genAlign((lstrlen(modDlg^[j]^.mdCon[0]^.miNam)+1)*2,4));
//        ������ �������
          inc(sSize,genSizeDlg(i,j))
        end;
        for j:=1 to topBMP do
//        directory_entry � data_entry
          inc(sSize,16+8);
//        ��� �������
          inc(sSize,genAlign((lstrlen(modBMP^[j].bmpName)+1)*2,4));
//        ������ bmp
          inc(sSize,modBMP^[j].bmpSize)
        end;
      end end;
//    ������
      globalICON:=0;
      for i:=1 to topMod do
      with tbMod[i] do
        if modICON<>nil then
          globalICON:=1;
        end
      end end;
      if globalICON>0 then
      //�������� icon � group
        inc(sSize,8+16+8);
        inc(sSize,8+16+8);
      //����� � ������ icon � group
        inc(sSize,16);
        inc(sSize,16);
        inc(sSize,sizeof(res_icon)+0x2e8);
      end;|
  end;
  return genAlign(sSize,align)
end genSize;

//------ ��������� ������ ������� -------------

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

//------ ��������� ������ �������� -------------

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

//--------- ����� �������� ������ ----------------

procedure genBaseCla(cla:pID):pID;
begin
  while (cla^.idRecCla<>cla^.idOwn)and(cla^.idRecCla<>nil) do
    cla:=cla^.idRecCla
  end;
  return cla
end genBaseCla;

//-------------- ����� ������ -------------------

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

//------ ���������� �������� � ������� ������� -------------

procedure genClassAlloc(var S:recStream; met:integer; var top:integer; main:integer);
begin
  with tbMod[main] do
  if top+4>genCLASSSIZE then lexError(S,_����������_�������_�������_�������[envER],nil);
  else
    genData^[maxWith*4+top+1]:=lobyte(loword(met));
    genData^[maxWith*4+top+2]:=hibyte(loword(met));
    genData^[maxWith*4+top+3]:=lobyte(hiword(met));
    genData^[maxWith*4+top+4]:=hibyte(hiword(met));
    inc(top,4)
  end end;
end genClassAlloc;

//------ ��������� ������ ������� -------------

procedure genClassCreate(var S:recStream; id:pID; cla:pClasses; var top:integer);
var no,i:integer; bas:pID; s:pstr; //�� ������ �� string !
begin
  if id=nil then //��������� �����
    top:=0;
    for no:=1 to topMod do
      if tbMod[no].modTab<>nil then
        genClassCreate(S,tbMod[no].modTab,cla,top);
      end
    end
  else //����������� �����
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
          then lexError(S,_�������_�����_�������[envER],nil)
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

//------ ������� ������ ������� -------------

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

//------ ��������� ������� ������� -------------

procedure genClassTable(var S:recStream; cla:pClasses; top,main:integer);
var topTable,gru,nom,add,i:integer; s:string[maxText]; met:pID;
begin
  topTable:=0;
//������ �������
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
//������ �������
  genClassBegin:=genBASECODE+0x1000+tbMod[main].genBegData+maxWith*4+topTable;
  for gru:=1 to top do
  with cla^[gru] do
    for nom:=1 to claListTop do
      genClassAlloc(S,integer(claAddr^[nom]),topTable,main);
    end
  end end
end genClassTable;

//------ ����� ������ � ������� ������� -------------

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

//------ ����� ������ � ������� ������� -------------

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

//------------ ��������� ����� ----------------

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
      0://�������
        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000);
        vsize:=genSize(exeEData,0);|
      1://������
        virtualAddress:=0x1000+genSize(exeData,0x1000);
        vsize:=genSize(exeIData,0);|
      2://�������
        virtualAddress:=0x1000+genSize(exeData,0x1000)+genSize(exeIData,0x1000)+genSize(exeEData,0x1000)+genSize(exeText,0x1000);
        vsize:=genSize(exeRsrc,0);|
      else
        virtualAddress:=0;
        vsize:=0;
    end
  end end
end
end genWinHeader;

//------------ ������� ��������� --------------

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

//--- ������� ��������� ������� ������� -------

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
//������ imageImportDesctriptor
  inc(res,(gloTop+1)*sizeof(imageImportDesctriptor));
//������ ���� DLL
  inc(res,genTrackDLL(gloTop+1));
//���������� Thunk
  for i:=1 to dll-1 do
  with gloImport^[i] do
//  ������ ����������
    inc(res,(impTop+1)*4);
//  ������ ���� �������
    inc(res,genTrackFun(i,impTop+1))
  end end;
  return res
end genTrackThunk;

//--- �������� ��������� ������� �������� -------

procedure genTrackExp(nom:integer):integer;
var res,i:integer;
begin
  res:=0;
  for i:=1 to nom-1 do
    inc(res,lstrlen(gloExport^[i])+1);
  end;
  return res
end genTrackExp;

//------- ���������� ���� �������� ------------

procedure genSortResource();
var i,j,k:integer; res:recSortRes;
begin
  topSortRes:=0;
//�������������
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
//����������
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

//------ �������� ��������� �������� ----------

procedure genTrackResName(m,d:integer; bitDlg:boolean):integer;
//0,0 - ����� ������ ������ ����
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
    mbS(_���������_������_�_genTrackResName[envER])
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

//----------- ��������� ������� ---------------

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
//��������� ���������
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
    if miFont<>nil then //�����
      genDlgWORD(pDlg,topDlg,miSize);
      genDlgSTR(pDlg,topDlg,miFont);
    end;
    while topDlg mod 4<>0 do //������������ ����� ������� �� dword
      genDlgCHAR(pDlg,topDlg,char(0))
    end
  end;
//��������� ���������
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
    while topDlg mod 4<>0 do //������������ ����� �������� �� dword
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
//��������� ���������
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
//��������� ���������
  for i:=1 to mdTop do
  with mdCon[i]^ do
    inc(topDlg,4); //style
    inc(topDlg,4); //ext style
    inc(topDlg,8);
    inc(topDlg,2); //ID
    inc(topDlg,(lstrlen(miCla)+1)*2); //class
    inc(topDlg,(lstrlen(miTxt)+1)*2); //caption
    inc(topDlg,2); //create data !�� ����������� �� DWORD!
    while topDlg mod 4<>0 do //������������ ����� �������� �� dword
      inc(topDlg)
    end
  end end;
  return topDlg
end
end genSizeDlg;

//------------ ������������ ����� ����� ������ ---------------

procedure genIconMas(nom:integer; pIcon:pstr):char;
var ���,����������,����������:integer; ���,����:byte; �����:boolean;
begin
  ���:=0;
  return char(���);//��������
  for ���:=0 to 7 do //���� �� ����� ����������
    ����������:=nom*8+���;
    ����������:=���������� div 2;
    ����:=byte(pIcon[40+16*4+����������]);
    if ���������� mod 2=1
      then �����:=(���� and 0x0F)=0x0F;
      else �����:=(���� and 0xF0)=0xF0;
    end;
    if ����� then
      case ��� of
        0:���:=��� or 0x01;|
        1:���:=��� or 0x02;|
        2:���:=��� or 0x04;|
        3:���:=��� or 0x08;|
        4:���:=��� or 0x10;|
        5:���:=��� or 0x20;|
        6:���:=��� or 0x40;|
        7:���:=��� or 0x80;|
      end
    end
  end;
  return char(���);
end genIconMas;

//------------ ��������� ������ ---------------

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

//������������� ��������� ������� �������
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

//������ � ����� ���������
  _lwrite(gFile,addr(OldHeader),genSize(exeOld,0));
  genGloImport();
  genGloExport();
  genWinHeader();
  if traMakeDLL then ep:=WinHeader.entryPoint; WinHeader.entryPoint:=0 end;
  _lwrite(gFile,addr(WinHeader),genSize(exeHeader,0));
  if traMakeDLL then WinHeader.entryPoint:=ep end;

//������� ������
  for sect:=exeData to exeRsrc do
  with tbSection[sect] do //���
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

//��������� ������� �������
  genClasses:=memAlloc(sizeof(arrClasses));
  genClassesTop:=0;
  genClassCreate(S,nil,genClasses,genClassesTop);
  genClassTable(S,genClasses,genClassesTop,main);

//������ ������
  for i:=1 to topMod do
  with tbMod[i] do
    data:=memAlloc(topData);
    RtlMoveMemory(data,genData,topData);
    for j:=1 to topVarCall do //������ ����������
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

//������ ������� (������ imageImportDesctriptor)
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

//������ ������� (������ ���� �������)
  for i:=1 to gloTop do
  with gloImport^[i] do
    genWriteS(gFile,impName);
    genWriteB(gFile,0);
  end end;

//������ ������� (������ ���� �������)
  for i:=1 to gloTop do
  with gloImport^[i] do
//������ ����������
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
//������ ���� �������
    for j:=1 to impTop do
    with impFuns^[j] do
      genWriteB(gFile,0);
      genWriteB(gFile,0);
      genWriteS(gFile,funName);
      genWriteB(gFile,0);
    end end
  end end;
  genWriteAlign(gFile,0x200);

//������ ��������
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
      else track:=0; MessageBox(0,_��_����������_�����_�����_[envER],gloExport^[i],0);
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

//������ ����
  for m:=1 to topMod do
  with tbMod[m] do
    code:=memAlloc(topCode);
    RtlMoveMemory(code,genCode,topCode);
    for i:=1 to topImport do //������ ������� �������
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
    for j:=1 to topProCall do //������ ������� �������� � �������
    with genProCall^[j] do
      if lstrposc('.',sou)=-1 then //������� ���������
        l:=genGetProcTrack(S,mo,sou)-(tbMod[m].genBegCode+track)-3;
        code^[track+0]:=lobyte(loword(l));
        code^[track+1]:=hibyte(loword(l));
        code^[track+2]:=lobyte(hiword(l));
        code^[track+3]:=hibyte(hiword(l));
      else //�����
        l:=(genClassMet(genClasses,genClassesTop,sou)-1)*4;
        code^[track+7]:=lobyte(loword(l));
        code^[track+8]:=hibyte(loword(l));
        code^[track+9]:=lobyte(hiword(l));
        code^[track+10]:=hibyte(hiword(l));
      end
    end end;
    for j:=1 to topVarCall do //������ ���������� � ������� ��������
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

//������ �������� (���������)
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
  if globalICON>0 then //������
  with irde do
    Name:=0x00000003;
    OffsetToData:=0x80000000+0x30+(0x10+globalDLGs*8)+(0x10+globalBMPs*8);
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;
  if globalDLGs>0 then //�������
  with irde do
    Name:=0x00000005;
    OffsetToData:=0x80000000+0x30;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;
  if globalICON>0 then //������ ������
  with irde do
    Name:=0x0000000E;
    OffsetToData:=0x80000000+0x30+(0x10+globalDLGs*8)+(0x10+globalBMPs*8)+0x30;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;
  for i:=3 downto ird.NumberOfIdEntries do //��������
  with irde do
    Name:=0x00000000;
    OffsetToData:=0x00000000;
    _lwrite(gFile,addr(irde),sizeof(image_resource_directory_entry));
  end end;

//������ �������� (�������� DLG)
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

//������ �������� (�������� BMP)
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

//������ �������� (������� ICON)
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

//������ �������� (������� GROUP)
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

//������ �������� (����� DLG)
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

//������ �������� (����� BMP)
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

//������ �������� (���� ICON)
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

//������ �������� (���� GROUP)
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

//������ �������� (����� DLG � BMP)
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

//������ �������� (������ DLG)
  pDlg:=memAlloc(maxDlgMem);
  for i:=1 to topMod do
  for j:=1 to tbMod[i].topMDlg do
  with tbMod[i] do
    genMakeDlg(i,j,pDlg,topDlg);
    _lwrite(gFile,pDlg,topDlg);
  end end end;
  memFree(pDlg);

//������ �������� (������ BMP)
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

//������ �������� (����� ICON)
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

//������ �������� (����� GROUP)
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

//-------- ��������� ������� ����� ------------

procedure genSizeFile(gFile:integer);
var w:integer;
begin
  _llseek(gFile,2,0);
  w:=_lsize(gFile) mod 512; _lwrite(gFile,addr(w),2);
  w:=_lsize(gFile) div 512;
  if _lsize(gFile) mod 512<>0 then inc(w) end;
  _lwrite(gFile,addr(w),2)
end genSizeFile;

//---------- �������� ����� EXE-����� --------------

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

//---------- ��������� EXE-����� --------------

procedure genExe(var S:recStream; gName:pstr; no:integer);
var gFile,i,j:integer; gTab:classExe;
begin
  if lstrposc(':',gName)=-1 then
    genExeName(gName,envExeFolder,genNameModule,traMakeDLL);
    gFile:=_lcreat(genNameModule,0);
    if gFile<=0 then mbS(_EXE_����_�����_������_�����������_[envER])
    else
      genConstruct(S,gFile,no);
      genSizeFile(gFile);
      _lclose(gFile);
    end;
    lstrdel(genNameModule,lstrposc('.',genNameModule),255);
  end
end genExe;

//---------- ��������� I-����� ----------------

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
//���
  _lwrite(gFile,addr(genEntry),4);
  _lwrite(gFile,addr(genBegCode),4);
  _lwrite(gFile,addr(topCode),4);
  _lwrite(gFile,pstr(genCode),topCode);
//������
  _lwrite(gFile,addr(genBegData),4);
  _lwrite(gFile,addr(topData),4);
  _lwrite(gFile,pstr(genData),topData);
//������
  _lwrite(gFile,addr(topMod),4);
  for i:=1 to topMod do
  with tbMod[i] do
    idWriteS(gFile,modNam);
  end end;
//��������������
  idWrite(modTab,gFile);
  gId:=memAlloc(sizeof(recID));
  gId^.idClass:=idNULL;
  _lwrite(gFile,pstr(gId),sizeof(recID));
  memFree(gId);
//������� �������
  _lwrite(gFile,addr(topImport),4);
  impWrite(genImport,topImport,gFile);
//������� ��������
  _lwrite(gFile,addr(topExport),4);
  expWrite(genExport,topExport,gFile);
//������ ����������
  _lwrite(gFile,addr(topVarCall),4);
  _lwrite(gFile,pstr(genVarCall),topVarCall*(sizeof(arrVarCall) div maxVarCall));
    for i:=1 to topVarCall do
      if genVarCall^[i].cla<>nil then
        idWriteS(gFile,genVarCall^[i].cla);
      end;
    end;
//������ ��������
  _lwrite(gFile,addr(topProCall),4);
  for i:=1 to topProCall do
  with genProCall^[i] do
    _lwrite(gFile,addr(genProCall^[i]),sizeof(arrProCall) div maxProCall);
    idWriteS(gFile,mo);
    idWriteS(gFile,sou);
  end end;
//�������
  _lwrite(gFile,addr(topMDlg),4);
  genDlgWrite(gFile,modDlg,topMDlg);
  _lwrite(gFile,addr(topBMP),4);
  genBmpWrite(gFile,modBMP,topBMP);
  idWriteS(gFile,modICON);
//���������� ����������
  _lwrite(gFile,addr(topGenStep),4);
  _lwrite(gFile,pstr(genStep),topGenStep*(sizeof(arrStep) div maxStep));
  _lclose(gFile);
end end
end genDef;

//----------- ������ I-����� ------------------

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
//���
    if no=tekt
      then _lread(gFile,addr(genEntry),4)
      else _lread(gFile,addr(pass),4)
    end;
    _lread(gFile,addr(genBegCode),4);
    _lread(gFile,addr(topCode),4);
    _lread(gFile,genCode,topCode);
//������
    _lread(gFile,addr(genBegData),4);
    _lread(gFile,addr(topData),4);
    _lread(gFile,genData,topData);
//������
  _lread(gFile,addr(topModImp),4);
  lexTest(topModImp>maxMod,S,_�������_�����_�������[envER],genNameModule);
  for i:=1 to topModImp do
    idReadS(gFile,tbModImp[i])
  end;
//��������������
    idRead(S,modTab,gFile,no);
//������� �������
    _lread(gFile,addr(topImport),4);
    impRead(genImport,topImport,gFile);
//������� ��������
    _lread(gFile,addr(topExport),4);
    expRead(genExport,topExport,gFile);
//������ ����������
    _lread(gFile,addr(topVarCall),4);
    _lread(gFile,pstr(genVarCall),topVarCall*(sizeof(arrVarCall) div maxVarCall));
    for i:=1 to topVarCall do
      genVarCall^[i].no:=tabGetImpNo(S,genVarCall^[i].no,true);
      if genVarCall^[i].cla<>nil then
        idReadS(gFile,genVarCall^[i].cla);
      end;
    end;
//������ ��������
    _lread(gFile,addr(topProCall),4);
    for i:=1 to topProCall do
    with genProCall^[i] do
      _lread(gFile,addr(genProCall^[i]),sizeof(arrProCall) div maxProCall);
      idReadS(gFile,mo);
      idReadS(gFile,sou);
    end end;
//�������
    _lread(gFile,addr(topMDlg),4);
    genDlgRead(gFile,modDlg,topMDlg);
    _lread(gFile,addr(topBMP),4);
    genBmpRead(gFile,modBMP,topBMP);
    idReadS(gFile,modICON);
//���������� ����������
    _lread(gFile,addr(topGenStep),4);
    _lread(gFile,pstr(genStep),topGenStep*(sizeof(arrStep) div maxStep));
    _lclose(gFile);
    return true
  else return false
  end
end
end genImp;

//===============================================
//                    ������
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

//--------------- ��������� -------------------

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

//--------------- ���������� ------------------

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

//------------- ���������� ��� ----------------

  procedure genCloseMods();
  var i:integer;
  begin
    for i:=1 to topMod do
      genCloseMod(i)
    end
  end genCloseMods;

//end SmGen.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ LEX (����������� ������)
//���� SMLEX.M

//implementation module SmLex;
//import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen;

//=============================================
//          ������� ������ � �������
//=============================================

//----------- �������� ������ ---------------

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

//----------- �������� ������ ---------------

  procedure lexClose;
  begin
//    if Stream.stLoad then
//      memFree(Stream.stText);
  end lexClose;

//=================================================}
//=============== ����������� ������ ==============}
//=================================================}

//------- �������� �� ������ --------

  procedure lexIN(c,cLo,cHi:char):boolean;
  begin
    return (ord(c)>=ord(cLo))and(ord(c)<=ord(cHi))
  end lexIN;

//----------- ������ ������ ---------------

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

//------- ������� �� ��������� --------------

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
        fNULL:lexError(Stream,'�������� ������',nil);|
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

//------------- ��������� ������� ---------------

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

//-------- ������� �������� ---------

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
        lexTest(stLex=lexEOF,Stream,"���������� �����������",nil);|
      pMulDiv:lexNextLex(Stream,bitID);|
    else lexNextLex(Stream,bitID);
    end end
  end
  end lexComment;

//-------- ������ ������������ ������ ---------

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

//----------- ������ ������� ������ -------------

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

//----- ������ ������ 1 (����������� ��������) ----------

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

//----- ������ ������ 1 (����������� ��������� ����� ��������) ----------

  procedure lexFillVal(var Stream:recStream; valOp:classConOp);
  begin
  with Stream do
    if topStackCon=maxStackCon
      then lexError(Stream,_�������_�������_����������_���������[envER],nil)
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

//----- ������ ������ 1 (����������� ����� ��������) ----------

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

//----- ������ ������ 1 (����������� ����� ��������) ----------

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
            conDiv:if conInt=0 then lexError(Stream,_�������_��_����[envER],nil) else evalLong:=evalLong div conInt end;|
            conMod:if conInt=0 then lexError(Stream,_�������_��_����[envER],nil) else evalLong:=evalLong mod conInt end;|
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
          conDiv:if conReal=0.0 then lexError(Stream,_�������_��_����[envER],nil) else evalReal:=evalReal/conReal end;|
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
              then lexError(Stream,_�������_�������_���������_���������[envER],nil)
              else lstrcat(stLexStr,conStr)
            end;|
          lexCHAR:
            if lstrlen(stLexStr)+1>=maxText
              then lexError(Stream,_�������_�������_���������_���������[envER],nil)
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

//----- ������ ������ 1 (����������� ���������) ----------

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
//                ������� ����������� ������
//=================================================

//----------- ��������� ����� ������� -----------

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

//----------- ��������� �������� ������� -----------

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

//----------- ������� ������ ������ 00 ----------

  procedure lexAccept00;
  var s:string[80];
  begin
  with Stream do
    if not ((stLex=lex)and((val=0)or(val=stLexInt))) then
      lexLexName(Stream,lex,val,s);
      lexError(Stream,_���������_[envER],s)
    end;
    if not stErr then
      lexGetLex00(Stream)
    end
  end
  end lexAccept00;

//----------- ������� ������ ������ 0 -----------

  procedure lexAccept0;
  var s:string[80];
  begin
  with Stream do
    if not ((stLex=lex)and((val=0)or(val=stLexInt))) then
      lexLexName(Stream,lex,val,s);
      lexError(Stream,_���������_[envER],s)
    end;
    if not stErr then
      lexGetLex0(Stream)
    end
  end
  end lexAccept0;

//---------- ������� ������ ������ 1 -------------

  procedure lexAccept1;
  var s:string[80];
  begin
  with Stream do
    if not ((stLex=lex)and((val=0)or(val=stLexInt))) then
      lexLexName(Stream,lex,val,s);
//      lexLexName(Stream,stLex,stLexInt,s);
      lexError(Stream,_���������_[envER],s);
    end;
    if not stErr then
      lexGetLex1(Stream)
    end
  end
  end lexAccept1;

//end SmLex.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ ASM (���������� ���������)
//���� SMASM.M

//implementation module SmAsm;
//import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex;

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

//end SmAsm.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TRA (���������� ������, ���� ������-2)
//���� SMTRA.M

//implementation module SmTra;
//import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm;

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

//--------- �������� ����� �������� -----------

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

//---------- �������� ����� ����� -------------

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
      lexError(S,_�����������_��������_����_[envER],idPoiPred);
    else idPoiBitForward:=false
    end;
//    idPoiPred:=nil
  end end;
  memFree(traListPre);
end
end traTYPEs;

//------------ �������� ������� ---------------

procedure traDIALOG(var S:recStream);
var bitMin:boolean;
begin
with S,tbMod[tekt] do
if topMDlg=maxMDlg then lexError(S,_�������_�����_��������_�_������[envER],nil)
else
  lexAccept1(S,lexREZ,integer(rDIALOG));
  inc(topMDlg);
  modDlg^[topMDlg]:=memAlloc(sizeof(recMDialog));
with modDlg^[topMDlg]^ do
  mdTop:=0;
  mdCon[mdTop]:=memAlloc(sizeof(recMItem));
//��������� �������
  with mdCon[mdTop]^ do
    miNam:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miNam,addr(stLexStr));
    lexAccept1(S,lexNEW,0);
    miX:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miY:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miCX:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miCY:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
    miSty:=stLexInt; lexAccept1(S,lexINT,0); lexAccept1(S,lexPARSE,integer(pCol));
//���������
    if okPARSE(S,pCol) then miTxt:=nil
    else
      miTxt:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miTxt,addr(stLexStr));
      lexAccept1(S,lexSTR,0);
    end;
//�����
    miCla:=nil;
    if okPARSE(S,pCol) then
      lexAccept1(S,lexPARSE,integer(pCol));
      if not okPARSE(S,pCol) then
        miCla:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(miCla,addr(stLexStr));
        lexAccept1(S,lexSTR,0);
      end
    end;
//����
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
    if mdTop=maxItem then lexError(S,_�������_�����_���������_�_�������[envER],nil)
    else
      inc(mdTop);
      mdCon[mdTop]:=memAlloc(sizeof(recMItem));
      RtlZeroMemory(mdCon[mdTop],sizeof(recMItem));
//������� �������
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

//------------ �������� bitmap ----------------

procedure traBITMAP(var S:recStream);
var f:integer;
begin
with S,tbMod[tekt] do
if topBMP=maxBMP then lexError(S,_�������_�����_bitmap_�_������[envER],nil)
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
    if f<=0 then lexError(S,_�����������_BMP_����_[envER],bmpFile)
    else
      if _lsize(f)<14
        then lexError(S,_BMP_����_���������_�������_[envER],bmpFile)
        else bmpSize:=_lsize(f)-14;
      end;
      _lclose(f)
    end
  end;
end end
end traBITMAP;

//------------ �������� icon ----------------

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
  if f<=0 then lexError(S,_�����������_BMP_����_[envER],modICON)
  else
    if _lsize(f)<14+40+16*4+512 then
      lexError(S,_BMP_����_���������_�������_[envER],modICON)
    end;
    _lclose(f)
  end
end
end traICON;

//----------- �������� ��������� --------------

procedure traCONST;
//CONST=��� "=" ["-"] ��������
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
    if okPARSE(S,pSqL) then //��������� ���������
      idClass:=idcSET;
      traSETCONST(S);
      idSet:=memAlloc(32);
      idSet^:=stLexSet;
    else lexError(S,_���������_��������_���������[envER],nil);
    end;
  end end;
  if bitMin then
  with conId^ do
  case stLex of
    lexINT:idInt :=-idInt;|
    lexREAL:idReal:=-idReal;|
  else lexError(S,_���������_�����[envER],nil);
  end end end;
  lexBitConst:=false;
  if bitGet then
    lexGetLex1(S);
  end
end
end traCONST;

//------------- �������� ���� -----------------

procedure traTYPE;
//TYPE=��� "=" DefTYPE
var typId:pID; typName:string[maxText];
begin
with S do
  lexAccept1(S,lexNEW,0);
  lstrcpy(typName,stLexOld);
  lexAccept1(S,lexPARSE,integer(pEqv));
  traDefTYPE(S,typName,true)
end
end traTYPE;

//----------- ����������� ���� ----------------

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
      else lexError(S,_������_�_��������_����[envER],nil);
      end;|
    lexPARSE:
      if classPARSE(stLexInt)=pOvL //{������}
        then traSCALAR(S,typId)
        else lexError(S,_������_�_��������_����[envER],nil)
      end;|
    lexTYPE:
      if bitNew then
      with typId^ do //����� ���
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
  else lexError(S,_���������_��������_����[envER],nil)
  end;
  return typId
end
end traDefTYPE;

//---- ���������� �������������� ��������� ----

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
        if (stLex<>lexINT)and(stLex<>lexSCAL) then lexError(S,_���������_�����_�����[envER],nil) else
          if bitMin then
            stLexInt:=-stLexInt;
          end;
          if (idBasNom=typeBYTE)and(stLexInt and 0xFFFFFF00<>0)or
             (idBasNom=typeWORD)and(stLexInt and 0xFFFF0000<>0) then
            lexError(S,'������� ������� ��������',nil);
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
        if stLex<>lexREAL then lexError(S,_���������_�����[envER],nil) else
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
        if stLex<>lexREAL then lexError(S,_���������_�����[envER],nil) else
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
      typeCHAR:if stLex<>lexCHAR then lexError(S,_��������_������[envER],nil) else
        genPutByte(S,lobyte(loword(stLexInt)));
        lexAccept1(S,lexCHAR,0);
      end;|
      typeBOOL:if (stLex<>lexFALSE)and(stLex<>lexTRUE) then lexError(S,_���������_���������_TRUE_���_FALSE[envER],nil) else
        genPutByte(S,lobyte(loword(stLexInt)));
        genPutByte(S,0);
        genPutByte(S,0);
        genPutByte(S,0);
        lexAccept1(S,stLex,0);
      end;|
      typePOINT:if (stLex<>lexNIL)and(stLex<>lexINT) then lexError(S,_���������_�����_���_nil[envER],nil) else
        genPutByte(S,lobyte(loword(stLexInt)));
        genPutByte(S,hibyte(loword(stLexInt)));
        genPutByte(S,lobyte(hiword(stLexInt)));
        genPutByte(S,hibyte(hiword(stLexInt)));
        lexAccept1(S,stLex,0);
      end;|
      typePSTR:if (stLex<>lexNIL)and(stLex<>lexCHAR)and(stLex<>lexSTR) then lexError(S,_���������_������_���_nil[envER],nil) else
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
      typeSET:if not(okPARSE(S,pSqL)or(stLex=lexSET)) then lexError(S,_���������_���������[envER],nil) else
        if okPARSE(S,pSqL) then
          traSETCONST(S);
        end;
        trans.s:=stLexSet;
        for i:=0 to 31 do
          genPutByte(S,trans.b[i]);
        end;
        lexGetLex1(S);
      end;|
      else lexError(S,_��������_���_�_�����������_���������[envER],nil)
    end;|
    idtARR:
    if (idArrItem=idTYPE[typeCHAR])and //������
      (idArrInd=idTYPE[typeINT])and
      (extArrBeg=0) then
      if stLex<>lexSTR then lexError(S,_���������_������[envER],nil) else
      if lstrlen(addr(stLexStr))>extArrEnd then lexError(S,_�������_�������_������[envER],nil) else
        for i:=0 to lstrlen(addr(stLexStr)) do
          genPutByte(S,byte(stLexStr[i]));
        end;
        for i:=lstrlen(addr(stLexStr))+1 to extArrEnd do
          genPutByte(S,0);
        end;
        lexAccept1(S,lexSTR,0)
      end end;
    else //������
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
      if stLex<>lexSCAL then lexError(S,_���������_���������_����������_����_[envER],idName)
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
    else lexError(S,_��������_���_�_�����������_���������_[envER],idName)
  end
end
end traDefSTRUCT;

//---- ���������� ��������� ��������� -------

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
  lexTest(not((stLex=lexPARSE)and(stLexInt=ord(pSqR))),S,_���������__[envER],nil);
end
end traSETCONST;

//---- ���������� ����������� ��������� -------

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

//----------- �������� ������� ----------------

procedure traARRAY;
//ARRAY="ARRAY" ["[" ��� ".." ���� "]"] "OF" ���
begin
with S,typId^ do
  idClass:=idtARR;
  lexAccept1(S,lexREZ,integer(rARRAY));
  if not okREZ(S,rOF) then
    lexBitConst:=true;
    lexAccept1(S,lexPARSE,integer(pSqL));
    if stLex=lexTYPE then //{������}
      if stLexID^.idClass<>idtSCAL then
        lexError(S,_��������_���_������������[envER],nil);
      end;
      idArrInd:=stLexID;
      extArrBeg:=0;
      extArrEnd:=stLexID^.idScalMax-1;
      lexGetLex1(S);
    else //{��������}
      case stLex of
        lexCHAR:idArrInd:=idTYPE[typeCHAR]; extArrBeg:=stLexInt;|
        lexINT:idArrInd:=idTYPE[typeINT ]; extArrBeg:=stLexInt;|
        lexSCAL:idArrInd:=stLexID^.idScalType; extArrBeg:=stLexInt;|
      else lexError(S,_���������_�����_���������[envER],nil)
      end;
      lexGetLex1(S);
      lexAccept1(S,lexPARSE,integer(pPoiPoi));
      case stLex of
        lexCHAR:if idArrInd<>idTYPE[typeCHAR] then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
        lexINT:if idArrInd<>idTYPE[typeINT] then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
        lexSCAL:if idArrInd<>stLexID^.idScalType then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
      else lexError(S,_���������_�����_���������[envER],nil)
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
    lexError(S,_��������_��������_��������[envER],nil)
  end
end
end traARRAY;

//----------- �������� ������ -----------------

procedure traSTRING;
//STRING="STRING" ["[" ���� "]"]
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

//----------- ������������ ������� -----------------

procedure traPROTECTED(var S:recStream; bitDup:boolean);
begin
  if okREZ(S,rPRIVATE) then traCarPro:=proPRIVATE; lexGetLex1(S); if bitDup then lexAccept1(S,lexPARSE,ord(pDup)) end;
  elsif okREZ(S,rPROTECTED) then traCarPro:=proPUBLIC; lexGetLex1(S); if bitDup then lexAccept1(S,lexPARSE,ord(pDup)) end;
  elsif okREZ(S,rPUBLIC) then traCarPro:=proPUBLIC; lexGetLex1(S); if bitDup then lexAccept1(S,lexPARSE,ord(pDup)) end;
  end;
end traPROTECTED;

//----------- �������� ������ -----------------

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
        _���������_���_������[envER],nil);
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
  if okREZ(S,rCASE) then //��������
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

//----------- �������� ��������� --------------

procedure traPOINTER;
//POINTER="POINTER" "TO" ���
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

//----------- �������� ��������� --------------

procedure traSET;
//SET="SET" "OF" ���
begin
with S,typId^ do
  idClass:=idtSET;
  lexAccept1(S,lexREZ,integer(rSET));
  lexAccept1(S,lexREZ,integer(rOF));
  idSetType:=traDefTYPE(S,"#set_base_type",false);
  idtSize:=32;
end
end traSET;

//------------ �������� ������� ---------------

procedure traSCALAR;
//SCALAR="(" ��� {"," ���} ")"
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

//-------- �������� ����� ���������� ----------

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

//-------- ������ �������� ���������� ---------

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

//------------ ������ ���������� --------------

procedure traDefVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST);
//DefVAR=��� ['*'|'-'] {"," ��� ['*'|'-']} ":" ���
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
        lexError(S,_���������_���_����_[envER],stLexStr)
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
  lexTest(stLex<>lexPARSE,S,_���������_�����_���[envER],nil);
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

//------------- ������ �������� ---------------

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
//                        ���� ��������
//===============================================

//------- �������� �� �������� --------

  procedure traINo(o,oLo,oHi:classOp):boolean;
  begin
    return (ord(o)>=ord(oLo))and(ord(o)<=ord(oHi))
  end traINo;

//---------- ���� �������� BYTE ---------------

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
  else lexError(S,_��������_��������_BYTE[envER],nil)
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

//---------- ���� �������� WORD ---------------

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
  else lexError(S,_��������_��������_WORD[envER],nil)
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

//---------- ���� �������� LONG ---------------

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
  else lexError(S,_��������_��������_LONG[envER],nil)
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

//---------- ���� �������� REAL ---------------

const masEQV=0x0100; masL=0x4000;

procedure traREAL(var S:recStream; op:classOp; size:integer);
begin
//�������� ���������
  case op of
    opADD,opSUB,opMUL,opDIV,opE..opGEZ:
//mov si,sp; wait; fld q/d [si+8/4]; wait
      genRR(S,cMOV,rESI,rESP);
      genGen(S,cWAIT,0);
      genM(S,cFLD,regNULL,regNULL,rESI,size,size);
      genGen(S,cWAIT,0);|
  end;
//��������
  case op of
    opADD:genM(S,cFADD,regNULL,regNULL,rESI,0,size);|
    opSUB:genM(S,cFSUB,regNULL,regNULL,rESI,0,size);|
    opMUL:genM(S,cFMUL,regNULL,regNULL,rESI,0,size);|
    opDIV:genM(S,cFDIV,regNULL,regNULL,rESI,0,size);|
    opE,opNE,opLZ,opGZ,opLEZ,opGEZ:genM(S,cFCOMP,regNULL,regNULL,rESI,0,size);|
  else mbI(integer(op),_��������_��������_REAL[envER])
  end;
//add sp,8/4; mov si,sp
  genRD(S,cADD,rESP,size);
  genRR(S,cMOV,rESI,rESP);
//�������� ����������
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
//  ���� �����:mov al,bh; and al,40; or ah,al
      genRR(S,cMOV,rAL,rBH);
      genRD(S,cAND,rAL,0x40);
      genRR(S,cOR,rAH,rAL);
//  ���������:mov al,bh; mov cl,7; rol al,cl; and al,80; or ah,al
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

//---------- ���� �������� SET ---------------

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
      //mov bx,8; xor dx,dx; div bx; --� ax ����� �����, � dx - ����� ����
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
      //mov bx,8; xor dx,dx; div bx; --� ax ����� �����, � dx - ����� ����
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
//                 ���������� ��������
//===============================================

//----------- �������� ������ -----------------

procedure traAddModule(var S:recStream; name:pstr):integer;
var no,i:integer; str:string[maxText];
begin
  lstrcpy(str,name);
  CharLower(str);
//����� ������ � ������� �������
  no:=0;
  for i:=1 to topMod do
    if lstrcmpi(tbMod[i].modNam,str)=0 then
      no:=i;
    end
  end;
//���������� ������ ������
  if no=0 then
    if topMod=maxMod
      then lexError(S,'������� ����� �������',nil)
      else inc(topMod)
    end;
    no:=topMod;
    if not genLoadMod(S,name,topMod,true) then
      lexError(S,_�����������_������_[envER],name);
      genCloseMod(topMod);
      dec(topMod);
    else tbMod[topMod].modAct:=true
    end
  elsif (no>topt)or tbMod[no].modComp then tbMod[no].modAct:=true
  elsif not genLoadMod(S,name,no,true) then lexError(S,_��_������������_������_[envER],name);
  else tbMod[no].modAct:=true
  end;
  return no
end traAddModule;

//------------- ��� ������ ��������� win32 ----------------

procedure traCall32(var S:recStream; mo,pr:pstr);
var procId:pID; no:integer;
begin
  procId:=nil;
  for no:=1 to topMod do
    procId:=idFind(tbMod[no].modTab,pr);
  end;
  if procId=nil then lexError(S,"�� ���������� ���������:",pr)
  else
    with tbMod[tekt] do
      impAdd(genImport,mo,pr,topCode+3,topImport);
    end;
    genM(S,cCALLF,regNULL,regNULL,regNULL,0,0);
  end;
end traCall32;

//------------- ��� ���������� ----------------

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

//---------------- ������ ---------------------

procedure traMODULE(var S:recStream);
//MODULE=["DEFINITION"|"IMPLEMENTATION"] "MODULE" ��� ";"
//       ["IMPORT" ��� ("," ���) ";"]
//       ["EXPORT" ��� ("," ���) ";"]
//       ListDEF
//       ["BEGIN" ListSTAT] "END" ��� "."
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
  if traBitH and not traBitDEFmod then lexError(S,_��������_definition_������[envER],nil) end;
  if not traBitH and traBitDEFmod then lexError(S,_��������_�����������_������[envER],nil) end;
  if not traBitH and not traBitDEFmod and not traBitIMP then
    tbMod[stTxt].modMain:=true;
  end;
  lexAccept1(S,lexREZ,integer(rMODULE));
  lexAccept1(S,lexNEW,0);
  lstrcpy(traModName,stLexOld);
  lexAccept1(S,lexPARSE,ord(pSem));
  //������
  if okREZ(S,rIMPORT) then
    lexAccept1(S,lexREZ,integer(rIMPORT));
    traIMPORT(S);
    while okPARSE(S,pCol) do
      lexAccept1(S,lexPARSE,integer(pCol));
      traIMPORT(S);
    end;
    lexAccept1(S,lexPARSE,ord(pSem))
  end;
  //���� ������
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
    lexError(S,_���������_���_������_[envER],traModName);
  end;
  lexGetLex1(S);
  if lstrcmp(traModName,stLexOld)<>0 then
    lexError(S,_���������_���_������_[envER],traModName);
  end;
  lexAccept1(S,lexPARSE,integer(pPoi));
  lexAccept1(S,lexEOF,0);
end
end traMODULE;

//-------------- ������ ������ ----------------

procedure traIMPORT(var S:recStream);
var impName:string[maxText]; no,i:integer;
begin
with S do
  lexTest(not (stLex=lexNEW),S,_���������_���_������[envER],nil);
  lexGetLex1(S);
//��� ����� ������
  lstrcpy(impName,stLexOld);
//����� ������ � ������� �������
  no:=traAddModule(S,impName);
end
end traIMPORT;

//---------------- ��������� ------------------

procedure traPROC(var S:recStream);
//PROCEDURE="PROCEDURE" ["(" ��������� ")"] ��� ["ASCII"] TITLE BODY|FORWARD
//BODY=["VAR" ListVAR] "BEGIN" [ListSTAT] "END" ���
//FROM="FROM" ���
var procId,modId,parId,procCla,virtId,id:pID; bitComp:boolean; i:integer; name,met:string[maxText];
begin
with S do
//���������
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
      else lexError(S,_���������_���_������[envER],nil)
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
  if (stLex=lexPROC)and((stLexID^.idProcAddr=-1)or(stLexID^.idNom<tekt)) then //���� FORWARD-��������
    procId:=stLexID;
    lexAccept1(S,lexPROC,0);
    for i:=1 to procId^.idProcMax do
      procId^.idProcList^[i]^.idActiv:=byte(true);
    end;
    if okPARSE(S,pOvL) then
      traTITLEtest(S,procId);
    end
  else //����� ���������
    lexAccept1(S,lexNEW,0);
    if procCla<>nil then
      lstrinsc('.',stLexOld,0);
      lstrins(procCla^.idName,stLexOld,0);
    end;
    procId:=idFindGlo(stLexOld,false);
    lexTest((procId<>nil)and(procId^.idProcAddr<>-1),S,_���������_���_������[envER],nil);
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
        lexError(S,_ASCII_�������_���������_������_�_def_������[envER],nil);
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
    with procId^ do //�������� �� ���������� ���������� ������������ ������
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
        lexTest(not bitComp,S,_������������_������_����������_������������_������_[envER],virtId^.idName);
      end
    end end
  end;
  if traCarProc<>nil then mbS(_���������_������_�_traPROC[envER]) end;
  traCarProc:=procId;
  lexAccept1(S,lexPARSE,ord(pSem));
//FORWARD | DEF | BODY
  if okREZ(S,rFORWARD) then //FORWARD
    lexAccept1(S,lexREZ,integer(rFORWARD));
    lexAccept1(S,lexPARSE,ord(pSem))
  elsif (traRecId<>nil)and(traRecId^.idRecCla<>nil) then //����� ������ ������
  elsif traBitDEFmod then //DEF,������� � ������ �������� DLL
    if traMakeDLL then
    with tbMod[stTxt] do
      expAdd(genExport,procId^.idName,topExport);
    end end
  else with procId^ do //BODY
    if not traBitDEFmod then
      idLocList:=memAlloc(sizeof(arrLIST));
//    ����������
      if okREZ(S,rVAR) then
        lexAccept1(S,lexREZ,integer(rVAR));
        traListVAR(S,idvLOC,0,idProcLock,idLocMax,idLocList);
      end;
//    ��������
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
//  ���������
      with tbMod[tekt] do
        idProcAddr:=topCode;
        stepAdd(S,tekt,stepSimple);
        with genStep^[topGenStep] do
          line:=word(S.stPosPred.y);
          frag:=word(S.stPosPred.f);
        end
      end;
//  enter _������
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
        else lexError(S,_���������_���_���������_[envER],idName)
      end;
      lexAccept1(S,lexPARSE,ord(pSem));
//    pop bx; pop si; leave; ret _���������
      genR(S,cPOP,rEBX);
      genR(S,cPOP,rESI);
      genGen(S,cLEAVE,0);
      genD(S,cRET,idProcPar);
//������ ��������� ����������
      for i:=1 to procId^.idLocMax do
        procId^.idLocList^[i]^.idActiv:=byte(false);
      end;
//����� with self
      if idProcCla<>nil then
        dec(topWith)
      end
    end
  end end;
  procId^.idProcCode:=tbMod[tekt].topCode-procId^.idProcAddr;
//������ ����������
  for i:=1 to procId^.idProcMax do
    procId^.idProcList^[i]^.idActiv:=byte(false);
  end;
  traCarProc:=nil
end
end traPROC;

//---------- ��������� ��������� --------------

procedure traTITLE(var S:recStream; procId:pID);
//TITLE="(" [FORMAL {";"|"," FORMAL}] ")" [":" ���] ";"
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
    lexTest(idProcType^.idtSize>8,S,_��������_���_����������_�������[envER],nil);
  end
end
end traTITLE;

//----- ���� ���������� ���������� ------------

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
  else //��� ����
    fPar:=idInsert(tbMod[tekt].modTab,"#proc_param",fId,tabMod,tekt);
    fPar^.idVarType:=stLexID;
    fPar^.idVarAddr:=idProcPar;
    if idProcMax=maxPars
      then lexError(S,_�������_�����_����������[envER],nil)
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

//---------- ��������� ��������� (��������) --------------

procedure traTITLEtest(var S:recStream; procId:pID);
//TITLE="(" [FORMAL {";"|"," FORMAL}] ")" [":" ���] ";"
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
  lexTest(traCarParam<>idProcMax,S,_�������������_����������_����������[envER],nil);
end
end traTITLEtest;

//----- ���� ���������� ���������� (��������) ------------

procedure traFORMALtest;
//FORMAL=["VAR"] ��� {"," ���} ":" ���
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
        then lexError(S,_�������������_����������_����������[envER],nil)
        else lexTest(lstrcmp(stLexOld,idProcList^[traCarParam]^.idName)<>0,S,_�������������_�����_���������[envER],nil);
      end;
      if not okPARSE(S,pDup) then
        lexAccept1(S,lexPARSE,integer(pCol));
      end
    end;
    lexAccept1(S,lexPARSE,integer(pDup));
    fType:=traDefTYPE(S,"#var_type",false);
    for i:=fBeg+1 to traCarParam do
      traEqv(S,idProcList^[i]^.idVarType,fType,true);
      lexTest(idProcList^[i]^.idClass<>fId,S,_�������������_������_���������[envER],nil);
    end
  else
    inc(traCarParam);
    lexAccept1(S,lexTYPE,0)
  end
end
end traFORMALtest;

//===============================================
//                ���������� ����������
//===============================================

//------- �������� ����� call --------------

procedure traAddCorrCall(var S:recStream; var modif:arrModif; var topModif:integer; addAddr:address; addNew:integer);
begin
  if topModif=maxModif
    then lexError(S,_�������_�����_���������_�������_�������[envER],nil)
    else inc(topModif);
  end;
  with modif[topModif] do
    modAddr:=addAddr;
    modNew:=addNew;
  end
end traAddCorrCall;

//------- ��������� ������ call --------------

procedure traCorrCall(var S:recStream; var modif:arrModif; var topModif:integer; oldBeg,oldEnd,newBeg,begCode:integer);
var i,j,k:integer;
begin
//������ �� genCall
  with tbMod[tekt],genCall^ do
    for i:=1 to top do
    with arr[i] do
      if (callSou-begCode+1>=oldBeg+1)and(callSou-begCode+1<=oldEnd) then
        traAddCorrCall(S,modif,topModif,addr(callSou),callSou-oldBeg+newBeg)
      end
    end end
  end;
//������ �� traImport
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
//������ �� genVarCall
  with tbMod[tekt] do
    for i:=1 to topVarCall do with genVarCall^[i] do
    if cl<>vcData then
      if (track>=oldBeg+1)and(track<=oldEnd) then
        traAddCorrCall(S,modif,topModif,addr(track),track-oldBeg+newBeg);
      end
    end end end
  end
end traCorrCall;

//--------- ���������� ������� � ������ ----------------

procedure traMetNum(cla:pID):integer;
var i:integer;
begin
  if cla=nil then return 0
  elsif cla^.idRecCla=cla^.idOwn then return cla^.idRecTop
  else return traMetNum(cla^.idRecCla)+cla^.idRecTop
  end
end traMetNum;

//--------- ����� ������ � ������ ----------------

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

//--------- ������������ ����� ----------------

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
        lstrcat(str,__�_[envER]);
      end;
      if (e2<>nil)and(e2^.idName<>nil)and(e2^.idName[0]<>'#') then
        lstrcat(str,e2^.idName);
      end;
    end;
    lexError(S,_��������������_�����__[envER],str);
  end;
  return eRes
end traEqv;

//------------ ��� ������������ ----------------

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

//------------ ������������ ----------------

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

//------------ ����� ��������� ----------------

procedure traCALL(var S:recStream; bitStat:boolean; cProc:pID):pID;
//CALL=��� "(" [EXPRESSION {"," EXPRESSION}] ")"
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
    _���������_����_�������[envER],nil);
  modif:=memAlloc(sizeof(arrModif));
  topModif:=0;
  bitPascalNull:=(traLANG=langPASCAL)and not okPARSE(S,pOvL) and
    ((idProcCla=nil)and(idProcMax=0)or(idProcCla<>nil)and(idProcMax=1));
  if not bitPascalNull then
    lexAccept1(S,lexPARSE,integer(pOvL));
  end;
//��������� ������ with
  begSaveWith:=tbMod[tekt].topCode;
  for i:=1 to topWith do
    genM(S,cPUSH,regNULL,regNULL,regNULL,genBASECODE+0x1000+(i-1)*4,4);
  end;
  endSaveWith:=tbMod[tekt].topCode;
  if idProcCla<>nil then //����������� ��� save with
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
//���������
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
//�������� �� ����
      cFact:=traEXPRESSION(S);
//��������� ���������-���������
      if bitPoint and (cFact=idProcList^[i]^.idVarType^.idPoiType) then
        cFact:=idProcList^[i]^.idVarType;
        if traLastLoad=-1 then lexError(S,_���������_�_traCALL[envER],nil)
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
//�������� ������� ����������
  with tbMod[tekt] do
  if idProcMax>0 then
    cCode:=memAlloc(cPars^.arrPars[idProcMax].parEnd-cPars^.arrPars[1].parBeg);
    cTop:=0;
    for i:=idProcMax downto 1 do
    with cPars^.arrPars[i] do
//    ��������� ���� ���������
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
//������ �������
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
//�����
  if idProcCla<>nil then
    genR(S,cPOP,rESI); genR(S,cPUSH,rESI); //  pop esi; push esi;
    genMR(S,cMOV,regNULL,regNULL,rESI,rESI,0,1); //  mov esi,[esi];
  end;
  if (idProcCla<>nil)and((idNom=0)or(idNom>topt)and(tbMod[idNom].topCode=0)) then //����� �������� COM-�������
    genM(S,cCALLF,regNULL,regNULL,rESI,(traMetNom(idProcCla,idOwn)-1)*4,0); //callf [esi+_nomMethod*4]
  elsif idProcCla<>nil then //����� �������
    genMR(S,cMOV,regNULL,regNULL,rESI,rESI,0,1); //  mov esi,[esi];
    genM(S,cCALLF,regNULL,regNULL,rESI,0xFFFFFF00,0); //callf [esi+_trackProcTab]
  elsif (idNom=0)or(idNom>topt)and(tbMod[idNom].topCode=0) then //������� �������� DLL
    genM(S,cCALLF,regNULL,regNULL,regNULL,0,0); //callf [_trackProc]
  else //������� ���������
    genGen(S,cCALL,0); //callf _cProc
  end;
//������������ ������ with
  for i:=topWith downto 1 do
    genM(S,cPOP,regNULL,regNULL,regNULL,genBASECODE+0x1000+(i-1)*4,4);
  end;
//  push dx; push ax; ��� �������
  genStack:=oldStack;
  if (idProcType<>nil) and not bitStat then
    lexTest(idProcType^.idtSize>8,S,_��������_���_����������_�������[envER],nil);
    if idProcType^.idtSize>4 then
      genR(S,cPUSH,rEDX);
    end;
    genR(S,cPUSH,rEAX);
  end;
  memFree(modif);
  return idProcType
end end end
end traCALL;

//---------------- ������� --------------------

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
    lexTest(idProcType^.idtSize>8,S,_��������_���_����������_�������[envER],nil);
//pop ax
    genPOP(S,rEAX,traBitAND);
//and ax,?????? ��� 1-3 ����
    with idProcType^ do
    if idtSize=1 then genRD(S,cAND,rEAX,0x000000FF)
    elsif idtSize=2 then genRD(S,cAND,rEAX,0x0000FFFF)
    elsif idtSize=3 then genRD(S,cAND,rEAX,0x00FFFFFF)
    end end;
//pop dx
    if idProcType^.idtSize>4 then
      genR(S,cPOP,rEDX);
    end;
//and dx,?????? ��� 5-7 ����
    with idProcType^ do
    if idtSize=5 then genRD(S,cAND,rEDX,0x000000FF)
    elsif idtSize=6 then genRD(S,cAND,rEDX,0x0000FFFF)
    elsif idtSize=7 then genRD(S,cAND,rEDX,0x00FFFFFF)
    end end
  end;
//mov si,[bp-_������-4]; mov bx,[bp-_������-8]; leave; retf _���������
  genMR(S,cMOV,regNULL,rEBP,regNULL,rESI,-genAlign(idProcLock,4)-4,1);
  genMR(S,cMOV,regNULL,rEBP,regNULL,rEBX,-genAlign(idProcLock,4)-8,1);
  genGen(S,cLEAVE,0);
  genD(S,cRET,idProcPar);
end
end traRETURN;

//----------- �������� �������� ---------------

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

//------------- �������� ������ ---------------

procedure traSELECT(var S:recStream; sType:pID);
//{Const [".." Const] ","}
var caseBeg:pointer to lstJamp; bitMin:boolean;
begin
with S,sType^,tbMod[tekt] do
  caseBeg:=memAlloc(sizeof(lstJamp));
  caseBeg^.top:=0;
  while (stLex=lexCHAR)or(stLex=lexINT)or(stLex=lexSCAL)or(stLex=lexFALSE)or(stLex=lexTRUE)or okPARSE(S,pMin) do
    if (idClass=idtSCAL)and((stLex<>lexSCAL)or(stLexID^.idScalType<>sType)) then
      lexError(S,_������������_���������[envER],nil);
    end;
    bitMin:=okPARSE(S,pMin);
    if bitMin then
      lexGetLex1(S);
      lexTest(stLex<>lexINT,S,_���������_�����[envER],nil);
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
        S,_������������_���������[envER],nil);
      bitMin:=okPARSE(S,pMin);
      if bitMin then
        lexGetLex1(S);
        lexTest(stLex<>lexINT,S,_���������_�����[envER],nil);
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

//------------- �������� ������ ---------------

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
    lexError(S,_��������_���_�������������[envER],nil);
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

//-------------- ���� WHILE -------------------

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

//-------------- ���� REPEAT ------------------

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

//------------ ���� ������� FOR ---------------

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

//------------ ����������� FOR ----------------

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

//---------------- ���� FOR -------------------

procedure traFOR(var S:recStream);
//"FOR" VARIABLE ":=" EXPRESSION "TO"|"DOWNTO" ["STRONG"] EXPRESSION ListSTAT "END"
var forType,expType:pID; modif:classModif; labBeg,jmpEnd:integer; Class:classFor;
begin
with S,tbMod[tekt] do
//��������� �����
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
  lexTest(Class=forNULL,S,_������������_���_��������_�����[envER],nil);
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
//���� �����
  labBeg:=topCode;
  stepAdd(S,tekt,stepBegFOR);
  traListSTAT(S);
  stepAdd(S,tekt,stepModFOR);
  lexAccept1(S,lexREZ,integer(rEND));
  traMODIF(S,Class,modif,forType,labBeg,jmpEnd);
end
end traFOR;

//-------- �������� ���������� ----------------

procedure traASM(var S:recStream);
//"ASM" ���������� "END"
begin
with S do
  lexAccept1(S,lexREZ,integer(rASM));
  asmInitial();
  asmAssembly(S);
  asmDestroy();
  lexAccept1(S,lexREZ,integer(rEND));
end
end traASM;

//---------- ���������� WITH ------------------

procedure traVarWITH(var S:recStream);
var recType:pID;
begin
with S do
  recType:=traVARIABLE(S,false,true,false);
  if recType^.idClass<>idtREC then lexError(S,_���������_����������_������[envER],nil)
  elsif topWith=maxWith then lexError(S,_�������_�����_���������_WITH[envER],nil)
  else
    inc(topWith);
    tbWith[topWith]:=recType;
    genM(S,cPOP,regNULL,regNULL,regNULL,genBASECODE+0x1000+(topWith-1)*4,0);
  end
end
end traVarWITH;

//---------- �������� WITH --------------------

procedure traWITH(var S:recStream);
//"WITH" ���������� {"," ����������} "DO" ��������� "END"
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

//---------- �������� FROM --------------------

procedure traFROM(var S:recStream);
//"FROM" ���������
begin
with S do
  lexAccept1(S,lexREZ,integer(rFROM));
  if not traBitDEF then
    lexError(S,_���������_FROM_�����_����_������_�_def_������[envER],nil);
  end;
  if not (stLex in setID) then
    lexError(S,_���������_���_DLL[envER],nil);
  end;
  lstrcpy(traFromDLL,stLexStr);
  if stLex<>lexSTR then
    lstrcat(traFromDLL,".dll");
  end;
  lexAccept1(S,stLex,0);
  lexAccept1(S,lexPARSE,ord(pSem));
end
end traFROM;

//-------- ��������� INC � DEC ----------------

procedure traINCDEC(var S:recStream);
//"INC"|"DEC" "(" ���������� ["," ���������] ")"
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
    lexError(S,_��������_���_����������[envER],nil);
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
      lexError(S,_��������_���_���������[envER],nil);
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

//-------- �������� NEW ----------------

procedure traNEW(var S:recStream);
//"NEW" "(" ���������� ")"
var varType:pID;
begin
with S do
  lexAccept1(S,lexREZ,ord(rNEW));
  lexAccept1(S,lexPARSE,integer(pOvL));
  varType:=traVARIABLE(S,false,true,false);
  if (varType<>nil)and(varType^.idClass=idtPOI)and(varType^.idPoiType^.idClass=idtREC)and(varType^.idPoiType^.idRecCla<>nil) then
// push mem; push 0; //�������� ������� ���������� !
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
  else lexError(S,_��������_�����[envER],nil)
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
end
end traNEW;

//----------- ������ ���������� ---------------

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
//  pVer �������� ��-�� ����������� ����������� ��������� �
//  �������� ��� � ����������� ����������
    end;
    if stLex=lexREZ then r:=classREZ(stLexInt) else r:=rezNULL end;
  end
end
end traListSTAT;

//===============================================
//                 ���������� ���������
//===============================================

//-------------- �������� �� ��� ��������� -------------------

procedure traOkSET(typ:pID; bitInt:boolean):boolean;
begin
with typ^ do
  if bitInt
    then return (idClass=idtBAS)and(idBasNom in [typeBYTE,typeCHAR,typeWORD,typeBOOL,typeINT,typeDWORD])or(idClass=idtSCAL)
    else return (idClass=idtSET)or(idClass=idtBAS)and(idBasNom=typeSET)
  end
end
end traOkSET;

//-------------- ���������� -------------------

procedure traVARIABLE(var S:recStream; bitOnlyName,bitOnlyVar,bitStatMetod:boolean):pID;
//VARIABLE={{"*"} "("} {"*"} ��� { "^" | "." ��� | "->" | ")" | "[" EXPRESSION "]" }
var varType,varInd,varField,varMetod:pID; varTrack,i,j:integer; str:string[maxText];
  varPoiC:array[0..maxPoiC]of integer; topPoiC,carPoiC:integer;
begin
with S do
  if traStackTop=maxStackMet then mbS(_�������_�����_���������_����������[envER])
  else
    inc(traStackTop);
    traStackMet[traStackTop]:=tbMod[tekt].topCode;
  end;
//������������� ���������� ��
  topPoiC:=0;
  varPoiC[0]:=0;
  while okPARSE(S,pMul) do
    varPoiC[0]:=0;
    while okPARSE(S,pMul) do
      inc(varPoiC[0]);
      lexAccept1(S,lexPARSE,integer(pMul));
    end;
    if okPARSE(S,pOvL) then
    if topPoiC=maxPoiC then lexError(S,_�������_�����_����������[envER],nil); lexGetLex1(S)
    else
      inc(topPoiC);
      varPoiC[topPoiC]:=varPoiC[0];
      varPoiC[0]:=0;
      lexAccept1(S,lexPARSE,integer(pOvL));
    end end;
  end;
//��� ����������
  if not ((stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC)or(stLex=lexVPAR)or(stLex=lexFIELD)or(stLex=lexSTRU)) then
    lexError(S,_���������_����������[envER],nil);
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
        _���������_����_�������[envER],nil);
//mov ax,[401000+with]
      genMR(S,cMOV,regNULL,regNULL,regNULL,rEAX,genBASECODE+0x1000+(withGlo-1)*4,1);
//add ax,��������; push ax
      genRD(S,cADD,rEAX,varTrack);
      genR(S,cPUSH,rEAX);|
    lexSTRU:
//push _Addr
      genD(S,cPUSH,varTrack);
      genAddVarCall(S,tekt,stLexID^.idNom,tbMod[tekt].topCode-3,vcCode,nil);|
  else lexError(S,_���������_����������[envER],nil)
  end;
  lexGetLex1(S);
//������ ���
  if bitOnlyName then return varType end;

//������������� ��
  for i:=1 to varPoiC[0] do
  if varType^.idClass<>idtPOI then lexError(S,_��������_���_���������[envER],nil)
  else
    varType:=varType^.idPoiType;
//pop si; push [si]
    genPOP(S,rESI,traBitAND);
    genM(S,cPUSH,regNULL,regNULL,rESI,0,4);
  end end;

//����� ����������
  while (okPARSE(S,pUg)or okPARSE(S,pPoi)or okPARSE(S,pSqL)or okPARSE(S,pMinUgR)or
    okPARSE(S,pOvR)and(topPoiC>0))and(varType^.idClass<>idPROC)and not stErr do
  case classPARSE(stLexInt) of
    pUg:if varType^.idClass<>idtPOI then lexError(S,_��������_���_���������[envER],nil)
    elsif varType^.idPoiBitForward then lexError(S,_��������������_���_���������[envER],nil)
    else
      varType:=varType^.idPoiType;
      lexAccept1(S,lexPARSE,integer(pUg));
//pop si; push [si]
      genPOP(S,rESI,traBitAND);
      genM(S,cPUSH,regNULL,regNULL,rESI,0,4);
    end;|
    pPoi,pMinUgR:
      if okPARSE(S,pMinUgR)or(varType^.idClass=idtPOI)and(varType^.idPoiType^.idClass=idtREC) then
        if okPARSE(S,pMinUgR) and(varType^.idClass<>idtPOI) then lexError(S,_��������_���_���������[envER],nil)
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
      if varType^.idClass<>idtREC then lexError(S,_��������_���_������[envER],nil)
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
              _���������_����_�������[envER],nil);
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
            else lexError(S,_���������_���_����_[envER],stLexStr)
            end
          end;
        end
        else lexError(S,_���������_���_����[envER],nil)
        end;
      end;|
    pSqL:if not ((varType^.idClass=idtARR)or((varType^.idClass=idtBAS)and(varType^.idBasNom=typePSTR))) then lexError(S,_��������_������[envER],nil)
    elsif varType^.idClass=idtARR then //������
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
    pOvR://������������� ��
      for i:=1 to varPoiC[topPoiC] do
      if varType^.idClass<>idtPOI then lexError(S,_��������_���_���������[envER],nil)
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
  lexTest(bitOnlyVar and(varType^.idClass=idPROC),S,_������������_����������[envER],nil);
  return varType
end
end traVARIABLE;

//------ �������� �������� ���������� ---------

procedure traLOAD(var S:recStream; uniType:pID);
begin
  traLastLoad:=tbMod[tekt].topCode;
  if uniType=nil then mbS(_���������_������_�_traLOAD[envER]) end;
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

//-------------- �������������� ����� --------------------

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
      S,_��������_��������������_�����[envER],nil)
  end end;
  return uniExp
end
end traMODTYPE;

//-------------- ��������� _����������[envER]--------------------

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

//-------------- ��������� --------------------

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
        lexError(S,_�������_��_����������_��������[envER],nil);
        uniType:=idTYPE[typeBYTE]
      end;|
    lexPARSE:case classPARSE(stLexInt) of
      pMul:uniType:=traVARLOAD(S);|
      pOvL:
        lexAccept1(S,lexPARSE,integer(pOvL));
        if (traLANG=langC)and((stLex=lexTYPE)or okREZ(S,rVOID)or okREZ(S,rUNSIGNED)) then
        //�������������� ���� ��
          if stLex=lexTYPE then //��� ��� char*
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
            lexTest((stLex=lexTYPE)and(stLexID=idTYPE[typeINT]),S,_���������_int[envER],nil);
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
        else //��������� ���������
          uniType:=traEXPRESSION(S);
          lexAccept1(S,lexPARSE,integer(pOvR));
        end;|
      pSob: //�����
        uniType:=idTYPE[typePOINT];
        lexAccept1(S,lexPARSE,integer(pSob));
        if okPARSE(S,pOvL) then
          lexAccept1(S,lexPARSE,integer(pOvL));
          traVARIABLE(S,false,true,false);
          lexAccept1(S,lexPARSE,integer(pOvR));
        elsif stLex=lexPROC then //���������
// mov ax,[BaseOfCode]; add ax,_Addr; push ax
          genMR(S,cMOV,regNULL,regNULL,regNULL,rEAX,genBASECODE+genSize(exeOld,1)+44,1);
          genRD(S,cADD,rEAX,genBASECODE+stLexID^.idProcAddr);
          genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode-3,vcAddr,nil);
          genR(S,cPUSH,rEAX);
          lexAccept1(S,lexPROC,0);
        else traVARIABLE(S,true,true,false)
        end;|
      pSqL://���������-���������
        uniType:=idTYPE[typeSET];
        traSETCONST(S);
        //push _Val0 push _Val1 push _Val2 push _Val3 push _Val4 push _Val5 push _Val6 push _Val7
        trans.s:=stLexSet;
        for i:=7 downto 0 do
          genD(S,cPUSH,trans.l[i]);
        end;
        lexGetLex1(S);|
      else
        lexError(S,_���������_���������[envER],nil);
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
      if okPARSE(S,pFiL) then //����������� ��������� push _Addr
        with tbMod[tekt] do
          genD(S,cPUSH,genBASECODE+0x1000+topData);
          genAddVarCall(S,tekt,tekt,tbMod[tekt].topCode-3,vcCode,nil);
        end;
        traLOAD(S,uniType);
        traSTRUCT(S,uniType);
      else //�������������� ����
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
        if stLexID=nil then lexError(S,_���������_���_����[envER],nil)
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
          lexError(S,_���������_������������_�����[envER],nil)
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
          lexError(S,'�������� ��� ���������',nil);
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
          then lexError(S,'�������� ��� ������������',nil)
          else uniType:=idTYPE[typeDWORD]
        end;|
      else
        lexError(S,_���������_���������[envER],nil);
        uniType:=idTYPE[typeBYTE]
    end;|
  else
    lexError(S,_���������_���������[envER],nil);
    return idTYPE[typeBYTE]; //�� ������ ������
  end;
  return uniType
end
end traUNIT;

//------------- �������� NOT ------------------

procedure traUNITNOT(var S:recStream):pID;
//UNITNOT=["NOT"|"!"|"~"] UNIT
var notType:pID; bitNot:boolean;
begin
with S do
  bitNot:=okREZ(S,rNOT) or okPARSE(S,pVos) or okPARSE(S,pVol);
  if bitNot then lexGetLex1(S) end;
  notType:=traUNIT(S);
  if bitNot then
    lexTest(not ((notType^.idClass=idtBAS)and(notType^.idBasNom in [typeBOOL,typeBYTE,typeWORD,typeDWORD,typeINT])),S,_��������_���[envER],nil);
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

//------- �������� * / div mod and ------------

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
    lexTest(not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeWORD,typeBOOL,typeINT,typeDWORD,typeREAL32,typeREAL])),S,_��������_���[envER],nil);
    lexTest((idBasNom=typeBOOL)and not (okREZ(S,rAND)or okPARSE(S,pSob)or okPARSE(S,pSobSob)),S,_��������_���[envER],nil);
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

//----------- �������� + - or -----------------

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
    lexTest(not((idClass=idtBAS)and(idBasNom in [typeINT,typeDWORD,typeREAL32,typeREAL])),S,_���������_�����[envER],nil);
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
    lexTest(not(traOkSET(expType,false)or(idClass=idtBAS)and(idBasNom in [typeBYTE,typeWORD,typeBOOL,typeINT,typeDWORD,typeREAL32,typeREAL])),S,_��������_���[envER],nil);
    lexTest((idBasNom=typeBOOL)and not (okREZ(S,rOR)or okPARSE(S,pVer)or okPARSE(S,pVerVer)),S,_��������_���[envER],nil);
    lexTest(traOkSET(expType,false)and not (okPARSE(S,pPlu)or okPARSE(S,pMin)),S,_��������_���[envER],nil);
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
      lexTest(not(traOkSET(expType2,false)or traOkSET(expType2,true)),S,_��������_���_�_���������_�_����������[envER],nil);
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

//------- �������� ��������� ---------------

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
      lexError(S,_��������_���_�_��������_���������[envER],nil);
    end;
    lexTest(okREZ(S,rIN) and not traOkSET(eqvType,true),S,_��������_���[envER],nil);
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
      then lexTest(not (traOkSET(eqvType,true)and traOkSET(eqvType2,false)),S,_��������_���[envER],nil);
      else traEqv(S,eqvType,eqvType2,true);
    end;
    if eqvOp=opSETIN then traGENSET(S,eqvOp)
    else
    case idtSize of
      1:traBYTE(S,eqvOp);|
      2:traWORD(S,eqvOp);|
      4:if idBasNom=typeREAL32 then traREAL(S,eqvOp,4) else traLONG(S,eqvOp) end;|
      8:traREAL(S,eqvOp,8);|
    else lexError(S,_��������_���_�_��������_���������[envER],nil);
    end end;
    eqvType:=idTYPE[typeBOOL]
  end end;
  return eqvType
end
end traEXPRESSION;

//end SmTra.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TRAC (���������� ������, ���� ��)
//���� SMTRAC.M

//implementation module SmTraC;
//import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra;

procedure tracDefTYPE(var S:recStream):pID; forward;
procedure tracListVAR(var S:recStream; vId:classID; vBeg:integer; typ:pID; name:pstr; var vMem,vTop:integer; vList:pLIST); forward;
procedure tracPROC(var S:recStream; typ,procId:pID; name:pstr); forward;
procedure tracBlockSTAT(var S:recStream); forward;
procedure tracListSTAT(var S:recStream); forward;
procedure tracINCDEC(var S:recStream; varType:pID); forward;

//----------- �������� �� ��� --------------

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

//----------- �������� ��������� --------------

procedure tracCONST(var S:recStream);
//CONST="DEFINE" ��� ["-"] ��������
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
  else lexError(S,_���������_��������_���������[envER],nil);
  end end;
  if bitMin then
  with conId^ do
  case stLex of
    lexINT:idInt :=-idInt;|
    lexREAL:idReal:=-idReal;|
  else lexError(S,_���������_�����[envER],nil);
  end end end;
  lexBitConst:=false;
  if bitGet then
    lexGetLex1(S);
  end
end
end tracCONST;

//----------- �������� ������ -----------------

procedure tracRECORD(var S:recStream; typId:pID):pID;
//RECORD="STRUCT"|"CLASS" ������� [":" ���������]
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
        _���������_���_������[envER],nil);
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
  if okREZ(S,rUNION) then //��������
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

//----------- �������� ��������� --------------

procedure tracSET(var S:recStream; typId:pID);
//SET="SET" "[" ��� "]"
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

//------------ �������� ������� ---------------

procedure tracSCALAR(var S:recStream; typId:pID);
//SCALAR="ENUM" ������� "{" ��� {"," ���} "}" ";"
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

//----------- ������������ ������� ----------------

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
    if stLex=lexTYPE then //������
      if stLexID^.idClass<>idtSCAL then
        lexError(S,_��������_���_������������[envER],nil);
      end;
      idArrInd:=stLexID;
      extArrBeg:=0;
      extArrEnd:=stLexID^.idScalMax-1;
      lexGetLex1(S);
    else //��������
      idArrInd:=idTYPE[typeDWORD];
      case stLex of
        lexCHAR:idArrInd:=idTYPE[typeCHAR]; extArrBeg:=stLexInt;|
        lexINT:idArrInd:=idTYPE[typeINT]; extArrBeg:=stLexInt;|
        lexSCAL:idArrInd:=stLexID^.idScalType; extArrBeg:=stLexInt;|
      else lexError(S,_���������_�����_���������[envER],nil)
      end;
      lexGetLex1(S);
      if not okPARSE(S,pPoiPoi) then extArrEnd:=extArrBeg-1; extArrBeg:=0;
      else
        lexBitConst:=true;
        lexAccept1(S,lexPARSE,integer(pPoiPoi));
        lexBitConst:=false;
        case stLex of
          lexCHAR:if idArrInd<>idTYPE[typeCHAR] then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
          lexINT:if idArrInd<>idTYPE[typeINT] then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
          lexSCAL:if idArrInd<>stLexID^.idScalType then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
        else lexError(S,_���������_�����_���������[envER],nil)
        end;
        lexGetLex1(S);
        if extArrBeg>extArrEnd then
          lexError(S,_��������_��������_��������[envER],nil)
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

//----------- ����� ���� ----------------

procedure tracNextTYPE(var S:recStream; typId:pID):pID;
var typNext:pID;
begin
with S do
  while okPARSE(S,pMul) or okPARSE(S,pSqL) do
    case classPARSE(stLexInt) of
      pMul://���������
        if (typId^.idClass=idtBAS)and(typId^.idBasNom=typeCHAR) then typId:=idTYPE[typePSTR]
        else
          typNext:=idInsertGlo("#pointer_type",idtPOI);
          typNext^.idPoiType:=typId;
          typNext^.idtSize:=4;
          typNext^.idPoiBitForward:=false;
          typId:=typNext;
        end;
        lexGetLex1(S);|
      pSqL://������
        typId:=tracArrTYPE(S,typId);|
    end
  end;
  return typId
end
end tracNextTYPE;

//----------- ����������� ���� ----------------

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
          if not ((stLex=lexTYPE)and(stLexID^.idBasNom=typeINT)) then lexError(S,_��������_���_int[envER],nil)
          else
            typId:=idTYPE[typeDWORD];
            lexGetLex1(S);
            typId:=tracNextTYPE(S,typId);
          end;|
      else lexError(S,_������_�_��������_����[envER],nil);
      end;|
    lexTYPE:
      typId:=stLexID;
      lexGetLex1(S);
      typId:=tracNextTYPE(S,typId);|
  else lexError(S,_���������_��������_����[envER],nil)
  end;
  return typId
end
end tracDefTYPE;

//------------- �������� ���� -----------------

procedure tracTYPE(var S:recStream);
//TYPE="TYPEDEF" DefTYPE ��� ";"
var newId,typId,newField,oldFi:pID; i,j:integer; str,name:string[maxText];
begin
with S do
  lexAccept1(S,lexREZ,integer(rTYPEDEF));
  typId:=tracDefTYPE(S);
  if typId=nil then lexError(S,_���������_���[envER],nil)
  else
    lexAccept1(S,lexNEW,0);
    newId:=idInsertGlo(stLexOld,typId^.idClass);
//����� ���
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
//��������� ���� ����� ������
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

//------------ ������ ���������� --------------

procedure tracListVAR(var S:recStream; vId:classID; vBeg:integer; typ:pID; name:pstr; var vMem,vTop:integer; vList:pLIST);
//ListVAR=��� [������] {"," ��� [������]}
var i,varTop:integer; varId:pID; str:string[maxText];
begin
with S do
  varTop:=vTop;
  while (stLex=lexNEW)or(name<>nil) do
    if vId<>idvFIELD then //����������
      if name=nil
        then lstrcpy(str,stLexStr)
        else lstrcpy(str,name)
      end
    else //��� ����
      lstrcpy(str,traRecId^.idName);
      lstrcatc(str,'.');
      if name=nil
        then lstrcat(str,stLexStr)
        else lstrcat(str,name)
      end;
      with traRecId^ do
      if listFind(idRecList,idRecMax,str)<>nil then
        lexError(S,_���������_���_����_[envER],stLexStr)
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
  lexTest(stLex<>lexPARSE,S,_���������_�����_���[envER],nil);

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

//-------- �������� ����� ���������� ----------

procedure tracVARs(var S:recStream; typ:pID; name:pstr; Class:classID);
//VARs=ListVAR ";"
var varList:arrLIST; varTop:integer;
begin
with S do
  if typ=nil then lexError(S,_��������_���[envER],nil)
  else
    varTop:=0;
    with tbMod[tekt] do
      tracListVAR(S,Class,0,typ,name,topData,varTop,varList);
      lexAccept1(S,lexPARSE,integer(pSem));
    end
  end
end
end tracVARs;

//----- ���� ���������� ���������� ------------

procedure tracFORMAL(var S:recStream; procId:pID);
//FORMAL=DefTYPE ["&"] [���]
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
      then lexError(S,_�������_�����_����������[envER],nil)
      else listAdd(idProcList,fPar,idProcMax);
    end;
    if fId=idvVPAR
      then inc(idProcPar,4)
      else inc(idProcPar,fPar^.idVarType^.idtSize);
    end;

//������ ����������
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
//        then lexError(S,_�������_�����_����������[envER],nil)
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

//---------- ��������� ��������� --------------

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

//----- ���� ���������� ���������� (��������) ------------

procedure tracFORMALtest(var S:recStream; procId:pID);
//FORMAL=DefTYPE ["&"] [���]
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
      lexTest(idProcList^[traCarParam]^.idClass<>fId,S,_�������������_������_���������[envER],nil);
      if traCarParam>idProcMax
        then lexError(S,_�������������_����������_����������[envER],nil)
        else lexTest(lstrcmp(stLexStr,idProcList^[traCarParam]^.idName)<>0,S,_�������������_�����_���������[envER],nil)
      end;
      lexAccept1(S,stLex,0);
    end;
  end
end
end tracFORMALtest;

//---------- ��������� ��������� (��������) --------------

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
  lexTest(traCarParam<>idProcMax,S,_�������������_����������_����������[envER],nil);
end
end tracTITLEtest;

//---------------- ��������� ------------------

procedure tracPROC(var S:recStream; typ,procId:pID; name:pstr);
//PROCEDURE=[��������� "::" �������]["ASCII"] TITLE BODY|FORWARD
//BODY="{" [ListVAR] [ListSTAT] "}"
//FORWARD=";"
var modId,virtId,procCla,parId:pID; i:integer; bitComp:boolean; str:string[maxText];
begin
with S do
//������� ���������
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
//���������
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
  else //����� ���������
    procCla:=nil;
    if (stLex=lexTYPE)or(traRecId<>nil)and(traRecId^.idRecCla<>nil) then //�����
      if stLex=lexTYPE then //����� ��� ������
        lexTest(stLexID^.idRecCla=nil,S,_��������_�����[envER],nil);
        procCla:=stLexID;
        lexGetLex1(S);
        lexAccept1(S,lexPARSE,ord(pDupDup));
        lstrcpy(str,procCla^.idName);
        lstrcatc(str,'.');
        lstrcat(str,stLexStr);
        lexTest(not (stLex in setID),S,_���������_�����_���[envER],nil);
        lexGetLex1(S);
      else //����� ������ ������
        procCla:=traRecId;
        lstrcpy(str,procCla^.idName);
        lstrcatc(str,'.');
        lstrcat(str,name);
      end;
      procId:=idFindGlo(str,false);
      lexTest((procId<>nil)and(procId^.idProcAddr<>-1),S,_���������_���_������[envER],nil);
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
        lexTest(idProcType^.idtSize>8,S,_��������_���_����������_�������[envER],nil);
      end;
      idProcASCII:=okREZ(S,rASCII);
      if idProcASCII then
        if not traBitDEF then
          lexError(S,_ASCII_�������_���������_������_�_def_������[envER],nil);
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
      S,_�������_main_��_������_�����_���������[envER],nil);
    with procId^ do //�������� �� ���������� ���������� ������������ ������
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
        lexTest(not bitComp,S,_������������_������_����������_������������_������_[envER],virtId^.idName);
      end
    end end
  end;
  if traCarProc<>nil then mbS(_���������_������_�_tracPROC[envER]) end;
  traCarProc:=procId;
//BODY|FORWARD
  if okPARSE(S,pSem) then //FORWARD
    lexAccept1(S,lexPARSE,integer(pSem))
  elsif (traRecId<>nil)and(traRecId^.idRecCla<>nil) then //����� ������ ������
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
//����������
      lexAccept1(S,lexPARSE,ord(pFiL));
      while tracTYPEOK(S) do
        typ:=tracDefTYPE(S);
        lexAccept1(S,lexNEW,0);
        if okPARSE(S,pCol) or okPARSE(S,pSem) or okPARSE(S,pSqL) then
          tracListVAR(S,idvLOC,0,typ,stLexOld,idProcLock,idLocMax,idLocList);
          lexAccept1(S,lexPARSE,integer(pSem));
        else lexError(S,_��������_������_����������[envER],nil)
        end;
        lexTest(lstrcmp(procId^.idName,"main")=0,
          S,_�������_main_��_������_�����_���������_����������[envER],nil);
      end;
//��������
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
//���������
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
//enter _������
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
// pop bx; pop si; leave; ret _���������
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
//����� with self
      if idProcCla<>nil then
        dec(topWith)
      end;
    else //traBitDEF,������� � ������ �������� DLL
      if traMakeDLL then
      with tbMod[stTxt] do
        expAdd(genExport,procId^.idName,topExport);
      end end
    end
  end end;
  procId^.idProcCode:=tbMod[tekt].topCode-procId^.idProcAddr;
//������ ���������� � ��������� ����������
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
//                 ���������� ��������
//===============================================

//------------- ������ �������� ---------------

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
  if (tracTYPEOK(S)and not okREZ(S,rENUM))or okREZ(S,rVIRTUAL) then //���������� ��� �������
    if okREZ(S,rVIRTUAL) then lexGetLex1(S) end;
    typ:=tracDefTYPE(S);
    if stLex=lexPROC then
      pProc:=stLexID;
      lexAccept1(S,lexPROC,0);
      tracPROC(S,typ,pProc,stLexOld);
    elsif stLex=lexTYPE then tracPROC(S,typ,nil,nil) //�����
    else
      lexAccept1(S,lexNEW,0);
      if okPARSE(S,pOvL)or okPARSE(S,pFiL) or okPARSE(S,pDupDup)or okREZ(S,rASCII)or tracTYPEOK(S) then tracPROC(S,typ,nil,stLexOld)
      elsif okPARSE(S,pCol)or okPARSE(S,pSem)or okPARSE(S,pSqL) then tracVARs(S,typ,stLexOld,idvVAR)
      else lexError(S,_��������_������_����������_���_�������[envER],nil)
      end
    end;
  else //������ ��������
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

//-------------- ��� ������ ----------------

procedure tracImpName(var S:recStream; impName:pstr);
begin
with S do
  if stLex=lexNEW then //�������������
    lstrcpy(impName,stLexStr);
    lexAccept1(S,lexNEW,0);
  elsif stLex=lexSTR then //��� ����� � ��������
    lstrcpy(impName,stLexStr);
    if lstrposc('.',impName)>=0 then
      lstrdel(impName,lstrposc('.',impName),99)
    end;
    lexAccept1(S,lexSTR,0);
  elsif okPARSE(S,pUgL) then //��� ����� � �������
    lexAccept1(S,lexPARSE,integer(pUgL));
    lexAccept1(S,lexNEW,0);
    lstrcpy(impName,stLexOld);
    if okPARSE(S,pPoi) then
      lexAccept1(S,lexPARSE,integer(pPoi));
      lexGetLex1(S);
    end;
    lexAccept1(S,lexPARSE,integer(pUgR));
  else lexError(S,_���������_���_������[envER],nil)
  end;
end
end tracImpName;

//-------------- ������ ������ ----------------

procedure tracIMPORT(var S:recStream);
//IMPORT="INCLIDE" ��������� {","���������}
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

//---------------- ������ ---------------------

procedure tracMODULE(var S:recStream; modName:pstr);
//{["#"] "INCLUDE" ��������� {"," ���������}}
//["EXPORT" ���������� {"," ����������}]
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
//                ���������� ����������
//===============================================

//-------- �������� NEW ----------------

procedure tracNEW(var S:recStream; varType:pID);
//���������� "=" "NEW" �������
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
// push mem; push 0; //�������� ������� ���������� !
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
  else lexError(S,_��������_�����[envER],nil)
  end
end
end tracNEW;

//------------ ������������ ----------------

procedure tracEQUAL(var S:recStream);
//EQUAL=VARIABLE "=" EXPRESSION | "++" "--" "+=" "-=" INCDEC | "NEW" �������
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

//------------ ����� ��������� ----------------

procedure tracCALL(var S:recStream; bitStat:boolean):pID;
//CALL=��� "(" [EXPRESSION {"," EXPRESSION}] ")"
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
    _���������_����_�������[envER],nil);
  str:=memAlloc(maxText);
  modif:=memAlloc(sizeof(arrModif));
  topModif:=0;
  lexAccept1(S,lexPROC,0);
  lexAccept1(S,lexPARSE,integer(pOvL));
//��������� ������ with
  begSaveWith:=tbMod[tekt].topCode;
  for i:=1 to topWith do
    genM(S,cPUSH,regNULL,regNULL,regNULL,genBASECODE+0x1000+(i-1)*4,4);
  end;
  endSaveWith:=tbMod[tekt].topCode;
  if idProcCla<>nil then //����������� ��� save with
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
//���������
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
//�������� �� ����
      cFact:=traEXPRESSION(S);
//��������� ���������-���������
      if bitPoint and (cFact=idProcList^[i]^.idVarType^.idPoiType) then
        cFact:=idProcList^[i]^.idVarType;
        if traLastLoad=-1 then lexError(S,_���������_�_tracCALL[envER],nil)
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
//�������� ������� ����������
  with tbMod[tekt] do
  if idProcMax>0 then
    cCode:=memAlloc(cPars^.arrPars[idProcMax].parEnd-cPars^.arrPars[1].parBeg);
    cTop:=0;
    for i:=idProcMax downto 1 do
    with cPars^.arrPars[i] do
//��������� ���� ���������
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
//������ �������
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
//�����
  if idProcCla<>nil then
    genR(S,cPOP,rESI); genR(S,cPUSH,rESI); //  pop esi; push esi;
    genMR(S,cMOV,regNULL,regNULL,rESI,rESI,0,1); //  mov esi,[esi];
  end;
  if (idProcCla<>nil)and((idNom=0)or(idNom>topt)and(tbMod[idNom].topCode=0)) then //����� �������� COM-�������
    genM(S,cCALLF,regNULL,regNULL,rESI,(traMetNom(idProcCla,idOwn)-1)*4,0); //callf [esi+_nomMethod*4]
  elsif idProcCla<>nil then //����� �������
    genMR(S,cMOV,regNULL,regNULL,rESI,rESI,0,1); //  mov esi,[esi];
    genM(S,cCALLF,regNULL,regNULL,rESI,0xFFFFFF00,0); //callf [esi+_trackProcTab]
  elsif (idNom=0)or(idNom>topt)and(tbMod[idNom].topCode=0) then //������� �������� DLL
    genM(S,cCALLF,regNULL,regNULL,regNULL,0,0); //callf [_trackProc]
  else //������� ���������
    genGen(S,cCALL,0); //callf _cProc
  end;
//������������ ������ with
  for i:=topWith downto 1 do
    genM(S,cPOP,regNULL,regNULL,regNULL,genBASECODE+0x1000+(i-1)*4,4);
  end;
//push dx; push ax; ��� �������
  genStack:=oldStack;
  if (idProcType<>nil) and not bitStat then
    lexTest(idProcType^.idtSize>8,S,_��������_���_����������_�������[envER],nil);
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

//---------------- ������� --------------------

procedure tracRETURN(var S:recStream);
//RETURN [EXPRESSION]
begin
  traRETURN(S);
  lexAccept1(S,lexPARSE,integer(pSem));
end tracRETURN;

//----------- �������� �������� ---------------

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

//------------- �������� ������ ---------------

procedure tracSELECT(var S:recStream; sType:pID);
//{"CASE" Const [".." Const] ":"}
var caseBeg:pointer to lstJamp; bitMin:boolean;
begin
with S,sType^,tbMod[tekt] do
  caseBeg:=memAlloc(sizeof(lstJamp));
  caseBeg^.top:=0;
  while okREZ(S,rCASE) do
    lexGetLex1(S);
    lexTest((idClass=idtSCAL)and((stLex<>lexSCAL)or(stLexID^.idScalType<>sType)),S,_������������_���������[envER],nil);
    bitMin:=okPARSE(S,pMin);
    if bitMin then
      lexGetLex1(S);
      lexTest(stLex<>lexINT,S,_���������_�����[envER],nil);
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
        S,_������������_���������[envER],nil);
      bitMin:=okPARSE(S,pMin);
      if bitMin then
        lexGetLex1(S);
        lexTest(stLex<>lexINT,S,_���������_�����[envER],nil);
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

//--------------- �������� ������ ---------------

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
    lexError(S,_��������_���_�������������[envER],nil);
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

//-------------- ���� WHILE -------------------

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

//-------------- ���� DO ------------------

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

//---------------- ���� FOR -------------------

procedure tracFOR(var S:recStream);
//"FOR" "(" ��� "=" EXPRESSION ";"
//��� "<"|"<="|">"|">=" EXPRESSION ";"
//��� "++"|"--" ")"
//BlockSTAT
var forType,expType:pID; modif:classModif; labBeg,jmpEnd:integer; Class:classFor; name:string[maxText];
begin
with S,tbMod[tekt] do
//��������� �����
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
  lexTest(Class=forNULL,S,_������������_���_��������_�����[envER],nil);
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
    lexTest(lstrcmp(stLexStr,name)<>0,S,_��������_�������_�����_[envER],name);
    lexGetLex1(S);
  else lexError(S,_��������_�������_�����_[envER],name)
  end;
  if stLex=lexPARSE then
    case classPARSE(stLexInt) of
      pUgL:modif:=modifTONE;|
      pUgLEqv:modif:=modifTO;|
      pUgR:modif:=modifDOWNTONE;|
      pUgREqv:modif:=modifDOWNTO;|
    else lexError(S,_���������_�������_���������_�����[envER],nil)
    end
  else lexError(S,_���������_�������_���������_�����[envER],nil)
  end;
  lexGetLex1(S);
  traBitAND:=false;
  expType:=traEXPRESSION(S);
  traEqv(S,forType,expType,true);
  lexAccept1(S,lexPARSE,integer(pSem));
  if (stLex=lexVAR)or(stLex=lexPAR)or(stLex=lexLOC) then
    lexTest(lstrcmp(stLexStr,name)<>0,S,_��������_�������_�����_[envER],name);
    lexGetLex1(S);
  else lexError(S,_��������_�������_�����_[envER],name)
  end;
  case modif of
    modifTO,modifTONE:lexAccept1(S,lexPARSE,integer(pPluPlu));|
    modifDOWNTO,modifDOWNTONE:lexAccept1(S,lexPARSE,integer(pMinMin));|
  end;
  lexAccept1(S,lexPARSE,integer(pOvR));
  jmpEnd:=traTEST(S,Class,modif);
//���� �����
  labBeg:=topCode;
  stepAdd(S,tekt,stepBegFOR);
  tracBlockSTAT(S);
  stepAdd(S,tekt,stepModFOR);
  traMODIF(S,Class,modif,forType,labBeg,jmpEnd);
end
end tracFOR;

//-------- �������� ���������� ----------------

procedure tracASM(var S:recStream);
//"ASM" "{" ���������� "}"
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

//---------- ���������� WITH ------------------

procedure tracVarWITH(var S:recStream);
var recType:pID;
begin
with S do
  recType:=traVARIABLE(S,false,true,false);
  if recType^.idClass<>idtREC then lexError(S,_���������_����������_������[envER],nil)
  elsif topWith=maxWith then lexError(S,_�������_�����_���������_WITH[envER],nil)
  else
    inc(topWith);
    tbWith[topWith]:=recType;
    genM(S,cPOP,regNULL,regNULL,regNULL,genBASECODE+0x1000+(topWith-1)*4,0);
  end
end
end tracVarWITH;

//---------- �������� WITH --------------------

procedure tracWITH(var S:recStream);
//"WITH" "(" ���������� {"," ����������} ")" BlockSTAT
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

//-------- ��������� INC � DEC ----------------

procedure tracINCDEC(var S:recStream; varType:pID);
//"++"|"--" [���������] | "+="|"-=" ���������
var bitINC:boolean; expType:pID; comm:classCommand;
begin
with S do
  bitINC:=okPARSE(S,pPluPlu) or okPARSE(S,pPluEqv);
  lexAccept1(S,lexPARSE,stLexInt);
  with varType^ do
  if not((idClass=idtBAS)and(idBasNom in [typeBYTE,typeCHAR,typeINT,typeWORD,typeDWORD])or(idClass=idtSCAL)) then
    lexError(S,_��������_���_����������[envER],nil);
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
      lexError(S,_��������_���_���������[envER],nil);
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

//----------- ������ ���������� ---------------

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

//----------- ������ ���������� ---------------

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

//----------- ���� ���������� ---------------

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

//end SmTraC.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TRAP (���������� ������, ���� �������)
//���� SMTRAP.M

//implementation module SmTraP;
//import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra;

procedure trapDefTYPE(var S:recStream; typName:pstr; bitNew:boolean):pID; forward;
procedure trapDefVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST); forward;
procedure trapListVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST); forward;
procedure trapPROC(var S:recStream); forward;
procedure trapSTATEMENT(var S:recStream); forward;
procedure trapListSTAT(var S:recStream; bitBeginEnd:boolean); forward;

//----------- �������� ������� ----------------

procedure trapARRAY(var S:recStream; typId:pID);
//ARRAY="ARRAY" ["[" ��� ".." ���� "]"] "OF" ���
begin
with S,typId^ do
  idClass:=idtARR;
  lexAccept1(S,lexREZ,integer(rARRAY));
  if not okREZ(S,rOF) then
    lexBitConst:=true;
    lexAccept1(S,lexPARSE,integer(pSqL));
    if stLex=lexTYPE then //������
      if stLexID^.idClass<>idtSCAL then
        lexError(S,_��������_���_������������[envER],nil);
      end;
      idArrInd:=stLexID;
      extArrBeg:=0;
      extArrEnd:=stLexID^.idScalMax-1;
      lexGetLex1(S);
    else //��������
      case stLex of
        lexCHAR:idArrInd:=idTYPE[typeCHAR]; extArrBeg:=stLexInt;|
        lexINT:idArrInd:=idTYPE[typeINT ]; extArrBeg:=stLexInt;|
        lexSCAL:idArrInd:=stLexID^.idScalType; extArrBeg:=stLexInt;|
      else lexError(S,_���������_�����_���������[envER],nil)
      end;
      lexGetLex1(S);
      lexAccept1(S,lexPARSE,integer(pPoiPoi));
      case stLex of
        lexCHAR:if idArrInd<>idTYPE[typeCHAR] then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
        lexINT:if idArrInd<>idTYPE[typeINT] then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
        lexSCAL:if idArrInd<>stLexID^.idScalType then lexError(S,_��������_���_�������[envER],nil) else extArrEnd:=stLexInt end;|
      else lexError(S,_���������_�����_���������[envER],nil)
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
    lexError(S,_��������_��������_��������[envER],nil)
  end
end
end trapARRAY;

//----------- �������� ������ -----------------

procedure trapRECORD(var S:recStream; typId:pID);
//RECORD="RECORD" | "OBJECT" ["("�������")"] ListVAR [ "CASE" [ListVAR] "OF" {[��������� ":"] "(" ListVAR ")"} ] "END"
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
        _���������_���_������[envER],nil);
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
  if okREZ(S,rCASE) then //��������
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

//----------- �������� ��������� --------------

procedure trapPOINTER(var S:recStream; typId:pID);
//POINTER="^" ���
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

//----------- ����������� ���� ----------------

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
      else lexError(S,_������_�_��������_����[envER],nil);
      end;|
    lexPARSE:
      if classPARSE(stLexInt)=pOvL then traSCALAR(S,typId) //������
      elsif classPARSE(stLexInt)=pUg then trapPOINTER(S,typId) //���������
      else lexError(S,_������_�_��������_����[envER],nil)
      end;|
    lexTYPE:
      if bitNew then
      with typId^ do //����� ���
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
  else lexError(S,_���������_��������_����[envER],nil)
  end;
  return typId
end
end trapDefTYPE;

//------------- �������� ���� -----------------

procedure trapTYPE(var S:recStream);
//TYPE=��� "=" DefTYPE
var typId:pID; typName:string[maxText];
begin
with S do
  lexAccept1(S,lexNEW,0);
  lstrcpy(typName,stLexOld);
  lexAccept1(S,lexPARSE,integer(pEqv));
  trapDefTYPE(S,typName,true)
end
end trapTYPE;

//---------- �������� ����� ����� -------------

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
      lexError(S,_�����������_��������_����_[envER],idPoiPred);
    else idPoiBitForward:=false
    end;
//    idPoiPred:=nil
  end end;
  memFree(traListPre);
end
end trapTYPEs;

//------------ ������ ���������� --------------

procedure trapDefVAR(var S:recStream; vId:classID; vBeg:integer; var vMem:integer; var vTop:integer; vList:pLIST);
//DefVAR=��� {"," ���} ":" ���
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
        lexError(S,_���������_���_����_[envER],stLexStr)
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
  lexTest(stLex<>lexPARSE,S,_���������_�����_���[envER],nil);
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

//-------- ������ �������� ���������� ---------

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

//-------- �������� ����� ���������� ----------

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

//------------- ������ �������� ---------------

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
//                ���������� ����������
//===============================================

//---------------- ������� --------------------

procedure trapRETURN(var S:recStream; proc:pID);
//"EXIT" | ":=" EXPRESSION
var cRes:pID;
begin
with S,traCarProc^ do
  if okREZ(S,rEXIT) then lexAccept1(S,lexREZ,integer(rEXIT));
  else
    lexTest(lstrcmp(proc^.idName,idName)<>0,S,_���������_���_�������_[envER],stLexOld);
    lexAccept1(S,lexPARSE,integer(pDupEqv));
    if idProcType<>nil then
      traBitAND:=false;
      cRes:=traEXPRESSION(S);
      traEqv(S,idProcType,cRes,true);
      lexTest(idProcType^.idtSize>8,S,_��������_���_����������_�������[envER],nil);
//  pop ax
      genPOP(S,rEAX,traBitAND);
//  and ax,?????? ��� 1-3 ����
      with idProcType^ do
      if idtSize=1 then genRD(S,cAND,rEAX,0x000000FF)
      elsif idtSize=2 then genRD(S,cAND,rEAX,0x0000FFFF)
      elsif idtSize=3 then genRD(S,cAND,rEAX,0x00FFFFFF)
      end end;
//  pop dx
      if idProcType^.idtSize>4 then
        genR(S,cPOP,rEDX);
      end;
//  and dx,?????? ��� 5-7 ����
      with idProcType^ do
      if idtSize=5 then genRD(S,cAND,rEDX,0x000000FF)
      elsif idtSize=6 then genRD(S,cAND,rEDX,0x0000FFFF)
      elsif idtSize=7 then genRD(S,cAND,rEDX,0x00FFFFFF)
      end end
    else lexError(S,_���������_���_�������[envER],nil)
    end
  end;
//mov si,[bp-_������-4]; mov bx,[bp-_������-8]; leave; retf _���������
  genMR(S,cMOV,regNULL,rEBP,regNULL,rESI,-genAlign(idProcLock,4)-4,1);
  genMR(S,cMOV,regNULL,rEBP,regNULL,rEBX,-genAlign(idProcLock,4)-8,1);
  genGen(S,cLEAVE,0);
  genD(S,cRET,idProcPar);
end
end trapRETURN;

//----------- �������� �������� ---------------

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

//------------- �������� ������ ---------------

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
    lexError(S,_��������_���_�������������[envER],nil);
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

//-------------- ���� WHILE -------------------

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

//-------------- ���� REPEAT ------------------

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

//---------------- ���� FOR -------------------

procedure trapFOR(var S:recStream);
//"FOR" VARIABLE ":=" EXPRESSION "TO"|"DOWNTO" ["STRONG"] EXPRESSION STATEMENT
var forType,expType:pID; modif:classModif; labBeg,jmpEnd:integer; Class:classFor;
begin
with S,tbMod[tekt] do
//��������� �����
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
  lexTest(Class=forNULL,S,_������������_���_��������_�����[envER],nil);
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
//���� �����
  labBeg:=topCode;
  stepAdd(S,tekt,stepBegFOR);
  trapSTATEMENT(S);
  stepAdd(S,tekt,stepModFOR);
  traMODIF(S,Class,modif,forType,labBeg,jmpEnd);
end
end trapFOR;

//---------- �������� WITH --------------------

procedure trapWITH(var S:recStream);
//"WITH" ���������� {"," ����������} "DO" STATEMENT
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

//----------- ������ ���������� ---------------

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

//--------------------- �������� -------------------

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
//                 ���������� ��������
//===============================================

//---------- ��������� ��������� --------------

procedure trapTITLE(var S:recStream; procId:pID; bitFunc:boolean);
//TITLE="(" [FORMAL {";"|"," FORMAL}] ")" [":" ���] ";"
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
    lexTest(idProcType^.idtSize>8,S,_��������_���_����������_�������[envER],nil);
  end
end
end trapTITLE;

//---------------- ��������� ------------------

procedure trapPROC(var S:recStream);
//PROCEDURE="PROCEDURE" | "FUNCTION" ��� ["ASCII"] TITLE BODY|FORWARD
//BODY=["VAR" ListVAR] "BEGIN" [ListSTAT] "END"
//FROM="FROM" ���
var procId,procCla,parId,virtId,modId:pID; i:integer; bitFunc,bitComp:boolean; met,name:string[maxText];
begin
with S do
//���������
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
  else //����� ���������
    lexAccept1(S,lexNEW,0);
    if procCla<>nil then
      lstrinsc('.',stLexOld,0);
      lstrins(procCla^.idName,stLexOld,0);
    end;
    procId:=idFindGlo(stLexOld,false);
    lexTest((procId<>nil)and(procId^.idProcAddr<>-1),S,_���������_���_������[envER],nil);
    if procId=nil then
      procId:=idInsertGlo(stLexOld,idPROC);
      procId^.idProcAddr:=-1;
    end;
    procId^.idProcASCII:=okREZ(S,rASCII);
    if procId^.idProcASCII then
      if not traBitDEF then
        lexError(S,_ASCII_�������_���������_������_�_def_������[envER],nil);
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
    with procId^ do //�������� �� ���������� ���������� ������������ ������
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
        lexTest(not bitComp,S,_������������_������_����������_������������_������_[envER],virtId^.idName);
      end
    end end
  end;
  if traCarProc<>nil then mbS(_���������_������_�_traPROC[envER]) end;
  traCarProc:=procId;
  lexAccept1(S,lexPARSE,integer(pSem));
//BODY | DEF | FORWARD
  if okREZ(S,rFORWARD) then //FORWARD
    lexAccept1(S,lexREZ,integer(rFORWARD));
    lexAccept1(S,lexPARSE,integer(pSem))
  elsif (traRecId<>nil)and(traRecId^.idRecCla<>nil) then //����� ������ ������
  else with procId^ do //BODY
    idProcLock:=0;
    idLocMax:=0;
    if not traBitDEFmod then
      idLocList:=memAlloc(sizeof(arrLIST));
//    ����������
      if okREZ(S,rVAR) then
        lexAccept1(S,lexREZ,integer(rVAR));
        trapListVAR(S,idvLOC,0,idProcLock,idLocMax,idLocList);
      end;
//    ��������
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
//  ���������
      with tbMod[tekt] do
        idProcAddr:=topCode;
        stepAdd(S,tekt,stepSimple);
        with genStep^[topGenStep] do
          line:=word(S.stPosPred.y);
          frag:=word(S.stPosPred.f);
        end
      end;
//  enter _������
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
//    pop bx; pop si; leave; ret _���������
      genR(S,cPOP,rEBX);
      genR(S,cPOP,rESI);
      genGen(S,cLEAVE,0);
      genD(S,cRET,idProcPar);
//����� with self
      if idProcCla<>nil then
        dec(topWith)
      end
    else //traBitDEF,������� � ������ �������� DLL
      if traMakeDLL then
      with tbMod[stTxt] do
        expAdd(genExport,procId^.idName,topExport);
      end end
    end
  end end;
  procId^.idProcCode:=tbMod[tekt].topCode-procId^.idProcAddr;
//������ ���������� � ��������� ����������
  for i:=1 to procId^.idProcMax do
    procId^.idProcList^[i]^.idActiv:=byte(false);
  end;
  for i:=1 to procId^.idLocMax do
    procId^.idLocList^[i]^.idActiv:=byte(false);
  end;
  traCarProc:=nil
end
end trapPROC;

//---------------- ������ ---------------------

procedure trapMODULE(var S:recStream);
//MODULE=["DEFINITION"] "UNIT" | "PROGRAM" ��� ";"
//       ["USES" ��� ("," ���) ";"] ListDEF
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
  if traBitH and not traBitDEFmod then lexError(S,_��������_definition_������[envER],nil) end;
  if not traBitH and traBitDEFmod then lexError(S,_��������_�����������_������[envER],nil) end;
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

//end SmTraP.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ RES (��������� ��������)
//���� SMRES.M

//implementation module SmRes;
//import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra;

procedure ������������(���:HWND); forward;

//procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean; forward;
procedure resDlgToTxt(txt:pstr); forward;

//===============================================
//    ������� ��������� ��������
//===============================================

//------ �������������� ���������� ������ � ���������� ----------

procedure ������XY(��:integer; ���Y:boolean):integer;
begin
  case ���Y of
    false:return integer(real(��*loword(GetDialogBaseUnits())) / 4.0);|
    true:return integer(real(��*hiword(GetDialogBaseUnits())) / 8.0);|
  end
end ������XY;

procedure ���XY���(xy:integer; ���Y:boolean):integer;
begin
  case ���Y of
    false:return integer(real(xy*4) / real(loword(GetDialogBaseUnits())));|
    true:return integer(real(xy*8) / real(hiword(GetDialogBaseUnits())));|
  end
end ���XY���;

//--------- ���������� ������ -----------------

procedure �������������(var ���:pstr; �����:pstr);
begin
  if �����=nil then ���:=nil
  else
    ���:=memAlloc(lstrlen(�����)+1);
    lstrcpy(���,�����);
  end
end �������������;

//--------- �������� ����� ����� --------------

procedure �������������(�����:pStyles; var ����:integer; �����:pstr);
begin
  if ����=maxItem
    then mbS(_�������_�����_������[envER])
    else inc(����)
  end;
  �����^[����]:=memAlloc(lstrlen(�����)+1);
  lstrcpy(�����^[����],�����);
end �������������;

//--------- �������� �������� �� ������ --------------

procedure �����������(���:integer; ���,���:pstr);
var ���:integer;
begin
  lstrcpy(���,���);
  for ���:=1 to ���-1 do
    if lstrposc(',',���)>=0 then
      lstrdel(���,0,lstrposc(',',���)+1)
    else ���[0]:=char(0);
    end
  end;
  if lstrposc(',',���)>=0 then
    lstrdel(���,lstrposc(',',���),999)
  end
end �����������;

//===============================================
//    ������� ������� �������� � �������
//===============================================

//---------- �������� ���� �������� -----------

procedure ���������������(����:integer);
var �����:integer;
begin
with resDlg,dItems^[����]^,iRect do
  iBlock:=false;
  �����:=WS_CHILD | WS_VISIBLE | WS_BORDER;
  iWnd:=CreateWindowEx(0,�������������,nil,�����,x,y,dx,dy,
    resDlg.dItems^[0]^.iWnd,0,hINSTANCE,nil);
  if (iText<>nil)and(iText[0]<>char(0))
    then SetWindowText(iWnd,iText)
    else SetWindowText(iWnd,iClass)
  end
end
end ���������������;

//---------- �������� ���� ������� ------------

procedure ��������������(����:HWND);
var �����:integer;
begin
with resDlg,dItems^[0]^,iRect do
  �����:=WS_CHILD | WS_VISIBLE | WS_THICKFRAME | WS_CAPTION;
  iWnd:=CreateWindowEx(0,������������,iText,�����,x,y,
    dx+GetSystemMetrics(SM_CXFRAME)*2,
    dy+GetSystemMetrics(SM_CYFRAME)*2+GetSystemMetrics(SM_CYCAPTION),
    ����,0,hINSTANCE,nil);
  SetWindowText(iWnd,iText);
end
end ��������������;

//---------- ��������� ���������� -------------

procedure ��������������(����:integer);
var ���,���2:string[maxText]; X,Y,dX,dY:integer;
begin
with resDlg,dItems^[����]^,iRect do
  lstrcpy(���,_�����_[envER]); lstrcat(���,iText); SendMessage(resStatus,SB_SETTEXT,ord(dsTextE),cardinal(addr(���)));
  lstrcpy(���,_�����_[envER]); lstrcat(���,iClass); SendMessage(resStatus,SB_SETTEXT,ord(dsClassE),cardinal(addr(���)));
  lstrcpy(���,_��_[envER]); lstrcat(���,iId); SendMessage(resStatus,SB_SETTEXT,ord(dsIdE),cardinal(addr(���)));
  X:=���XY���(x,false);
  Y:=���XY���(y,true);
  dX:=���XY���(dx,false);
  dY:=���XY���(dy,true);
  wvsprintf(���,"x,y:%li,",addr(X));
  wvsprintf(���2,"%li",addr(Y));
  lstrcat(���,���2);
  SendMessage(resStatus,SB_SETTEXT,ord(dsXY),cardinal(addr(���)));
  wvsprintf(���,"dx,dy:%li,",addr(dX));
  wvsprintf(���2,"%li",addr(dY));
  lstrcat(���,���2);
  SendMessage(resStatus,SB_SETTEXT,ord(dsDXDY),cardinal(addr(���)));
end
end ��������������;

//--------------- ���������/����� ����� ----------------

procedure �����������������(�������:integer; ����:boolean);
var �����:integer;
begin
with resDlg do
  if (�������>0)and(�������<=dTop) then
    if dItems^[�������]^.iBlock<>���� then
      if ����
        then �����:=WS_CHILD | WS_VISIBLE | WS_THICKFRAME
        else �����:=WS_CHILD | WS_VISIBLE | WS_BORDER
      end;
      SetWindowLong(dItems^[�������]^.iWnd,GWL_STYLE,�����);
      RedrawWindow(dItems^[�������]^.iWnd,nil,0,RDW_FRAME | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW | RDW_ERASENOW);
      dItems^[�������]^.iBlock:=����
    end
  end
end
end �����������������;

//--------------- ���������� ��������� ��������� � ���� ----------------

procedure ���������������������������();
var
  ���:integer;
  ���X,���Y,���X,���Y:integer;
begin
with resDlg do
//���������� �����
  if ����������X<���������X then
    ���X:=����������X;
    ���X:=���������X;
  else
    ���X:=���������X;
    ���X:=����������X;
  end;
  if ����������Y<���������Y then
    ���Y:=����������Y;
    ���Y:=���������Y;
  else
    ���Y:=���������Y;
    ���Y:=����������Y;
  end;
//�������� ���������
  for ���:=1 to dTop do
  with dItems^[���]^,iRect do
      �����������������(���,(���X<=x)and(���X>=x+dx-1)and(���Y<=y)and(���Y>=y+dy-1));
  end end;
end
end ���������������������������;

//--------------- ����� ������ ----------------

procedure �����������(����:HWND);
var ���,���:integer;
begin
with resDlg do
//����� ������ ��������
  ���:=-1;
  for ���:=0 to dTop do
    if ����=dItems^[���]^.iWnd then
      ���:=���;
  end end;
  if ���>-1 then
//����� ���� ������ ���������
    for ���:=0 to dTop do
      �����������������(���,false);
    end;
//��������� ������
    �����������������(���,true);
    resDlgItem:=���;
    ��������������(resDlgItem);
  end
end
end �����������;

//--------------- ����������� ���� ----------------

procedure ��������������(����:HWND; ����,������,������:integer; ������:boolean);
var ���,���2,���3:RECT; ���,���:integer;
begin
  ���:=-1;
  for ���:=0 to resDlg.dTop do
    if ����=resDlg.dItems^[���]^.iWnd then
      ���:=���;
  end end;
  if ���>-1 then
  with resDlg,dItems^[���]^.iRect do
    case ���� of
      WM_SIZE:
        if ������
          then GetClientRect(����,���)
          else GetWindowRect(����,���);
        end;
        dx:=���.right-���.left;
        dy:=���.bottom-���.top;|
      WM_MOVE:
        GetWindowRect(����,���);
        GetClientRect(����,���2);
        x:=loword(������)-(���.right-���.left-���2.right) div 2;
        y:=hiword(������)-(���.bottom-���.top-���2.bottom) div 2;|
    end;
    ��������������(resDlgItem);
  end end
end ��������������;

//------- ������� ������� �������� -----------

procedure �����������(����:HWND; ����,������,������:integer):integer;
var ���:string[maxText]; ��:HDC; ������:PAINTSTRUCT; ���:RECT; ���:integer;
begin
  case ���� of
//  �������� � ��������
    WM_CREATE:|
    WM_DESTROY:|
//  �����������
    WM_PAINT:
      GetWindowText(����,���,maxText);
      ��:=BeginPaint(����,������);
      SetBkMode(��,TRANSPARENT);
      SetTextColor(��,0xC0C0C0);
      TextOut(��,0,0,���,lstrlen(���));
      EndPaint(����,������);|
//  �������
    WM_SIZE:��������������(����,����,������,������,false);|
    WM_MOVE:��������������(����,����,������,������,false);|
//  ����
    WM_NCHITTEST:
      ���:=integer(DefWindowProc(����,����,������,������));
      if ���=HTCLIENT
        then return HTCAPTION
        else return ���
      end;|
    WM_NCLBUTTONDOWN:
      �����������(����);
      return integer(DefWindowProc(����,����,������,������));|
    WM_NCLBUTTONDBLCLK:������������(resDlgWnd);|
    WM_KEYDOWN:SendMessage(GetParent(����),����,������,������);|
  else return integer(DefWindowProc(����,����,������,������))
  end;
  return 0
end �����������;

//------- �������� ����� ����� -----------

procedure ���������������(��:HDC; ����:HWND);
var
  ���X,���Y,���X,���Y:integer;
  ����,������:HPEN;
begin
//���������� �����
  if ����������X<���������X then
    ���X:=����������X;
    ���X:=���������X;
  else
    ���X:=���������X;
    ���X:=����������X;
  end;
  if ����������Y<���������Y then
    ���Y:=����������Y;
    ���Y:=���������Y;
  else
    ���Y:=���������Y;
    ���Y:=����������Y;
  end;
//���������
  ����:=CreatePen(PS_DOT,1,0);
  ������:=SelectObject(��,����);
  MoveToEx(��,���X,���Y,nil);
  LineTo(��,���X,���Y);
  LineTo(��,���X,���Y);
  LineTo(��,���X,���Y);
  LineTo(��,���X,���Y);
  SelectObject(��,������);
  DeleteObject(����);
end ���������������;

//------- ������� ������� ������� -----------

procedure ����������(����:HWND; ����,������,������:integer):integer;
var ���:string[maxText]; ��:HDC; ������:PAINTSTRUCT;
begin
  case ���� of
//  �������� � ��������
    WM_CREATE:
      ����������X:=0;
      ����������Y:=0;|
    WM_DESTROY:|
//  �������
    WM_SIZE:��������������(����,����,������,������,true);|
    WM_MOVE:��������������(����,����,������,������,true);|
    WM_PAINT:
      if ����������X<>0 then
        ��:=BeginPaint(����,������);
        ���������������(��,����);
        EndPaint(����,������);
      end;
      return integer(DefWindowProc(����,����,������,������));|
//  ���� � ����������
    WM_LBUTTONDOWN:
      �����������(����);
      SetCapture(����);
      ����������X:=loword(������);
      ����������Y:=hiword(������);|
    WM_LBUTTONUP:
      if ����������X<>0 then
        ReleaseCapture();
        ����������X:=0;
        ����������Y:=0;
        InvalidateRect(����,nil,true);
        UpdateWindow(����);
      end;|
    WM_MOUSEMOVE:
      if ����������X<>0 then
        ���������X:=loword(������);
        ���������Y:=hiword(������);
        InvalidateRect(����,nil,true);
        UpdateWindow(����);
        ���������������������������();
      end;|
    WM_LBUTTONDBLCLK:|
    WM_KEYDOWN:SendMessage(GetParent(����),����,������,������);|
    else return integer(DefWindowProc(����,����,������,������))
  end;
  return 0
end ����������;

//===============================================
//             ��������� ������
//===============================================

//--------- �������� ����� ������� ------------

procedure ���������������(��:integer);
var ��,���,���:integer; ���:string[maxText];
begin
with resDlg do
  if dTop=maxItem
    then mbS(_�������_�����_���������_�_�������[envER])
    else inc(dTop)
  end;
  dItems^[dTop]:=memAlloc(sizeof(recItem));
  with dItems^[dTop]^ do
//����������� ������ � ����
    ��:=�� div 100;
    ���:=�� mod 100;
    if (��<=resTopClass)and(���<=resClasses^[��].claTop) then
    with resClasses^[��] do
//���������� ���������� ��������
      �������������(iClass,claName);
      �������������(iText,claIniText);
      �������������(iId,"-1");
      with iRect do
        x:=resDlgIniX;
        y:=resDlgIniY;
        dx:=������XY(claIniDX,false);
        dy:=������XY(claIniDY,true);
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      ���:=2;
      �����������(���,claList[���],���);
      while lstrcmp(���,"")<>0 do
        �������������(iStyles,iTop,���);
        inc(���);
        �����������(���,claList[���],���);
      end;
      iWnd:=0;
      ���������������(dTop);
      �����������(iWnd);
    end end;
  end;
end
end ���������������;

//-------------- �������� ������ ---------------------

procedure ������������();
var ����,���,i:integer; ��:recID; ���:boolean; S:recStream; ������:pstr;
begin
  if resStyles=nil then
    resStyles:=memAlloc(sizeof(arrListStyles));
    resTopStyles:=0;
    envInfBegin(_��������_������_������_��_[envER],resWIN32);
    ����:=_lopen(resWIN32,OF_READ);
    if ����>0 then
    //������� ���������
      _lread(����,addr(���),4);//Entry
      _lread(����,addr(���),4);//���
      _lread(����,addr(���),4);
      _llseek(����,���,FILE_CURRENT);
      _lread(����,addr(���),4);//������
      _lread(����,addr(���),4);
      _llseek(����,���,FILE_CURRENT);
      _lread(����,addr(���),4);//������
      for i:=1 to ��� do
        idReadS(����,������);
        memFree(������);
      end;
    //������ ���������������
      while idReadID(S,��,����) do
      with �� do
        if idClass=idcINT then
        //����� ��������
          ���:=(lstrpos("WS_",idName)=0)or(lstrpos("DS_",idName)=0);
          for ���:=1 to resTopClass do
          if not ��� then
            if lstrpos(resClasses^[���].claStyle,idName)=0 then
              ���:=true
            end
          end end;
        //������ � ������
          if ��� and(resTopStyles<maxListStyles) then
            inc(resTopStyles);
            resStyles^[resTopStyles]:=memAlloc(lstrlen(idName)+1);
            lstrcpy(resStyles^[resTopStyles],idName);
          end
        end;
      //������������ ������
        memFree(idName);
        case idClass of
          idcSTR:memFree(idStr);|
          idtREC:memFree(idRecList);|
          idtSCAL:memFree(idScalList);|
          idPROC:memFree(idProcList); memFree(idProcDLL);|
        end;
      end end;
      _lclose(����);
    end;
    envInfEnd();
  end
end ������������;

//-------------- ������ ������ ---------------------

const
  ���������=101;
  ���������=102;
  ���������=103;
  ����X=104;
  ����DX=105;
  ����Y=106;
  ����DY=107;
  ���������=108;
  ������������=109;
  �����������=110;
  �������������=111;
  ���������������=112;
  ����������=113;
  ������=120;
  ����������=121;

const DLG_STYLE=stringER{"DLG_STYLE_R","DLG_STYLE_E"};
dialog DLG_STYLE_R 22,14,268,176,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "��������� �������� �������"
begin
  control "����� ��������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,2,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,2,194,10
  control "����� ��������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,14,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,14,90,10
  control "�������������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,26,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,26,90,10
  control "�������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,178,16,72,10
  control "X:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,30,14,10
  control "",����X,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,30,26,10
  control "DX:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,30,14,10
  control "",����DX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,30,26,10
  control "Y:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,40,14,10
  control "",����Y,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,40,26,10
  control "DY:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,40,14,10
  control "",����DY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,40,26,10
  control "����� ��������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,66,56,100,10
  control "",���������,"LISTBOX",WS_CHILD | WS_BORDER | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL,2,80,100,74
  control "��������",������������,"Button",0 | WS_CHILD | WS_VISIBLE,162,68,46,10
  control "�������",�����������,"Button",0 | WS_CHILD | WS_VISIBLE,2,68,46,10
  control "�������",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,80,54,10
  control "",�������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,80,100,120
  control "����� ������",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,98,54,10
  control "",���������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,98,100,120
  control "������",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,116,54,10
  control "",����������,"EDIT",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,162,116,100,12
  control "��",������,"Button",0 | WS_CHILD | WS_VISIBLE,82,162,46,10
  control "������",����������,"Button",0 | WS_CHILD | WS_VISIBLE,136,162,46,10
end;
dialog DLG_STYLE_E 22,14,268,176,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "Item options"
begin
  control "Item text:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,2,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,2,194,10
  control "Item class:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,14,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,14,90,10
  control "Identifier:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,26,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,26,90,10
  control "Sizes:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,178,16,72,10
  control "X:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,30,14,10
  control "",����X,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,30,26,10
  control "DX:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,30,14,10
  control "",����DX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,30,26,10
  control "Y:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,40,14,10
  control "",����Y,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,40,26,10
  control "DY:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,40,14,10
  control "",����DY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,40,26,10
  control "Item styles:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,66,56,100,10
  control "",���������,"LISTBOX",WS_CHILD | WS_BORDER | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL,2,80,100,74
  control "Add",������������,"Button",0 | WS_CHILD | WS_VISIBLE,162,68,46,10
  control "Delete",�����������,"Button",0 | WS_CHILD | WS_VISIBLE,2,68,46,10
  control "Window",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,80,54,10
  control "",�������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,80,100,120
  control "Class styles",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,98,54,10
  control "",���������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,98,100,120
  control "Other",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,116,54,10
  control "",����������,"EDIT",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,162,116,100,12
  control "Ok",������,"Button",0 | WS_CHILD | WS_VISIBLE,82,162,46,10
  control "Cancel",����������,"Button",0 | WS_CHILD | WS_VISIBLE,136,162,46,10
end;

//------- ���������� ������� ���������� �������� -----------

procedure ������������(����:HWND; ����,������,������:integer):boolean;
var ���:integer; ���:string[maxText];
begin
  case ���� of
    WM_INITDIALOG:with resDlg.dItems^[resDlgItem]^ do //������������� �������
      SetDlgItemText(����,���������,iText);
      SetDlgItemText(����,���������,iClass);
      SetDlgItemText(����,���������,iId);
      with iRect do
        SetDlgItemInt(����,����X,���XY���(x,false),true);
        SetDlgItemInt(����,����DX,���XY���(dx,false),true);
        SetDlgItemInt(����,����Y,���XY���(y,true),true);
        SetDlgItemInt(����,����DY,���XY���(dy,true),true);
      end;
      for ���:=1 to iTop do
        SendDlgItemMessage(����,���������,LB_ADDSTRING,0,integer(iStyles^[���]));
      end;
    //�������� ������
      ������������();
      if resDlgItem=0 then lstrcpy(���,"DS_")
      else
        ���[0]:=char(0);
        for ���:=1 to resTopClass do
        if lstrcmp(resClasses^[���].claName,iClass)=0 then
          lstrcpy(���,resClasses^[���].claStyle);
        end end
      end;
      for ���:=1 to resTopStyles do
        if lstrpos("WS_",resStyles^[���])=0 then
          SendDlgItemMessage(����,�������������,CB_ADDSTRING,0,integer(resStyles^[���]));
        elsif lstrpos(���,resStyles^[���])=0 then
          SendDlgItemMessage(����,���������������,CB_ADDSTRING,0,integer(resStyles^[���]));
        end
      end;
      SendDlgItemMessage(����,�������������,CB_SETCURSEL,0,0);
      SendDlgItemMessage(����,���������������,CB_SETCURSEL,0,0);
      SetFocus(GetDlgItem(����,���������));
    end;|
    WM_COMMAND:case loword(������) of
      ������������:
        GetDlgItemText(����,resDlgFocus,���,maxText);
        if ���[0]=char(0) then mbS(_������_���������_������_�����[envER])
        elsif SendDlgItemMessage(����,���������,LB_FINDSTRING,0,integer(addr(���)))>=0 then mbS(_������_���������_���������_�����[envER])
        else SendDlgItemMessage(����,���������,LB_ADDSTRING,0,integer(addr(���)))
        end;|
      �����������:
        ���:=SendDlgItemMessage(����,���������,LB_GETCURSEL,0,0);
        if ���>=0 then
          SendDlgItemMessage(����,���������,LB_DELETESTRING,���,0);
          if ���>0 then
            SendDlgItemMessage(����,���������,LB_SETCURSEL,���-1,0);
          end;
          SetFocus(GetDlgItem(����,���������));
        end;|
      IDOK,������:with resDlg.dItems^[resDlgItem]^ do
        memFree(iText); GetDlgItemText(����,���������,���,maxText); �������������(iText,���);
        memFree(iClass); GetDlgItemText(����,���������,���,maxText); �������������(iClass,���);
        memFree(iId); GetDlgItemText(����,���������,���,maxText); �������������(iId,���);
        with iRect do
          x:=������XY(GetDlgItemInt(����,����X,nil,true),false);
          y:=������XY(GetDlgItemInt(����,����Y,nil,true),true);
          dx:=������XY(GetDlgItemInt(����,����DX,nil,true),false);
          dy:=������XY(GetDlgItemInt(����,����DY,nil,true),true);
        end;
        for ���:=1 to iTop do
          memFree(iStyles^[���]);
        end;
        iTop:=SendDlgItemMessage(����,���������,LB_GETCOUNT,0,0);
        for ���:=1 to iTop do
          iStyles^[���]:=memAlloc(SendDlgItemMessage(����,���������,LB_GETTEXTLEN,���-1,0)+1);
          SendDlgItemMessage(����,���������,LB_GETTEXT,���-1,integer(iStyles^[���]));
        end;
        EndDialog(����,1);
      end;|
      IDCANCEL,����������:EndDialog(����,0);|
      �������������,���������������,����������:case hiword(������) of
        CBN_SETFOCUS,EN_SETFOCUS:resDlgFocus:=loword(������);|
      end;|
    end;|
  else return false
  end;
  return true
end ������������;

//-------- ��������� ������ �������� -----------

procedure ������������;
begin
  if boolean(DialogBoxParam(hINSTANCE,DLG_STYLE[envER],���,addr(������������),0)) then
  with resDlg.dItems^[resDlgItem]^,iRect do
    if resDlgItem=0 then
      MoveWindow(iWnd,x,y,
        dx+GetSystemMetrics(SM_CXFRAME)*2,
        dy+GetSystemMetrics(SM_CYFRAME)*2+GetSystemMetrics(SM_CYCAPTION),true);
    else MoveWindow(iWnd,x,y,dx,dy,true)
    end;
    ��������������(resDlgItem);
    if (iText<>nil)and(iText[0]<>char(0))
      then SetWindowText(iWnd,iText)
      else SetWindowText(iWnd,iClass)
    end;
    InvalidateRect(iWnd,nil,true);
    UpdateWindow(iWnd);
  end end
end ������������;

//===============================================
//             ��������� ������ �������
//===============================================

//------------- ����� ������ ------------------

const DLG_FONT=stringER{"DLG_FONT_R","DLG_FONT_E"};
dialog DLG_FONT_R 46,34,184,114,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "����� ������"
begin
  control "�����:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,6,4,32,8
  control "",101,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,4,14,96,78
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,102,4,28,8
  control "",102,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,108,14,24,78
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,22,32,8
  control "",103,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,22,6,6
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,34,32,8
  control "",104,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,34,6,6
  control "����:",-1,"Static",1 | WS_CHILD | WS_VISIBLE,144,54,32,8
  control "��",120,"Button",0 | WS_CHILD | WS_VISIBLE,36,96,52,12
  control "������",121,"Button",0 | WS_CHILD | WS_VISIBLE,94,96,52,12
  control "",105,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,140,65,38,10
end;
dialog DLG_FONT_E 46,34,184,114,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Font"
begin
  control "Font:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,6,4,32,8
  control "",101,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,4,14,96,78
  control "Size:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,102,4,28,8
  control "",102,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,108,14,24,78
  control "Bold:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,22,32,8
  control "",103,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,22,6,6
  control "Italic:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,34,32,8
  control "",104,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,34,6,6
  control "Color:",-1,"Static",1 | WS_CHILD | WS_VISIBLE,144,54,32,8
  control "Ok",120,"Button",0 | WS_CHILD | WS_VISIBLE,36,96,52,12
  control "Cancel",121,"Button",0 | WS_CHILD | WS_VISIBLE,94,96,52,12
  control "",105,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,140,65,38,10
end;

//------------- ����� ������ ------------------

const
  idFntFace=101;
  idFntSize=102;
  idFntBold=103;
  idFntItal=104;
  idFntCol=105;
  idFntOk=120;
  idFntCancel=121;

procedure dlgFont(Wnd:HWND; Message,wParam,lParam:integer):boolean;
var i,j:integer; buf:string[maxText]; fonts:sysFonts; dc:HDC;
begin
  case Message of
    WM_INITDIALOG:
      with carFont do
        SetDlgItemText(Wnd,idFntFace,fFace);
        dc:=GetDC(mainWnd);
        sysGetFamilies(dc,fonts);
        ReleaseDC(dc,mainWnd);
        for i:=1 to fonts.top do
          SendDlgItemMessage(Wnd,idFntFace,CB_ADDSTRING,0,integer(fonts.fnts[i]));
          if lstrcmp(fFace,fonts.fnts[i])=0 then
            SendDlgItemMessage(Wnd,idFntFace,CB_SETCURSEL,i-1,0)
          end;
          memFree(fonts.fnts[i])
        end;
        SetDlgItemInt(Wnd,idFntSize,fSize,false);
        for i:=6 to 20 do
          wvsprintf(buf,"%li",addr(i));
          SendDlgItemMessage(Wnd,idFntSize,CB_ADDSTRING,0,integer(addr(buf)));
          if fSize=i then
            SendDlgItemMessage(Wnd,idFntSize,CB_SETCURSEL,i-6,0)
          end
        end;
        CheckDlgButton(Wnd,idFntBold,integer(fBold));
        CheckDlgButton(Wnd,idFntItal,integer(fItal));
        wvsprintf(buf,"%.6lX",addr(fCol));
        SetDlgItemText(Wnd,idFntCol,buf);
      end;|
    WM_COMMAND:case loword(wParam) of
      idFntBold:
        if boolean(IsDlgButtonChecked(Wnd,idFntBold))
          then CheckDlgButton(Wnd,idFntBold,0)
          else CheckDlgButton(Wnd,idFntBold,1);
        end;|
      idFntItal:
        if boolean(IsDlgButtonChecked(Wnd,idFntItal))
          then CheckDlgButton(Wnd,idFntItal,0)
          else CheckDlgButton(Wnd,idFntItal,1);
        end;|
      idFntCol:if hiword(wParam)=BN_CLICKED then
        GetDlgItemText(Wnd,idFntCol,buf,maxText);
        lstrinsc('x',buf,0); lstrinsc('0',buf,0);
        i:=sysChooseColor(Wnd,wvscani(buf));
        wvsprintf(buf,"%.6lX",addr(i));
        SetDlgItemText(Wnd,idFntCol,buf);
      end;|
      IDOK,idFntOk:
        with carFont do
          GetDlgItemText(Wnd,idFntFace,fFace,maxStrID);
          fSize:=GetDlgItemInt(Wnd,idFntSize,nil,false);
          fBold:=boolean(IsDlgButtonChecked(Wnd,idFntBold));
          fItal:=boolean(IsDlgButtonChecked(Wnd,idFntItal));
          GetDlgItemText(Wnd,idFntCol,buf,maxText);
          lstrinsc('x',buf,0); lstrinsc('0',buf,0);
          fCol:=wvscani(buf);
          if fCol>cardinal(0xFFFFFF) then
            mbS(_��������_����[envER])
          end
        end;
        EndDialog(Wnd,1);|
      IDCANCEL,idFntCancel:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true;
end dlgFont;

//------------- ����� ������ ------------------

procedure ������������(����:HWND);
begin
  with resDlg.dItems^[0]^,carFont do
    RtlZeroMemory(addr(carFont),sizeof(recFont));
    lstrcpy(fFace,iFont);
    fSize:=iSize;
  end;
  if boolean(DialogBoxParam(hINSTANCE,DLG_FONT[envER],����,addr(dlgFont),0)) then
  with resDlg.dItems^[0]^,carFont do
    iFont:=memAlloc(lstrlen(fFace)+1);
    if lstrlen(fFace)=0
      then iFont:=nil
      else lstrcpy(iFont,fFace)
    end;
    iSize:=fSize;
  end end
end ������������;

//------------- ����� ������ ��������� ------------------

procedure envCorrFont(f:classFrag);
begin
  carFont:=stFont[f];
  if boolean(DialogBoxParam(hINSTANCE,DLG_FONT[envER],GetFocus(),addr(dlgFont),0)) then
    stFont[f]:=carFont;
  end
end envCorrFont;

//===============================================
//             ������� ������������
//===============================================

//------- ������� ������ -------------

bitmap bmpToolDlg="tooldlg.bmp";

procedure ����������������(����:HWND);
var
  ���:integer; �������:classDlgComm; bmp:HBITMAP; ���:RECT;
  ������:array[1..maxButt]of TBBUTTON;
begin
  InitCommonControls();
  bmp:=LoadBitmap(hINSTANCE,"bmpToolDlg");
  ���:=0;
  for �������:=cdNULL to cdCancel do
    if (setDlgCommand[envER][�������].numTool>0)and(���<maxButt) then
      inc(���);
      RtlZeroMemory(addr(������[���]),sizeof(TBBUTTON));
      with ������[���] do
        iBitmap:=setDlgCommand[envER][�������].numTool-1;
        idCommand:=idDlgBase+ord(�������);
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_BUTTON;
      end;
    end;
    if (���<maxButt)and((�������=cdEditDel)or(�������=cdAlignDown)or(�������=cdAlignSizeY)) then
      inc(���);
      RtlZeroMemory(addr(������[���]),sizeof(TBBUTTON));
      with ������[���] do
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_SEP;
      end
    end
  end;
  wndToolDlg:=CreateToolbarEx(
    ����,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,���,0,bmp,addr(������),���,20,20,20,20,sizeof(TBBUTTON));
  with ��� do
    GetWindowRect(wndToolDlg,���);
    inc(bottom,10);
    MoveWindow(wndToolDlg,left,top,right-left+1,bottom-top+1,true);
  end;
end ����������������;

//------- ��������� ���������������� ��������� -------------

procedure ��������������(������:cardinal);
var ������:pNMHDR; �����������:pTOOLTIPTEXT;
begin
  ������:=address(������);
  �����������:=address(������);
  with ������^,�����������^ do
    case code of
      TTN_NEEDTEXT:lpszText:=setDlgCommand[envER][classDlgComm(idFrom-idDlgBase)].name;| //����� ������
    end
  end
end ��������������;

//===============================================
//             ������ � �������
//===============================================

//----------- ������ ������ ������� ------------

procedure ���������(�����:pstr; var ���:integer);
begin
  if ������������� then
    if �����[���]<>'\0' then
      inc(���)
    end;
    ����������:=��������
  else
    while (�����[���]=' ')or(�����[���]='\10')or(�����[���]='\13') do
      inc(���);
    end;
    case �����[���] of
      '\0':����������:=��������;|
      'A'..'Z','a'..'z','�'..'�','�'..'�','_'://�������������
        ����������:=���������;
        �������������[0]:='\0';
        lstrcatc(�������������,�����[���]); inc(���);
        while
          (ord(�����[���])>=ord('A'))and(ord(�����[���])<=ord('Z'))or
          (ord(�����[���])>=ord('a'))and(ord(�����[���])<=ord('z'))or
          (ord(�����[���])>=ord('�'))and(ord(�����[���])<=ord('�'))or
          (ord(�����[���])>=ord('�'))and(ord(�����[���])<=ord('�'))or
          (ord(�����[���])>=ord('0'))and(ord(�����[���])<=ord('9'))or
          (�����[���]='_') do
          lstrcatc(�������������,�����[���]);  inc(���);
        end;|
      '"'://������
        ����������:=����������;
        �������������[0]:='\0';
        inc(���);
        while (�����[���]<>'"')and(�����[���]<>'\0') do
          lstrcatc(�������������,�����[���]); inc(���);
        end;
        if �����[���]='"'
          then inc(���);
          else �������������:=true;
        end;|
      '0'..'9'://�����
        ����������:=���������;
        ������������:=ord(�����[���])-ord('0');
        �������������[0]:='\0';
        lstrcatc(�������������,�����[���]); inc(���);
        while (ord(�����[���])>=ord('0'))and(ord(�����[���])<=ord('9')) do
          ������������:=������������*10+ord(�����[���])-ord('0');
          lstrcatc(�������������,�����[���]); inc(���);
        end;|
    else //������
      ����������:=����������;
      �������������:=�����[���];
      inc(���);
    end
  end
end ���������;

//----------- ���� �� ������ ------------

procedure ���������������(�����:pstr; �������������:boolean):boolean;
var ���:integer; ���:string[maxText]; ��������:boolean; ����:HWND;
begin
  with resDlg do
    if ������������� then
      dTop:=-1;
    end;
  //����� �����
    for ���:=1 to dTop do
      �����������������(���,false);
    end;
    ���:=0;
    �������������:=false;
    ���������(�����,���);
    while (����������=���������)and(
      (lstrcmp(�������������,nameREZ[carSet][rCONTROL])=0)or
      (lstrcmp(�������������,nameREZ[carSet][rDIALOG])=0)) do
    //����� �������
      if dTop=maxItem
        then �������������:=true;
        else inc(dTop)
      end;
      if dTop=0 then
        ����:=dItems^[dTop]^.iWnd;
      end;
      dItems^[dTop]:=memAlloc(sizeof(recItem));
      with dItems^[dTop]^ do
      //�����
        ���������(�����,���);
        �������������:=not (����������=����������);
        iText:=memAlloc(lstrlen(�������������)+1);
        lstrcpy(iText,�������������);
      //�������������
        ���������(�����,���);
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        �������������:=not ((����������=���������)or(����������=���������)or
          (����������=����������)and(�������������='-'));
        ��������:=(����������=����������)and(�������������='-');
        if �������� then
          ���������(�����,���);
          �������������:=not ((����������=���������)or(����������=���������));
        end;
        iId:=memAlloc(lstrlen(�������������)+2);
        if �������� then
          lstrcpy(iId,"-");
        end;
        lstrcpy(iId,�������������);
      //�����
        ���������(�����,���);
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        �������������:=not (����������=����������);
        iClass:=memAlloc(lstrlen(�������������)+1);
        lstrcpy(iClass,�������������);
      //�����
        ���������(�����,���);
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        iTop:=0;
        iStyles:=memAlloc(sizeof(arrStyles));
        while (����������=���������)or(����������=���������) do
          if iTop=maxStyle
            then �������������:=true;
            else inc(iTop)
          end;
          iStyles^[iTop]:=memAlloc(lstrlen(�������������)+1);
          lstrcpy(iStyles^[iTop],�������������);
          ���������(�����,���);
          if (����������=����������)and(�������������='|') then
            ���������(�����,���);
          end
        end;
      //�������
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        with iRect do
        //x
          �������������:=not (����������=���������);
          x:=������������;
          ���������(�����,���);
          �������������:=not ((����������=����������)and(�������������=','));
          ���������(�����,���);
        //y
          �������������:=not (����������=���������);
          y:=������������;
          ���������(�����,���);
          �������������:=not ((����������=����������)and(�������������=','));
          ���������(�����,���);
        //cx
          �������������:=not (����������=���������);
          dx:=������������;
          ���������(�����,���);
          �������������:=not ((����������=����������)and(�������������=','));
          ���������(�����,���);
        //cy
          �������������:=not (����������=���������);
          dy:=������������;
          ���������(�����,���);
        end;
        if dTop=0
          then iWnd:=����;
          else ���������������(dTop);
        end;
      end
    end
  end;
//  if ������������� then lstrdel(�����,0,���); mbI(���,�����) end;
  return not �������������
end ���������������;

//----------- ���� � ����� ------------

procedure �������������(�����:pstr; �������������:boolean);
var �������,���:integer; ���:string[maxText];
begin
  with resDlg do
    �����[0]:='\0';
    for �������:=0 to dTop do
    with dItems^[�������]^,iRect do
    if iBlock and(�������>0) or ������������� then
      lstrcat(�����,"\13\10  ");
      if �������=0
        then lstrcat(�����,nameREZ[carSet][rDIALOG])
        else lstrcat(�����,nameREZ[carSet][rCONTROL])
      end;
      lstrcat(�����,' "'); lstrcat(�����,iText); lstrcat(�����,'",');
      lstrcat(�����,iId);
      lstrcatc(�����,','); lstrcatc(�����,'"'); lstrcat(�����,iClass); lstrcatc(�����,'"');  lstrcatc(�����,',');
      if iTop=0 then lstrcatc(�����,'0')
      else
      for ���:=1 to iTop do
        lstrcat(�����,iStyles^[���]);
        if ���<iTop then
          lstrcat(�����," | ");
        end
      end end;
      lstrcatc(�����,',');
      wvsprintf(���,'%li,',addr(x)); lstrcat(�����,���);
      wvsprintf(���,'%li,',addr(y)); lstrcat(�����,���);
      wvsprintf(���,'%li,',addr(dx)); lstrcat(�����,���);
      wvsprintf(���,'%li',addr(dy)); lstrcat(�����,���);
    end end end
  end
end �������������;

//----------- ���������� � clipboard ------------

procedure �����������������();
var �����,�����:pstr;
begin
  �����:=memAlloc(maxResMem);
  �������������(�����,false);
  �����:=memAlloc(lstrlen(�����)+1);
  lstrcpy(�����,�����);
  memFree(�����);
  if OpenClipboard(editWnd) then
    EmptyClipboard();
    SetClipboardData(CF_TEXT,HANDLE(�����));
    CloseClipboard()
  else
    memFree(�����);
    mbS(_������_Clipboard_�����_������_�����������[envER])
  end
end �����������������;

//----------- �������� �� clipboard ------------

procedure ���������������();
var �����,�����:pstr;
begin
  if not OpenClipboard(editWnd) then
    mbS(_������_Clipboard_�����_������_�����������[envER])
  else
    if (IsClipboardFormatAvailable(CF_TEXT)=false)and(IsClipboardFormatAvailable(CF_OEMTEXT)=false) then
      mbI(GetPriorityClipboardFormat(nil,0),_������_��������_������_������_�_Clipboard[envER])
    else
      �����:=pstr(GetClipboardData(CF_TEXT));
      if �����<>nil then
        if not ���������������(�����,false) then
          mbS(_��������_������_�_Clipboard[envER])
        end
      end
    end;
    CloseClipboard()
  end
end ���������������;

//----------- ������� ���� ------------

procedure ��������������(�������������:boolean);
var �������,���:integer;
begin
  with resDlg do
    for �������:=dTop downto 0 do
    with dItems^[�������]^ do
    if iBlock and(�������>0) or ������������� then
      if �������>0 then
        DestroyWindow(iWnd);
      end;
      memFree(iText);
      memFree(iId);
      memFree(iClass);
      for ���:=1 to iTop do
        memFree(iStyles^[���]);
      end;
      memFree(iStyles);
      memFree(dItems^[�������]);
      for ���:=������� to dTop-1 do
        dItems^[���]:=dItems^[���+1];
      end;
      dec(dTop);
    end end end;
    if (resDlgItem>dTop)and(dTop>0) then
      �����������(dItems^[dTop]^.iWnd);
    end;
  end
end ��������������;

//----------- �������� ��� ------------

procedure ������������������();
var ���:integer;
begin
  with resDlg do
    for ���:=1 to dTop do
      �����������������(���,true);
    end
  end
end ������������������;

//----------- ������������ ------------

procedure ����������������(�������:classDlgComm);
var �������,������:integer;
begin
  with resDlg do
  //����������� ������ (�������)
    ������:=0;
    for �������:=1 to dTop do
    with dItems^[�������]^,iRect do
    if iBlock then
      case ������� of
        cdAlignLeft:if (������=0)or(������>=x) then ������:=x end;|
        cdAlignRight:if (������=0)or(������<=x+dx) then ������:=x+dx end;|
        cdAlignUp:if (������=0)or(������>=y) then ������:=y end;|
        cdAlignDown:if (������=0)or(������<=y+dy) then ������:=y+dy end;|
        cdAlignSizeX:if (������=0)or(������<=dx) then ������:=dx end;|
        cdAlignSizeY:if (������=0)or(������<=dy) then ������:=dy end;|
      end
    end end end;
  //��������� ������� (�������)
    for �������:=1 to dTop do
    with dItems^[�������]^,iRect do
    if iBlock then
      case ������� of
        cdAlignLeft:x:=������;|
        cdAlignRight:x:=������-dx;|
        cdAlignUp:y:=������;|
        cdAlignDown:y:=������-dy;|
        cdAlignSizeX:dx:=������;|
        cdAlignSizeY:dy:=������;|
      end;
      MoveWindow(iWnd,x,y,dx,dy,true);
    end end end;
  end
end ����������������;

//----- ��������� ������ ��� ������ -------

procedure �����������������();
var �����:pstr; ���:integer;
begin
  �����:=memAlloc(maxResMem);
  �������������(�����,true);
  if ������������<maxResUndo then inc(������������);
  else
    for ���:=1 to ������������-1 do
      ��������[���]:=��������[���+1];
    end
  end;
  ��������[������������]:=memAlloc(lstrlen(�����)+1);
  lstrcpy(��������[������������],�����);
  memFree(�����);
end �����������������;

//----- ��������� ����� -------

procedure �����������������();
begin
  if ������������>0 then
    ��������������(true);
    if not ���������������(��������[������������],true) then
      mbS(_���������_������_��������_������_�_������_������_[envER]);
      mbS(��������[������������]);
    end;
    with resDlg,dItems^[0]^,iRect do
//      MoveWindow(iWnd,x,y,dx,dy,true);
      if (resDlgItem<0)or(resDlgItem>dTop) then
        resDlgItem:=0
      end;
    end;
    memFree(��������[������������]);
    dec(������������);
  end
end �����������������;

//----- ���������� ������ ������ -------

procedure ������������������();
var ���:integer;
begin
  for ���:=1 to ������������ do
    memFree(��������[���]);
  end
end ������������������;

//===============================================
//      ���������� ������� ��������� ��������
//===============================================

//----- ������ ��������� ������ -------

const
  ���������=101;
  ���������=102;
  ����������=103;
  ����������=104;
  �������=120;
  �����������=121;

const DLG_GEN=stringER{"DLG_GEN_R","DLG_GEN_E"};
dialog DLG_GEN_R 45,43,198,64,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "��������� ������ �������"
begin
  control "������� ������ ������� � ����� ���������",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,4,168,10
  control "������� ������ ������� � clipboard",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,14,168,10
  control "��������� ������ ���������� �������",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,26,168,10
  control "��������� ������ ������ �������",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,36,168,10
  control "��",�������,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,46,49,40,10
  control "������",�����������,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,96,49,40,10
end;
dialog DLG_GEN_E 45,43,198,64,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Dialog text generation"
begin
  control "Insert dialog into the program",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,4,168,10
  control "Insert dialog into the  clipboard",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,14,168,10
  control "Dialog function text generation",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,26,168,10
  control "Dialog call text generation",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,36,168,10
  control "Ok",�������,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,46,49,40,10
  control "Cancel",�����������,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,96,49,40,10
end;

//----- ���������� ������� ��������� ������ -------

procedure ����������������(����:HWND; ����,������,������:integer):boolean;
//������ - ��� ������ �������
var ���:integer; ���:string[maxText];
begin
  case ���� of
    WM_INITDIALOG:
      if boolean(������) then
        SendDlgItemMessage(����,���������,BM_SETCHECK,0,0);
        SendDlgItemMessage(����,���������,BM_SETCHECK,1,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,1,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,1,0);
      else
        SendDlgItemMessage(����,���������,BM_SETCHECK,1,0);
        SendDlgItemMessage(����,���������,BM_SETCHECK,0,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,0,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,0,0);
      end;|
    WM_COMMAND:case loword(������) of
      BN_CLICKED:case loword(������) of
        ���������:SendDlgItemMessage(����,���������,BM_SETCHECK,0,0);|
        ���������:SendDlgItemMessage(����,���������,BM_SETCHECK,1,0);|
      end;|
      IDOK,�������:
        ����������������:=SendDlgItemMessage(����,���������,BM_GETCHECK,0,0)=BST_CHECKED;
        ������������������:=SendDlgItemMessage(����,����������,BM_GETCHECK,0,0)=BST_CHECKED;
        �����������������:=SendDlgItemMessage(����,����������,BM_GETCHECK,0,0)=BST_CHECKED;
        EndDialog(����,1);|
      IDCANCEL,�����������:EndDialog(����,0);|
    end;|
  else return false
  end;
  return true
end ����������������;

//----- ����� ������� ��������� ������ -------

procedure ���������������(����:HWND; ��������������:boolean):boolean;
begin
  return boolean(DialogBoxParam(hINSTANCE,DLG_GEN[envER],����,addr(����������������),cardinal(��������������)));
end ���������������;

//----- �������� ������-������ ��������� -------

procedure �������������(����:HWND; �������:boolean);
var ����:array[classDlgStatus]of integer; ���:RECT; ����:classDlgStatus; ���,������:integer;
begin
  if ������� then
    resStatus:=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      nil,����,0);
  end;
  GetClientRect(����,���);
  if not ������� then
  with ��� do
    SendMessage(resStatus,WM_SIZE,right-left+1,bottom-top+1);
  end end;
  ���:=0;
  for ����:=dsTextE to resFinStatus do
    ������:=(���.right-���.left+1)*resStatusProc[����] div 100;
    ����[����]:=���+������;
    inc(���,������)
  end;
  ����[resFinStatus]:=-1;
  SendMessage(resStatus,SB_SETPARTS,ord(resFinStatus)+1,cardinal(addr(����)));
end �������������;

//----------- �������� ���� -------------------

procedure �����������():HMENU;
var ����,�������,�������2:HMENU; ���,���:integer; ���:string[maxText]; �������:classDlgComm;
begin
  ����:=CreateMenu();
//���� _�����[envER]
  �������:=CreatePopupMenu();
  for ���:=1 to resTopClass do
  with resClasses^[���] do
    �������2:=CreatePopupMenu();
    for ���:=1 to claTop do
      lstrcpy(���,claList[���]);
      lstrdel(���,lstrposc(',',���),999);
      AppendMenu(�������2,MF_STRING,idDlgBaseNew+���*100+���,���);
    end;
    AppendMenu(�������,MF_POPUP,�������2,resClasses^[���].claMenu);
  end end;
  AppendMenu(����,MF_POPUP,�������,setDlgCommand[envER][cdNew].name);
//���� _������[envER]
  �������:=CreatePopupMenu();
  for �������:=cdEditUndo to cdEditAll do
    if (�������=cdEditCut)or(�������=cdEditAll) then
      AppendMenu(�������,MF_SEPARATOR,0,nil);
    end;
    AppendMenu(�������,MF_STRING,idDlgBase+ord(�������),setDlgCommand[envER][�������].name);
  end;
  AppendMenu(����,MF_POPUP,�������,setDlgCommand[envER][cdEdit].name);
//���� _���������[envER]
  �������:=CreatePopupMenu();
  for �������:=cdAlignLeft to cdAlignSizeY do
    if �������=cdAlignSizeX then
      AppendMenu(�������,MF_SEPARATOR,0,nil);
    end;
    AppendMenu(�������,MF_STRING,idDlgBase+ord(�������),setDlgCommand[envER][�������].name);
  end;
  AppendMenu(����,MF_POPUP,�������,setDlgCommand[envER][cdAlign].name);
//������ ������
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdParam),setDlgCommand[envER][cdParam].name);
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdFont),setDlgCommand[envER][cdFont].name);
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdOk),setDlgCommand[envER][cdOk].name);
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdCancel),setDlgCommand[envER][cdCancel].name);
  return ����;
end �����������;

//----- ������ ��������� �������� -----

const DLG_RES=stringER{"DLG_RES_R","DLG_RES_E"};
dialog DLG_RES_R 80,48,160,96,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "�������� ��������"
begin
end;
dialog DLG_RES_E 80,48,160,96,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "Dialog editor"
begin
end;

//----- ���������� ������� ��������� �������� -----

procedure ��������������(����:HWND; ����,������,������:integer):boolean;
var ���:integer; ���:string[maxText];
begin
  case ���� of
    WM_INITDIALOG:
      resDlgWnd:=����;
      ���:=GetSystemMetrics(SM_CYCAPTION);
      MoveWindow(����,���,���,GetSystemMetrics(SM_CXSCREEN)-���*2,
        GetSystemMetrics(SM_CYSCREEN)-GetSystemMetrics(SM_CYCAPTION)*3 div 2-���*2,true);
      SetMenu(����,�����������());
      �������������(����,true);
      resDlgItem:=0;
      ��������������(����);
      for ���:=1 to resDlg.dTop do
        ���������������(���);
      end;
      ������������:=0;
      �����������������();
      ����������������(����);
      ��������������(resDlgItem);|
    WM_SIZE:�������������(����,false);|
    WM_NOTIFY:��������������(������);|
    WM_COMMAND:case loword(������) of
      idDlgBaseNew..idDlgBaseNew+5000:�����������������(); ���������������(loword(������)-idDlgBaseNew);|
      idDlgBase+cdEditUndo:�����������������();|
      idDlgBase+cdEditCut:�����������������(); �����������������(); ��������������(false);|
      idDlgBase+cdEditCopy:�����������������(); �����������������();|
      idDlgBase+cdEditPaste:�����������������(); ���������������();|
      idDlgBase+cdEditDel:�����������������(); ��������������(false);|
      idDlgBase+cdEditAll:������������������();|
      idDlgBase+cdAlignLeft..idDlgBase+cdAlignSizeY:�����������������(); ����������������(classDlgComm(loword(������)-idDlgBase));|
      idDlgBase+cdParam:�����������������(); ������������(����);|
      idDlgBase+cdFont:������������(����);|
      idDlgBase+cdOk:
        if ���������������(����,�����������������) then
          ������������������();
          EndDialog(����,1);
        end;|
      IDCANCEL,idDlgBase+cdCancel:������������������(); EndDialog(����,0);|
    end;|
    WM_KEYDOWN:case loword(������) of
      VK_DELETE:SendMessage(����,WM_COMMAND,idDlgBase+ord(cdEditDel),0);|
//      VK_RETURN:SendMessage(����,WM_COMMAND,idDlgBase+ord(cdParam),0);|
//      VK_TAB:with resDlg do
//        if resDlgItem<dTop then �����������(dItems^[resDlgItem+1]^.iWnd);
//        elsif resDlgItem=dTop then �����������(dItems^[0]^.iWnd);
//        elsif dTop>0 then �����������(dItems^[1]^.iWnd);
//        end;
//      end;|
    end;|
  else return false
  end;
  return true
end ��������������;

//===============================================
//             ��������� �������
//===============================================

//-------------- ������ ������ ----------------

procedure ���������������();
var dlgx,dlgy:integer;
begin
  with resDlg do
    dMenu:=nil;
    dTop:=2;
    dItems:=memAlloc(sizeof(arrItem));
//������
    dItems^[0]:=memAlloc(sizeof(recItem));
    with dItems^[0]^ do
      �������������(iText,_������[envER]);
      �������������(iClass,nil);
      �������������(iId,"DLG");
      with iRect do
        x:=GetSystemMetrics(SM_CXSCREEN)*25 div 100;
        y:=GetSystemMetrics(SM_CYSCREEN)*20 div 100;
        dx:=GetSystemMetrics(SM_CXSCREEN)*50 div 100;
        dy:=GetSystemMetrics(SM_CYSCREEN)*40 div 100;
        dlgx:=dx;
        dlgy:=dy-GetSystemMetrics(SM_CYCAPTION);
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      �������������(iStyles,iTop,"WS_POPUP");
      �������������(iStyles,iTop,"WS_CAPTION");
      �������������(iStyles,iTop,"WS_SYSMENU");
      �������������(iStyles,iTop,"DS_MODALFRAME");
    end;
//������� 1
    dItems^[1]:=memAlloc(sizeof(recItem));
    with dItems^[1]^ do
      �������������(iText,_��[envER]);
      �������������(iId,"IDOK");
      �������������(iClass,"Button");
      with iRect do
        x:=dlgx*20 div 100;
        y:=dlgy*90 div 100;
        dx:=dlgx*28 div 100;
        dy:=dlgy*10 div 100;
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      �������������(iStyles,iTop,"WS_CHILD");
      �������������(iStyles,iTop,"WS_VISIBLE");
      �������������(iStyles,iTop,"BS_DEFPUSHBUTTON");
    end;
//{������� 2}
    dItems^[2]:=memAlloc(sizeof(recItem));
    with dItems^[2]^ do
      �������������(iText,_������[envER]);
      �������������(iId,"IDCANCEL");
      �������������(iClass,"Button");
      with iRect do
        x:=dlgx*52 div 100;
        y:=dlgy*90 div 100;
        dx:=dlgx*28 div 100;
        dy:=dlgy*10 div 100;
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      �������������(iStyles,iTop,"WS_CHILD");
      �������������(iStyles,iTop,"WS_VISIBLE");
      �������������(iStyles,iTop,"BS_PUSHBUTTON");
    end
  end;
end ���������������;

//------------ ��������� ������� --------------

procedure �������������(��������:boolean):pstr;
var i:integer; ���:pstr;
begin
  if �������� then
    ���������������();
  end;
  if boolean(DialogBoxParam(hINSTANCE,DLG_RES[envER],mainWnd,addr(��������������),0)) then
    ���:=memAlloc(maxBufClip);
    resDlgToTxt(���);
    return ���;
  else return nil
  end;
end �������������;

//------- ����������� ������� ������� ---------

procedure �������������();
var �����:WNDCLASS;
begin
  �����.hInstance:=hINSTANCE;
  with ����� do
    style:=CS_HREDRAW | CS_VREDRAW;
    cbClsExtra:=0;
    cbWndExtra:=0;
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=GetStockObject(GRAY_BRUSH);
    lpszMenuName:=nil;
    lpfnWndProc:=addr(�����������);
    lpszClassName:=�������������;
  end;
  if RegisterClass(�����)=0 then
    mbS(_������_�����������_������_��������[envER]);
  end;
  with ����� do
    lpfnWndProc:=addr(����������);
    lpszClassName:=������������;
    hbrBackground:=CreateHatchBrush(HS_CROSS,0);
  end;
  if RegisterClass(�����)=0 then
    mbS(_������_�����������_������_�������[envER]);
  end;
end �������������;

//===============================================
//             ���������� ��������
//===============================================

//----------- ������������� ������ ------------

procedure resOpen(var S:recStream; cart:integer);
begin
  with S,tbMod[cart] do
    lstrcpy(addr(stFile),modNam);
    with txts[txtn[cart]][cart] do
      with stPosLex do f:=1; y:=txtTrackY+txtCarY end;
      with stPosPred do f:=1; y:=txtTrackY+txtCarY end;
      with stErrPos do f:=1; y:=txtTrackY+txtCarY end;
    end;
    stLex:=lexNULL;
    stLexInt:=0;
    stLexStr[0]:=char(0);
    stLexOld[0]:=char(0);
    stLexReal:=0.0;
    stErr:=false;
    stErrText[0]:=char(0);
    stLoad:=false;
    stTxt:=cart;
    stExt:=txtn[cart];
    idDestroy(tbMod[cart].modTab);
    idInitial(tbMod[cart].modTab,cart);
    lexGetLex0(S);
  end
end resOpen;

//--------------- �����-bmp (������) -------------------

procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean;
var S:recStream;
begin
  with S do
    resOpen(S,cart);
    if bitBmp then
      lexAccept00(S,lexREZ,integer(rBITMAP));
      lexAccept00(S,lexNEW,0);
      lexAccept00(S,lexPARSE,integer(pEqv));
    else lexAccept00(S,lexREZ,integer(rICON));
    end;
    lstrcpy(str,stLexStr);
    lexAccept00(S,lexSTR,0);
    if stErr then
//      envSetError(cart,stErrPos.f,stErrPos.y);
//      envUpdate(editWnd);
      MessageBox(0,stErrText,_������[envER],MB_ICONSTOP);
    end;
    return stErr;
  end;
end resTxtToBmp;

//--------------- �����-������ ----------------

procedure resTxtToDlg(cart:integer; var ���Y,���Y:integer):boolean;
var S:recStream; bitMin:boolean; str:string[maxText];
begin
  with S,tbMod[cart],resDlg do
    with txts[txtn[cart]][cart] do
      ���Y:=txtTrackY+txtCarY;
    end;
    resOpen(S,cart);
//������������� �������
    dItems:=memAlloc(sizeof(arrItem));
    dTop:=0;
    dItems^[0]:=memAlloc(sizeof(recItem));
    dMenu:=nil;
//  ��������� �������
    lexAccept00(S,lexREZ,integer(rDIALOG));
    with dItems^[dTop]^ do
     �������������(iId,stLexStr);
     lexAccept00(S,lexNEW,0);
      with iRect do
        x:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        y:=������XY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        dx:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        dy:=������XY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
      end;
//  �����
      iStyles:=memAlloc(sizeof(arrStyles));
      iTop:=1;
      iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
      lstrcpy(iStyles^[iTop],stLexStr);
      case stLex of
        lexINT:lexAccept00(S,lexINT,0);|
        lexNEW:lexAccept00(S,lexNEW,0);|
      end;
      while okPARSE(S,pVer) do
        lexAccept00(S,lexPARSE,integer(pVer));
        if iTop<maxStyle then
          inc(iTop);
        end;
        iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iStyles^[iTop],stLexStr);
        case stLex of
          lexINT:lexAccept00(S,lexINT,0);|
          lexNEW:lexAccept00(S,lexNEW,0);|
        end
      end;
//  ���������
      if not okPARSE(S,pCol) then iText:=nil
      else
        lexAccept00(S,lexPARSE,integer(pCol));
        iText:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iText,stLexStr);
        lexAccept00(S,lexSTR,0);
      end;
//�����
      iClass:=nil;
      if okPARSE(S,pCol) then
        lexAccept00(S,lexPARSE,integer(pCol));
        if not okPARSE(S,pCol) then
          iClass:=memAlloc(lstrlen(stLexStr)+1);
          lstrcpy(iClass,stLexStr);
          lexAccept00(S,lexSTR,0);
        end
      end;
//����
    if not okPARSE(S,pCol) then iFont:=nil
    else
      lexAccept00(S,lexPARSE,integer(pCol));
      iFont:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(iFont,addr(stLexStr));
      lexAccept00(S,lexSTR,0);
      lexAccept00(S,lexPARSE,integer(pCol));
      iSize:=stLexInt; lexAccept00(S,lexINT,0);
    end
    end;
//��������
    if okREZ(S,rBEGIN) then
      lexAccept00(S,lexREZ,integer(rBEGIN));
      while okREZ(S,rCONTROL) do
      if dTop=maxItem then lexError(S,_�������_�����_���������_�_�������[envER],nil)
      else
        inc(dTop);
        dItems^[dTop]:=memAlloc(sizeof(recItem));
//  ������� �������
      with dItems^[dTop]^ do
        lexAccept00(S,lexREZ,integer(rCONTROL));
//  �����
        iText:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iText,stLexStr);
        lexAccept00(S,lexSTR,0);
        lexAccept00(S,lexPARSE,integer(pCol));
//  �������������
        bitMin:=false;
        if okPARSE(S,pMin) then
          lexAccept00(S,lexPARSE,integer(pMin));
          bitMin:=true;
        end;
        iId:=memAlloc(lstrlen(stLexStr)+2); iId[0]:=char(0);
        if bitMin then
          lstrcatc(iId,'-');
        end;
        case stLex of
          lexINT:wvsprintf(str,"%li",addr(stLexInt)); lstrcat(iId,str);|
          lexNEW:lstrcat(iId,stLexStr);|
        end;
        case stLex of
          lexINT:lexAccept00(S,lexINT,0);|
          lexNEW:lexAccept00(S,lexNEW,0);|
        end;
        lexAccept00(S,lexPARSE,integer(pCol));
//  �����
        iClass:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iClass,stLexStr);
        lexAccept00(S,lexSTR,0);
        lexAccept00(S,lexPARSE,integer(pCol));
//  �����
        iStyles:=memAlloc(sizeof(arrStyles));
        iTop:=1;
        iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iStyles^[iTop],stLexStr);
        case stLex of
          lexINT:lexAccept00(S,lexINT,0);|
          lexNEW:lexAccept00(S,lexNEW,0);|
        end;
        while okPARSE(S,pVer) do
          lexAccept00(S,lexPARSE,integer(pVer));
          if iTop<maxStyle then
            inc(iTop);
          end;
          iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
          lstrcpy(iStyles^[iTop],stLexStr);
          case stLex of
            lexINT:lexAccept00(S,lexINT,0);|
            lexNEW:lexAccept00(S,lexNEW,0);|
          end
        end;
        lexAccept00(S,lexPARSE,integer(pCol));
//  �������
        with iRect do
          x:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          y:=������XY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          dx:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          dy:=������XY(stLexInt,true); lexAccept00(S,lexINT,0);
        end
      end
      end end;
      lexAccept00(S,lexREZ,integer(rEND));
      ���Y:=stPosLex.y;
      lexAccept00(S,lexPARSE,integer(pSem));
    end;
    if stErr then
//      envSetError(cart,stErrPos.f,stErrPos.y);
//      envUpdate(editWnd);
      MessageBox(0,stErrText,_������[envER],MB_ICONSTOP);
    end;
    return stErr
  end;
end resTxtToDlg;

//--------------- ����� ���������� ������� (������) ----------------

procedure resDlgFunMODULA(txt:pstr);
var i:integer;
begin
with resDlg do
if ������������������ then
  lstrcat(txt,"\13\10");
//procedure ��������������(wnd:HWND; message,wparam,lparam:integer):boolean;
  lstrcat(txt,nameREZ[carSet][rPROCEDURE]); lstrcat(txt," proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"(wnd:HWND; message,wparam,lparam:integer):boolean;\13\10");
//begin case message of
  lstrcat(txt,nameREZ[carSet][rBEGIN]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," message "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//WM_INITDIALOG:| WM_COMMAND:case loword(wparam) of
  lstrcat(txt,"    WM_INITDIALOG:|\13\10");
  lstrcat(txt,"    WM_COMMAND:"); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rLOWORD]); lstrcat(txt,"(wparam) "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//IDOK:EndDialog(wnd,1);| IDCANCEL:EndDialog(wnd,0);|
  lstrcat(txt,"      IDOK:EndDialog(wnd,1);|\13\10");
  lstrcat(txt,"      IDCANCEL:EndDialog(wnd,0);|\13\10");
//end;| else return false end; return true
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";|\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rELSE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rFALSE]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rTRUE]); lstrcat(txt,"\13\10");
//end ��������������;
  lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt," proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,";\13\10");
end;

//-----------------����� ������ �������
if ����������������� then
//DialogBoxParam(hINSTANCE,_����������[envER],0,addr(��������������),0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,addr(proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"),0);\13\10");
end;

end
end resDlgFunMODULA;

//--------------- ����� ���������� ������� (��) ----------------

procedure resDlgFunC(txt:pstr);
var i:integer;
begin
with resDlg do
if ������������������ then
  lstrcat(txt,"\13\10");
//boolean ��������������(HWND wnd,int message,int wparam,int lparam)
  lstrcat(txt,"bool proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"(HWND wnd,int message,int wparam,int lparam)\13\10");
//{ switch(message) {
  lstrcat(txt,"{\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rSWITCH]); lstrcat(txt,"(message) {"); lstrcat(txt,"\13\10");
//case WM_INITDIALOG:break; case WM_COMMAND:switch(loword(wparam)) {
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," WM_INITDIALOG:"); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," WM_COMMAND:"); lstrcat(txt,nameREZ[carSet][rSWITCH]); lstrcat(txt,"("); lstrcat(txt,nameREZ[carSet][rLOWORD]); lstrcat(txt,"(wparam)) {"); lstrcat(txt,"\13\10");
//case IDOK:EndDialog(wnd,1); break; case IDCANCEL:EndDialog(����,0); break;
  lstrcat(txt,"      "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," IDOK:EndDialog(wnd,1); "); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
  lstrcat(txt,"      "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," IDCANCEL:EndDialog(wnd,0); "); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
//default:return false; break;
  lstrcat(txt,"      "); lstrcat(txt,nameREZ[carSet][rDEFAULT]); lstrcat(txt,":");
  lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rFALSE]); lstrcat(txt,"; ");
  lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
//} break; } return true;
  lstrcat(txt,"    "); lstrcat(txt,"} "); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,"}\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rTRUE]); lstrcat(txt,";\13\10");
//}
  lstrcat(txt,"}\13\10");
end;

//-----------------����� ������ �������
if ����������������� then
//DialogBoxParam(hINSTANCE,_����������[envER],0,&��������������,0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,&proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,",0);\13\10");
end;

end
end resDlgFunC;

//--------------- ����� ���������� ������� (�������) ----------------

procedure resDlgFunPASCAL(txt:pstr);
var i:integer;
begin
with resDlg do
if ������������������ then
  lstrcat(txt,"\13\10");
//function ��������������(wnd:HWND; message,wparam,lparam:integer):boolean;
  lstrcat(txt,nameREZ[carSet][rFUNCTION]); lstrcat(txt," proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"(wnd:HWND; message,wparam,lparam:integer):boolean;\13\10");
//begin case message of
  lstrcat(txt,nameREZ[carSet][rBEGIN]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," message "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//WM_INITDIALOG:; WM_COMMAND:case loword(wparam) of
  lstrcat(txt,"    WM_INITDIALOG:;\13\10");
  lstrcat(txt,"    WM_COMMAND:"); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rLOWORD]); lstrcat(txt,"(wparam) "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//IDOK:EndDialog(wnd,1); IDCANCEL:EndDialog(wnd,0);
  lstrcat(txt,"      IDOK:EndDialog(wnd,1);\13\10");
  lstrcat(txt,"      IDCANCEL:EndDialog(wnd,0);\13\10");
//end; else return false end; return true
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rELSE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rFALSE]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rTRUE]); lstrcat(txt,"\13\10");
//end;
  lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
end;

//-----------------����� ������ �������
if ����������������� then
//DialogBoxParam(hINSTANCE,_����������[envER],0,addr(��������������),0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,addr(proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"),0);\13\10");
end;

end
end resDlgFunPASCAL;

//--------------- ������-����� ----------------

procedure resDlgToTxt;
var s:string[maxText]; i,j,k:integer;
begin
with resDlg do
  txt[0]:=char(0);
//���������
  with dItems^[0]^,iRect do
    lstrcat(txt,nameREZ[carSet][rDIALOG]); lstrcatc(txt,' ');
    lstrcat(txt,iId); lstrcatc(txt,' ');
    k:=���XY���(x,false); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=���XY���(y,true); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=���XY���(dx,false); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=���XY���(dy,true); wvsprintf(s,"%li,\13\10  ",addr(k)); lstrcat(txt,s);
    if iTop=0 then lstrcatc(txt,'0')
    else
    for j:=1 to iTop do
      lstrcat(txt,iStyles^[j]);
      if j<iTop then
        lstrcat(txt," | ");
      end
    end end;
    lstrcat(txt,",\13\10  ");
    lstrcatc(txt,'"');
    lstrcat(txt,iText);
    lstrcatc(txt,'"');
    if (iClass<>nil)and(iClass[0]<>char(0)) then
      lstrcat(txt,',"');
      lstrcat(txt,iClass);
      lstrcatc(txt,'"');
    end;
    if not((iClass<>nil)and(iClass[0]<>char(0)))and(iFont<>nil)and(iFont[0]<>char(0)) then
      lstrcatc(txt,',');
    end;
    if (iFont<>nil)and(iFont[0]<>char(0)) then
      lstrcat(txt,',"');
      lstrcat(txt,iFont);
      lstrcat(txt,'",');
      wvsprintf(s,"%li",addr(iSize)); lstrcat(txt,s);
    end
  end;
//��������
  lstrcat(txt,"\13\10");
  lstrcat(txt,nameREZ[carSet][rBEGIN]);
  for i:=1 to dTop do
  with dItems^[i]^,iRect do
    lstrcat(txt,"\13\10  ");
    lstrcat(txt,nameREZ[carSet][rCONTROL]);
    lstrcat(txt,' "'); lstrcat(txt,iText); lstrcat(txt,'",');
    lstrcat(txt,iId);
    lstrcatc(txt,','); lstrcatc(txt,'"'); lstrcat(txt,iClass); lstrcatc(txt,'"');  lstrcatc(txt,',');
    if iTop=0 then lstrcatc(txt,'0')
    else
    for j:=1 to iTop do
      lstrcat(txt,iStyles^[j]);
      if j<iTop then
        lstrcat(txt," | ");
      end
    end end;
    lstrcatc(txt,',');
    k:=���XY���(x,false); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=���XY���(y,true); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=���XY���(dx,false); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=���XY���(dy,true); wvsprintf(s,'%li',addr(k)); lstrcat(txt,s);
  end end;
  lstrcat(txt,"\13\10");
  lstrcat(txt,nameREZ[carSet][rEND]);
  lstrcat(txt,";\13\10");

//-----------------����� ���������� ������� � ������ �������
  case traLANG of
    langMODULA:resDlgFunMODULA(txt);|
    langC:resDlgFunC(txt);|
    langPASCAL:resDlgFunPASCAL(txt);|
  end;

end
end resDlgToTxt;

//===============================================
//             ��������� ��������� ��������
//===============================================

//---------- ������� ���������� ������� -----------

procedure ���������������(�����:pClass; var ����:integer);
var ��,���:integer;
begin
  for ��:=1 to ���� do
  with �����^[��] do
    for ���:=1 to claTop do
      memFree(claList[���]);
    end;
    claTop:=0;
  end end;
  ����:=0;
end ���������������;

//---------- ����������� ���������� ������� -----------

procedure ������������(���,����:pClass; var �������,��������:integer);
var ��,���:integer;
begin
  ��������:=�������;
  for ��:=1 to ������� do
    ����^[��]:=���^[��];
    with ����^[��] do
      for ���:=1 to claTop do
        claList[���]:=memAlloc(lstrlen(���^[��].claList[���])+1);
        lstrcpy(claList[���],���^[��].claList[���]);
      end
    end
  end;
end ������������;

//---------- ��������� ������� �� ��������� -----------

procedure �������������();
var ��,���,����:integer;
begin
  ����:=0;
  resTopClass:=ord(lastIniClass)+1;
  for ��:=1 to resTopClass do
    resClasses^[��]:=iniClass[envER][classIniClass(��-1)];
    with resClasses^[��] do
    for ���:=1 to claTop do
      inc(����);
      claList[���]:=memAlloc(lstrlen(iniMenu[envER][����])+1);
      lstrcpy(claList[���],iniMenu[envER][����]);
    end end;
  end
end �������������;

//---------- ���������� ���������� ������� -----------

procedure ������������();
var ����,��,���,��:integer;
begin
  ����:=_lcreat(ResFile,0);
  if ����>0 then
    _lwrite(����,resWIN32,maxText);
    _lwrite(����,addr(resTopClass),4);
    for ��:=1 to resTopClass do
    with resClasses^[��] do
      _lwrite(����,addr(resClasses^[��]),sizeof(recClass));
      for ���:=1 to claTop do
        ��:=lstrlen(claList[���]);
        _lwrite(����,addr(��),4);
        _lwrite(����,claList[���],lstrlen(claList[���])+1);
      end;
    end end;
    _lclose(����)
  end
end ������������;

//---------- �������� ���������� ������� -----------

procedure ������������();
var ����,��,���,��:integer;
begin
  ����:=_lopen(ResFile,0);
  if ����>0 then
    _lread(����,resWIN32,maxText);
    _lread(����,addr(resTopClass),4);
    for ��:=1 to resTopClass do
    with resClasses^[��] do
      _lread(����,addr(resClasses^[��]),sizeof(recClass));
      for ���:=1 to claTop do
        _lread(����,addr(��),4);
        claList[���]:=memAlloc(��+1);
        _lread(����,claList[���],��+1);
      end;
    end end;
    _lclose(����)
  else �������������();
  end
end ������������;

//----------- ������ �������� ------------

const
  �����Win32=101;
  �����������=102;
  �������������=103;
  ������������=104;
  ��������������=10;
  ���������������=106;
  ����������=107;
  �������������=108;
  ��������X=109;
  ��������Y=110;
  �������������=111;
  ������������=112;
  ���������������=113;
  ��������������=114;
  �������=120;
  �����������=121;
  ��������������=122;

const DLG_SETDLG=stringER{"DLG_SETDLG_R","DLG_SETDLG_E"};
dialog DLG_SETDLG_R 2,6,304,188,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "��������� ��������� ��������"
begin
  control "���� Win32:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,42,2,60,10
  control "",�����Win32,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,2,74,10
  control "������ �������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,14,80,10
  control "",�����������,"LISTBOX",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,8,28,80,68
  control "��������",�������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,8,96,36,10
  control "�������",������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,50,96,36,10
  control "�������� ������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,136,18,88,10
  control "�������� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,32,90,10
  control "",���������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,32,60,10
  control "��� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,44,90,10
  control "",��������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,44,60,10
  control "������� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,56,90,10
  control "",����������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,56,40,10
  control "��������� �����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,68,90,10
  control "",�������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,68,60,10
  control "��������� ������ �� X:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,80,90,10
  control "",��������X,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,80,40,10
  control "��������� ������ �� Y:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,92,90,10
  control "",��������Y,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,92,40,10
  control "������ ��������� ������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,32,110,108,10
  control "",�������������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY,2,120,300,40
  control "",������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,2,162,300,10
  control "��������",���������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,152,110,38,10
  control "�������",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,194,110,38,10
  control "��",�������,"Button",WS_CHILD | WS_VISIBLE,84,174,44,10
  control "��������",�����������,"Button",WS_CHILD | WS_VISIBLE,136,174,44,10
  control "�� ���������",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,250,174,52,10
end;
dialog DLG_SETDLG_E 2,6,304,188,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Options"
begin
  control "Win32 file:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,42,2,60,10
  control "",�����Win32,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,2,74,10
  control "Classes list:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,14,80,10
  control "",�����������,"LISTBOX",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,8,28,80,68
  control "Add",�������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,8,96,36,10
  control "Delete",������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,50,96,36,10
  control "Class options:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,136,18,88,10
  control "Class name:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,32,90,10
  control "",���������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,32,60,10
  control "Class ident:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,44,90,10
  control "",��������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,44,60,10
  control "Styles prefix:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,56,90,10
  control "",����������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,56,40,10
  control "Initial text:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,68,90,10
  control "",�������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,68,60,10
  control "Initial size X:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,80,90,10
  control "",��������X,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,80,40,10
  control "Initial size Y:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,92,90,10
  control "",��������Y,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,92,40,10
  control "Class variants:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,32,110,108,10
  control "",�������������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY,2,120,300,40
  control "",������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,2,162,300,10
  control "Add",���������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,152,110,38,10
  control "Delete",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,194,110,38,10
  control "Ok",�������,"Button",WS_CHILD | WS_VISIBLE,84,174,44,10
  control "Cancel",�����������,"Button",WS_CHILD | WS_VISIBLE,136,174,44,10
  control "By default",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,250,174,52,10
end;

//--------------------- ���������� ��������� ������ ----------------------------

procedure ������������(����:HWND; ��:integer);
var s:string[maxText]; ���:integer;
begin
  if (��>0)and(��<=resTopClass) then
  with resClasses^[��] do
    GetDlgItemText(����,���������������,claMenu,maxSClass);
    GetDlgItemText(����,��������������,claName,maxSClass);
    GetDlgItemText(����,����������,claStyle,maxSClass);
    GetDlgItemText(����,�������������,claIniText,maxSClass);
    claIniDX:=GetDlgItemInt(����,��������X,nil,true);
    claIniDY:=GetDlgItemInt(����,��������Y,nil,true);
    for ���:=1 to claTop do
      memFree(claList[���]);
    end;
    claTop:=SendDlgItemMessage(����,�������������,LB_GETCOUNT,0,0);
    for ���:=1 to claTop do
      SendDlgItemMessage(����,�������������,LB_GETTEXT,���-1,integer(addr(s)));
      claList[���]:=memAlloc(lstrlen(s)+1);
      lstrcpy(claList[���],s);
    end;
  end end;
end ������������;

//--------------------- �������� ��������� ������ ----------------------------

procedure ������������(����:HWND; ��:integer);
var ���:integer;
begin
  if (��>0)and(��<=resTopClass) then
  with resClasses^[��] do
    SetDlgItemText(����,���������������,claMenu);
    SetDlgItemText(����,��������������,claName);
    SetDlgItemText(����,����������,claStyle);
    SetDlgItemText(����,�������������,claIniText);
    SetDlgItemInt(����,��������X,claIniDX,true);
    SetDlgItemInt(����,��������Y,claIniDY,true);
    SendDlgItemMessage(����,�������������,LB_RESETCONTENT,0,0);
    for ���:=1 to claTop do
      SendDlgItemMessage(����,�������������,LB_ADDSTRING,0,integer(claList[���]));
    end;
    SendDlgItemMessage(����,�������������,LB_SETCURSEL,0,0);
    SendMessage(����,WM_COMMAND,LBN_SELCHANGE*0x10000+�������������,0);
  end end;
end ������������;

//--------------------- ���������� ������� �������� ----------------------------

procedure ������������(����:HWND; ����,������,������:integer):boolean;
var ��,����,���:integer; s,s2:string[maxText];
begin
  case ���� of
    WM_INITDIALOG: //�������������
      SetDlgItemText(����,�����Win32,resWIN32);
      for ��:=1 to resTopClass do
        SendDlgItemMessage(����,�����������,LB_ADDSTRING,0,integer(addr(resClasses^[��].claMenu)));
      end;
      resCarClass:=1;
      SendDlgItemMessage(����,�����������,LB_SETCURSEL,0,0);
      ������������(����,resCarClass);
      SetFocus(GetDlgItem(����,�����������));|
    WM_COMMAND:case loword(������) of
      �����������:if hiword(������)=LBN_SELCHANGE then //����� ������
        ��:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0)+1;
        ������������(����,resCarClass);
        resCarClass:=��;
        ������������(����,resCarClass);
      end;|
      �������������:if hiword(������)=LBN_SELCHANGE then //����� ��������
        ���:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0);
        if ���>=0 then
          SendDlgItemMessage(����,�������������,LB_GETTEXT,���,integer(addr(s)));
          SetDlgItemText(����,������������,s);
        end
      end;|
      ���������������:if hiword(������)=EN_CHANGE then //����� �������� ������
        GetDlgItemText(����,���������������,s,maxText);
        ���:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0);
        SendDlgItemMessage(����,�����������,LB_GETTEXT,���,integer(addr(s2)));
        if (lstrcmp(s,s2)<>0)and(���>=0) then
          SendDlgItemMessage(����,�����������,LB_DELETESTRING,���,0);
          SendDlgItemMessage(����,�����������,LB_INSERTSTRING,���,integer(addr(s)));
          SendDlgItemMessage(����,�����������,LB_SETCURSEL,���,0);
        end;
      end;|
      ������������:if hiword(������)=EN_CHANGE then //����� ������ ��������
        GetDlgItemText(����,������������,s,maxText);
        ���:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0);
        SendDlgItemMessage(����,�������������,LB_GETTEXT,���,integer(addr(s2)));
        if (lstrcmp(s,s2)<>0)and(���>=0) then
          SendDlgItemMessage(����,�������������,LB_DELETESTRING,���,0);
          SendDlgItemMessage(����,�������������,LB_INSERTSTRING,���,integer(addr(s)));
          SendDlgItemMessage(����,�������������,LB_SETCURSEL,���,0);
        end;
      end;|
      �������������:if hiword(������)=BN_CLICKED then //�������� �����
      if resTopClass=maxClass then mbS(_�������_�����_�������[envER])
      else
        ������������(����,resCarClass);
        ��:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0)+2;
        if (��>0)and(��<=resTopClass+1) then
          for ���:=resTopClass+1 downto ��+1 do
            resClasses^[���]:=resClasses^[���-1];
          end;
          RtlZeroMemory(addr(resClasses^[��]),sizeof(recClass));
          inc(resTopClass);
          SendDlgItemMessage(����,�����������,LB_INSERTSTRING,��-1,integer(""));
          SendDlgItemMessage(����,�����������,LB_SETCURSEL,��-1,0);
          resCarClass:=��;
          ������������(����,resCarClass);
          SetFocus(GetDlgItem(����,���������������));
        end
      end end;|
      ������������:if hiword(������)=BN_CLICKED then //������� �����
      if resTopClass=0 then mbS(_���_�������_�_������[envER])
      else
        ������������(����,resCarClass);
        ��:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0)+1;
        if (��>0)and(��<=resTopClass) then
          for ���:=�� to resTopClass-1 do
            resClasses^[���]:=resClasses^[���+1];
          end;
          dec(resTopClass);
          SendDlgItemMessage(����,�����������,LB_DELETESTRING,��-1,0);
          SendDlgItemMessage(����,�����������,LB_SETCURSEL,��-1,0);
          if ��<=resTopClass
            then resCarClass:=��;
            else resCarClass:=��-1;
          end;
          ������������(����,resCarClass);
        end
      end end;|
      ���������������:if hiword(������)=BN_CLICKED then //�������� �������
      with resClasses^[resCarClass] do
        ����:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0)+2;
        if ����>0 then
          SendDlgItemMessage(����,�������������,LB_INSERTSTRING,����-1,integer(""));
          SendDlgItemMessage(����,�������������,LB_SETCURSEL,����-1,0);
          SetDlgItemText(����,������������,nil);
          SetFocus(GetDlgItem(����,������������));
        end
      end end;|
      ��������������:if hiword(������)=BN_CLICKED then //������� �������
      with resClasses^[resCarClass] do
        ����:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0)+1;
        if ����>0 then
          SendDlgItemMessage(����,�������������,LB_DELETESTRING,����-1,0);
          SetDlgItemText(����,������������,nil);
        end;
      end end;|
      ��������������:if boolean(MessageBox(0,
        _��������_���_��������_��_��������_��_���������__[envER],"�������� !",MB_YESNO)) then
        ���������������(resClasses,resTopClass);
        �������������();
        SendDlgItemMessage(����,�����������,LB_RESETCONTENT,0,0);
        SendMessage(����,WM_INITDIALOG,0,0);
      end;|
      IDOK,�������:
        ������������(����,resCarClass);
        GetDlgItemText(����,�����Win32,resWIN32,maxText);
        EndDialog(����,1);|
      IDCANCEL,�����������:EndDialog(����,0);|
    end;|
  else return false
  end;
  return true;
end ������������;

//--------- ��������� ������� -------------

procedure ������������();
var ���:HWND; resClassesOld:pClass; resTopClassOld:integer;
begin
  ���:=GetFocus();
  resClassesOld:=memAlloc(sizeof(arrClass));
  ������������(resClasses,resClassesOld,resTopClass,resTopClassOld);
  if boolean(DialogBoxParam(hINSTANCE,DLG_SETDLG[envER],GetFocus(),addr(������������),0)) then
    ������������();
    ���������������(resClassesOld,resTopClassOld);
  else
    ���������������(resClasses,resTopClass);
    ������������(resClassesOld,resClasses,resTopClassOld,resTopClass);
  end;
  memFree(resClassesOld);
  SetFocus(���);
end ������������;

//end SmRes.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ ENV (������� ��������������� �����)
//���� SMENV.M

//implementation module SmEnv;
//import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra,SmTraC,SmTraP,SmRes;

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

//end SmEnv.
///////////////////////////////////////////////////////////////////////////////

end SmImp.
