//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер 7:Работа с DBF-файлами
include Win32,Win32ext

  char str[50];
  recDBF dbf;
  char *rec;
  int file,num;

void main() {
//создание заголовка
  with(dbf) {
    dbfTopField=3;
    with(dbfFields[1]) {
      lstrcpy(dbfFieldName,"Fam");
      dbfFieldType='C';
      dbfFieldLength=20;
    }
    with(dbfFields[2]) {
      lstrcpy(dbfFieldName,"Name");
      dbfFieldType='C';
      dbfFieldLength=10;
    }
    with(dbfFields[3]) {
      lstrcpy(dbfFieldName,"Sum");
      dbfFieldType='C';
      dbfFieldLength=15;
    }
  }

//создание файла
  file=_lcreat("Test9_7.dbf",0);
  dbfNewTitle(dbf,file);
  _lclose(file);
  MessageBox(0,"Ok","dbfNewTitle",0);

//запись в файл
  file=_lopen("Test9_7.dbf",OF_READWRITE);
  if(!dbfGetTitle(dbf,file)) {
    MessageBox(0,"Ошибка при загрузке DBF-заголовка","Внимание !",0);
  }
  rec=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"Сенчуков");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"Михаил");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"20.00");
  dbfWriteRecord(dbf,file,0,rec);
  memFree(rec);
  rec=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"Шувалов");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"Александр");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"130.10");
  dbfWriteRecord(dbf,file,1,rec);
  memFree(rec);
  _lclose(file);
  MessageBox(0,"Ok","dbfWriteRecord",0);

//чтение из файла
  file=_lopen("Test9_7.dbf",OF_READ);
  dbfGetTitle(dbf,file);
  rec=dbfNewRecord(dbf);
  dbfReadRecord(dbf,file,1,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"Шувалов",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"Александр",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"130.10",0);
  memFree(rec);
  _lclose(file);

//запись середину файла
  file=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  rec=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"Крабин");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"Сергей");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"45.40");
  dbfWriteRecord(dbf,file,1,rec);
  memFree(rec);
  _lclose(file);

  file=_lopen("Test9_7.dbf",OF_READ);
  dbfGetTitle(dbf,file);
  rec=dbfNewRecord(dbf);
  dbfReadRecord(dbf,file,1,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"Крабин",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"Сергей",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"45.40",0);
  memFree(rec);
  _lclose(file);

//размер файла
  file=_lopen("Test9_7.dbf",OF_READ);
  dbfGetTitle(dbf,file);
  num=dbfGetSize(dbf,file);
  _lclose(file);
  wvsprintf(str,"size=%li",addr(num));
  MessageBox(0,str,"size=2",0);

//вставка в файл
  file=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  rec=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"Шувалов");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"Александр");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"130.10");
  dbfInsertRecord(dbf,file,1,rec);
  dbfReadRecord(dbf,file,2,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"Крабин",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"Сергей",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"45.40",0);
  num=dbfGetSize(dbf,file);
  wvsprintf(str,"size=%li",&num);
  MessageBox(0,str,"size=3",0);
  memFree(rec);
  _lclose(file);

//удаление из файла
  file=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  dbfDeleteRecord(dbf,file,0,false);
  if(dbfIsDeleted(dbf,file,0))
    MessageBox(0,"Ok","IsDeleted",0);
  else MessageBox(0,"Error","IsDeleted",0);
  _lclose(file);

//очистка файла  
  file=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  dbfClearFile(dbf,file);
  rec=dbfNewRecord(dbf);
  dbfReadRecord(dbf,file,0,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"Шувалов",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"Александр",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"130.10",0);
  num=dbfGetSize(dbf,file);
  wvsprintf(str,"size=%li",addr(num));
  MessageBox(0,str,"size=2",0);
  memFree(rec);
  _lclose(file);

}

