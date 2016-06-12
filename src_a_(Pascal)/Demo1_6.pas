// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 6:Use GDI

program Demo1_6;
uses Win32;

const 
  INSTANCE=0x400000;
  className="Strannik";

const
  id1=0x0000FF;
  id2=0xFF0000;
  id3=0x00FF00;
  id4=50;
  id5=FW_NORMAL;
  id6=1;

procedure id7(id8:HWND; dc:HDC);
var id9,id10:HPEN; id11,id12:HBRUSH; id13,id14:HFONT; id15:RECT;
begin
//drawing pixel
  SetPixel(dc,10,10,id1);
//drawing line
  MoveToEx(dc,20,20,nil);
  LineTo(dc,20,30);
  LineTo(dc,30,30);
//drawing line (color)
  id9:=CreatePen(PS_SOLID,10,id1);
  id10:=SelectObject(dc,id9);
  MoveToEx(dc,40,40,nil);
  LineTo(dc,40,70);
  LineTo(dc,70,70);
  SelectObject(dc,id10);
  DeleteObject(id9);
//drawing ellipse (fragment)
  id9:=CreatePen(PS_SOLID,5,id2);
  id10:=SelectObject(dc,id9);
  Arc(dc,0,0,200,100,110,100,110,0);
  SelectObject(dc,id10);
  DeleteObject(id9);
//drawing rectangle
  Rectangle(dc,100,150,200,200);
//drawing rectangle (color)
  id9:=CreatePen(PS_SOLID,10,id1);
  id10:=SelectObject(dc,id9);
  id11:=CreateSolidBrush(id3);
  id12:=SelectObject(dc,id11);
  Rectangle(dc,300,150,400,200);
  SelectObject(dc,id10);
  DeleteObject(id9);
  SelectObject(dc,id12);
  DeleteObject(id11);
//drawing ellipse
  Ellipse(dc,100,250,200,300);
//drawing ellipse (color)
  id9:=CreatePen(PS_SOLID,10,id1);
  id10:=SelectObject(dc,id9);
  id11:=CreateSolidBrush(id3);
  id12:=SelectObject(dc,id11);
  Ellipse(dc,300,250,500,300);
  SelectObject(dc,id10);
  DeleteObject(id9);
  SelectObject(dc,id12);
  DeleteObject(id11);
//drawing text
  with id15 do begin
    left:=300;
    top:=0;
    right:=400;
    bottom:=100;
  end;
  DrawText(dc,"Strannik",lstrlen("Strannik"),id15,0);
//drawing text (font and size)
  with id15 do begin
    left:=300;
    top:=20;
    right:=500;
    bottom:=80;
  end;
  SetTextColor(dc,id1);
  SetBkColor(dc,id2);
  id13:=CreateFont(id4,0,0,0,id5,id6,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  id14:=SelectObject(dc,id13);
  DrawText(dc,"Strannik",lstrlen("Strannik"),id15,0);
  SelectObject(dc,id14);
  DeleteObject(id13);
//drawing transparent text
  with id15 do begin
    left:=300;
    top:=80;
    right:=500;
    bottom:=120;
  end;
  SetTextColor(dc,id1);
  id13:=CreateFont(id4,0,0,0,id5,id6,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  id14:=SelectObject(dc,id13);
  SetBkMode(dc,TRANSPARENT);
  DrawText(dc,"Strannik",lstrlen("Strannik"),id15,0);
  SetBkMode(dc,OPAQUE);
  SelectObject(dc,id14);
  DeleteObject(id13);
end;

function id16(wnd:HWND; msg,wparam,lparam:dword):boolean;
var dc:HDC; id17:PAINTSTRUCT;
begin
  case msg of
    WM_CREATE:return(true);
    WM_PAINT:begin
      dc:=BeginPaint(wnd,id17);
      id7(wnd,dc);
      EndPaint(wnd,id17);
    end;
    WM_DESTROY:begin PostQuitMessage(0); return(DefWindowProc(wnd,msg,wparam,lparam)) end;
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end;

var
  id18:WNDCLASS;
  id19:HWND;
  id20:MSG;

begin

//class registration
  with id18 do begin
    RtlZeroMemory(addr(id18),sizeof(WNDCLASS));
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(id16);
    hInstance:=INSTANCE;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:=className;
  end;
  RegisterClass(id18);
                     
//window create
  id19:=CreateWindowEx(0,className,"Demo1_6",WS_OVERLAPPEDWINDOW,
    50,50,600,400, 0,0,INSTANCE,nil);

  ShowWindow(id19,SW_SHOW);
  UpdateWindow(id19);

//message loop
  while GetMessage(id20,0,0,0) do begin
    TranslateMessage(id20);
    DispatchMessage(id20);
  end;

end.

