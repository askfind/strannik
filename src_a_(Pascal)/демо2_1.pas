// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.1:–абота с деревом

program Demo2_1;
uses Win32;

const 
  hINSTANCE=0x400000;

  идƒобавить=100;
  ид”далить=101;
  идќк=200;
  идќкноƒерево=1000;

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

var
  иконкаќткр:dword;
  иконка«акр:dword;

//================= добавить элемент в дерево =======================

function ƒобавитьЁлемент¬ƒерево(окно:HWND; ниже,после:HTREEITEM; текст:pstr, иконка,иконка¬ыдел:HBITMAP):HTREEITEM;
var структ:TV_INSERTSTRUCT;
begin
  RtlZeroMemory(addr(структ),sizeof(TV_INSERTSTRUCT));
  with структ,item do begin
    mask:=TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;
    pszText:=текст;
    cchTextMax:=lstrlen(текст);
    iImage:=иконка;
    iSelectedImage:=иконка¬ыдел;
    hInsertAfter:=после;
    hParent:=ниже;  
  end;
  ƒобавитьЁлемент¬ƒерево:=HTREEITEM(SendMessage(окно,TVM_INSERTITEM,0,integer(addr(структ))))
end;

//================= создать окно с деревом =======================

procedure —оздатьƒерево(главное:HWND; ид:dword);
var список:HIMAGELIST; иконка:HBITMAP;
begin
  InitCommonControls();
  список:=ImageList_Create(20,20,0,2,0);
  иконка:=LoadBitmap(hINSTANCE,"TreeOpen"); иконкаќткр:=ImageList_Add(список,иконка,0);
  иконка:=LoadBitmap(hINSTANCE,"TreeClose"); иконка«акр:=ImageList_Add(список,иконка,0);
  SendMessage(GetDlgItem(главное,ид),TVM_SETIMAGELIST,TVSIL_NORMAL,список);
end;

//================= заполнить дерево элементами =======================

procedure «аполнитьƒерево(окно:HWND);
var корень,первый,второй:HTREEITEM;
begin
  корень:=ƒобавитьЁлемент¬ƒерево(окно,TVI_ROOT,TVI_FIRST,"корневой элемент",иконка«акр,иконкаќткр);
  первый:=ƒобавитьЁлемент¬ƒерево(окно,корень,TVI_LAST,"первый уровнь, элемент 1",иконка«акр,иконкаќткр);
  второй:=ƒобавитьЁлемент¬ƒерево(окно,первый,TVI_LAST,"второй уровнь, элемент 1",иконка«акр,иконкаќткр);
  второй:=ƒобавитьЁлемент¬ƒерево(окно,первый,TVI_LAST,"второй уровнь, элемент 2",иконка«акр,иконкаќткр);
  первый:=ƒобавитьЁлемент¬ƒерево(окно,корень,TVI_LAST,"первый уровнь, элемент 2",иконка«акр,иконкаќткр);
  второй:=ƒобавитьЁлемент¬ƒерево(окно,первый,TVI_LAST,"второй уровнь, элемент 3",иконка«акр,иконкаќткр);
end;

//================= добавть новый элемент после текущего =======================

procedure командаƒобавить(окно:HWND);
var текущий,вышележащий:HTREEITEM;
begin
  текущий:=SendMessage(окно,TVM_GETNEXTITEM,TVGN_CARET,0);
  вышележащий:=SendMessage(окно,TVM_GETNEXTITEM,TVGN_PARENT,текущий);
  ƒобавитьЁлемент¬ƒерево(окно,вышележащий,текущий,"новый элемент",иконка«акр,иконкаќткр);
end;

//================= удалить текущий элемент =======================

procedure команда”далить(окно:HWND);
var текущий:HTREEITEM;
begin
  текущий:=SendMessage(окно,TVM_GETNEXTITEM,TVGN_CARET,0);
  SendMessage(окно,TVM_DELETEITEM,0,текущий);
end;

//================= обработка извещений от окна =======================

function ќбработать»звещениеќтƒерева(окно:HWND; инфо:pTV_DISPINFO):boolean;
begin
  with инфо^.hdr,инфо^.item do begin
  case code of
    TVN_ENDLABELEDIT://изменение текста элемента
      if pszText=nil then return false
      else begin
        MessageBox(0,pszText,"Ќовый текст",0);
        return true
      end;
  end end;
  ќбработать»звещениеќтƒерева:=false
end;

//================= главный диалог =======================

dialog DLG_MAIN 80,39,160,115,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo 2_1:–абота с деревом"
begin
  control "ќк",идќк,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,62,97,45,14
  control "",идќкноƒерево,"SysTreeView32",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | TVS_HASLINES | TVS_HASBUTTONS | TVS_LINESATROOT | TVS_EDITLABELS,8,24,145,67
  control "”далить",ид”далить,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,97,6,40,12
  control "ƒобавить",идƒобавить,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,33,6,40,12
end;

//================= диалогова€ функци€ =======================

function procDLG_MAIN(wnd:HWND; message,wparam,lparam:integer):boolean;
begin
  case message of
    WM_INITDIALOG:begin —оздатьƒерево(wnd,идќкноƒерево); «аполнитьƒерево(GetDlgItem(wnd,идќкноƒерево)) end;
    WM_COMMAND:case loword(wparam) of
      идƒобавить:командаƒобавить(GetDlgItem(wnd,идќкноƒерево));
      ид”далить:команда”далить(GetDlgItem(wnd,идќкноƒерево));
      IDOK,идќк:EndDialog(wnd,1);
      IDCANCEL:EndDialog(wnd,0);
    end;
    WM_NOTIFY:case loword(wparam) of
      идќкноƒерево:procDLG_MAIN:=ќбработать»звещениеќтƒерева(GetDlgItem(wnd,идќкноƒерево),address(lparam));
    end;
  else procDLG_MAIN:=false
  end;
  procDLG_MAIN:=true
end;

//================= вызов диалога ====================

begin
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,addr(procDLG_MAIN),0);
end.

