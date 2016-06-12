//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль SYS (вспомогательные функции)
//Файл SMSYS.M

implementation module SmSys;
import Win32,Win32Ext;

//===============================================
//            ПРИСОЕДИНЕНИЕ ОБЪЕКТОВ
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
//                     СТРОКИ
//===============================================

  procedure listFill(fillLen:integer; fillStr,fillBuf:pstr):pstr;
// отрицательное fillLen выравнивает вправо
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
//           СТАНДАРТНЫЕ ДИАЛОГИ
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
var chBuf:CHOOSEFONT; chFont:LOGFONT; рез:boolean;
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
    рез:=false;
    if ChooseFont(chBuf) then
      рез:=true;
      lstrcpy(chFace,addr(chFont.lfFaceName));
      chStyle:=nFontType;
      if chSize<>0 then
        chSize:=iPointSize
      end
    end;
    return рез
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
//                   РИСОВАНИЕ
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
//           ПРЕОБРАЗОВАНИЯ ТИПОВ
//===============================================


//преобразования типов
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

end SmSys.

