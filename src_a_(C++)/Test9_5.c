//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 9:УТИЛИТЫ Win32ext
//Тест номер    5:Создание диалога indirect

include Win32,Win32ext

define INSTANCE 0x400000

void* pDlg;
int topDlg;

//================= диалоговая функция ======================

bool procDlg(HWND hWnd, int msg, int wParam, int lParam)
{
  switch(msg) {
    case WM_COMMAND:switch(loword(wParam)) {
      case IDOK:EndDialog(hWnd,1); break;
      case IDCANCEL:EndDialog(hWnd,0); break;
    } break;
    default:return false; break;
  }
}

int f;

void main() {
  topDlg=0;
  pDlg=memAlloc(indMAXMEM);
  indCaption(pDlg,topDlg,
    DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_VISIBLE,
    100,100,400,300,
    nil,nil,"Заголовок диалога");
  indItem(pDlg,topDlg,
    10,10,100,30,
    0,SS_RIGHT | WS_CHILD | WS_VISIBLE,
    "Static","Строка");
  indItem(pDlg,topDlg,
    10,40,100,30,
    0,SS_RIGHT | WS_CHILD | WS_VISIBLE,
    "Static","Строка");
//  f=_lcreat("dlg",0);
//  _lwrite(f,pDlg,topDlg);
//  _lclose(f);
  DialogBoxIndirectParam(INSTANCE,pDlg,0,&procDlg,0);
  memFree(pDlg);
}

