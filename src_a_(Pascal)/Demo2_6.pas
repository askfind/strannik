// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.6:Choice of the file

program Demo2_6;
uses Win32;

var
  id1:string[512];
  id2:string[512];

function id3(id4,id5:pstr; id6:integer; id7:boolean):boolean;
var id8:OPENFILENAME;
begin
  RtlZeroMemory(addr(id8),sizeof(OPENFILENAME));
  with id8 do begin
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=id6;
    lpstrFile:=id5; 
    lpstrFilter:=id5; 
    nMaxFileTitle:=id6;
    lpstrFileTitle:=id4; 
    Flags:=OFN_EXPLORER;
  end;
  if id7
    then id3:=GetOpenFileName(id8)
    else id3:=GetSaveFileName(id8)
end;

begin
  lstrcpy(id1,"");
  lstrcpy(id2,"*.m;*.c;*.pas");
  if id3(id1,id2,512,true)
    then MessageBox(0,id1,"Select file:",0)
    else MessageBox(0,"Cancel","",0);
  ExitProcess(0); //need for unload openfilename
end.

