// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.6:Стандартный диалог выбора файла

module Demo2_6;
import Win32;

var
  ИмяФайла:string[512];
  МаскаФайла:string[512];

procedure ПолучитьИмяФайла(файл,маска:pstr; размер:integer; bitOpenыть:boolean):boolean;
var структ:OPENFILENAME;
begin
  RtlZeroMemory(addr(структ),sizeof(OPENFILENAME));
  with структ do
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=размер;
    lpstrFile:=маска; 
    lpstrFilter:=маска; 
    nMaxFileTitle:=размер;
    lpstrFileTitle:=файл; 
    Flags:=OFN_EXPLORER;
  end;
  if bitOpenыть
    then return GetOpenFileName(структ)
    else return GetSaveFileName(структ)
  end;
end ПолучитьИмяФайла;

begin
  lstrcpy(ИмяФайла,"");
  lstrcpy(МаскаФайла,"*.m;*.c;*.pas");
  if ПолучитьИмяФайла(ИмяФайла,МаскаФайла,512,true)
    then MessageBox(0,ИмяФайла,"Выбран файл:",0)
    else MessageBox(0,"Отказ от выбора файла","",0)
  end;
  ExitProcess(0); //необходимо для выгрузки стандартного диалога из памяти
end Demo2_6.

