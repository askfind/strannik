// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.6:Стандартный диалог выбора файла

include Win32

char ИмяФайла[512];
char МаскаФайла[512];

bool ПолучитьИмяФайла(char* файл, char* маска, int размер, bool bitOpenыть)
{OPENFILENAME структ;

  RtlZeroMemory(&структ,sizeof(OPENFILENAME));
  with(структ) {
    lStructSize=sizeof(OPENFILENAME);
    nMaxFile=размер;
    lpstrFile=маска; 
    lpstrFilter=маска; 
    nMaxFileTitle=размер;
    lpstrFileTitle=файл; 
    Flags=OFN_EXPLORER;
  }
  if(bitOpenыть) return GetOpenFileName(структ);
  else return GetSaveFileName(структ);
}

void main()
{
  lstrcpy(ИмяФайла,"");
  lstrcpy(МаскаФайла,"*.m;*.c;*.pas");
  if(ПолучитьИмяФайла(ИмяФайла,МаскаФайла,512,true))
    MessageBox(0,ИмяФайла,"Выбран файл:",0);
  else MessageBox(0,"Отказ от выбора файла","",0);
  ExitProcess(0); //необходимо для выгрузки стандартного диалога из памяти
}

