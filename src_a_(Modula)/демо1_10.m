// ��������  ������-��-������� ��� Win32
// ���������������� ���������
// ���� 10:������ (������)

module Demo1_10;
import Win32;

const 
  hINSTANCE=0x400000;
  className='Strannik';

  �����������=0x0000FF;
  ���������=0xFF0000;
  �����������=0x00FF00;

  ������=3;

//------------------------ ������ ------------------------------

type ������=record ()
    x,y:integer;
    ������X,������Y:integer;
    ����:cardinal;
    procedure ������������*(���_x,���_y:integer; ���_����:cardinal);
    procedure ��������X*():integer;
    procedure ��������Y*():integer;
    procedure ��������������X*():integer;
    procedure ��������������Y*():integer;
    procedure ������������*():integer;
    procedure �����������*(���_x,���_y:integer);
  end;

procedure (������) ������������(���_x,���_y:integer; ���_����:cardinal);
begin
  x:=���_x;
  y:=���_y;
  ������X:=���_x;
  ������Y:=���_y;
  ����:=���_����;
end ������������;

procedure (������) ��������X():integer; begin return x end ��������X;
procedure (������) ��������Y():integer; begin return y end ��������Y;
procedure (������) ��������������X():integer; begin return ������X end ��������������X;
procedure (������) ��������������Y():integer; begin return ������Y end ��������������Y;
procedure (������) ������������():integer; begin return ���� end ������������;

procedure (������) �����������(���_x,���_y:integer);
begin
  ������X:=x;
  ������Y:=y;
  inc(x,���_x);
  inc(y,���_y);
end �����������;

//------------------------ ������ ------------------------------

type ������=record (������)
    ������X,������Y:integer;
  end;

procedure (������) ������������������(���_x,���_y,���_������X,���_������Y:integer; ���_����:cardinal);
begin
  self.������������(���_x,���_y,���_����);
  ������X:=���_������X;
  ������Y:=���_������Y;
end ������������������;

procedure (������) ��������������X*():integer; begin return ������X end ��������������X;
procedure (������) ��������������Y*():integer; begin return ������Y end ��������������Y;

procedure (������) ����������(dc:HDC; ���:COLORREF);
var ����,������:HPEN; ���������,���X,���Y:integer; �����,������:HBRUSH;
begin
  if ���=0
    then ���������:=self.������������(); ���X:=self.��������X(); ���Y:=self.��������Y();
    else ���������:=���; ���X:=self.��������������X(); ���Y:=self.��������������Y();
  end;
  ����:=CreatePen(PS_SOLID,������,���������); ������:=SelectObject(dc,����);
  �����:=CreateSolidBrush(���������); ������:=SelectObject(dc,�����);
  Rectangle(dc,���X,���Y,���X+������X,���Y+������Y);
  SelectObject(dc,������); DeleteObject(����);
  SelectObject(dc,������); DeleteObject(�����);
end ����������;

//------------------------ ��� ------------------------------

type ���=record (������)
    �������:integer;
    ��������X,��������Y:integer;
  end;

procedure (���) ���������������(���_x,���_y,���_��������X,���_��������Y,���_�������:integer; ���_����:cardinal);
begin
  self.������������(���_x,���_y,���_����);
  �������:=���_�������;
  ��������X:=���_��������X;
  ��������Y:=���_��������Y;
end ���������������;

procedure (���) ����������(dc:HDC; ���:COLORREF);
var ����,������:HPEN; �����,������:HBRUSH; ��������,���X,���Y:integer;
begin
  if ���=0
    then ��������:=self.������������(); ���X:=self.��������X(); ���Y:=self.��������Y();
    else ��������:=���; ���X:=self.��������������X(); ���Y:=self.��������������Y();
  end;
  ����:=CreatePen(PS_SOLID,1,��������); ������:=SelectObject(dc,����);
  �����:=CreateSolidBrush(��������); ������:=SelectObject(dc,�����);
  Ellipse(dc,���X-������� div 2,���Y-������� div 2,���X+������� div 2,���Y+������� div 2);
  SelectObject(dc,������); DeleteObject(����);
  SelectObject(dc,������); DeleteObject(�����);
end ����������;

procedure (���) ��������������(wnd:HWND; �������,�����:������):boolean;
var ���X,���Y:integer;
begin
  ���X:=self.��������X();
  ���Y:=self.��������Y();
  inc(���X,��������X); //������������ ����
  inc(���Y,��������Y);
  if (���Y>�����.��������������Y())and(  //�������� �� ���� �� �������
    (���X<�������.��������X())or
    (���X>�������.��������X()+�������.��������������X())) then
    return true
  end;
  if ���X<0 then ���X:=-���X; ��������X:=-��������X end; //�������� �� ����� �� ������� ������
  if ���Y<0 then ���Y:=-���Y; ��������Y:=-��������Y end;
  if ���X>�����.��������������X() then ���X:=�����.��������������X()-(���X-�����.��������������X()); ��������X:=-��������X end;
  if ���Y>�����.��������������Y() then ���Y:=�����.��������������Y()-(���Y-�����.��������������Y()); ��������Y:=-��������Y end;
  if ���X<0 then ���X:=-���X; ��������X:=-��������X end; //��������� �������� �� ����� �� ������� ������
  if ���Y<0 then ���Y:=-���Y; ��������Y:=-��������Y end;
  if ���X>�����.��������������X() then ���X:=�����.��������������X()-(���X-�����.��������������X()); ��������X:=-��������X end;
  if ���Y>�����.��������������Y() then ���Y:=�����.��������������Y()-(���Y-�����.��������������Y()); ��������Y:=-��������Y end;
  self.�����������(���X-self.��������X(),���Y-self.��������Y());
  return false
end ��������������;

//------------------------ ��������� ------------------------------

var
  �����:���;
  �������,�����:������;
  ��������������:boolean;

procedure wndProc(wnd:HWND; msg,wparam,lparam:cardinal):boolean;
var dc:HDC; stru:PAINTSTRUCT; reg:RECT;
begin
  case msg of
    WM_CREATE:
      GetClientRect(wnd,reg);
      new(�����); �����.������������������(0,0,reg.right-1,reg.bottom-1,�����������);
      new(�������); �������.������������������(�����.��������������X() div 2,�����.��������������Y()-������,�����.��������������X() div 10,������,�����������);
      new(�����); �����.���������������(�����.��������������X() div 2,1,5,25,10,���������);
      ��������������:=false;
      SetTimer(wnd,1,100,nil);
      return true;|
    WM_PAINT:
      dc:=BeginPaint(wnd,stru);
      if not �������������� then
        �����.����������(dc,0);
        ��������������:=true
      end;
      �����.����������(dc,�����.����);
      �����.����������(dc,0);
      �������.����������(dc,�����.����);
      �������.����������(dc,0);
      EndPaint(wnd,stru);|
    WM_ERASEBKGND:return true;|
    WM_KEYDOWN:case loword(wparam) of
      VK_LEFT:
        if �������.��������X()>0 then
          �������.�����������(-�������.��������������X() div 2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd)
        end;|
      VK_RIGHT:
        if �������.��������X()+�������.��������������X()<�����.��������������X() then
          �������.�����������(�������.��������������X() div 2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd)
        end;|
    end;|
    WM_TIMER:
      if �����.��������������(wnd,�������,�����) then
        KillTimer(wnd,1);
        MessageBox(0,"�� ���������.","��������:",MB_ICONSTOP);
        DestroyWindow(wnd);
      end;
      InvalidateRect(wnd,nil,true);
      UpdateWindow(wnd);|
    WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam);|
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end wndProc;

var
  cla:WNDCLASS;
  wnd:HWND;
  message:MSG;

begin

//����������� ������
  with cla do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=className;
  end;
  RegisterClass(cla);
                     
//�������� ����
  wnd:=CreateWindowEx(0,className,'Demo1_10',WS_OVERLAPPEDWINDOW,
    100,100,500,400, 0,0,hINSTANCE,nil);

  ShowWindow(wnd,SW_SHOW);
  UpdateWindow(wnd);

//���� ���������
  while GetMessage(message,0,0,0) do
    TranslateMessage(message);
    DispatchMessage(message);
  end;

end Demo1_10.

