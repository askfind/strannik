// ��������  ������-��-������� ��� Win32
// ���������������� ���������
// ���� 4:��������� ��������
module Demo1_4;
import Win32;

const 
  INSTANCE=0x400000;
  ���������="Strannik";

  ���������=100;
  �����������=101;
  �������������=102;
  ���������=200;

var
  ���������:WNDCLASS;
  ��������:HWND;
  �������:HWND;
  �����:MSG;

//================ ��������� ��������� =================

procedure memAlloc(len:cardinal):address;
var h:HANDLE;
begin
    h:=GlobalAlloc(GMEM_FIXED,len);
    return(GlobalLock(h));
end memAlloc;

procedure memFree(p:address);
var h:HANDLE;
begin
  h:=GlobalHandle(p);
  GlobalFree(h);
end memFree;

procedure ��������(���:integer; ����:pstr);
var ���:pstr;
begin
  ���:=memAlloc(50);
  wvsprintf(���,'%li',addr(���));
  MessageBox(0,���,����,0);
  memFree(���);
end ��������;

//================= �������� ���� =======================

procedure ��������(����:HWND);
var �������,��������:HMENU;
begin
  �������:=CreateMenu();

  ��������:=CreatePopupMenu();
  AppendMenu(��������,MF_STRING,���������,"�����");
  AppendMenu(��������,MF_STRING,�����������,"�������");
  AppendMenu(��������,MF_STRING,�������������,"���������");
  AppendMenu(�������,MF_POPUP,��������,"����");

  AppendMenu(�������,MF_STRING,���������,"�����");
  SetMenu(����,�������);
end ��������;

//================ �������� ��� ����� =================

procedure �������������(����:pstr; �������:boolean):boolean;
var ����:OPENFILENAME; �����:boolean;
begin
  RtlZeroMemory(addr(����),sizeof(OPENFILENAME));
  with ���� do
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=512;
    lpstrFile:=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle:=512;
    lpstrFileTitle:=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]:='\0';
  end;
  if �������
    then �����:=GetOpenFileName(����)
    else �����:=GetSaveFileName(����)
  end;
//  ��������(integer(�����),"�����");
//  ��������(CommDlgExtendedError(),"error");
  with ���� do
    lstrcpyn(����,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  end;
  return(�����);
end �������������;

//=============== ��������� ���� ======================

procedure ��������(���:pstr);
var ����:HFILE; ����:cardinal; ���:pstr;
begin
  ����:=_lopen(���,OF_READ);
  ����:=_llseek(����,0,FILE_END);
  ���:=memAlloc(����+1);
  _llseek(����,0,FILE_BEGIN);
  _lread(����,���,����);
  ���[����]:='\0';
  _lclose(����);
  SetWindowText(�������,���);  
  SetWindowText(��������,���);
  memFree(���);
end ��������;

//================= ����� ���� ======================

procedure ���������();
begin
  SetWindowText(�������,nil);
  SetWindowText(��������,nil);
end ���������;

//================= ������� ���� ======================

procedure �����������();
var ���:string[200];
begin
  if �������������(���,true) then
    ��������(���)
  end;
  SetFocus(�������);
end �����������;

//================= ��������� ���� ======================

procedure �������������();
var ���:string[200]; ����:HFILE; ���:pstr; ����:cardinal; �����:boolean;
begin
  GetWindowText(��������,���,200);
  �����:=true;
  if ���[0]='\0' then
    lstrcpy(���,'*.txt');
    �����:=�������������(���,false);
    if ����� then
      SetWindowText(��������,���);
    end  
  end;
  if ����� then
    ����:=GetWindowTextLength(�������);
    ���:=memAlloc(����+1);
    GetWindowText(�������,���,����);
    ����:=_lcreat(���,0);
    _lwrite(����,���,����);
    _lclose(����);
  end;
  SetFocus(�������);
end �������������;

//================= ������� ������� ======================

procedure ��������(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
var ���:RECT;
begin
  case msg of
    WM_CREATE:|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam));|
    WM_SIZE:
      GetClientRect(��������,���);
      MoveWindow(�������,���.left+5,���.top+5,���.right-���.left-10,���.bottom-���.top-10,true);|
    WM_COMMAND:case loword(wParam) of
      ���������:���������();|
      �����������:�����������();|
      �������������:�������������();|
      ���������:DestroyWindow(��������);|
    end;|
    else return(DefWindowProc(hWnd,msg,wParam,lParam));
  end;
  return(true)
end ��������;

//================= �������� ��������� ====================

begin
//����������� ������
  with ��������� do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(��������);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=INSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=���������;
  end;
  RegisterClass(���������);
                     
//�������� ����
  ��������:=CreateWindowEx(0,���������,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(��������,SW_SHOW);
  UpdateWindow(��������);

//�������� ���� ���������
  �������:=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    ��������,0,INSTANCE,nil);
  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);
  SetFocus(�������);

//�������� ����
  ��������(��������);

//���� ���������
  while GetMessage(�����,0,0,0) do
    TranslateMessage(�����);
    DispatchMessage(�����);
  end;
  ExitProcess(0);
end Demo1_4.

