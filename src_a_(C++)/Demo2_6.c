// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.6:Choice of the file

include Win32

char id1[512];
char id2[512];

bool id3(char* id4, char* id5, int id6, bool id7)
{OPENFILENAME id8;

  RtlZeroMemory(&id8,sizeof(OPENFILENAME));
  with(id8) {
    lStructSize=sizeof(OPENFILENAME);
    nMaxFile=id6;
    lpstrFile=id5; 
    lpstrFilter=id5; 
    nMaxFileTitle=id6;
    lpstrFileTitle=id4; 
    Flags=OFN_EXPLORER;
  }
  if(id7) return GetOpenFileName(id8);
  else return GetSaveFileName(id8);
}

void main()
{
  lstrcpy(id1,"");
  lstrcpy(id2,"*.m;*.c;*.pas");
  if(id3(id1,id2,512,true))
    MessageBox(0,id1,"Select file:",0);
  else MessageBox(0,"Cancel","",0);
  ExitProcess(0); //need for unload openfilename
}

