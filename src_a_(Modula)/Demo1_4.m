// STRANNIK Modula-C-Pascal for Win32
// Demo program
// Demo 4:Text editor
module Demo1_4;
import Win32;

const 
  INSTANCE=0x400000;
  id1="Strannik";

  id2=100;
  id3=101;
  id4=102;
  id5=200;

var
  id6:WNDCLASS;
  id7:HWND;
  id8:HWND;
  id9:MSG;

//================ system function =================

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

procedure id10(id11:integer; id12:pstr);
var id13:pstr;
begin
  id13:=memAlloc(50);
  wvsprintf(id13,'%li',addr(id11));
  MessageBox(0,id13,id12,0);
  memFree(id13);
end id10;

//================= create menu =======================

procedure id14(id15:HWND);
var id16,id17:HMENU;
begin
  id16:=CreateMenu();

  id17:=CreatePopupMenu();
  AppendMenu(id17,MF_STRING,id2,"New");
  AppendMenu(id17,MF_STRING,id3,"Open");
  AppendMenu(id17,MF_STRING,id4,"Save");
  AppendMenu(id16,MF_POPUP,id17,"File");

  AppendMenu(id16,MF_STRING,id5,"Exit");
  SetMenu(id15,id16);
end id14;

//================ get file name =================

procedure id18(id19:pstr; id20:boolean):boolean;
var id21:OPENFILENAME; id22:boolean;
begin
  RtlZeroMemory(addr(id21),sizeof(OPENFILENAME));
  with id21 do
    lStructSize:=sizeof(OPENFILENAME);
    nMaxFile:=512;
    lpstrFile:=memAlloc(nMaxFile); 
    lstrcpy(lpstrFile,"*.txt");
    nMaxFileTitle:=512;
    lpstrFileTitle:=memAlloc(nMaxFileTitle); 
    lpstrFileTitle[0]:='\0';
  end;
  if id20
    then id22:=GetOpenFileName(id21)
    else id22:=GetSaveFileName(id21)
  end;
  with id21 do
    lstrcpyn(id19,lpstrFile,200);
    memFree(lpstrFile); 
    memFree(lpstrFileTitle); 
  end;
  return(id22);
end id18;

//=============== load file ======================

procedure id23(id24:pstr);
var id19:HFILE; id25:cardinal; id26:pstr;
begin
  id19:=_lopen(id24,OF_READ);
  id25:=_llseek(id19,0,FILE_END);
  id26:=memAlloc(id25+1);
  _llseek(id19,0,FILE_BEGIN);
  _lread(id19,id26,id25);
  id26[id25]:='\0';
  _lclose(id19);
  SetWindowText(id8,id26);  
  SetWindowText(id7,id24);
  memFree(id26);
end id23;

//================= new file ======================

procedure id27();
begin
  SetWindowText(id8,nil);
  SetWindowText(id7,nil);
end id27;

//================= open file ======================

procedure id28();
var id24:string[200];
begin
  if id18(id24,true) then
    id23(id24)
  end;
  SetFocus(id8);
end id28;

//================= save file ======================

procedure id29();
var id24:string[200]; id19:HFILE; id26:pstr; id25:cardinal; id22:boolean;
begin
  GetWindowText(id7,id24,200);
  id22:=true;
  if id24[0]='\0' then
    lstrcpy(id24,'*.txt');
    id22:=id18(id24,false);
    if id22 then
      SetWindowText(id7,id24);
    end  
  end;
  if id22 then
    id25:=GetWindowTextLength(id8);
    id26:=memAlloc(id25+1);
    GetWindowText(id8,id26,id25);
    id19:=_lcreat(id24,0);
    _lwrite(id19,id26,id25);
    _lclose(id19);
  end;
  SetFocus(id8);
end id29;

//================= window function ======================

procedure id30(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
var id31:RECT;
begin
  case msg of
    WM_CREATE:|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam));|
    WM_SIZE:
      GetClientRect(id7,id31);
      MoveWindow(id8,id31.left+5,id31.top+5,id31.right-id31.left-10,id31.bottom-id31.top-10,true);|
    WM_COMMAND:case loword(wParam) of
      id2:id27();|
      id3:id28();|
      id4:id29();|
      id5:DestroyWindow(id7);|
    end;|
    else return(DefWindowProc(hWnd,msg,wParam,lParam));
  end;
  return(true)
end id30;

//================= main ====================

begin
//class registration
  with id6 do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(id30);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=INSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=id1;
  end;
  RegisterClass(id6);
                     
//window create
  id7:=CreateWindowEx(0,id1,"Demo1_4",WS_OVERLAPPEDWINDOW,
    100,100,CW_USEDEFAULT,CW_USEDEFAULT,
    0,0,INSTANCE,nil);
  ShowWindow(id7,SW_SHOW);
  UpdateWindow(id7);

//editor window create
  id8:=CreateWindowEx(0,"Edit",nil,
    WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE, 0,0,0,0,
    id7,0,INSTANCE,nil);
  ShowWindow(id8,SW_SHOW);
  UpdateWindow(id8);
  SetFocus(id8);

//menu create
  id14(id7);

//messages loop
  while GetMessage(id9,0,0,0) do
    TranslateMessage(id9);
    DispatchMessage(id9);
  end;
  ExitProcess(0);
end Demo1_4.

