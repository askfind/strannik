// СТРАННИК  Модула-Си-Паскаль для Win32
// Демонстрационная программа (Применение Win32)
// Демо 2.13:Проигрывание звукового файла

module Demo2_13;
import Win32;

begin
  PlaySound("Demo2_13.wav",0,SND_FILENAME);
  ExitProcess(0);
end Demo2_13.

