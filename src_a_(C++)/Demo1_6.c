// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 6:Use GDI

include Win32

define INSTANCE 0x400000
define className "Strannik"

define id1 0x0000FF
define id2 0xFF0000
define id3 0x00FF00
define id4 50
define id5 FW_NORMAL
define id6 1

void id7(HWND id8, HDC dc) {
HPEN id9,id10; HBRUSH id11,id12; HFONT id13,id14; RECT id15;

//drawing pixel
  SetPixel(dc,10,10,id1);
//drawing line
  MoveToEx(dc,20,20,nil);
  LineTo(dc,20,30);
  LineTo(dc,30,30);
//drawing line (color)
  id9=CreatePen(PS_SOLID,10,id1);
  id10=SelectObject(dc,id9);
  MoveToEx(dc,40,40,nil);
  LineTo(dc,40,70);
  LineTo(dc,70,70);
  SelectObject(dc,id10);
  DeleteObject(id9);
//drawing ellipse (fragment)
  id9=CreatePen(PS_SOLID,5,id2);
  id10=SelectObject(dc,id9);
  Arc(dc,0,0,200,100,110,100,110,0);
  SelectObject(dc,id10);
  DeleteObject(id9);
//drawing rectangle
  Rectangle(dc,100,150,200,200);
//drawing rectangle (color)
  id9=CreatePen(PS_SOLID,10,id1);
  id10=SelectObject(dc,id9);
  id11=CreateSolidBrush(id3);
  id12=SelectObject(dc,id11);
  Rectangle(dc,300,150,400,200);
  SelectObject(dc,id10);
  DeleteObject(id9);
  SelectObject(dc,id12);
  DeleteObject(id11);
//drawing ellipse
  Ellipse(dc,100,250,200,300);
//drawing ellipse (color)
  id9=CreatePen(PS_SOLID,10,id1);
  id10=SelectObject(dc,id9);
  id11=CreateSolidBrush(id3);
  id12=SelectObject(dc,id11);
  Ellipse(dc,300,250,500,300);
  SelectObject(dc,id10);
  DeleteObject(id9);
  SelectObject(dc,id12);
  DeleteObject(id11);
//drawing text
  with(id15) {
    left=300;
    top=0;
    right=400;
    bottom=100;
  }
  DrawText(dc,"Strannik",lstrlen("Strannik"),id15,0);
//drawing text (font and size)
  with(id15) {
    left=300;
    top=20;
    right=500;
    bottom=80;
  }
  SetTextColor(dc,id1);
  SetBkColor(dc,id2);
  id13=CreateFont(id4,0,0,0,id5,id6,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  id14=SelectObject(dc,id13);
  DrawText(dc,"Strannik",lstrlen("Strannik"),id15,0);
  SelectObject(dc,id14);
  DeleteObject(id13);
//drawing transparent text
  with(id15) {
    left=300;
    top=80;
    right=500;
    bottom=120;
  }
  SetTextColor(dc,id1);
  id13=CreateFont(id4,0,0,0,id5,id6,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  id14=SelectObject(dc,id13);
  SetBkMode(dc,TRANSPARENT);
  DrawText(dc,"Strannik",lstrlen("Strannik"),id15,0);
  SetBkMode(dc,OPAQUE);
  SelectObject(dc,id14);
  DeleteObject(id13);
}

bool id16(HWND wnd,uint msg,uint wparam,uint lparam) {
HDC dc; PAINTSTRUCT id17;

  switch(msg) {
    case WM_CREATE:return true; break;
    case WM_PAINT:
      dc=BeginPaint(wnd,id17);
      id7(wnd,dc);
      EndPaint(wnd,id17); break;
    case WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

WNDCLASS id18;
HWND id19;
MSG id20;

void main()
{
//class registration
  with(id18) {
    RtlZeroMemory(addr(id18),sizeof(WNDCLASS));
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=addr(id16);
    hInstance=INSTANCE;
    hCursor=LoadCursor(0,(pchar)IDC_ARROW);
    hbrBackground=COLOR_WINDOW;
    lpszClassName=className;
  }
  RegisterClass(id18);
                     
//window create
  id19=CreateWindowEx(0,className,"Demo1_6",WS_OVERLAPPEDWINDOW,
    50,50,600,400, 0,0,INSTANCE,nil);

  ShowWindow(id19,SW_SHOW);
  UpdateWindow(id19);

//message loop
  while(GetMessage(id20,0,0,0)) {
    TranslateMessage(id20);
    DispatchMessage(id20);
  }

}

