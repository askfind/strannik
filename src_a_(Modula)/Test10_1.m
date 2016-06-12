//Проект Странник-Модула Для Windows 32, тестовая программа
//Группа тестов 10:РЕСУРСЫ
//Тест номер    1:Диалог
module Test10_1;
import Win32;

const INSTANCE=0x400000;

//================= описание диалога ======================

dialog Диалог 21,53,263,84,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | WS_VISIBLE | DS_MODALFRAME,
  "Настройки программы:"
begin
  control "Строка", -1, "Static", SS_CENTER | WS_CHILD | WS_VISIBLE,34, 17, 156, 16
  control "Кнопка", 100, "Button", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,34, 34, 58, 16
  control "Ок",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,79,66,44,13
  control "Отмена",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,128,66,44,13
end;

//================= диалоговая функция ======================

procedure procDlg(hWnd:HWND; msg,wParam,lParam:cardinal):boolean;
begin
  case msg of
    WM_COMMAND:case loword(wParam) of
      IDOK:EndDialog(hWnd,1);|
      IDCANCEL:EndDialog(hWnd,0);|
    end;|
    else return(false);
  end
end procDlg;

begin
  DialogBoxParam(INSTANCE,"Диалог",0,addr(procDlg),0);
end Test10_1.

