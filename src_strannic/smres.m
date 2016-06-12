//—“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
//ћодуль RES (редакторы ресурсов)
//‘айл SMRES.M

implementation module SmRes;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra;

procedure рес орр—тили(длг:HWND); forward;

//procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean; forward;
procedure resDlgToTxt(txt:pstr); forward;

//===============================================
//    ”“»Ћ»“џ –≈ƒј “ќ–ј ƒ»јЋќ√ќ¬
//===============================================

//------ ѕреобразовани€ диалоговых единиц в координаты ----------

procedure ресƒ≈вXY(де:integer; битY:boolean):integer;
begin
  case битY of
    false:return integer(real(де*loword(GetDialogBaseUnits())) / 4.0);|
    true:return integer(real(де*hiword(GetDialogBaseUnits())) / 8.0);|
  end
end ресƒ≈вXY;

procedure ресXYвƒ≈(xy:integer; битY:boolean):integer;
begin
  case битY of
    false:return integer(real(xy*4) / real(loword(GetDialogBaseUnits())));|
    true:return integer(real(xy*8) / real(hiword(GetDialogBaseUnits())));|
  end
end ресXYвƒ≈;

//--------- –азместить строку -----------------

procedure рес–азместить(var стр:pstr; текст:pstr);
begin
  if текст=nil then стр:=nil
  else
    стр:=memAlloc(lstrlen(текст)+1);
    lstrcpy(стр,текст);
  end
end рес–азместить;

//--------- ƒобавить новый стиль --------------

procedure ресƒобав—тиль(стили:pStyles; var верх:integer; стиль:pstr);
begin
  if верх=maxItem
    then mbS(_—лишком_много_стилей[envER])
    else inc(верх)
  end;
  стили^[верх]:=memAlloc(lstrlen(стиль)+1);
  lstrcpy(стили^[верх],стиль);
end ресƒобав—тиль;

//--------- ¬ыделить параметр из строки --------------

procedure рес»з—троки(ном:integer; исх,рез:pstr);
var тек:integer;
begin
  lstrcpy(рез,исх);
  for тек:=1 to ном-1 do
    if lstrposc(',',рез)>=0 then
      lstrdel(рез,0,lstrposc(',',рез)+1)
    else рез[0]:=char(0);
    end
  end;
  if lstrposc(',',рез)>=0 then
    lstrdel(рез,lstrposc(',',рез),999)
  end
end рес»з—троки;

//===============================================
//    ќ ќЌЌџ≈ ‘”Ќ ÷»» ЁЋ≈ћ≈Ќ“ј » ƒ»јЋќ√ј
//===============================================

//---------- создание окна элемента -----------

procedure рес—оздќкноЁлем(элем:integer);
var стиль:integer;
begin
with resDlg,dItems^[элем]^,iRect do
  iBlock:=false;
  стиль:=WS_CHILD | WS_VISIBLE | WS_BORDER;
  iWnd:=CreateWindowEx(0,классЁлемента,nil,стиль,x,y,dx,dy,
    resDlg.dItems^[0]^.iWnd,0,hINSTANCE,nil);
  if (iText<>nil)and(iText[0]<>char(0))
    then SetWindowText(iWnd,iText)
    else SetWindowText(iWnd,iClass)
  end
end
end рес—оздќкноЁлем;

//---------- создание окна диалога ------------

procedure рес—оздќкноƒлг(глав:HWND);
var стиль:integer;
begin
with resDlg,dItems^[0]^,iRect do
  стиль:=WS_CHILD | WS_VISIBLE | WS_THICKFRAME | WS_CAPTION;
  iWnd:=CreateWindowEx(0,классƒиалога,iText,стиль,x,y,
    dx+GetSystemMetrics(SM_CXFRAME)*2,
    dy+GetSystemMetrics(SM_CYFRAME)*2+GetSystemMetrics(SM_CYCAPTION),
    глав,0,hINSTANCE,nil);
  SetWindowText(iWnd,iText);
end
end рес—оздќкноƒлг;

//---------- —татусна€ информаци€ -------------

procedure рес—татусќбнов(элем:integer);
var стр,стр2:string[maxText]; X,Y,dX,dY:integer;
begin
with resDlg,dItems^[элем]^,iRect do
  lstrcpy(стр,_“екст_[envER]); lstrcat(стр,iText); SendMessage(resStatus,SB_SETTEXT,ord(dsTextE),cardinal(addr(стр)));
  lstrcpy(стр,_ ласс_[envER]); lstrcat(стр,iClass); SendMessage(resStatus,SB_SETTEXT,ord(dsClassE),cardinal(addr(стр)));
  lstrcpy(стр,_»д_[envER]); lstrcat(стр,iId); SendMessage(resStatus,SB_SETTEXT,ord(dsIdE),cardinal(addr(стр)));
  X:=ресXYвƒ≈(x,false);
  Y:=ресXYвƒ≈(y,true);
  dX:=ресXYвƒ≈(dx,false);
  dY:=ресXYвƒ≈(dy,true);
  wvsprintf(стр,"x,y:%li,",addr(X));
  wvsprintf(стр2,"%li",addr(Y));
  lstrcat(стр,стр2);
  SendMessage(resStatus,SB_SETTEXT,ord(dsXY),cardinal(addr(стр)));
  wvsprintf(стр,"dx,dy:%li,",addr(dX));
  wvsprintf(стр2,"%li",addr(dY));
  lstrcat(стр,стр2);
  SendMessage(resStatus,SB_SETTEXT,ord(dsDXDY),cardinal(addr(стр)));
end
end рес—татусќбнов;

//--------------- установка/сброс блока ----------------

procedure рес”становитьЅлок(элемент:integer; блок:boolean);
var флаги:integer;
begin
with resDlg do
  if (элемент>0)and(элемент<=dTop) then
    if dItems^[элемент]^.iBlock<>блок then
      if блок
        then флаги:=WS_CHILD | WS_VISIBLE | WS_THICKFRAME
        else флаги:=WS_CHILD | WS_VISIBLE | WS_BORDER
      end;
      SetWindowLong(dItems^[элемент]^.iWnd,GWL_STYLE,флаги);
      RedrawWindow(dItems^[элемент]^.iWnd,nil,0,RDW_FRAME | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW | RDW_ERASENOW);
      dItems^[элемент]^.iBlock:=блок
    end
  end
end
end рес”становитьЅлок;

//--------------- установить вхождение элементов в блок ----------------

procedure рес”становитьЅлокиЁлементов();
var
  тек:integer;
  начX,начY,конX,конY:integer;
begin
with resDlg do
//координаты блока
  if ресƒлгЅлокX<ресƒлг“екX then
    начX:=ресƒлгЅлокX;
    конX:=ресƒлг“екX;
  else
    начX:=ресƒлг“екX;
    конX:=ресƒлгЅлокX;
  end;
  if ресƒлгЅлокY<ресƒлг“екY then
    начY:=ресƒлгЅлокY;
    конY:=ресƒлг“екY;
  else
    начY:=ресƒлг“екY;
    конY:=ресƒлгЅлокY;
  end;
//проверка элементов
  for тек:=1 to dTop do
  with dItems^[тек]^,iRect do
      рес”становитьЅлок(тек,(начX<=x)and(конX>=x+dx-1)and(начY<=y)and(конY>=y+dy-1));
  end end;
end
end рес”становитьЅлокиЁлементов;

//--------------- смена фокуса ----------------

procedure рес»зм‘окус(окно:HWND);
var тек,нов:integer;
begin
with resDlg do
//поиск нового элемента
  нов:=-1;
  for тек:=0 to dTop do
    if окно=dItems^[тек]^.iWnd then
      нов:=тек;
  end end;
  if нов>-1 then
//сброс всех старых элементов
    for тек:=0 to dTop do
      рес”становитьЅлок(тек,false);
    end;
//установка нового
    рес”становитьЅлок(нов,true);
    resDlgItem:=нов;
    рес—татусќбнов(resDlgItem);
  end
end
end рес»зм‘окус;

//--------------- ѕеремещение окна ----------------

procedure ресѕереместить(окно:HWND; сооб,вѕарам,лѕарам:integer; битƒлг:boolean);
var рег,рег2,рег3:RECT; тек,нов:integer;
begin
  нов:=-1;
  for тек:=0 to resDlg.dTop do
    if окно=resDlg.dItems^[тек]^.iWnd then
      нов:=тек;
  end end;
  if нов>-1 then
  with resDlg,dItems^[нов]^.iRect do
    case сооб of
      WM_SIZE:
        if битƒлг
          then GetClientRect(окно,рег)
          else GetWindowRect(окно,рег);
        end;
        dx:=рег.right-рег.left;
        dy:=рег.bottom-рег.top;|
      WM_MOVE:
        GetWindowRect(окно,рег);
        GetClientRect(окно,рег2);
        x:=loword(лѕарам)-(рег.right-рег.left-рег2.right) div 2;
        y:=hiword(лѕарам)-(рег.bottom-рег.top-рег2.bottom) div 2;|
    end;
    рес—татусќбнов(resDlgItem);
  end end
end ресѕереместить;

//------- ќконна€ функци€ элемента -----------

procedure ресѕроцЁлем(окно:HWND; сооб,вѕарам,лѕарам:integer):integer;
var стр:string[maxText]; дк:HDC; структ:PAINTSTRUCT; рег:RECT; рез:integer;
begin
  case сооб of
//  создание и удаление
    WM_CREATE:|
    WM_DESTROY:|
//  изображение
    WM_PAINT:
      GetWindowText(окно,стр,maxText);
      дк:=BeginPaint(окно,структ);
      SetBkMode(дк,TRANSPARENT);
      SetTextColor(дк,0xC0C0C0);
      TextOut(дк,0,0,стр,lstrlen(стр));
      EndPaint(окно,структ);|
//  размеры
    WM_SIZE:ресѕереместить(окно,сооб,вѕарам,лѕарам,false);|
    WM_MOVE:ресѕереместить(окно,сооб,вѕарам,лѕарам,false);|
//  мышь
    WM_NCHITTEST:
      рез:=integer(DefWindowProc(окно,сооб,вѕарам,лѕарам));
      if рез=HTCLIENT
        then return HTCAPTION
        else return рез
      end;|
    WM_NCLBUTTONDOWN:
      рес»зм‘окус(окно);
      return integer(DefWindowProc(окно,сооб,вѕарам,лѕарам));|
    WM_NCLBUTTONDBLCLK:рес орр—тили(resDlgWnd);|
    WM_KEYDOWN:SendMessage(GetParent(окно),сооб,вѕарам,лѕарам);|
  else return integer(DefWindowProc(окно,сооб,вѕарам,лѕарам))
  end;
  return 0
end ресѕроцЁлем;

//------- –исовать рамку блока -----------

procedure рес–исоватьЅлок(дк:HDC; окно:HWND);
var
  начX,начY,конX,конY:integer;
  перо,старое:HPEN;
begin
//координаты блока
  if ресƒлгЅлокX<ресƒлг“екX then
    начX:=ресƒлгЅлокX;
    конX:=ресƒлг“екX;
  else
    начX:=ресƒлг“екX;
    конX:=ресƒлгЅлокX;
  end;
  if ресƒлгЅлокY<ресƒлг“екY then
    начY:=ресƒлгЅлокY;
    конY:=ресƒлг“екY;
  else
    начY:=ресƒлг“екY;
    конY:=ресƒлгЅлокY;
  end;
//рисование
  перо:=CreatePen(PS_DOT,1,0);
  старое:=SelectObject(дк,перо);
  MoveToEx(дк,начX,начY,nil);
  LineTo(дк,конX,начY);
  LineTo(дк,конX,конY);
  LineTo(дк,начX,конY);
  LineTo(дк,начX,начY);
  SelectObject(дк,старое);
  DeleteObject(перо);
end рес–исоватьЅлок;

//------- ќконна€ функци€ диалога -----------

procedure ресѕроцƒлг(окно:HWND; сооб,вѕарам,лѕарам:integer):integer;
var стр:string[maxText]; дк:HDC; структ:PAINTSTRUCT;
begin
  case сооб of
//  создание и удаление
    WM_CREATE:
      ресƒлгЅлокX:=0;
      ресƒлгЅлокY:=0;|
    WM_DESTROY:|
//  размеры
    WM_SIZE:ресѕереместить(окно,сооб,вѕарам,лѕарам,true);|
    WM_MOVE:ресѕереместить(окно,сооб,вѕарам,лѕарам,true);|
    WM_PAINT:
      if ресƒлгЅлокX<>0 then
        дк:=BeginPaint(окно,структ);
        рес–исоватьЅлок(дк,окно);
        EndPaint(окно,структ);
      end;
      return integer(DefWindowProc(окно,сооб,вѕарам,лѕарам));|
//  мышь и клавиатура
    WM_LBUTTONDOWN:
      рес»зм‘окус(окно);
      SetCapture(окно);
      ресƒлгЅлокX:=loword(лѕарам);
      ресƒлгЅлокY:=hiword(лѕарам);|
    WM_LBUTTONUP:
      if ресƒлгЅлокX<>0 then
        ReleaseCapture();
        ресƒлгЅлокX:=0;
        ресƒлгЅлокY:=0;
        InvalidateRect(окно,nil,true);
        UpdateWindow(окно);
      end;|
    WM_MOUSEMOVE:
      if ресƒлгЅлокX<>0 then
        ресƒлг“екX:=loword(лѕарам);
        ресƒлг“екY:=hiword(лѕарам);
        InvalidateRect(окно,nil,true);
        UpdateWindow(окно);
        рес”становитьЅлокиЁлементов();
      end;|
    WM_LBUTTONDBLCLK:|
    WM_KEYDOWN:SendMessage(GetParent(окно),сооб,вѕарам,лѕарам);|
    else return integer(DefWindowProc(окно,сооб,вѕарам,лѕарам))
  end;
  return 0
end ресѕроцƒлг;

//===============================================
//              ќ––≈ ÷»я —“»Ћ≈…
//===============================================

//--------- ƒобавить новый элемент ------------

procedure ресƒобавитьЁлем(ид:integer);
var кл,вар,тек:integer; стр:string[maxText];
begin
with resDlg do
  if dTop=maxItem
    then mbS(_—лишком_много_элементов_в_диалоге[envER])
    else inc(dTop)
  end;
  dItems^[dTop]:=memAlloc(sizeof(recItem));
  with dItems^[dTop]^ do
//определение класса и меню
    кл:=ид div 100;
    вар:=ид mod 100;
    if (кл<=resTopClass)and(вар<=resClasses^[кл].claTop) then
    with resClasses^[кл] do
//заполнение параметров элемента
      рес–азместить(iClass,claName);
      рес–азместить(iText,claIniText);
      рес–азместить(iId,"-1");
      with iRect do
        x:=resDlgIniX;
        y:=resDlgIniY;
        dx:=ресƒ≈вXY(claIniDX,false);
        dy:=ресƒ≈вXY(claIniDY,true);
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      тек:=2;
      рес»з—троки(тек,claList[вар],стр);
      while lstrcmp(стр,"")<>0 do
        ресƒобав—тиль(iStyles,iTop,стр);
        inc(тек);
        рес»з—троки(тек,claList[вар],стр);
      end;
      iWnd:=0;
      рес—оздќкноЁлем(dTop);
      рес»зм‘окус(iWnd);
    end end;
  end;
end
end ресƒобавитьЁлем;

//-------------- «агрузка стилей ---------------------

procedure рес«агр—тили();
var файл,тек,i:integer; ид:recID; бит:boolean; S:recStream; строка:pstr;
begin
  if resStyles=nil then
    resStyles:=memAlloc(sizeof(arrListStyles));
    resTopStyles:=0;
    envInfBegin(_«агрузка_списка_стилей_из_[envER],resWIN32);
    файл:=_lopen(resWIN32,OF_READ);
    if файл>0 then
    //пропуск заголовка
      _lread(файл,addr(тек),4);//Entry
      _lread(файл,addr(тек),4);//код
      _lread(файл,addr(тек),4);
      _llseek(файл,тек,FILE_CURRENT);
      _lread(файл,addr(тек),4);//данные
      _lread(файл,addr(тек),4);
      _llseek(файл,тек,FILE_CURRENT);
      _lread(файл,addr(тек),4);//модули
      for i:=1 to тек do
        idReadS(файл,строка);
        memFree(строка);
      end;
    //чтение идентификаторов
      while (idReadID(S,ид,файл)) do
      with ид do
        if idClass=idcINT then
        //поиск префикса
          бит:=(lstrpos("WS_",idName)=0)or(lstrpos("DS_",idName)=0);
          for тек:=1 to resTopClass do
          if not бит then
            if lstrpos(resClasses^[тек].claStyle,idName)=0 then
              бит:=true
            end
          end end;
        //запись в список
          if бит and(resTopStyles<maxListStyles) then
            inc(resTopStyles);
            resStyles^[resTopStyles]:=memAlloc(lstrlen(idName)+1);
            lstrcpy(resStyles^[resTopStyles],idName);
          end
        end;
      //освобождение пам€ти
        memFree(idName);
        case idClass of
          idcSTR:memFree(idStr);|
          idtREC:memFree(idRecList);|
          idtSCAL:memFree(idScalList);|
          idPROC:memFree(idProcList); memFree(idProcDLL);|
        end;
      end end;
      _lclose(файл);
    end;
    envInfEnd();
  end
end рес«агр—тили;

//-------------- ƒиалог стилей ---------------------

const
  идЁл“екст=101;
  идЁл ласс=102;
  идЁл»дент=103;
  идЁлX=104;
  идЁлDX=105;
  идЁлY=106;
  идЁлDY=107;
  идЁл—тили=108;
  идЁлƒобавить=109;
  идЁл”далить=110;
  идЁл—тилиќкна=111;
  идЁл—тили ласса=112;
  идЁлƒругое=113;
  идЁлќк=120;
  идЁлќтмена=121;

const DLG_STYLE=stringER{"DLG_STYLE_R","DLG_STYLE_E"};
dialog DLG_STYLE_R 22,14,268,176,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "ѕараметры элемента диалога"
begin
  control "“екст элемента:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,2,62,10
  control "",идЁл“екст,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,2,194,10
  control " ласс элемента:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,14,62,10
  control "",идЁл ласс,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,14,90,10
  control "»дентификатор:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,26,62,10
  control "",идЁл»дент,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,26,90,10
  control "–азмеры:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,178,16,72,10
  control "X:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,30,14,10
  control "",идЁлX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,30,26,10
  control "DX:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,30,14,10
  control "",идЁлDX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,30,26,10
  control "Y:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,40,14,10
  control "",идЁлY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,40,26,10
  control "DY:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,40,14,10
  control "",идЁлDY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,40,26,10
  control "—тили элемента:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,66,56,100,10
  control "",идЁл—тили,"LISTBOX",WS_CHILD | WS_BORDER | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL,2,80,100,74
  control "ƒобавить",идЁлƒобавить,"Button",0 | WS_CHILD | WS_VISIBLE,162,68,46,10
  control "”далить",идЁл”далить,"Button",0 | WS_CHILD | WS_VISIBLE,2,68,46,10
  control "ќконные",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,80,54,10
  control "",идЁл—тилиќкна,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,80,100,120
  control "—тили класса",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,98,54,10
  control "",идЁл—тили ласса,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,98,100,120
  control "ƒругое",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,116,54,10
  control "",идЁлƒругое,"EDIT",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,162,116,100,12
  control "ќк",идЁлќк,"Button",0 | WS_CHILD | WS_VISIBLE,82,162,46,10
  control "ќтмена",идЁлќтмена,"Button",0 | WS_CHILD | WS_VISIBLE,136,162,46,10
end;
dialog DLG_STYLE_E 22,14,268,176,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "Item options"
begin
  control "Item text:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,2,62,10
  control "",идЁл“екст,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,2,194,10
  control "Item class:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,14,62,10
  control "",идЁл ласс,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,14,90,10
  control "Identifier:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,26,62,10
  control "",идЁл»дент,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,26,90,10
  control "Sizes:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,178,16,72,10
  control "X:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,30,14,10
  control "",идЁлX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,30,26,10
  control "DX:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,30,14,10
  control "",идЁлDX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,30,26,10
  control "Y:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,40,14,10
  control "",идЁлY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,40,26,10
  control "DY:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,40,14,10
  control "",идЁлDY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,40,26,10
  control "Item styles:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,66,56,100,10
  control "",идЁл—тили,"LISTBOX",WS_CHILD | WS_BORDER | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL,2,80,100,74
  control "Add",идЁлƒобавить,"Button",0 | WS_CHILD | WS_VISIBLE,162,68,46,10
  control "Delete",идЁл”далить,"Button",0 | WS_CHILD | WS_VISIBLE,2,68,46,10
  control "Window",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,80,54,10
  control "",идЁл—тилиќкна,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,80,100,120
  control "Class styles",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,98,54,10
  control "",идЁл—тили ласса,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,98,100,120
  control "Other",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,116,54,10
  control "",идЁлƒругое,"EDIT",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,162,116,100,12
  control "Ok",идЁлќк,"Button",0 | WS_CHILD | WS_VISIBLE,82,162,46,10
  control "Cancel",идЁлќтмена,"Button",0 | WS_CHILD | WS_VISIBLE,136,162,46,10
end;

//------- ƒиалогова€ функци€ параметров элемента -----------

procedure ресѕроц—тили(окно:HWND; сооб,вѕарам,лѕарам:integer):boolean;
var тек:integer; стр:string[maxText];
begin
  case сооб of
    WM_INITDIALOG:with resDlg.dItems^[resDlgItem]^ do //инициализаци€ диалога
      SetDlgItemText(окно,идЁл“екст,iText);
      SetDlgItemText(окно,идЁл ласс,iClass);
      SetDlgItemText(окно,идЁл»дент,iId);
      with iRect do
        SetDlgItemInt(окно,идЁлX,ресXYвƒ≈(x,false),true);
        SetDlgItemInt(окно,идЁлDX,ресXYвƒ≈(dx,false),true);
        SetDlgItemInt(окно,идЁлY,ресXYвƒ≈(y,true),true);
        SetDlgItemInt(окно,идЁлDY,ресXYвƒ≈(dy,true),true);
      end;
      for тек:=1 to iTop do
        SendDlgItemMessage(окно,идЁл—тили,LB_ADDSTRING,0,integer(iStyles^[тек]));
      end;
    //загрузка стилей
      рес«агр—тили();
      if resDlgItem=0 then lstrcpy(стр,"DS_")
      else
        стр[0]:=char(0);
        for тек:=1 to resTopClass do
        if lstrcmp(resClasses^[тек].claName,iClass)=0 then
          lstrcpy(стр,resClasses^[тек].claStyle);
        end end
      end;
      for тек:=1 to resTopStyles do
        if lstrpos("WS_",resStyles^[тек])=0 then
          SendDlgItemMessage(окно,идЁл—тилиќкна,CB_ADDSTRING,0,integer(resStyles^[тек]));
        elsif lstrpos(стр,resStyles^[тек])=0 then
          SendDlgItemMessage(окно,идЁл—тили ласса,CB_ADDSTRING,0,integer(resStyles^[тек]));
        end 
      end;
      SendDlgItemMessage(окно,идЁл—тилиќкна,CB_SETCURSEL,0,0);
      SendDlgItemMessage(окно,идЁл—тили ласса,CB_SETCURSEL,0,0);
      SetFocus(GetDlgItem(окно,идЁл“екст));
    end;|
    WM_COMMAND:case loword(вѕарам) of
      идЁлƒобавить:
        GetDlgItemText(окно,resDlgFocus,стр,maxText);
        if стр[0]=char(0) then mbS(_Ќельз€_добавл€ть_пустой_стиль[envER])
        elsif SendDlgItemMessage(окно,идЁл—тили,LB_FINDSTRING,0,integer(addr(стр)))>=0 then mbS(_Ќельз€_добавл€ть_повторный_стиль[envER])
        else SendDlgItemMessage(окно,идЁл—тили,LB_ADDSTRING,0,integer(addr(стр)))
        end;|
      идЁл”далить:
        тек:=SendDlgItemMessage(окно,идЁл—тили,LB_GETCURSEL,0,0);
        if тек>=0 then
          SendDlgItemMessage(окно,идЁл—тили,LB_DELETESTRING,тек,0);
          if тек>0 then
            SendDlgItemMessage(окно,идЁл—тили,LB_SETCURSEL,тек-1,0);
          end;
          SetFocus(GetDlgItem(окно,идЁл—тили));
        end;|
      IDOK,идЁлќк:with resDlg.dItems^[resDlgItem]^ do
        memFree(iText); GetDlgItemText(окно,идЁл“екст,стр,maxText); рес–азместить(iText,стр);
        memFree(iClass); GetDlgItemText(окно,идЁл ласс,стр,maxText); рес–азместить(iClass,стр);
        memFree(iId); GetDlgItemText(окно,идЁл»дент,стр,maxText); рес–азместить(iId,стр);
        with iRect do
          x:=ресƒ≈вXY(GetDlgItemInt(окно,идЁлX,nil,true),false);
          y:=ресƒ≈вXY(GetDlgItemInt(окно,идЁлY,nil,true),true);
          dx:=ресƒ≈вXY(GetDlgItemInt(окно,идЁлDX,nil,true),false);
          dy:=ресƒ≈вXY(GetDlgItemInt(окно,идЁлDY,nil,true),true);
        end;
        for тек:=1 to iTop do
          memFree(iStyles^[тек]);
        end;
        iTop:=SendDlgItemMessage(окно,идЁл—тили,LB_GETCOUNT,0,0);
        for тек:=1 to iTop do
          iStyles^[тек]:=memAlloc(SendDlgItemMessage(окно,идЁл—тили,LB_GETTEXTLEN,тек-1,0)+1);
          SendDlgItemMessage(окно,идЁл—тили,LB_GETTEXT,тек-1,integer(iStyles^[тек]));
        end;
        EndDialog(окно,1);
      end;|
      IDCANCEL,идЁлќтмена:EndDialog(окно,0);|
      идЁл—тилиќкна,идЁл—тили ласса,идЁлƒругое:case hiword(вѕарам) of
        CBN_SETFOCUS,EN_SETFOCUS:resDlgFocus:=loword(вѕарам);|
      end;|
    end;|
  else return false
  end;
  return true
end ресѕроц—тили;

//--------  оррекци€ стилей элемента -----------

procedure рес орр—тили;
begin
  if boolean(DialogBoxParam(hINSTANCE,DLG_STYLE[envER],длг,addr(ресѕроц—тили),0)) then
  with resDlg.dItems^[resDlgItem]^,iRect do
    if resDlgItem=0 then
      MoveWindow(iWnd,x,y,
        dx+GetSystemMetrics(SM_CXFRAME)*2,
        dy+GetSystemMetrics(SM_CYFRAME)*2+GetSystemMetrics(SM_CYCAPTION),true);
    else MoveWindow(iWnd,x,y,dx,dy,true)
    end;
    рес—татусќбнов(resDlgItem);
    if (iText<>nil)and(iText[0]<>char(0))
      then SetWindowText(iWnd,iText)
      else SetWindowText(iWnd,iClass)
    end;
    InvalidateRect(iWnd,nil,true);
    UpdateWindow(iWnd);
  end end
end рес орр—тили;

//===============================================
//              ќ––≈ ÷»я Ў–»‘“ј ƒ»јЋќ√ј 
//===============================================

//------------- ¬ыбор шрифта ------------------

const DLG_FONT=stringER{"DLG_FONT_R","DLG_FONT_E"};
dialog DLG_FONT_R 46,34,184,114,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "¬ыбор шрифта"
begin
  control "Ўрифт:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,6,4,32,8
  control "",101,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,4,14,96,78
  control "–азмер:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,102,4,28,8
  control "",102,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,108,14,24,78
  control "∆ирный:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,22,32,8
  control "",103,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,22,6,6
  control " урсив:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,34,32,8
  control "",104,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,34,6,6
  control "÷вет:",-1,"Static",1 | WS_CHILD | WS_VISIBLE,144,54,32,8
  control "ќк",120,"Button",0 | WS_CHILD | WS_VISIBLE,36,96,52,12
  control "ќтмена",121,"Button",0 | WS_CHILD | WS_VISIBLE,94,96,52,12
  control "",105,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,140,65,38,10
end;
dialog DLG_FONT_E 46,34,184,114,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Font"
begin
  control "Font:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,6,4,32,8
  control "",101,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,4,14,96,78
  control "Size:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,102,4,28,8
  control "",102,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,108,14,24,78
  control "Bold:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,22,32,8
  control "",103,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,22,6,6
  control "Italic:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,34,32,8
  control "",104,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,34,6,6
  control "Color:",-1,"Static",1 | WS_CHILD | WS_VISIBLE,144,54,32,8
  control "Ok",120,"Button",0 | WS_CHILD | WS_VISIBLE,36,96,52,12
  control "Cancel",121,"Button",0 | WS_CHILD | WS_VISIBLE,94,96,52,12
  control "",105,"Button",WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP | BS_PUSHBUTTON,140,65,38,10
end;

//------------- ¬ыбор шрифта ------------------

const
  idFntFace=101;
  idFntSize=102;
  idFntBold=103;
  idFntItal=104;
  idFntCol=105;
  idFntOk=120;
  idFntCancel=121;

procedure dlgFont(Wnd:HWND; Message,wParam,lParam:integer):boolean;
var i,j:integer; buf:string[maxText]; fonts:sysFonts; dc:HDC;
begin
  case Message of
    WM_INITDIALOG:
      with carFont do
        SetDlgItemText(Wnd,idFntFace,fFace);
        dc:=GetDC(mainWnd);
        sysGetFamilies(dc,fonts);
        ReleaseDC(dc,mainWnd);
        for i:=1 to fonts.top do
          SendDlgItemMessage(Wnd,idFntFace,CB_ADDSTRING,0,integer(fonts.fnts[i]));
          if lstrcmp(fFace,fonts.fnts[i])=0 then
            SendDlgItemMessage(Wnd,idFntFace,CB_SETCURSEL,i-1,0)
          end;
          memFree(fonts.fnts[i])
        end;
        SetDlgItemInt(Wnd,idFntSize,fSize,false);
        for i:=6 to 20 do
          wvsprintf(buf,"%li",addr(i));
          SendDlgItemMessage(Wnd,idFntSize,CB_ADDSTRING,0,integer(addr(buf)));
          if fSize=i then
            SendDlgItemMessage(Wnd,idFntSize,CB_SETCURSEL,i-6,0)
          end
        end;
        CheckDlgButton(Wnd,idFntBold,integer(fBold));
        CheckDlgButton(Wnd,idFntItal,integer(fItal));
        wvsprintf(buf,"%.6lX",addr(fCol));
        SetDlgItemText(Wnd,idFntCol,buf);
      end;|
    WM_COMMAND:case loword(wParam) of
      idFntBold:
        if boolean(IsDlgButtonChecked(Wnd,idFntBold))
          then CheckDlgButton(Wnd,idFntBold,0)
          else CheckDlgButton(Wnd,idFntBold,1);
        end;|
      idFntItal:
        if boolean(IsDlgButtonChecked(Wnd,idFntItal))
          then CheckDlgButton(Wnd,idFntItal,0)
          else CheckDlgButton(Wnd,idFntItal,1);
        end;|
      idFntCol:if hiword(wParam)=BN_CLICKED then
        GetDlgItemText(Wnd,idFntCol,buf,maxText);
        lstrinsc('x',buf,0); lstrinsc('0',buf,0);
        i:=sysChooseColor(Wnd,wvscani(buf));
        wvsprintf(buf,"%.6lX",addr(i));
        SetDlgItemText(Wnd,idFntCol,buf);
      end;|
      IDOK,idFntOk:
        with carFont do
          GetDlgItemText(Wnd,idFntFace,fFace,maxStrID);
          fSize:=GetDlgItemInt(Wnd,idFntSize,nil,false);
          fBold:=boolean(IsDlgButtonChecked(Wnd,idFntBold));
          fItal:=boolean(IsDlgButtonChecked(Wnd,idFntItal));
          GetDlgItemText(Wnd,idFntCol,buf,maxText);
          lstrinsc('x',buf,0); lstrinsc('0',buf,0);
          fCol:=wvscani(buf);
          if fCol>cardinal(0xFFFFFF) then
            mbS(_Ќеверный_цвет[envER])
          end
        end;
        EndDialog(Wnd,1);|
      IDCANCEL,idFntCancel:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true;
end dlgFont;

//------------- ¬ыбор шрифта ------------------

procedure рес оррЎрифт(окно:HWND);
begin
  with resDlg.dItems^[0]^,carFont do
    RtlZeroMemory(addr(carFont),sizeof(recFont));
    lstrcpy(fFace,iFont);
    fSize:=iSize;
  end;
  if boolean(DialogBoxParam(hINSTANCE,DLG_FONT[envER],окно,addr(dlgFont),0)) then
  with resDlg.dItems^[0]^,carFont do
    iFont:=memAlloc(lstrlen(fFace)+1);
    if lstrlen(fFace)=0
      then iFont:=nil
      else lstrcpy(iFont,fFace)
    end;
    iSize:=fSize;
  end end
end рес оррЎрифт;

//------------- ¬ыбор шрифта фрагмента ------------------

procedure envCorrFont(f:classFrag);
begin
  carFont:=stFont[f];
  if boolean(DialogBoxParam(hINSTANCE,DLG_FONT[envER],GetFocus(),addr(dlgFont),0)) then
    stFont[f]:=carFont;
  end
end envCorrFont;

//===============================================
//             Ћ»Ќ≈… ј »Ќ—“–”ћ≈Ќ“ќ¬
//===============================================

//------- —оздать кнопки -------------

bitmap bmpToolDlg="tooldlg.bmp";

procedure рес—оздать нопки(окно:HWND);
var
  тек:integer; команда:classDlgComm; bmp:HBITMAP; рег:RECT;
  кнопки:array[1..maxButt]of TBBUTTON;
begin
  InitCommonControls();
  bmp:=LoadBitmap(hINSTANCE,"bmpToolDlg");
  тек:=0;
  for команда:=cdNULL to cdCancel do
    if (setDlgCommand[envER][команда].numTool>0)and(тек<maxButt) then
      inc(тек);
      RtlZeroMemory(addr(кнопки[тек]),sizeof(TBBUTTON));
      with кнопки[тек] do
        iBitmap:=setDlgCommand[envER][команда].numTool-1;
        idCommand:=idDlgBase+ord(команда);
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_BUTTON;
      end;
    end;
    if (тек<maxButt)and((команда=cdEditDel)or(команда=cdAlignDown)or(команда=cdAlignSizeY)) then
      inc(тек);
      RtlZeroMemory(addr(кнопки[тек]),sizeof(TBBUTTON));
      with кнопки[тек] do
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_SEP;
      end
    end
  end;
  wndToolDlg:=CreateToolbarEx(
    окно,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,тек,0,bmp,addr(кнопки),тек,20,20,20,20,sizeof(TBBUTTON));
  with рег do
    GetWindowRect(wndToolDlg,рег);
    inc(bottom,10);
    MoveWindow(wndToolDlg,left,top,right-left+1,bottom-top+1,true);
  end;
end рес—оздать нопки;

//------- ќбработка нотификационного сообщени€ -------------

procedure ресЌотификаци€(лѕарам:cardinal);
var ук»нфо:pNMHDR; ук»нфо“екст:pTOOLTIPTEXT;
begin
  ук»нфо:=address(лѕарам);
  ук»нфо“екст:=address(лѕарам);
  with ук»нфо^,ук»нфо“екст^ do
    case code of
      TTN_NEEDTEXT:lpszText:=setDlgCommand[envER][classDlgComm(idFrom-idDlgBase)].name;| //текст кнопки
    end
  end
end ресЌотификаци€;

//===============================================
//             –јЅќ“ј — ЅЋќ јћ»
//===============================================

//----------- —канер текста диалога ------------

procedure рес—канер(текст:pstr; var тек:integer);
begin
  if ресЋексќшибка then
    if текст[тек]<>'\0' then
      inc(тек)
    end;
    ресЋексема:=лексЌоль
  else
    while (текст[тек]=' ')or(текст[тек]='\10')or(текст[тек]='\13') do
      inc(тек);
    end;
    case текст[тек] of
      '\0':ресЋексема:=лексЌоль;|
      'A'..'Z','a'..'z','ј'..'я','а'..'€','_'://идентификатор
        ресЋексема:=лекс»дент;
        ресЋекс—трока[0]:='\0';
        lstrcatc(ресЋекс—трока,текст[тек]); inc(тек);
        while
          (ord(текст[тек])>=ord('A'))and(ord(текст[тек])<=ord('Z'))or
          (ord(текст[тек])>=ord('a'))and(ord(текст[тек])<=ord('z'))or
          (ord(текст[тек])>=ord('ј'))and(ord(текст[тек])<=ord('я'))or
          (ord(текст[тек])>=ord('а'))and(ord(текст[тек])<=ord('€'))or
          (ord(текст[тек])>=ord('0'))and(ord(текст[тек])<=ord('9'))or
          (текст[тек]='_') do
          lstrcatc(ресЋекс—трока,текст[тек]);  inc(тек);
        end;|
      '"'://строка
        ресЋексема:=лекс—трока;
        ресЋекс—трока[0]:='\0';
        inc(тек);
        while (текст[тек]<>'"')and(текст[тек]<>'\0') do
          lstrcatc(ресЋекс—трока,текст[тек]); inc(тек);
        end;
        if текст[тек]='"'
          then inc(тек);
          else ресЋексќшибка:=true;
        end;|
      '0'..'9'://число
        ресЋексема:=лекс÷елое;
        ресЋекс÷елое:=ord(текст[тек])-ord('0');
        ресЋекс—трока[0]:='\0';
        lstrcatc(ресЋекс—трока,текст[тек]); inc(тек);
        while (ord(текст[тек])>=ord('0'))and(ord(текст[тек])<=ord('9')) do
          ресЋекс÷елое:=ресЋекс÷елое*10+ord(текст[тек])-ord('0');
          lstrcatc(ресЋекс—трока,текст[тек]); inc(тек);
        end;|
    else //символ
      ресЋексема:=лекс—имвол;
      ресЋекс—имвол:=текст[тек];
      inc(тек);
    end
  end
end рес—канер;

//----------- Ѕлок из текста ------------

procedure ресЅлок»з“екста(текст:pstr; бит¬есьƒиалог:boolean):boolean;
var тек:integer; стр:string[maxText]; битћинус:boolean; окно:HWND;
begin
  with resDlg do
    if бит¬есьƒиалог then
      dTop:=-1;
    end;
  //сброс блока
    for тек:=1 to dTop do
      рес”становитьЅлок(тек,false);
    end;
    тек:=0;
    ресЋексќшибка:=false;
    рес—канер(текст,тек);
    while (ресЋексема=лекс»дент)and(
      (lstrcmp(ресЋекс—трока,nameREZ[carSet][rCONTROL])=0)or
      (lstrcmp(ресЋекс—трока,nameREZ[carSet][rDIALOG])=0)) do
    //новый элемент
      if dTop=maxItem
        then ресЋексќшибка:=true;
        else inc(dTop)
      end;
      if dTop=0 then
        окно:=dItems^[dTop]^.iWnd;
      end;
      dItems^[dTop]:=memAlloc(sizeof(recItem));
      with dItems^[dTop]^ do
      //текст
        рес—канер(текст,тек);
        ресЋексќшибка:=not (ресЋексема=лекс—трока);
        iText:=memAlloc(lstrlen(ресЋекс—трока)+1);
        lstrcpy(iText,ресЋекс—трока);
      //идентификатор
        рес—канер(текст,тек);
        ресЋексќшибка:=not ((ресЋексема=лекс—имвол)and(ресЋекс—имвол=','));
        рес—канер(текст,тек);
        ресЋексќшибка:=not ((ресЋексема=лекс»дент)or(ресЋексема=лекс÷елое)or
          (ресЋексема=лекс—имвол)and(ресЋекс—имвол='-'));
        битћинус:=(ресЋексема=лекс—имвол)and(ресЋекс—имвол='-');
        if битћинус then
          рес—канер(текст,тек);
          ресЋексќшибка:=not ((ресЋексема=лекс»дент)or(ресЋексема=лекс÷елое));
        end;
        iId:=memAlloc(lstrlen(ресЋекс—трока)+2);
        if битћинус then
          lstrcpy(iId,"-");
        end;
        lstrcpy(iId,ресЋекс—трока);
      //класс
        рес—канер(текст,тек);
        ресЋексќшибка:=not ((ресЋексема=лекс—имвол)and(ресЋекс—имвол=','));
        рес—канер(текст,тек);
        ресЋексќшибка:=not (ресЋексема=лекс—трока);
        iClass:=memAlloc(lstrlen(ресЋекс—трока)+1);
        lstrcpy(iClass,ресЋекс—трока);
      //стили
        рес—канер(текст,тек);
        ресЋексќшибка:=not ((ресЋексема=лекс—имвол)and(ресЋекс—имвол=','));
        рес—канер(текст,тек);
        iTop:=0;
        iStyles:=memAlloc(sizeof(arrStyles));
        while (ресЋексема=лекс»дент)or(ресЋексема=лекс÷елое) do
          if iTop=maxStyle
            then ресЋексќшибка:=true;
            else inc(iTop)
          end;
          iStyles^[iTop]:=memAlloc(lstrlen(ресЋекс—трока)+1);
          lstrcpy(iStyles^[iTop],ресЋекс—трока);
          рес—канер(текст,тек);
          if (ресЋексема=лекс—имвол)and(ресЋекс—имвол='|') then
            рес—канер(текст,тек);
          end
        end;
      //размеры
        ресЋексќшибка:=not ((ресЋексема=лекс—имвол)and(ресЋекс—имвол=','));
        рес—канер(текст,тек);
        with iRect do
        //x
          ресЋексќшибка:=not (ресЋексема=лекс÷елое);
          x:=ресЋекс÷елое;
          рес—канер(текст,тек);
          ресЋексќшибка:=not ((ресЋексема=лекс—имвол)and(ресЋекс—имвол=','));
          рес—канер(текст,тек);
        //y
          ресЋексќшибка:=not (ресЋексема=лекс÷елое);
          y:=ресЋекс÷елое;
          рес—канер(текст,тек);
          ресЋексќшибка:=not ((ресЋексема=лекс—имвол)and(ресЋекс—имвол=','));
          рес—канер(текст,тек);
        //cx
          ресЋексќшибка:=not (ресЋексема=лекс÷елое);
          dx:=ресЋекс÷елое;
          рес—канер(текст,тек);
          ресЋексќшибка:=not ((ресЋексема=лекс—имвол)and(ресЋекс—имвол=','));
          рес—канер(текст,тек);
        //cy
          ресЋексќшибка:=not (ресЋексема=лекс÷елое);
          dy:=ресЋекс÷елое;
          рес—канер(текст,тек);
        end;
        if dTop=0
          then iWnd:=окно;
          else рес—оздќкноЁлем(dTop);
        end;
      end
    end
  end;
//  if ресЋексќшибка then lstrdel(текст,0,тек); mbI(тек,текст) end;
  return not ресЋексќшибка
end ресЅлок»з“екста;

//----------- Ѕлок в текст ------------

procedure ресЅлок¬“екст(текст:pstr; бит¬есьƒиалог:boolean);
var элемент,тек:integer; стр:string[maxText];
begin
  with resDlg do
    текст[0]:='\0';
    for элемент:=0 to dTop do
    with dItems^[элемент]^,iRect do
    if iBlock and(элемент>0) or бит¬есьƒиалог then
      lstrcat(текст,"\13\10  ");
      if элемент=0
        then lstrcat(текст,nameREZ[carSet][rDIALOG])
        else lstrcat(текст,nameREZ[carSet][rCONTROL])
      end;
      lstrcat(текст,' "'); lstrcat(текст,iText); lstrcat(текст,'",');
      lstrcat(текст,iId);
      lstrcatc(текст,','); lstrcatc(текст,'"'); lstrcat(текст,iClass); lstrcatc(текст,'"');  lstrcatc(текст,',');
      if iTop=0 then lstrcatc(текст,'0')
      else
      for тек:=1 to iTop do
        lstrcat(текст,iStyles^[тек]);
        if тек<iTop then
          lstrcat(текст," | ");
        end
      end end;
      lstrcatc(текст,',');
      wvsprintf(стр,'%li,',addr(x)); lstrcat(текст,стр);
      wvsprintf(стр,'%li,',addr(y)); lstrcat(текст,стр);
      wvsprintf(стр,'%li,',addr(dx)); lstrcat(текст,стр);
      wvsprintf(стр,'%li',addr(dy)); lstrcat(текст,стр);
    end end end
  end
end ресЅлок¬“екст;

//-----------  опировать в clipboard ------------

procedure ресЅлок опировать();
var текст,буфер:pstr;
begin
  текст:=memAlloc(maxResMem);
  ресЅлок¬“екст(текст,false);
  буфер:=memAlloc(lstrlen(текст)+1);
  lstrcpy(буфер,текст);
  memFree(текст);
  if OpenClipboard(editWnd) then
    EmptyClipboard();
    SetClipboardData(CF_TEXT,HANDLE(буфер));
    CloseClipboard()
  else
    memFree(буфер);
    mbS(_ќЎ»Ѕ ј_Clipboard_зан€т_другим_приложением[envER])
  end
end ресЅлок опировать;

//----------- ¬ставить из clipboard ------------

procedure ресЅлок¬ставить();
var текст,буфер:pstr;
begin
  if not OpenClipboard(editWnd) then
    mbS(_ќЎ»Ѕ ј_Clipboard_зан€т_другим_приложением[envER])
  else
    if (IsClipboardFormatAvailable(CF_TEXT)=false)and(IsClipboardFormatAvailable(CF_OEMTEXT)=false) then
      mbI(GetPriorityClipboardFormat(nil,0),_ќЎ»Ѕ ј_Ќеверный_формат_данных_в_Clipboard[envER])
    else
      текст:=pstr(GetClipboardData(CF_TEXT));
      if текст<>nil then
        if not ресЅлок»з“екста(текст,false) then
          mbS(_Ќеверные_данные_в_Clipboard[envER])
        end
      end
    end;
    CloseClipboard()
  end
end ресЅлок¬ставить;

//----------- ”далить блок ------------

procedure ресЅлок”далить(бит¬есьƒиалог:boolean);
var элемент,тек:integer;
begin
  with resDlg do
    for элемент:=dTop downto 0 do
    with dItems^[элемент]^ do
    if iBlock and(элемент>0) or бит¬есьƒиалог then
      if элемент>0 then
        DestroyWindow(iWnd);
      end;
      memFree(iText);
      memFree(iId);
      memFree(iClass);
      for тек:=1 to iTop do
        memFree(iStyles^[тек]);
      end;
      memFree(iStyles);
      memFree(dItems^[элемент]);
      for тек:=элемент to dTop-1 do
        dItems^[тек]:=dItems^[тек+1];
      end;
      dec(dTop);
    end end end;
    if (resDlgItem>dTop)and(dTop>0) then
      рес»зм‘окус(dItems^[dTop]^.iWnd);
    end;
  end
end ресЅлок”далить;

//----------- ¬ыделить все ------------

procedure ресЅлок¬ыделить¬се();
var тек:integer;
begin
  with resDlg do
    for тек:=1 to dTop do
      рес”становитьЅлок(тек,true);
    end
  end
end ресЅлок¬ыделить¬се;

//----------- ¬ыравнивание ------------

procedure ресЅлок¬ыровн€ть(команда:classDlgComm);
var элемент,размер:integer;
begin
  with resDlg do
  //определение сдвига (размера)
    размер:=0;
    for элемент:=1 to dTop do
    with dItems^[элемент]^,iRect do
    if iBlock then
      case команда of
        cdAlignLeft:if (размер=0)or(размер>=x) then размер:=x end;|
        cdAlignRight:if (размер=0)or(размер<=x+dx) then размер:=x+dx end;|
        cdAlignUp:if (размер=0)or(размер>=y) then размер:=y end;|
        cdAlignDown:if (размер=0)or(размер<=y+dy) then размер:=y+dy end;|
        cdAlignSizeX:if (размер=0)or(размер<=dx) then размер:=dx end;|
        cdAlignSizeY:if (размер=0)or(размер<=dy) then размер:=dy end;|
      end
    end end end;
  //изменение позиции (размера)
    for элемент:=1 to dTop do
    with dItems^[элемент]^,iRect do
    if iBlock then
      case команда of
        cdAlignLeft:x:=размер;|
        cdAlignRight:x:=размер-dx;|
        cdAlignUp:y:=размер;|
        cdAlignDown:y:=размер-dy;|
        cdAlignSizeX:dx:=размер;|
        cdAlignSizeY:dy:=размер;|
      end;
      MoveWindow(iWnd,x,y,dx,dy,true);
    end end end;
  end
end ресЅлок¬ыровн€ть;

//----- «апомнить диалог дл€ отката -------

procedure рес«апомнитьќткат();
var текст:pstr; тек:integer;
begin
  текст:=memAlloc(maxResMem);
  ресЅлок¬“екст(текст,true);
  if рес¬ерхќткат<maxResUndo then inc(рес¬ерхќткат);
  else
    for тек:=1 to рес¬ерхќткат-1 do
      ресќткат[тек]:=ресќткат[тек+1];
    end
  end;
  ресќткат[рес¬ерхќткат]:=memAlloc(lstrlen(текст)+1);
  lstrcpy(ресќткат[рес¬ерхќткат],текст);
  memFree(текст);
end рес«апомнитьќткат;

//----- —овершить откат -------

procedure рес¬ыполнитьќткат();
begin
  if рес¬ерхќткат>0 then
    ресЅлок”далить(true);
    if not ресЅлок»з“екста(ресќткат[рес¬ерхќткат],true) then
      mbS(_—истемна€_ошибка_Ќеверные_данные_в_буфере_отката_[envER]);
      mbS(ресќткат[рес¬ерхќткат]);
    end;
    with resDlg,dItems^[0]^,iRect do
//      MoveWindow(iWnd,x,y,dx,dy,true);
      if (resDlgItem<0)or(resDlgItem>dTop) then
        resDlgItem:=0
      end;
    end;
    memFree(ресќткат[рес¬ерхќткат]);
    dec(рес¬ерхќткат);
  end
end рес¬ыполнитьќткат;

//----- ќсвободить пам€ть отката -------

procedure ресќсвободитьќткат();
var тек:integer;
begin
  for тек:=1 to рес¬ерхќткат do
    memFree(ресќткат[тек]);
  end
end ресќсвободитьќткат;

//===============================================
//      ƒ»јЋќ√ќ¬јя ‘”Ќ ÷»я –≈ƒј “ќ–ј ƒ»јЋќ√ќ¬
//===============================================

//----- ƒиалог генерации текста -------

const
  ид√енѕрог=101;
  ид√ен лип=102;
  ид√ен“екст=103;
  ид√ен¬ызов=104;
  ид√енќк=120;
  ид√енќтмена=121;

const DLG_GEN=stringER{"DLG_GEN_R","DLG_GEN_E"};
dialog DLG_GEN_R 45,43,198,64,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "√енераци€ текста диалога"
begin
  control "¬ставка текста диалога в текст программы",ид√енѕрог,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,4,168,10
  control "¬ставка текста диалога в clipboard",ид√ен лип,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,14,168,10
  control "√енераци€ текста диалоговой функции",ид√ен“екст,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,26,168,10
  control "√енераци€ текста вызова диалога",ид√ен¬ызов,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,36,168,10
  control "ќк",ид√енќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,46,49,40,10
  control "ќтмена",ид√енќтмена,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,96,49,40,10
end;
dialog DLG_GEN_E 45,43,198,64,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Dialog text generation"
begin
  control "Insert dialog into the program",ид√енѕрог,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,4,168,10
  control "Insert dialog into the  clipboard",ид√ен лип,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,14,168,10
  control "Dialog function text generation",ид√ен“екст,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,26,168,10
  control "Dialog call text generation",ид√ен¬ызов,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,36,168,10
  control "Ok",ид√енќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,46,49,40,10
  control "Cancel",ид√енќтмена,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,96,49,40,10
end;

//----- ƒиалогова€ функци€ генерации текста -------

procedure ресѕроц√енераци€(окно:HWND; сооб,вѕарам,лѕарам:integer):boolean;
//лѕарам - бит нового диалога
var тек:integer; стр:string[maxText];
begin
  case сооб of
    WM_INITDIALOG:
      if boolean(лѕарам) then
        SendDlgItemMessage(окно,ид√енѕрог,BM_SETCHECK,0,0);
        SendDlgItemMessage(окно,ид√ен лип,BM_SETCHECK,1,0);
        SendDlgItemMessage(окно,ид√ен“екст,BM_SETCHECK,1,0);
        SendDlgItemMessage(окно,ид√ен¬ызов,BM_SETCHECK,1,0);
      else
        SendDlgItemMessage(окно,ид√енѕрог,BM_SETCHECK,1,0);
        SendDlgItemMessage(окно,ид√ен лип,BM_SETCHECK,0,0);
        SendDlgItemMessage(окно,ид√ен“екст,BM_SETCHECK,0,0);
        SendDlgItemMessage(окно,ид√ен¬ызов,BM_SETCHECK,0,0);
      end;|
    WM_COMMAND:case loword(вѕарам) of
      BN_CLICKED:case loword(лѕарам) of
        ид√енѕрог:SendDlgItemMessage(окно,ид√ен лип,BM_SETCHECK,0,0);|
        ид√ен лип:SendDlgItemMessage(окно,ид√ен лип,BM_SETCHECK,1,0);|
      end;|
      IDOK,ид√енќк:
        ресЅит¬ѕрограмму:=SendDlgItemMessage(окно,ид√енѕрог,BM_GETCHECK,0,0)=BST_CHECKED;
        ресЅит“екст‘ункции:=SendDlgItemMessage(окно,ид√ен“екст,BM_GETCHECK,0,0)=BST_CHECKED;
        ресЅит“екст¬ызова:=SendDlgItemMessage(окно,ид√ен¬ызов,BM_GETCHECK,0,0)=BST_CHECKED;
        EndDialog(окно,1);|
      IDCANCEL,ид√енќтмена:EndDialog(окно,0);|
    end;|
  else return false
  end;
  return true
end ресѕроц√енераци€;

//----- ¬ызов диалога генерации текста -------

procedure рес√енерировать(окно:HWND; битЌовыйƒиалог:boolean):boolean;
begin
  return boolean(DialogBoxParam(hINSTANCE,DLG_GEN[envER],окно,addr(ресѕроц√енераци€),cardinal(битЌовыйƒиалог)));
end рес√енерировать;

//----- —оздание статус-строки редактора -------

procedure рес—озд—татус(окно:HWND; бит»ниц:boolean);
var разм:array[classDlgStatus]of integer; рег:RECT; стат:classDlgStatus; тек,ширина:integer;
begin
  if бит»ниц then
    resStatus:=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      nil,окно,0);
  end;
  GetClientRect(окно,рег);
  if not бит»ниц then
  with рег do
    SendMessage(resStatus,WM_SIZE,right-left+1,bottom-top+1);
  end end;
  тек:=0;
  for стат:=dsTextE to resFinStatus do
    ширина:=(рег.right-рег.left+1)*resStatusProc[стат] div 100;
    разм[стат]:=тек+ширина;
    inc(тек,ширина)
  end;
  разм[resFinStatus]:=-1;
  SendMessage(resStatus,SB_SETPARTS,ord(resFinStatus)+1,cardinal(addr(разм)));
end рес—озд—татус;

//----------- —оздание меню -------------------

procedure рес—оздћеню():HMENU;
var меню,подменю,подменю2:HMENU; тек,вар:integer; стр:string[maxText]; команда:classDlgComm;
begin
  меню:=CreateMenu();
//меню _Ќовый[envER]
  подменю:=CreatePopupMenu();
  for тек:=1 to resTopClass do
  with resClasses^[тек] do
    подменю2:=CreatePopupMenu();
    for вар:=1 to claTop do
      lstrcpy(стр,claList[вар]);
      lstrdel(стр,lstrposc(',',стр),999);
      AppendMenu(подменю2,MF_STRING,idDlgBaseNew+тек*100+вар,стр);
    end;
    AppendMenu(подменю,MF_POPUP,подменю2,resClasses^[тек].claMenu);
  end end;
  AppendMenu(меню,MF_POPUP,подменю,setDlgCommand[envER][cdNew].name);
//меню _ѕравка[envER]
  подменю:=CreatePopupMenu();
  for команда:=cdEditUndo to cdEditAll do
    if (команда=cdEditCut)or(команда=cdEditAll) then
      AppendMenu(подменю,MF_SEPARATOR,0,nil);
    end;
    AppendMenu(подменю,MF_STRING,idDlgBase+ord(команда),setDlgCommand[envER][команда].name);
  end;
  AppendMenu(меню,MF_POPUP,подменю,setDlgCommand[envER][cdEdit].name);
//меню _¬ыровн€ть[envER]
  подменю:=CreatePopupMenu();
  for команда:=cdAlignLeft to cdAlignSizeY do
    if команда=cdAlignSizeX then
      AppendMenu(подменю,MF_SEPARATOR,0,nil);
    end;
    AppendMenu(подменю,MF_STRING,idDlgBase+ord(команда),setDlgCommand[envER][команда].name);
  end;
  AppendMenu(меню,MF_POPUP,подменю,setDlgCommand[envER][cdAlign].name);
//прочие пункты
  AppendMenu(меню,MF_STRING,idDlgBase+ord(cdParam),setDlgCommand[envER][cdParam].name);
  AppendMenu(меню,MF_STRING,idDlgBase+ord(cdFont),setDlgCommand[envER][cdFont].name);
  AppendMenu(меню,MF_STRING,idDlgBase+ord(cdOk),setDlgCommand[envER][cdOk].name);
  AppendMenu(меню,MF_STRING,idDlgBase+ord(cdCancel),setDlgCommand[envER][cdCancel].name);
  return меню;
end рес—оздћеню;

//----- ƒиалог редактора диалогов -----

const DLG_RES=stringER{"DLG_RES_R","DLG_RES_E"};
dialog DLG_RES_R 80,48,160,96,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "–едактор диалогов"
begin
end;
dialog DLG_RES_E 80,48,160,96,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "Dialog editor"
begin
end;

//----- ƒиалогова€ функци€ редактора диалогов -----

procedure ресѕроц–есурсы(окно:HWND; сооб,вѕарам,лѕарам:integer):boolean;
var тек:integer; стр:string[maxText];
begin
  case сооб of
    WM_INITDIALOG:
      resDlgWnd:=окно;
      тек:=GetSystemMetrics(SM_CYCAPTION);
      MoveWindow(окно,тек,тек,GetSystemMetrics(SM_CXSCREEN)-тек*2,
        GetSystemMetrics(SM_CYSCREEN)-GetSystemMetrics(SM_CYCAPTION)*3 div 2-тек*2,true);
      SetMenu(окно,рес—оздћеню());
      рес—озд—татус(окно,true);
      resDlgItem:=0;
      рес—оздќкноƒлг(окно);
      for тек:=1 to resDlg.dTop do
        рес—оздќкноЁлем(тек);
      end;
      рес¬ерхќткат:=0;
      рес«апомнитьќткат();
      рес—оздать нопки(окно);
      рес—татусќбнов(resDlgItem);|
    WM_SIZE:рес—озд—татус(окно,false);|
    WM_NOTIFY:ресЌотификаци€(лѕарам);|
    WM_COMMAND:case loword(вѕарам) of
      idDlgBaseNew..idDlgBaseNew+5000:рес«апомнитьќткат(); ресƒобавитьЁлем(loword(вѕарам)-idDlgBaseNew);|
      idDlgBase+cdEditUndo:рес¬ыполнитьќткат();|
      idDlgBase+cdEditCut:рес«апомнитьќткат(); ресЅлок опировать(); ресЅлок”далить(false);|
      idDlgBase+cdEditCopy:рес«апомнитьќткат(); ресЅлок опировать();|
      idDlgBase+cdEditPaste:рес«апомнитьќткат(); ресЅлок¬ставить();|
      idDlgBase+cdEditDel:рес«апомнитьќткат(); ресЅлок”далить(false);|
      idDlgBase+cdEditAll:ресЅлок¬ыделить¬се();|
      idDlgBase+cdAlignLeft..idDlgBase+cdAlignSizeY:рес«апомнитьќткат(); ресЅлок¬ыровн€ть(classDlgComm(loword(вѕарам)-idDlgBase));|
      idDlgBase+cdParam:рес«апомнитьќткат(); рес орр—тили(окно);|
      idDlgBase+cdFont:рес оррЎрифт(окно);|
      idDlgBase+cdOk:
        if рес√енерировать(окно,ресЅитЌовыйƒиалог) then
          ресќсвободитьќткат();
          EndDialog(окно,1);
        end;|
      IDCANCEL,idDlgBase+cdCancel:ресќсвободитьќткат(); EndDialog(окно,0);|
    end;|
    WM_KEYDOWN:case loword(вѕарам) of
      VK_DELETE:SendMessage(окно,WM_COMMAND,idDlgBase+ord(cdEditDel),0);|
//      VK_RETURN:SendMessage(окно,WM_COMMAND,idDlgBase+ord(cdParam),0);|
//      VK_TAB:with resDlg do
//        if resDlgItem<dTop then рес»зм‘окус(dItems^[resDlgItem+1]^.iWnd);
//        elsif resDlgItem=dTop then рес»зм‘окус(dItems^[0]^.iWnd);
//        elsif dTop>0 then рес»зм‘окус(dItems^[1]^.iWnd);
//        end;
//      end;|
    end;|
  else return false
  end;
  return true
end ресѕроц–есурсы;

//===============================================
//              ќ––≈ ÷»я ƒ»јЋќ√ј
//===============================================

//-------------- ѕустой диалог ----------------

procedure ресѕустойƒиалог();
var dlgx,dlgy:integer;
begin
  with resDlg do
    dMenu:=nil;
    dTop:=2;
    dItems:=memAlloc(sizeof(arrItem));
//диалог
    dItems^[0]:=memAlloc(sizeof(recItem));
    with dItems^[0]^ do
      рес–азместить(iText,_ƒиалог[envER]);
      рес–азместить(iClass,nil);
      рес–азместить(iId,"DLG");
      with iRect do
        x:=GetSystemMetrics(SM_CXSCREEN)*25 div 100;
        y:=GetSystemMetrics(SM_CYSCREEN)*20 div 100;
        dx:=GetSystemMetrics(SM_CXSCREEN)*50 div 100;
        dy:=GetSystemMetrics(SM_CYSCREEN)*40 div 100;
        dlgx:=dx;
        dlgy:=dy-GetSystemMetrics(SM_CYCAPTION);
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      ресƒобав—тиль(iStyles,iTop,"WS_POPUP");
      ресƒобав—тиль(iStyles,iTop,"WS_CAPTION");
      ресƒобав—тиль(iStyles,iTop,"WS_SYSMENU");
      ресƒобав—тиль(iStyles,iTop,"DS_MODALFRAME");
    end;
//элемент 1
    dItems^[1]:=memAlloc(sizeof(recItem));
    with dItems^[1]^ do
      рес–азместить(iText,_ќк[envER]);
      рес–азместить(iId,"IDOK");
      рес–азместить(iClass,"Button");
      with iRect do
        x:=dlgx*20 div 100;
        y:=dlgy*90 div 100;
        dx:=dlgx*28 div 100;
        dy:=dlgy*10 div 100;
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      ресƒобав—тиль(iStyles,iTop,"WS_CHILD");
      ресƒобав—тиль(iStyles,iTop,"WS_VISIBLE");
      ресƒобав—тиль(iStyles,iTop,"BS_DEFPUSHBUTTON");
    end;
//{элемент 2}
    dItems^[2]:=memAlloc(sizeof(recItem));
    with dItems^[2]^ do
      рес–азместить(iText,_ќтмена[envER]);
      рес–азместить(iId,"IDCANCEL");
      рес–азместить(iClass,"Button");
      with iRect do
        x:=dlgx*52 div 100;
        y:=dlgy*90 div 100;
        dx:=dlgx*28 div 100;
        dy:=dlgy*10 div 100;
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      ресƒобав—тиль(iStyles,iTop,"WS_CHILD");
      ресƒобав—тиль(iStyles,iTop,"WS_VISIBLE");
      ресƒобав—тиль(iStyles,iTop,"BS_PUSHBUTTON");
    end
  end;
end ресѕустойƒиалог;

//------------  оррекци€ диалога --------------

procedure рес оррƒиалог(битЌовый:boolean):pstr;
var i:integer; буф:pstr;
begin
  if битЌовый then
    ресѕустойƒиалог();
  end;
  if boolean(DialogBoxParam(hINSTANCE,DLG_RES[envER],mainWnd,addr(ресѕроц–есурсы),0)) then
    буф:=memAlloc(maxBufClip);
    resDlgToTxt(буф);
    return буф;
  else return nil
  end;  
end рес оррƒиалог;

//------- –егистраци€ классов диалога ---------

procedure рес»ниц лассы();
var класс:WNDCLASS;
begin
  класс.hInstance:=hINSTANCE;
  with класс do
    style:=CS_HREDRAW | CS_VREDRAW;
    cbClsExtra:=0;
    cbWndExtra:=0;
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=GetStockObject(GRAY_BRUSH);
    lpszMenuName:=nil;
    lpfnWndProc:=addr(ресѕроцЁлем);
    lpszClassName:=классЁлемента;
  end;
  if RegisterClass(класс)=0 then
    mbS(_ќшибка_регистрации_класса_элемента[envER]);
  end;
  with класс do
    lpfnWndProc:=addr(ресѕроцƒлг);
    lpszClassName:=классƒиалога;
    hbrBackground:=CreateHatchBrush(HS_CROSS,0);
  end;
  if RegisterClass(класс)=0 then
    mbS(_ќшибка_регистрации_класса_диалога[envER]);
  end;
end рес»ниц лассы;

//===============================================
//             “–јЌ—Ћя÷»я –≈—”–—ќ¬
//===============================================

//----------- »нициализаци€ потока ------------

procedure resOpen(var S:recStream; cart:integer);
begin
  with S,tbMod[cart] do
    lstrcpy(addr(stFile),modNam);
    with txts[txtn[cart]][cart] do
      with stPosLex do f:=1; y:=txtTrackY+txtCarY end;
      with stPosPred do f:=1; y:=txtTrackY+txtCarY end;
      with stErrPos do f:=1; y:=txtTrackY+txtCarY end;
    end;
    stLex:=lexNULL;
    stLexInt:=0;
    stLexStr[0]:=char(0);
    stLexOld[0]:=char(0);
    stLexReal:=0.0;
    stErr:=false;
    stErrText[0]:=char(0);
    stLoad:=false;
    stTxt:=cart;
    stExt:=txtn[cart];
    idDestroy(tbMod[cart].modTab);
    idInitial(tbMod[cart].modTab,cart);
    lexGetLex0(S);
  end
end resOpen;

//--------------- “екст-bmp (иконка) -------------------

procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean;
var S:recStream;
begin
  with S do
    resOpen(S,cart);
    if bitBmp then
      lexAccept00(S,lexREZ,integer(rBITMAP));
      lexAccept00(S,lexNEW,0);
      lexAccept00(S,lexPARSE,integer(pEqv));
    else lexAccept00(S,lexREZ,integer(rICON));
    end;
    lstrcpy(str,stLexStr);
    lexAccept00(S,lexSTR,0);
    if stErr then
//      envSetError(cart,stErrPos.f,stErrPos.y);
//      envUpdate(editWnd);
      MessageBox(0,stErrText,_ќЎ»Ѕ ј[envER],MB_ICONSTOP);
    end;
    return stErr;
  end;
end resTxtToBmp;

//--------------- “екст-диалог ----------------

procedure resTxtToDlg(cart:integer; var начY,конY:integer):boolean;
var S:recStream; bitMin:boolean; str:string[maxText];
begin
  with S,tbMod[cart],resDlg do
    with txts[txtn[cart]][cart] do
      начY:=txtTrackY+txtCarY;
    end;
    resOpen(S,cart);
//инициализаци€ диалога
    dItems:=memAlloc(sizeof(arrItem));
    dTop:=0;
    dItems^[0]:=memAlloc(sizeof(recItem));
    dMenu:=nil;
//  заголовок диалога
    lexAccept00(S,lexREZ,integer(rDIALOG));
    with dItems^[dTop]^ do
     рес–азместить(iId,stLexStr);
     lexAccept00(S,lexNEW,0);
      with iRect do
        x:=ресƒ≈вXY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        y:=ресƒ≈вXY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        dx:=ресƒ≈вXY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        dy:=ресƒ≈вXY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
      end;
//  стили
      iStyles:=memAlloc(sizeof(arrStyles));
      iTop:=1;
      iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
      lstrcpy(iStyles^[iTop],stLexStr);
      case stLex of
        lexINT:lexAccept00(S,lexINT,0);|
        lexNEW:lexAccept00(S,lexNEW,0);|
      end;
      while okPARSE(S,pVer) do
        lexAccept00(S,lexPARSE,integer(pVer));
        if iTop<maxStyle then
          inc(iTop);
        end;
        iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iStyles^[iTop],stLexStr);
        case stLex of
          lexINT:lexAccept00(S,lexINT,0);|
          lexNEW:lexAccept00(S,lexNEW,0);|
        end
      end;
//  заголовок
      if not okPARSE(S,pCol) then iText:=nil
      else
        lexAccept00(S,lexPARSE,integer(pCol));
        iText:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iText,stLexStr);
        lexAccept00(S,lexSTR,0);
      end;
//класс
      iClass:=nil;
      if okPARSE(S,pCol) then
        lexAccept00(S,lexPARSE,integer(pCol));
        if not okPARSE(S,pCol) then
          iClass:=memAlloc(lstrlen(stLexStr)+1);
          lstrcpy(iClass,stLexStr);
          lexAccept00(S,lexSTR,0);
        end
      end;
//фонт
    if not okPARSE(S,pCol) then iFont:=nil
    else
      lexAccept00(S,lexPARSE,integer(pCol));
      iFont:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(iFont,addr(stLexStr));
      lexAccept00(S,lexSTR,0);
      lexAccept00(S,lexPARSE,integer(pCol));
      iSize:=stLexInt; lexAccept00(S,lexINT,0);
    end
    end;
//элементы
    if okREZ(S,rBEGIN) then
      lexAccept00(S,lexREZ,integer(rBEGIN));
      while okREZ(S,rCONTROL) do
      if dTop=maxItem then lexError(S,_—лишком_много_элементов_в_диалоге[envER],nil)
      else
        inc(dTop);
        dItems^[dTop]:=memAlloc(sizeof(recItem));
//  элемент диалога
      with dItems^[dTop]^ do
        lexAccept00(S,lexREZ,integer(rCONTROL));
//  текст
        iText:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iText,stLexStr);
        lexAccept00(S,lexSTR,0);
        lexAccept00(S,lexPARSE,integer(pCol));
//  идентификатор
        bitMin:=false;
        if okPARSE(S,pMin) then
          lexAccept00(S,lexPARSE,integer(pMin));
          bitMin:=true;
        end;
        iId:=memAlloc(lstrlen(stLexStr)+2); iId[0]:=char(0);
        if bitMin then
          lstrcatc(iId,'-');
        end;
        case stLex of
          lexINT:wvsprintf(str,"%li",addr(stLexInt)); lstrcat(iId,str);|
          lexNEW:lstrcat(iId,stLexStr);|
        end;
        case stLex of
          lexINT:lexAccept00(S,lexINT,0);|
          lexNEW:lexAccept00(S,lexNEW,0);|
        end;
        lexAccept00(S,lexPARSE,integer(pCol));
//  класс
        iClass:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iClass,stLexStr);
        lexAccept00(S,lexSTR,0);
        lexAccept00(S,lexPARSE,integer(pCol));
//  стили
        iStyles:=memAlloc(sizeof(arrStyles));
        iTop:=1;
        iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iStyles^[iTop],stLexStr);
        case stLex of
          lexINT:lexAccept00(S,lexINT,0);|
          lexNEW:lexAccept00(S,lexNEW,0);|
        end;
        while okPARSE(S,pVer) do
          lexAccept00(S,lexPARSE,integer(pVer));
          if iTop<maxStyle then
            inc(iTop);
          end;
          iStyles^[iTop]:=memAlloc(lstrlen(stLexStr)+1);
          lstrcpy(iStyles^[iTop],stLexStr);
          case stLex of
            lexINT:lexAccept00(S,lexINT,0);|
            lexNEW:lexAccept00(S,lexNEW,0);|
          end
        end;
        lexAccept00(S,lexPARSE,integer(pCol));
//  размеры
        with iRect do
          x:=ресƒ≈вXY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          y:=ресƒ≈вXY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          dx:=ресƒ≈вXY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          dy:=ресƒ≈вXY(stLexInt,true); lexAccept00(S,lexINT,0);
        end
      end
      end end;
      lexAccept00(S,lexREZ,integer(rEND));
      конY:=stPosLex.y;
      lexAccept00(S,lexPARSE,integer(pSem));
    end;
    if stErr then
//      envSetError(cart,stErrPos.f,stErrPos.y);
//      envUpdate(editWnd);
      MessageBox(0,stErrText,_ќЎ»Ѕ ј[envER],MB_ICONSTOP);
    end;
    return stErr
  end;
end resTxtToDlg;

//--------------- “екст диалоговой функции (ћќƒ”Ћј) ----------------

procedure resDlgFunMODULA(txt:pstr);
var i:integer;
begin
with resDlg do
if ресЅит“екст‘ункции then
  lstrcat(txt,"\13\10");
//procedure проц»м€ƒиалога(wnd:HWND; message,wparam,lparam:integer):boolean;
  lstrcat(txt,nameREZ[carSet][rPROCEDURE]); lstrcat(txt," proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"(wnd:HWND; message,wparam,lparam:integer):boolean;\13\10");
//begin case message of
  lstrcat(txt,nameREZ[carSet][rBEGIN]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," message "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//WM_INITDIALOG:| WM_COMMAND:case loword(wparam) of
  lstrcat(txt,"    WM_INITDIALOG:|\13\10");
  lstrcat(txt,"    WM_COMMAND:"); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rLOWORD]); lstrcat(txt,"(wparam) "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//IDOK:EndDialog(wnd,1);| IDCANCEL:EndDialog(wnd,0);|
  lstrcat(txt,"      IDOK:EndDialog(wnd,1);|\13\10");
  lstrcat(txt,"      IDCANCEL:EndDialog(wnd,0);|\13\10");
//end;| else return false end; return true
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";|\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rELSE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rFALSE]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rTRUE]); lstrcat(txt,"\13\10");
//end проц»м€ƒиалога;
  lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt," proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,";\13\10");
end;

//-----------------текст вызова диалога
if ресЅит“екст¬ызова then
//DialogBoxParam(hINSTANCE,_»м€ƒиалога[envER],0,addr(проц»м€ƒиалога),0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,addr(proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"),0);\13\10"); 
end;

end
end resDlgFunMODULA;

//--------------- “екст диалоговой функции (—и) ----------------

procedure resDlgFunC(txt:pstr);
var i:integer;
begin
with resDlg do
if ресЅит“екст‘ункции then
  lstrcat(txt,"\13\10");
//boolean проц»м€ƒиалога(HWND wnd,int message,int wparam,int lparam)
  lstrcat(txt,"bool proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"(HWND wnd,int message,int wparam,int lparam)\13\10");
//{ switch(message) {
  lstrcat(txt,"{\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rSWITCH]); lstrcat(txt,"(message) {"); lstrcat(txt,"\13\10");
//case WM_INITDIALOG:break; case WM_COMMAND:switch(loword(wparam)) {
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," WM_INITDIALOG:"); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," WM_COMMAND:"); lstrcat(txt,nameREZ[carSet][rSWITCH]); lstrcat(txt,"("); lstrcat(txt,nameREZ[carSet][rLOWORD]); lstrcat(txt,"(wparam)) {"); lstrcat(txt,"\13\10");
//case IDOK:EndDialog(wnd,1); break; case IDCANCEL:EndDialog(окно,0); break;
  lstrcat(txt,"      "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," IDOK:EndDialog(wnd,1); "); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
  lstrcat(txt,"      "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," IDCANCEL:EndDialog(wnd,0); "); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
//default:return false; break;
  lstrcat(txt,"      "); lstrcat(txt,nameREZ[carSet][rDEFAULT]); lstrcat(txt,":");
  lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rFALSE]); lstrcat(txt,"; ");
  lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
//} break; } return true;
  lstrcat(txt,"    "); lstrcat(txt,"} "); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,"}\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rTRUE]); lstrcat(txt,";\13\10");
//}
  lstrcat(txt,"}\13\10");
end;

//-----------------текст вызова диалога
if ресЅит“екст¬ызова then
//DialogBoxParam(hINSTANCE,_»м€ƒиалога[envER],0,&проц»м€ƒиалога,0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,&proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,",0);\13\10"); 
end;

end
end resDlgFunC;

//--------------- “екст диалоговой функции (ѕј— јЋ№) ----------------

procedure resDlgFunPASCAL(txt:pstr);
var i:integer;
begin
with resDlg do
if ресЅит“екст‘ункции then
  lstrcat(txt,"\13\10");
//function проц»м€ƒиалога(wnd:HWND; message,wparam,lparam:integer):boolean;
  lstrcat(txt,nameREZ[carSet][rFUNCTION]); lstrcat(txt," proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"(wnd:HWND; message,wparam,lparam:integer):boolean;\13\10");
//begin case message of
  lstrcat(txt,nameREZ[carSet][rBEGIN]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," message "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//WM_INITDIALOG:; WM_COMMAND:case loword(wparam) of
  lstrcat(txt,"    WM_INITDIALOG:;\13\10");
  lstrcat(txt,"    WM_COMMAND:"); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rLOWORD]); lstrcat(txt,"(wparam) "); lstrcat(txt,nameREZ[carSet][rOF]);  lstrcat(txt,"\13\10");
//IDOK:EndDialog(wnd,1); IDCANCEL:EndDialog(wnd,0);
  lstrcat(txt,"      IDOK:EndDialog(wnd,1);\13\10");
  lstrcat(txt,"      IDCANCEL:EndDialog(wnd,0);\13\10");
//end; else return false end; return true
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rELSE]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rFALSE]); lstrcat(txt,"\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rRETURN]); lstrcat(txt," "); lstrcat(txt,nameREZ[carSet][rTRUE]); lstrcat(txt,"\13\10");
//end;
  lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt,";\13\10");
end;

//-----------------текст вызова диалога
if ресЅит“екст¬ызова then
//DialogBoxParam(hINSTANCE,_»м€ƒиалога[envER],0,addr(проц»м€ƒиалога),0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,addr(proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"),0);\13\10"); 
end;

end
end resDlgFunPASCAL;

//--------------- ƒиалог-текст ----------------

procedure resDlgToTxt;
var s:string[maxText]; i,j,k:integer;
begin
with resDlg do
  txt[0]:=char(0);
//заголовок
  with dItems^[0]^,iRect do
    lstrcat(txt,nameREZ[carSet][rDIALOG]); lstrcatc(txt,' ');
    lstrcat(txt,iId); lstrcatc(txt,' ');
    k:=ресXYвƒ≈(x,false); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=ресXYвƒ≈(y,true); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=ресXYвƒ≈(dx,false); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=ресXYвƒ≈(dy,true); wvsprintf(s,"%li,\13\10  ",addr(k)); lstrcat(txt,s);
    if iTop=0 then lstrcatc(txt,'0')
    else
    for j:=1 to iTop do
      lstrcat(txt,iStyles^[j]);
      if j<iTop then
        lstrcat(txt," | ");
      end
    end end;
    lstrcat(txt,",\13\10  ");
    lstrcatc(txt,'"');
    lstrcat(txt,iText);
    lstrcatc(txt,'"');
    if (iClass<>nil)and(iClass[0]<>char(0)) then
      lstrcat(txt,',"');
      lstrcat(txt,iClass);
      lstrcatc(txt,'"');
    end;
    if not((iClass<>nil)and(iClass[0]<>char(0)))and(iFont<>nil)and(iFont[0]<>char(0)) then
      lstrcatc(txt,',');
    end;
    if (iFont<>nil)and(iFont[0]<>char(0)) then
      lstrcat(txt,',"');
      lstrcat(txt,iFont);
      lstrcat(txt,'",');
      wvsprintf(s,"%li",addr(iSize)); lstrcat(txt,s);
    end
  end;
//элементы
  lstrcat(txt,"\13\10");
  lstrcat(txt,nameREZ[carSet][rBEGIN]);
  for i:=1 to dTop do
  with dItems^[i]^,iRect do
    lstrcat(txt,"\13\10  ");
    lstrcat(txt,nameREZ[carSet][rCONTROL]);
    lstrcat(txt,' "'); lstrcat(txt,iText); lstrcat(txt,'",');
    lstrcat(txt,iId);
    lstrcatc(txt,','); lstrcatc(txt,'"'); lstrcat(txt,iClass); lstrcatc(txt,'"');  lstrcatc(txt,',');
    if iTop=0 then lstrcatc(txt,'0')
    else
    for j:=1 to iTop do
      lstrcat(txt,iStyles^[j]);
      if j<iTop then
        lstrcat(txt," | ");
      end
    end end;
    lstrcatc(txt,',');
    k:=ресXYвƒ≈(x,false); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=ресXYвƒ≈(y,true); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=ресXYвƒ≈(dx,false); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=ресXYвƒ≈(dy,true); wvsprintf(s,'%li',addr(k)); lstrcat(txt,s);
  end end;
  lstrcat(txt,"\13\10");
  lstrcat(txt,nameREZ[carSet][rEND]);
  lstrcat(txt,";\13\10");

//-----------------текст диалоговой функции и вызова диалога
  case traLANG of
    langMODULA:resDlgFunMODULA(txt);|
    langC:resDlgFunC(txt);|
    langPASCAL:resDlgFunPASCAL(txt);|
  end;

end
end resDlgToTxt;

//===============================================
//             Ќј—“–ќ… » –≈ƒј “ќ–ј ƒ»јЋќ√ќ¬
//===============================================

//---------- очистка параметров диалога -----------

procedure ресѕарам„истить(парам:pClass; var верх:integer);
var кл,тек:integer;
begin
  for кл:=1 to верх do
  with парам^[кл] do
    for тек:=1 to claTop do
      memFree(claList[тек]);
    end;
    claTop:=0;
  end end;
  верх:=0;
end ресѕарам„истить;

//---------- копирование параметров диалога -----------

procedure ресѕарам опи(исх,назн:pClass; var верх»сх,верхЌазн:integer);
var кл,тек:integer;
begin
  верхЌазн:=верх»сх;
  for кл:=1 to верх»сх do
    назн^[кл]:=исх^[кл];
    with назн^[кл] do
      for тек:=1 to claTop do
        claList[тек]:=memAlloc(lstrlen(исх^[кл].claList[тек])+1);
        lstrcpy(claList[тек],исх^[кл].claList[тек]);
      end
    end
  end;
end ресѕарам опи;

//---------- параметры диалога по умолчанию -----------

procedure ресѕарам”молч();
var кл,тек,меню:integer;
begin
  меню:=0;
  resTopClass:=ord(lastIniClass)+1;
  for кл:=1 to resTopClass do
    resClasses^[кл]:=iniClass[envER][classIniClass(кл-1)];
    with resClasses^[кл] do
    for тек:=1 to claTop do
      inc(меню);
      claList[тек]:=memAlloc(lstrlen(iniMenu[envER][меню])+1);
      lstrcpy(claList[тек],iniMenu[envER][меню]);
    end end;
  end
end ресѕарам”молч;

//---------- сохранение параметров диалога -----------

procedure рес—охрѕарам();
var файл,кл,тек,дл:integer;
begin
  файл:=_lcreat(ResFile,0);
  if файл>0 then
    _lwrite(файл,resWIN32,maxText);
    _lwrite(файл,addr(resTopClass),4);
    for кл:=1 to resTopClass do
    with resClasses^[кл] do
      _lwrite(файл,addr(resClasses^[кл]),sizeof(recClass));
      for тек:=1 to claTop do
        дл:=lstrlen(claList[тек]);
        _lwrite(файл,addr(дл),4);
        _lwrite(файл,claList[тек],lstrlen(claList[тек])+1);
      end;
    end end;
    _lclose(файл)
  end
end рес—охрѕарам;

//---------- загрузка параметров диалога -----------

procedure рес«агрѕарам();
var файл,кл,тек,дл:integer;
begin
  файл:=_lopen(ResFile,0);
  if файл>0 then
    _lread(файл,resWIN32,maxText);
    _lread(файл,addr(resTopClass),4);
    for кл:=1 to resTopClass do
    with resClasses^[кл] do
      _lread(файл,addr(resClasses^[кл]),sizeof(recClass));
      for тек:=1 to claTop do
        _lread(файл,addr(дл),4);
        claList[тек]:=memAlloc(дл+1);
        _lread(файл,claList[тек],дл+1);
      end;
    end end;
    _lclose(файл)
  else ресѕарам”молч();
  end
end рес«агрѕарам;

//----------- ƒиалог настроек ------------

const
  ид–есWin32=101;
  ид–ес лассы=102;
  ид–есƒоб ласс=103;
  ид–ес”д ласс=104;
  ид–ес»м€ ласса=10;
  ид–есЌазв ласса=106;
  ид–ес—тили=107;
  ид–есЌач“екст=108;
  ид–есЌачX=109;
  ид–есЌачY=110;
  ид–ес¬арианты=111;
  ид–ес¬ариант=112;
  ид–есƒоб¬ариант=113;
  ид–ес”д¬ариант=114;
  ид–есќк=120;
  ид–есќтмена=121;
  ид–ес”молчание=122;

const DLG_SETDLG=stringER{"DLG_SETDLG_R","DLG_SETDLG_E"};
dialog DLG_SETDLG_R 2,6,304,188,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Ќастройки редактора диалогов"
begin
  control "‘айл Win32:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,42,2,60,10
  control "",ид–есWin32,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,2,74,10
  control "—писок классов:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,14,80,10
  control "",ид–ес лассы,"LISTBOX",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,8,28,80,68
  control "ƒобавить",ид–есƒоб ласс,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,8,96,36,10
  control "”далить",ид–ес”д ласс,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,50,96,36,10
  control "—войства класса:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,136,18,88,10
  control "Ќазвание класса:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,32,90,10
  control "",ид–есЌазв ласса,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,32,60,10
  control "»м€ класса:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,44,90,10
  control "",ид–ес»м€ ласса,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,44,60,10
  control "ѕрефикс стилей:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,56,90,10
  control "",ид–ес—тили,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,56,40,10
  control "Ќачальный текст:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,68,90,10
  control "",ид–есЌач“екст,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,68,60,10
  control "Ќачальный размер по X:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,80,90,10
  control "",ид–есЌачX,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,80,40,10
  control "Ќачальный размер по Y:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,92,90,10
  control "",ид–есЌачY,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,92,40,10
  control "—писок вариантов класса:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,32,110,108,10
  control "",ид–ес¬арианты,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY,2,120,300,40
  control "",ид–ес¬ариант,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,2,162,300,10
  control "ƒобавить",ид–есƒоб¬ариант,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,152,110,38,10
  control "”далить",ид–ес”д¬ариант,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,194,110,38,10
  control "ќк",ид–есќк,"Button",WS_CHILD | WS_VISIBLE,84,174,44,10
  control "ќтменить",ид–есќтмена,"Button",WS_CHILD | WS_VISIBLE,136,174,44,10
  control "ѕо умолчанию",ид–ес”молчание,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,250,174,52,10
end;
dialog DLG_SETDLG_E 2,6,304,188,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Options"
begin
  control "Win32 file:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,42,2,60,10
  control "",ид–есWin32,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,2,74,10
  control "Classes list:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,14,80,10
  control "",ид–ес лассы,"LISTBOX",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,8,28,80,68
  control "Add",ид–есƒоб ласс,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,8,96,36,10
  control "Delete",ид–ес”д ласс,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,50,96,36,10
  control "Class options:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,136,18,88,10
  control "Class name:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,32,90,10
  control "",ид–есЌазв ласса,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,32,60,10
  control "Class ident:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,44,90,10
  control "",ид–ес»м€ ласса,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,44,60,10
  control "Styles prefix:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,56,90,10
  control "",ид–ес—тили,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,56,40,10
  control "Initial text:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,68,90,10
  control "",ид–есЌач“екст,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,68,60,10
  control "Initial size X:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,80,90,10
  control "",ид–есЌачX,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,80,40,10
  control "Initial size Y:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,92,90,10
  control "",ид–есЌачY,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,92,40,10
  control "Class variants:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,32,110,108,10
  control "",ид–ес¬арианты,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY,2,120,300,40
  control "",ид–ес¬ариант,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,2,162,300,10
  control "Add",ид–есƒоб¬ариант,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,152,110,38,10
  control "Delete",ид–ес”д¬ариант,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,194,110,38,10
  control "Ok",ид–есќк,"Button",WS_CHILD | WS_VISIBLE,84,174,44,10
  control "Cancel",ид–есќтмена,"Button",WS_CHILD | WS_VISIBLE,136,174,44,10
  control "By default",ид–ес”молчание,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,250,174,52,10
end;

//--------------------- сохранение компонент класса ----------------------------

procedure рес—охр ласс(окно:HWND; кл:integer);
var s:string[maxText]; тек:integer;
begin
  if (кл>0)and(кл<=resTopClass) then
  with resClasses^[кл] do
    GetDlgItemText(окно,ид–есЌазв ласса,claMenu,maxSClass);
    GetDlgItemText(окно,ид–ес»м€ ласса,claName,maxSClass);
    GetDlgItemText(окно,ид–ес—тили,claStyle,maxSClass);
    GetDlgItemText(окно,ид–есЌач“екст,claIniText,maxSClass);
    claIniDX:=GetDlgItemInt(окно,ид–есЌачX,nil,true);
    claIniDY:=GetDlgItemInt(окно,ид–есЌачY,nil,true);
    for тек:=1 to claTop do
      memFree(claList[тек]);
    end;
    claTop:=SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETCOUNT,0,0);
    for тек:=1 to claTop do
      SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETTEXT,тек-1,integer(addr(s)));
      claList[тек]:=memAlloc(lstrlen(s)+1);
      lstrcpy(claList[тек],s);
    end;
  end end;
end рес—охр ласс;

//--------------------- загрузка компонент класса ----------------------------

procedure рес«агр ласс(окно:HWND; кл:integer);
var тек:integer;
begin
  if (кл>0)and(кл<=resTopClass) then
  with resClasses^[кл] do
    SetDlgItemText(окно,ид–есЌазв ласса,claMenu);
    SetDlgItemText(окно,ид–ес»м€ ласса,claName);
    SetDlgItemText(окно,ид–ес—тили,claStyle);
    SetDlgItemText(окно,ид–есЌач“екст,claIniText);
    SetDlgItemInt(окно,ид–есЌачX,claIniDX,true);
    SetDlgItemInt(окно,ид–есЌачY,claIniDY,true);
    SendDlgItemMessage(окно,ид–ес¬арианты,LB_RESETCONTENT,0,0);
    for тек:=1 to claTop do
      SendDlgItemMessage(окно,ид–ес¬арианты,LB_ADDSTRING,0,integer(claList[тек]));
    end;
    SendDlgItemMessage(окно,ид–ес¬арианты,LB_SETCURSEL,0,0);
    SendMessage(окно,WM_COMMAND,LBN_SELCHANGE*0x10000+ид–ес¬арианты,0);
  end end;
end рес«агр ласс;

//--------------------- диалогова€ функци€ настроек ----------------------------

procedure проц–есЌастр(окно:HWND; сооб,вѕарам,лѕарам:integer):boolean;
var кл,меню,тек:integer; s,s2:string[maxText];
begin
  case сооб of
    WM_INITDIALOG: //инициализаци€
      SetDlgItemText(окно,ид–есWin32,resWIN32);
      for кл:=1 to resTopClass do
        SendDlgItemMessage(окно,ид–ес лассы,LB_ADDSTRING,0,integer(addr(resClasses^[кл].claMenu)));
      end;
      resCarClass:=1;
      SendDlgItemMessage(окно,ид–ес лассы,LB_SETCURSEL,0,0);
      рес«агр ласс(окно,resCarClass);
      SetFocus(GetDlgItem(окно,ид–ес лассы));|
    WM_COMMAND:case loword(вѕарам) of
      ид–ес лассы:if hiword(вѕарам)=LBN_SELCHANGE then //смена класса
        кл:=SendDlgItemMessage(окно,ид–ес лассы,LB_GETCURSEL,0,0)+1;
        рес—охр ласс(окно,resCarClass);
        resCarClass:=кл;
        рес«агр ласс(окно,resCarClass);
      end;|
      ид–ес¬арианты:if hiword(вѕарам)=LBN_SELCHANGE then //смена варианта
        тек:=SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETCURSEL,0,0);
        if тек>=0 then
          SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETTEXT,тек,integer(addr(s)));
          SetDlgItemText(окно,ид–ес¬ариант,s);
        end
      end;|
      ид–есЌазв ласса:if hiword(вѕарам)=EN_CHANGE then //смена названи€ класса
        GetDlgItemText(окно,ид–есЌазв ласса,s,maxText);
        тек:=SendDlgItemMessage(окно,ид–ес лассы,LB_GETCURSEL,0,0);
        SendDlgItemMessage(окно,ид–ес лассы,LB_GETTEXT,тек,integer(addr(s2)));
        if (lstrcmp(s,s2)<>0)and(тек>=0) then
          SendDlgItemMessage(окно,ид–ес лассы,LB_DELETESTRING,тек,0);
          SendDlgItemMessage(окно,ид–ес лассы,LB_INSERTSTRING,тек,integer(addr(s)));
          SendDlgItemMessage(окно,ид–ес лассы,LB_SETCURSEL,тек,0);
        end;
      end;|
      ид–ес¬ариант:if hiword(вѕарам)=EN_CHANGE then //смена текста варианта
        GetDlgItemText(окно,ид–ес¬ариант,s,maxText);
        тек:=SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETCURSEL,0,0);
        SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETTEXT,тек,integer(addr(s2)));
        if (lstrcmp(s,s2)<>0)and(тек>=0) then
          SendDlgItemMessage(окно,ид–ес¬арианты,LB_DELETESTRING,тек,0);
          SendDlgItemMessage(окно,ид–ес¬арианты,LB_INSERTSTRING,тек,integer(addr(s)));
          SendDlgItemMessage(окно,ид–ес¬арианты,LB_SETCURSEL,тек,0);
        end;
      end;|
      ид–есƒоб ласс:if hiword(вѕарам)=BN_CLICKED then //добавить класс
      if resTopClass=maxClass then mbS(_—лишком_много_классов[envER])
      else
        рес—охр ласс(окно,resCarClass);
        кл:=SendDlgItemMessage(окно,ид–ес лассы,LB_GETCURSEL,0,0)+2;
        if (кл>0)and(кл<=resTopClass+1) then
          for тек:=resTopClass+1 downto кл+1 do
            resClasses^[тек]:=resClasses^[тек-1];
          end;
          RtlZeroMemory(addr(resClasses^[кл]),sizeof(recClass));
          inc(resTopClass);
          SendDlgItemMessage(окно,ид–ес лассы,LB_INSERTSTRING,кл-1,integer(""));
          SendDlgItemMessage(окно,ид–ес лассы,LB_SETCURSEL,кл-1,0);
          resCarClass:=кл;
          рес«агр ласс(окно,resCarClass);
          SetFocus(GetDlgItem(окно,ид–есЌазв ласса));
        end
      end end;|
      ид–ес”д ласс:if hiword(вѕарам)=BN_CLICKED then //удалить класс
      if resTopClass=0 then mbS(_Ќет_классов_в_списке[envER])
      else
        рес—охр ласс(окно,resCarClass);
        кл:=SendDlgItemMessage(окно,ид–ес лассы,LB_GETCURSEL,0,0)+1;
        if (кл>0)and(кл<=resTopClass) then
          for тек:=кл to resTopClass-1 do
            resClasses^[тек]:=resClasses^[тек+1];
          end;
          dec(resTopClass);
          SendDlgItemMessage(окно,ид–ес лассы,LB_DELETESTRING,кл-1,0);
          SendDlgItemMessage(окно,ид–ес лассы,LB_SETCURSEL,кл-1,0);
          if кл<=resTopClass
            then resCarClass:=кл;
            else resCarClass:=кл-1;
          end;
          рес«агр ласс(окно,resCarClass);
        end
      end end;|
      ид–есƒоб¬ариант:if hiword(вѕарам)=BN_CLICKED then //добавить вариант
      with resClasses^[resCarClass] do
        меню:=SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETCURSEL,0,0)+2;
        if меню>0 then
          SendDlgItemMessage(окно,ид–ес¬арианты,LB_INSERTSTRING,меню-1,integer(""));
          SendDlgItemMessage(окно,ид–ес¬арианты,LB_SETCURSEL,меню-1,0);
          SetDlgItemText(окно,ид–ес¬ариант,nil);
          SetFocus(GetDlgItem(окно,ид–ес¬ариант));
        end
      end end;|
      ид–ес”д¬ариант:if hiword(вѕарам)=BN_CLICKED then //удалить вариант
      with resClasses^[resCarClass] do
        меню:=SendDlgItemMessage(окно,ид–ес¬арианты,LB_GETCURSEL,0,0)+1;
        if меню>0 then
          SendDlgItemMessage(окно,ид–ес¬арианты,LB_DELETESTRING,меню-1,0);
          SetDlgItemText(окно,ид–ес¬ариант,nil);
        end;
      end end;|
      ид–ес”молчание:if boolean(MessageBox(0,
        _«аменить_все_значени€_на_значени€_по_умолчанию__[envER],"¬Ќ»ћјЌ»≈ !",MB_YESNO)) then
        ресѕарам„истить(resClasses,resTopClass);
        ресѕарам”молч();
        SendDlgItemMessage(окно,ид–ес лассы,LB_RESETCONTENT,0,0);
        SendMessage(окно,WM_INITDIALOG,0,0);
      end;|
      IDOK,ид–есќк:
        рес—охр ласс(окно,resCarClass);
        GetDlgItemText(окно,ид–есWin32,resWIN32,maxText);
        EndDialog(окно,1);|
      IDCANCEL,ид–есќтмена:EndDialog(окно,0);|
    end;|
  else return false
  end;
  return true;
end проц–есЌастр;

//--------- Ќастройки диалога -------------

procedure ресЌастройки();
var фок:HWND; resClassesOld:pClass; resTopClassOld:integer;
begin
  фок:=GetFocus();
  resClassesOld:=memAlloc(sizeof(arrClass));
  ресѕарам опи(resClasses,resClassesOld,resTopClass,resTopClassOld);
  if boolean(DialogBoxParam(hINSTANCE,DLG_SETDLG[envER],GetFocus(),addr(проц–есЌастр),0)) then
    рес—охрѕарам();
    ресѕарам„истить(resClassesOld,resTopClassOld);
  else
    ресѕарам„истить(resClasses,resTopClass);
    ресѕарам опи(resClassesOld,resClasses,resTopClassOld,resTopClass);
  end;
  memFree(resClassesOld);
  SetFocus(фок);
end ресЌастройки;

end SmRes.
