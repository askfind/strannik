// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.13:Проигрывание звукового файла

program Demo2_13;
uses Win32;

begin
  PlaySound("Demo2_13.wav",0,SND_FILENAME);
  ExitProcess(0);
end.

