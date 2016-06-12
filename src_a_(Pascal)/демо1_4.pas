// СТРАННИК Модула-Си-Паскаль для Win32
// Демонстрационная программа
// Демо 4:Текстовый редактор
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

//================ системные процедуры =================

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

procedure messInt(цел:integer; комм:pstr);
var стр:pstr;
begin
  стр:=memAlloc(50);
  wvsprintf(стр,'%li',addr(цел));
  MessageBox(0,стр,комм,0);
  memFree(стр);
end;

//================= создание меню(create menu)=======================

procedure createMenu(окно:HWND);
var mainMenu,popupMenu:HMENU;
begin
  mainMenu:=CreateMenu();

  popupMenu:=CreatePopupMenu();
  AppendMenu(popupMenu,MF_STRING,menuNew,"New");
  AppendMenu(popupMenu,MF_STRING,menuOpen,"Open");
  AppendMenu(popupMenu,MF_STRING,menuSave,"Save");
  AppendMenu(mainMenu,MF_POPUP,popupMenu,"File");

  AppendMenu(mainMenu,MF_STRING,menuExit,"Exit");
  SetMenu(окно,mainMenu);
end;

//================ получить имя файла(Get file name)=================

function getFileName(файл:pstr; bitOpen:boolean):boolean;
var откр:OPENFILENAME; bitOk:boolean;
begin
  RtlZeroMemory(addr(откр),sizeof(OPENFILENAME));
  with откр do begin
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=512;
    lpstrFile:=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle:=512;
    lpstrFileTitle:=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]:='\0';
  end;
  if bitOpen
    then bitOk:=GetOpenFileName(откр)
    else bitOk:=GetSaveFileName(откр);
//  messInt(integer(bitOk),"bitOk");
//  messInt(CommDlgExtendedError(),"error");
  with откр do begin
    lstrcpyn(файл,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  end;
  return bitOk;
end;

//=============== загрузить файл(load file)======================

procedure LoadFile(имя:pstr);
var файл:HFILE; разм:dword; буф:pstr;
begin
  файл:=_lopen(имя,OF_READ);
  разм:=_llseek(файл,0,FILE_END);
  буф:=memAlloc(разм+1);
  _llseek(файл,0,FILE_BEGIN);
  _lread(файл,буф,разм);
  буф[разм]:='\0';
  _lclose(файл);
  SetWindowText(wndEdit,буф);
  SetWindowText(wndMain,имя);
  memFree(буф);
end;

//================= новый файл(new file)======================

procedure procNew();
begin
  SetWindowText(wndEdit,nil);
  SetWindowText(wndMain,nil);
end;

//================= открыть файл(open file)======================

procedure procOpen();
var имя:string[200];
begin
  if getFileName(имя,true) then begin
    LoadFile(имя)
  end;
  SetFocus(wndEdit);
end;

//================= сохранить файл(save file)======================

procedure procSave();
var имя:string[200]; файл:HFILE; буф:pstr; разм:dword; bitOk:boolean;
begin
  GetWindowText(wndMain,имя,200);
  bitOk:=true;
  if имя[0]='\0' then begin
    lstrcpy(имя,'*.txt');
    bitOk:=getFileName(имя,false);
    if bitOk then begin
      SetWindowText(wndMain,имя);
    end  
  end;
  if bitOk then begin
    разм:=GetWindowTextLength(wndEdit);
    буф:=memAlloc(разм+1);
    GetWindowText(wndEdit,буф,разм);
    файл:=_lcreat(имя,0);
    _lwrite(файл,буф,разм);
    _lclose(файл);
  end;
  SetFocus(wndEdit);
end;

//================= оконная функция(window function)======================

function wndProc(hWnd:HWND; msg,wParam,lParam:dword):boolean;
var рег:RECT;
begin
  case msg of
    WM_CREATE:;
    WM_DESTROY:begin PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam)) end;
    WM_SIZE:begin
      GetClientRect(wndMain,рег);
      MoveWindow(wndEdit,рег.left+5,рег.top+5,рег.right-рег.left-10,рег.bottom-рег.top-10,true);
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

//================= основная программа(main routine)====================

begin
// регистрация класса(class registration)
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
                     
// создание окна(window create)
  wndMain:=CreateWindowEx(0,className,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(wndMain,SW_SHOW);
  UpdateWindow(wndMain);

// создание окна(window create) редактора
  wndEdit:=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    wndMain,0,INSTANCE,nil);
  ShowWindow(wndEdit,SW_SHOW);
  UpdateWindow(wndEdit);
  SetFocus(wndEdit);

// создание меню(create menu)
  createMenu(wndMain);

//цикл сообщений (message cycle)
  while GetMessage(message,0,0,0) do begin
    TranslateMessage(message);
    DispatchMessage(message);
  end;
  ExitProcess(0);
end.

