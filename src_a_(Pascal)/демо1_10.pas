// ��������  ������-��-������� ��� Win32
// ���������������� ���������
// ���� 10:������ (������)

program Demo1_10;
uses Win32;

const 
  hINSTANCE=0x400000;
  className='Strannik';

  �����������=0x0000FF;
  ���������=0xFF0000;
  �����������=0x00FF00;

  ������=3;

//------------------------ ������ ------------------------------

type ������=object
  private
    x,y:integer;
    ������X,������Y:integer;
    ����:dword;
  public
    procedure ������������(���_x,���_y:integer; ���_����:dword);
    function ��������X:integer;
    function ��������Y:integer;
    function ��������������X:integer;
    function ��������������Y:integer;
    function ������������:integer;
    procedure �����������(���_x,���_y:integer);
  end;

procedure ������.������������(���_x,���_y:integer; ���_����:dword);
begin
  x:=���_x;
  y:=���_y;
  ������X:=���_x;
  ������Y:=���_y;
  ����:=���_����;
end;

function ������.��������X:integer; begin return x end;
function ������.��������Y:integer; begin return y end;
function ������.��������������X:integer; begin return ������X end;
function ������.��������������Y:integer; begin return ������Y end;
function ������.������������:integer; begin return ���� end;

procedure ������.�����������(���_x,���_y:integer);
begin
  ������X:=x;
  ������Y:=y;
  inc(x,���_x);
  inc(y,���_y);
end;

//------------------------ ������ ------------------------------

type ������=object (������)
    ������X,������Y:integer;
  end;

procedure ������.������������������(���_x,���_y,���_������X,���_������Y:integer; ���_����:dword);
begin
  self.������������(���_x,���_y,���_����);
  ������X:=���_������X;
  ������Y:=���_������Y;
end;

function ������.��������������X:integer; begin return ������X end;
function ������.��������������Y:integer; begin return ������Y end;

procedure ������.����������(dc:HDC; ���:COLORREF);
var ����,������:HPEN; ���������,���X,���Y:integer; �����,������:HBRUSH;
begin
  if ���=0
    then begin ���������:=self.������������; ���X:=self.��������X; ���Y:=self.��������Y end
    else begin ���������:=���; ���X:=self.��������������X; ���Y:=self.��������������Y end;
  ����:=CreatePen(PS_SOLID,������,���������); ������:=SelectObject(dc,����);
  �����:=CreateSolidBrush(���������); ������:=SelectObject(dc,�����);
  Rectangle(dc,���X,���Y,���X+������X,���Y+������Y);
  SelectObject(dc,������); DeleteObject(����);
  SelectObject(dc,������); DeleteObject(�����);
end;

//------------------------ ��� ------------------------------

type ���=object (������)
    �������:integer;
    ��������X,��������Y:integer;
  end;

procedure ���.���������������(���_x,���_y,���_��������X,���_��������Y,���_�������:integer; ���_����:dword);
begin
  self.������������(���_x,���_y,���_����);
  �������:=���_�������;
  ��������X:=���_��������X;
  ��������Y:=���_��������Y;
end;

procedure ���.����������(dc:HDC; ���:COLORREF);
var ����,������:HPEN; �����,������:HBRUSH; ��������,���X,���Y:integer;
begin
  if ���=0
    then begin ��������:=self.������������; ���X:=self.��������X; ���Y:=self.��������Y end
    else begin ��������:=���; ���X:=self.��������������X; ���Y:=self.��������������Y end;
  ����:=CreatePen(PS_SOLID,1,��������); ������:=SelectObject(dc,����);
  �����:=CreateSolidBrush(��������); ������:=SelectObject(dc,�����);
  Ellipse(dc,���X-������� div 2,���Y-������� div 2,���X+������� div 2,���Y+������� div 2);
  SelectObject(dc,������); DeleteObject(����);
  SelectObject(dc,������); DeleteObject(�����);
end;

function ���.��������������(wnd:HWND; �������,�����:������):boolean;
var ���X,���Y:integer;
begin
  ���X:=self.��������X;
  ���Y:=self.��������Y;
  inc(���X,��������X); //������������ ����
  inc(���Y,��������Y);
  if (���Y>�����.��������������Y)and( //�������� �� ���� �� �������
    (���X<�������.��������X)or
    (���X>�������.��������X+�������.��������������X)) then
    return true;
  if ���X<0 then begin ���X:=-���X; ��������X:=-��������X end; //�������� �� ����� �� ������� ������
  if ���Y<0 then begin ���Y:=-���Y; ��������Y:=-��������Y end;
  if ���X>�����.��������������X then begin ���X:=�����.��������������X-(���X-�����.��������������X); ��������X:=-��������X end;
  if ���Y>�����.��������������Y then begin ���Y:=�����.��������������Y-(���Y-�����.��������������Y); ��������Y:=-��������Y end;
  if ���X<0 then begin ���X:=-���X; ��������X:=-��������X end; //��������� �������� �� ����� �� ������� ������
  if ���Y<0 then begin ���Y:=-���Y; ��������Y:=-��������Y end;
  if ���X>�����.��������������X then begin ���X:=�����.��������������X-(���X-�����.��������������X); ��������X:=-��������X end;
  if ���Y>�����.��������������Y then begin ���Y:=�����.��������������Y-(���Y-�����.��������������Y); ��������Y:=-��������Y end;
  self.�����������(���X-self.��������X,���Y-self.��������Y);
  return false
end;

//------------------------ ��������� ------------------------------

var
  �����:���;
  �������,�����:������;
  ��������������:boolean;

function wndProc(wnd:HWND; msg,wparam,lparam:dword):boolean;
var dc:HDC; stru:PAINTSTRUCT; reg:RECT;
begin
  case msg of
    WM_CREATE:begin
      GetClientRect(wnd,reg);
      new(�����); �����.������������������(0,0,reg.right-1,reg.bottom-1,�����������);
      new(�������); �������.������������������(�����.��������������X div 2,�����.��������������Y-������,�����.��������������X div 10,������,�����������);
      new(�����); �����.���������������(�����.��������������X div 2,1,5,25,10,���������);
      ��������������:=false;
      SetTimer(wnd,1,100,nil);
      return true;
    end;
    WM_PAINT:begin
      dc:=BeginPaint(wnd,stru);
      if not �������������� then begin
        �����.����������(dc,0);
        ��������������:=true
      end;
      �����.����������(dc,�����.����);
      �����.����������(dc,0);
      �������.����������(dc,�����.����);
      �������.����������(dc,0);
      EndPaint(wnd,stru);
    end;
    WM_ERASEBKGND:return true;
    WM_KEYDOWN:case loword(wparam) of
      VK_LEFT:if �������.��������X>0 then begin
        �������.�����������(-�������.��������������X div 2,0);
        InvalidateRect(wnd,nil,true);
        UpdateWindow(wnd)
      end;
      VK_RIGHT:begin
        if �������.��������X+�������.��������������X<�����.��������������X then begin
          �������.�����������(�������.��������������X div 2,0);
          InvalidateRect(wnd,nil,true);
          UpdateWindow(wnd)
        end;
      end;
    end;
    WM_TIMER:begin
      if �����.��������������(wnd,�������,�����) then begin
        KillTimer(wnd,1);
        MessageBox(0,"�� ���������.","��������:",MB_ICONSTOP);
        DestroyWindow(wnd);
      end;
      InvalidateRect(wnd,nil,true);
      UpdateWindow(wnd);
    end;
    WM_DESTROY:begin PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam) end;
  else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end;

var
  cla:WNDCLASS;
  wnd:HWND;
  message:MSG;

begin

//����������� ������
  with cla do begin
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
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;

end.

