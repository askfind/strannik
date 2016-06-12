// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа
// ƒемо 2:ѕрограмма с окном
module Demo1_2;
import Win32;

const 
  hINSTANCE=0x400000;
  им€ ласса="Strannik";

procedure оконѕроц(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_CREATE:return true;|
    WM_DESTROY:PostQuitMessage(0); return DefWindowProc(hWnd,msg,wParam,lParam);|
    else return DefWindowProc(hWnd,msg,wParam,lParam);
  end
end оконѕроц;

var
  осн ласс:WNDCLASS;
  оснќкно:HWND;
  сообщ:MSG;

begin

//регистраци€ класса
  with осн ласс do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(оконѕроц);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=0;//LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=им€ ласса;
  end;
  RegisterClass(осн ласс);
                     
//создание окна
  оснќкно:=CreateWindowEx(0,им€ ласса,'Demo1_2',WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(оснќкно,SW_SHOW);
  UpdateWindow(оснќкно);

//цикл сообщений
  while GetMessage(сообщ,0,0,0) do
    TranslateMessage(сообщ);
    DispatchMessage(сообщ);
  end;

end Demo1_2.

