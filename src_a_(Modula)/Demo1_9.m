// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 9:Get command line

module Demo1_9;
import Win32;

var
  id1:pstr;

begin
  id1:=GetCommandLine();
  MessageBox(0,id1,"Command line:",0);
end Demo1_9.

