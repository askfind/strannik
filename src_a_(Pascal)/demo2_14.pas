// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.14:view bitmap file

program Demo2_14;
uses Win32;

const 
  hINSTANCE=0x400000;
  className="Demo2_14";
  idBitmap=100;
  idOk=101;

//======== draw bmp to rectangle ==========

function bmpDraw(drawDC:HDC; reg:RECT; hbmp:HBITMAP):integer;
var oldBmp:HBITMAP; memDC:HDC; BM:BITMAP; ptSize,ptDestSize,ptOrg:POINT;
begin
with reg do begin
  memDC:=CreateCompatibleDC(drawDC); if memDC=0 then return 1;
  oldBmp:=SelectObject(memDC,hbmp); if oldBmp=0 then return 2;
  SetMapMode(memDC,GetMapMode(drawDC));
  GetObject(hbmp,sizeof(BITMAP),addr(BM));
  ptSize.x:=BM.bmWidth; ptSize.y:=BM.bmHeight; DPtoLP(drawDC,ptSize,1);
  ptDestSize.x:=right-left; ptDestSize.y:=bottom-top; DPtoLP(drawDC,ptDestSize,1);
  ptOrg.x:=0; ptOrg.y:=0; DPtoLP(memDC,ptOrg,1);
  if not StretchBlt(drawDC,left,top,ptDestSize.x,ptDestSize.y,memDC,ptOrg.x,ptOrg.y,ptSize.x,ptSize.y,SRCCOPY) then return 3;
  SelectObject(memDC,oldBmp);
  DeleteDC(memDC);
  return 0
end
end;

//================= window function of bmp  =======================

function wndProc(wnd:HWND; msg,wparam,lparam:dword):boolean;
var dc:HDC; stru:PAINTSTRUCT; reg:RECT; bmp:HANDLE;
begin
  case msg of
    WM_CREATE:return true;
    WM_PAINT:begin
      dc:=BeginPaint(wnd,stru);
      GetClientRect(wnd,reg);
      bmp:=LoadImage(0,"Demo2_14.bmp",IMAGE_BITMAP,0,0,LR_LOADFROMFILE);
      if bmp<>0 then begin
        bmpDraw(dc,reg,bmp);
        DeleteObject(bmp);
      end;
      EndPaint(wnd,stru);
    end;
    WM_DESTROY:begin PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam) end;
    else return DefWindowProc(wnd,msg,wparam,lparam)
  end
end;

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_14:View bitmap file"
begin
  control "Ok",idOk,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "Bitmap",idBitmap,className,WS_CHILD | WS_VISIBLE | WS_BORDER | ACS_CENTER | ACS_TRANSPARENT,5,24,149,21
end;

//================= dialog function =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_COMMAND:case loword(wparam) of
      IDOK,idOk:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
  else return false
  end;
  return true
end;

//================= call dialog ====================

var
  mainClass:WNDCLASS;
  message:MSG;

begin
//class registration
  RtlZeroMemory(addr(mainClass),sizeof(WNDCLASS));
  with mainClass do begin
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(wndProc);
    hInstance:=hINSTANCE;    
    hbrBackground:=COLOR_WINDOW;
    lpszClassName:=className;
  end;
  RegisterClass(mainClass);

//call dialog
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
  ExitProcess(0);
end.

