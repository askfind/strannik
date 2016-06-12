// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 6:������������� GDI
include Win32

define INSTANCE 0x400000
define className "Strannik"

define ����������� 0x0000FF
define ��������� 0xFF0000
define ����������� 0x00FF00
define ������ 50
define ��� FW_NORMAL
define ������ 1

void �������������(HWND ����, HDC dc) {
HPEN ����,������; HBRUSH �����,������; HFONT �����,������; RECT ������;

//��������� �����
  SetPixel(dc,10,10,�����������);
//��������� �����
  MoveToEx(dc,20,20,nil);
  LineTo(dc,20,30);
  LineTo(dc,30,30);
//��������� ������� �����
  ����=CreatePen(PS_SOLID,10,�����������);
  ������=SelectObject(dc,����);
  MoveToEx(dc,40,40,nil);
  LineTo(dc,40,70);
  LineTo(dc,70,70);
  SelectObject(dc,������);
  DeleteObject(����);
//��������� ���� �������
  ����=CreatePen(PS_SOLID,5,���������);
  ������=SelectObject(dc,����);
  Arc(dc,0,0,200,100,110,100,110,0);
  SelectObject(dc,������);
  DeleteObject(����);
//��������� ��������������
  Rectangle(dc,100,150,200,200);
//��������� �������� ��������������
  ����=CreatePen(PS_SOLID,10,�����������);
  ������=SelectObject(dc,����);
  �����=CreateSolidBrush(�����������);
  ������=SelectObject(dc,�����);
  Rectangle(dc,300,150,400,200);
  SelectObject(dc,������);
  DeleteObject(����);
  SelectObject(dc,������);
  DeleteObject(�����);
//��������� �������
  Ellipse(dc,100,250,200,300);
//��������� �������� �������
  ����=CreatePen(PS_SOLID,10,�����������);
  ������=SelectObject(dc,����);
  �����=CreateSolidBrush(�����������);
  ������=SelectObject(dc,�����);
  Ellipse(dc,300,250,500,300);
  SelectObject(dc,������);
  DeleteObject(����);
  SelectObject(dc,������);
  DeleteObject(�����);
//����� ������
  with(������) {
    left=300;
    top=0;
    right=400;
    bottom=100;
  }
  DrawText(dc,"Strannik",lstrlen("Strannik"),������,0);
//����� ������ ��������� ������ � �������
  with(������) {
    left=300;
    top=20;
    right=500;
    bottom=80;
  }
  SetTextColor(dc,�����������);
  SetBkColor(dc,���������);
  �����=CreateFont(������,0,0,0,���,������,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  ������=SelectObject(dc,�����);
  DrawText(dc,"Strannik",lstrlen("Strannik"),������,0);
  SelectObject(dc,������);
  DeleteObject(�����);
//����� ����������� ������
  with(������) {
    left=300;
    top=80;
    right=500;
    bottom=120;
  }
  SetTextColor(dc,�����������);
  �����=CreateFont(������,0,0,0,���,������,0,0,
      ANSI_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY,DEFAULT_PITCH,"Arial Cyr");
  ������=SelectObject(dc,�����);
  SetBkMode(dc,TRANSPARENT);
  DrawText(dc,"Strannik",lstrlen("Strannik"),������,0);
  SetBkMode(dc,OPAQUE);
  SelectObject(dc,������);
  DeleteObject(�����);
} //�������������

bool ��������������(HWND wnd,uint msg,uint wparam,uint lparam) {
HDC dc; PAINTSTRUCT ���������;

  switch(msg) {
    case WM_CREATE:return true; break;
    case WM_PAINT:
      dc=BeginPaint(wnd,���������);
      �������������(wnd,dc);
      EndPaint(wnd,���������); break;
    case WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
} //��������������

WNDCLASS ���������;
HWND ����;
MSG ���������;

void main()
{
// ����������� ������(class registration)
  with(���������) {
    RtlZeroMemory(addr(���������),sizeof(WNDCLASS));
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=addr(��������������);
    hInstance=INSTANCE;
    hCursor=LoadCursor(0,(pchar)IDC_ARROW);
    hbrBackground=COLOR_WINDOW;
    lpszClassName=className;
  }
  RegisterClass(���������);
                     
// �������� ����(window create)
  ����=CreateWindowEx(0,className,"Demo1_6",WS_OVERLAPPEDWINDOW,
    50,50,600,400, 0,0,INSTANCE,nil);

  ShowWindow(����,SW_SHOW);
  UpdateWindow(����);

//���� ��������� (message cycle)
  while(GetMessage(���������,0,0,0)) {
    TranslateMessage(���������);
    DispatchMessage(���������);
  }

} //Demo1_6

