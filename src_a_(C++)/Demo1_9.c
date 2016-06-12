// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 9:Get command line

include Win32

char* id1;

void main()
{
  id1=GetCommandLine();
  MessageBox(0,id1,"Command line:",0);
}

