// ��������  ������-��-������� ��� Win32
// ���������������� ���������
// ���� 10:������ (������)

include Win32

define hINSTANCE 0x400000
define className 'Strannik'

define ����������� 0x0000FF
define ��������� 0xFF0000
define ����������� 0x00FF00

define ������ 3

//------------------------ ������ ------------------------------

class ������ {
private:
  int x,y;
  int ������X,������Y;
  uint ����;
public:
  void ������������(int ���_x, int ���_y, uint ���_����);
  int ��������X();
  int ��������Y();
  int ��������������X();
  int ��������������Y();
  int ������������();
  void �����������(int ���_x, int ���_y);
}

void ������::������������(int ���_x, int ���_y, uint ���_����)
{
  x=���_x;
  y=���_y;
  ������X=���_x;
  ������Y=���_y;
  ����=���_����;
}

int ������::��������X() {return x;}
int ������::��������Y() {return y;}
int ������::��������������X() {return ������X;}
int ������::��������������Y() {return ������Y;}
int ������::������������() {return ����;}

void ������::�����������(int ���_x, int ���_y)
{
  ������X=x;
  ������Y=y;
  x+=���_x;
  y+=���_y;
}

//------------------------ ������ ------------------------------

class ������:������ {
private:
  int ������X,������Y;
public:
  void ������������������(int ���_x,int ���_y,int ���_������X,int ���_������Y,uint ���_����);
  int ��������������X();
  int ��������������Y();
  virtual void ����������(HDC dc, COLORREF ���);
}

void ������::������������������(int ���_x,int ���_y,int ���_������X,int ���_������Y,uint ���_����)
{
  this.������������(���_x,���_y,���_����);
  ������X=���_������X;
  ������Y=���_������Y;
}

int ������::��������������X() {return ������X;}
int ������::��������������Y() {return ������Y;}

void ������::����������(HDC dc, COLORREF ���)
{
HPEN ����,������; int ���������,���X,���Y; HBRUSH �����,������;

  if(���==0) {���������=this.������������(); ���X=this.��������X(); ���Y=this.��������Y();}
  else {���������=���; ���X=this.��������������X(); ���Y=this.��������������Y();}
  ����=CreatePen(PS_SOLID,������,���������); ������=SelectObject(dc,����);
  �����=CreateSolidBrush(���������); ������=SelectObject(dc,�����);
  Rectangle(dc,���X,���Y,���X+������X,���Y+������Y);
  SelectObject(dc,������); DeleteObject(����);
  SelectObject(dc,������); DeleteObject(�����);
}

//------------------------ ��� ------------------------------

class ���:������ {
private:
  int �������;
  int ��������X,��������Y;
public:
  void ���������������(int ���_x,int ���_y,int ���_��������X,int ���_��������Y,int ���_�������,uint ���_����);
  virtual void ����������(HDC dc, COLORREF ���);
  bool ��������������(HWND wnd, ������ �������,������ �����);
}

void ���::���������������(int ���_x,int ���_y,int ���_��������X,int ���_��������Y,int ���_�������,uint ���_����)
{
  this.������������(���_x,���_y,���_����);
  �������=���_�������;
  ��������X=���_��������X;
  ��������Y=���_��������Y;
}

void ���::����������(HDC dc, COLORREF ���)
{
HPEN ����,������; HBRUSH �����,������; int ��������,���X,���Y;

  if(���==0) {��������=this.������������(); ���X=this.��������X(); ���Y=this.��������Y();}
  else {��������=���; ���X=this.��������������X(); ���Y=this.��������������Y();}
  ����=CreatePen(PS_SOLID,1,��������); ������=SelectObject(dc,����);
  �����=CreateSolidBrush(��������); ������=SelectObject(dc,�����);
  Ellipse(dc,���X-�������/2,���Y-�������/2,���X+�������/2,���Y+�������/2);
  SelectObject(dc,������); DeleteObject(����);
  SelectObject(dc,������); DeleteObject(�����);
}

bool ���::��������������(HWND wnd, ������ �������,������ �����)
{
int ���X,���Y;

  ���X=this.��������X();
  ���Y=this.��������Y();
  ���X+=��������X; //������������ ����
  ���Y+=��������Y;
  if((���Y>�����.��������������Y())&&(  //�������� �� ���� �� �������
    (���X<�������.��������X())||
    (���X>�������.��������X()+�������.��������������X())))
    return true;
  if(���X<0) {���X=-���X; ��������X=-��������X;} //�������� �� ����� �� ������� ������
  if(���Y<0) {���Y=-���Y; ��������Y=-��������Y;}
  if(���X>�����.��������������X()) {���X=�����.��������������X()-(���X-�����.��������������X()); ��������X=-��������X;}
  if(���Y>�����.��������������Y()) {���Y=�����.��������������Y()-(���Y-�����.��������������Y()); ��������Y=-��������Y;}
  if(���X<0) {���X=-���X; ��������X=-��������X;} //��������� �������� �� ����� �� ������� ������
  if(���Y<0) {���Y=-���Y; ��������Y=-��������Y;}
  if(���X>�����.��������������X()) {���X=�����.��������������X()-(���X-�����.��������������X()); ��������X=-��������X;}
  if(���Y>�����.��������������Y()) {���Y=�����.��������������Y()-(���Y-�����.��������������Y()); ��������Y=-��������Y;}
  this.�����������(���X-this.��������X(),���Y-this.��������Y());
  return false;
}

//------------------------ ��������� ------------------------------

  ��� �����;
  ������ �������,�����;
  bool ��������������;

bool wndProc(HWND wnd,uint msg,uint wparam,uint lparam)
{
HDC dc; PAINTSTRUCT stru; RECT reg;

  switch(msg) {
    case WM_CREATE:
      GetClientRect(wnd,reg);
      �����=new ������; �����.������������������(0,0,reg.right-1,reg.bottom-1,�����������);
      �������=new ������; �������.������������������(�����.��������������X()/2,�����.��������������Y()-������,�����.��������������X()/10,������,�����������);
      �����=new ���; �����.���������������(�����.��������������X()/2,1,5,25,10,���������);
      ��������������=false;
      SetTimer(wnd,1,100,NULL);
      return true;
      break;
    case WM_PAINT:
      dc=BeginPaint(wnd,stru);
      if(!��������������) {
        �����.����������(dc,0);
        ��������������=true;
      }
      �����.����������(dc,�����.����);
      �����.����������(dc,0);
      �������.����������(dc,�����.����);
      �������.����������(dc,0);
      EndPaint(wnd,stru);
      break;
    case WM_ERASEBKGND:return true; break;
    case WM_KEYDOWN:switch(loword(wparam)) {
      case VK_LEFT:
        if(�������.��������X()>0) {
          �������.�����������(-�������.��������������X()/2,0);
          InvalidateRect(wnd,NULL,true);
          UpdateWindow(wnd);
        }
        break;
      case VK_RIGHT:
        if(�������.��������X()+�������.��������������X()<�����.��������������X()) {
          �������.�����������(�������.��������������X()/2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd);
        }
        break;
      }
      break;
    case WM_TIMER:
      if(�����.��������������(wnd,�������,�����)) {
        KillTimer(wnd,1);
        MessageBox(0,"�� ���������.","��������:",MB_ICONSTOP);
        DestroyWindow(wnd);
      }
      InvalidateRect(wnd,NULL,true);
      UpdateWindow(wnd);
      break;
    case WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

  WNDCLASS cla;
  HWND wnd;
  MSG message;

void main()
{
//����������� ������
  with(cla) {
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=&wndProc;
    cbClsExtra=0;
    cbWndExtra=0;
    hInstance=hINSTANCE;    
    hIcon=0;
    hCursor=LoadCursor(0,pchar(IDC_ARROW));
    hbrBackground=COLOR_WINDOW;
    lpszMenuName=NULL;
    lpszClassName=className;
  }
  RegisterClass(cla);
                     
//�������� ����
  wnd=CreateWindowEx(0,className,'Demo1_10',WS_OVERLAPPEDWINDOW,
    100,100,500,400, 0,0,hINSTANCE,NULL);

  ShowWindow(wnd,SW_SHOW);
  UpdateWindow(wnd);

//���� ���������
  while(GetMessage(message,0,0,0)) {
    TranslateMessage(message);
    DispatchMessage(message);
  }

}

