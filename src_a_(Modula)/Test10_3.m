//ѕроект —транник-ћодула ƒл€ Windows 32, тестова€ программа
//√руппа тестов 10:–≈—”–—џ
//“ест номер    3:»конка
module Test10_3;
import Win32;

const 
  hINSTANCE=0x400000;
  им€ ласса="Strannik";

icon "Test10_3.bmp";

procedure оконѕроц(окно:HWND; сооб,вѕарам,лѕарам:cardinal):boolean;
var dc:HDC; пикт:HICON; структ:PAINTSTRUCT;
begin
  case сооб of
    WM_CREATE:return(true);|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(окно,сооб,вѕарам,лѕарам));|
    WM_PAINT:
      dc:=BeginPaint(окно,структ);
      пикт:=LoadIcon(hINSTANCE,pstr(0x0000));
      DrawIcon(dc,10,10,пикт);
      DestroyIcon(пикт);
      EndPaint(окно,структ);|
    else return(DefWindowProc(окно,сооб,вѕарам,лѕарам));
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
    hIcon:=LoadIcon(hINSTANCE,pstr(0x0000));
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=им€ ласса;
  end;
  RegisterClass(осн ласс);
                     
//создание окна
  оснќкно:=CreateWindowEx(0,им€ ласса,"Test10_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(оснќкно,SW_SHOW);
  UpdateWindow(оснќкно);

//цикл сообщений
  while GetMessage(сообщ,0,0,0) do
    TranslateMessage(сообщ);
    DispatchMessage(сообщ);
  end;

end Test10_3.

