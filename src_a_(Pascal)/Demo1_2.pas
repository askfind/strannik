// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 2:Program with window

program Demo1_2;
uses Win32;

const 
  hINSTANCE=0x400000;
  className='Strannik';

function wndProc(hWnd:HWND; msg,wParam,lParam:dword):boolean;
begin
  case msg of
    WM_CREATE:return true;
    WM_DESTROY:begin PostQuitMessage(0); return DefWindowProc(hWnd,msg,wParam,lParam) end;
    else return DefWindowProc(hWnd,msg,wParam,lParam)
  end
end;

var
  id1:WNDCLASS;
  id2:HWND;
  message:MSG;

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
  id2:=CreateWindowEx(0,className,'Demo1_2',WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(id2,SW_SHOW);
  UpdateWindow(id2);

//message cycle
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;

end.

