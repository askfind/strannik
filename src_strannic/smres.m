//�������� ������-��-������� ��� Win32
//������ RES (��������� ��������)
//���� SMRES.M

implementation module SmRes;
import Win32,Win32Ext,SmSys,SmDat,SmTab,SmGen,SmLex,SmAsm,SmTra;

procedure ������������(���:HWND); forward;

//procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean; forward;
procedure resDlgToTxt(txt:pstr); forward;

//===============================================
//    ������� ��������� ��������
//===============================================

//------ �������������� ���������� ������ � ���������� ----------

procedure ������XY(��:integer; ���Y:boolean):integer;
begin
  case ���Y of
    false:return integer(real(��*loword(GetDialogBaseUnits())) / 4.0);|
    true:return integer(real(��*hiword(GetDialogBaseUnits())) / 8.0);|
  end
end ������XY;

procedure ���XY���(xy:integer; ���Y:boolean):integer;
begin
  case ���Y of
    false:return integer(real(xy*4) / real(loword(GetDialogBaseUnits())));|
    true:return integer(real(xy*8) / real(hiword(GetDialogBaseUnits())));|
  end
end ���XY���;

//--------- ���������� ������ -----------------

procedure �������������(var ���:pstr; �����:pstr);
begin
  if �����=nil then ���:=nil
  else
    ���:=memAlloc(lstrlen(�����)+1);
    lstrcpy(���,�����);
  end
end �������������;

//--------- �������� ����� ����� --------------

procedure �������������(�����:pStyles; var ����:integer; �����:pstr);
begin
  if ����=maxItem
    then mbS(_�������_�����_������[envER])
    else inc(����)
  end;
  �����^[����]:=memAlloc(lstrlen(�����)+1);
  lstrcpy(�����^[����],�����);
end �������������;

//--------- �������� �������� �� ������ --------------

procedure �����������(���:integer; ���,���:pstr);
var ���:integer;
begin
  lstrcpy(���,���);
  for ���:=1 to ���-1 do
    if lstrposc(',',���)>=0 then
      lstrdel(���,0,lstrposc(',',���)+1)
    else ���[0]:=char(0);
    end
  end;
  if lstrposc(',',���)>=0 then
    lstrdel(���,lstrposc(',',���),999)
  end
end �����������;

//===============================================
//    ������� ������� �������� � �������
//===============================================

//---------- �������� ���� �������� -----------

procedure ���������������(����:integer);
var �����:integer;
begin
with resDlg,dItems^[����]^,iRect do
  iBlock:=false;
  �����:=WS_CHILD | WS_VISIBLE | WS_BORDER;
  iWnd:=CreateWindowEx(0,�������������,nil,�����,x,y,dx,dy,
    resDlg.dItems^[0]^.iWnd,0,hINSTANCE,nil);
  if (iText<>nil)and(iText[0]<>char(0))
    then SetWindowText(iWnd,iText)
    else SetWindowText(iWnd,iClass)
  end
end
end ���������������;

//---------- �������� ���� ������� ------------

procedure ��������������(����:HWND);
var �����:integer;
begin
with resDlg,dItems^[0]^,iRect do
  �����:=WS_CHILD | WS_VISIBLE | WS_THICKFRAME | WS_CAPTION;
  iWnd:=CreateWindowEx(0,������������,iText,�����,x,y,
    dx+GetSystemMetrics(SM_CXFRAME)*2,
    dy+GetSystemMetrics(SM_CYFRAME)*2+GetSystemMetrics(SM_CYCAPTION),
    ����,0,hINSTANCE,nil);
  SetWindowText(iWnd,iText);
end
end ��������������;

//---------- ��������� ���������� -------------

procedure ��������������(����:integer);
var ���,���2:string[maxText]; X,Y,dX,dY:integer;
begin
with resDlg,dItems^[����]^,iRect do
  lstrcpy(���,_�����_[envER]); lstrcat(���,iText); SendMessage(resStatus,SB_SETTEXT,ord(dsTextE),cardinal(addr(���)));
  lstrcpy(���,_�����_[envER]); lstrcat(���,iClass); SendMessage(resStatus,SB_SETTEXT,ord(dsClassE),cardinal(addr(���)));
  lstrcpy(���,_��_[envER]); lstrcat(���,iId); SendMessage(resStatus,SB_SETTEXT,ord(dsIdE),cardinal(addr(���)));
  X:=���XY���(x,false);
  Y:=���XY���(y,true);
  dX:=���XY���(dx,false);
  dY:=���XY���(dy,true);
  wvsprintf(���,"x,y:%li,",addr(X));
  wvsprintf(���2,"%li",addr(Y));
  lstrcat(���,���2);
  SendMessage(resStatus,SB_SETTEXT,ord(dsXY),cardinal(addr(���)));
  wvsprintf(���,"dx,dy:%li,",addr(dX));
  wvsprintf(���2,"%li",addr(dY));
  lstrcat(���,���2);
  SendMessage(resStatus,SB_SETTEXT,ord(dsDXDY),cardinal(addr(���)));
end
end ��������������;

//--------------- ���������/����� ����� ----------------

procedure �����������������(�������:integer; ����:boolean);
var �����:integer;
begin
with resDlg do
  if (�������>0)and(�������<=dTop) then
    if dItems^[�������]^.iBlock<>���� then
      if ����
        then �����:=WS_CHILD | WS_VISIBLE | WS_THICKFRAME
        else �����:=WS_CHILD | WS_VISIBLE | WS_BORDER
      end;
      SetWindowLong(dItems^[�������]^.iWnd,GWL_STYLE,�����);
      RedrawWindow(dItems^[�������]^.iWnd,nil,0,RDW_FRAME | RDW_ERASE | RDW_INVALIDATE | RDW_UPDATENOW | RDW_ERASENOW);
      dItems^[�������]^.iBlock:=����
    end
  end
end
end �����������������;

//--------------- ���������� ��������� ��������� � ���� ----------------

procedure ���������������������������();
var
  ���:integer;
  ���X,���Y,���X,���Y:integer;
begin
with resDlg do
//���������� �����
  if ����������X<���������X then
    ���X:=����������X;
    ���X:=���������X;
  else
    ���X:=���������X;
    ���X:=����������X;
  end;
  if ����������Y<���������Y then
    ���Y:=����������Y;
    ���Y:=���������Y;
  else
    ���Y:=���������Y;
    ���Y:=����������Y;
  end;
//�������� ���������
  for ���:=1 to dTop do
  with dItems^[���]^,iRect do
      �����������������(���,(���X<=x)and(���X>=x+dx-1)and(���Y<=y)and(���Y>=y+dy-1));
  end end;
end
end ���������������������������;

//--------------- ����� ������ ----------------

procedure �����������(����:HWND);
var ���,���:integer;
begin
with resDlg do
//����� ������ ��������
  ���:=-1;
  for ���:=0 to dTop do
    if ����=dItems^[���]^.iWnd then
      ���:=���;
  end end;
  if ���>-1 then
//����� ���� ������ ���������
    for ���:=0 to dTop do
      �����������������(���,false);
    end;
//��������� ������
    �����������������(���,true);
    resDlgItem:=���;
    ��������������(resDlgItem);
  end
end
end �����������;

//--------------- ����������� ���� ----------------

procedure ��������������(����:HWND; ����,������,������:integer; ������:boolean);
var ���,���2,���3:RECT; ���,���:integer;
begin
  ���:=-1;
  for ���:=0 to resDlg.dTop do
    if ����=resDlg.dItems^[���]^.iWnd then
      ���:=���;
  end end;
  if ���>-1 then
  with resDlg,dItems^[���]^.iRect do
    case ���� of
      WM_SIZE:
        if ������
          then GetClientRect(����,���)
          else GetWindowRect(����,���);
        end;
        dx:=���.right-���.left;
        dy:=���.bottom-���.top;|
      WM_MOVE:
        GetWindowRect(����,���);
        GetClientRect(����,���2);
        x:=loword(������)-(���.right-���.left-���2.right) div 2;
        y:=hiword(������)-(���.bottom-���.top-���2.bottom) div 2;|
    end;
    ��������������(resDlgItem);
  end end
end ��������������;

//------- ������� ������� �������� -----------

procedure �����������(����:HWND; ����,������,������:integer):integer;
var ���:string[maxText]; ��:HDC; ������:PAINTSTRUCT; ���:RECT; ���:integer;
begin
  case ���� of
//  �������� � ��������
    WM_CREATE:|
    WM_DESTROY:|
//  �����������
    WM_PAINT:
      GetWindowText(����,���,maxText);
      ��:=BeginPaint(����,������);
      SetBkMode(��,TRANSPARENT);
      SetTextColor(��,0xC0C0C0);
      TextOut(��,0,0,���,lstrlen(���));
      EndPaint(����,������);|
//  �������
    WM_SIZE:��������������(����,����,������,������,false);|
    WM_MOVE:��������������(����,����,������,������,false);|
//  ����
    WM_NCHITTEST:
      ���:=integer(DefWindowProc(����,����,������,������));
      if ���=HTCLIENT
        then return HTCAPTION
        else return ���
      end;|
    WM_NCLBUTTONDOWN:
      �����������(����);
      return integer(DefWindowProc(����,����,������,������));|
    WM_NCLBUTTONDBLCLK:������������(resDlgWnd);|
    WM_KEYDOWN:SendMessage(GetParent(����),����,������,������);|
  else return integer(DefWindowProc(����,����,������,������))
  end;
  return 0
end �����������;

//------- �������� ����� ����� -----------

procedure ���������������(��:HDC; ����:HWND);
var
  ���X,���Y,���X,���Y:integer;
  ����,������:HPEN;
begin
//���������� �����
  if ����������X<���������X then
    ���X:=����������X;
    ���X:=���������X;
  else
    ���X:=���������X;
    ���X:=����������X;
  end;
  if ����������Y<���������Y then
    ���Y:=����������Y;
    ���Y:=���������Y;
  else
    ���Y:=���������Y;
    ���Y:=����������Y;
  end;
//���������
  ����:=CreatePen(PS_DOT,1,0);
  ������:=SelectObject(��,����);
  MoveToEx(��,���X,���Y,nil);
  LineTo(��,���X,���Y);
  LineTo(��,���X,���Y);
  LineTo(��,���X,���Y);
  LineTo(��,���X,���Y);
  SelectObject(��,������);
  DeleteObject(����);
end ���������������;

//------- ������� ������� ������� -----------

procedure ����������(����:HWND; ����,������,������:integer):integer;
var ���:string[maxText]; ��:HDC; ������:PAINTSTRUCT;
begin
  case ���� of
//  �������� � ��������
    WM_CREATE:
      ����������X:=0;
      ����������Y:=0;|
    WM_DESTROY:|
//  �������
    WM_SIZE:��������������(����,����,������,������,true);|
    WM_MOVE:��������������(����,����,������,������,true);|
    WM_PAINT:
      if ����������X<>0 then
        ��:=BeginPaint(����,������);
        ���������������(��,����);
        EndPaint(����,������);
      end;
      return integer(DefWindowProc(����,����,������,������));|
//  ���� � ����������
    WM_LBUTTONDOWN:
      �����������(����);
      SetCapture(����);
      ����������X:=loword(������);
      ����������Y:=hiword(������);|
    WM_LBUTTONUP:
      if ����������X<>0 then
        ReleaseCapture();
        ����������X:=0;
        ����������Y:=0;
        InvalidateRect(����,nil,true);
        UpdateWindow(����);
      end;|
    WM_MOUSEMOVE:
      if ����������X<>0 then
        ���������X:=loword(������);
        ���������Y:=hiword(������);
        InvalidateRect(����,nil,true);
        UpdateWindow(����);
        ���������������������������();
      end;|
    WM_LBUTTONDBLCLK:|
    WM_KEYDOWN:SendMessage(GetParent(����),����,������,������);|
    else return integer(DefWindowProc(����,����,������,������))
  end;
  return 0
end ����������;

//===============================================
//             ��������� ������
//===============================================

//--------- �������� ����� ������� ------------

procedure ���������������(��:integer);
var ��,���,���:integer; ���:string[maxText];
begin
with resDlg do
  if dTop=maxItem
    then mbS(_�������_�����_���������_�_�������[envER])
    else inc(dTop)
  end;
  dItems^[dTop]:=memAlloc(sizeof(recItem));
  with dItems^[dTop]^ do
//����������� ������ � ����
    ��:=�� div 100;
    ���:=�� mod 100;
    if (��<=resTopClass)and(���<=resClasses^[��].claTop) then
    with resClasses^[��] do
//���������� ���������� ��������
      �������������(iClass,claName);
      �������������(iText,claIniText);
      �������������(iId,"-1");
      with iRect do
        x:=resDlgIniX;
        y:=resDlgIniY;
        dx:=������XY(claIniDX,false);
        dy:=������XY(claIniDY,true);
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      ���:=2;
      �����������(���,claList[���],���);
      while lstrcmp(���,"")<>0 do
        �������������(iStyles,iTop,���);
        inc(���);
        �����������(���,claList[���],���);
      end;
      iWnd:=0;
      ���������������(dTop);
      �����������(iWnd);
    end end;
  end;
end
end ���������������;

//-------------- �������� ������ ---------------------

procedure ������������();
var ����,���,i:integer; ��:recID; ���:boolean; S:recStream; ������:pstr;
begin
  if resStyles=nil then
    resStyles:=memAlloc(sizeof(arrListStyles));
    resTopStyles:=0;
    envInfBegin(_��������_������_������_��_[envER],resWIN32);
    ����:=_lopen(resWIN32,OF_READ);
    if ����>0 then
    //������� ���������
      _lread(����,addr(���),4);//Entry
      _lread(����,addr(���),4);//���
      _lread(����,addr(���),4);
      _llseek(����,���,FILE_CURRENT);
      _lread(����,addr(���),4);//������
      _lread(����,addr(���),4);
      _llseek(����,���,FILE_CURRENT);
      _lread(����,addr(���),4);//������
      for i:=1 to ��� do
        idReadS(����,������);
        memFree(������);
      end;
    //������ ���������������
      while (idReadID(S,��,����)) do
      with �� do
        if idClass=idcINT then
        //����� ��������
          ���:=(lstrpos("WS_",idName)=0)or(lstrpos("DS_",idName)=0);
          for ���:=1 to resTopClass do
          if not ��� then
            if lstrpos(resClasses^[���].claStyle,idName)=0 then
              ���:=true
            end
          end end;
        //������ � ������
          if ��� and(resTopStyles<maxListStyles) then
            inc(resTopStyles);
            resStyles^[resTopStyles]:=memAlloc(lstrlen(idName)+1);
            lstrcpy(resStyles^[resTopStyles],idName);
          end
        end;
      //������������ ������
        memFree(idName);
        case idClass of
          idcSTR:memFree(idStr);|
          idtREC:memFree(idRecList);|
          idtSCAL:memFree(idScalList);|
          idPROC:memFree(idProcList); memFree(idProcDLL);|
        end;
      end end;
      _lclose(����);
    end;
    envInfEnd();
  end
end ������������;

//-------------- ������ ������ ---------------------

const
  ���������=101;
  ���������=102;
  ���������=103;
  ����X=104;
  ����DX=105;
  ����Y=106;
  ����DY=107;
  ���������=108;
  ������������=109;
  �����������=110;
  �������������=111;
  ���������������=112;
  ����������=113;
  ������=120;
  ����������=121;

const DLG_STYLE=stringER{"DLG_STYLE_R","DLG_STYLE_E"};
dialog DLG_STYLE_R 22,14,268,176,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "��������� �������� �������"
begin
  control "����� ��������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,2,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,2,194,10
  control "����� ��������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,14,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,14,90,10
  control "�������������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,26,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,26,90,10
  control "�������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,178,16,72,10
  control "X:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,30,14,10
  control "",����X,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,30,26,10
  control "DX:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,30,14,10
  control "",����DX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,30,26,10
  control "Y:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,40,14,10
  control "",����Y,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,40,26,10
  control "DY:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,40,14,10
  control "",����DY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,40,26,10
  control "����� ��������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,66,56,100,10
  control "",���������,"LISTBOX",WS_CHILD | WS_BORDER | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL,2,80,100,74
  control "��������",������������,"Button",0 | WS_CHILD | WS_VISIBLE,162,68,46,10
  control "�������",�����������,"Button",0 | WS_CHILD | WS_VISIBLE,2,68,46,10
  control "�������",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,80,54,10
  control "",�������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,80,100,120
  control "����� ������",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,98,54,10
  control "",���������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,98,100,120
  control "������",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,116,54,10
  control "",����������,"EDIT",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,162,116,100,12
  control "��",������,"Button",0 | WS_CHILD | WS_VISIBLE,82,162,46,10
  control "������",����������,"Button",0 | WS_CHILD | WS_VISIBLE,136,162,46,10
end;
dialog DLG_STYLE_E 22,14,268,176,
  DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
  "Item options"
begin
  control "Item text:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,2,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,2,194,10
  control "Item class:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,14,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,14,90,10
  control "Identifier:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,4,26,62,10
  control "",���������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,68,26,90,10
  control "Sizes:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,178,16,72,10
  control "X:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,30,14,10
  control "",����X,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,30,26,10
  control "DX:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,30,14,10
  control "",����DX,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,30,26,10
  control "Y:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,172,40,14,10
  control "",����Y,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,188,40,26,10
  control "DY:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_RIGHT,218,40,14,10
  control "",����DY,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,234,40,26,10
  control "Item styles:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,66,56,100,10
  control "",���������,"LISTBOX",WS_CHILD | WS_BORDER | WS_VISIBLE | LBS_NOTIFY | WS_VSCROLL,2,80,100,74
  control "Add",������������,"Button",0 | WS_CHILD | WS_VISIBLE,162,68,46,10
  control "Delete",�����������,"Button",0 | WS_CHILD | WS_VISIBLE,2,68,46,10
  control "Window",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,80,54,10
  control "",�������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,80,100,120
  control "Class styles",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,98,54,10
  control "",���������������,"COMBOBOX",CBS_DROPDOWN | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,162,98,100,120
  control "Other",-1,"Static",2 | WS_CHILD | WS_VISIBLE,106,116,54,10
  control "",����������,"EDIT",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_LEFT | ES_AUTOHSCROLL,162,116,100,12
  control "Ok",������,"Button",0 | WS_CHILD | WS_VISIBLE,82,162,46,10
  control "Cancel",����������,"Button",0 | WS_CHILD | WS_VISIBLE,136,162,46,10
end;

//------- ���������� ������� ���������� �������� -----------

procedure ������������(����:HWND; ����,������,������:integer):boolean;
var ���:integer; ���:string[maxText];
begin
  case ���� of
    WM_INITDIALOG:with resDlg.dItems^[resDlgItem]^ do //������������� �������
      SetDlgItemText(����,���������,iText);
      SetDlgItemText(����,���������,iClass);
      SetDlgItemText(����,���������,iId);
      with iRect do
        SetDlgItemInt(����,����X,���XY���(x,false),true);
        SetDlgItemInt(����,����DX,���XY���(dx,false),true);
        SetDlgItemInt(����,����Y,���XY���(y,true),true);
        SetDlgItemInt(����,����DY,���XY���(dy,true),true);
      end;
      for ���:=1 to iTop do
        SendDlgItemMessage(����,���������,LB_ADDSTRING,0,integer(iStyles^[���]));
      end;
    //�������� ������
      ������������();
      if resDlgItem=0 then lstrcpy(���,"DS_")
      else
        ���[0]:=char(0);
        for ���:=1 to resTopClass do
        if lstrcmp(resClasses^[���].claName,iClass)=0 then
          lstrcpy(���,resClasses^[���].claStyle);
        end end
      end;
      for ���:=1 to resTopStyles do
        if lstrpos("WS_",resStyles^[���])=0 then
          SendDlgItemMessage(����,�������������,CB_ADDSTRING,0,integer(resStyles^[���]));
        elsif lstrpos(���,resStyles^[���])=0 then
          SendDlgItemMessage(����,���������������,CB_ADDSTRING,0,integer(resStyles^[���]));
        end 
      end;
      SendDlgItemMessage(����,�������������,CB_SETCURSEL,0,0);
      SendDlgItemMessage(����,���������������,CB_SETCURSEL,0,0);
      SetFocus(GetDlgItem(����,���������));
    end;|
    WM_COMMAND:case loword(������) of
      ������������:
        GetDlgItemText(����,resDlgFocus,���,maxText);
        if ���[0]=char(0) then mbS(_������_���������_������_�����[envER])
        elsif SendDlgItemMessage(����,���������,LB_FINDSTRING,0,integer(addr(���)))>=0 then mbS(_������_���������_���������_�����[envER])
        else SendDlgItemMessage(����,���������,LB_ADDSTRING,0,integer(addr(���)))
        end;|
      �����������:
        ���:=SendDlgItemMessage(����,���������,LB_GETCURSEL,0,0);
        if ���>=0 then
          SendDlgItemMessage(����,���������,LB_DELETESTRING,���,0);
          if ���>0 then
            SendDlgItemMessage(����,���������,LB_SETCURSEL,���-1,0);
          end;
          SetFocus(GetDlgItem(����,���������));
        end;|
      IDOK,������:with resDlg.dItems^[resDlgItem]^ do
        memFree(iText); GetDlgItemText(����,���������,���,maxText); �������������(iText,���);
        memFree(iClass); GetDlgItemText(����,���������,���,maxText); �������������(iClass,���);
        memFree(iId); GetDlgItemText(����,���������,���,maxText); �������������(iId,���);
        with iRect do
          x:=������XY(GetDlgItemInt(����,����X,nil,true),false);
          y:=������XY(GetDlgItemInt(����,����Y,nil,true),true);
          dx:=������XY(GetDlgItemInt(����,����DX,nil,true),false);
          dy:=������XY(GetDlgItemInt(����,����DY,nil,true),true);
        end;
        for ���:=1 to iTop do
          memFree(iStyles^[���]);
        end;
        iTop:=SendDlgItemMessage(����,���������,LB_GETCOUNT,0,0);
        for ���:=1 to iTop do
          iStyles^[���]:=memAlloc(SendDlgItemMessage(����,���������,LB_GETTEXTLEN,���-1,0)+1);
          SendDlgItemMessage(����,���������,LB_GETTEXT,���-1,integer(iStyles^[���]));
        end;
        EndDialog(����,1);
      end;|
      IDCANCEL,����������:EndDialog(����,0);|
      �������������,���������������,����������:case hiword(������) of
        CBN_SETFOCUS,EN_SETFOCUS:resDlgFocus:=loword(������);|
      end;|
    end;|
  else return false
  end;
  return true
end ������������;

//-------- ��������� ������ �������� -----------

procedure ������������;
begin
  if boolean(DialogBoxParam(hINSTANCE,DLG_STYLE[envER],���,addr(������������),0)) then
  with resDlg.dItems^[resDlgItem]^,iRect do
    if resDlgItem=0 then
      MoveWindow(iWnd,x,y,
        dx+GetSystemMetrics(SM_CXFRAME)*2,
        dy+GetSystemMetrics(SM_CYFRAME)*2+GetSystemMetrics(SM_CYCAPTION),true);
    else MoveWindow(iWnd,x,y,dx,dy,true)
    end;
    ��������������(resDlgItem);
    if (iText<>nil)and(iText[0]<>char(0))
      then SetWindowText(iWnd,iText)
      else SetWindowText(iWnd,iClass)
    end;
    InvalidateRect(iWnd,nil,true);
    UpdateWindow(iWnd);
  end end
end ������������;

//===============================================
//             ��������� ������ ������� 
//===============================================

//------------- ����� ������ ------------------

const DLG_FONT=stringER{"DLG_FONT_R","DLG_FONT_E"};
dialog DLG_FONT_R 46,34,184,114,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "����� ������"
begin
  control "�����:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,6,4,32,8
  control "",101,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,4,14,96,78
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,102,4,28,8
  control "",102,"COMBOBOX",CBS_SIMPLE | WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP,108,14,24,78
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,22,32,8
  control "",103,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,22,6,6
  control "������:",-1,"Static",2 | WS_CHILD | WS_VISIBLE,138,34,32,8
  control "",104,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_CHECKBOX,172,34,6,6
  control "����:",-1,"Static",1 | WS_CHILD | WS_VISIBLE,144,54,32,8
  control "��",120,"Button",0 | WS_CHILD | WS_VISIBLE,36,96,52,12
  control "������",121,"Button",0 | WS_CHILD | WS_VISIBLE,94,96,52,12
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

//------------- ����� ������ ------------------

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
            mbS(_��������_����[envER])
          end
        end;
        EndDialog(Wnd,1);|
      IDCANCEL,idFntCancel:EndDialog(Wnd,0);|
    end;|
  else return false
  end;
  return true;
end dlgFont;

//------------- ����� ������ ------------------

procedure ������������(����:HWND);
begin
  with resDlg.dItems^[0]^,carFont do
    RtlZeroMemory(addr(carFont),sizeof(recFont));
    lstrcpy(fFace,iFont);
    fSize:=iSize;
  end;
  if boolean(DialogBoxParam(hINSTANCE,DLG_FONT[envER],����,addr(dlgFont),0)) then
  with resDlg.dItems^[0]^,carFont do
    iFont:=memAlloc(lstrlen(fFace)+1);
    if lstrlen(fFace)=0
      then iFont:=nil
      else lstrcpy(iFont,fFace)
    end;
    iSize:=fSize;
  end end
end ������������;

//------------- ����� ������ ��������� ------------------

procedure envCorrFont(f:classFrag);
begin
  carFont:=stFont[f];
  if boolean(DialogBoxParam(hINSTANCE,DLG_FONT[envER],GetFocus(),addr(dlgFont),0)) then
    stFont[f]:=carFont;
  end
end envCorrFont;

//===============================================
//             ������� ������������
//===============================================

//------- ������� ������ -------------

bitmap bmpToolDlg="tooldlg.bmp";

procedure ����������������(����:HWND);
var
  ���:integer; �������:classDlgComm; bmp:HBITMAP; ���:RECT;
  ������:array[1..maxButt]of TBBUTTON;
begin
  InitCommonControls();
  bmp:=LoadBitmap(hINSTANCE,"bmpToolDlg");
  ���:=0;
  for �������:=cdNULL to cdCancel do
    if (setDlgCommand[envER][�������].numTool>0)and(���<maxButt) then
      inc(���);
      RtlZeroMemory(addr(������[���]),sizeof(TBBUTTON));
      with ������[���] do
        iBitmap:=setDlgCommand[envER][�������].numTool-1;
        idCommand:=idDlgBase+ord(�������);
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_BUTTON;
      end;
    end;
    if (���<maxButt)and((�������=cdEditDel)or(�������=cdAlignDown)or(�������=cdAlignSizeY)) then
      inc(���);
      RtlZeroMemory(addr(������[���]),sizeof(TBBUTTON));
      with ������[���] do
        fsState:=TBSTATE_ENABLED;
        fsStyle:=TBSTYLE_SEP;
      end
    end
  end;
  wndToolDlg:=CreateToolbarEx(
    ����,WS_CHILD | WS_VISIBLE | TBSTYLE_TOOLTIPS | CCS_ADJUSTABLE,
    0,���,0,bmp,addr(������),���,20,20,20,20,sizeof(TBBUTTON));
  with ��� do
    GetWindowRect(wndToolDlg,���);
    inc(bottom,10);
    MoveWindow(wndToolDlg,left,top,right-left+1,bottom-top+1,true);
  end;
end ����������������;

//------- ��������� ���������������� ��������� -------------

procedure ��������������(������:cardinal);
var ������:pNMHDR; �����������:pTOOLTIPTEXT;
begin
  ������:=address(������);
  �����������:=address(������);
  with ������^,�����������^ do
    case code of
      TTN_NEEDTEXT:lpszText:=setDlgCommand[envER][classDlgComm(idFrom-idDlgBase)].name;| //����� ������
    end
  end
end ��������������;

//===============================================
//             ������ � �������
//===============================================

//----------- ������ ������ ������� ------------

procedure ���������(�����:pstr; var ���:integer);
begin
  if ������������� then
    if �����[���]<>'\0' then
      inc(���)
    end;
    ����������:=��������
  else
    while (�����[���]=' ')or(�����[���]='\10')or(�����[���]='\13') do
      inc(���);
    end;
    case �����[���] of
      '\0':����������:=��������;|
      'A'..'Z','a'..'z','�'..'�','�'..'�','_'://�������������
        ����������:=���������;
        �������������[0]:='\0';
        lstrcatc(�������������,�����[���]); inc(���);
        while
          (ord(�����[���])>=ord('A'))and(ord(�����[���])<=ord('Z'))or
          (ord(�����[���])>=ord('a'))and(ord(�����[���])<=ord('z'))or
          (ord(�����[���])>=ord('�'))and(ord(�����[���])<=ord('�'))or
          (ord(�����[���])>=ord('�'))and(ord(�����[���])<=ord('�'))or
          (ord(�����[���])>=ord('0'))and(ord(�����[���])<=ord('9'))or
          (�����[���]='_') do
          lstrcatc(�������������,�����[���]);  inc(���);
        end;|
      '"'://������
        ����������:=����������;
        �������������[0]:='\0';
        inc(���);
        while (�����[���]<>'"')and(�����[���]<>'\0') do
          lstrcatc(�������������,�����[���]); inc(���);
        end;
        if �����[���]='"'
          then inc(���);
          else �������������:=true;
        end;|
      '0'..'9'://�����
        ����������:=���������;
        ������������:=ord(�����[���])-ord('0');
        �������������[0]:='\0';
        lstrcatc(�������������,�����[���]); inc(���);
        while (ord(�����[���])>=ord('0'))and(ord(�����[���])<=ord('9')) do
          ������������:=������������*10+ord(�����[���])-ord('0');
          lstrcatc(�������������,�����[���]); inc(���);
        end;|
    else //������
      ����������:=����������;
      �������������:=�����[���];
      inc(���);
    end
  end
end ���������;

//----------- ���� �� ������ ------------

procedure ���������������(�����:pstr; �������������:boolean):boolean;
var ���:integer; ���:string[maxText]; ��������:boolean; ����:HWND;
begin
  with resDlg do
    if ������������� then
      dTop:=-1;
    end;
  //����� �����
    for ���:=1 to dTop do
      �����������������(���,false);
    end;
    ���:=0;
    �������������:=false;
    ���������(�����,���);
    while (����������=���������)and(
      (lstrcmp(�������������,nameREZ[carSet][rCONTROL])=0)or
      (lstrcmp(�������������,nameREZ[carSet][rDIALOG])=0)) do
    //����� �������
      if dTop=maxItem
        then �������������:=true;
        else inc(dTop)
      end;
      if dTop=0 then
        ����:=dItems^[dTop]^.iWnd;
      end;
      dItems^[dTop]:=memAlloc(sizeof(recItem));
      with dItems^[dTop]^ do
      //�����
        ���������(�����,���);
        �������������:=not (����������=����������);
        iText:=memAlloc(lstrlen(�������������)+1);
        lstrcpy(iText,�������������);
      //�������������
        ���������(�����,���);
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        �������������:=not ((����������=���������)or(����������=���������)or
          (����������=����������)and(�������������='-'));
        ��������:=(����������=����������)and(�������������='-');
        if �������� then
          ���������(�����,���);
          �������������:=not ((����������=���������)or(����������=���������));
        end;
        iId:=memAlloc(lstrlen(�������������)+2);
        if �������� then
          lstrcpy(iId,"-");
        end;
        lstrcpy(iId,�������������);
      //�����
        ���������(�����,���);
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        �������������:=not (����������=����������);
        iClass:=memAlloc(lstrlen(�������������)+1);
        lstrcpy(iClass,�������������);
      //�����
        ���������(�����,���);
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        iTop:=0;
        iStyles:=memAlloc(sizeof(arrStyles));
        while (����������=���������)or(����������=���������) do
          if iTop=maxStyle
            then �������������:=true;
            else inc(iTop)
          end;
          iStyles^[iTop]:=memAlloc(lstrlen(�������������)+1);
          lstrcpy(iStyles^[iTop],�������������);
          ���������(�����,���);
          if (����������=����������)and(�������������='|') then
            ���������(�����,���);
          end
        end;
      //�������
        �������������:=not ((����������=����������)and(�������������=','));
        ���������(�����,���);
        with iRect do
        //x
          �������������:=not (����������=���������);
          x:=������������;
          ���������(�����,���);
          �������������:=not ((����������=����������)and(�������������=','));
          ���������(�����,���);
        //y
          �������������:=not (����������=���������);
          y:=������������;
          ���������(�����,���);
          �������������:=not ((����������=����������)and(�������������=','));
          ���������(�����,���);
        //cx
          �������������:=not (����������=���������);
          dx:=������������;
          ���������(�����,���);
          �������������:=not ((����������=����������)and(�������������=','));
          ���������(�����,���);
        //cy
          �������������:=not (����������=���������);
          dy:=������������;
          ���������(�����,���);
        end;
        if dTop=0
          then iWnd:=����;
          else ���������������(dTop);
        end;
      end
    end
  end;
//  if ������������� then lstrdel(�����,0,���); mbI(���,�����) end;
  return not �������������
end ���������������;

//----------- ���� � ����� ------------

procedure �������������(�����:pstr; �������������:boolean);
var �������,���:integer; ���:string[maxText];
begin
  with resDlg do
    �����[0]:='\0';
    for �������:=0 to dTop do
    with dItems^[�������]^,iRect do
    if iBlock and(�������>0) or ������������� then
      lstrcat(�����,"\13\10  ");
      if �������=0
        then lstrcat(�����,nameREZ[carSet][rDIALOG])
        else lstrcat(�����,nameREZ[carSet][rCONTROL])
      end;
      lstrcat(�����,' "'); lstrcat(�����,iText); lstrcat(�����,'",');
      lstrcat(�����,iId);
      lstrcatc(�����,','); lstrcatc(�����,'"'); lstrcat(�����,iClass); lstrcatc(�����,'"');  lstrcatc(�����,',');
      if iTop=0 then lstrcatc(�����,'0')
      else
      for ���:=1 to iTop do
        lstrcat(�����,iStyles^[���]);
        if ���<iTop then
          lstrcat(�����," | ");
        end
      end end;
      lstrcatc(�����,',');
      wvsprintf(���,'%li,',addr(x)); lstrcat(�����,���);
      wvsprintf(���,'%li,',addr(y)); lstrcat(�����,���);
      wvsprintf(���,'%li,',addr(dx)); lstrcat(�����,���);
      wvsprintf(���,'%li',addr(dy)); lstrcat(�����,���);
    end end end
  end
end �������������;

//----------- ���������� � clipboard ------------

procedure �����������������();
var �����,�����:pstr;
begin
  �����:=memAlloc(maxResMem);
  �������������(�����,false);
  �����:=memAlloc(lstrlen(�����)+1);
  lstrcpy(�����,�����);
  memFree(�����);
  if OpenClipboard(editWnd) then
    EmptyClipboard();
    SetClipboardData(CF_TEXT,HANDLE(�����));
    CloseClipboard()
  else
    memFree(�����);
    mbS(_������_Clipboard_�����_������_�����������[envER])
  end
end �����������������;

//----------- �������� �� clipboard ------------

procedure ���������������();
var �����,�����:pstr;
begin
  if not OpenClipboard(editWnd) then
    mbS(_������_Clipboard_�����_������_�����������[envER])
  else
    if (IsClipboardFormatAvailable(CF_TEXT)=false)and(IsClipboardFormatAvailable(CF_OEMTEXT)=false) then
      mbI(GetPriorityClipboardFormat(nil,0),_������_��������_������_������_�_Clipboard[envER])
    else
      �����:=pstr(GetClipboardData(CF_TEXT));
      if �����<>nil then
        if not ���������������(�����,false) then
          mbS(_��������_������_�_Clipboard[envER])
        end
      end
    end;
    CloseClipboard()
  end
end ���������������;

//----------- ������� ���� ------------

procedure ��������������(�������������:boolean);
var �������,���:integer;
begin
  with resDlg do
    for �������:=dTop downto 0 do
    with dItems^[�������]^ do
    if iBlock and(�������>0) or ������������� then
      if �������>0 then
        DestroyWindow(iWnd);
      end;
      memFree(iText);
      memFree(iId);
      memFree(iClass);
      for ���:=1 to iTop do
        memFree(iStyles^[���]);
      end;
      memFree(iStyles);
      memFree(dItems^[�������]);
      for ���:=������� to dTop-1 do
        dItems^[���]:=dItems^[���+1];
      end;
      dec(dTop);
    end end end;
    if (resDlgItem>dTop)and(dTop>0) then
      �����������(dItems^[dTop]^.iWnd);
    end;
  end
end ��������������;

//----------- �������� ��� ------------

procedure ������������������();
var ���:integer;
begin
  with resDlg do
    for ���:=1 to dTop do
      �����������������(���,true);
    end
  end
end ������������������;

//----------- ������������ ------------

procedure ����������������(�������:classDlgComm);
var �������,������:integer;
begin
  with resDlg do
  //����������� ������ (�������)
    ������:=0;
    for �������:=1 to dTop do
    with dItems^[�������]^,iRect do
    if iBlock then
      case ������� of
        cdAlignLeft:if (������=0)or(������>=x) then ������:=x end;|
        cdAlignRight:if (������=0)or(������<=x+dx) then ������:=x+dx end;|
        cdAlignUp:if (������=0)or(������>=y) then ������:=y end;|
        cdAlignDown:if (������=0)or(������<=y+dy) then ������:=y+dy end;|
        cdAlignSizeX:if (������=0)or(������<=dx) then ������:=dx end;|
        cdAlignSizeY:if (������=0)or(������<=dy) then ������:=dy end;|
      end
    end end end;
  //��������� ������� (�������)
    for �������:=1 to dTop do
    with dItems^[�������]^,iRect do
    if iBlock then
      case ������� of
        cdAlignLeft:x:=������;|
        cdAlignRight:x:=������-dx;|
        cdAlignUp:y:=������;|
        cdAlignDown:y:=������-dy;|
        cdAlignSizeX:dx:=������;|
        cdAlignSizeY:dy:=������;|
      end;
      MoveWindow(iWnd,x,y,dx,dy,true);
    end end end;
  end
end ����������������;

//----- ��������� ������ ��� ������ -------

procedure �����������������();
var �����:pstr; ���:integer;
begin
  �����:=memAlloc(maxResMem);
  �������������(�����,true);
  if ������������<maxResUndo then inc(������������);
  else
    for ���:=1 to ������������-1 do
      ��������[���]:=��������[���+1];
    end
  end;
  ��������[������������]:=memAlloc(lstrlen(�����)+1);
  lstrcpy(��������[������������],�����);
  memFree(�����);
end �����������������;

//----- ��������� ����� -------

procedure �����������������();
begin
  if ������������>0 then
    ��������������(true);
    if not ���������������(��������[������������],true) then
      mbS(_���������_������_��������_������_�_������_������_[envER]);
      mbS(��������[������������]);
    end;
    with resDlg,dItems^[0]^,iRect do
//      MoveWindow(iWnd,x,y,dx,dy,true);
      if (resDlgItem<0)or(resDlgItem>dTop) then
        resDlgItem:=0
      end;
    end;
    memFree(��������[������������]);
    dec(������������);
  end
end �����������������;

//----- ���������� ������ ������ -------

procedure ������������������();
var ���:integer;
begin
  for ���:=1 to ������������ do
    memFree(��������[���]);
  end
end ������������������;

//===============================================
//      ���������� ������� ��������� ��������
//===============================================

//----- ������ ��������� ������ -------

const
  ���������=101;
  ���������=102;
  ����������=103;
  ����������=104;
  �������=120;
  �����������=121;

const DLG_GEN=stringER{"DLG_GEN_R","DLG_GEN_E"};
dialog DLG_GEN_R 45,43,198,64,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "��������� ������ �������"
begin
  control "������� ������ ������� � ����� ���������",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,4,168,10
  control "������� ������ ������� � clipboard",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,14,168,10
  control "��������� ������ ���������� �������",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,26,168,10
  control "��������� ������ ������ �������",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,36,168,10
  control "��",�������,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,46,49,40,10
  control "������",�����������,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,96,49,40,10
end;
dialog DLG_GEN_E 45,43,198,64,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME,
  "Dialog text generation"
begin
  control "Insert dialog into the program",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,4,168,10
  control "Insert dialog into the  clipboard",���������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTORADIOBUTTON,28,14,168,10
  control "Dialog function text generation",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,26,168,10
  control "Dialog call text generation",����������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_AUTOCHECKBOX,12,36,168,10
  control "Ok",�������,"Button",WS_CHILD | WS_VISIBLE | BS_DEFPUSHBUTTON,46,49,40,10
  control "Cancel",�����������,"Button",WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,96,49,40,10
end;

//----- ���������� ������� ��������� ������ -------

procedure ����������������(����:HWND; ����,������,������:integer):boolean;
//������ - ��� ������ �������
var ���:integer; ���:string[maxText];
begin
  case ���� of
    WM_INITDIALOG:
      if boolean(������) then
        SendDlgItemMessage(����,���������,BM_SETCHECK,0,0);
        SendDlgItemMessage(����,���������,BM_SETCHECK,1,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,1,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,1,0);
      else
        SendDlgItemMessage(����,���������,BM_SETCHECK,1,0);
        SendDlgItemMessage(����,���������,BM_SETCHECK,0,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,0,0);
        SendDlgItemMessage(����,����������,BM_SETCHECK,0,0);
      end;|
    WM_COMMAND:case loword(������) of
      BN_CLICKED:case loword(������) of
        ���������:SendDlgItemMessage(����,���������,BM_SETCHECK,0,0);|
        ���������:SendDlgItemMessage(����,���������,BM_SETCHECK,1,0);|
      end;|
      IDOK,�������:
        ����������������:=SendDlgItemMessage(����,���������,BM_GETCHECK,0,0)=BST_CHECKED;
        ������������������:=SendDlgItemMessage(����,����������,BM_GETCHECK,0,0)=BST_CHECKED;
        �����������������:=SendDlgItemMessage(����,����������,BM_GETCHECK,0,0)=BST_CHECKED;
        EndDialog(����,1);|
      IDCANCEL,�����������:EndDialog(����,0);|
    end;|
  else return false
  end;
  return true
end ����������������;

//----- ����� ������� ��������� ������ -------

procedure ���������������(����:HWND; ��������������:boolean):boolean;
begin
  return boolean(DialogBoxParam(hINSTANCE,DLG_GEN[envER],����,addr(����������������),cardinal(��������������)));
end ���������������;

//----- �������� ������-������ ��������� -------

procedure �������������(����:HWND; �������:boolean);
var ����:array[classDlgStatus]of integer; ���:RECT; ����:classDlgStatus; ���,������:integer;
begin
  if ������� then
    resStatus:=CreateStatusWindow(
      WS_CHILD | WS_BORDER | WS_VISIBLE | SBARS_SIZEGRIP,
      nil,����,0);
  end;
  GetClientRect(����,���);
  if not ������� then
  with ��� do
    SendMessage(resStatus,WM_SIZE,right-left+1,bottom-top+1);
  end end;
  ���:=0;
  for ����:=dsTextE to resFinStatus do
    ������:=(���.right-���.left+1)*resStatusProc[����] div 100;
    ����[����]:=���+������;
    inc(���,������)
  end;
  ����[resFinStatus]:=-1;
  SendMessage(resStatus,SB_SETPARTS,ord(resFinStatus)+1,cardinal(addr(����)));
end �������������;

//----------- �������� ���� -------------------

procedure �����������():HMENU;
var ����,�������,�������2:HMENU; ���,���:integer; ���:string[maxText]; �������:classDlgComm;
begin
  ����:=CreateMenu();
//���� _�����[envER]
  �������:=CreatePopupMenu();
  for ���:=1 to resTopClass do
  with resClasses^[���] do
    �������2:=CreatePopupMenu();
    for ���:=1 to claTop do
      lstrcpy(���,claList[���]);
      lstrdel(���,lstrposc(',',���),999);
      AppendMenu(�������2,MF_STRING,idDlgBaseNew+���*100+���,���);
    end;
    AppendMenu(�������,MF_POPUP,�������2,resClasses^[���].claMenu);
  end end;
  AppendMenu(����,MF_POPUP,�������,setDlgCommand[envER][cdNew].name);
//���� _������[envER]
  �������:=CreatePopupMenu();
  for �������:=cdEditUndo to cdEditAll do
    if (�������=cdEditCut)or(�������=cdEditAll) then
      AppendMenu(�������,MF_SEPARATOR,0,nil);
    end;
    AppendMenu(�������,MF_STRING,idDlgBase+ord(�������),setDlgCommand[envER][�������].name);
  end;
  AppendMenu(����,MF_POPUP,�������,setDlgCommand[envER][cdEdit].name);
//���� _���������[envER]
  �������:=CreatePopupMenu();
  for �������:=cdAlignLeft to cdAlignSizeY do
    if �������=cdAlignSizeX then
      AppendMenu(�������,MF_SEPARATOR,0,nil);
    end;
    AppendMenu(�������,MF_STRING,idDlgBase+ord(�������),setDlgCommand[envER][�������].name);
  end;
  AppendMenu(����,MF_POPUP,�������,setDlgCommand[envER][cdAlign].name);
//������ ������
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdParam),setDlgCommand[envER][cdParam].name);
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdFont),setDlgCommand[envER][cdFont].name);
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdOk),setDlgCommand[envER][cdOk].name);
  AppendMenu(����,MF_STRING,idDlgBase+ord(cdCancel),setDlgCommand[envER][cdCancel].name);
  return ����;
end �����������;

//----- ������ ��������� �������� -----

const DLG_RES=stringER{"DLG_RES_R","DLG_RES_E"};
dialog DLG_RES_R 80,48,160,96,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "�������� ��������"
begin
end;
dialog DLG_RES_E 80,48,160,96,
  WS_POPUP | WS_CAPTION | WS_SYSMENU | DS_MODALFRAME | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  "Dialog editor"
begin
end;

//----- ���������� ������� ��������� �������� -----

procedure ��������������(����:HWND; ����,������,������:integer):boolean;
var ���:integer; ���:string[maxText];
begin
  case ���� of
    WM_INITDIALOG:
      resDlgWnd:=����;
      ���:=GetSystemMetrics(SM_CYCAPTION);
      MoveWindow(����,���,���,GetSystemMetrics(SM_CXSCREEN)-���*2,
        GetSystemMetrics(SM_CYSCREEN)-GetSystemMetrics(SM_CYCAPTION)*3 div 2-���*2,true);
      SetMenu(����,�����������());
      �������������(����,true);
      resDlgItem:=0;
      ��������������(����);
      for ���:=1 to resDlg.dTop do
        ���������������(���);
      end;
      ������������:=0;
      �����������������();
      ����������������(����);
      ��������������(resDlgItem);|
    WM_SIZE:�������������(����,false);|
    WM_NOTIFY:��������������(������);|
    WM_COMMAND:case loword(������) of
      idDlgBaseNew..idDlgBaseNew+5000:�����������������(); ���������������(loword(������)-idDlgBaseNew);|
      idDlgBase+cdEditUndo:�����������������();|
      idDlgBase+cdEditCut:�����������������(); �����������������(); ��������������(false);|
      idDlgBase+cdEditCopy:�����������������(); �����������������();|
      idDlgBase+cdEditPaste:�����������������(); ���������������();|
      idDlgBase+cdEditDel:�����������������(); ��������������(false);|
      idDlgBase+cdEditAll:������������������();|
      idDlgBase+cdAlignLeft..idDlgBase+cdAlignSizeY:�����������������(); ����������������(classDlgComm(loword(������)-idDlgBase));|
      idDlgBase+cdParam:�����������������(); ������������(����);|
      idDlgBase+cdFont:������������(����);|
      idDlgBase+cdOk:
        if ���������������(����,�����������������) then
          ������������������();
          EndDialog(����,1);
        end;|
      IDCANCEL,idDlgBase+cdCancel:������������������(); EndDialog(����,0);|
    end;|
    WM_KEYDOWN:case loword(������) of
      VK_DELETE:SendMessage(����,WM_COMMAND,idDlgBase+ord(cdEditDel),0);|
//      VK_RETURN:SendMessage(����,WM_COMMAND,idDlgBase+ord(cdParam),0);|
//      VK_TAB:with resDlg do
//        if resDlgItem<dTop then �����������(dItems^[resDlgItem+1]^.iWnd);
//        elsif resDlgItem=dTop then �����������(dItems^[0]^.iWnd);
//        elsif dTop>0 then �����������(dItems^[1]^.iWnd);
//        end;
//      end;|
    end;|
  else return false
  end;
  return true
end ��������������;

//===============================================
//             ��������� �������
//===============================================

//-------------- ������ ������ ----------------

procedure ���������������();
var dlgx,dlgy:integer;
begin
  with resDlg do
    dMenu:=nil;
    dTop:=2;
    dItems:=memAlloc(sizeof(arrItem));
//������
    dItems^[0]:=memAlloc(sizeof(recItem));
    with dItems^[0]^ do
      �������������(iText,_������[envER]);
      �������������(iClass,nil);
      �������������(iId,"DLG");
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
      �������������(iStyles,iTop,"WS_POPUP");
      �������������(iStyles,iTop,"WS_CAPTION");
      �������������(iStyles,iTop,"WS_SYSMENU");
      �������������(iStyles,iTop,"DS_MODALFRAME");
    end;
//������� 1
    dItems^[1]:=memAlloc(sizeof(recItem));
    with dItems^[1]^ do
      �������������(iText,_��[envER]);
      �������������(iId,"IDOK");
      �������������(iClass,"Button");
      with iRect do
        x:=dlgx*20 div 100;
        y:=dlgy*90 div 100;
        dx:=dlgx*28 div 100;
        dy:=dlgy*10 div 100;
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      �������������(iStyles,iTop,"WS_CHILD");
      �������������(iStyles,iTop,"WS_VISIBLE");
      �������������(iStyles,iTop,"BS_DEFPUSHBUTTON");
    end;
//{������� 2}
    dItems^[2]:=memAlloc(sizeof(recItem));
    with dItems^[2]^ do
      �������������(iText,_������[envER]);
      �������������(iId,"IDCANCEL");
      �������������(iClass,"Button");
      with iRect do
        x:=dlgx*52 div 100;
        y:=dlgy*90 div 100;
        dx:=dlgx*28 div 100;
        dy:=dlgy*10 div 100;
      end;
      iTop:=0;
      iStyles:=memAlloc(sizeof(arrStyles));
      �������������(iStyles,iTop,"WS_CHILD");
      �������������(iStyles,iTop,"WS_VISIBLE");
      �������������(iStyles,iTop,"BS_PUSHBUTTON");
    end
  end;
end ���������������;

//------------ ��������� ������� --------------

procedure �������������(��������:boolean):pstr;
var i:integer; ���:pstr;
begin
  if �������� then
    ���������������();
  end;
  if boolean(DialogBoxParam(hINSTANCE,DLG_RES[envER],mainWnd,addr(��������������),0)) then
    ���:=memAlloc(maxBufClip);
    resDlgToTxt(���);
    return ���;
  else return nil
  end;  
end �������������;

//------- ����������� ������� ������� ---------

procedure �������������();
var �����:WNDCLASS;
begin
  �����.hInstance:=hINSTANCE;
  with ����� do
    style:=CS_HREDRAW | CS_VREDRAW;
    cbClsExtra:=0;
    cbWndExtra:=0;
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=GetStockObject(GRAY_BRUSH);
    lpszMenuName:=nil;
    lpfnWndProc:=addr(�����������);
    lpszClassName:=�������������;
  end;
  if RegisterClass(�����)=0 then
    mbS(_������_�����������_������_��������[envER]);
  end;
  with ����� do
    lpfnWndProc:=addr(����������);
    lpszClassName:=������������;
    hbrBackground:=CreateHatchBrush(HS_CROSS,0);
  end;
  if RegisterClass(�����)=0 then
    mbS(_������_�����������_������_�������[envER]);
  end;
end �������������;

//===============================================
//             ���������� ��������
//===============================================

//----------- ������������� ������ ------------

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

//--------------- �����-bmp (������) -------------------

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
      MessageBox(0,stErrText,_������[envER],MB_ICONSTOP);
    end;
    return stErr;
  end;
end resTxtToBmp;

//--------------- �����-������ ----------------

procedure resTxtToDlg(cart:integer; var ���Y,���Y:integer):boolean;
var S:recStream; bitMin:boolean; str:string[maxText];
begin
  with S,tbMod[cart],resDlg do
    with txts[txtn[cart]][cart] do
      ���Y:=txtTrackY+txtCarY;
    end;
    resOpen(S,cart);
//������������� �������
    dItems:=memAlloc(sizeof(arrItem));
    dTop:=0;
    dItems^[0]:=memAlloc(sizeof(recItem));
    dMenu:=nil;
//  ��������� �������
    lexAccept00(S,lexREZ,integer(rDIALOG));
    with dItems^[dTop]^ do
     �������������(iId,stLexStr);
     lexAccept00(S,lexNEW,0);
      with iRect do
        x:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        y:=������XY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        dx:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
        dy:=������XY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
      end;
//  �����
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
//  ���������
      if not okPARSE(S,pCol) then iText:=nil
      else
        lexAccept00(S,lexPARSE,integer(pCol));
        iText:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iText,stLexStr);
        lexAccept00(S,lexSTR,0);
      end;
//�����
      iClass:=nil;
      if okPARSE(S,pCol) then
        lexAccept00(S,lexPARSE,integer(pCol));
        if not okPARSE(S,pCol) then
          iClass:=memAlloc(lstrlen(stLexStr)+1);
          lstrcpy(iClass,stLexStr);
          lexAccept00(S,lexSTR,0);
        end
      end;
//����
    if not okPARSE(S,pCol) then iFont:=nil
    else
      lexAccept00(S,lexPARSE,integer(pCol));
      iFont:=memAlloc(lstrlen(addr(stLexStr))+1); lstrcpy(iFont,addr(stLexStr));
      lexAccept00(S,lexSTR,0);
      lexAccept00(S,lexPARSE,integer(pCol));
      iSize:=stLexInt; lexAccept00(S,lexINT,0);
    end
    end;
//��������
    if okREZ(S,rBEGIN) then
      lexAccept00(S,lexREZ,integer(rBEGIN));
      while okREZ(S,rCONTROL) do
      if dTop=maxItem then lexError(S,_�������_�����_���������_�_�������[envER],nil)
      else
        inc(dTop);
        dItems^[dTop]:=memAlloc(sizeof(recItem));
//  ������� �������
      with dItems^[dTop]^ do
        lexAccept00(S,lexREZ,integer(rCONTROL));
//  �����
        iText:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iText,stLexStr);
        lexAccept00(S,lexSTR,0);
        lexAccept00(S,lexPARSE,integer(pCol));
//  �������������
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
//  �����
        iClass:=memAlloc(lstrlen(stLexStr)+1);
        lstrcpy(iClass,stLexStr);
        lexAccept00(S,lexSTR,0);
        lexAccept00(S,lexPARSE,integer(pCol));
//  �����
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
//  �������
        with iRect do
          x:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          y:=������XY(stLexInt,true); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          dx:=������XY(stLexInt,false); lexAccept00(S,lexINT,0); lexAccept00(S,lexPARSE,integer(pCol));
          dy:=������XY(stLexInt,true); lexAccept00(S,lexINT,0);
        end
      end
      end end;
      lexAccept00(S,lexREZ,integer(rEND));
      ���Y:=stPosLex.y;
      lexAccept00(S,lexPARSE,integer(pSem));
    end;
    if stErr then
//      envSetError(cart,stErrPos.f,stErrPos.y);
//      envUpdate(editWnd);
      MessageBox(0,stErrText,_������[envER],MB_ICONSTOP);
    end;
    return stErr
  end;
end resTxtToDlg;

//--------------- ����� ���������� ������� (������) ----------------

procedure resDlgFunMODULA(txt:pstr);
var i:integer;
begin
with resDlg do
if ������������������ then
  lstrcat(txt,"\13\10");
//procedure ��������������(wnd:HWND; message,wparam,lparam:integer):boolean;
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
//end ��������������;
  lstrcat(txt,nameREZ[carSet][rEND]); lstrcat(txt," proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,";\13\10");
end;

//-----------------����� ������ �������
if ����������������� then
//DialogBoxParam(hINSTANCE,_����������[envER],0,addr(��������������),0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,addr(proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"),0);\13\10"); 
end;

end
end resDlgFunMODULA;

//--------------- ����� ���������� ������� (��) ----------------

procedure resDlgFunC(txt:pstr);
var i:integer;
begin
with resDlg do
if ������������������ then
  lstrcat(txt,"\13\10");
//boolean ��������������(HWND wnd,int message,int wparam,int lparam)
  lstrcat(txt,"bool proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"(HWND wnd,int message,int wparam,int lparam)\13\10");
//{ switch(message) {
  lstrcat(txt,"{\13\10");
  lstrcat(txt,"  "); lstrcat(txt,nameREZ[carSet][rSWITCH]); lstrcat(txt,"(message) {"); lstrcat(txt,"\13\10");
//case WM_INITDIALOG:break; case WM_COMMAND:switch(loword(wparam)) {
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," WM_INITDIALOG:"); lstrcat(txt,nameREZ[carSet][rBREAK]); lstrcat(txt,";\13\10");
  lstrcat(txt,"    "); lstrcat(txt,nameREZ[carSet][rCASE]); lstrcat(txt," WM_COMMAND:"); lstrcat(txt,nameREZ[carSet][rSWITCH]); lstrcat(txt,"("); lstrcat(txt,nameREZ[carSet][rLOWORD]); lstrcat(txt,"(wparam)) {"); lstrcat(txt,"\13\10");
//case IDOK:EndDialog(wnd,1); break; case IDCANCEL:EndDialog(����,0); break;
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

//-----------------����� ������ �������
if ����������������� then
//DialogBoxParam(hINSTANCE,_����������[envER],0,&��������������,0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,&proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,",0);\13\10"); 
end;

end
end resDlgFunC;

//--------------- ����� ���������� ������� (�������) ----------------

procedure resDlgFunPASCAL(txt:pstr);
var i:integer;
begin
with resDlg do
if ������������������ then
  lstrcat(txt,"\13\10");
//function ��������������(wnd:HWND; message,wparam,lparam:integer):boolean;
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

//-----------------����� ������ �������
if ����������������� then
//DialogBoxParam(hINSTANCE,_����������[envER],0,addr(��������������),0);
  lstrcat(txt,"\13\10");
  lstrcat(txt,"DialogBoxParam(hINSTANCE,");
  lstrcatc(txt,'"'); lstrcat(txt,dItems^[0]^.iId); lstrcatc(txt,'"');
  lstrcat(txt,",0,addr(proc"); lstrcat(txt,dItems^[0]^.iId); lstrcat(txt,"),0);\13\10"); 
end;

end
end resDlgFunPASCAL;

//--------------- ������-����� ----------------

procedure resDlgToTxt;
var s:string[maxText]; i,j,k:integer;
begin
with resDlg do
  txt[0]:=char(0);
//���������
  with dItems^[0]^,iRect do
    lstrcat(txt,nameREZ[carSet][rDIALOG]); lstrcatc(txt,' ');
    lstrcat(txt,iId); lstrcatc(txt,' ');
    k:=���XY���(x,false); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=���XY���(y,true); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=���XY���(dx,false); wvsprintf(s,"%li,",addr(k)); lstrcat(txt,s);
    k:=���XY���(dy,true); wvsprintf(s,"%li,\13\10  ",addr(k)); lstrcat(txt,s);
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
//��������
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
    k:=���XY���(x,false); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=���XY���(y,true); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=���XY���(dx,false); wvsprintf(s,'%li,',addr(k)); lstrcat(txt,s);
    k:=���XY���(dy,true); wvsprintf(s,'%li',addr(k)); lstrcat(txt,s);
  end end;
  lstrcat(txt,"\13\10");
  lstrcat(txt,nameREZ[carSet][rEND]);
  lstrcat(txt,";\13\10");

//-----------------����� ���������� ������� � ������ �������
  case traLANG of
    langMODULA:resDlgFunMODULA(txt);|
    langC:resDlgFunC(txt);|
    langPASCAL:resDlgFunPASCAL(txt);|
  end;

end
end resDlgToTxt;

//===============================================
//             ��������� ��������� ��������
//===============================================

//---------- ������� ���������� ������� -----------

procedure ���������������(�����:pClass; var ����:integer);
var ��,���:integer;
begin
  for ��:=1 to ���� do
  with �����^[��] do
    for ���:=1 to claTop do
      memFree(claList[���]);
    end;
    claTop:=0;
  end end;
  ����:=0;
end ���������������;

//---------- ����������� ���������� ������� -----------

procedure ������������(���,����:pClass; var �������,��������:integer);
var ��,���:integer;
begin
  ��������:=�������;
  for ��:=1 to ������� do
    ����^[��]:=���^[��];
    with ����^[��] do
      for ���:=1 to claTop do
        claList[���]:=memAlloc(lstrlen(���^[��].claList[���])+1);
        lstrcpy(claList[���],���^[��].claList[���]);
      end
    end
  end;
end ������������;

//---------- ��������� ������� �� ��������� -----------

procedure �������������();
var ��,���,����:integer;
begin
  ����:=0;
  resTopClass:=ord(lastIniClass)+1;
  for ��:=1 to resTopClass do
    resClasses^[��]:=iniClass[envER][classIniClass(��-1)];
    with resClasses^[��] do
    for ���:=1 to claTop do
      inc(����);
      claList[���]:=memAlloc(lstrlen(iniMenu[envER][����])+1);
      lstrcpy(claList[���],iniMenu[envER][����]);
    end end;
  end
end �������������;

//---------- ���������� ���������� ������� -----------

procedure ������������();
var ����,��,���,��:integer;
begin
  ����:=_lcreat(ResFile,0);
  if ����>0 then
    _lwrite(����,resWIN32,maxText);
    _lwrite(����,addr(resTopClass),4);
    for ��:=1 to resTopClass do
    with resClasses^[��] do
      _lwrite(����,addr(resClasses^[��]),sizeof(recClass));
      for ���:=1 to claTop do
        ��:=lstrlen(claList[���]);
        _lwrite(����,addr(��),4);
        _lwrite(����,claList[���],lstrlen(claList[���])+1);
      end;
    end end;
    _lclose(����)
  end
end ������������;

//---------- �������� ���������� ������� -----------

procedure ������������();
var ����,��,���,��:integer;
begin
  ����:=_lopen(ResFile,0);
  if ����>0 then
    _lread(����,resWIN32,maxText);
    _lread(����,addr(resTopClass),4);
    for ��:=1 to resTopClass do
    with resClasses^[��] do
      _lread(����,addr(resClasses^[��]),sizeof(recClass));
      for ���:=1 to claTop do
        _lread(����,addr(��),4);
        claList[���]:=memAlloc(��+1);
        _lread(����,claList[���],��+1);
      end;
    end end;
    _lclose(����)
  else �������������();
  end
end ������������;

//----------- ������ �������� ------------

const
  �����Win32=101;
  �����������=102;
  �������������=103;
  ������������=104;
  ��������������=10;
  ���������������=106;
  ����������=107;
  �������������=108;
  ��������X=109;
  ��������Y=110;
  �������������=111;
  ������������=112;
  ���������������=113;
  ��������������=114;
  �������=120;
  �����������=121;
  ��������������=122;

const DLG_SETDLG=stringER{"DLG_SETDLG_R","DLG_SETDLG_E"};
dialog DLG_SETDLG_R 2,6,304,188,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "��������� ��������� ��������"
begin
  control "���� Win32:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,42,2,60,10
  control "",�����Win32,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,2,74,10
  control "������ �������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,14,80,10
  control "",�����������,"LISTBOX",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,8,28,80,68
  control "��������",�������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,8,96,36,10
  control "�������",������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,50,96,36,10
  control "�������� ������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,136,18,88,10
  control "�������� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,32,90,10
  control "",���������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,32,60,10
  control "��� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,44,90,10
  control "",��������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,44,60,10
  control "������� ������:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,56,90,10
  control "",����������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,56,40,10
  control "��������� �����:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,68,90,10
  control "",�������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,68,60,10
  control "��������� ������ �� X:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,80,90,10
  control "",��������X,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,80,40,10
  control "��������� ������ �� Y:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,92,90,10
  control "",��������Y,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,92,40,10
  control "������ ��������� ������:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,32,110,108,10
  control "",�������������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY,2,120,300,40
  control "",������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,2,162,300,10
  control "��������",���������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,152,110,38,10
  control "�������",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,194,110,38,10
  control "��",�������,"Button",WS_CHILD | WS_VISIBLE,84,174,44,10
  control "��������",�����������,"Button",WS_CHILD | WS_VISIBLE,136,174,44,10
  control "�� ���������",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,250,174,52,10
end;
dialog DLG_SETDLG_E 2,6,304,188,
  DS_MODALFRAME | WS_POPUP | WS_CAPTION | WS_SYSMENU,
  "Options"
begin
  control "Win32 file:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,42,2,60,10
  control "",�����Win32,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,104,2,74,10
  control "Classes list:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,8,14,80,10
  control "",�����������,"LISTBOX",LBS_NOTIFY | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,8,28,80,68
  control "Add",�������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,8,96,36,10
  control "Delete",������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,50,96,36,10
  control "Class options:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,136,18,88,10
  control "Class name:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,32,90,10
  control "",���������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,32,60,10
  control "Class ident:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,44,90,10
  control "",��������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,44,60,10
  control "Styles prefix:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,56,90,10
  control "",����������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,56,40,10
  control "Initial text:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,68,90,10
  control "",�������������,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,68,60,10
  control "Initial size X:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,80,90,10
  control "",��������X,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,80,40,10
  control "Initial size Y:",-1,"Static",SS_RIGHT | WS_CHILD | WS_VISIBLE,100,92,90,10
  control "",��������Y,"EDIT",ES_LEFT | ES_AUTOHSCROLL | WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP,190,92,40,10
  control "Class variants:",-1,"Static",WS_CHILD | WS_VISIBLE | SS_CENTER,32,110,108,10
  control "",�������������,"Listbox",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | LBS_NOTIFY,2,120,300,40
  control "",������������,"Edit",WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_AUTOHSCROLL,2,162,300,10
  control "Add",���������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,152,110,38,10
  control "Delete",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,194,110,38,10
  control "Ok",�������,"Button",WS_CHILD | WS_VISIBLE,84,174,44,10
  control "Cancel",�����������,"Button",WS_CHILD | WS_VISIBLE,136,174,44,10
  control "By default",��������������,"Button",WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON,250,174,52,10
end;

//--------------------- ���������� ��������� ������ ----------------------------

procedure ������������(����:HWND; ��:integer);
var s:string[maxText]; ���:integer;
begin
  if (��>0)and(��<=resTopClass) then
  with resClasses^[��] do
    GetDlgItemText(����,���������������,claMenu,maxSClass);
    GetDlgItemText(����,��������������,claName,maxSClass);
    GetDlgItemText(����,����������,claStyle,maxSClass);
    GetDlgItemText(����,�������������,claIniText,maxSClass);
    claIniDX:=GetDlgItemInt(����,��������X,nil,true);
    claIniDY:=GetDlgItemInt(����,��������Y,nil,true);
    for ���:=1 to claTop do
      memFree(claList[���]);
    end;
    claTop:=SendDlgItemMessage(����,�������������,LB_GETCOUNT,0,0);
    for ���:=1 to claTop do
      SendDlgItemMessage(����,�������������,LB_GETTEXT,���-1,integer(addr(s)));
      claList[���]:=memAlloc(lstrlen(s)+1);
      lstrcpy(claList[���],s);
    end;
  end end;
end ������������;

//--------------------- �������� ��������� ������ ----------------------------

procedure ������������(����:HWND; ��:integer);
var ���:integer;
begin
  if (��>0)and(��<=resTopClass) then
  with resClasses^[��] do
    SetDlgItemText(����,���������������,claMenu);
    SetDlgItemText(����,��������������,claName);
    SetDlgItemText(����,����������,claStyle);
    SetDlgItemText(����,�������������,claIniText);
    SetDlgItemInt(����,��������X,claIniDX,true);
    SetDlgItemInt(����,��������Y,claIniDY,true);
    SendDlgItemMessage(����,�������������,LB_RESETCONTENT,0,0);
    for ���:=1 to claTop do
      SendDlgItemMessage(����,�������������,LB_ADDSTRING,0,integer(claList[���]));
    end;
    SendDlgItemMessage(����,�������������,LB_SETCURSEL,0,0);
    SendMessage(����,WM_COMMAND,LBN_SELCHANGE*0x10000+�������������,0);
  end end;
end ������������;

//--------------------- ���������� ������� �������� ----------------------------

procedure ������������(����:HWND; ����,������,������:integer):boolean;
var ��,����,���:integer; s,s2:string[maxText];
begin
  case ���� of
    WM_INITDIALOG: //�������������
      SetDlgItemText(����,�����Win32,resWIN32);
      for ��:=1 to resTopClass do
        SendDlgItemMessage(����,�����������,LB_ADDSTRING,0,integer(addr(resClasses^[��].claMenu)));
      end;
      resCarClass:=1;
      SendDlgItemMessage(����,�����������,LB_SETCURSEL,0,0);
      ������������(����,resCarClass);
      SetFocus(GetDlgItem(����,�����������));|
    WM_COMMAND:case loword(������) of
      �����������:if hiword(������)=LBN_SELCHANGE then //����� ������
        ��:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0)+1;
        ������������(����,resCarClass);
        resCarClass:=��;
        ������������(����,resCarClass);
      end;|
      �������������:if hiword(������)=LBN_SELCHANGE then //����� ��������
        ���:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0);
        if ���>=0 then
          SendDlgItemMessage(����,�������������,LB_GETTEXT,���,integer(addr(s)));
          SetDlgItemText(����,������������,s);
        end
      end;|
      ���������������:if hiword(������)=EN_CHANGE then //����� �������� ������
        GetDlgItemText(����,���������������,s,maxText);
        ���:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0);
        SendDlgItemMessage(����,�����������,LB_GETTEXT,���,integer(addr(s2)));
        if (lstrcmp(s,s2)<>0)and(���>=0) then
          SendDlgItemMessage(����,�����������,LB_DELETESTRING,���,0);
          SendDlgItemMessage(����,�����������,LB_INSERTSTRING,���,integer(addr(s)));
          SendDlgItemMessage(����,�����������,LB_SETCURSEL,���,0);
        end;
      end;|
      ������������:if hiword(������)=EN_CHANGE then //����� ������ ��������
        GetDlgItemText(����,������������,s,maxText);
        ���:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0);
        SendDlgItemMessage(����,�������������,LB_GETTEXT,���,integer(addr(s2)));
        if (lstrcmp(s,s2)<>0)and(���>=0) then
          SendDlgItemMessage(����,�������������,LB_DELETESTRING,���,0);
          SendDlgItemMessage(����,�������������,LB_INSERTSTRING,���,integer(addr(s)));
          SendDlgItemMessage(����,�������������,LB_SETCURSEL,���,0);
        end;
      end;|
      �������������:if hiword(������)=BN_CLICKED then //�������� �����
      if resTopClass=maxClass then mbS(_�������_�����_�������[envER])
      else
        ������������(����,resCarClass);
        ��:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0)+2;
        if (��>0)and(��<=resTopClass+1) then
          for ���:=resTopClass+1 downto ��+1 do
            resClasses^[���]:=resClasses^[���-1];
          end;
          RtlZeroMemory(addr(resClasses^[��]),sizeof(recClass));
          inc(resTopClass);
          SendDlgItemMessage(����,�����������,LB_INSERTSTRING,��-1,integer(""));
          SendDlgItemMessage(����,�����������,LB_SETCURSEL,��-1,0);
          resCarClass:=��;
          ������������(����,resCarClass);
          SetFocus(GetDlgItem(����,���������������));
        end
      end end;|
      ������������:if hiword(������)=BN_CLICKED then //������� �����
      if resTopClass=0 then mbS(_���_�������_�_������[envER])
      else
        ������������(����,resCarClass);
        ��:=SendDlgItemMessage(����,�����������,LB_GETCURSEL,0,0)+1;
        if (��>0)and(��<=resTopClass) then
          for ���:=�� to resTopClass-1 do
            resClasses^[���]:=resClasses^[���+1];
          end;
          dec(resTopClass);
          SendDlgItemMessage(����,�����������,LB_DELETESTRING,��-1,0);
          SendDlgItemMessage(����,�����������,LB_SETCURSEL,��-1,0);
          if ��<=resTopClass
            then resCarClass:=��;
            else resCarClass:=��-1;
          end;
          ������������(����,resCarClass);
        end
      end end;|
      ���������������:if hiword(������)=BN_CLICKED then //�������� �������
      with resClasses^[resCarClass] do
        ����:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0)+2;
        if ����>0 then
          SendDlgItemMessage(����,�������������,LB_INSERTSTRING,����-1,integer(""));
          SendDlgItemMessage(����,�������������,LB_SETCURSEL,����-1,0);
          SetDlgItemText(����,������������,nil);
          SetFocus(GetDlgItem(����,������������));
        end
      end end;|
      ��������������:if hiword(������)=BN_CLICKED then //������� �������
      with resClasses^[resCarClass] do
        ����:=SendDlgItemMessage(����,�������������,LB_GETCURSEL,0,0)+1;
        if ����>0 then
          SendDlgItemMessage(����,�������������,LB_DELETESTRING,����-1,0);
          SetDlgItemText(����,������������,nil);
        end;
      end end;|
      ��������������:if boolean(MessageBox(0,
        _��������_���_��������_��_��������_��_���������__[envER],"�������� !",MB_YESNO)) then
        ���������������(resClasses,resTopClass);
        �������������();
        SendDlgItemMessage(����,�����������,LB_RESETCONTENT,0,0);
        SendMessage(����,WM_INITDIALOG,0,0);
      end;|
      IDOK,�������:
        ������������(����,resCarClass);
        GetDlgItemText(����,�����Win32,resWIN32,maxText);
        EndDialog(����,1);|
      IDCANCEL,�����������:EndDialog(����,0);|
    end;|
  else return false
  end;
  return true;
end ������������;

//--------- ��������� ������� -------------

procedure ������������();
var ���:HWND; resClassesOld:pClass; resTopClassOld:integer;
begin
  ���:=GetFocus();
  resClassesOld:=memAlloc(sizeof(arrClass));
  ������������(resClasses,resClassesOld,resTopClass,resTopClassOld);
  if boolean(DialogBoxParam(hINSTANCE,DLG_SETDLG[envER],GetFocus(),addr(������������),0)) then
    ������������();
    ���������������(resClassesOld,resTopClassOld);
  else
    ���������������(resClasses,resTopClass);
    ������������(resClassesOld,resClasses,resTopClassOld,resTopClass);
  end;
  memFree(resClassesOld);
  SetFocus(���);
end ������������;

end SmRes.
