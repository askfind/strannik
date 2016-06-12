// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 2:Program with window

module Demo1_2;
import Win32;

const 
  hINSTANCE=0x400000;
  id1="Strannik";

procedure id2(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_CREATE:return true;|
    WM_DESTROY:PostQuitMessage(0); return DefWindowProc(hWnd,msg,wParam,lParam);|
    else return DefWindowProc(hWnd,msg,wParam,lParam);
  end
end id2;

var
  id3:WNDCLASS;
  id4:HWND;
  id5:MSG;

begin

//class registration
  with id3 do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(id2);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=0;
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=id1;
  end;
  RegisterClass(id3);
                     
//create window
  id4:=CreateWindowEx(0,id1,'Demo1_2',WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(id4,SW_SHOW);
  UpdateWindow(id4);

//messages loop
  while GetMessage(id5,0,0,0) do
    TranslateMessage(id5);
    DispatchMessage(id5);
  end;

end Demo1_2.

