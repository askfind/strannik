// STRANNIK Modula-C-Pascal for Win32
// Demo program (Use Win32)
// Demo 2.14:view bitmap file

#include "Win32"

#define hINSTANCE 0x400000
#define className "Demo2_14"
#define idBitmap 100
#define idOk 101

//======== draw bmp to rectangle ==========

int bmpDraw(HDC drawDC, RECT reg, HBITMAP hbmp) {
HBITMAP oldBmp; HDC memDC; BITMAP BM; POINT ptSize,ptDestSize,ptOrg;

  memDC=CreateCompatibleDC(drawDC); if(memDC==0) return 1;
  oldBmp=SelectObject(memDC,hbmp); if(oldBmp==0) return 2;
  SetMapMode(memDC,GetMapMode(drawDC));
  GetObject(hbmp,sizeof(BITMAP),&BM);
  ptSize.x=BM.bmWidth; ptSize.y=BM.bmHeight; DPtoLP(drawDC,ptSize,1);
  ptDestSize.x=reg.right-reg.left; ptDestSize.y=reg.bottom-reg.top; DPtoLP(drawDC,ptDestSize,1);
  ptOrg.x=0; ptOrg.y=0; DPtoLP(memDC,ptOrg,1);
  if(!(StretchBlt(drawDC,reg.left,reg.top,ptDestSize.x,ptDestSize.y,memDC,ptOrg.x,ptOrg.y,ptSize.x,ptSize.y,SRCCOPY))) return 3;
  SelectObject(memDC,oldBmp);
  DeleteDC(memDC);
  return 0;
}

//================= window function of bmp  =======================

bool wndProc(HWND wnd, int msg, int wparam, int lparam) {
HDC dc; PAINTSTRUCT stru; RECT reg; HANDLE bmp;

  switch(msg) {
    case WM_CREATE:return true; break;
    case WM_PAINT:
      dc=BeginPaint(wnd,stru);
      GetClientRect(wnd,reg);
      bmp=LoadImage(0,"Demo2_14.bmp",IMAGE_BITMAP,0,0,LR_LOADFROMFILE);
      if(bmp!=0) {
        bmpDraw(dc,reg,bmp);
        DeleteObject(bmp);
      }
      EndPaint(wnd,stru);
      break;
    case WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

//================= main dialog =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_14:View bitmap file"
begin
  control "Ok",idOk,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "Bitmap",idBitmap,className,WS_CHILD | WS_VISIBLE | WS_BORDER | ACS_CENTER | ACS_TRANSPARENT,5,24,149,21
end;

//================= dialog function =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam) {
  switch(message) {
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case idOk:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
  default:return false; break;
  }
  return true;
}

//================= call dialog ====================

  WNDCLASS mainClass;
  MSG message;

void main() {
//class registration
  RtlZeroMemory(&mainClass,sizeof(WNDCLASS));
  mainClass.style=CS_HREDRAW | CS_VREDRAW;
  mainClass.lpfnWndProc=&wndProc;
  mainClass.hInstance=hINSTANCE;    
  mainClass.hbrBackground=COLOR_WINDOW;
  mainClass.lpszClassName=className;
  RegisterClass(mainClass);

//call dialog
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
  ExitProcess(0);
}

