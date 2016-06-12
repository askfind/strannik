//СТРАННИК Модула-Си-Паскаль для Win32
// Утилиты Win32 Extention
// Файл Win32ext.pas

unit Win32ext;
uses Win32;

//===============================================================
//                                  работа со строками символов
//===============================================================

  procedure lstrcatc(str:pstr; sym:char);
  begin
    str[lstrlen(str)+1]:='\0';
    str[lstrlen(str)]:=sym;
  end;

  function lstrposc(sym:char; str:pstr):integer;
  var i:integer;
  begin
    if str=nil then return -1;
    i:=0;
    while (str[i]<>'\0')and(str[i]<>sym) do
      i:=i+1;
    if str[i]=sym
      then return i
      else return -1
  end;

  function lstrpos(sub,str:pstr):integer;
  var p:integer;
  begin
    asm
 PUSH ESI; PUSH EDI; //нельзя портить DI ! Почему-неизвестно. При определенных условиях мешает вызову WinExec
//инициализация поиска
     MOV ESI,[EBP+offs(sub)]; MOV AL,[ESI];
     MOV EDI,[EBP+offs(str)];
//поиск первой буквы от DI (буква в AL)
RepC:CMP b [EDI],0; JE Fail; // не найдена
     CMP AL,[EDI]; JE EndC; //найдена
     INC EDI;
     JMP RepC;
EndC:
//сравнение последующих букв
     PUSH ESI; PUSH EDI;
RepE:MOV BL,[ESI]; CMP BL,0; JE Succ; //достигнут конец подстроки (успех)
     CMP BL,[EDI]; JNE EndE; //найдено несоответствие строки и подстроки
     INC ESI; INC EDI;
     JMP RepE;
//следующий поиск первой совпадающей буквы
EndE:POP EDI; POP ESI;
     INC EDI;
     JMP RepC;
//успех
Succ:POP EDI; POP ESI;
     MOV EBX,offs(str); ADD EBX,EBP;
     SUB EDI,[EBX];
     MOV EBX,offs(p); ADD EBX,EBP; MOV [EBX],EDI;
     JMP EndP;
//неудача
Fail:MOV EBX,offs(p); ADD EBX,EBP; MOV d [EBX],0xFFFFFFFF;
EndP:
     POP EDI; POP ESI;
    end;
    return p;
  end;

  function lstrposi(sub,str:pstr; i:integer):integer;
  var p:integer;
  begin
    if lstrlen(str)-1<i then return(-1)
    else begin
      p:=lstrpos(sub,addr(str[i]));
      if p=-1
        then return p
        else return p+i
    end
  end;

  procedure lstrdel(str:pstr; pos,len:integer);
  var i,l:integer;
  begin
    if pos<0 then begin
      len:=len+pos;
      pos:=0;
    end;
    if len>=0 then begin
      l:=lstrlen(str);
      if pos+len>l then
        if pos<l then str[pos]:='\0' else
      else
        for i:=1 to l-(pos+len)+1 do
          str[pos+i-1]:=str[pos+i+len-1];
    end
  end;

  procedure lstrinsc(sym:char; str:pstr; pos:integer);
  var i:integer;
  begin
    for i:=lstrlen(str)+1 downto pos+1 do
      str[i]:=str[i-1];
    str[pos]:=sym
  end;

  procedure lstrins(ins,str:pstr; pos:integer);
  var i:integer;
  begin
     for i:=lstrlen(ins)-1 downto 0 do
       lstrinsc(ins[i],str,pos);
  end;

//===============================================================
//                                  преобразования типов (real)
//===============================================================

  function wvscani(s:pstr):integer;
  var i,r,expo:integer; bitMin,bitHex:boolean;
  begin
    r:=0;
    i:=0;
    while s[i]=' ' do inc(i);
    bitMin:=(s[i]='-');
    if bitMin then inc(i);
    bitHex:=(s[i]='0')and((s[i+1]='x')or(s[i+1]='X'));
    if bitHex then inc(i,2);
    if bitHex
      then expo:=16
      else expo:=10;
    if i<lstrlen(s) then begin
      while
         (byte(s[i])>=byte('0'))and(byte(s[i])<=byte('9'))or
         bitHex and(byte(s[i])>=byte('A'))and(byte(s[i])<=byte('F'))or
         bitHex and(byte(s[i])>=byte('a'))and(byte(s[i])<=byte('f')) do begin
        case s[i] of
          '0'..'9':r:=r*expo+(integer(s[i])-integer('0'));
          'A','a':r:=r*expo+10;
          'B','b':r:=r*expo+11;
          'C','c':r:=r*expo+12;
          'D','d':r:=r*expo+13;
          'E','e':r:=r*expo+14;
          'F','f':r:=r*expo+15;
        end;
        inc(i);
      end;
      if s[i]='\0' 
        then return r
        else return iERROR;
    end
  end;

  function wvscanr(s:pstr):real;
  var i,j,e:integer; r,expo:real; bit,bitE,bitN:boolean;
  begin
    bitN:=false;
    r:=0.0;
    i:=0;
    while s[i]=' ' do i:=i+1;
    bit:=(s[i]='-');
    if bit then i:=i+1;
    while (byte(s[i])>=byte('0'))and(byte(s[i])<=byte('9')) do begin
      r:=r*10.0+real(integer(s[i])-integer('0'));
      i:=i+1;
      bitN:=true;
    end;
    if s[i]='.' then begin
      i:=i+1;
      expo:=1.0/10.0;
      while (byte(s[i])>=byte('0'))and(byte(s[i])<=byte('9')) do begin
        r:=r+real(integer(s[i])-integer('0'))*expo;
        expo:=expo/10.0;
        i:=i+1;
        bitN:=true;
      end;
    end;
//степень
    if (s[i]='e')or(s[i]='E') then begin
      inc(i);
      e:=0;
      bitE:=(s[i]='-');
      if bitE or(s[i]='+') then inc(i);
      if (ord(s[i])>=ord('0'))and(ord(s[i])<=ord('9')) then begin
        e:=e*10+ord(s[i])-ord('0');
        inc(i);
        bitN:=true;
        if (ord(s[i])>=ord('0'))and(ord(s[i])<=ord('9')) then begin
          e:=e*10+ord(s[i])-ord('0');
          inc(i);
          if (ord(s[i])>=ord('0'))and(ord(s[i])<=ord('9')) then begin
            e:=e*10+ord(s[i])-ord('0');
            inc(i);
          end;
        end;
      end;
      for j:=1 to e do
        if bitE
          then r:=r/10.0
          else r:=r*10.0;
    end;
    while s[i]=' ' do i:=i+1;
    if bit then r:=-r;
    if (s[i]='\0')and bitN
      then return(r)
      else return(rERROR);
  end;

  procedure wvsprintr(r:real; dest:integer; s:pstr);
  var  b:array[0..9]of byte; r10:real; i,j,k:integer;
  begin
  //проверка на НЕ ЧИСЛО
    RtlMoveMemory(addr(b),addr(r),8);
    if ((b[7] and 0x7F)=0x7F)and((b[6] and 0xF0)=0xF0) then
      r:=0.0;
  //число в двоично-десятичный буфер
    r10:=10.0;
    asm
   WAIT; FLD [EBP+offs(r)];//загрузка числа в ST0
   MOV ECX,[EBP+offs(dest)];//цикл по точности
   JCXZ Пропуск;//проверка на dest=0
Цикл:
   WAIT; FMUL [EBP+offs(r10)];//ST0*10
   LOOP Цикл;
Пропуск:
   WAIT; FBSTP [EBP+offs(b)];
    end;
//знак числа
    if b[9]=0 
      then s[0]:=' '
      else s[0]:='-';
//значащие цифры
    k:=0;
    for i:=8 downto 0 do begin
      for j:=2 downto 1 do begin
//десятичная точка
        if (i*2+j)=dest then begin
          if k=0 then begin
            k:=k+1;
            s[k]:='0';
          end;
          k:=k+1;
          s[k]:='.';
        end;
//цифра
        k:=k+1;
        if j=1
          then s[k]:=char(b[i] mod 16 + integer('0'))
          else s[k]:=char(b[i] div 16 + integer('0'));
//убрать префикс 0
        if (k=1)and(s[k]='0')and((i*2+j)<>1) then
          k:=0;
      end
    end;
    s[k+1]:=char(0)
  end;

  procedure wvsprinte(r:real; s:pstr);
  var  b:array[0..9]of byte; i,j,k,e:integer; num:string[30];
  begin
//степень
    e:=0;
    if abs(r)>=1.0 then begin
      while (r<>0.0)and(abs(r)>=1.0) do begin
        inc(e);
        r:=r/10.0;
      end;
      wvsprintf(num,"e+%02li",addr(e))
    end
    else begin
      while (r<>0.0)and(abs(r)<0.1) do begin
        inc(e);
        r:=r*10.0;
      end;
      wvsprintf(num,"e-%02li",addr(e))
    end;
  //проверка на НЕ ЧИСЛО
    RtlMoveMemory(addr(b),addr(r),8);
    if ((b[7] and 0x7F)=0x7F)and((b[6] and 0xF0)=0xF0) then
      r:=rERROR;
  //число в двоично-десятичный буфер
    r:=r*1e18;
    asm
   WAIT; FLD [EBP+offs(r)]; //загрузка числа в ST0
   WAIT; FBSTP [EBP+offs(b)]; //выгрузка в двоично-десятичном формате
    end;
//знак числа
    if b[9]=0 
      then lstrcpy(s,' 0.')
      else lstrcpy(s,'-0.');
//значащие цифры
    k:=2;
    for i:=8 downto 1 do
      for j:=2 downto 1 do begin
        inc(k);
        if j=1
          then s[k]:=char(b[i] mod 16 + ord('0'))
          else s[k]:=char(b[i] div 16 + ord('0'));
    end;
    s[k+1]:=char(0);
    lstrcat(s,num)
  end;

//===============================================================
//                                 выделение и освобождение памяти
//===============================================================

  function memAlloc(len:dword):address;
  var h:HANDLE;
  begin
      h:=GlobalAlloc(GMEM_FIXED,len);
      return GlobalLock(h);
  end;

  procedure memFree(p:address);
  var h:HANDLE;
  begin
    h:=GlobalHandle(p);
    GlobalFree(h);
  end;

//===============================================================
//                                 работа с файлами
//===============================================================

  function _lsize(file:integer):dword;
  var car,siz:dword;
  begin
    car:=_llseek(file,0,1);
    siz:=_llseek(file,0,2);
    _llseek(file,car,0);
    return siz;
  end;

  function _fileok(path:pstr):boolean;
  var f:WIN32_FIND_DATA; res:HANDLE;
  begin
    res:=FindFirstFile(path,f);
    if res=INVALID_HANDLE_VALUE then _fileok:=false
    else begin
      FindClose(res);
      _fileok:=true
    end
  end;

  function _lreads(hFile:integer; s:pstr; max:dword):boolean;
  var readRez,readLen:integer;
  begin
    readRez:=_lread(hFile,s,max);
    s[readRez]:=char(0);
    readLen:=lstrposc(char(13),s);
    if readLen<>-1 then begin
      s[readLen]:=char(0);
      _llseek(hFile,0-readRez+readLen+2,1)
    end;
    return _llseek(hFile,0,1)=_lsize(hFile)
  end;

//===============================================================
//                                 сообщения MessageBox
//===============================================================

  procedure mbS(str:pstr);
  begin
    MessageBox(0,str,"ВНИМАНИЕ:",0);
  end;

  procedure mbI(i:integer; title:pstr);
  var str:string[50];
  begin
    wvsprintf(str,"%li",addr(i));
    MessageBox(0,str,title,0);
  end;

  procedure mbX(x:dword; title:pstr);
  var str:string[50];
  begin
    wvsprintf(str,"%#lX",addr(x));
    MessageBox(0,str,title,0);
  end;

  procedure mbR(r:real; title:pstr; dest:integer);
  var str:string[50];
  begin
    wvsprintr(r,dest,str);
    MessageBox(0,str,title,0);
  end;

//===============================================================
//                                 арифметика с плавающей точкой
//===============================================================

  function ln(r:real):real;
  var res:real;
  begin
    asm
   WAIT; FLDLN2; //загрузка ln2
   WAIT; FLD [EBP+offs(r)]; //загрузка числа в ST0
   WAIT; FYL2X;
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     end;
     return res
  end;

  function exp(r:real):real;
  var res:real;
  begin
    asm
   WAIT; FLDL2E; //загрузка log2(e)
   WAIT; FMUL [EBP+offs(r)]; //число*log2(e)
   WAIT; F2XM1;
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
   WAIT; FLD1;
   WAIT; FADD [EBP+offs(res)]; //результат+1
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     end;
     return res
  end;

  function sqrt(r:real):real;
  var res:real;
  begin
    asm
   WAIT; FLD [EBP+offs(r)]; //загрузка числа в ST0
   WAIT; FSQRT;
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     end;
     return res
  end;

  function sin(r:real):real;
  var res,res2,y_x:real;
  begin
    res2:=2.0;
    res:=4.0;
    asm
   WAIT; FLD [EBP+offs(r)]; //загрузка операнда
   WAIT; FDIV [EBP+offs(res2)]; //операнд/2
   WAIT; FPTAN; //tg(ST0)
   WAIT; FSTP [EBP+offs(res)]; //выгрузка x в res
   WAIT; FDIV [EBP+offs(res)]; //y/x
   WAIT; FSTP [EBP+offs(y_x)]; //выгрузка y/x в y_x
   WAIT; FLD [EBP+offs(y_x)]; //y/x**2
   WAIT; FMUL [EBP+offs(y_x)];
   WAIT; FSTP [EBP+offs(res)];
   WAIT; FLD1; //1+y/x**2
   WAIT; FADD [EBP+offs(res)];
   WAIT; FSTP [EBP+offs(res)];
   WAIT; FLD [EBP+offs(y_x)]; //2*y/x
   WAIT; FMUL [EBP+offs(res2)];
   WAIT; FDIV [EBP+offs(res)]; //2*y/x / 1+y/x**2
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     end;
     return res
  end;

  function cos(r:real):real;
  var res,res2,y_x:real;
  begin
    res2:=2.0;
    res:=4.0;
    asm
   WAIT; FLD [EBP+offs(r)]; //загрузка операнда
   WAIT; FDIV [EBP+offs(res2)]; //операнд/2
   WAIT; FPTAN; //tg(ST0)
   WAIT; FSTP [EBP+offs(res)]; //выгрузка x в res
   WAIT; FDIV [EBP+offs(res)]; //y/x
   WAIT; FSTP [EBP+offs(y_x)]; //выгрузка y/x в y_x
   WAIT; FLD [EBP+offs(y_x)]; //y/x**2
   WAIT; FMUL [EBP+offs(y_x)];
   WAIT; FSTP [EBP+offs(y_x)];
   WAIT; FLD1; //1+y/x**2
   WAIT; FADD [EBP+offs(y_x)];
   WAIT; FSTP [EBP+offs(res)];
   WAIT; FLD1; //1-y/x**2
   WAIT; FSUB [EBP+offs(y_x)];
   WAIT; FDIV [EBP+offs(res)]; //1-y/x**2 / 1+y/x**2
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     end;
     return res
  end;

  function tg(r:real):real;
  var res:real;
  begin
    asm
   WAIT; FLD [EBP+offs(r)]; //загрузка операнда
   WAIT; FPTAN; //tg(ST0)
   WAIT; FSTP [EBP+offs(res)]; //выгрузка x в res
   WAIT; FDIV [EBP+offs(res)]; //y/x
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     end;
     return res
  end;

  function arctg(r:real):real;
  var res:real;
  begin
    asm
   WAIT; FLD [EBP+offs(r)]; //загрузка операнда
   WAIT; FLD1; //загрузка 1
   WAIT; FPATAN; //arctg(ST0)
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     end;
     return res
  end;

  function abs(r:real):real;
  begin
    if r<0.0
      then abs:=-r
      else abs:=r
  end;

//===============================================================
//                                 работа с dbf-файлами
//===============================================================

//создание нового DBF-файла
  procedure dbfNewTitle(dbfStruct:pDBF; dbfFile:integer); //создание нового DBF-файла
  var carField,carTrack:integer; buffer:byte;
  begin
    with dbfStruct^,dbfTitle do begin
//заполнение малого заголовка
      dbfDescription:=0x03;
      dbfYear:=0x64;
      dbfMouns:=0x03;
      dbfDay:=0x04;
      dbfNumRecords:=0;
      RtlZeroMemory(addr(dbfReserved),20);
//заполнение описаний полей
      carTrack:=1;
      for carField:=1 to dbfTopField do
      with dbfFields[carField] do begin
        dbfFieldTrack:=carTrack;
        inc(carTrack,integer(dbfFieldLength));
        RtlZeroMemory(addr(dbfFieldReserved),14);
      end;
      dbfRecordLenght:=carTrack;
      dbfHeaderLenght:=sizeof(recDbfTitle)+sizeof(recDbfField)*dbfTopField+1;
//запись заголовка
      _llseek(dbfFile,0,0);
      _lwrite(dbfFile,addr(dbfTitle),sizeof(recDbfTitle));
      for carField:=1 to dbfTopField do begin
        _lwrite(dbfFile,addr(dbfFields[carField]),sizeof(recDbfField));
      end;
      buffer:=0x0D;
      _lwrite(dbfFile,addr(buffer),1);
      buffer:=0x1A;
      _lwrite(dbfFile,addr(buffer),1);
    end
  end;

//чтение заголовка DBF-файла
  function dbfGetTitle(dbfStruct:pDBF; dbfFile:integer):boolean; //чтение заголовка DBF-файла
  var res,track:integer;
  begin
    with dbfStruct^,dbfTitle do begin
      _llseek(dbfFile,0,0);
      _lread(dbfFile,addr(dbfTitle),sizeof(recDbfTitle));
      dbfTopField:=0;
      track:=1;
      res:=_lread(dbfFile,addr(dbfFields[dbfTopField+1]),sizeof(recDbfField));
      while
        (res=sizeof(recDbfField))and
        (dbfTopField<maxDbfField)and
        (dbfFields[dbfTopField+1].dbfFieldName[0]<>char(0x0D)) do begin
        inc(dbfTopField);
        with dbfFields[dbfTopField] do begin
          dbfFieldTrack:=track;
          inc(track,dbfFieldLength)
        end;
        res:=_lread(dbfFile,addr(dbfFields[dbfTopField+1]),sizeof(recDbfField));
      end;
      dbfGetTitle:=dbfFields[dbfTopField+1].dbfFieldName[0]=char(0x0D)
    end
  end;

//количество кортежей в DBF-файле
  function dbfGetSize(dbfStruct:pDBF; dbfFile:integer):dword; //количество кортежей в DBF-файле
  begin
    with dbfStruct^,dbfTitle do begin
      dbfGetSize:=(_lsize(dbfFile)-dbfHeaderLenght-1) div dbfRecordLenght
    end
  end;

//инициализация кортежа
  function dbfNewRecord(dbfStruct:pDBF):pstr; //инициализация кортежа
  var dbfRecord:pstr;
  begin
    with dbfStruct^,dbfTitle do begin
      dbfRecord:=memAlloc(dbfRecordLenght);
      RtlFillMemory(dbfRecord,dbfRecordLenght,byte(' '));
      dbfNewRecord:=dbfRecord;
    end
  end;

//чтение кортежа
  procedure dbfReadRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //чтение кортежа
  begin
    with dbfStruct^,dbfTitle do begin
      _llseek(dbfFile,dword(dbfHeaderLenght)+dbfPos*dbfRecordLenght,0);
      _lread(dbfFile,dbfRecord,dbfRecordLenght);
    end
  end;

//запись кортежа
  procedure dbfWriteRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //запись кортежа
  var buffer:byte;
  begin
    with dbfStruct^,dbfTitle do begin
      if dbfPos<dbfNumRecords then begin
        _llseek(dbfFile,dword(dbfHeaderLenght)+dbfPos*dbfRecordLenght,0);
        _lwrite(dbfFile,dbfRecord,dbfRecordLenght);
      end
      else begin
        _llseek(dbfFile,dword(dbfHeaderLenght)+dbfPos*dbfRecordLenght,0);
        _lwrite(dbfFile,dbfRecord,dbfRecordLenght);
        buffer:=0x1A;
        _lwrite(dbfFile,addr(buffer),1);
        inc(dbfNumRecords);
        _llseek(dbfFile,0,0);
        _lwrite(dbfFile,addr(dbfTitle),sizeof(recDbfTitle));
      end
    end
  end;

//вставка кортежа
  procedure dbfInsertRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; dbfRecord:pstr); //вставка кортежа
  var car:integer; rec:pstr;
  begin
    with dbfStruct^,dbfTitle do begin
      rec:=dbfNewRecord(dbfStruct);
      for car:=dbfGetSize(dbfStruct,dbfFile) downto dbfPos+1 do begin
        dbfReadRecord(dbfStruct,dbfFile,car-1,rec);
        dbfWriteRecord(dbfStruct,dbfFile,car,rec);
      end;
      dbfWriteRecord(dbfStruct,dbfFile,dbfPos,dbfRecord);
      memFree(rec)
    end
  end;

//удаление/восстановление кортежа
  procedure dbfDeleteRecord(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer; bitUnDelete:boolean); //удаление/восстановление кортежа
  var rec:pstr;
  begin
    with dbfStruct^,dbfTitle do begin
      rec:=dbfNewRecord(dbfStruct);
      dbfReadRecord(dbfStruct,dbfFile,dbfPos,rec);
      if bitUnDelete
        then rec[0]:=' '
        else rec[0]:='*';
      dbfWriteRecord(dbfStruct,dbfFile,dbfPos,rec);
      memFree(rec)
    end
  end;

//проверка пометки удаления кортежа
  function dbfIsDeleted(dbfStruct:pDBF; dbfFile:integer; dbfPos:integer):boolean; //проверка пометки удаления кортежа
  var rec:pstr; c:char;
  begin
    with dbfStruct^,dbfTitle do begin
      rec:=dbfNewRecord(dbfStruct);
      dbfReadRecord(dbfStruct,dbfFile,dbfPos,rec);
      c:=rec[0];
      memFree(rec);
      dbfIsDeleted:=c='*';
    end
  end;

//очистка DBF-файла от удаленных записей
  procedure dbfClearFile(dbfStruct:pDBF; dbfFile:integer); //очистка DBF-файла от удаленных записей
  var car,dist:integer; rec:pstr; c:char;
  begin
    with dbfStruct^,dbfTitle do begin
      rec:=dbfNewRecord(dbfStruct);
      dist:=0;
      for car:=0 to dbfGetSize(dbfStruct,dbfFile)-1 do begin
        if dbfIsDeleted(dbfStruct,dbfFile,car) then inc(dist)
        elsif dist>0 then begin
          dbfReadRecord(dbfStruct,dbfFile,car,rec);
          dbfWriteRecord(dbfStruct,dbfFile,car-dist,rec);
        end
      end;
    //усечение файла
      _llseek(dbfFile,-dist*dbfRecordLenght,FILE_END);
      _lwrite(dbfFile,nil,0);
      c:=char(0x1A);
      _lwrite(dbfFile,addr(c),1);
      dec(dbfNumRecords,dist);
      _llseek(dbfFile,0,0);
      _lwrite(dbfFile,addr(dbfTitle),sizeof(recDbfTitle));
      memFree(rec)
    end
  end;

//извлечение поля из кортежа
  procedure dbfGetField(dbfStruct:pDBF; dbfRecord:pstr; dbfField:integer; dbfFieldValue:pstr); //извлечение поля из кортежа
  begin
    with dbfStruct^,dbfTitle,dbfFields[dbfField] do begin
      RtlMoveMemory(dbfFieldValue,addr(dbfRecord[dbfFieldTrack]),dbfFieldLength);
      dbfFieldValue[dbfFieldLength]:='\0';
    end
  end;

//запись поля в кортеж
  procedure dbfSetField(dbfStruct:pDBF; dbfRecord:pstr; dbfField:integer; dbfFieldValue:pstr); //запись поля в кортеж
  begin
    if dbfField>0 then
    with dbfStruct^,dbfTitle,dbfFields[dbfField] do begin
      RtlMoveMemory(addr(dbfRecord[dbfFieldTrack]),dbfFieldValue,dbfFieldLength);
    end
  end;

//поиск номера поля по имени
  function dbfFindField(dbfStruct:pDBF; dbfName:pstr):integer; //поиск номера поля по имени
  var carField:integer;
  begin
    with dbfStruct^ do begin
      for carField:=1 to dbfTopField do begin
        if lstrcmp(dbfFields[carField].dbfFieldName,dbfName)=0 then begin
          dbfFindField:=carField;
        end
      end;
      dbfFindField:=0;
    end
  end;

//===============================================================
//                                 создание диалога indirect
//===============================================================

// размещение символа, целого и строки

  procedure indCHAR(pDlg:pstr; var topDlg:integer; chrDlg:char);
  begin
    if topDlg=indMAXMEM then indERROR:=true
    else begin
      topDlg:=topDlg+1;
      pDlg[topDlg-1]:=chrDlg
    end
  end;

  procedure indWORD(pDlg:pstr; var topDlg:integer; wordDlg:dword);
  begin
    indCHAR(pDlg,topDlg,char(lobyte(wordDlg)));
    indCHAR(pDlg,topDlg,char(hibyte(wordDlg)));
  end;

  procedure indDWORD(pDlg:pstr; var topDlg:integer; dwordDlg:dword);
  begin
    indWORD(pDlg,topDlg,loword(dwordDlg));
    indWORD(pDlg,topDlg,hiword(dwordDlg));
  end;

  procedure indSTR(pDlg:pstr; var topDlg:integer; strDlg:pstr);
  var i:integer; buf:array[0..indMAXWSTR]of word;
  begin
    if strDlg=nil then indWORD(pDlg,topDlg,0)
    else begin
      MultiByteToWideChar(0,0,strDlg,lstrlen(strDlg)+1,addr(buf),indMAXWSTR);
      for i:=0 to lstrlen(strDlg) do
        indWORD(pDlg,topDlg,buf[i]);
    end
  end;

//размещение заголовка диалога
  procedure indCaption(pDlg:pstr; var topDlg:integer; style,x,y,cx,cy:integer; menu,cla,caption:pstr);
  begin
    indERROR:=false;
    indDWORD(pDlg,topDlg,style); //style
    indDWORD(pDlg,topDlg,0); //ext style
    indWORD(pDlg,topDlg,0); //Nitems
    indWORD(pDlg,topDlg,x * 4 div loword(GetDialogBaseUnits())); //x
    indWORD(pDlg,topDlg,y * 8 div hiword(GetDialogBaseUnits())); //y
    indWORD(pDlg,topDlg,cx * 4 div loword(GetDialogBaseUnits())); //cx
    indWORD(pDlg,topDlg,cy * 8 div hiword(GetDialogBaseUnits())); //cy
    indSTR(pDlg,topDlg,menu); //menu
    indSTR(pDlg,topDlg,cla); //class
    indSTR(pDlg,topDlg,caption); //caption
    if topDlg mod 4<>0 then
      indWORD(pDlg,topDlg,0);
  end;

//размещение элемента диалога
  function indItem(pDlg:pstr; var topDlg:integer; x,y,cx,cy,ID,style:integer; cla,txt:pstr):boolean;
  begin
    indDWORD(pDlg,topDlg,style); //style
    indDWORD(pDlg,topDlg,0); //ext style
    indWORD(pDlg,topDlg,x * 4 div loword(GetDialogBaseUnits())); //x
    indWORD(pDlg,topDlg,y * 8 div hiword(GetDialogBaseUnits())); //y
    indWORD(pDlg,topDlg,cx * 4 div loword(GetDialogBaseUnits())); //cx
    indWORD(pDlg,topDlg,cy * 8 div hiword(GetDialogBaseUnits())); //cy
    indWORD(pDlg,topDlg,ID); //ID
    indSTR(pDlg,topDlg,cla); //text
    indSTR(pDlg,topDlg,txt); //text
    indWORD(pDlg,topDlg,0);//create data !НЕ ВЫРАВНИВАТЬ НА DWORD!

    while topDlg mod 4<>0 do //выравнивание конца элемента на dword
      indCHAR(pDlg,topDlg,'\0');

    pDlg[8]:=char(byte(pDlg[8])+1); //NItems+1
    if pDlg[8]='\0' then 
      indERROR:=true 
  end;

end.

