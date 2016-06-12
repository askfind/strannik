//������ ��������-������ ��� Windows 32, �������� ���������
//������ ������ 10:�������
//���� �����    2:��������� �����������

include Win32

define hINSTANCE 0x400000
define ��������� "Strannik"

bitmap BIT="Test10_2.bmp";

void ��������(HWND ����) {
HBITMAP bm,hBM,hOldBM;
BITMAP BM;
HDC dc,hMemDC;
POINT ptSize,ptOrg;
PAINTSTRUCT ps;

  dc=BeginPaint(����,ps);
  bm=LoadBitmap(hINSTANCE,"BIT");
  hMemDC=CreateCompatibleDC(dc);
  hOldBM=SelectObject(hMemDC,bm);
  if(hOldBM != 0) {
    SetMapMode(hMemDC,GetMapMode(dc));
    GetObject(bm,sizeof(BITMAP),&BM);
    ptSize.x=BM.bmWidth;
    ptSize.y=BM.bmHeight;
    DPtoLP(dc,ptSize,1);
    ptOrg.x=0;
    ptOrg.y=0;
    DPtoLP(hMemDC,ptOrg,1);
    BitBlt(dc,10,10,ptSize.x,ptSize.y,hMemDC,ptOrg.x,ptOrg.y,SRCCOPY);
  }
  SelectObject(hMemDC,hOldBM);
  DeleteDC(hMemDC);
  EndPaint(����,ps);
}

boolean ��������(HWND ����, int ����,int ������,int ������)
{
  switch(����) {
    case WM_CREATE:return(true); break;
    case WM_DESTROY:PostQuitMessage(0); return(DefWindowProc(����,����,������,������)); break;
    case WM_PAINT:��������(����); break;
    default:return(DefWindowProc(����,����,������,������));
  }
}

WNDCLASS ��������;
HWND �������;
MSG �����;

void main()
{
//����������� ������
  with(��������) {
    style=CS_HREDRAW | CS_VREDRAW;
    lpfnWndProc=&��������;
    cbClsExtra=0;
    cbWndExtra=0;
    hInstance=hINSTANCE;    
    hIcon=0;
    hCursor=LoadCursor(0,(pchar)IDC_ARROW);
    hbrBackground=COLOR_WINDOW;
    lpszMenuName=nil;
    lpszClassName=���������;
  }
  RegisterClass(&��������);
                     
//�������� ����
  �������=CreateWindowEx(0,���������,"Beta1_2",WS_OVERLAPPEDWINDOW,
    100,100,300,300, 0,0,hINSTANCE,nil);

  ShowWindow(�������,SW_SHOW);
  UpdateWindow(�������);

//���� ���������
  while(GetMessage(&�����,0,0,0)) {
    TranslateMessage(&�����);
    DispatchMessage(&�����);
  }
}

