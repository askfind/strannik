//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 10:�������
//���� �����    2:��������� �����������
module Test10_2;
import Win32;

const 
  hINSTANCE=0x400000;
  ���������="Strannik";

bitmap BIT="Test10_2.bmp";

procedure ��������(����:HWND);
var bm,hBM,hOldBM:HBITMAP; dc,hMemDC:HDC; BM:BITMAP; ptSize,ptOrg:POINT; ps:PAINTSTRUCT;
begin
  dc:=BeginPaint(����,ps);
  bm:=LoadBitmap(hINSTANCE,"BIT");
  hMemDC:=CreateCompatibleDC(dc);
  hOldBM:=SelectObject(hMemDC,bm);
  if hOldBM<>0 then
    SetMapMode(hMemDC,GetMapMode(dc));
    GetObject(bm,sizeof(BITMAP),addr(BM));
    ptSize.x:=BM.bmWidth;
    ptSize.y:=BM.bmHeight;
    DPtoLP(dc,ptSize,1);
    ptOrg.x:=0;
    ptOrg.y:=0;
    DPtoLP(hMemDC,ptOrg,1);
    BitBlt(dc,10,10,ptSize.x,ptSize.y,
           hMemDC,ptOrg.x,ptOrg.y,SRCCOPY);
  end;
  SelectObject(hMemDC,hOldBM);
  DeleteDC(hMemDC);
  EndPaint(����,ps);
end ��������;

procedure ��������(����:HWND; ����,������,������:cardinal):boolean;
begin
  case ���� of
    WM_CREATE:return(true);|
    WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(����,����,������,������));|
    WM_PAINT:��������(����);|
    else return(DefWindowProc(����,����,������,������));
  end
end ��������;

var
  ��������:WNDCLASS;
  �������:HWND;
  �����:MSG;

begin

//����������� ������
  with �������� do
    style:=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc:=addr(��������);
    cbClsExtra:=0;
    cbWndExtra:=0;
    hInstance:=hINSTANCE;    
    hIcon:=0;
    hCursor:=LoadCursor(0,pstr(IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
    lpszClassName:=���������;
  end;
  RegisterClass(addr(��������));
                     
//�������� ����
  �������:=CreateWindowEx(0,���������,"Test10_2",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);

//���� ���������
  while GetMessage(addr(�����),0,0,0) do
    TranslateMessage(addr(�����));
    DispatchMessage(addr(�����));
  end;

end Test10_2.

