//ѕроект —транник-ћодула ƒл€ Windows 32, тестова€ программа
//√руппа тестов 10:–≈—”–—џ
//“ест номер    2:–астровые изображени€

include Win32

define hINSTANCE 0x400000
define им€ ласса "Strannik"

bitmap BIT="Test10_2.bmp";

void –исовать(HWND окно) {
HBITMAP bm,hBM,hOldBM;
BITMAP BM;
HDC dc,hMemDC;
POINT ptSize,ptOrg;
PAINTSTRUCT ps;

  dc=BeginPaint(окно,ps);
  bm=LoadBitmap(hINSTANCE,"BIT");
  hMemDC=CreateCompatibleDC(dc);
  hOldBM=SelectObject(hMemDC,bm);
  if(hOldBM != 0) {
    SetMapMode(hMemDC,GetMapMode(dc));
    GetObject(bm,sizeof(BITMAP),&BM);
    ptSize.x=BM.bmWidth;
    ptSize.y=BM.bmHeight;
    DPtoLP(dc,ptSize,1);
    ptOrg.x=0;
    ptOrg.y=0;
    DPtoLP(hMemDC,ptOrg,1);
    BitBlt(dc,10,10,ptSize.x,ptSize.y,hMemDC,ptOrg.x,ptOrg.y,SRCCOPY);
  }
  SelectObject(hMemDC,hOldBM);
  DeleteDC(hMemDC);
  EndPaint(окно,ps);
}

boolean оконѕроц(HWND окно, int сооб,int вѕарам,int лѕарам)
{
  switch(сооб) {
    case WM_CREATE:return(true); break;
    case WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(окно,сооб,вѕарам,лѕарам)); break;
    case WM_PAINT:–исовать(окно); break;
    default:return(DefWindowProc(окно,сооб,вѕарам,лѕарам));
  }
}

WNDCLASS осн ласс;
HWND оснќкно;
MSG сообщ;

void main()
{
//регистраци€ класса
  with(осн ласс) {
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=&оконѕроц;
    cbClsExtra=0;
    cbWndExtra=0;
    hInstance=hINSTANCE;    
    hIcon=0;
    hCursor=LoadCursor(0,(pchar)IDC_ARROW);
    hbrBackground=COLOR_WINDOW;
    lpszMenuName=nil;
    lpszClassName=им€ ласса;
  }
  RegisterClass(&осн ласс);
                     
//создание окна
  оснќкно=CreateWindowEx(0,им€ ласса,"Beta1_2",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(оснќкно,SW_SHOW);
  UpdateWindow(оснќкно);

//цикл сообщений
  while(GetMessage(&сообщ,0,0,0)) {
    TranslateMessage(&сообщ);
    DispatchMessage(&сообщ);
  }
}

