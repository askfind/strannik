// ��������  ������-��-������� ��� Win32
// ���������������� ��������� (���������� Win32)
// ���� 2.12:������ � ����������

include Win32

define hINSTANCE 0x400000

//����� ������� � ������
  int lstrposc(char sym, char* str)
{int i;
  
    if(str==NULL) return -1;
    i=0;
    while((str[i]!='\0')&&(str[i]!=sym))
      i++;
    if(str[i]==sym) return(i);
    else return(-1);
  }

//�������� ���������
  void lstrdel(char* str, int pos,int len)
{int i,l;
  
    if(pos<0) {
      len=len+pos;
      pos=0;
    }
    if(len>=0) {
      l=lstrlen(str);
      if(pos+len>l)
        if(pos<l) str[pos]='\0'; else {}
      else
        for(i=1; i<=l-(pos+len)+1; i++)
          str[pos+i-1]=str[pos+i+len-1];
    }
  }

//��������� ���� ���������
void ������������������(HWND ���������, char* ������) {
  RECT ������; HDITEM �������; int ���,����;
  char �����[500],������[500];

  GetClientRect(���������,������);
  ����=0;
  for(���=0;���<=lstrlen(������)-1;���++) {
    if(������[���]!='\9') ����++;
  }
  lstrcpyn(�����,������,500);
  ���=0;
  while(lstrposc('\9',�����)>=0) {
    lstrcpy(������,�����);
    ������[lstrposc('\9',�����)]='\0';
    �������.mask=HDI_TEXT | HDI_FORMAT | HDI_WIDTH;
    �������.pszText=&������;
    �������.cxy=(������.right-������.left)*lstrlen(������) / (����-1);
    �������.cchTextMax=lstrlen(������);
    �������.fmt=HDF_LEFT | HDF_STRING;
    SendMessage(���������,HDM_INSERTITEM,���,(int)(&�������));
    lstrdel(�����,0,lstrposc('\9',�����)+1);
    ���++;
  }
}

// ���������� ������ ������
void ����������������(HWND ���������, pDRAWITEMSTRUCT ���) {
char ������[1000],�����[1000]; RECT ���; int ���,����; HDITEM ����;

  SendMessage(���->hwndItem,LB_GETTEXT,���->itemID,(int)(&�����));
  ���=0;
  ����=0;
  while(lstrposc('\9',�����)>=0) {
    lstrcpy(������,�����);
    ������[lstrposc('\9',�����)]='\0';
    ����.mask=HDI_WIDTH;
    SendMessage(���������,HDM_GETITEM,���,(int)(&����));
    ���=���->rcItem;
    ���.left++����;
    ���.right=���.left+����.cxy;
    if(���->itemState and ODS_SELECTED<>0)
      {SetTextColor(���->hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(���->hDC,GetSysColor(COLOR_HIGHLIGHT));}
    else {SetTextColor(���->hDC,GetSysColor(COLOR_WINDOWTEXT)); SetBkColor(���->hDC,GetSysColor(COLOR_MENU));}
    ExtTextOut(���->hDC,���.left,���.top,ETO_CLIPPED | ETO_OPAQUE,&���,������,lstrlen(������),NULL);
    lstrdel(�����,0,lstrposc('\9',�����)+1);
    ���++;
    ����++����.cxy;
  }
}

//������
dialog DLG_LIST 126,40,306,169,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Demo2_12"
begin
  control "",100,"Listbox",WS_BORDER | WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_VSCROLL | LBS_OWNERDRAWFIXED | LBS_HASSTRINGS | LBS_WANTKEYBOARDINPUT,32,18,240,123
  control "",101,"SysHeader32",WS_CHILD | WS_VISIBLE | WS_BORDER | HDS_BUTTONS | HDS_HORZ,32,3,240,14
  control "��",IDOK,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,128,144,52,14
end;

//���������� �������
bool procDLG_LIST(HWND wnd, int message,int wparam,int lparam) {
  switch(message) {
    case WM_INITDIALOG:
      ������������������(GetDlgItem(wnd,101),"File             \9Size     \9Date        \9");
      SendDlgItemMessage(wnd,100,LB_RESETCONTENT,0,0);
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_10 \9 12K \9 12.03.2004 \9");
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_11 \9 29K \9 01.08.2004 \9");
      SendDlgItemMessage(wnd,100,LB_ADDSTRING,0,(int)"demo1_12 \9 18K \9 20.11.2004 \9");
    break;
    case WM_DRAWITEM:if(wparam<>0) ����������������(GetDlgItem(wnd,101),(pDRAWITEMSTRUCT)(lparam)); break;
    case WM_MEASUREITEM:break;//������ ������ ������
    case WM_VKEYTOITEM:break;//���������� ������� �� ���������� � ������
    case WM_COMMAND:switch(loword(wparam)) {
      case IDOK:case IDCANCEL:EndDialog(wnd,1); break;
    } break;
  default:return false; break;
  }
  return true;
}

void main() {
  InitCommonControlsEx(NULL);
  DialogBoxParam(hINSTANCE,"DLG_LIST",0,&procDLG_LIST,0);
}

