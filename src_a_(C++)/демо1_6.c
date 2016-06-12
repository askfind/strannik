// —“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа
// “ест 6:»спользование GDI
include Win32

define INSTANCE 0x400000
define className "Strannik"

define  расный÷вет 0x0000FF
define —иний÷вет 0xFF0000
define «еленый÷вет 0x00FF00
define ¬ысота 50
define ¬ес FW_NORMAL
define  урсив 1

void –исовать¬ќкне(HWND окно, HDC dc) {
HPEN перо,старое; HBRUSH кисть,стара€; HFONT шрифт,старый; RECT регион;

//рисование точки
  SetPixel(dc,10,10, расный÷вет);
//рисование линии
  MoveToEx(dc,20,20,nil);
  LineTo(dc,20,30);
  LineTo(dc,30,30);
//рисование цветной линии
  перо=CreatePen(PS_SOLID,10, расный÷вет);
  старое=SelectObject(dc,перо);
  MoveToEx(dc,40,40,nil);
  LineTo(dc,40,70);
  LineTo(dc,70,70);
  SelectObject(dc,старое);
  DeleteObject(перо);
//рисование дуги эллипса
  перо=CreatePen(PS_SOLID,5,—иний÷вет);
  старое=SelectObject(dc,перо);
  Arc(dc,0,0,200,100,110,100,110,0);
  SelectObject(dc,старое);
  DeleteObject(перо);
//рисование пр€моугольника
  Rectangle(dc,100,150,200,200);
//рисование цветного пр€моугольника
  перо=CreatePen(PS_SOLID,10, расный÷вет);
  старое=SelectObject(dc,перо);
  кисть=CreateSolidBrush(«еленый÷вет);
  стара€=SelectObject(dc,кисть);
  Rectangle(dc,300,150,400,200);
  SelectObject(dc,старое);
  DeleteObject(перо);
  SelectObject(dc,стара€);
  DeleteObject(кисть);
//рисование эллипса
  Ellipse(dc,100,250,200,300);
//рисование цветного эллипса
  перо=CreatePen(PS_SOLID,10, расный÷вет);
  старое=SelectObject(dc,перо);
  кисть=CreateSolidBrush(«еленый÷вет);
  стара€=SelectObject(dc,кисть);
  Ellipse(dc,300,250,500,300);
  SelectObject(dc,старое);
  DeleteObject(перо);
  SelectObject(dc,стара€);
  DeleteObject(кисть);
//вывод текста
  with(регион) {
    left=300;
    top=0;
    right=400;
    bottom=100;
  }
  DrawText(dc,"Strannik",lstrlen("Strannik"),регион,0);
//вывод текста заданного шрифта и размера
  with(регион) {
    left=300;
    top=20;
    right=500;
    bottom=80;
  }
  SetTextColor(dc, расный÷вет);
  SetBkColor(dc,—иний÷вет);
  шрифт=CreateFont(¬ысота,0,0,0,¬ес, урсив,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  старый=SelectObject(dc,шрифт);
  DrawText(dc,"Strannik",lstrlen("Strannik"),регион,0);
  SelectObject(dc,старый);
  DeleteObject(шрифт);
//вывод прозрачного текста
  with(регион) {
    left=300;
    top=80;
    right=500;
    bottom=120;
  }
  SetTextColor(dc, расный÷вет);
  шрифт=CreateFont(¬ысота,0,0,0,¬ес, урсив,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  старый=SelectObject(dc,шрифт);
  SetBkMode(dc,TRANSPARENT);
  DrawText(dc,"Strannik",lstrlen("Strannik"),регион,0);
  SetBkMode(dc,OPAQUE);
  SelectObject(dc,старый);
  DeleteObject(шрифт);
} //–исовать¬ќкне

bool ќконна€‘ункци€(HWND wnd,uint msg,uint wparam,uint lparam) {
HDC dc; PAINTSTRUCT структура;

  switch(msg) {
    case WM_CREATE:return true; break;
    case WM_PAINT:
      dc=BeginPaint(wnd,структура);
      –исовать¬ќкне(wnd,dc);
      EndPaint(wnd,структура); break;
    case WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
} //ќконна€‘ункци€

WNDCLASS  лассќкна;
HWND ќкно;
MSG —ообщение;

void main()
{
// регистраци€ класса(class registration)
  with( лассќкна) {
    RtlZeroMemory(addr( лассќкна),sizeof(WNDCLASS));
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=addr(ќконна€‘ункци€);
    hInstance=INSTANCE;
    hCursor=LoadCursor(0,(pchar)IDC_ARROW);
    hbrBackground=COLOR_WINDOW;
    lpszClassName=className;
  }
  RegisterClass( лассќкна);
                     
// создание окна(window create)
  ќкно=CreateWindowEx(0,className,"Demo1_6",WS_OVERLAPPEDWINDOW,
    50,50,600,400, 0,0,INSTANCE,nil);

  ShowWindow(ќкно,SW_SHOW);
  UpdateWindow(ќкно);

//цикл сообщений (message cycle)
  while(GetMessage(—ообщение,0,0,0)) {
    TranslateMessage(—ообщение);
    DispatchMessage(—ообщение);
  }

} //Demo1_6

