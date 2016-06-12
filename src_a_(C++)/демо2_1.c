// —“–јЌЌ»   ћодула-—и-ѕаскаль дл€ Win32
// ƒемонстрационна€ программа (ѕрименение Win32)
// ƒемо 2.1:–абота с деревом

include "Win32"

define hINSTANCE 0x400000

define идƒобавить 100
define ид”далить 101
define идќк 200
define идќкноƒерево 1000

bitmap TreeOpen="Tree_Op.bmp";
bitmap TreeClose="Tree_Cl.bmp";

uint иконкаќткр;
uint иконка«акр;

//================= добавить элемент в дерево =======================

HTREEITEM ƒобавитьЁлемент¬ƒерево(HWND окно, HTREEITEM ниже, HTREEITEM после, char* текст, HBITMAP иконка, HBITMAP иконка¬ыдел)
{
TV_INSERTSTRUCT структ;

  RtlZeroMemory(&структ,sizeof(TV_INSERTSTRUCT));
  with(структ,item) {
    mask=TVIF_TEXT | TVIF_IMAGE | TVIF_SELECTEDIMAGE | TVIF_PARAM;
    pszText=текст;
    cchTextMax=lstrlen(текст);
    iImage=иконка;
    iSelectedImage=иконка¬ыдел;
    hInsertAfter=после;
    hParent=ниже;  
  }
  return (HTREEITEM) SendMessage(окно,TVM_INSERTITEM,0,(int)(&структ));
}

//================= создать окно с деревом =======================

void —оздатьƒерево(HWND главное, uint ид)
{
HIMAGELIST список; HBITMAP иконка;
  InitCommonControls();
  список=ImageList_Create(20,20,0,2,0);
  иконка=LoadBitmap(hINSTANCE,"TreeOpen"); иконкаќткр=ImageList_Add(список,иконка,0);
  иконка=LoadBitmap(hINSTANCE,"TreeClose"); иконка«акр=ImageList_Add(список,иконка,0);
  SendMessage(GetDlgItem(главное,ид),TVM_SETIMAGELIST,TVSIL_NORMAL,список);
}

//================= заполнить дерево элементами =======================

void «аполнитьƒерево(HWND окно)
{
HTREEITEM корень,первый,второй;

  корень=ƒобавитьЁлемент¬ƒерево(окно,TVI_ROOT,TVI_FIRST,"корневой элемент",иконка«акр,иконкаќткр);
  первый=ƒобавитьЁлемент¬ƒерево(окно,корень,TVI_LAST,"первый уровнь, элемент 1",иконка«акр,иконкаќткр);
  второй=ƒобавитьЁлемент¬ƒерево(окно,первый,TVI_LAST,"второй уровнь, элемент 1",иконка«акр,иконкаќткр);
  второй=ƒобавитьЁлемент¬ƒерево(окно,первый,TVI_LAST,"второй уровнь, элемент 2",иконка«акр,иконкаќткр);
  первый=ƒобавитьЁлемент¬ƒерево(окно,корень,TVI_LAST,"первый уровнь, элемент 2",иконка«акр,иконкаќткр);
  второй=ƒобавитьЁлемент¬ƒерево(окно,первый,TVI_LAST,"второй уровнь, элемент 3",иконка«акр,иконкаќткр);
}

//================= добавть новый элемент после текущего =======================

void командаƒобавить(HWND окно)
{
HTREEITEM текущий,вышележащий;

  текущий=SendMessage(окно,TVM_GETNEXTITEM,TVGN_CARET,0);
  вышележащий=SendMessage(окно,TVM_GETNEXTITEM,TVGN_PARENT,текущий);
  ƒобавитьЁлемент¬ƒерево(окно,вышележащий,текущий,"новый элемент",иконка«акр,иконкаќткр);
}

//================= удалить текущий элемент =======================

void команда”далить(HWND окно)
{
HTREEITEM текущий;

  текущий=SendMessage(окно,TVM_GETNEXTITEM,TVGN_CARET,0);
  SendMessage(окно,TVM_DELETEITEM,0,текущий);
}

//================= обработка извещений от окна =======================

bool ќбработать»звещениеќтƒерева(HWND окно, TV_DISPINFO* инфо)
{
  with(инфо->hdr,инфо->item) {
  switch(code) {
    case TVN_ENDLABELEDIT://изменение текста элемента
      if(pszText==nil) return false;
      else {
        MessageBox(0,pszText,"Ќовый текст",0);
        return true;
      } break;
  }}
  return false;
}

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

bool procDLG_MAIN(HWND wnd, int message, int wparam, int lparam)
{
  switch(message) {
    case WM_INITDIALOG:—оздатьƒерево(wnd,идќкноƒерево); «аполнитьƒерево(GetDlgItem(wnd,идќкноƒерево)); break;
    case WM_COMMAND:switch(loword(wparam)) {
      case идƒобавить:командаƒобавить(GetDlgItem(wnd,идќкноƒерево)); break;
      case ид”далить:команда”далить(GetDlgItem(wnd,идќкноƒерево)); break;
      case IDOK: case идќк:EndDialog(wnd,1); break;
      case IDCANCEL:EndDialog(wnd,0); break;
    } break;
    case WM_NOTIFY:switch(loword(wparam)) {
      case идќкноƒерево:return ќбработать»звещениеќтƒерева(GetDlgItem(wnd,идќкноƒерево),(void*)lparam); break;
    } break;
  default:return false; break;
  }
  return true;
}

//================= вызов диалога ====================

void main()
{
  DialogBoxParam(hINSTANCE,"DLG_MAIN",0,&procDLG_MAIN,0);
}

