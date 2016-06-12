//—“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
//√оловной модуль 
//‘айл SM.M

module Sm;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra,SmRes,SmEnv;

icon "icon.bmp";

var mainMessage:MSG;

//===============================================
//                 √Ћј¬Ќќ≈ ќ Ќќ
//===============================================

//-------- —оздание дочерних окон -------------

procedure mainCreate(Wnd:HWND);
var dx,dy,x,y,len,i:integer; r:RECT;
begin
  GetClientRect(Wnd,r);
  dx:=loword(GetDialogBaseUnits());
  dy:=hiword(GetDialogBaseUnits());
//кнопки
  x:=dy div 4;
  y:=dy div 4;
//закладки
  envCreateTitle(Wnd);
//редактор
  y:=dy*3 div 2 +dy+(dy div 4)*2;
  editWnd:=CreateWindowEx(0,"Stran32Env",nil,ES_MULTILINE | WS_CHILD | WS_BORDER | WS_VSCROLL | WS_HSCROLL,
    1,y,r.right-2,r.bottom-r.top-y,Wnd,idBase+maxTxt+2,hINSTANCE,nil);
  if editWnd=0 then mbS(_ќшибка_при_создании_окна_editWnd[envER]) end
end mainCreate;

//---- »зменение размеров дочерних окон -------

procedure winResize(Wnd:HWND);
var cy,dx,dy,x,y,len,i:integer; r,rTool,rStat:RECT;
begin
  GetClientRect(Wnd,r);
  GetWindowRect(wndToolbar,rTool);
  GetWindowRect(wndStatus,rStat);
  dx:=loword(GetDialogBaseUnits());
  dy:=hiword(GetDialogBaseUnits());
  cy:=dy*5 div 4;
//статус
  envStatusCreate(false);
//закладки
  envDestroyTitle();
  envCreateTitle(Wnd);
//редактор
  y:=rTool.bottom-rTool.top+1+cy;
  MoveWindow(editWnd,1,y,r.right-1,r.bottom-r.top-y-(rStat.bottom-rStat.top),true);
end winResize;

//===============================================
//                    ћ≈Ќё
//===============================================

procedure mainCreateMenu():HMENU;
var crMenu,crMenuGroup,crMenu2:HMENU;
    gr:classGroup; co:classComm;
    i,j:integer; s:string[maxText];
begin
//меню главного окна
  crMenu:=CreateMenu();
  for gr:=gFil to gHlp do
  with setGroup[envER][gr] do
    crMenuGroup:=CreatePopupMenu();
    for co:=grLo to grHi do
      lstrcpy(s,setCommand[envER][co]);
      if (co=cSetMain)and(mait>0) then
        lstrcatc(s,'\9');
        lstrcat(s,txts[txtn[mait]][mait].txtTitle);
      end;
      if s[0]=char(0)
        then AppendMenu(crMenuGroup,MF_SEPARATOR,0,nil)
        else AppendMenu(crMenuGroup,MF_STRING | MF_ENABLED,idBaseComm+integer(co),s)
      end
    end;
    AppendMenu(crMenu,MF_POPUP | MF_ENABLED,crMenuGroup,grName);
    envMenuH[gr]:=crMenuGroup
  end end;
  co:=setGroup[envER][gLanguige].grLo; AppendMenu(crMenu,MF_STRING | MF_ENABLED,idBaseComm+integer(co),setCommand[envER][co]);
  co:=setGroup[envER][gExit].grLo; AppendMenu(crMenu,MF_STRING | MF_ENABLED,idBaseComm+integer(co),setCommand[envER][co]);
  return crMenu;
end mainCreateMenu;

//------- ”становить главный файл -------------

procedure envMain(mai:integer);
begin
  mait:=mai;
  SetMenu(mainWnd,mainCreateMenu());
  envEnable();
end envMain;

//------- ќбработка нотификационного сообщени€ -------------

procedure envNotify(lParam:cardinal);
var ук»нфо:pNMHDR; ук»нфо“екст:pTOOLTIPTEXT;
begin
  ук»нфо:=address(lParam);
  ук»нфо“екст:=address(lParam);
  with ук»нфо^,ук»нфо“екст^ do
    case code of
      TTN_NEEDTEXT:lpszText:=setCommand[envER][classComm(idFrom-idBaseComm)];| //текст кнопки
      TCN_SELCHANGE:
        envSelect(
          cardinal(SendMessage(wndTabs,TCM_GETCURSEL,0,0))+1,
          cardinal(SendMessage(wndExt,TCM_GETCURSEL,0,0)));| //выбор закладки
    end
  end
end envNotify;

//===============================================
//                ќ ќЌЌјя ‘”Ќ ÷»я
//===============================================

procedure mainProc(Wnd:HWND; Message,wParam,lParam:integer):integer;
var s:string[maxText]; i,rezProc:integer; foc:HWND; oldComp:boolean;
begin
  rezProc:=0;
  oldComp:=tbMod[tekt].modComp;
  case Message of
//создание и удаление
    WM_CREATE:mainCreate(Wnd); SetTimer(Wnd,0,1000,nil);|
    WM_DESTROY:if not envBitSaveFiles then envSaveFiles(false) end; KillTimer(Wnd,0); PostQuitMessage(0);|
    WM_SETFOCUS:SetFocus(editWnd);|    
    WM_TIMER:inc(time);|
    WM_SIZE:winResize(Wnd);|
    WM_NOTIFY:envNotify(lParam);|
//команды
    WM_COMMAND:case loword(wParam) of
      idBaseComm+cFilNew:envNew(); envUndoClear();|
      idBaseComm+cFilOpen:envOpen(nil,nil,topt+1); envUndoClear();|
      idBaseComm+cFilOpenCar:envOpen(nil,nil,tekt); envUndoClear();|
      idBaseComm+cFilClose:if mait=tekt then envMain(0) end; envClose(); envUndoClear();|
      idBaseComm+cFilSave:envSave();|
      idBaseComm+cFilSaveAs:envSaveAs();|
      idBaseComm+cFilExit:PostMessage(Wnd,WM_COMMAND,idBaseComm+integer(cExit),0);|
      idBaseComm+cBlkUndo:envUndoPop(tekt); envSetCaret(tekt);|
      idBaseComm+cBlkCut:if txts[txtn[tekt]][tekt].blkSet then envEditCopy(tekt); envUndoPush(undoDelBlock,tekt); envEditDel(tekt); envUndoBlockEnd(tekt) end;|
      idBaseComm+cBlkCopy:envEditCopy(tekt);|
      idBaseComm+cBlkPaste:
        if txts[txtn[tekt]][tekt].blkSet then envUndoPush(undoDelBlock,tekt); envEditDel(tekt); envUndoBlockEnd(tekt) end;
        envUndoPush(undoInsBlock,tekt); envEditIns(tekt); envUndoBlockEnd(tekt);|
      idBaseComm+cBlkDel:if txts[txtn[tekt]][tekt].blkSet then envUndoPush(undoDelBlock,tekt); envEditDel(tekt); envUndoBlockEnd(tekt) end;|
      idBaseComm+cBlkAll:envEditAll();|
      idBaseComm+cFindFind:PostMessage(editWnd,WM_COMMAND,wParam,0);|
      idBaseComm+cFindNext:PostMessage(editWnd,WM_COMMAND,wParam,0);|
      idBaseComm+cFindRepl:PostMessage(editWnd,WM_COMMAND,wParam,0);|
      idBaseComm+cComComp:envTranslate();|
      idBaseComm+cComAll:envTransAll(false,false);|
      idBaseComm+cComDll:envTransAll(false,true);|
      idBaseComm+cComRun:envExecute();|
      idBaseComm+cDebRun:envDebRun();|
      idBaseComm+cDebRunEnd:envDebRunEnd();|
      idBaseComm+cDebEnd:envDebEnd();|
      idBaseComm+cDebNextDown:envDebNextDown();|
      idBaseComm+cDebNext:envDebNext();|
      idBaseComm+cDebGoto:envDebGoto();|
      idBaseComm+cDebView:envDebView();|
      idBaseComm+cUtilId:envIdentifier();|
      idBaseComm+cUtilRes:envResource(tekt);|
      idBaseComm+cUtilErr:envTransAll(true,false);|
      idBaseComm+cSetComp:envSetComp();|
      idBaseComm+cSetEnv:envSetEnv();|
      idBaseComm+cSetDlg:ресЌастройки();|
      idBaseComm+cSetMain:envMain(tekt);|
      idBaseComm+cSetClear:envMain(0);|
      idBaseComm+cHlpCont:envHelp(HelpFile);|
      idBaseComm+cHlpWin32:envHelp(envWIN32);|
      idBaseComm+cHlpAbout:envAbout();|
      idBaseComm+cLanguige:if envER=erRussian then envER:=erEnglish else envER:=erRussian end; datSaveConst(); SetMenu(mainWnd,mainCreateMenu());|
      idBaseComm+cExit:if envSaveFiles(true) then DestroyWindow(mainWnd) end;|
    end;|
    WM_KEYDOWN:case loword(wParam) of
      VK_F4:|
    end;|
  else rezProc:=integer(DefWindowProc(Wnd,Message,wParam,lParam))
  end;
  with tbMod[tekt] do
  if oldComp<>modComp then
    envSetStatus(tekt)
  end end;
  return rezProc;
end mainProc;

//-------- –егистраци€ класса и окна ----------

procedure mainInitClass();
var initClass:WNDCLASS;
begin
  initClass.hInstance:=hINSTANCE;
  with initClass do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(mainProc);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hIcon:=LoadIcon(0,pstr(0xFFFF));
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:="Stran32";
  end;
  if RegisterClass(initClass)=0 then
    mbS(_ќшибка_регистрации_класса_Stran32[envER])
  end
end mainInitClass;

procedure mainInitWindow(winTitle:pstr);
begin
  mainWnd:=CreateWindowEx(0,"Stran32",winTitle,WS_OVERLAPPEDWINDOW,0,0,
    GetSystemMetrics(SM_CXSCREEN),
    GetSystemMetrics(SM_CYSCREEN)-
    GetSystemMetrics(SM_CYCAPTION)*3 div 2,
    0,0,hINSTANCE,nil);
  if mainWnd=0 then mbS(_ќшибка_открыти€_окна[envER]) end;
  ShowWindow(mainWnd,SW_SHOW)
end mainInitWindow;

//-------- √лавный цикл программы -------------

begin //Sm
  mainInitClass();
  envInitClass();
  рес»ниц лассы();
  datInitial();
  рес«агрѕарам();
  mainInitWindow(ProgName[envER]);
  envStatusCreate(true);
  envButtonCreate();
  envStatusLoad();
  SetMenu(mainWnd,mainCreateMenu());
  SetFocus(editWnd);

  while GetMessage(mainMessage,0,0,0) do
    TranslateMessage(mainMessage);
    DispatchMessage(mainMessage);
  end;

  if stepDebugged then
    отл«акончить();
  end;
  envStatusSave();
  datDestroy();
  ExitProcess(0)
end Sm.
