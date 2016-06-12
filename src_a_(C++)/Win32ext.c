// СТРАННИК-Модула для Win32
// Утилиты Win32 Extention
// Файл Win32ext.c

include Win32

//===============================================================
//                                  работа со строками символов
//===============================================================

  void lstrcatc(char* str, char sym)
  {
    str[lstrlen(str)+1]='\0';
    str[lstrlen(str)]=sym;
  }

  int lstrposc(char sym, char* str)
{int i;
  
    if(str==NULL) return -1;
    i=0;
    while((str[i]!='\0')&&(str[i]!=sym))
      i++;
    if(str[i]==sym) return(i);
    else return(-1);
  }

  int lstrpos(char* sub,char* str)
{int p;
  
    asm {
 PUSH ESI; PUSH EDI; //нельзя портить DI ! Почему-неизвестно. При определенных условиях мешает вызову WinExec
//инициализация поиска
     MOV ESI,[EBP+offs(sub)]; MOV AL,[ESI];
     MOV EDI,[EBP+offs(str)];
//поиск первой буквы от DI (буква в AL)
RepC:CMP b [EDI],0; JE Fail; //не найдена
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
    }
    return(p);
  }

  int lstrposi(char* sub,char* str, int i)
{int p;
  
    if(lstrlen(str)-1<i) return(-1);
    else {
      p=lstrpos(sub,&(str[i]));
      if(p==-1) return(p);
      else return(p+i);
    }
  }

  void lstrdel(char* str, int pos,int len)
{int i,l;
  
    if(pos<0) {
      len=len+pos;
      pos=0;
    }
    if(len>=0) {
      l=lstrlen(str);
      if(pos+len>l)
        if(pos<l) str[pos]='\0'; else {}
      else
        for(i=1; i<=l-(pos+len)+1; i++)
          str[pos+i-1]=str[pos+i+len-1];
    }
  }

  void lstrinsc(char sym, char* str, int pos)
{int i;
  
    for(i=lstrlen(str)+1; i>=pos+1; i--)
      str[i]=str[i-1];
    str[pos]=sym;
  }

  void lstrins(char* ins,char* str, int pos)
{int i;
  
     for(i=lstrlen(ins)-1; i>=0; i--)
       lstrinsc(ins[i],str,pos);
  }

//===============================================================
//                                  преобразования типов (real)
//===============================================================

  int wvscani(char* s)
{int i,r,expo;
  bool bitMin,bitHex;
  
    r=0;
    i=0;
    while(s[i]==' ') i++;
    bitMin=(s[i]=='-');
    if(bitMin) i++;
    bitHex=(s[i]=='0')&&((s[i+1]=='x')||(s[i+1]=='X'));
    if(bitHex) i++2;
    if(bitHex) expo=16;
    else expo=10;
    if(i<lstrlen(s)) {
      while(
         (ord(s[i])>=ord('0'))&&(ord(s[i])<=ord('9'))||
         bitHex &&(ord(s[i])>=ord('A'))&&(ord(s[i])<=ord('F'))||
         bitHex &&(ord(s[i])>=ord('a'))&&(ord(s[i])<=ord('f'))) {
        switch(s[i]) {
          case '0'..'9':r=r*expo+(ord(s[i])-ord('0')); break;
          case 'A': case 'a':r=r*expo+10; break;
          case 'B': case 'b':r=r*expo+11; break;
          case 'C': case 'c':r=r*expo+12; break;
          case 'D': case 'd':r=r*expo+13; break;
          case 'E': case 'e':r=r*expo+14; break;
          case 'F': case 'f':r=r*expo+15; break;
        }
        i++;
      }
      if(s[i]=='\0') return r;
      else return iERROR;
    }
  }

  float wvscanr(char* s)
{int i,j,e; float r,expo; bool bit,bitE,bitN;
  
    bitN=false;
    r=0.0;
    i=0;
    while(s[i]==' ') i++;
    bit=(s[i]=='-');
    if(bit) i++;
    while((ord(s[i])>=ord('0'))&&(ord(s[i])<=ord('9'))) {
      r=r*10.0+(float)(ord(s[i])-ord('0'));
      i++;
      bitN=true;
    }
    if(s[i]=='.') {
      i++;
      expo=1.0/10.0;
      while((ord(s[i])>=ord('0'))and(ord(s[i])<=ord('9'))) {
        r=r+(float)(ord(s[i])-ord('0'))*expo;
        expo=expo/10.0;
        i++;
        bitN=true;
      }
    }
//степень
    if((s[i]=='e')|(s[i]=='E')) {
      i++;
      e=0;
      bitE=(s[i]=='-');
      if(bitE |(s[i]=='+')) i++;
      if((ord(s[i])>=ord('0'))&(ord(s[i])<=ord('9'))) {
        e=e*10+ord(s[i])-ord('0');
        i++;
        bitN=true;
        if((ord(s[i])>=ord('0'))&(ord(s[i])<=ord('9'))) {
          e=e*10+ord(s[i])-ord('0');
          i++;
          if((ord(s[i])>=ord('0'))&(ord(s[i])<=ord('9'))) {
            e=e*10+ord(s[i])-ord('0');
            i++;
          }
        }
      }
      for(j=1; j<=e; j++) {
        if(bitE) r=r/10.0;
        else r=r*10.0;
      }
    }
    while(s[i]==' ') i++;
    if(bit) r=-r;
    if((s[i]=='\0')&& bitN) return(r);
    else return(rERROR);
  }

  void wvsprintr(float r, int dest, char* s)
{byte b[10]; float r10; int i,j,k;
  
  //проверка на НЕ ЧИСЛО
    RtlMoveMemory(&b,&r,8);
    if(((b[7] & 0x7F)==0x7F)&&((b[6] & 0xF0)==0xF0))
      r=0.0;
  //число в двоично-десятичный буфер
    r10=10.0;
    asm {
   WAIT; FLD [EBP+offs(r)]; //загрузка числа в ST0
   MOV ECX,[EBP+offs(dest)]; //цикл по точности
   JCXZ Пропуск; //проверка на dest=0
Цикл:
   WAIT; FMUL [EBP+offs(r10)]; //ST0*10
   LOOP Цикл;
Пропуск:
   WAIT; FBSTP [EBP+offs(b)];
    }
//знак числа
    if(b[9]==0) s[0]=' ';
    else s[0]='-';
//значащие цифры
    k=0;
    for(i=8; i>=0; i--) {
      for(j=2; j>=1; j--) {
//десятичная точка
        if((i*2+j)==dest) {
          if(k==0) {
            k=k+1;
            s[k]='0';
          }
          k=k+1;
          s[k]='.';
        }
//цифра
        k=k+1;
        if(j==1) s[k]=(char)(b[i] % 16 + (int)'0');
        else s[k]=(char)(b[i] / 16 + (int)'0');
//убрать префикс 0
        if((k==1)&&(s[k]=='0')&&((i*2+j)!=1))
          k=0;
      }
    }
    s[k+1]=(char)0;
  }

  void wvsprinte(float r, char* s)
{byte b[10]; int i,j,k,e; char num[30];
  
//степень
    e=0;
    if(abs(r)>=1.0) {
      while((r!=0.0)&(abs(r)>=1.0)) {
        e++;
        r=r/10.0;
      }
      wvsprintf(num,"e+%02li",&e);
    }
    else {
      while((r!=0.0)&(abs(r)<0.1)) {
        e++;
        r=r*10.0;
      }
      wvsprintf(num,"e-%02li",&e);
    }
  //проверка на НЕ ЧИСЛО
    RtlMoveMemory(&b,&r,8);
    if(((b[7] & 0x7F)==0x7F)&((b[6] & 0xF0)==0xF0)) {
      r=rERROR;
    }
  //число в двоично-десятичный буфер
    r=r*1e18;
    asm {
   WAIT; FLD [EBP+offs(r)]; //загрузка числа в ST0
   WAIT; FBSTP [EBP+offs(b)]; //выгрузка в двоично-десятичном формате
    }
//знак числа
    if(b[9]==0) lstrcpy(s,' 0.');
    else lstrcpy(s,'-0.');
//значащие цифры
    k=2;
    for(i=8; i>=1; i--) {
      for(j=2; j>=1; j--) {
        k++;
        if(j==1) s[k]=(char)(b[i] % 16 + ord('0'));
        else s[k]=(char)(b[i] / 16 + ord('0'));
      }
    }
    s[k+1]=(char)0;
    lstrcat(s,num);
  }

//===============================================================
//                                 выделение и освобождение памяти
//===============================================================

  void* memAlloc(int len)
{HANDLE h;
  
    h=GlobalAlloc(0,len);
    return(GlobalLock(h));
  }

  void memFree(void* p)
{HANDLE h;
  
    h=GlobalHandle(p);
    GlobalFree(h);
  }

//===============================================================
//                                 работа с файлами
//===============================================================

  unsigned int _lsize(int file)
{unsigned int car,siz;
  
    car=_llseek(file,0,1);
    siz=_llseek(file,0,2);
    _llseek(file,car,0);
    return(siz);
  }

  bool _fileok(char* path)
{WIN32_FIND_DATA f; HANDLE res;
    res=FindFirstFile(path,f);
    if(res==INVALID_HANDLE_VALUE) return false;
    else {FindClose(res); return true;}
}

  bool _lreads(int hFile, char* s, unsigned int max)
{int readRez,readLen;

    readRez=_lread(hFile,s,max);
    s[readRez]='\0';
    readLen=lstrposc('\13',s);
    if(readLen!=-1) {
      s[readLen]='\0';
      _llseek(hFile,0-readRez+readLen+2,1);
    }
    return _llseek(hFile,0,1)==_lsize(hFile);
}

//===============================================================
//                                 сообщения MessageBox
//===============================================================

  void mbS(char* str)
  {
    MessageBox(0,str,"ВНИМАНИЕ:",0);
  }

  void mbI(int i, char* title)
{char str[50];
    wvsprintf(str,"%li",&i);
    MessageBox(0,str,title,0);
  }

  void mbX(int x, char* title)
{char str[50];
    wvsprintf(str,"%#lX",&x);
    MessageBox(0,str,title,0);
  }

  void mbR(float r, char* title, int dest)
{char str[50];
    wvsprintr(r,dest,str);
    MessageBox(0,str,title,0);
  }

//===============================================================
//                                 арифметика с плавающей точкой
//===============================================================

  float ln(float r)
{float res;
  
    asm {
   WAIT; FLDLN2; //загрузка ln2
   WAIT; FLD [EBP+offs(r)]; //загрузка числа в ST0
   WAIT; FYL2X;
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     }
     return res;
  }

  float exp(float r)
{float res;
  
    asm {
   WAIT; FLDL2E; //загрузка log2(e)
   WAIT; FMUL [EBP+offs(r)]; //число*log2(e)
   WAIT; F2XM1;
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
   WAIT; FLD1;
   WAIT; FADD [EBP+offs(res)]; //результат+1
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     }
     return res;
  }

  float sqrt(float r)
{float res;
  
    asm {
   WAIT; FLD [EBP+offs(r)]; //загрузка числа в ST0
   WAIT; FSQRT;
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     }
     return res;
  }

  float sin(float r)
{float res,res2,y_x;
  
    res2=2.0;
    res=4.0;
    asm {
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
     }
     return res;
  }

  float cos(float r)
{float res,res2,y_x;
  
    res2=2.0;
    res=4.0;
    asm {
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
     }
     return res;
  }

  float tg(float r)
{float res;
  
    asm {
   WAIT; FLD [EBP+offs(r)]; //загрузка операнда
   WAIT; FPTAN; //tg(ST0)
   WAIT; FSTP [EBP+offs(res)]; //выгрузка x в res
   WAIT; FDIV [EBP+offs(res)]; //y/x
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     }
     return res;
  }

  float arctg(float r)
{float res;
  
    asm {
   WAIT; FLD [EBP+offs(r)]; //загрузка операнда
   WAIT; FLD1; //загрузка 1
   WAIT; FPATAN; //arctg(ST0)
   WAIT; FSTP [EBP+offs(res)]; //выгрузка результата в res
     }
     return res;
  }

  float abs(float r)
  {
    if(r<0.0) return -r;
    else return r;
  }

//===============================================================
//                                 работа с dbf-файлами
//===============================================================

//создание нового DBF-файла
  void dbfNewTitle(pDBF dbfStruct, int dbfFile) //создание нового DBF-файла
{int carField,carTrack;
  byte buffer;
  
    with(dbfStruct^,dbfTitle) {
//заполнение малого заголовка
      dbfDescription=0x03;
      dbfYear=0x64;
      dbfMouns=0x03;
      dbfDay=0x04;
      dbfNumRecords=0;
      RtlZeroMemory(&dbfReserved,20);
//заполнение описаний полей
      carTrack=1;
      for(carField=1; carField<=dbfTopField; carField++) {
      with(dbfFields[carField]) {
        dbfFieldTrack=carTrack;
        carTrack++dbfFieldLength;
        RtlZeroMemory(&dbfFieldReserved,14);
      }}
      dbfRecordLenght=carTrack;
      dbfHeaderLenght=sizeof(recDbfTitle)+sizeof(recDbfField)*dbfTopField+1;
//запись заголовка
      _llseek(dbfFile,0,0);
      _lwrite(dbfFile,&dbfTitle,sizeof(recDbfTitle));
      for(carField=1; carField<=dbfTopField; carField++) {
        _lwrite(dbfFile,&(dbfFields[carField]),sizeof(recDbfField));
      }
      buffer=0x0D;
      _lwrite(dbfFile,&buffer,1);
      buffer=0x1A;
      _lwrite(dbfFile,&buffer,1);
    }
  }

//чтение заголовка DBF-файла
  bool dbfGetTitle(pDBF dbfStruct, int dbfFile) //чтение заголовка DBF-файла
{int res,track;
  
    with(dbfStruct^,dbfTitle) {
      _llseek(dbfFile,0,0);
      _lread(dbfFile,&dbfTitle,sizeof(recDbfTitle));
      dbfTopField=0;
      track=1;
      res=_lread(dbfFile,&(dbfFields[dbfTopField+1]),sizeof(recDbfField));
      while(
        (res==sizeof(recDbfField))&
        (dbfTopField<maxDbfField)&
        (dbfFields[dbfTopField+1].dbfFieldName[0]!=(char)(0x0D))) {
        dbfTopField++;
        with(dbfFields[dbfTopField]) {
          dbfFieldTrack=track;
          track++dbfFieldLength;
        }
        res=_lread(dbfFile,&(dbfFields[dbfTopField+1]),sizeof(recDbfField));
      }
      return dbfFields[dbfTopField+1].dbfFieldName[0]==(char)(0x0D);
    }
  }

//количество кортежей в DBF-файле
  uint dbfGetSize(pDBF dbfStruct, int dbfFile) //количество кортежей в DBF-файле
  {
    with(dbfStruct^,dbfTitle) {
      return (_lsize(dbfFile)-dbfHeaderLenght-1) / dbfRecordLenght;
    }
  }

//инициализация кортежа
  pchar dbfNewRecord(pDBF dbfStruct) //инициализация кортежа
{char* dbfRecord;
  
    with(dbfStruct^,dbfTitle) {
      dbfRecord=memAlloc(dbfRecordLenght);
      RtlFillMemory(dbfRecord,dbfRecordLenght,(byte)(' '));
      return dbfRecord;
    }
  }

//чтение кортежа
  void dbfReadRecord(pDBF dbfStruct, int dbfFile,int dbfPos, pchar dbfRecord) //чтение кортежа
  {
    with(dbfStruct^,dbfTitle) {
      _llseek(dbfFile,(uint)(dbfHeaderLenght)+dbfPos*dbfRecordLenght,0);
      _lread(dbfFile,dbfRecord,dbfRecordLenght);
    }
  }

//запись кортежа
  void dbfWriteRecord(pDBF dbfStruct, int dbfFile,int dbfPos, pchar dbfRecord) //запись кортежа
{byte buffer;
  
    with(dbfStruct^,dbfTitle) {
      if(dbfPos<dbfNumRecords) {
        _llseek(dbfFile,(uint)(dbfHeaderLenght)+dbfPos*dbfRecordLenght,0);
        _lwrite(dbfFile,dbfRecord,dbfRecordLenght);
      } else {
        _llseek(dbfFile,(uint)(dbfHeaderLenght)+dbfPos*dbfRecordLenght,0);
        _lwrite(dbfFile,dbfRecord,dbfRecordLenght);
        buffer=0x1A;
        _lwrite(dbfFile,&buffer,1);
        dbfNumRecords++;
        _llseek(dbfFile,0,0);
        _lwrite(dbfFile,&dbfTitle,sizeof(recDbfTitle));
      }
    }
  }

//вставка кортежа
  void dbfInsertRecord(pDBF dbfStruct, int dbfFile,int dbfPos, pchar dbfRecord) //вставка кортежа
{int car; char* rec;
  
    with(dbfStruct^,dbfTitle) {
      rec=dbfNewRecord(dbfStruct);
      for(car=dbfGetSize(dbfStruct,dbfFile); car>=dbfPos+1; car--) {
        dbfReadRecord(dbfStruct,dbfFile,car-1,rec);
        dbfWriteRecord(dbfStruct,dbfFile,car,rec);
      }
      dbfWriteRecord(dbfStruct,dbfFile,dbfPos,dbfRecord);
      memFree(rec);
    }
  }

//удаление/восстановление кортежа
  void dbfDeleteRecord(pDBF dbfStruct, int dbfFile,int dbfPos, bool bitUnDelete) //удаление/восстановление кортежа
{char* rec;
  
    with(dbfStruct^,dbfTitle) {
      rec=dbfNewRecord(dbfStruct);
      dbfReadRecord(dbfStruct,dbfFile,dbfPos,rec);
      if(bitUnDelete) rec[0]=' ';
      else rec[0]='*';
      dbfWriteRecord(dbfStruct,dbfFile,dbfPos,rec);
      memFree(rec);
    }
  }

//проверка пометки удаления кортежа
  bool dbfIsDeleted(pDBF dbfStruct, int dbfFile,int dbfPos) //проверка пометки удаления кортежа
{char* rec; char c;
  
    with(dbfStruct^,dbfTitle) {
      rec=dbfNewRecord(dbfStruct);
      dbfReadRecord(dbfStruct,dbfFile,dbfPos,rec);
      c=rec[0];
      memFree(rec);
      return c=='*';
    }
  }

//очистка DBF-файла от удаленных записей
  void dbfClearFile(pDBF dbfStruct, int dbfFile) //очистка DBF-файла от удаленных записей
{int car,dist; char* rec; char c;
  
    with(dbfStruct^,dbfTitle) {
      rec=dbfNewRecord(dbfStruct);
      dist=0;
      for(car=0; car<=dbfGetSize(dbfStruct,dbfFile)-1; car++) {
        if(dbfIsDeleted(dbfStruct,dbfFile,car)) dist++;
        else if(dist>0) {
          dbfReadRecord(dbfStruct,dbfFile,car,rec);
          dbfWriteRecord(dbfStruct,dbfFile,car-dist,rec);
        }
      }
    //усечение файла
      _llseek(dbfFile,-dist*dbfRecordLenght,FILE_END);
      _lwrite(dbfFile,nil,0);
      c=char(0x1A);
      _lwrite(dbfFile,&c,1);
      dbfNumRecords--dist;
      _llseek(dbfFile,0,0);
      _lwrite(dbfFile,&dbfTitle,sizeof(recDbfTitle));
      memFree(rec);
    }
  }

//извлечение поля из кортежа
  void dbfGetField(pDBF dbfStruct, pchar dbfRecord, int dbfField, pchar dbfFieldValue) //извлечение поля из кортежа
  {
    with(dbfStruct^,dbfTitle,dbfFields[dbfField]) {
      RtlMoveMemory(dbfFieldValue,&(dbfRecord[dbfFieldTrack]),dbfFieldLength);
      dbfFieldValue[dbfFieldLength]='\0';
    }
  }

//запись поля в кортеж
  void dbfSetField(pDBF dbfStruct, pchar dbfRecord, int dbfField, pchar dbfFieldValue) //запись поля в кортеж
  {
    if(dbfField>0) {
    with(dbfStruct^,dbfTitle,dbfFields[dbfField]) {
      RtlMoveMemory(&(dbfRecord[dbfFieldTrack]),dbfFieldValue,dbfFieldLength);
    }}
  }

//поиск номера поля по имени
  int dbfFindField(pDBF dbfStruct, pchar dbfName) //поиск номера поля по имени
{int carField;
  
    with(dbfStruct^) {
      for(carField=1; carField<=dbfTopField; carField++) {
        if(lstrcmp(dbfFields[carField].dbfFieldName,dbfName)==0) {
          return carField;
        }
      }
      return 0;
    }
  }

//===============================================================
//                                 создание диалога indirect
//===============================================================

// размещение символа, целого и строки

  void indCHAR(char* pDlg, int &topDlg, char chrDlg)
  {
    if(topDlg==indMAXMEM) indERROR=true;
    else {
      topDlg++;
      pDlg[topDlg-1]=chrDlg;
    }
  }

  void indWORD(char* pDlg, int &topDlg, unsigned int wordDlg)
  {
    indCHAR(pDlg,topDlg,(char)(lobyte(wordDlg)));
    indCHAR(pDlg,topDlg,(char)(hibyte(wordDlg)));
  }

  void indDWORD(char* pDlg, int &topDlg, unsigned int dwordDlg)
  {
    indWORD(pDlg,topDlg,loword(dwordDlg));
    indWORD(pDlg,topDlg,hiword(dwordDlg));
  }

  void indSTR(char* pDlg, int &topDlg, char* strDlg) {
  int i;
  word buf[indMAXWSTR];
  
    if(strDlg==nil) indWORD(pDlg,topDlg,0);
    else {
      MultiByteToWideChar(0,0,strDlg,lstrlen(strDlg)+1,&buf,indMAXWSTR);
      for(i=0; i<=lstrlen(strDlg); i++)
        indWORD(pDlg,topDlg,buf[i]);
    }
  }

//размещение заголовка диалога

  void indCaption(char* pDlg, int &topDlg, int style,int x,int y,int cx,int cy, char* menu,char* cla,char* caption)
  {
    indERROR=false;
    indDWORD(pDlg,topDlg,style); //style
    indDWORD(pDlg,topDlg,0); //ext style
    indWORD(pDlg,topDlg,0); //Nitems
    indWORD(pDlg,topDlg,x * 4 / loword(GetDialogBaseUnits())); //x
    indWORD(pDlg,topDlg,y * 8 / hiword(GetDialogBaseUnits())); //y
    indWORD(pDlg,topDlg,cx * 4 / loword(GetDialogBaseUnits())); //cx
    indWORD(pDlg,topDlg,cy * 8 / hiword(GetDialogBaseUnits())); //cy
    indSTR(pDlg,topDlg,menu); //menu
    indSTR(pDlg,topDlg,cla); //class
    indSTR(pDlg,topDlg,caption); //caption
    if(topDlg % 4 != 0)
      indWORD(pDlg,topDlg,0);
  }

//размещение элемента диалога

  bool indItem(char*pDlg, int &topDlg, int x,int y,int cx,int cy,int ID,int style, char* cla,char* txt)
 {
    indDWORD(pDlg,topDlg,style); //style
    indDWORD(pDlg,topDlg,0); //ext style
    indWORD(pDlg,topDlg,x * 4 / loword(GetDialogBaseUnits())); //x
    indWORD(pDlg,topDlg,y * 8 / hiword(GetDialogBaseUnits())); //y
    indWORD(pDlg,topDlg,cx * 4 / loword(GetDialogBaseUnits())); //cx
    indWORD(pDlg,topDlg,cy * 8 / hiword(GetDialogBaseUnits())); //cy
    indWORD(pDlg,topDlg,ID); //ID
    indSTR(pDlg,topDlg,cla); //text
    indSTR(pDlg,topDlg,txt); //text
    indWORD(pDlg,topDlg,0); //create data !НЕ ВЫРАВНИВАТЬ НА DWORD!

    while(topDlg % 4 != 0) //выравнивание конца элемента на dword
      indCHAR(pDlg,topDlg,'\0');

    pDlg[8]=(char)(ord(pDlg[8])+1); //NItems+1
    if(pDlg[8]=='\0') indERROR=true;
  }

