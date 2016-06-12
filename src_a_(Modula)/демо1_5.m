// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа
// ƒемо 5:“екстовый редактор RTF-файлов

module Demo1_5;
import Win32;

icon "icon_rtf.bmp";
const INSTANCE=0x400000;

//===============================================
//                      ѕ≈–≈ћ≈ЌЌџ≈
//===============================================

type
  —писок—татус=(статус»м€‘айла,статус»зменен,статусЎрифт,статус–азмер,статус∆ирный,статус урсив);
  “ип—татус=array[—писок—татус]of integer;
const
  »нфо—татус=“ип—татус{35,10,20,15,10,10};

var
  ќкно–едактора:HWND;
  ќкноRTF:HWND;
  ќкно—татус:HWND;
  ќкно нопок:HWND;
  ‘ильтрRTF:HANDLE;
  »м€‘айла–едактора:string[500];
  ќбразецƒл€ѕоиска:string[500];

//------------------------ команды редактора ----------------------------

type
  —писок оманд–едактора=(
    ред‘айлЌовый,ред‘айлќткрыть,ред‘айл—охранить,ред‘айл—охранить ак,редѕусто1,ред‘айлѕечать,редѕусто11,ред‘айл¬ыход,
    редѕравкаќтменить,редѕусто2,редѕравка¬ырезать,редѕравка опировать,редѕравка¬ставить,редѕравка”далить,редѕусто3,редѕравка¬ыделить¬се,
    редѕоиск,ред—ледующийѕоиск,
    ред‘орматЎрифт,редѕусто31,ред‘орматЎрифт∆ирный,ред‘орматЎрифт урсив,редѕусто4,ред‘орматјбзац¬лево,ред‘орматјбзац¬право,ред‘орматјбзацѕо÷ентру,
    ред»нструментWINDOWS,ред»нструментDOS,
    ред¬ыход);

  —писок√рупп оманд–едактора=(
    ред√руппа‘айл,ред√руппаѕравка,ред√руппаѕоиск,ред√руппа‘ормат,ред√руппа»нструмент,ред√руппа¬ыход);

type
  “ип—войств оманд–едактора=array[—писок оманд–едактора]of pstr;
  “ип—войств√рупп оманд–едактора=array[—писок√рупп оманд–едактора]of record
    »м€√руппы:pstr;
    ѕерва€ оманда√руппы:—писок оманд–едактора;
    ѕоследн€€ оманда√руппы:—писок оманд–едактора;
  end;

const
  —войства оманд–едактора=“ип—войств оманд–едактора{
    "Ќовый файл","ќткрыть файл...","—охранить файл","—охранить ак...","","ѕечать...","","Exit",
    "ќтменить","","¬ырезать\9Shift+Delete"," опировать\9Ctrl+Insert","¬ставить\9Shift+Insert","”далить\9Delete","","¬ыделить все",
    "ѕоиск...","—ледующий поиск\9F3",
    "Ўрифт","","”становить/убрать жирный","”становить/убрать курсив","","¬ыровн€ть абзац влево","¬ыровн€ть абзац вправо","¬ыровн€ть абзац по центру",
    "ѕеревести в кодировку WINDOWS","ѕеревести в кодировку DOS",
    "Exit"};
  —войства√рупп оманд–едактора=“ип—войств√рупп оманд–едактора{
    {"File",ред‘айлЌовый,ред‘айл¬ыход},
    {"ѕравка",редѕравкаќтменить,редѕравка¬ыделить¬се},
    {"ѕоиск",редѕоиск,ред—ледующийѕоиск},
    {"‘ормат",ред‘орматЎрифт,ред‘орматјбзацѕо÷ентру},
    {"»нструменты",ред»нструментWINDOWS,ред»нструментDOS},
    {"Exit",ред¬ыход,ред¬ыход}};

//номера кнопок в toolbar (от 1)
type “ип нопок=array[—писок оманд–едактора]of integer;
const Ќомер нопки=“ип нопок{
    1,2,3,4,0,5,0,0,
    6,0,7,8,9,10,0,0,
    11,12,
    13,0,14,15,0,16,17,18,
    19,20,
    0};

const
  ид–едактор=200;
  ид–едакторRTF=101;

//===============================================
//              ¬—ѕќћќ√ј“≈Ћ№Ќџ≈ ѕ–ќ÷≈ƒ”–џ
//===============================================

procedure mbI(цел:integer; комм:pstr);
var стр:string[100];
begin
  wvsprintf(стр,'%li',addr(цел));
  MessageBox(0,стр,комм,0);
end mbI;

//---------------- —оздание статус-строки редактора ----------------

procedure —оздать—татус(окно:HWND; бит“олько–азмеры:boolean);
var
  размер:array[—писок—татус]of integer;
  регион:RECT;
  статус:—писок—татус;
  тек,ширина:integer;
begin
  if not бит“олько–азмеры then
    ќкно—татус:=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      nil,окно,0);
  end;
  GetClientRect(окно,регион);
  if бит“олько–азмеры then
  with регион do
    SendMessage(ќкно—татус,WM_SIZE,right-left+1,bottom-top+1);
  end end;
  тек:=0;
  for статус:=статус»м€‘айла to статус урсив do
    ширина:=(регион.right-регион.left+1)*»нфо—татус[статус] div 100;
    размер[статус]:=тек+ширина;
    inc(тек,ширина)
  end;
  размер[статус урсив]:=-1;
  SendMessage(ќкно—татус,SB_SETPARTS,ord(статус урсив)+1,cardinal(addr(размер)));
end —оздать—татус;

//------------- ќбновление статус-строки --------------------

procedure ќбновить—татус(wnd:HWND);
var строка:string[500]; формат:CHARFORMAT;
begin
  SendMessage(ќкно—татус,SB_SETTEXT,ord(статус»м€‘айла),cardinal(addr(»м€‘айла–едактора)));
  if boolean(SendMessage(ќкноRTF,EM_GETMODIFY,0,0))
    then SendMessage(ќкно—татус,SB_SETTEXT,ord(статус»зменен),cardinal("»зменен"));
    else SendMessage(ќкно—татус,SB_SETTEXT,ord(статус»зменен),cardinal(""));
  end;
  with формат do
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(ќкноRTF,EM_GETCHARFORMAT,1,cardinal(addr(формат)));
    SendMessage(ќкно—татус,SB_SETTEXT,ord(статусЎрифт),cardinal(addr(szFaceName)));
    yHeight:=yHeight div 20;
    wvsprintf(строка,"–азмер:%li",addr(yHeight));
    SendMessage(ќкно—татус,SB_SETTEXT,ord(статус–азмер),cardinal(addr(строка)));
    if dwEffects and CFE_BOLD=0
      then SendMessage(ќкно—татус,SB_SETTEXT,ord(статус∆ирный),cardinal(""));
      else SendMessage(ќкно—татус,SB_SETTEXT,ord(статус∆ирный),cardinal("ѕолужирный"));
    end;
    if dwEffects and CFE_ITALIC=0
      then SendMessage(ќкно—татус,SB_SETTEXT,ord(статус урсив),cardinal(""));
      else SendMessage(ќкно—татус,SB_SETTEXT,ord(статус урсив),cardinal(" урсив"));
    end;
  end
end ќбновить—татус;

//------------------------ выравнивание абзаца ----------------------------

procedure ”становить¬ыравниваниејбзаца(wnd:HWND; выравнивание:integer);
var формат:PARAFORMAT;
begin
  with формат do
    cbSize:=sizeof(PARAFORMAT);
    dwMask:=PFM_ALIGNMENT;
    case выравнивание of
      -1:wAlignment:=PFA_LEFT;|
      0:wAlignment:=PFA_CENTER;|
      1:wAlignment:=PFA_RIGHT;|
    end;
    SendMessage(ќкноRTF,EM_SETPARAFORMAT,0,cardinal(addr(формат)));
  end
end ”становить¬ыравниваниејбзаца;

//-------------------- сменить начертание шрифта -------------------------

procedure ”становитьЌачертаниеЎрифта(wnd:HWND; битѕолужирный:boolean);
var формат:CHARFORMAT;
begin
  with формат do
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(ќкноRTF,EM_GETCHARFORMAT,1,cardinal(addr(формат)));
    case битѕолужирный of
      true:dwMask:=CFM_BOLD; dwEffects:=(not dwEffects and CFE_BOLD)or(dwEffects and not CFE_BOLD);|
      false:dwMask:=CFM_ITALIC; dwEffects:=(not dwEffects and CFE_ITALIC)or(dwEffects and not CFE_ITALIC);|
    end;
    SendMessage(ќкноRTF,EM_SETCHARFORMAT,SCF_SELECTION,cardinal(addr(формат)));
  end
end ”становитьЌачертаниеЎрифта;

//-------------------- проверка на текстовый файл -------------------------

procedure “екстовый‘айл(им€‘айла:pstr):boolean;
var точка:integer;
begin
  точка:=lstrlen(им€‘айла)-4;
  return (точка>=0)and((им€‘айла[точка+1]='t')or(им€‘айла[точка+1]='T'));
end “екстовый‘айл;

//------------ функци€ обратного вызова загрузки ----------

procedure «агрузитьЅлок(dwCookie:cardinal; pbBuff:address; cb:cardinal; pcb:pINT):cardinal;
begin
  pcb^:=_lread(dwCookie,pbBuff,cb);
  if pcb^<0 then
    pcb^:=0
  end;
  return 0;
end «агрузитьЅлок;

//-------------------- загрузить файл(load file)-------------------------

procedure «агрузить‘айл–едактора(wnd:HWND; им€‘айла:pstr);
var файл:integer; поток:EDITSTREAM;
begin
  with поток do
    файл:=_lopen(им€‘айла,0);
    if файл>0 then 
      dwCookie:=файл;
      dwError:=0;
      pfnCallback:=addr(«агрузитьЅлок);
      if “екстовый‘айл(им€‘айла)
        then SendMessage(ќкноRTF,EM_STREAMIN,SF_TEXT,cardinal(addr(поток)))
        else SendMessage(ќкноRTF,EM_STREAMIN,SF_RTF,cardinal(addr(поток)))
      end;
      _lclose(файл);
       SendMessage(ќкноRTF,EM_SETMODIFY,0,0)
    end
  end
end «агрузить‘айл–едактора;

//------------ функци€ обратного вызова сохранени€ ----------

procedure —охранитьЅлок(dwCookie:cardinal; pbBuff:address; cb:cardinal; pcb:pINT):cardinal;
begin
  cb:=_lwrite(dwCookie,pbBuff,cb);
  pcb^:=cb;
  return 0;
end —охранитьЅлок;

//-------------------- сохранить файл(save file)-------------------------

procedure —охранить‘айл–едактора(wnd:HWND; им€‘айла:pstr);
var файл:integer; поток:EDITSTREAM;
begin
  with поток do
    файл:=_lcreat(им€‘айла,0);
    if файл>0 then
      dwCookie:=файл;
      dwError:=0;
      pfnCallback:=addr(—охранитьЅлок);
      if “екстовый‘айл(им€‘айла)
        then SendMessage(ќкноRTF,EM_STREAMOUT,SF_TEXT,cardinal(addr(поток)))
        else SendMessage(ќкноRTF,EM_STREAMOUT,SF_RTF,cardinal(addr(поток)))
      end;
      _lclose(файл);
       SendMessage(ќкноRTF,EM_SETMODIFY,0,0)
    end
  end
end —охранить‘айл–едактора;

//-------------------- диалог поиска -------------------------

const
  идќбразецƒл€ѕоиска=101;

dialog DLG_FIND 80,58,160,65,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "ѕоиск текста"
begin
  control "ќбразец дл€ поиска:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,5,3,149,11
  control "",идќбразецƒл€ѕоиска,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,16,149,12
  control "ќк",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,31,48,45,12
  control "ќтмена",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,82,48,45,12
end;

procedure ƒиалогова€‘ункци€ѕоиска(wnd:HWND; msg,wparam,lparam:cardinal):cardinal;
begin
  case msg of
    WM_INITDIALOG:SetDlgItemText(wnd,идќбразецƒл€ѕоиска,ќбразецƒл€ѕоиска);|
    WM_COMMAND:case loword(wparam) of
      IDOK:
        GetDlgItemText(wnd,идќбразецƒл€ѕоиска,ќбразецƒл€ѕоиска,500);
        EndDialog(wnd,1);|
      IDCANCEL:EndDialog(wnd,0);|
    end;|
    else return(0);
  end;
  return(1);
end ƒиалогова€‘ункци€ѕоиска;

//---------------------------инициализаци€ toolbar------------------------------

bitmap bmpToolbar="tool_rtf.bmp";

procedure —оздать нопки(wnd:HWND);
var
  кнопки:array[1..50]of TBBUTTON;
  количество:integer;
  bmp:HBITMAP;
  группа:—писок√рупп оманд–едактора;
  команда:—писок оманд–едактора;
  регион:RECT;
begin
  InitCommonControls();
  bmp:=LoadBitmap(INSTANCE,"bmpToolbar");
  //заполнение массива кнопок
  количество:=0;
  for группа:=ред√руппа‘айл to ред√руппа»нструмент do
  with —войства√рупп оманд–едактора[группа] do 
    //кнопки группы команд
    for команда:=ѕерва€ оманда√руппы to ѕоследн€€ оманда√руппы do
    if (Ќомер нопки[команда]>0)and(количество<50) then
      inc(количество);
      RtlZeroMemory(addr(кнопки[количество]),sizeof(TBBUTTON));
      with кнопки[количество] do
        iBitmap:=Ќомер нопки[команда]-1;
        idCommand:=ид–едактор+integer(команда);
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_BUTTON;
      end;
    end end;
    //промежуток между кнопками
    if количество<50 then
      inc(количество);
      RtlZeroMemory(addr(кнопки[количество]),sizeof(TBBUTTON));
      with кнопки[количество] do
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_SEP;
      end
    end
  end end;
  //создание toolbar
  ќкно нопок:=CreateToolbarEx(
    wnd,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,количество,0,bmp,addr(кнопки),количество,20,20,20,20,sizeof(TBBUTTON));
  //коррекци€ положени€ toolbar
  with регион do
    GetWindowRect(ќкно нопок,регион);
    dec(top,10);
    MoveWindow(ќкно нопок,left,top,right-left+1,bottom-top+1,true);
  end;
end —оздать нопки;

//---------------------------тексты кнопок toolbar------------------------------

procedure ¬ернуть“екст нопки(lparam:cardinal);
var
  ук»нфо:pNMHDR;
  ук»нфо“екст:pTOOLTIPTEXT;
  команда:—писок оманд–едактора;
begin
  ук»нфо:=address(lparam);
  ук»нфо“екст:=address(lparam);  
  with ук»нфо^,ук»нфо“екст^ do
    команда:=—писок оманд–едактора(idFrom-ид–едактор);
    case code of
      TTN_NEEDTEXT:
        команда:=—писок оманд–едактора(idFrom-ид–едактор);
        lpszText:=—войства оманд–едактора[команда];|
    end
  end
end ¬ернуть“екст нопки;

//---------------------------размеры окна RTF------------------------------

procedure »зменить–азмерRTF(wnd:HWND);
var регион–едактора,регион нопок,регион—татус,регионRTF:RECT;
begin
  with регионRTF do
    GetClientRect(wnd,регион–едактора);
    GetWindowRect(ќкно нопок,регион нопок);
    GetWindowRect(ќкно—татус,регион—татус);
    left:=5;
    right:=регион–едактора.right-регион–едактора.left-10;
    top:=регион нопок.bottom-регион нопок.top+5;
    bottom:=
      (регион–едактора.bottom-регион–едактора.top)-
      (регион—татус.bottom-регион—татус.top)-
      (регион нопок.bottom-регион нопок.top)-10;
    MoveWindow(ќкноRTF,left,top,right,bottom,true);
  end
end »зменить–азмерRTF;

//-------------------- сменить кодировку -------------------------

procedure —менить одировку(wnd:HWND; битDOS:boolean);
var буфер:pstr;
begin
  if not(not “екстовый‘айл(»м€‘айла–едактора)and
    (MessageBox(ќкно–едактора,"¬ы уверены в необходимости смены кодировки ?","¬Ќ»ћјЌ»≈:",MB_YESNO)<>IDYES)) then
    буфер:=GlobalLock(GlobalAlloc(GMEM_FIXED,GetWindowTextLength(ќкноRTF)+1));
    GetWindowText(ќкноRTF,буфер,GetWindowTextLength(ќкноRTF)+1);
    if битDOS
      then CharToOem(буфер,буфер);
      else OemToChar(буфер,буфер);
    end;
    SetWindowText(ќкноRTF,буфер);
    GlobalFree(GlobalHandle(буфер));
  end
end —менить одировку;

//===============================================
//                  ќЅ–јЅќ“„» »  ќћјЌƒ ћ≈Ќё
//===============================================

//-------------------- открыть файл(open file)-------------------------

procedure  оманда‘айлќткрыть(wnd:HWND);
var путь,им€:string[500]; ofn:OPENFILENAME;
begin
  with ofn do
    lstrcpy(путь,"*.rtf");
    им€[0]:=char(0);
    RtlZeroMemory(addr(ofn),sizeof(OPENFILENAME));
    lStructSize:=sizeof(OPENFILENAME);
    lpstrFilter:="RTF-файлы\0*.rtf\0“екстовые файлы\0*.txt\0";
    nFilterIndex:=1;
    lpstrFile:=addr(путь);
    nMaxFile:=500;
    lpstrFileTitle:=addr(им€);
    nMaxFileTitle:=500;
    Flags:=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if GetOpenFileName(ofn) then
      «агрузить‘айл–едактора(wnd,путь);
      lstrcpy(»м€‘айла–едактора,путь);
    end;
  end
end  оманда‘айлќткрыть;

//-------------------- сохранить файл(save file)-------------------------

procedure  оманда‘айл—охранить(wnd:HWND);
begin
  if »м€‘айла–едактора[0]<>'\0' then
    —охранить‘айл–едактора(wnd,»м€‘айла–едактора);
  end
end  оманда‘айл—охранить;

//-------------------- сохранить как -------------------------

procedure  оманда‘айл—охранить ак(wnd:HWND);
var путь,им€:string[500]; ofn:OPENFILENAME;
begin
  with ofn do
    lstrcpy(путь,"*.rtf");
    им€[0]:=char(0);
    RtlZeroMemory(addr(ofn),sizeof(OPENFILENAME));
    lStructSize:=sizeof(OPENFILENAME);
    lpstrFilter:="RTF-файлы\0*.rtf\0“екстовые файлы\0*.txt\0";
    nFilterIndex:=1;
    lpstrFile:=addr(путь);
    nMaxFile:=500;
    lpstrFileTitle:=addr(им€);
    nMaxFileTitle:=500;
    Flags:=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if GetSaveFileName(ofn) then
      —охранить‘айл–едактора(wnd,путь);
      lstrcpy(»м€‘айла–едактора,путь);
    end
  end
end  оманда‘айл—охранить ак;

//-------------------- выделить все -------------------------

procedure  оманда¬ыделить¬се(wnd:HWND);
var регион:CHARRANGE;
begin
  with регион do
    cpMin:=0;
    cpMax:=-1;
    SendMessage(ќкноRTF,EM_EXSETSEL,0,cardinal(addr(регион)));
  end
end  оманда¬ыделить¬се;

//-------------------- поиск -------------------------

procedure  омандаѕоиск(wnd:HWND; бит«апросќбразца:boolean);
var образец:FINDTEXTEX; найдено:integer;
begin
  if (бит«апросќбразца and
    boolean(DialogBoxParam(INSTANCE,"DLG_FIND",ќкноRTF,addr(ƒиалогова€‘ункци€ѕоиска),0))) or
    not бит«апросќбразца then
    with образец do
      if бит«апросќбразца
        then chrg.cpMin:=0;
        else chrg.cpMin:=hiword(SendMessage(ќкноRTF,EM_GETSEL,0,0));
      end;
      chrg.cpMax:=-1;
      lpstrText:=addr(ќбразецƒл€ѕоиска);
      найдено:=SendMessage(ќкноRTF,EM_FINDTEXTEX,0,cardinal(addr(образец)));
      if найдено=-1
        then MessageBox(ќкноRTF,"‘рагмент не найден","¬Ќ»ћјЌ»≈:",MB_ICONSTOP)
        else SendMessage(ќкноRTF,EM_SETSEL,chrgText.cpMin,chrgText.cpMax)
      end;
    end
  end
end  омандаѕоиск;

//-------------------- выбор шрифта -------------------------

procedure  омандаЎрифт(wnd:HWND);
var формат:CHARFORMAT; шрифт:CHOOSEFONT; логшрифт:LOGFONT; dc:HDC;
begin
  with формат do
  //получить текущий формат
    cbSize:=sizeof(CHARFORMAT);
    dwMask:=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(ќкноRTF,EM_GETCHARFORMAT,1,cardinal(addr(формат)));
    dc:=GetDC(wnd);
  //заполнить шрифт текущими характеристиками
    with логшрифт do
      RtlZeroMemory(addr(логшрифт),sizeof(LOGFONT));
      lfItalic:=byte((dwEffects and CFE_ITALIC)<>0);
      lfHeight:=-yHeight div 15;
      lfPitchAndFamily:=bPitchAndFamily;
      lstrcpy(lfFaceName,szFaceName);
      if (dwEffects and CFE_BOLD)=0
        then lfWidth:=FW_NORMAL
        else lfWidth:=FW_BOLD
      end;
    end;
  //заполнить структуру выбора шрифта
    with шрифт do
      RtlZeroMemory(addr(шрифт),sizeof(CHOOSEFONT));
      lStructSize:=sizeof(CHOOSEFONT);
      Flags:=CF_SCREENFONTS | CF_INITTOLOGFONTSTRUCT;
      hDC:=dc;
      hwndOwner:=wnd;
      lpLogFont:=addr(логшрифт);
      rgbColors:=0;
      nFontType:=SCREEN_FONTTYPE;
    end;
  //выбор шрифта
    if ChooseFont(шрифт) then
  //заполн€ем формат символа
      with логшрифт do
        dwMask:=CFM_BOLD | CFM_FACE | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE | CFM_OFFSET;
        yHeight:=-lfHeight*15;
        dwEffects:=0;
        if boolean(lfItalic) then dwEffects:=dwEffects or CFE_ITALIC end;
        if lfWeight=FW_BOLD then dwEffects:=dwEffects or CFE_BOLD end;
        bPitchAndFamily:=lfPitchAndFamily;
        lstrcpy(szFaceName,lfFaceName);
      end;
//измен€ем формат символов
      SendMessage(ќкноRTF,EM_SETCHARFORMAT,SCF_SELECTION,cardinal(addr(формат)));
    end;
    ReleaseDC(wnd,dc);
  end
end  омандаЎрифт;

//-------------------- печать файла -------------------------

procedure  оманда‘айлѕечать(wnd:HWND);
var
  документ:DOCINFO;
  формат:FORMATRANGE;
  печать:PRINTDLG;
  результат:integer;
  текущий—имвол,последний—имвол:integer;
  dc:HDC;
begin
  //заполнить структуру дл€ диалога печати
  with печать do
    RtlZeroMemory(addr(печать),sizeof(PRINTDLG));
    lStructSize:=sizeof(PRINTDLG);
    hwndOwner:=ќкноRTF;
    hInstance:=INSTANCE;
    Flags:=PD_RETURNDC | PD_NOPAGENUMS | PD_NOSELECTION | PD_PRINTSETUP | PD_ALLPAGES;
    nFromPage:=0xFFFF;
    nToPage:=0xFFFF;
    nMinPage:=0;
    nMaxPage:=0xFFFF;
    nCopies:=1;
  end;
  //вывод диалога печати
  if PrintDlg(печать) then
    dc:=печать.hDC;
  //заполнение полей структуры форматировани€
    with формат do
      RtlZeroMemory(addr(формат),sizeof(FORMATRANGE));
      hdc:=dc; //контекст печати принтера
      hdcTarget:=dc;
      chrg.cpMin:=0; //весь документ
      chrg.cpMax:=-1;
      rcPage.top:=0; //размеры страницы в TWIPS
      rcPage.left:=0;
      rcPage.right:=MulDiv(GetDeviceCaps(dc,PHYSICALWIDTH),1440,GetDeviceCaps(dc,LOGPIXELSX));
      rcPage.bottom:=MulDiv(GetDeviceCaps(dc,PHYSICALHEIGHT),1440,GetDeviceCaps(dc,LOGPIXELSY));
      rc:=rcPage;
    end;  
  //заполнение полей документа
    with документ do
      RtlZeroMemory(addr(документ),sizeof(DOCINFO));
      cbSize:=sizeof(DOCINFO);
      lpszOutput:=nil;
      lpszDocName:="Strannik";
    end;
  //печать документа
    результат:=StartDoc(dc,документ);
    if результат<=0 then MessageBox(ќкноRTF,"ќшибка печати","¬Ќ»ћјЌ»≈:",MB_ICONSTOP)
    else
      текущий—имвол:=0;
      последний—имвол:=SendMessage(ќкноRTF,WM_GETTEXTLENGTH,0,0);
      while текущий—имвол<последний—имвол do
      //форматирование и печать
        текущий—имвол:=SendMessage(ќкноRTF,EM_FORMATRANGE,1,cardinal(addr(формат)));
        if текущий—имвол<последний—имвол then
          EndPage(dc);
          StartPage(dc);
          формат.chrg.cpMin:=текущий—имвол;
          формат.chrg.cpMax:=-1;
        end;
        SendMessage(ќкноRTF,EM_FORMATRANGE,1,0);
        EndPage(dc);
        EndDoc(dc);
      end
    end;
    DeleteDC(dc);
  end;
end  оманда‘айлѕечать;

//-------------------- выход из редактора -------------------------

procedure  оманда¬ыход(wnd:HWND):boolean;
var ответ:cardinal;
begin
   if boolean(SendMessage(ќкноRTF,EM_GETMODIFY,0,0)) then
     ответ:=MessageBox(ќкноRTF,"‘айл был изменен. —охранить ?","¬Ќ»ћјЌ»≈",MB_ICONSTOP | MB_YESNOCANCEL);
     case ответ of
       IDYES:—охранить‘айл–едактора(wnd,»м€‘айла–едактора); return true;|
       IDNO:return true;|
       IDCANCEL:return false;|
     end;
   else return true
   end
end  оманда¬ыход;

//===============================================
//            ƒ»јЋќ√ќ¬јя ‘”Ќ ÷»я –≈ƒј “ќ–ј
//===============================================

//------------------------ создание меню(create menu)----------------------------

procedure —оздатьћеню–едактора(wnd:HWND);
var
  меню оманд,меню√руппы:HMENU;
  команда:—писок оманд–едактора;
  группа:—писок√рупп оманд–едактора;
begin
  меню оманд:=CreateMenu();
  for группа:=ред√руппа‘айл to ред√руппа»нструмент do
  with —войства√рупп оманд–едактора[группа] do 
    меню√руппы:=CreatePopupMenu();
    for команда:=ѕерва€ оманда√руппы to ѕоследн€€ оманда√руппы do
      if —войства оманд–едактора[команда][0]='\0'
        then AppendMenu(меню√руппы,MF_SEPARATOR,0,nil)
        else AppendMenu(меню√руппы,MF_STRING,ид–едактор+integer(команда),—войства оманд–едактора[команда])
      end
    end;
    AppendMenu(меню оманд,MF_POPUP,меню√руппы,»м€√руппы);
  end end;
  AppendMenu(меню оманд,MF_STRING,ид–едактор+integer(ред¬ыход),—войства оманд–едактора[ред¬ыход]);
  SetMenu(wnd,меню оманд);
end —оздатьћеню–едактора;

//------------ функци€ фильтра дл€ RichEdit ------------------

procedure ‘ункци€‘ильтра(code,wparam,lparam:integer):cardinal;
var messageение:pMSG;
begin
  messageение:=pMSG(lparam);
  with messageение^ do
  if  code=HC_ACTION then
    ќбновить—татус(hwnd);
    case message of
      WM_KEYDOWN:SendMessage(ќкно–едактора,message,wParam,lParam);|
    end;
  end end;
  return 0
end ‘ункци€‘ильтра;

//------------------------ диалог редактора ----------------------------

dialog DLG_EDI 6,5,291,179,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "“екстовый редактор '—транник'"
begin
  control "",ид–едакторRTF,"RichEdit",WS_CHILD | WS_BORDER | ES_MULTILINE | ES_AUTOVSCROLL | WS_VSCROLL | ES_WANTRETURN | WS_VISIBLE | ES_SAVESEL,2,12,286,146
end;

//--------------- диалогова€ функци€ редактора ------------------

procedure ƒиалогова€‘ункци€–едактора(wnd:HWND; msg,wparam,lparam:cardinal):cardinal;
begin
  case msg of
    WM_INITDIALOG:
      —оздатьћеню–едактора(wnd);
      ќкно–едактора:=wnd;
      ќкноRTF:=GetDlgItem(wnd,ид–едакторRTF);
      »м€‘айла–едактора[0]:=char(0);
      ќбразецƒл€ѕоиска[0]:=char(0);
      ‘ильтрRTF:=SetWindowsHookEx(WH_GETMESSAGE,addr(‘ункци€‘ильтра),0,GetWindowThreadProcessId(ќкноRTF,nil));
      —оздать нопки(wnd);
      —оздать—татус(wnd,false);
      »зменить–азмерRTF(wnd);|
    WM_SIZE:»зменить–азмерRTF(wnd); —оздать—татус(wnd,true);|
    WM_COMMAND:case loword(wparam) of
      ид–едактор+ред‘айлЌовый:if  оманда¬ыход(wnd) then SetWindowText(ќкноRTF,"") end;|
      ид–едактор+ред‘айлќткрыть:if  оманда¬ыход(wnd) then  оманда‘айлќткрыть(wnd) end;|
      ид–едактор+ред‘айл—охранить: оманда‘айл—охранить(wnd);|
      ид–едактор+ред‘айл—охранить ак: оманда‘айл—охранить ак(wnd);|
      ид–едактор+ред‘айлѕечать: оманда‘айлѕечать(wnd);|
      ид–едактор+редѕравкаќтменить:SendMessage(ќкноRTF,EM_UNDO,0,0);|
      ид–едактор+редѕравка¬ырезать:SendMessage(ќкноRTF,WM_CUT,0,0);|
      ид–едактор+редѕравка опировать:SendMessage(ќкноRTF,WM_COPY,0,0);|
      ид–едактор+редѕравка¬ставить:SendMessage(ќкноRTF,WM_PASTE,0,0);|
      ид–едактор+редѕравка”далить:SendMessage(ќкноRTF,WM_CLEAR,0,0);|
      ид–едактор+редѕравка¬ыделить¬се: оманда¬ыделить¬се(wnd);|
      ид–едактор+редѕоиск: омандаѕоиск(wnd,true);|
      ид–едактор+ред—ледующийѕоиск: омандаѕоиск(wnd,false);|
      ид–едактор+ред‘орматЎрифт: омандаЎрифт(wnd);|
      ид–едактор+ред‘орматЎрифт∆ирный:”становитьЌачертаниеЎрифта(wnd,true);|
      ид–едактор+ред‘орматЎрифт урсив:”становитьЌачертаниеЎрифта(wnd,false);|
      ид–едактор+ред‘орматјбзац¬лево:”становить¬ыравниваниејбзаца(wnd,-1);|
      ид–едактор+ред‘орматјбзац¬право:”становить¬ыравниваниејбзаца(wnd,1);|
      ид–едактор+ред‘орматјбзацѕо÷ентру:”становить¬ыравниваниејбзаца(wnd,0);|
      ид–едактор+ред»нструментWINDOWS:—менить одировку(wnd,false);|
      ид–едактор+ред»нструментDOS:—менить одировку(wnd,true);|
      IDCANCEL,ид–едактор+ред‘айл¬ыход,ид–едактор+ред¬ыход:if  оманда¬ыход(wnd) then
        UnhookWindowsHookEx(‘ильтрRTF);
        EndDialog(wnd,1)
      end;|
    end;|
    WM_KEYDOWN:case loword(wparam) of
      VK_F3:SendMessage(wnd,WM_COMMAND,ид–едактор+ord(ред—ледующийѕоиск),0);|
    end;|
    WM_NOTIFY:¬ернуть“екст нопки(lparam);|
  else return(0);
  end;
  return(1);
end ƒиалогова€‘ункци€–едактора;

//--------------- вызов редактора ------------------

procedure –едакторRTF(–одительскоеќкно:HWND);
var модуль:HANDLE;
begin
  модуль:=LoadLibrary("RICHED32.DLL");
  DialogBoxParam(INSTANCE,"DLG_EDI",–одительскоеќкно,addr(ƒиалогова€‘ункци€–едактора),0);
  FreeLibrary(модуль);
end –едакторRTF;

begin
  –едакторRTF(0);
  ExitProcess(0); //необходимо дл€ выгрузки из пам€ти RTF
end Demo1_5.

