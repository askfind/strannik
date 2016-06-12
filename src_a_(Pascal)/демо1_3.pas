// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 3:��������� � ����
program Demo1_3;
uses Win32;

const 
  hINSTANCE=0x400000;
  className='Strannik';

  menuNew=100;
  menuOpen=101;
  menuSave=102;
  menuExit=200;

var
  ��������:WNDCLASS;
  �������:HWND;
  message:MSG;

//================= �������� ����(create menu)=======================

procedure createMenu(����:HWND);
var mainMenu,popupMenu:HMENU;
begin
  mainMenu:=CreateMenu();

  popupMenu:=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING|MF_ENABLED,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP|MF_ENABLED,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING|MF_ENABLED,menuExit,"Exit");
  SetMenu(����,mainMenu);
end;

//================= ������� �������(window function)======================

function wndProc(hWnd:HWND; msg,wParam,lParam:dword):boolean;
begin
  case msg of
    WM_CREATE:return true;
    WM_DESTROY:begin PostQuitMessage(0); return DefWindowProc(hWnd,msg,wParam,lParam) end;
    WM_COMMAND:case word(wParam) of
      menuNew:MessageBox(0,"New","����:",0);
      menuOpen:MessageBox(0,"Open","����:",0);
      menuSave:MessageBox(0,"Save","����:",0);
      menuExit:MessageBox(0,"Exit","����:",0);
    end;
    else return DefWindowProc(hWnd,msg,wParam,lParam)
  end
end;

//================= �������� ���������(main routine)====================

begin

// ����������� ������(class registration)
  with �������� do begin
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
  RegisterClass(��������);
                     
// �������� ����(window create)
  �������:=CreateWindowEx(0,className,"Demo1_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);

// �������� ����(create menu)
  createMenu(�������);

//���� ��������� (message cycle)
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;

end.

