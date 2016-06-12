//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль SYS (вспомогательные функции)
//Файл SMSYS.D

definition module SmSys;
import Win32;

const  maxFonts=40;
type
  sysFonts=record
    top:integer;
    fnts:array[1..maxFonts]of pstr;
  end;
  pSysFonts=pointer to sysFonts;

//присоединение объектов
  procedure sysSelectObject(dc:HDC; h:HANDLE; var old:HANDLE);
  procedure sysDeleteObject(dc:HDC; h:HANDLE; old:HANDLE);

//строки
  procedure listFill(fillLen:integer; fillStr,fillBuf:pstr):pstr;
  procedure SetDlgItemReal(Dlg:HWND; idDlgItem:integer; Value:real; Pre:integer);
  procedure GetDlgItemReal(Dlg:HWND; idDlgItem:integer):real;

//стандартные диалоги
  procedure sysGetFileName(bitOpen:boolean; getMas:pstr; getPath,getTitle:pstr):boolean;
  procedure sysChooseFont(chFace:pstr; var chStyle,chSize:integer):boolean;
  procedure sysGetFamilies(DC:HDC; res:pSysFonts);
  procedure sysChooseColor(wnd:HWND; col:cardinal):cardinal;
  procedure sysPrintDlg(var prnCopies:integer):HDC;

//рисование
  procedure sysDrawBitmap(drawDC:HDC; x,y:integer; drawBitmap:HBITMAP);

//преобразования типов
  procedure sysAnsiToUnicode(c:char):word;
  procedure sysRealToReal32(r:real):cardinal;

end SmSys.

