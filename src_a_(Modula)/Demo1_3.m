// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 3:Program with menu
module Demo1_3;
import Win32;

const 
  hINSTANCE=0x400000;
  id1="Strannik";

  id2=100;
  id3=101;
  id4=102;
  id5=200;

var
  id6:WNDCLASS;
  id7:HWND;
  id8:MSG;

//================= menu create =======================

procedure id9(id10:HWND);
var id11,id12:HMENU;
begin
  id11:=CreateMenu();

  id12:=CreatePopupMenu();
  AppendMenu(id12,MF_STRING|MF_ENABLED,id2,"New");
  AppendMenu(id12,MF_STRING|MF_ENABLED,id3,"Open");
  AppendMenu(id12,MF_STRING|MF_ENABLED,id4,"Save");
  AppendMenu(id11,MF_POPUP|MF_ENABLED,id12,"File");

  AppendMenu(id11,MF_STRING|MF_ENABLED,id5,"Exit");
  SetMenu(id10,id11);
end id9;

//================= window function ======================

procedure id13(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_CREATE:return(true);|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam));|
    WM_COMMAND:case word(wParam) of
      id2:MessageBox(0,"New","Menu:",0);|
      id3:MessageBox(0,"Open","Menu:",0);|
      id4:MessageBox(0,"Save","Menu:",0);|
      id5:MessageBox(0,"Exit","Menu:",0);|
    end;|
    else return(DefWindowProc(hWnd,msg,wParam,lParam));
  end
end id13;

//================= main ====================

begin

//class registration
  with id6 do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(id13);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=id1;
  end;
  RegisterClass(id6);
                     
//window create
  id7:=CreateWindowEx(0,id1,"Demo1_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(id7,SW_SHOW);
  UpdateWindow(id7);

//menu create
  id9(id7);

//messages loop
  while GetMessage(id8,0,0,0) do
    TranslateMessage(id8);
    DispatchMessage(id8);
  end;

end Demo1_3.

