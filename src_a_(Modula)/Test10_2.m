//ѕроект —транник-ћодула ƒл€ Windows 32, тестова€ программа
//√руппа тестов 10:–≈—”–—џ
//“ест номер    2:–астровые изображени€
module Test10_2;
import Win32;

const 
  hINSTANCE=0x400000;
  им€ ласса="Strannik";

bitmap BIT="Test10_2.bmp";

procedure –исовать(окно:HWND);
var bm,hBM,hOldBM:HBITMAP; dc,hMemDC:HDC; BM:BITMAP; ptSize,ptOrg:POINT; ps:PAINTSTRUCT;
begin
  dc:=BeginPaint(окно,ps);
  bm:=LoadBitmap(hINSTANCE,"BIT");
  hMemDC:=CreateCompatibleDC(dc);
  hOldBM:=SelectObject(hMemDC,bm);
  if hOldBM<>0 then
    SetMapMode(hMemDC,GetMapMode(dc));
    GetObject(bm,sizeof(BITMAP),addr(BM));
    ptSize.x:=BM.bmWidth;
    ptSize.y:=BM.bmHeight;
    DPtoLP(dc,ptSize,1);
    ptOrg.x:=0;
    ptOrg.y:=0;
    DPtoLP(hMemDC,ptOrg,1);
    BitBlt(dc,10,10,ptSize.x,ptSize.y,
           hMemDC,ptOrg.x,ptOrg.y,SRCCOPY);
  end;
  SelectObject(hMemDC,hOldBM);
  DeleteDC(hMemDC);
  EndPaint(окно,ps);
end –исовать;

procedure оконѕроц(окно:HWND; сооб,вѕарам,лѕарам:cardinal):boolean;
begin
  case сооб of
    WM_CREATE:return(true);|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(окно,сооб,вѕарам,лѕарам));|
    WM_PAINT:–исовать(окно);|
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
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=им€ ласса;
  end;
  RegisterClass(addr(осн ласс));
                     
//создание окна
  оснќкно:=CreateWindowEx(0,им€ ласса,"Test10_2",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(оснќкно,SW_SHOW);
  UpdateWindow(оснќкно);

//цикл сообщений
  while GetMessage(addr(сообщ),0,0,0) do
    TranslateMessage(addr(сообщ));
    DispatchMessage(addr(сообщ));
  end;

end Test10_2.

