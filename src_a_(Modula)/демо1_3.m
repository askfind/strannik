// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа
// ƒемо 3:ѕрограмма с меню
module Demo1_3;
import Win32;

const 
  hINSTANCE=0x400000;
  им€ ласса="Strannik";

  менюЌовый=100;
  менюќткрыть=101;
  меню—охранить=102;
  меню¬ыход=200;

var
  осн ласс:WNDCLASS;
  оснќкно:HWND;
  сообщ:MSG;

//================= создание меню =======================

procedure создћеню(окно:HWND);
var оснћеню,всплћеню:HMENU;
begin
  оснћеню:=CreateMenu();

  всплћеню:=CreatePopupMenu();
  AppendMenu(всплћеню,MF_STRING|MF_ENABLED,менюЌовый,"Ќовый");
  AppendMenu(всплћеню,MF_STRING|MF_ENABLED,менюќткрыть,"ќткрыть");
  AppendMenu(всплћеню,MF_STRING|MF_ENABLED,меню—охранить,"—охранить");
  AppendMenu(оснћеню,MF_POPUP|MF_ENABLED,всплћеню,"‘айл");

  AppendMenu(оснћеню,MF_STRING|MF_ENABLED,меню¬ыход,"¬ыход");
  SetMenu(окно,оснћеню);
end создћеню;

//================= оконна€ функци€ ======================

procedure оконѕроц(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_CREATE:return(true);|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(hWnd,msg,wParam,lParam));|
    WM_COMMAND:case word(wParam) of
      менюЌовый:MessageBox(0,"Ќовый","ћеню:",0);|
      менюќткрыть:MessageBox(0,"ќткрыть","ћеню:",0);|
      меню—охранить:MessageBox(0,"—охранить","ћеню:",0);|
      меню¬ыход:MessageBox(0,"¬ыход","ћеню:",0);|
    end;|
    else return(DefWindowProc(hWnd,msg,wParam,lParam));
  end
end оконѕроц;

//================= основна€ программа ====================

begin

//регистраци€ класса
  with осн ласс do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(оконѕроц);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=им€ ласса;
  end;
  RegisterClass(осн ласс);
                     
//создание окна
  оснќкно:=CreateWindowEx(0,им€ ласса,"Beta1_3",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);
  ShowWindow(оснќкно,SW_SHOW);
  UpdateWindow(оснќкно);

//создание меню
  создћеню(оснќкно);

//цикл сообщений
  while GetMessage(сообщ,0,0,0) do
    TranslateMessage(сообщ);
    DispatchMessage(сообщ);
  end;

end Demo1_3.

