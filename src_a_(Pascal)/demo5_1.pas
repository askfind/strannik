// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use DirectX)
// Demo 5.1:Set Display Mode
program Demo5_1;
uses Win32;

var
  ddraw:pDIRECTDRAW;

begin
  DirectDrawCreate(nil,addr(ddraw),nil);
  ddraw.SetDisplayMode(800, 600, 16);
  ddraw.Release();
  ExitProcess(0)
end.


