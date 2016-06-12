// —“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа
// ƒемо 6:»спользование GDI
program Demo1_6;
uses Win32;

const 
  INSTANCE=0x400000;
  className="Strannik";

const
   расный÷вет=0x0000FF;
  —иний÷вет=0xFF0000;
  «еленый÷вет=0x00FF00;
  ¬ысота=50;
  ¬ес=FW_NORMAL;
   урсив=1;

procedure –исовать¬ќкне(окно:HWND; dc:HDC);
var перо,старое:HPEN; кисть,стара€:HBRUSH; шрифт,старый:HFONT; регион:RECT;
begin
//рисование точки
  SetPixel(dc,10,10, расный÷вет);
//рисование линии
  MoveToEx(dc,20,20,nil);
  LineTo(dc,20,30);
  LineTo(dc,30,30);
//рисование цветной линии
  перо:=CreatePen(PS_SOLID,10, расный÷вет);
  старое:=SelectObject(dc,перо);
  MoveToEx(dc,40,40,nil);
  LineTo(dc,40,70);
  LineTo(dc,70,70);
  SelectObject(dc,старое);
  DeleteObject(перо);
//рисование дуги эллипса
  перо:=CreatePen(PS_SOLID,5,—иний÷вет);
  старое:=SelectObject(dc,перо);
  Arc(dc,0,0,200,100,110,100,110,0);
  SelectObject(dc,старое);
  DeleteObject(перо);
//рисование пр€моугольника
  Rectangle(dc,100,150,200,200);
//рисование цветного пр€моугольника
  перо:=CreatePen(PS_SOLID,10, расный÷вет);
  старое:=SelectObject(dc,перо);
  кисть:=CreateSolidBrush(«еленый÷вет);
  стара€:=SelectObject(dc,кисть);
  Rectangle(dc,300,150,400,200);
  SelectObject(dc,старое);
  DeleteObject(перо);
  SelectObject(dc,стара€);
  DeleteObject(кисть);
//рисование эллипса
  Ellipse(dc,100,250,200,300);
//рисование цветного эллипса
  перо:=CreatePen(PS_SOLID,10, расный÷вет);
  старое:=SelectObject(dc,перо);
  кисть:=CreateSolidBrush(«еленый÷вет);
  стара€:=SelectObject(dc,кисть);
  Ellipse(dc,300,250,500,300);
  SelectObject(dc,старое);
  DeleteObject(перо);
  SelectObject(dc,стара€);
  DeleteObject(кисть);
//вывод текста
  with регион do begin
    left:=300;
    top:=0;
    right:=400;
    bottom:=100;
  end;
  DrawText(dc,"Strannik",lstrlen("Strannik"),регион,0);
//вывод текста заданного шрифта и размера
  with регион do begin
    left:=300;
    top:=20;
    right:=500;
    bottom:=80;
  end;
  SetTextColor(dc, расный÷вет);
  SetBkColor(dc,—иний÷вет);
  шрифт:=CreateFont(¬ысота,0,0,0,¬ес, урсив,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  старый:=SelectObject(dc,шрифт);
  DrawText(dc,"Strannik",lstrlen("Strannik"),регион,0);
  SelectObject(dc,старый);
  DeleteObject(шрифт);
//вывод прозрачного текста
  with регион do begin
    left:=300;
    top:=80;
    right:=500;
    bottom:=120;
  end;
  SetTextColor(dc, расный÷вет);
  шрифт:=CreateFont(¬ысота,0,0,0,¬ес, урсив,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  старый:=SelectObject(dc,шрифт);
  SetBkMode(dc,TRANSPARENT);
  DrawText(dc,"Strannik",lstrlen("Strannik"),регион,0);
  SetBkMode(dc,OPAQUE);
  SelectObject(dc,старый);
  DeleteObject(шрифт);
end;

function ќконна€‘ункци€(wnd:HWND; msg,wparam,lparam:dword):boolean;
var dc:HDC; структура:PAINTSTRUCT;
begin
  case msg of
    WM_CREATE:return(true);
    WM_PAINT:begin
      dc:=BeginPaint(wnd,структура);
      –исовать¬ќкне(wnd,dc);
      EndPaint(wnd,структура);
    end;
    WM_DESTROY:begin PostQuitMessage(0); return(DefWindowProc(wnd,msg,wparam,lparam)) end;
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end;

var
   лассќкна:WNDCLASS;
  ќкно:HWND;
  —ообщение:MSG;

begin

// регистраци€ класса(class registration)
  with  лассќкна do begin
    RtlZeroMemory(addr( лассќкна),sizeof(WNDCLASS));
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(ќконна€‘ункци€);
    hInstance:=INSTANCE;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:=className;
  end;
  RegisterClass( лассќкна);
                     
// создание окна(window create)
  ќкно:=CreateWindowEx(0,className,"Demo1_6",WS_OVERLAPPEDWINDOW,
    50,50,600,400, 0,0,INSTANCE,nil);

  ShowWindow(ќкно,SW_SHOW);
  UpdateWindow(ќкно);

//цикл сообщений (message cycle)
  while GetMessage(—ообщение,0,0,0) do begin
    TranslateMessage(—ообщение);
    DispatchMessage(—ообщение);
  end;

end.

