// —“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа
// ƒемо 5:“екстовый редактор RTF

include Win32

icon "icon_rtf.bmp";
define INSTANCE 0x400000

//===============================================
//                      ѕ≈–≈ћ≈ЌЌџ≈
//===============================================

enum —писок—татус {статус»м€‘айла,статус»зменен,статусЎрифт,статус–азмер,статус∆ирный,статус урсив};
typedef int[—писок—татус] “ип—татус;
define »нфо—татус “ип—татус{35,10,20,15,10,10}

HWND ќкно–едактора;
HWND ќкноRTF;
HWND ќкно—татус;
HWND ќкно нопок;
HANDLE ‘ильтрRTF;
char »м€‘айла–едактора[500];
char ќбразецƒл€ѕоиска[500];

//------------------------ команды редактора ----------------------------

enum —писок оманд–едактора {
    ред‘айлЌовый,ред‘айлќткрыть,ред‘айл—охранить,ред‘айл—охранить ак,редѕусто1,ред‘айлѕечать,редѕусто11,ред‘айл¬ыход,
    редѕравкаќтменить,редѕусто2,редѕравка¬ырезать,редѕравка опировать,редѕравка¬ставить,редѕравка”далить,редѕусто3,редѕравка¬ыделить¬се,
    редѕоиск,ред—ледующийѕоиск,
    ред‘орматЎрифт,редѕусто31,ред‘орматЎрифт∆ирный,ред‘орматЎрифт урсив,редѕусто4,ред‘орматјбзац¬лево,ред‘орматјбзац¬право,ред‘орматјбзацѕо÷ентру,
    ред»нструментWINDOWS,ред»нструментDOS,
    ред¬ыход};

enum —писок√рупп оманд–едактора {
    ред√руппа‘айл,ред√руппаѕравка,ред√руппаѕоиск,ред√руппа‘ормат,ред√руппа»нструмент,ред√руппа¬ыход};

typedef pchar[—писок оманд–едактора] “ип—войств оманд–едактора;
typedef struct {
    pchar »м€√руппы;
    —писок оманд–едактора ѕерва€ оманда√руппы;
    —писок оманд–едактора ѕоследн€€ оманда√руппы;
  } [—писок√рупп оманд–едактора] “ип—войств√рупп оманд–едактора;

define —войства оманд–едактора “ип—войств оманд–едактора{
    "Ќовый файл","ќткрыть файл...","—охранить файл","—охранить ак...","","ѕечать...","","Exit",
    "ќтменить","","¬ырезать\9Shift+Delete"," опировать\9Ctrl+Insert","¬ставить\9Shift+Insert","”далить\9Delete","","¬ыделить все",
    "ѕоиск...","—ледующий поиск\9F3",
    "Ўрифт","","”становить/убрать жирный","”становить/убрать курсив","","¬ыровн€ть абзац влево","¬ыровн€ть абзац вправо","¬ыровн€ть абзац по центру",
    "ѕеревести в кодировку WINDOWS","ѕеревести в кодировку DOS",
    "Exit"}
define —войства√рупп оманд–едактора “ип—войств√рупп оманд–едактора{
    {"File",ред‘айлЌовый,ред‘айл¬ыход},
    {"ѕравка",редѕравкаќтменить,редѕравка¬ыделить¬се},
    {"ѕоиск",редѕоиск,ред—ледующийѕоиск},
    {"‘ормат",ред‘орматЎрифт,ред‘орматјбзацѕо÷ентру},
    {"»нструменты",ред»нструментWINDOWS,ред»нструментDOS},
    {"Exit",ред¬ыход,ред¬ыход}}

//номера кнопок в toolbar (от 1)
typedef int [—писок оманд–едактора] “ип нопок;
define Ќомер нопки “ип нопок{
    1,2,3,4,0,5,0,0,
    6,0,7,8,9,10,0,0,
    11,12,
    13,0,14,15,0,16,17,18,
    19,20,
    0}

define ид–едактор 200
define ид–едакторRTF 101

//===============================================
//              ¬—ѕќћќ√ј“≈Ћ№Ќџ≈ ѕ–ќ÷≈ƒ”–џ
//===============================================

void mbI(int цел, char* комм) {
char стр[100];

  wvsprintf(стр,'%li',&цел);
  MessageBox(0,стр,комм,0);
}

//---------------- —оздание статус-строки редактора ----------------

void —оздать—татус(HWND окно, bool бит“олько–азмеры) {
 int размер[—писок—татус];
 RECT регион;
 —писок—татус статус;
 int тек,ширина;

  if(!бит“олько–азмеры) {
    ќкно—татус=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      NULL,окно,0);
  }
  GetClientRect(окно,регион);
  if(бит“олько–азмеры) {
  with(регион) {
    SendMessage(ќкно—татус,WM_SIZE,right-left+1,bottom-top+1);
  }}
  тек=0;
  for(статус=статус»м€‘айла; статус<=статус урсив; статус++) {
    ширина=(регион.right-регион.left+1)*»нфо—татус[статус] / 100;
    размер[статус]=тек+ширина;
    тек++ширина;
  }
  размер[статус урсив]=-1;
  SendMessage(ќкно—татус,SB_SETPARTS,ord(статус урсив)+1,(uint)&размер);
}

//------------- ќбновление статус-строки --------------------

void ќбновить—татус(HWND wnd) {
char строка[500]; CHARFORMAT формат;

  SendMessage(ќкно—татус,SB_SETTEXT,ord(статус»м€‘айла),(uint)&»м€‘айла–едактора);
  if((bool)SendMessage(ќкноRTF,EM_GETMODIFY,0,0))
    SendMessage(ќкно—татус,SB_SETTEXT,ord(статус»зменен),(uint)"»зменен");
  else SendMessage(ќкно—татус,SB_SETTEXT,ord(статус»зменен),(uint)"");
  with(формат) {
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(ќкноRTF,EM_GETCHARFORMAT,1,(uint)&формат);
    SendMessage(ќкно—татус,SB_SETTEXT,ord(статусЎрифт),(uint)&szFaceName);
    yHeight=yHeight / 20;
    wvsprintf(строка,"–азмер:%li",&yHeight);
    SendMessage(ќкно—татус,SB_SETTEXT,ord(статус–азмер),(uint)&строка);
    if(dwEffects & CFE_BOLD==0)
      SendMessage(ќкно—татус,SB_SETTEXT,ord(статус∆ирный),(uint)"");
    else SendMessage(ќкно—татус,SB_SETTEXT,ord(статус∆ирный),(uint)"ѕолужирный");
    if(dwEffects & CFE_ITALIC==0)
      SendMessage(ќкно—татус,SB_SETTEXT,ord(статус урсив),(uint)"");
    else SendMessage(ќкно—татус,SB_SETTEXT,ord(статус урсив),(uint)" урсив");
  }
}

//------------------------ выравнивание абзаца ----------------------------

void ”становить¬ыравниваниејбзаца(HWND wnd, int выравнивание) {
PARAFORMAT формат;

  with(формат) {
    cbSize=sizeof(PARAFORMAT);
    dwMask=PFM_ALIGNMENT;
    switch(выравнивание) {
      case -1:wAlignment=PFA_LEFT; break;
      case 0:wAlignment=PFA_CENTER; break;
      case 1:wAlignment=PFA_RIGHT; break;
    }
    SendMessage(ќкноRTF,EM_SETPARAFORMAT,0,(uint)&формат);
  }
}

//-------------------- сменить начертание шрифта -------------------------

void ”становитьЌачертаниеЎрифта(HWND wnd, bool битѕолужирный) {
CHARFORMAT формат;

  with(формат) {
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(ќкноRTF,EM_GETCHARFORMAT,1,(uint)&формат);
    switch(битѕолужирный) {
      case true:dwMask=CFM_BOLD; dwEffects=(!dwEffects & CFE_BOLD) | (dwEffects & !CFE_BOLD); break;
      case false:dwMask=CFM_ITALIC; dwEffects=(!dwEffects & CFE_ITALIC) | (dwEffects & !CFE_ITALIC); break;
    }
    SendMessage(ќкноRTF,EM_SETCHARFORMAT,SCF_SELECTION,(uint)&формат);
  }
}

//-------------------- проверка на текстовый файл -------------------------

bool “екстовый‘айл(char *им€‘айла) {
int точка;

  точка=lstrlen(им€‘айла)-4;
  return (точка>=0)&((им€‘айла[точка+1]=='t') | (им€‘айла[точка+1]=='T'));
}

//------------ функци€ обратного вызова загрузки ----------

uint «агрузитьЅлок(uint dwCookie, void *pbBuff, uint cb, pINT pcb)
{
  *pcb=_lread(dwCookie,pbBuff,cb);
  if(*pcb<0)
    *pcb=0;
  return 0;
}

//-------------------- загрузить файл(load file)-------------------------

void «агрузить‘айл–едактора(HWND wnd, char *им€‘айла) {
int файл; EDITSTREAM поток;

  with(поток) {
    файл=_lopen(им€‘айла,0);
    if(файл>0) {
      dwCookie=файл;
      dwError=0;
      pfnCallback=&«агрузитьЅлок;
      if(“екстовый‘айл(им€‘айла))
        SendMessage(ќкноRTF,EM_STREAMIN,SF_TEXT,(uint)&поток);
      else SendMessage(ќкноRTF,EM_STREAMIN,SF_RTF,(uint)&поток);
      _lclose(файл);
      SendMessage(ќкноRTF,EM_SETMODIFY,0,0);
    }
  }
}

//------------ функци€ обратного вызова сохранени€ ----------

uint —охранитьЅлок(uint dwCookie, void *pbBuff, uint cb, pINT pcb)
{
  cb=_lwrite(dwCookie,pbBuff,cb);
  *pcb=cb;
  return 0;
}

//-------------------- сохранить файл(save file)-------------------------

void —охранить‘айл–едактора(HWND wnd, char *им€‘айла) {
int файл; EDITSTREAM поток;

  with(поток) {
    файл=_lcreat(им€‘айла,0);
    if(файл>0) {
      dwCookie=файл;
      dwError=0;
      pfnCallback=&—охранитьЅлок;
      if(“екстовый‘айл(им€‘айла))
        SendMessage(ќкноRTF,EM_STREAMOUT,SF_TEXT,(uint)&поток);
      else SendMessage(ќкноRTF,EM_STREAMOUT,SF_RTF,(uint)&поток);
      _lclose(файл);
       SendMessage(ќкноRTF,EM_SETMODIFY,0,0);
    }
  }
}

//-------------------- диалог поиска -------------------------

define идќбразецƒл€ѕоиска 101

dialog DLG_FIND 80,58,160,65,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "ѕоиск текста"
begin
  control "ќбразец дл€ поиска:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,5,3,149,11
  control "",идќбразецƒл€ѕоиска,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,6,16,149,12
  control "ќк",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,31,48,45,12
  control "ќтмена",IDCANCEL,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,82,48,45,12
end;

uint ƒиалогова€‘ункци€ѕоиска(HWND wnd,uint msg,uint wparam,uint lparam)
{
  switch(msg) {
    case WM_INITDIALOG:SetDlgItemText(wnd,идќбразецƒл€ѕоиска,ќбразецƒл€ѕоиска); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:
        GetDlgItemText(wnd,идќбразецƒл€ѕоиска,ќбразецƒл€ѕоиска,500);
        EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    default:return 0; break;
  }
  return 1;
}

//---------------------------инициализаци€ toolbar------------------------------

bitmap bmpToolbar="tool_rtf.bmp";

void —оздать нопки(HWND wnd) {
  TBBUTTON кнопки[50];
  int количество;
  HBITMAP bmp;
  —писок√рупп оманд–едактора группа;
  —писок оманд–едактора команда;
  RECT регион;

  InitCommonControls();
  bmp=LoadBitmap(INSTANCE,"bmpToolbar");
  //заполнение массива кнопок
  количество=-1;
  for(группа=ред√руппа‘айл; группа<=ред√руппа»нструмент; группа++) {
  with(—войства√рупп оманд–едактора[группа]) { 
    //кнопки группы команд
    for(команда=ѕерва€ оманда√руппы; команда<=ѕоследн€€ оманда√руппы; команда++) {
    if((Ќомер нопки[команда]>0)and(количество<50)) {
      количество++;
      RtlZeroMemory(&(кнопки[количество]),sizeof(TBBUTTON));
      with(кнопки[количество]) {
        iBitmap=Ќомер нопки[команда]-1;
        idCommand=ид–едактор+ord(команда);
        fsState=TBSTATE_ENABLED;
        fsStyle=TBSTYLE_BUTTON;
      }
    }}
    //промежуток между кнопками
    if(количество<50) {
      количество++;
      RtlZeroMemory(&(кнопки[количество]),sizeof(TBBUTTON));
      with(кнопки[количество]) {
        fsState=TBSTATE_ENABLED;
        fsStyle=TBSTYLE_SEP;
      }
    }
  }}
  //создание toolbar
  ќкно нопок=CreateToolbarEx(
    wnd,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,количество,0,bmp,&кнопки,количество,20,20,20,20,sizeof(TBBUTTON));
  //коррекци€ положени€ toolbar
  with(регион) {
    GetWindowRect(ќкно нопок,регион);
    bottom++10;
    MoveWindow(ќкно нопок,left,top,right-left+1,bottom-top+1,true);
  }
}

//---------------------------тексты кнопок toolbar------------------------------

void ¬ернуть“екст нопки(uint lparam) {
  pNMHDR ук»нфо;
  pTOOLTIPTEXT ук»нфо“екст;
  —писок оманд–едактора команда;

  ук»нфо=(pvoid)lparam;
  ук»нфо“екст=(pvoid)lparam;
  with(*ук»нфо,*ук»нфо“екст) {
    команда=—писок оманд–едактора(idFrom-ид–едактор);
    switch(code) {
      case TTN_NEEDTEXT:{
        команда=—писок оманд–едактора(idFrom-ид–едактор);
        lpszText=—войства оманд–едактора[команда];}
    }
  }
}

//---------------------------размеры окна RTF------------------------------

void »зменить–азмерRTF(HWND wnd) {
RECT регион–едактора,регион нопок,регион—татус,регионRTF;

  with(регионRTF) {
    GetClientRect(wnd,регион–едактора);
    GetWindowRect(ќкно нопок,регион нопок);
    GetWindowRect(ќкно—татус,регион—татус);
    left=5;
    right=регион–едактора.right-регион–едактора.left-10;
    top=регион нопок.bottom-регион нопок.top+5;
    bottom=
      (регион–едактора.bottom-регион–едактора.top)-
      (регион—татус.bottom-регион—татус.top)-
      (регион нопок.bottom-регион нопок.top)-10;
    MoveWindow(ќкноRTF,left,top,right,bottom,true);
  }
}

//-------------------- сменить кодировку -------------------------

void —менить одировку(HWND wnd, bool битDOS) {
char *буфер;

  if(!(!“екстовый‘айл(»м€‘айла–едактора) &
    (MessageBox(ќкно–едактора,"¬ы уверены в необходимости смены кодировки ?","¬Ќ»ћјЌ»≈:",MB_YESNO)!=IDYES))) {
    буфер=GlobalLock(GlobalAlloc(GMEM_FIXED,GetWindowTextLength(ќкноRTF)+1));
    GetWindowText(ќкноRTF,буфер,GetWindowTextLength(ќкноRTF)+1);
    if(битDOS)
      CharToOem(буфер,буфер);
    else OemToChar(буфер,буфер);
    SetWindowText(ќкноRTF,буфер);
    GlobalFree(GlobalHandle(буфер));
  }
}

//===============================================
//                  ќЅ–јЅќ“„» »  ќћјЌƒ ћ≈Ќё
//===============================================

//-------------------- открыть файл(open file)-------------------------

void  оманда‘айлќткрыть(HWND wnd) {
char[500] путь,им€; OPENFILENAME ofn;

  with(ofn) {
    lstrcpy(путь,"*.rtf");
    им€[0]='\0';
    RtlZeroMemory(&ofn,sizeof(OPENFILENAME));
    lStructSize=sizeof(OPENFILENAME);
    lpstrFilter="RTF-файлы\0*.rtf\0“екстовые файлы\0*.txt\0";
    nFilterIndex=1;
    lpstrFile=&путь;
    nMaxFile=500;
    lpstrFileTitle=&им€;
    nMaxFileTitle=500;
    Flags=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if(GetOpenFileName(ofn)) {
      «агрузить‘айл–едактора(wnd,путь);
      lstrcpy(»м€‘айла–едактора,путь);
    }
  }
}

//-------------------- сохранить файл(save file)-------------------------

void  оманда‘айл—охранить(HWND wnd)
{
  if(»м€‘айла–едактора[0]!='\0') {
    —охранить‘айл–едактора(wnd,»м€‘айла–едактора);
  }
}

//-------------------- сохранить как -------------------------

void  оманда‘айл—охранить ак(HWND wnd) {
char[500] путь,им€; OPENFILENAME ofn;

  with(ofn) {
    lstrcpy(путь,"*.rtf");
    им€[0]='\0';
    RtlZeroMemory(&ofn,sizeof(OPENFILENAME));
    lStructSize=sizeof(OPENFILENAME);
    lpstrFilter="RTF-файлы\0*.rtf\0“екстовые файлы\0*.txt\0";
    nFilterIndex=1;
    lpstrFile=&путь;
    nMaxFile=500;
    lpstrFileTitle=&им€;
    nMaxFileTitle=500;
    Flags=OFN_NOCHANGEDIR | OFN_HIDEREADONLY;
    if(GetSaveFileName(ofn)) {
      —охранить‘айл–едактора(wnd,путь);
      lstrcpy(»м€‘айла–едактора,путь);
    }
  }
}

//-------------------- выделить все -------------------------

void  оманда¬ыделить¬се(HWND wnd) {
CHARRANGE регион;

  with(регион) {
    cpMin=0;
    cpMax=-1;
    SendMessage(ќкноRTF,EM_EXSETSEL,0,(uint)&регион);
  }
}

//-------------------- поиск -------------------------

void  омандаѕоиск(HWND wnd, bool бит«апросќбразца) {
FINDTEXTEX образец; int найдено;

  if((бит«апросќбразца &
    (bool)DialogBoxParam(INSTANCE,"DLG_FIND",ќкноRTF,&ƒиалогова€‘ункци€ѕоиска,0)) |
    !бит«апросќбразца) {
    with(образец) {
      if(бит«апросќбразца)
        chrg.cpMin=0;
      else chrg.cpMin=hiword(SendMessage(ќкноRTF,EM_GETSEL,0,0));
      chrg.cpMax=-1;
      lpstrText=&ќбразецƒл€ѕоиска;
      найдено=SendMessage(ќкноRTF,EM_FINDTEXTEX,0,(uint)&образец);
      if(найдено==-1)
        MessageBox(ќкноRTF,"‘рагмент не найден","¬Ќ»ћјЌ»≈:",MB_ICONSTOP);
      else SendMessage(ќкноRTF,EM_SETSEL,chrgText.cpMin,chrgText.cpMax);
    }
  }
}

//-------------------- выбор шрифта -------------------------

void  омандаЎрифт(HWND wnd) {
CHARFORMAT формат; CHOOSEFONT шрифт; LOGFONT логшрифт; HDC dc;

  with(формат) {
  //получить текущий формат
    cbSize=sizeof(CHARFORMAT);
    dwMask=CFM_FACE | CFM_SIZE | CFM_BOLD | CFM_ITALIC | CFM_UNDERLINE;
    SendMessage(ќкноRTF,EM_GETCHARFORMAT,1,(uint)&формат);
    dc=GetDC(wnd);
  //заполнить шрифт текущими характеристиками
    with(логшрифт) {
      RtlZeroMemory(&логшрифт,sizeof(LOGFONT));
      lfItalic=(byte)((dwEffects & CFE_ITALIC)!=0);
      lfHeight=-yHeight / 15;
      lfPitchAndFamily=bPitchAndFamily;
      lstrcpy(lfFaceName,szFaceName);
      if((dwEffects & CFE_BOLD)==0)
        lfWidth=FW_NORMAL;
      else lfWidth=FW_BOLD;
    }
  //заполнить структуру выбора шрифта
    with(шрифт) {
      RtlZeroMemory(&шрифт,sizeof(CHOOSEFONT));
      lStructSize=sizeof(CHOOSEFONT);
      Flags=CF_SCREENFONTS | CF_INITTOLOGFONTSTRUCT;
      hDC=dc;
      hwndOwner=wnd;
      lpLogFont=&логшрифт;
      rgbColors=0;
      nFontType=SCREEN_FONTTYPE;
    }
  //выбор шрифта
    if(ChooseFont(шрифт)) {
  //заполн€ем формат символа
      with(логшрифт) {
        dwMask=CFM_BOLD | CFM_FACE | CFM_ITALIC | CFM_UNDERLINE | CFM_SIZE | CFM_OFFSET;
        yHeight=-lfHeight*15;
        dwEffects=0;
        if((bool)lfItalic) dwEffects=dwEffects | CFE_ITALIC;
        if(lfWeight==FW_BOLD) dwEffects=dwEffects | CFE_BOLD;
        bPitchAndFamily=lfPitchAndFamily;
        lstrcpy(szFaceName,lfFaceName);
      }
//измен€ем формат символов
      SendMessage(ќкноRTF,EM_SETCHARFORMAT,SCF_SELECTION,(uint)&формат);
    }
    ReleaseDC(wnd,dc);
  }
}

//-------------------- печать файла -------------------------

void  оманда‘айлѕечать(HWND wnd) {
  DOCINFO документ;
  FORMATRANGE формат;
  PRINTDLG печать;
  int результат;
  int текущий—имвол,последний—имвол;
  HDC dc;

  //заполнить структуру дл€ диалога печати
  with(печать) {
    RtlZeroMemory(&печать,sizeof(PRINTDLG));
    lStructSize=sizeof(PRINTDLG);
    hwndOwner=ќкноRTF;
    hInstance=INSTANCE;
    Flags=PD_RETURNDC | PD_NOPAGENUMS | PD_NOSELECTION | PD_PRINTSETUP | PD_ALLPAGES;
    nFromPage=0xFFFF;
    nToPage=0xFFFF;
    nMinPage=0;
    nMaxPage=0xFFFF;
    nCopies=1;
  }
  //вывод диалога печати
  if(PrintDlg(печать)) {
    dc=печать.hDC;
  //заполнение полей структуры форматировани€
    with(формат) {
      RtlZeroMemory(&формат,sizeof(FORMATRANGE));
      hdc=dc; //контекст печати принтера
      hdcTarget=dc;
      chrg.cpMin=0; //весь документ
      chrg.cpMax=-1;
      rcPage.top=0; //размеры страницы в TWIPS
      rcPage.left=0;
      rcPage.right=MulDiv(GetDeviceCaps(dc,PHYSICALWIDTH),1440,GetDeviceCaps(dc,LOGPIXELSX));
      rcPage.bottom=MulDiv(GetDeviceCaps(dc,PHYSICALHEIGHT),1440,GetDeviceCaps(dc,LOGPIXELSY));
      rc=rcPage;
    }
  //заполнение полей документа
    with(документ) {
      RtlZeroMemory(&документ,sizeof(DOCINFO));
      cbSize=sizeof(DOCINFO);
      lpszOutput=NULL;
      lpszDocName="Strannik";
    }
  //печать документа
    результат=StartDoc(dc,документ);
    if(результат<0) MessageBox(ќкноRTF,"ќшибка печати","¬Ќ»ћјЌ»≈:",MB_ICONSTOP);
    else {
      текущий—имвол=0;
      последний—имвол=SendMessage(ќкноRTF,WM_GETTEXTLENGTH,0,0);
      while(текущий—имвол<последний—имвол) {
      //форматирование и печать
        текущий—имвол=SendMessage(ќкноRTF,EM_FORMATRANGE,1,(uint)&формат);
        if(текущий—имвол<последний—имвол) {
          EndPage(dc);
          StartPage(dc);
          формат.chrg.cpMin=текущий—имвол;
          формат.chrg.cpMax=-1;
        }
        SendMessage(ќкноRTF,EM_FORMATRANGE,1,0);
        EndPage(dc);
        EndDoc(dc);
      }
    }
    DeleteDC(dc);
  }
}

//-------------------- выход из редактора -------------------------

bool  оманда¬ыход(HWND wnd) {
uint ответ;

   if((bool)SendMessage(ќкноRTF,EM_GETMODIFY,0,0)) {
     ответ=MessageBox(ќкноRTF,"‘айл был изменен. —охранить ?","¬Ќ»ћјЌ»≈",MB_ICONSTOP | MB_YESNOCANCEL);
     switch(ответ) {
       case IDYES:{—охранить‘айл–едактора(wnd,»м€‘айла–едактора); return true;}
       case IDNO:{return true;}
       case IDCANCEL:{return false;}
     }
   }
   else return true;
}

//===============================================
//            ƒ»јЋќ√ќ¬јя ‘”Ќ ÷»я –≈ƒј “ќ–ј
//===============================================

//------------------------ создание меню(create menu)----------------------------

void —оздатьћеню–едактора(HWND wnd) {
  HMENU меню оманд,меню√руппы;
  —писок оманд–едактора команда;
  —писок√рупп оманд–едактора группа;

  меню оманд=CreateMenu();
  for(группа=ред√руппа‘айл;  группа<=ред√руппа»нструмент; группа++) {
  with(—войства√рупп оманд–едактора[группа]) { 
    меню√руппы=CreatePopupMenu();
    for(команда=ѕерва€ оманда√руппы; команда<=ѕоследн€€ оманда√руппы; команда++) {
      if(—войства оманд–едактора[команда][0]=='\0')
        AppendMenu(меню√руппы,MF_SEPARATOR,0,NULL);
      else AppendMenu(меню√руппы,MF_STRING,ид–едактор+(int)команда,—войства оманд–едактора[команда]);
    }
    AppendMenu(меню оманд,MF_POPUP,меню√руппы,»м€√руппы);
  }}
  AppendMenu(меню оманд,MF_STRING,ид–едактор+(int)ред¬ыход,—войства оманд–едактора[ред¬ыход]);
  SetMenu(wnd,меню оманд);
}

//------------ функци€ фильтра дл€ RichEdit ------------------

uint ‘ункци€‘ильтра(int code,int wparam,int lparam) {
pMSG messageение;

  messageение=(pMSG)lparam;
  with(*messageение) {
  if(code==HC_ACTION) {
    ќбновить—татус(hwnd);
    switch(message) {
      case WM_KEYDOWN:SendMessage(ќкно–едактора,message,wParam,lParam); break;
    }
  }}
  return 0;
}

//------------------------ диалог редактора ----------------------------

dialog DLG_EDI 6,5,291,179,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "“екстовый редактор '—транник'"
begin
  control "",ид–едакторRTF,"RichEdit",WS_CHILD | WS_BORDER | ES_MULTILINE | ES_AUTOVSCROLL | WS_VSCROLL | ES_WANTRETURN | WS_VISIBLE | ES_SAVESEL,2,12,286,146
end;

//--------------- диалогова€ функци€ редактора ------------------

uint ƒиалогова€‘ункци€–едактора(HWND wnd,uint msg,uint wparam,uint lparam)
{
  switch(msg) {
    case WM_INITDIALOG:
      —оздатьћеню–едактора(wnd);
      ќкно–едактора=wnd;
      ќкноRTF=GetDlgItem(wnd,ид–едакторRTF);
      »м€‘айла–едактора[0]='\0';
      ќбразецƒл€ѕоиска[0]='\0';
      ‘ильтрRTF=SetWindowsHookEx(WH_GETMESSAGE,&‘ункци€‘ильтра,0,GetWindowThreadProcessId(ќкноRTF,NULL));
      —оздать нопки(wnd);
      —оздать—татус(wnd,false);
      »зменить–азмерRTF(wnd); break;
    case WM_SIZE:»зменить–азмерRTF(wnd); —оздать—татус(wnd,true); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case ид–едактор+ред‘айлЌовый:if( оманда¬ыход(wnd)) SetWindowText(ќкноRTF,""); break;
      case ид–едактор+ред‘айлќткрыть:if( оманда¬ыход(wnd))  оманда‘айлќткрыть(wnd); break;
      case ид–едактор+ред‘айл—охранить: оманда‘айл—охранить(wnd); break;
      case ид–едактор+ред‘айл—охранить ак: оманда‘айл—охранить ак(wnd); break;
      case ид–едактор+ред‘айлѕечать: оманда‘айлѕечать(wnd); break;
      case ид–едактор+редѕравкаќтменить:SendMessage(ќкноRTF,EM_UNDO,0,0); break;
      case ид–едактор+редѕравка¬ырезать:SendMessage(ќкноRTF,WM_CUT,0,0); break;
      case ид–едактор+редѕравка опировать:SendMessage(ќкноRTF,WM_COPY,0,0); break;
      case ид–едактор+редѕравка¬ставить:SendMessage(ќкноRTF,WM_PASTE,0,0); break;
      case ид–едактор+редѕравка”далить:SendMessage(ќкноRTF,WM_CLEAR,0,0); break;
      case ид–едактор+редѕравка¬ыделить¬се: оманда¬ыделить¬се(wnd); break;
      case ид–едактор+редѕоиск: омандаѕоиск(wnd,true); break;
      case ид–едактор+ред—ледующийѕоиск: омандаѕоиск(wnd,false); break;
      case ид–едактор+ред‘орматЎрифт: омандаЎрифт(wnd); break;
      case ид–едактор+ред‘орматЎрифт∆ирный:”становитьЌачертаниеЎрифта(wnd,true); break;
      case ид–едактор+ред‘орматЎрифт урсив:”становитьЌачертаниеЎрифта(wnd,false); break;
      case ид–едактор+ред‘орматјбзац¬лево:”становить¬ыравниваниејбзаца(wnd,-1); break;
      case ид–едактор+ред‘орматјбзац¬право:”становить¬ыравниваниејбзаца(wnd,1); break;
      case ид–едактор+ред‘орматјбзацѕо÷ентру:”становить¬ыравниваниејбзаца(wnd,0); break;
      case ид–едактор+ред»нструментWINDOWS:—менить одировку(wnd,false); break;
      case ид–едактор+ред»нструментDOS:—менить одировку(wnd,true); break;
      case IDCANCEL: case ид–едактор+ред‘айл¬ыход: case ид–едактор+ред¬ыход:if( оманда¬ыход(wnd)) {
        UnhookWindowsHookEx(‘ильтрRTF);
        EndDialog(wnd,1);
      } break;
    } break;
    case WM_KEYDOWN:switch(loword(wparam)) {
      case VK_F3:SendMessage(wnd,WM_COMMAND,ид–едактор+ord(ред—ледующийѕоиск),0); break;
    } break;
    case WM_NOTIFY:¬ернуть“екст нопки(lparam); break;
    default:return 0; break;
  }
  return 1;
}

//--------------- вызов редактора ------------------

void –едакторRTF(HWND –одительскоеќкно) {
HANDLE модуль;

  модуль=LoadLibrary("RICHED32.DLL");
  DialogBoxParam(INSTANCE,"DLG_EDI",–одительскоеќкно,&ƒиалогова€‘ункци€–едактора,0);
  FreeLibrary(модуль);
}

void main()
{
  –едакторRTF(0);
  ExitProcess(0); //необходимо дл€ выгрузки из пам€ти RTF
}

