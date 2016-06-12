// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 4:Text editor
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

//================ system function =================

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

procedure messInt(id1:integer; id2:pstr);
var id3:pstr;
begin
  id3:=memAlloc(50);
  wvsprintf(id3,'%li',addr(id1));
  MessageBox(0,id3,id2,0);
  memFree(id3);
end;

//================= create menu =======================

procedure createMenu(id4:HWND);
var mainMenu,popupMenu:HMENU;
begin
  mainMenu:=CreateMenu();

  popupMenu:=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING,menuExit,"Exit");
  SetMenu(id4,mainMenu);
end;

//================ get file name =================

function getFileName(id5:pstr; bitOpen:boolean):boolean;
var id6:OPENFILENAME; bitOk:boolean;
begin
  RtlZeroMemory(addr(id6),sizeof(OPENFILENAME));
  with id6 do begin
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=512;
    lpstrFile:=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle:=512;
    lpstrFileTitle:=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]:='\0';
  end;
  if bitOpen
    then bitOk:=GetOpenFileName(id6)
    else bitOk:=GetSaveFileName(id6);
  with id6 do begin
    lstrcpyn(id5,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  end;
  return bitOk;
end;

//=============== load file ======================

procedure LoadFile(id7:pstr);
var id5:HFILE; id8:dword; id9:pstr;
begin
  id5:=_lopen(id7,OF_READ);
  id8:=_llseek(id5,0,FILE_END);
  id9:=memAlloc(id8+1);
  _llseek(id5,0,FILE_BEGIN);
  _lread(id5,id9,id8);
  id9[id8]:='\0';
  _lclose(id5);
  SetWindowText(wndEdit,id9);
  SetWindowText(wndMain,id7);
  memFree(id9);
end;

//================= new file ======================

procedure procNew();
begin
  SetWindowText(wndEdit,nil);
  SetWindowText(wndMain,nil);
end;

//================= open file ======================

procedure procOpen();
var id7:string[200];
begin
  if getFileName(id7,true) then begin
    LoadFile(id7)
  end;
  SetFocus(wndEdit);
end;

//================= save file ======================

procedure procSave();
var id7:string[200]; id5:HFILE; id9:pstr; id8:dword; bitOk:boolean;
begin
  GetWindowText(wndMain,id7,200);
  bitOk:=true;
  if id7[0]='\0' then begin
    lstrcpy(id7,'*.txt');
    bitOk:=getFileName(id7,false);
    if bitOk then begin
      SetWindowText(wndMain,id7);
    end  
  end;
  if bitOk then begin
    id8:=GetWindowTextLength(wndEdit);
    id9:=memAlloc(id8+1);
    GetWindowText(wndEdit,id9,id8);
    id5:=_lcreat(id7,0);
    _lwrite(id5,id9,id8);
    _lclose(id5);
  end;
  SetFocus(wndEdit);
end;

//================= window function ======================

function wndProc(hWnd:HWND; msg,wParam,lParam:dword):boolean;
var id10:RECT;
begin
  case msg of
    WM_CREATE:;
    WM_DESTROY:begin PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)) end;
    WM_SIZE:begin
      GetClientRect(wndMain,id10);
      MoveWindow(wndEdit,id10.left+5,id10.top+5,id10.right-id10.left-10,id10.bottom-id10.top-10,true);
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

//================= main ====================

begin
//class registration
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
                     
//window create
  wndMain:=CreateWindowEx(0,className,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(wndMain,SW_SHOW);
  UpdateWindow(wndMain);

//editor window create
  wndEdit:=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    wndMain,0,INSTANCE,nil);
  ShowWindow(wndEdit,SW_SHOW);
  UpdateWindow(wndEdit);
  SetFocus(wndEdit);

//menu create
  createMenu(wndMain);

//messages loop
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;
  ExitProcess(0);
end.

