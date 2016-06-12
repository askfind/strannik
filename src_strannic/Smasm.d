//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль ASM (встроенный ассемблер)
//Файл SMASM.D

definition module SmAsm;
import Win32,SmDat;

procedure asmInitial();
procedure asmDestroy();
procedure asmAssembly(var S:recStream);

end SmAsm.

