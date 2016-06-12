// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 6:������������� GDI
program Demo1_6;
uses Win32;

const 
  INSTANCE=0x400000;
  className="Strannik";

const
  �����������=0x0000FF;
  ���������=0xFF0000;
  �����������=0x00FF00;
  ������=50;
  ���=FW_NORMAL;
  ������=1;

procedure �������������(����:HWND; dc:HDC);
var ����,������:HPEN; �����,������:HBRUSH; �����,������:HFONT; ������:RECT;
begin
//��������� �����
  SetPixel(dc,10,10,�����������);
//��������� �����
  MoveToEx(dc,20,20,nil);
  LineTo(dc,20,30);
  LineTo(dc,30,30);
//��������� ������� �����
  ����:=CreatePen(PS_SOLID,10,�����������);
  ������:=SelectObject(dc,����);
  MoveToEx(dc,40,40,nil);
  LineTo(dc,40,70);
  LineTo(dc,70,70);
  SelectObject(dc,������);
  DeleteObject(����);
//��������� ���� �������
  ����:=CreatePen(PS_SOLID,5,���������);
  ������:=SelectObject(dc,����);
  Arc(dc,0,0,200,100,110,100,110,0);
  SelectObject(dc,������);
  DeleteObject(����);
//��������� ��������������
  Rectangle(dc,100,150,200,200);
//��������� �������� ��������������
  ����:=CreatePen(PS_SOLID,10,�����������);
  ������:=SelectObject(dc,����);
  �����:=CreateSolidBrush(�����������);
  ������:=SelectObject(dc,�����);
  Rectangle(dc,300,150,400,200);
  SelectObject(dc,������);
  DeleteObject(����);
  SelectObject(dc,������);
  DeleteObject(�����);
//��������� �������
  Ellipse(dc,100,250,200,300);
//��������� �������� �������
  ����:=CreatePen(PS_SOLID,10,�����������);
  ������:=SelectObject(dc,����);
  �����:=CreateSolidBrush(�����������);
  ������:=SelectObject(dc,�����);
  Ellipse(dc,300,250,500,300);
  SelectObject(dc,������);
  DeleteObject(����);
  SelectObject(dc,������);
  DeleteObject(�����);
//����� ������
  with ������ do begin
    left:=300;
    top:=0;
    right:=400;
    bottom:=100;
  end;
  DrawText(dc,"Strannik",lstrlen("Strannik"),������,0);
//����� ������ ��������� ������ � �������
  with ������ do begin
    left:=300;
    top:=20;
    right:=500;
    bottom:=80;
  end;
  SetTextColor(dc,�����������);
  SetBkColor(dc,���������);
  �����:=CreateFont(������,0,0,0,���,������,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  ������:=SelectObject(dc,�����);
  DrawText(dc,"Strannik",lstrlen("Strannik"),������,0);
  SelectObject(dc,������);
  DeleteObject(�����);
//����� ����������� ������
  with ������ do begin
    left:=300;
    top:=80;
    right:=500;
    bottom:=120;
  end;
  SetTextColor(dc,�����������);
  �����:=CreateFont(������,0,0,0,���,������,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  ������:=SelectObject(dc,�����);
  SetBkMode(dc,TRANSPARENT);
  DrawText(dc,"Strannik",lstrlen("Strannik"),������,0);
  SetBkMode(dc,OPAQUE);
  SelectObject(dc,������);
  DeleteObject(�����);
end;

function ��������������(wnd:HWND; msg,wparam,lparam:dword):boolean;
var dc:HDC; ���������:PAINTSTRUCT;
begin
  case msg of
    WM_CREATE:return(true);
    WM_PAINT:begin
      dc:=BeginPaint(wnd,���������);
      �������������(wnd,dc);
      EndPaint(wnd,���������);
    end;
    WM_DESTROY:begin PostQuitMessage(0); return(DefWindowProc(wnd,msg,wparam,lparam)) end;
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end;

var
  ���������:WNDCLASS;
  ����:HWND;
  ���������:MSG;

begin

// ����������� ������(class registration)
  with ��������� do begin
    RtlZeroMemory(addr(���������),sizeof(WNDCLASS));
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(��������������);
    hInstance:=INSTANCE;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:=className;
  end;
  RegisterClass(���������);
                     
// �������� ����(window create)
  ����:=CreateWindowEx(0,className,"Demo1_6",WS_OVERLAPPEDWINDOW,
    50,50,600,400, 0,0,INSTANCE,nil);

  ShowWindow(����,SW_SHOW);
  UpdateWindow(����);

//���� ��������� (message cycle)
  while GetMessage(���������,0,0,0) do begin
    TranslateMessage(���������);
    DispatchMessage(���������);
  end;

end.

