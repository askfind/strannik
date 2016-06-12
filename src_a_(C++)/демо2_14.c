// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.14:ƒемонстраци€ файла изображени€

#include "Win32"

#define hINSTANCE 0x400000
#define им€ ласса "Demo2_14"
#define ид артинка 100
#define идќк 101

//======== отображение bmp в пр€моугольную область ==========

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

//================= оконна€ функци€ bmp  =======================

bool оконѕроц(HWND wnd, int msg, int wparam,int lparam) {
  HDC dc; PAINTSTRUCT структура; RECT регион; HANDLE bmp;

  switch(msg) {
    case WM_CREATE:return true; break;
    case WM_PAINT:
      dc=BeginPaint(wnd,структура);
      GetClientRect(wnd,регион);
      bmp=LoadImage(0,"Demo2_14.bmp",IMAGE_BITMAP,0,0,LR_LOADFROMFILE);
      if(bmp!=0) {
        bmpDraw(dc,регион,bmp);
        DeleteObject(bmp);
      }
      EndPaint(wnd,структура);
      break;
    case WM_DESTROY:PostQuitMessage(0); return DefWindowProc(wnd,msg,wparam,lparam); break;
    default:return DefWindowProc(wnd,msg,wparam,lparam); break;
  }
}

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,72,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_14:ƒемонстраци€ файла изображени€"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,55,51,45,14
  control "»зображение",ид артинка,им€ ласса,WS_CHILD | WS_VISIBLE | WS_BORDER | ACS_CENTER | ACS_TRANSPARENT,5,24,149,21
end;

//================= диалогова€ функци€ =======================

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam) {
  switch(message) {
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case идќк:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
  default:return false; break;
  }
  return true;
}

//================= вызов диалога ====================

  WNDCLASS осн ласс;
  MSG сообщ;

void main() {
//регистраци€ класса
  RtlZeroMemory(&осн ласс,sizeof(WNDCLASS));
  осн ласс.style=CS_HREDRAW | CS_VREDRAW;
  осн ласс.lpfnWndProc=addr(оконѕроц);
  осн ласс.hInstance=hINSTANCE;    
  осн ласс.hbrBackground=COLOR_WINDOW;
  осн ласс.lpszClassName=им€ ласса;
  RegisterClass(осн ласс);

//вызов диалога
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
  ExitProcess(0);
}

