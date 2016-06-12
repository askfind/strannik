// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 3:Program with menu
program Demo1_3;
uses Win32;

const 
  hINSTANCE=0x400000;
  className='Strannik';

  menuNew=100;
  menuOpen=101;
  menuSave=102;
  menuExit=200;

var
  id1:WNDCLASS;
  id2:HWND;
  message:MSG;

//================= menu create =======================

procedure createMenu(id3:HWND);
var mainMenu,popupMenu:HMENU;
begin
  mainMenu:=CreateMenu();

  popupMenu:=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP|MF_ENABLED,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING|MF_ENABLED,menuExit,"Exit");
  SetMenu(id3,mainMenu);
end;

//================= window function ======================

function wndProc(hWnd:HWND; msg,wParam,lParam:dword):boolean;
begin
  case msg of
    WM_CREATE:return true;
    WM_DESTROY:begin PostQuitMessage(0); return DefWindowProc(hWnd,msg,wParam,lParam) end;
    WM_COMMAND:case word(wParam) of
      menuNew:MessageBox(0,"New","Menu:",0);
      menuOpen:MessageBox(0,"Open","Menu:",0);
      menuSave:MessageBox(0,"Save","Menu:",0);
      menuExit:MessageBox(0,"Exit","Menu:",0);
    end;
    else return DefWindowProc(hWnd,msg,wParam,lParam)
  end
end;

//================= main ====================

begin

//class registration
  with id1 do begin
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=className;
  end;
  RegisterClass(id1);
                     
//window create
  id2:=CreateWindowEx(0,className,"Demo1_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(id2,SW_SHOW);
  UpdateWindow(id2);

//menu create
  createMenu(id2);

//messages loop
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;

end.

