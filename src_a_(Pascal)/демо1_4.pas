// �������� ������-��-������� ��� Win32
// ���������������� ���������
// ���� 4:��������� ��������
program Demo1_4;
uses Win32;

const 
  INSTANCE=0x400000;
  className="Strannik";

  menuNew=100;
  menuOpen=101;
  menuSave=102;
  menuExit=200;

var
  classMain:WNDCLASS;
  wndMain:HWND;
  wndEdit:HWND;
  message:MSG;

//================ ��������� ��������� =================

function memAlloc(len:dword):address;
var h:HANDLE;
begin
    h:=GlobalAlloc(GMEM_FIXED,len);
    return GlobalLock(h);
end;

procedure memFree(p:address);
var h:HANDLE;
begin
  h:=GlobalHandle(p);
  GlobalFree(h);
end;

procedure messInt(���:integer; ����:pstr);
var ���:pstr;
begin
  ���:=memAlloc(50);
  wvsprintf(���,'%li',addr(���));
  MessageBox(0,���,����,0);
  memFree(���);
end;

//================= �������� ����(create menu)=======================

procedure createMenu(����:HWND);
var mainMenu,popupMenu:HMENU;
begin
  mainMenu:=CreateMenu();

  popupMenu:=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING,menuExit,"Exit");
  SetMenu(����,mainMenu);
end;

//================ �������� ��� �����(Get file name)=================

function getFileName(����:pstr; bitOpen:boolean):boolean;
var ����:OPENFILENAME; bitOk:boolean;
begin
  RtlZeroMemory(addr(����),sizeof(OPENFILENAME));
  with ���� do begin
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=512;
    lpstrFile:=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle:=512;
    lpstrFileTitle:=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]:='\0';
  end;
  if bitOpen
    then bitOk:=GetOpenFileName(����)
    else bitOk:=GetSaveFileName(����);
//  messInt(integer(bitOk),"bitOk");
//  messInt(CommDlgExtendedError(),"error");
  with ���� do begin
    lstrcpyn(����,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  end;
  return bitOk;
end;

//=============== ��������� ����(load file)======================

procedure LoadFile(���:pstr);
var ����:HFILE; ����:dword; ���:pstr;
begin
  ����:=_lopen(���,OF_READ);
  ����:=_llseek(����,0,FILE_END);
  ���:=memAlloc(����+1);
  _llseek(����,0,FILE_BEGIN);
  _lread(����,���,����);
  ���[����]:='\0';
  _lclose(����);
  SetWindowText(wndEdit,���);
  SetWindowText(wndMain,���);
  memFree(���);
end;

//================= ����� ����(new file)======================

procedure procNew();
begin
  SetWindowText(wndEdit,nil);
  SetWindowText(wndMain,nil);
end;

//================= ������� ����(open file)======================

procedure procOpen();
var ���:string[200];
begin
  if getFileName(���,true) then begin
    LoadFile(���)
  end;
  SetFocus(wndEdit);
end;

//================= ��������� ����(save file)======================

procedure procSave();
var ���:string[200]; ����:HFILE; ���:pstr; ����:dword; bitOk:boolean;
begin
  GetWindowText(wndMain,���,200);
  bitOk:=true;
  if ���[0]='\0' then begin
    lstrcpy(���,'*.txt');
    bitOk:=getFileName(���,false);
    if bitOk then begin
      SetWindowText(wndMain,���);
    end  
  end;
  if bitOk then begin
    ����:=GetWindowTextLength(wndEdit);
    ���:=memAlloc(����+1);
    GetWindowText(wndEdit,���,����);
    ����:=_lcreat(���,0);
    _lwrite(����,���,����);
    _lclose(����);
  end;
  SetFocus(wndEdit);
end;

//================= ������� �������(window function)======================

function wndProc(hWnd:HWND; msg,wParam,lParam:dword):boolean;
var ���:RECT;
begin
  case msg of
    WM_CREATE:;
    WM_DESTROY:begin PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)) end;
    WM_SIZE:begin
      GetClientRect(wndMain,���);
      MoveWindow(wndEdit,���.left+5,���.top+5,���.right-���.left-10,���.bottom-���.top-10,true);
    end;
    WM_COMMAND:case loword(wParam) of
      menuNew:procNew();
      menuOpen:procOpen();
      menuSave:procSave();
      menuExit:DestroyWindow(wndMain);
    end;
    else return DefWindowProc(hWnd,msg,wParam,lParam)
  end;
  return true
end;

//================= �������� ���������(main routine)====================

begin
// ����������� ������(class registration)
  with classMain do begin
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=INSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=className;
  end;
  RegisterClass(classMain);
                     
// �������� ����(window create)
  wndMain:=CreateWindowEx(0,className,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(wndMain,SW_SHOW);
  UpdateWindow(wndMain);

// �������� ����(window create) ���������
  wndEdit:=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    wndMain,0,INSTANCE,nil);
  ShowWindow(wndEdit,SW_SHOW);
  UpdateWindow(wndEdit);
  SetFocus(wndEdit);

// �������� ����(create menu)
  createMenu(wndMain);

//���� ��������� (message cycle)
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;
  ExitProcess(0);
end.

