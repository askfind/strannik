//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 9:������� Win32ext
//���� ����� 7:������ � DBF-�������
program Test9_7;
uses Win32,Win32ext;

var
  str:string[50];
  dbf:recDBF;
  rec:pstr;
  file,num:integer;

begin
//�������� ���������
  with dbf do begin
    dbfTopField:=3;
    with dbfFields[1] do begin
      lstrcpy(dbfFieldName,"Fam");
      dbfFieldType:='C';
      dbfFieldLength:=20;
    end;
    with dbfFields[2] do begin
      lstrcpy(dbfFieldName,"Name");
      dbfFieldType:='C';
      dbfFieldLength:=10;
    end;
    with dbfFields[3] do begin
      lstrcpy(dbfFieldName,"Sum");
      dbfFieldType:='C';
      dbfFieldLength:=15;
    end;
  end;

//�������� �����
  file:=_lcreat("Test9_7.dbf",0);
  dbfNewTitle(dbf,file);
  _lclose(file);
  MessageBox(0,"Ok","dbfNewTitle",0);

//������ � ����
  file:=_lopen("Test9_7.dbf",OF_READWRITE);
  if not dbfGetTitle(dbf,file) then begin
    MessageBox(0,"������ ��� �������� DBF-���������","�������� !",0);
  end;
  rec:=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"��������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"20.00");
  dbfWriteRecord(dbf,file,0,rec);
  memFree(rec);
  rec:=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"�������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"���������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"130.10");
  dbfWriteRecord(dbf,file,1,rec);
  memFree(rec);
  _lclose(file);
  MessageBox(0,"Ok","dbfWriteRecord",0);

//������ �� �����
  file:=_lopen("Test9_7.dbf",OF_READ);
  dbfGetTitle(dbf,file);
  rec:=dbfNewRecord(dbf);
  dbfReadRecord(dbf,file,1,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"�������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"���������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"130.10",0);
  memFree(rec);
  _lclose(file);

//������ �������� �����
  file:=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  rec:=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"45.40");
  dbfWriteRecord(dbf,file,1,rec);
  memFree(rec);
  _lclose(file);

  file:=_lopen("Test9_7.dbf",OF_READ);
  dbfGetTitle(dbf,file);
  rec:=dbfNewRecord(dbf);
  dbfReadRecord(dbf,file,1,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"45.40",0);
  memFree(rec);
  _lclose(file);

//������ �����
  file:=_lopen("Test9_7.dbf",OF_READ);
  dbfGetTitle(dbf,file);
  num:=dbfGetSize(dbf,file);
  _lclose(file);
  wvsprintf(str,"size=%li",addr(num));
  MessageBox(0,str,"size=2",0);

//������� � ����
  file:=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  rec:=dbfNewRecord(dbf);
  dbfSetField(dbf,rec,dbfFindField(dbf,"Fam"),"�������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Name"),"���������");
  dbfSetField(dbf,rec,dbfFindField(dbf,"Sum"),"130.10");
  dbfInsertRecord(dbf,file,1,rec);
  dbfReadRecord(dbf,file,2,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"45.40",0);
  num:=dbfGetSize(dbf,file);
  wvsprintf(str,"size=%li",addr(num));
  MessageBox(0,str,"size=3",0);
  memFree(rec);
  _lclose(file);

//�������� �� �����
  file:=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  dbfDeleteRecord(dbf,file,0,false);
  if dbfIsDeleted(dbf,file,0)
    then MessageBox(0,"Ok","IsDeleted",0)
    else MessageBox(0,"Error","IsDeleted",0);
  _lclose(file);

//������� �����  
  file:=_lopen("Test9_7.dbf",OF_READWRITE);
  dbfGetTitle(dbf,file);
  dbfClearFile(dbf,file);
  rec:=dbfNewRecord(dbf);
  dbfReadRecord(dbf,file,0,rec);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Fam"),str); MessageBox(0,str,"�������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Name"),str); MessageBox(0,str,"���������",0);
  dbfGetField(dbf,rec,dbfFindField(dbf,"Sum"),str); MessageBox(0,str,"130.10",0);
  num:=dbfGetSize(dbf,file);
  wvsprintf(str,"size=%li",addr(num));
  MessageBox(0,str,"size=2",0);
  memFree(rec);
  _lclose(file);

end.

