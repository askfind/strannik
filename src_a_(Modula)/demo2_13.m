// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.13:play sound file

module Demo2_13;
import Win32;

begin
  PlaySound("Demo2_13.wav",0,SND_FILENAME);
  ExitProcess(0);
end Demo2_13.

