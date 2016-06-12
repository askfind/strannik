//�������� ������-��-������� ��� Win32
//������
//���� SMIMP.D

definition module SmImp;
import Win32;

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ SYS (��������������� �������)
//���� SMSYS.D

//definition module SmSys;
//import Win32;

const  maxFonts=40;
type
  sysFonts=record
    top:integer;
    fnts:array[1..maxFonts]of pstr;
  end;
  pSysFonts=pointer to sysFonts;

//������������� ��������
  procedure sysSelectObject(dc:HDC; h:HANDLE; var old:HANDLE);
  procedure sysDeleteObject(dc:HDC; h:HANDLE; old:HANDLE);

//������
  procedure listFill(fillLen:integer; fillStr,fillBuf:pstr):pstr;
  procedure SetDlgItemReal(Dlg:HWND; idDlgItem:integer; Value:real; Pre:integer);
  procedure GetDlgItemReal(Dlg:HWND; idDlgItem:integer):real;

//����������� �������
  procedure sysGetFileName(bitOpen:boolean; getMas:pstr; getPath,getTitle:pstr):boolean;
  procedure sysChooseFont(chFace:pstr; var chStyle,chSize:integer):boolean;
  procedure sysGetFamilies(DC:HDC; res:pSysFonts);
  procedure sysChooseColor(wnd:HWND; col:cardinal):cardinal;
  procedure sysPrintDlg(var prnCopies:integer):HDC;

//���������
  procedure sysDrawBitmap(drawDC:HDC; x,y:integer; drawBitmap:HBITMAP);

//�������������� �����
  procedure sysAnsiToUnicode(c:char):word;
  procedure sysRealToReal32(r:real):cardinal;

//end SmSys.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ DAT (��������� ������)
//���� SMDAT.D

//definition module SmDat;
//import Win32;

//===============================================
//                 ���������
//===============================================

const hINSTANCE=0x400000;

//---------------- ������� --------------------

const
  idBase=30000;
  idBaseComm=9000;
  maxText=1024;
  maxTxt=20;
  maxFrag=150;
  maxStr=30000;
  maxMod=50;
  maxLIST=200;
  maxSubs=10000;
  maxPars=100;
  maxParCalls=30;
  maxSTRING=5000;
  maxUNDO=400;
  maxWith=16;
  maxStackCon=50;
  maxCode=0x2FFFF;
  maxData=0x2FFFF;
  maxVarCall=5000;
  maxProCall=5000;
  maxDebVar=500;
  maxDebFun=1000;
  maxDebStr=maxStr;
  maxDebLevel=10;
  maxLoadPSTR=300;
  maxLoadVAR=10000;
  maxJamp=2000;
  maxCall=2000;
  maxPoiC=30;
  maxImpDLL=100;
  maxImpFun=1000;
  maxExport=500;
  maxImpCALL=1000;
  maxDlgMem=32000;
  maxResMem=16000;
  maxModif=100;
  maxMDlg=100;
  maxBMP=100;
  maxRes=1000;
  maxResUndo=30;
  maxStrID=100;
  maxTxtFile=255;
  maxTxtTitle=255;
  maxButt=50;
  maxClass=40;
  maxSClass=30;
  maxClassMenu=15;
  maxFind=50;
  maxStep=10000;
  maxStackStep=50;
  maxStepActive=300;
  maxStackMet=200;
  maxClasses=5000;
  StatusFile="Sm.Sta";
  ConstFile="Sm.Con";
  ResFile="Sm.Res";
  HelpFile="Sm.hlp";
  envBUFSIZE=500;

//------------- ������������� -----------------

const
  _ediTrackX  =10;
  _genBASECODE=0x400000;
  _genSTACKMAX=0x100000;
  _genSTACKMIN=0x2000;
  _genHEAPMAX=0x100000;
  _genHEAPMIN=0x1000;
  _genCLASSSIZE=512;
  _envEDITBK=0xFFFFFF;
  _envEDITSEL=0x808080;
  _envTRACKMAX=200;
  _envTRACKUP=4;
  _envWIN32="Win32.hlp";
  _envEXTM="m";
  _envEXTD="d";
  _envEXTI="i";
  _envBMPE="MSPaint.exe";
  _resWIN32="Win32.i";

//��������� ����� ����������

type classER=(erRussian,erEnglish);
type stringER=array[classER]of pstr;

  const
    ProgName=stringER{"�������� ������-��-�������","Strannik Modula-C-Pascal"};
    _���������_�������������=stringER{"��������� �������������","Duplicate identifier"};
    _������_�������������_���_�����=stringER{"������:������������� ��� �����","ERROR:Identifier without name"};
    _��������_�����_������=stringER{"�������� ����� ������","Incorrect module number"};
    _��_������_������_=stringER{"�� ������ ������:","Undefined module:"};
    _�_������_��_������_�������������_=stringER{"� ������ �� ������ �������������:","Undefined identifier:"};
    _���������_�_tabSubs_=stringER{"��������� � tabSubs:","System error in tabSubs:"};
    _������_=stringER{"������ ","Import "};
    _���������_������_�_idRead=stringER{"��������� ������ � idRead","System error in idRead"};
    _�����������������_������_�������=stringER{"����������������� ������ �������","Uninitial import list"};
    _�������_�����_�������_DLL=stringER{"������� ����� ������� DLL","Too much DLL calls"};
    _�������_�����_��������������_����=stringER{"������� ����� �������������� ����","Too much export identifier"};
    _������������_������_���������_��������=stringER{"������������ ������ ��������� ��������","Too much string constant"};
    _����������_���������__=stringER{"���������� ��������� ?","Abort process ?"};
    _�������_�����_��������_IF_���_CASE=stringER{"������� ����� �������� IF ��� CASE","Too much items in IF or CASE"};
    _���������_�_genSetJamp_=stringER{"��������� � genSetJamp:","System error in genSetJamp:"};
    _�������_�����_�������_��������_�_������=stringER{"������� ����� ������� �������� � ������","Too much procedure calls"};
    _��_����������_���������_=stringER{"�� ���������� ���������:","Undefined procedure:"};
    _���������_������_�_GenSetCalls=stringER{"��������� ������ � GenSetCalls","System error in GenSetCalls"};
    _�������_�����_���������_�_����������_�_������=stringER{"������� ����� ��������� � ���������� � ������","Too much variable calls"};
    _�������_�����_�������_�������_��������_�_������=stringER{"������� ����� ������� ������� �������� � ������","Too much external procedure calls"};
    _��_������_�������������_=stringER{"�� ������ �������������:","Undefined identifier:"};
    _��_�������_�������_=stringER{"�� ������� �������:","Undefined function:"};
    _�������_�����_�����������_��������=stringER{"������� ����� ����������� ��������","Too much structured constant"};
    _�������_�������_���=stringER{"������� ������� ���","Too much code"};
    _genPref_���������_������=stringER{"genPref:��������� ������","System error in genPref"};
    _�����_������_����������=stringER{"����� ������ ����������","Error located"};
    _��������_�������__genPost_=stringER{"�������� ������� (genPost)","Undefined command (genPost)"};
    _��������_��������=stringER{"�������� ��������","Operand error"};
    _���������_�_GenSeg=stringER{"��������� � GenSeg","System error in GenSeg"};
    _���������_�_GenRR=stringER{"��������� � GenRR","System error in GenRR"};
    _���������_�_GenRD=stringER{"��������� � GenRD","System error in GenRD"};
    _���������_�_GenMR_=stringER{"��������� � GenMR:","System error in GenMR:"};
    _���������_�_GenMD=stringER{"��������� � GenMD","System error in GenMD"};
    _�������=stringER{"�������","register"};
    _���������_�_GenR=stringER{"��������� � GenR","System error in GenR"};
    _������=stringER{"������","memory"};
    _���������_�_GenM_=stringER{"��������� � GenM:","System error in GenM:"};
    _���������_�_GenD=stringER{"��������� � GenD","System error in GenD"};
    _���������_������_�_genGen_=stringER{"��������� ������ � genGen:","System error in genGen:"};
    _���������_������_�_genRCL=stringER{"��������� ������ � genRCL","System error in genRCL"};
    _���������_�_genSize=stringER{"��������� � genSize","System error in genSize"};
    _���������_�_genSize_2=stringER{"��������� � genSize 2","System error in genSize 2"};
    _���������_������_�_genTrackResName=stringER{"��������� ������ � genTrackResName","System error in genTrackResName"};
    _��_����������_�����_�����_=stringER{"�� ���������� ����� �����:","Undefined point enter:"};
    _EXE_����_�����_������_�����������_=stringER{"EXE-���� ����� ������ �����������:","EXE-file occupied:"};
    _�������_�����_�������=stringER{"������� ����� �������","Too much modules"};
    _�������_�������_����������_���������=stringER{"������� ������� ���������� ���������","Too mach const expression"};
    _�������_��_����=stringER{"������� �� ����","Divide by zero"};
    _�������_�������_���������_���������=stringER{"������� ������� ��������� ���������","Too much string constant"};
    _���������_=stringER{"��������� ","Expected "};
    _�������_�����_�����=stringER{"������� ����� �����","Too mach labels"};
    _�����_���_�������=stringER{"����� ��� �������","Label already is present"};
    _�����_���_������������=stringER{"����� ��� ������������","Label is already used"};
    _�������_�����_������_��������=stringER{"������� ����� ������ ��������","Too mach jamp"};
    _��������_������_���������=stringER{"�������� ������ ���������","Incorrect size of operands"};
    _���������_���������=stringER{"��������� ���������","Constant expected"};
    _���������_���_����������=stringER{"��������� ��� ����������","Variable name expected"};
    _��������_�������=stringER{"�������� �������","Incorrect operand"};
    _���������_�����=stringER{"��������� �����","Label expected"};
    _���������_�_asmCommand=stringER{"��������� � asmCommand","System error in asmCommand"};
    _��������_�����_����������=stringER{"�������� ����� ����������","Incorrect interrupt number"};
    _���������_�������=stringER{"��������� �������","Incorrect operand"};
    _��������������_�����=stringER{"�������������� �����","Undefined label"};
    _�������_�������_�������_��_�����_=stringER{"������� ������� ������� �� ����� ","Too long jamp to label "};
    _�����������_��������_����_=stringER{"����������� �������� ����:","Type definition expected:"};
    _�������_�����_��������_�_������=stringER{"������� ����� �������� � ������","Too much dialogs in module"};
    _�������_�����_���������_�_�������=stringER{"������� ����� ��������� � �������","Too much items in dialog"};
    _�������_�����_bitmap_�_������=stringER{"������� ����� bitmap � ������","Too much bitmap in module"};
    _�����������_BMP_����_=stringER{"����������� BMP-����:","BMP-file expected:"};
    _BMP_����_���������_�������_=stringER{"BMP-���� ��������� �������:","Incorrect format of BMP-file:"};
    _���������_��������_���������=stringER{"��������� �������� ���������","Constant value expected"};
    _���������_�����=stringER{"��������� �����","Number expected"};
    _������_�_��������_����=stringER{"������ � �������� ����","Type definition error"};
    _���������_��������_����=stringER{"��������� �������� ����","Type definition expected"};
    _���������_�����_�����=stringER{"��������� ����� �����","Integer expected"};
    _��������_������=stringER{"�������� ������","Symbol expected"};
    _���������_���������_TRUE_���_FALSE=stringER{"��������� ��������� TRUE ��� FALSE","TRUE or FALSE expected"};
    _���������_�����_���_nil=stringER{"��������� ����� ��� nil","Integer or nil expected"};
    _���������_������_���_nil=stringER{"��������� ������ ��� nil","String or nil expected"};
    _���������_���������=stringER{"��������� ���������","Set expected"};
    _��������_���_�_�����������_���������=stringER{"�������� ��� � ����������� ���������","Incorrect type"};
    _���������_������=stringER{"��������� ������","String expected"};
    _�������_�������_������=stringER{"������� ������� ������","Too long string"};
    _���������_���������_����������_����_=stringER{"��������� ��������� ���������� ���� ","Constant expected "};
    _��������_���_�_�����������_���������_=stringER{"�������� ��� � ����������� ���������:","Incorrect type:"};
    _���������__=stringER{"��������� ]","] expected"};
    _��������_���_������������=stringER{"�������� ��� ������������","Scalar expected"};
    _���������_�����_���������=stringER{"��������� ����� ���������","Integer constant expected"};
    _��������_���_�������=stringER{"�������� ��� �������","Incorrect index type"};
    _��������_��������_��������=stringER{"�������� �������� ��������","Incorrect index range"};
    _���������_���_����_=stringER{"��������� ��� ����:","Duplicate field name:"};
    _���������_�����_���=stringER{"��������� ����� ���","New name expected"};
    _��������_��������_BYTE=stringER{"�������� �������� BYTE","Incorrect BYTE operation"};
    _��������_��������_WORD=stringER{"�������� �������� WORD","Incorrect WORD operation"};
    _��������_��������_LONG=stringER{"�������� �������� LONG","Incorrect LONG operation"};
    _��������_��������_REAL=stringER{"�������� �������� REAL","Incorrect REAL operation"};
    _�����������_������_=stringER{"����������� ������:","Module expected:"};
    _��_������������_������_=stringER{"�� ������������ ������:","Module is not compiling:"};
    _��������_definition_������=stringER{"�������� definition ������","Definition module expected"};
    _��������_�����������_������=stringER{"�������� ����������� ������","Program module expected"};
    _���������_���_������_=stringER{"��������� ��� ������:","Module name expected:"};
    _���������_���_������=stringER{"��������� ��� ������","Module name expected"};
    _ASCII_�������_���������_������_�_def_������=stringER{"ASCII-������� ��������� ������ � def-������","ASCII-function is admitted only in the def-module"};
    _���������_������_�_traPROC=stringER{"��������� ������ � traPROC","System error in traPROC"};
    _���������_���_���������_=stringER{"��������� ��� ���������:","Procedure name expected:"};
    _��������_���_����������_�������=stringER{"�������� ��� ���������� �������","Incorrect type of function result"};
    _�������_�����_����������=stringER{"������� ����� ����������","Too much parameters"};
    _�������������_����������_����������=stringER{"������������� ���������� ����������","Incorrect amount of parameters"};
    _�������������_�����_���������=stringER{"������������� ����� ���������","Incorrect parameter name"};
    _�������������_������_���������=stringER{"������������� ������ ���������","Incorrect parameter class"};
    _�������_�����_���������_�������_�������=stringER{"������� ����� ��������� ������� �������","Too much function calls"};
    __�_=stringER{" � "," and "};
    _��������������_�����__=stringER{"�������������� �����: ","Type mismatch: "};
    _���������_�_traCALL=stringER{"��������� � traCALL","System error in traCALL"};
    _������������_���������=stringER{"������������ ���������","Incorrect constant"};
    _���������_�����=stringER{"��������� �����","Integer expected"};
    _��������_���_�������������=stringER{"�������� ��� �������������","Incorrect type"};
    _������������_���_��������_�����=stringER{"������������ ��� �������� �����","Incorrect type"};
    _���������_����������_������=stringER{"��������� ����������-������","Record variable expected"};
    _�������_�����_���������_WITH=stringER{"������� ����� ��������� WITH","Too much WITH"};
    _���������_FROM_�����_����_������_�_def_������=stringER{"��������� FROM ����� ���� ������ � def-������","FROM is admitted only in the def-module"};
    _���������_���_DLL=stringER{"��������� ��� DLL","DLL name expected"};
    _��������_���_����������=stringER{"�������� ��� ����������","Incorrect type"};
    _��������_���_���������=stringER{"�������� ��� ���������","Incorrect type"};
    _�������_�����_����������=stringER{"������� ����� ����������","Too much pointers"};
    _���������_����������=stringER{"��������� ����������","Variable expected"};
    _��������_���_���������=stringER{"�������� ��� ���������","Pointer expected"};
    _��������������_���_���������=stringER{"�������������� ��� ���������","Undefined pointer"};
    _��������_���_������=stringER{"�������� ��� ������","Record expected"};
    _���������_���_����_=stringER{"��������� ��� ����:","Field name expected:"};
    _���������_���_����=stringER{"��������� ��� ����","Field name expected"};
    _��������_������=stringER{"�������� ������","Array expected"};
    _���������_������_�_traLOAD=stringER{"��������� ������ � traLOAD","System error in traLOAD"};
    _��������_��������������_�����=stringER{"�������� �������������� �����","Incorrect typecast"};
    _����������=stringER{"����������","variable"};
    _�������_��_����������_��������=stringER{"������� �� ���������� ��������","The function does not return value"};
    _���������_int=stringER{"��������� int","int expected"};
    _���������_���������=stringER{"��������� ���������","Expression expected"};
    _���������_���_����=stringER{"��������� ��� ����","Type name expected"};
    _���������_������������_�����=stringER{"��������� ������������ �����","Float expected"};
    _��������_���=stringER{"�������� ���","Incorrect type"};
    _��������_���_�_���������_�_����������=stringER{"�������� ��� � ��������� � ����������","Incorrect type"};
    _��������_���_�_��������_���������=stringER{"�������� ��� � �������� ���������","Incorrect type"};
    _��������_���_int=stringER{"�������� ��� int","int expected"};
    _���������_���=stringER{"��������� ���","Incorrect type"};
    _�������_main_��_������_�����_���������=stringER{"������� main �� ������ ����� ����������","The main function should not have parameters"};
    _���������_������_�_tracPROC=stringER{"��������� ������ � tracPROC","System error in tracPROC"};
    _��������_������_����������=stringER{"�������� ������ ����������","Variable list expected"};
    _�������_main_��_������_�����_���������_����������=stringER{"������� main �� ������ ����� ��������� ����������","The main function should not have local variable"};
    _��������_������_����������_���_�������=stringER{"�������� ������ ���������� ��� �������","Variable list or function expected"};
    _���������_�_tracCALL=stringER{"��������� � tracCALL","System error in tracCALL"};
    _��������_�������_�����_=stringER{"�������� ������� �����:","The counter of a cycle was expected:"};
    _���������_�������_���������_�����=stringER{"��������� ������� ��������� �����","The condition of the termination of a cycle was expected"};
    _���������_���_�������_=stringER{"��������� ��� �������:","Function name expected:"};
    _���������_���_�������=stringER{"��������� ��� �������","Function name expected"};
    _�������_�����_������=stringER{"������� ����� ������","Too much styles"};
    _�����_=stringER{"�����:","Text:"};
    _�����_=stringER{"�����:","Class:"};
    _��_=stringER{"��:","Id:"};
    _��������_������_������_��_=stringER{"�������� ������ ������ �� ","Loading styles from "};
    _������_���������_������_�����=stringER{"������ ��������� ������ �����","It is impossible to add empty style"};
    _������_���������_���������_�����=stringER{"������ ��������� ��������� �����","It is impossible to add repeated style"};
    _������_Clipboard_�����_������_�����������=stringER{"������:Clipboard ����� ������ �����������","ERROR:Clipboard is occupied in other application"};
    _������_��������_������_������_�_Clipboard=stringER{"������:�������� ������ ������ � Clipboard","ERROR:Incorrect data format in Clipboard"};
    _��������_������_�_Clipboard=stringER{"�������� ������ � Clipboard","Incorrect data in Clipboard"};
    _���������_������_��������_������_�_������_������_=stringER{"��������� ������:�������� ������ � ������ ������:","System error:Incorrect data in undo buffer:"};
    _�����=stringER{"�����","New"};
    _������=stringER{"������","Edit"};
    _���������=stringER{"���������","Align"};
    _������=stringER{"������","Dialog"};
    _��=stringER{"��","Ok"};
    _������=stringER{"������","Cancel"};
    _������_�����������_������_��������=stringER{"������ ����������� ������ ��������","Error registration class"};
    _������_�����������_������_�������=stringER{"������ ����������� ������ �������","Error registration class"};
    _������=stringER{"������","ERROR"};
    _����������=stringER{"����������","DialogName"};
    _�������_�����_�������=stringER{"������� ����� �������","Too much classes"};
    _���_�������_�_������=stringER{"��� ������� � ������","No classes in the list"};
    _��������_���_��������_��_��������_��_���������__=stringER{"�������� ��� �������� �� �������� �� ��������� ?","Set standard values ?"};
    _���������_=stringER{"���������:","Constant:"};
    _�������_���_=stringER{"������� ���:","Base type:"};
    _������_=stringER{"������[","Array["};
    _���������_��_=stringER{"��������� �� ","Pointer to "};
    _���_������������=stringER{"��� ������������","Scalar type"};
    _����_������=stringER{"���� ������","Record field"};
    _��������_���������=stringER{"�������� ���������","Function parameter"};
    _����������=stringER{"����������","Variable"};
    _����������_���������=stringER{"���������� ���������","Local variable"};
    _��������_���������__VAR_=stringER{"�������� ��������� (VAR)","Function parameter (VAR)"};
    _���_������=stringER{"��� ������","Module name"};
    _�����������������_�������������=stringER{"����������������� �������������","Reserved identificator"};
    _���������_������_����������_��������_�����=stringER{"��������� ������:���������� �������� �����","System error:impossible to receive the font"};
    _�������=stringER{"�������","Modified"};
    _������__li=stringER{"��� %li","Line %li"};
    __�������__li=stringER{" ��� %li"," Col %li"};
    __�����__li=stringER{" ����� %li"," Lines %li"};
    __������__li_�=stringER{" ������ %li �"," Memory %li K"};
    _������_�_ediStatusOtr_������������_����=stringER{"������ � ediStatusOtr,������������ ����","System error in ediStatusOtr"};
    _������_�_envStatusOtr_�������������_����=stringER{"������ � envStatusOtr,������������� ����","System error in envStatusOtr"};
    _�������_�����=stringER{"������� �����","������� �����"};
    _��������_�����=stringER{"�������� �����","Deleting text"};
    _��������_�����_=stringER{"�������� �����:","Loading file:"};
    _�������_���_��������_�����_=stringER{"������� ��� �������� �����:","Failure at opening the file:"};
    _�������_�����_����=stringER{"������� ����� ����","Too much windows"};
    _�_����_�������������_�����__���������__=stringER{"� ���� ������������� �����. ��������� ?","Text was modified. Save it ?"};
    _����_���_����������__����������__=stringER{"���� ��� ����������. ���������� ?","The file already exists. Rewrite it ?"};
    _�_����_�������������_�����__���������_=stringER{"� ���� ������������� �����. ���������?","Text was modified. Save it ?"};
    _����������=stringER{"����������","COMPILING"};
    _�������������_������=stringER{"������������� ������","Initialization of the tables"};
    _���������_i_�����=stringER{"��������� i-�����","i-file created"};
    _���������_exe_dll__�����=stringER{"��������� exe(dll)-�����","Exe(dll)-file created"};
    __13_10_������_����������=stringER{"\13\10 ������ ����������","\13\10 Variable list"};
    __13_10_������_�������=stringER{"\13\10 ������ �������","\13\10 Function list"};
    __���__lx=stringER{":��� %lx",":code %lx"};
    __������__li=stringER{":������ %li",":line %li"};
    __13_10_������_�����=stringER{"\13\10 ������ �����","\13\10 Lines list"};
    _�����_������_��_����������=stringER{"����� ������ �� ����������","The place of an error is not revealed"};
    _�����������_����_=stringER{"����������� ����:","File expected:"};
    _������_���_��������_�������=stringER{"������ ��� �������� �������","Create dialog error"};
    _��������_��_������=stringER{"�������� �� ������","Text is not found"};
    _��_����������_��������_���_������=stringER{"�� ���������� �������� ��� ������","Find text is not set"};
    _��������_��������__=stringER{"�������� �������� ?","Replace text ?"};
    _������_���_�������_���������=stringER{"������ ��� ������� ���������","RUN ERROR"};
    _�������_�����_������__=stringER{"������� ����� ������ ?","Create new dialog ?"};
    _���_�����=stringER{"��� �����","File expected"};
    _��������_������_���������������_��_=stringER{"�������� ������ ��������������� �� ","Loading identifiers from "};
    _���_����������__����������__�����������_����������_=stringER{"��� ����������. ����������, ����������� ����������.","Not information. Compiling, please."};
    _�����������_�������������_=stringER{"����������� �������������:","Indefined identifier:"};
    _�_������=stringER{"� ������","Copy"};
    _��������_����=stringER{"�������� ����","Incorrect color"};
    _����������_�����=stringER{"���������� �����","English small"};
    _����������_�������=stringER{"���������� �������","English large"};
    _�������_�����=stringER{"������� �����","Russian small"};
    _�������_�������=stringER{"������� �������","Russian large"};
    _��������_����_=stringER{"�������� ����:","Incorrect color:"};
    _������_�����������_������_Stran32Env=stringER{"������ ����������� ������ Stran32Env","Class registration error:Stran32Env"};
    _������_���_��������_����_editWnd=stringER{"������ ��� �������� ���� editWnd","Create window error:editWnd"};
    _������_�����������_������_Stran32=stringER{"������ ����������� ������ Stran32","Class registration error:Stran32"};
    _������_��������_����=stringER{"������ �������� ����","Create window error"};
    _���������_������_�_stepPop=stringER{"��������� ������ � stepPop","System error in stepPop"};
    _������_���������_���������_��������=stringER{"������ ��������� ��������� ��������","Error get context process"};
    _������_������_������_��_�����=stringER{"������ ������ ������ �� �����","Error get stack process"};
    _������_������_������_��������=stringER{"������ ������ ������ ��������","Error get process data"};
    _�������_�����_�����_��������=stringER{"������� ����� ����� ��������","Too many breakpoint"};
    _���������_������_�_����������Break=stringER{"��������� ������ � ����������Break","System error in otlDeleteBreak"};
    _�����_����������_����������_�_������__li_�_������_=stringER{"����� ���������� ���������� � ������ %li � ������ ","Breakpoint into %li line in module "};
    _������_��������__lx_=stringER{"������ �������� %lx ","Process error %li"};
    __��_������__lx_=stringER{" �� ������ %lx "," in address %lx"};
    _������_�����������_������_���������=stringER{"������ ����������� ������ ���������","Error of definition of the breakpoint"};
    _������_�����������_������_���������__2_=stringER{"������ ����������� ������ ��������� (2)","Error of definition of the breakpoint (2)"};
    _���������_������_�_���������������=stringER{"��������� ������ � ���������������","System error in otlInit"};
    _�������_��������_�������_�������=stringER{"������� �������� ������� �������","Failure of created debug timer"};
    _�������_�������_�����_=stringER{"������� ������� �����:","Failure of run of file:"};
    _���������_������_�_������������=stringER{"��������� ������ � ������������","System error in otlEnd"};
    _������_������_�����_�����=stringER{"������ ������ ����� �����","Error of find of procedure enter"};
    _������_������_�����_��������=stringER{"������ ������ ����� ��������","Error of find of procedure return"};
    _���������_�_�������������Break__1_=stringER{"��������� � �������������Break (1)","System error in otlReasstavitBreak (1)"};
    _���������_�_�������������Break__2_=stringER{"��������� � �������������Break (2)","System error in otlReasstavitBreak (2)"};
    _���������_�_�������������Break__3_=stringER{"��������� � �������������Break (3)","System error in otlReasstavitBreak (3)"};
    _���������_�_�������������Break__4_=stringER{"��������� � �������������Break (4)","System error in otlReasstavitBreak (4)"};
    _��������_���_�������=stringER{"�������� ��� �������","Debugger already run"};
    _��������_��_�������=stringER{"�������� �� �������","Debugger not run"};
    _���_����_���_�������_������=stringER{"��� ���� ��� ������� ������","No code for this line"};
    _�����_�������_��������=stringER{"����� ������� ��������","Debug stopped"};
    _�������=stringER{"�������","Debugged"};
    _��������=stringER{"��������","Running"};
    _������_��������_����������=stringER{"������ �������� ����������","Reading variable value"};
    _���������_���_������=stringER{"��������� ��� ������","Class name expected"};
    _��������_�����=stringER{"�������� �����","Class expected"};
    _�������_�����_���������_����������=stringER{"������� ����� ��������� ����������","Too many nested variables"};
    _������������_������_���������������=stringER{"������������ ������ ���������������","Too many names"};
    _������������_������_�����=stringER{"������������ ������ �����","Too many substitutions"};
    _����������_�������_�������_�������=stringER{"���������� ������� ������� �������","Class table overflow"};
    _������������_����������=stringER{"������������ ����������","Incorrect variable"};
    _������������_������_����������_������������_������_=stringER{"������������ ������ ���������� ������������ ������:","Incorrect parameter list of virtual method"};
    _���������_����_�������=stringER{"��������� ���� �������","Violation of access rights"};
    _���������_���_������=stringER{"��������� ��� ������","Method name duplicated"};

//������,����������������� ��������������,������� ����

var
  ediTrackX:integer;
  genBASECODE:integer;
  genSTACKMAX:integer;
  genSTACKMIN:integer;
  genHEAPMAX:integer;
  genHEAPMIN:integer;
  genCLASSSIZE:integer;
  envEDITBK:integer;
  envEDITSEL:integer;
  envTRACKMAX:integer;
  envTRACKUP:integer;
  envWIN32:pstr;
  envEXTM:pstr;
  envEXTD:pstr;
  envEXTI:pstr;
  envBMPE:pstr;
  envExeFolder:pstr;
  resWIN32:pstr;

  type pinteger=pointer to integer;

//===============================================
//             ��������������� �����
//===============================================

type classLANG=(langMODULA,langC,langPASCAL);

const
  ButtonStyle=WS_CHILD | WS_VISIBLE | WS_TABSTOP | BS_PUSHBUTTON;
  StaticStyle=WS_CHILD | WS_VISIBLE | SS_CENTER;
  EditorStyle=WS_CHILD | WS_VISIBLE | WS_BORDER | WS_TABSTOP;
  ListboxStyle=WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER;

//---------------- ������� --------------------

type
  classComm=(comNULL,
    cFilNew,cFilOpen,cFilOpenCar,cFilSave,cFilSaveAs,cFilClose,cSEP1,cFilExit,
    cBlkUndo,cSEP2,cBlkCut,cBlkCopy,cBlkPaste,cBlkDel,cSEP3,cBlkAll,
    cFindFind,cFindNext,cFindRepl,
    cComComp,cComAll,cComDll,cSEP4,cComRun,
    cDebRun,cDebEnd,cDebRunEnd,cSEP41,cDebNextDown,cDebNext,cDebGoto,cSEP42,cDebView,
    cUtilId,cSEP5,cUtilRes,cUtilErr,
    cSetComp,cSetEnv,cSetDlg,cSEP6,cSetMain,cSetClear,
    cHlpCont,cHlpWin32,cSEP7,cHlpAbout,
    cLanguige,cExit);
  classGroup=(gNULL,gFil,gBlk,gFind,gCom,gDeb,gUtil,gSet,gHlp,gLanguige,gExit);

type arrCommand=array[classER]of array[classComm]of pstr;
const setCommand=arrCommand{{"",
    "&�����","&�������","������� &����� �������","&���������\9F2","��������� &��� ...","&�������\9Ctrl+F4","","&�����\9Alt+F4",
    "&��������\9Ctrl+Backspace","","&��������\9Shift+Delelte","&����������\9Ctrl+Insert","�&�������\9Shift+Insert","&�������\9Delete","","�&������� ���",
    "&�����\9Ctrl+F3","&��������� �����\9F3","����� � &������\9Shift+F3",
    "&�������������\9Alt+F9","������������� &���\9F9","������������� &DLL","","&���������\9Ctrl+F9",
    "&��������� ��� ����������","��������� &�������","��������� &�����","","&��������� ���\9F7","��������� ��� (&��� ����� � ���������)\9F8","&������� � ������� ������\9F4","","�������� �&���������",
    "&�������������\9Ctrl+F1","","&������������� ������","&����� ������",
    "��������� &�����������","��������� &��������������� �����","��������� &��������� ��������","","&���������� ������� ����","&�������� ������� ����",
    "&��������������� ����� � ����� ����������������","���������� �� &Win32","","� &���������",
    "&English","&�����"},
   {"",
    "&New","&Open","Open &before","&Save\9F2","Save &As ...","&Close\9Ctrl+F4","","&Exit\9Alt+F4",
    "&Undo\9Ctrl+Backspace","","&Cut\9Shift+Delelte","&Copy\9Ctrl+Insert","&Paste\9Shift+Insert","C&lear\9Delete","","&Select all",
    "&Find\9Ctrl+F3","&Next find\9F3","Find and &repalce\9Shift+F3",
    "&Compile\9Alt+F9","&Make all\9F9","Compile &DLL","","&Run\9Ctrl+F9",
    "&Run debugger","Stop &debugged","Run to &end","","&Next step\9F7","Next step (&without proc enter)\9F8","&Go to current line\9F4","","&View variables",
    "&Identifier\9Ctrl+F1","","&Edit resurce","&Find error",
    "&Compiler options","&Editor options","&Dialog editor options","","&Set main file","&Reset main file",
    "&Editor and programming languages","Help on &Win32","","&About",
    "&Russian","&Exit"}};

//������ bitmap �� 1
type arrButtons=array[classComm]of integer;
const setButtons=arrButtons{0,
    26,1,0,2,0,4,0,0,
    24,0,5,6,7,8,0,0,
    9,10,11,
    12,13,27,0,14,
    28,29,0,0,30,31,33,0,32,
    15,0,16,17,
    0,0,0,0,20,21,
    0,0,0,0,
    0,0};

type arrGroup=array[classER]of array[classGroup]of record
  grName:pstr;
  grLo,grHi:classComm;
end;
const setGroup=arrGroup{{
  {"",comNULL,comNULL},
  {"&����",cFilNew,cFilExit},
  {"&������",cBlkUndo,cBlkAll},
  {"&�����",cFindFind,cFindRepl},
  {"&����������",cComComp,cComRun},
  {"&�������",cDebRun,cDebView},
  {"&�����������",cUtilId,cUtilErr},
  {"&���������",cSetComp,cSetClear},
  {"&������",cHlpCont,cHlpAbout},
  {"&English",cLanguige,cLanguige},
  {"&�����",cExit,cExit}},
{
  {"",comNULL,comNULL},
  {"&File",cFilNew,cFilExit},
  {"&Edit",cBlkUndo,cBlkAll},
  {"F&ind",cFindFind,cFindRepl},
  {"&Compile",cComComp,cComRun},
  {"&Debugged",cDebRun,cDebView},
  {"&Tools",cUtilId,cUtilErr},
  {"&Options",cSetComp,cSetClear},
  {"&Help",cHlpCont,cHlpAbout},
  {"&Russian",cLanguige,cLanguige},
  {"&Exit",cExit,cExit}}};

//-------------- ����������� ------------------

type classPARSE=(pNULL,
       pPlu,pMin,pDiv,pPro,pMul,pVer,pVos,pVol,pRes,pDol,pPoi,pAmp,pUg,pSob,
       pOvR,pOvL,pFiL,pFiR,pSem,pDup,pSqR,pSqL,pCol,
       pUgR,pEqv,pUgL,
       pPluPlu,pMinMin,pPluEqv,pMinEqv,pDivDiv,pVosEqv,pVerVer,pSobSob,pPoiPoi,pDolDol,pDupDup,pDupEqv,
       pDivMul,pMulDiv,
       pUgLUgL,pUgRUgR,pMinUgR,pEqvEqv,pUgREqv,pUgLUgR,pUgLEqv);

const loPARSE=pPlu; hiPARSE=pUgLEqv;
type arrPARSE=array[classPARSE]of pstr;
const namePARSE=arrPARSE{'',
      '+','-','/','%','*','|','!','~','#','$','.','@','^','&',
      ')',"(",'{','}',';',':',']','[',',',
      '>','=','<',
      '++','--','+=','-=','//','!=','||','&&','..','$$','::',':=',
      "/*","*/",
      '<<','>>','->','==','>=','<>','<='};

//------- ����������������� ����� -------------

type classREZ=(rezNULL,
               rADDR,rAND,rARRAY,rASCII,rASM,rBEGIN,rBITMAP,rBREAK,rCASE,rCLASS,rCONST,rCONTROL,
               rDEC,rDEFINE,rDEFAULT,rDEFINITION,rDIALOG,rDIV,rDO,rDOWNTO,
               rELSE,rELSIF,rEND,rENUM,rEXIT,rEXPORT,rFALSE,rFOR,rFORWARD,rFROM,rFUNCTION,rHIBYTE,rHIWORD,
               rICON,rIF,rIMPLEMENTATION,rIMPORT,rIN,rINC,rINCLUDE,rLOBYTE,rLOWORD,
               rMOD,rMODULE,rNEW,rNIL,rNOT,rNULL,rOBJECT,rOF,rOFFS,rOR,rORD,rPOINTER,rPRIVATE,rPROCEDURE,rPROTECTED,rPROGRAM,rPUBLIC,
               rRECORD,rREPEAT,rRETURN,rSET,rSIZEOF,rSTRING,rSTRONG,rSTRUCT,rSWITCH,
               rTHEN,rTO,rTRUE,rTRUNC,rTYPE,rTYPEDEF,
               rUNION,rUNIT,rUNSIGNED,rUNTIL,rUSES,rVAR,rVIRTUAL,rVOID,rWITH,rWHILE);
type classSET=(setSmEn,setBiEn,setSmRu,setBiRu);
const loREZ=rADDR; hiREZ=rWHILE;
type arrREZ=array[classSET]of array[classREZ]of pstr;
const nameREZ=arrREZ{
              {'',
               'addr','and','array','ascii','asm','begin','bitmap','break','case','class','const','control',
               'dec','define','default','definition','dialog','div','do','downto',
               'else','elsif','end','enum','exit','export',
               'false','for','forward','from','function','hibyte','hiword',
               'icon','if','implementation','import','in','inc','include',
               'lobyte','loword','mod','module','new','nil','not','NULL',
               'object','of','offs','or','ord','pointer','private','procedure','protected','program','public',
               'record','repeat','return','set','sizeof','string','strong','struct','switch',
               'then','to','true','trunc','type','typedef',
               'union','unit','unsigned','until','uses','var','virtual','void','with','while'},
              {'',
               'ADDR','AND','ARRAY','ASCII','ASM','BEGIN','BITMAP','BREAK','CASE','CLASS','CONST','CONTROL',
               'DEC','DEFINE','DEFAULT','DEFINITION','DIALOG','DIV','DO','DOWNTO',
               'ELSE','ELSIF','END','ENUM','EXIT','EXPORT',
               'FALSE','FOR','FORWARD','FROM','FUNCTION','HIBYTE','HIWORD',
               'ICON','IF','IMPLEMENTATION','IMPORT','IN','INC','INCLUDE',
               'LOBYTE','LOWORD','MOD','MODULE','NEW','NIL','NOT','NULL',
               'OBJECT','OF','OFFS','OR','ORD','POINTER','PRIVATE','PROCEDURE','PROTECTED','PROGRAM','PUBLIC',
               'RECORD','REPEAT','RETURN','SET','SIZEOF','STRING','STRONG','STRUCT','SWITCH',
               'THEN','TO','TRUE','TRUNC','TYPE','TYPEDEF',
               'UNION','UNIT','UNSIGNED','UNTIL','USES','VAR','VIRTUAL','VOID','WITH','WHILE'},
              {'',
               '���','�','������','ascii','���','������','������','��������','�����','�����','�����','�������',
               '������','�������','�����','�����','������','���','���','����',
               '�����','������','���','��������','�����','�������',
               '����','���','�����','����','�������','������','�������',
               '������','����','������','������','�','����','��������',
               '������','�������','���','������','�����','����','��','����',
               '������','��','����','���','�������','����','���������','���������','����������','���������','���������',
               '������','������','�������','����','����','������','������','������','��������',
               '��','�','������','���','���','������',
               '�����','����','�������','��','������������','���','�������','�����','�','����'},
              {'',
               '���','�','������','ASCII','���','������','������','��������','�����','�����','�����','�������',
               '������','�������','�����','�����','������','���','���','����',
               '�����','������','���','��������','�����','�������',
               '����','���','�����','����','�������','������','�������',
               '������','����','������','������','�','����','��������',
               '������','�������','���','������','�����','����','��','����',
               '������','��','����','���','�������','����','���������','���������','����������','���������','���������',
               '������','������','�������','����','����','������','������','������','��������',
               '��','�','������','���','���','������',
               '�����','����','�������','��','������������','���','�������','�����','�','����'}
               };
var carSet:classSET;

//-------- ���������������� ���� --------------

type
  classTYPE=(typeNULL,
             typeBYTE,typeCHAR,
             typeWORD,
             typeBOOL,typeINT,typeDWORD,
             typePOINT,typePSTR,
             typeSET,
             typeREAL32,
             typeREAL);
const loType=typeBYTE; hiType=typeREAL;
type arrTYPE=array[classLANG]of array[classTYPE]of pstr;
const nameTYPE=arrTYPE{
  {"","byte","char","word","boolean","integer","cardinal","address","pstr","setbyte","real32","real"},
  {"","byte","char","word","bool","int","uint","pvoid","pchar","setbyte","float32","float"},
  {"","byte","char","word","boolean","integer","dword","address","pstr","setbyte","real32","real"}};

//-------- ��������� ������ --------------

type
  classUNDO=(undoNULL,
    undoInsChar,undoDelChar,undoBackChar,
    undoInsStr,undoDelStr,
    undoInsBlock,undoDelBlock);
  arrSetUndo=array[classER]of array[classUNDO]of pstr;

const setUndo=arrSetUndo{{"������ ����������",
    "������ ������� �������\9Ctrl+Backspace","������ �������� �������\9Ctrl+Backspace","������ �������� �������\9Ctrl+Backspace",
    "������ Enter\9Ctrl+Backspace","������ Delete\9Ctrl+Backspace",
    "������ ������� �����\9Ctrl+Backspace","������ �������� �����\9Ctrl+Backspace"},
   {"Undo is impossible",
    "Undo symbol insert\9Ctrl+Backspace","Undo symbol delete\9Ctrl+Backspace","Undo symbol delete\9Ctrl+Backspace",
    "Undo Enter\9Ctrl+Backspace","Undo Delete\9Ctrl+Backspace",
    "Undo text insert\9Ctrl+Backspace","Undo text delete\9Ctrl+Backspace"}};

type
  recUndo=record
    Class:classUNDO;
    undoTxt:integer; //������ �� ��������
    undoExt:integer; //���������� �� ��������
    posX,posY,posTrackX,posTrackY:integer; //������� ������� �� ��������
    blockX,blockY,blockTrackX,blockTrackY:integer; //������� ������� ����� ��������
    undoChar:char; //��������� ������
    undoBlock:pstr; //��������� ����
  end;
  arrUndo=array[1..maxUNDO]of recUndo;

//===============================================
//               ��������� ����
//===============================================

//-------- ���, ���������� ----------

type
  arrCode=array[1..maxCode]of byte;
  arrData=array[1..maxData]of byte;

//------ ������ ������� ������� DLL ------------

type

  arrCALL=array[1..maxImpCALL]of integer; //������ ���������� CALL (����������� dword)
  pCALL=pointer to arrCALL;

  recIMPFUN=record
              funName:pstr;
              funCALL:pCALL;
              funTop:integer;
              funRVA:integer;// RVA � ������� �������
            end;
  arrIMPFUN=array[1..maxImpFun]of recIMPFUN;
  pIMPFUN=pointer to arrIMPFUN;

  recIMPORT=record
              impName:pstr;
              impFuns:pIMPFUN;
              impTop:integer;
            end;
  arrIMPORT=array[1..maxImpDLL]of recIMPORT;
  pIMPORT=pointer to arrIMPORT;

  arrEXPORT=array[1..maxExport]of pstr;
  pEXPORT=pointer to arrEXPORT;

var
  gloImport:pIMPORT;
  gloTop:integer;
  gloExport:pEXPORT;
  gloTopExp:integer;

//===============================================
//            ������ �������� RES
//===============================================

const
  maxStyle=50;
  maxItem=100;
  maxListStyles=1000;
  maxBufClip=60000;
  idDlgBase=1000;
  idDlgBaseNew=1200;
  resDlgIniX=10;
  resDlgIniY=10;

type
//����������
  recRect=record
    x,y:integer;
    dx,dy:integer;
  end;

//����� ������
  arrStyles=array[1..maxStyle]of pstr;
  pStyles=pointer to arrStyles;

//�������������� ��������
  recItem=record
    iText:pstr;
    iClass:pstr;
    iId:pstr;
    iRect:recRect;
    iTop:integer;
    iStyles:pStyles;
    iWnd:HWND;
    iBlock:boolean;
    iFont:pstr;
    iSize:integer;
  end;
  pItem=pointer to recItem;
  arrItem=array[0..maxItem]of pItem; //0-������
  pItems=pointer to arrItem;

//������
  recDialog=record
    dMenu:pstr;
    dTop:integer;
    dItems:pItems;
  end;

//������� ����
type classDlgComm=(cdNULL,cdNew,
  cdEdit,cdEditUndo,cdEditCut,cdEditCopy,cdEditPaste,cdEditDel,cdEditAll,
  cdAlign,cdAlignLeft,cdAlignRight,cdAlignUp,cdAlignDown,cdAlignSizeX,cdAlignSizeY,
  cdParam,cdFont,cdOk,cdCancel);

type arrDlgCommand=array[classER]of array[classDlgComm]of record
  name:pstr;
  numTool:integer;
end;
const setDlgCommand=arrDlgCommand{{{"",0},{"&����� �������",0},
  {"&������",0},{"&��������",1},{"&��������",2},{"&����������",3},{"�&�������",4},{"&�������",5},{"�&������� ���",0},
  {"&������������",0},{"��������� �&����",6},{"��������� �&�����",7},{"��������� �&����",8},{"��������� �&���",9},{"��������� ������ �� &X",10},{"��������� ������ �� &Y",11},
  {"&��������",12},{"&�����",0},{"&��",0},{"�&�����",0}},
  {{"",0},{"&New item",0},
  {"&Edit",0},{"&Undo",1},{"Cu&t",2},{"&Copy",3},{"&Insert",4},{"C&lear",5},{"&Select all",0},
  {"&Alignment",0},{"Align &left",6},{"Align &right",7},{"Align &up",8},{"Align &down",9},{"Align sizes to &X",10},{"Align sizes to &Y",11},
  {"&Options",12},{"&Font",0},{"&Ok",0},{"&Cancel",0}}};

//������� � BMP �������
type
  recMItem=record
    miTxt:pstr;  //����� ��� ���������
    miNam:pstr; //��� �������
    miId:integer; //������������� ��������
    miCla:pstr; //�����
    miSty:integer; //�����
    miX,miY,miCX,miCY:integer; //����������
    miFont:pstr; //���� �������
    miSize:integer; //������ �������
  end;
  pMItem=pointer to recMItem;

  recMDialog=record
    mdTop:integer;
    mdCon:array[0..maxItem]of pMItem;
  end;
  pMDialog=pointer to recMDialog;

  arrDlg=array[1..maxMDlg]of pMDialog;
  pDlgs=pointer to arrDlg;

  recBMP=record
    bmpName:pstr;
    bmpFile:pstr;
    bmpSize:integer;
  end;

  arrBMP=array[1..maxBMP]of recBMP;
  pBMPs=pointer to arrBMP;

//��������� ��������� ��������
type
  arrClassMenu=array[1..maxClassMenu]of pstr;
  pClassMenu=pointer to arrClassMenu;
  recClass=record
    claMenu:string[maxSClass];
    claName:string[maxSClass];
    claStyle:string[maxSClass];
    claIniText:string[maxSClass];
    claIniDX:integer;
    claIniDY:integer;
    claTop:integer;
    claList:arrClassMenu;
  end;
  arrClass=array[1..maxClass]of recClass;
  pClass=pointer to arrClass;

type
  classDlgStatus=(dsTextE,dsClassE,dsIdE,dsXY,dsDXDY);
  arrDlgStatus=array[classDlgStatus]of integer;
const
  resStatusProc=arrDlgStatus{30,20,20,15,15};
  resFinStatus=dsDXDY;

type
  classIniClass=(iniStatic,iniButton,iniEdit,iniListbox,iniCombobox,
    iniScrollbar,iniRichEdit,iniListView,iniTreeView,iniTrackbar,iniProgressbar,iniAnimation,iniUpDown,iniHotKey,
    iniDateTimePick,iniCalendar);
  arrIniClass=array[classER]of array[classIniClass]of recClass;
const lastIniClass=iniCalendar;
const iniClass=arrIniClass{{
  {"�����","Static","SS_","�����",50,15,4,},
  {"������","Button","BS_","������",50,15,6,},
  {"��������","Edit","ES_","",50,15,3,},
  {"������","Listbox","LBS_","",50,60,2,},
  {"�����������","Combobox","CBS_","",50,60,2,},
  {"�������","Scrollbar","SBS_","",30,30,2,},
  {"�������� RTF","RichEdit","ES_","",200,100,1,},
  {"������ ListView","SysListView32","LVS_","",70,100,4,},
  {"������ TreeView","SysTreeView32","TVS_","",70,100,1,},
  {"������ Trackbar","msctls_trackbar32","TBS_","",30,40,2,},
  {"��������� Progressbar","msctls_progress32","","",70,40,1,},
  {"����� Animation","SysAnimate32","ACS_","",200,100,3,},
  {"������ Up-Down","","UDS_","",20,20,2,},
  {"���� ������ Hotkey","msctls_hotkey32","","",50,20,1,},
  {"���� � ����� DateTimePick","SysDateTimePick32","DTS_","",70,15,3,},
  {"���������","SysMonthCal32","MCS_","",100,100,2,}
},{
  {"Text","Static","SS_","Text",50,15,4,},
  {"Button","Button","BS_","Button",50,15,6,},
  {"Editor","Edit","ES_","",50,15,3,},
  {"Listbox","Listbox","LBS_","",50,60,2,},
  {"Combobox","Combobox","CBS_","",50,60,2,},
  {"Scrollbar","Scrollbar","SBS_","",30,30,2,},
  {"RTF Editor","RichEdit","ES_","",200,100,1,},
  {"ListView","SysListView32","LVS_","",70,100,4,},
  {"TreeView","SysTreeView32","TVS_","",70,100,1,},
  {"Trackbar","msctls_trackbar32","TBS_","",30,40,2,},
  {"Progressbar","msctls_progress32","","",70,40,1,},
  {"Animation","SysAnimate32","ACS_","",200,100,3,},
  {"Up-Down","","UDS_","",20,20,2,},
  {"Hotkey","msctls_hotkey32","","",50,20,1,},
  {"DateTimePick","SysDateTimePick32","DTS_","",70,15,3,},
  {"Calendar","SysMonthCal32","MCS_","",100,100,2,}
}};

const maxIniMenu=39;
type arrIniMenu=array[classER]of array[1..maxIniMenu]of pstr;
const iniMenu=arrIniMenu{{
  "����������� �����,WS_CHILD,WS_VISIBLE,SS_LEFT",
  "����������� ������,WS_CHILD,WS_VISIBLE,SS_RIGHT",
  "����������� �� ������,WS_CHILD,WS_VISIBLE,SS_CENTER",
  "������,WS_CHILD,WS_VISIBLE,SS_ICON",

  "�������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_PUSHBUTTON",
  "�������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_DEFPUSHBUTTON",
  "���������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_3STATE",
  "�������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTOCHECKBOX",
  "�����������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTORADIOBUTTON",
  "�����,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_GROUPBOX",

  "������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL",
  "��� ����� ������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_PASSWORD",
  "�������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_MULTILINE",

  "�������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY",
  "���������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY,LBS_MULTICOLUMN",

  "�������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_SIMPLE",
  "��������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_DROPDOWN",

  "������������,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_VERT",
  "��������������,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_HORZ",

  "�������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_MULTILINE,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_NOHIDESEL,ES_SAVESEL,ES_SUNKEN",

  "��������� �����,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_REPORT",
  "��������� ������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_SMALLICON,LVS_EDITLABELS",
  "��������� ������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_SMALLICON,LVS_EDITLABELS",
  "������ � ��������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_LIST,LVS_EDITLABELS",

  "�������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TVS_HASLINES,TVS_HASBUTTONS,TVS_LINESATROOT",

  "��������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_BOTTOM",
  "������������,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_LEFT",

  "�������,WS_CHILD,WS_VISIBLE,WS_BORDER",

  "�������,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER",
  "����������,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT",
  "�������,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT,ACS_AUTOPLAY",

  "�������,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS",
  "��������������,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS,UDS_HORZ",

  "�������,WS_CHILD,WS_VISIBLE",

  "����,WS_BORDER,WS_CHILD,WS_VISIBLE",
  "���� �������,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_LONGDATEFORMAT",
  "�����,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_TIMEFORMAT",

  "�������,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE",
  "������������� �����,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE,MCS_MULTISELECT"
},{
  "Align to left,WS_CHILD,WS_VISIBLE,SS_LEFT",
  "Align to right,WS_CHILD,WS_VISIBLE,SS_RIGHT",
  "Align to center,WS_CHILD,WS_VISIBLE,SS_CENTER",
  "Icon,WS_CHILD,WS_VISIBLE,SS_ICON",

  "Pushbutton,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_PUSHBUTTON",
  "Defpushbutton,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_DEFPUSHBUTTON",
  "3State,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_3STATE",
  "Checkbox,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTOCHECKBOX",
  "Radiobutton,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_AUTORADIOBUTTON",
  "Groupbox,WS_CHILD,WS_VISIBLE,WS_TABSTOP,BS_GROUPBOX",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL",
  "Password,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_PASSWORD",
  "Multiline,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_MULTILINE",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY",
  "Multicolumn,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LBS_NOTIFY,LBS_MULTICOLUMN",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_SIMPLE",
  "Dropdown,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,CBS_DROPDOWN",

  "Vertical,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_VERT",
  "Horizontal,WS_CHILD,WS_VISIBLE,WS_BORDER,SBS_HORZ",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,ES_MULTILINE,ES_AUTOHSCROLL,ES_AUTOVSCROLL,ES_NOHIDESEL,ES_SAVESEL,ES_SUNKEN",

  "Report,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_REPORT",
  "SmallIcons,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_SMALLICON,LVS_EDITLABELS",
  "Icons,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_ICON,LVS_EDITLABELS",
  "List,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,LVS_LIST,LVS_EDITLABELS",

  "Standard,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TVS_HASLINES,TVS_HASBUTTONS,TVS_LINESATROOT",

  "Horizontal,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_BOTTOM",
  "Vertical,WS_CHILD,WS_VISIBLE,WS_TABSTOP,WS_BORDER,TBS_HORZ,TBS_LEFT",

  "Standard,WS_CHILD,WS_VISIBLE,WS_BORDER",

  "Simple,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER",
  "Transparent,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT",
  "Autoplay,WS_CHILD,WS_VISIBLE,WS_BORDER,ACS_CENTER,ACS_TRANSPARENT,ACS_AUTOPLAY",

  "Standard,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS",
  "Horizontal,WS_CHILD,WS_VISIBLE,WS_BORDER,UDS_WRAP,UDS_ARROWKEYS,UDS_ALIGNRIGHT,UDS_SETBUDDYINT,UDS_NOTHOUSANDS,UDS_HORZ",

  "Standard,WS_CHILD,WS_VISIBLE",

  "Date,WS_BORDER,WS_CHILD,WS_VISIBLE",
  "Date long,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_LONGDATEFORMAT",
  "Time,WS_BORDER,WS_CHILD,WS_VISIBLE,DTS_TIMEFORMAT",

  "Standard,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE",
  "Multiselect,WS_BORDER,WS_CHILD,WS_VISIBLE,MCS_DAYSTATE,MCS_MULTISELECT"
}};

//--------- ������ ������ �� Win32.i ------------

type
  arrListStyles=array[1..maxListStyles]of pstr;
  pListStyles=pointer to arrListStyles;

//--------- ���������� ��������� �������� ------------

var
  resClasses:pClass; //���������������� ������
  resTopClass:integer;
  resCarClass:integer;
  resDlg:recDialog; //������������� ������
  resDlgWnd:integer; //���� ��������� ��������
  resDlgItem:integer; //������� ���������� �������
  resDlgFocus:HWND; //������� ������ ������
  resStatus:HWND; //������-������ ��������� ��������
  resStyles:pListStyles; //����� �� ����� Win32.i
  resTopStyles:integer;
  wndToolDlg:HWND; //���� ������� ������������

var
  ����������X:integer; //��������� ���������� �����
  ����������Y:integer;
  ���������X:integer; //������� ���������� ����
  ���������Y:integer;

  ����������:(��������,���������,����������,���������,����������);
  �������������:boolean;
  �������������:string[maxText];
  ������������:cardinal;
  �������������:char;

  ��������:array[1..maxResUndo]of pstr;
  ������������:integer;

  �����������������:boolean;
  ����������������:boolean;
  ������������������:boolean;
  �����������������:boolean;

//------------------------- ���������� ���������� -----------------------------

type
  classStep=(stepNULL,
    stepSimple,
    stepCALL,stepRETURN,
    stepIF,stepVarIF,stepEndIF,
    stepCASE,stepVarCASE,stepEndCASE,
    stepFOR,stepBegFOR,stepModFOR,stepEndFOR,
    stepWHILE,stepBegWHILE,stepModWHILE,stepEndWHILE,
    stepREPEAT,stepModREPEAT,stepEndREPEAT);

  arrStep=array[1..maxStep]of record
    Class:classStep;
    source:integer; //��� � genCode
    line:word; //����� ������ � ������
    frag:word; //����� ��������� � ������
    level:byte; //topStack
    proc:address; //��������� � stepCALL
  end;

var
  stepStack:array[1..maxStackStep]of record
    Class:classStep;
    parent:integer;
  end;
  stepTopStack:integer;

  stepActive:array[1..maxStepActive]of record
    nom:integer; //� tbMod
    ind:integer; //� genStep
    buf:pstr; //����� ������
  end;
  stepTopActive:integer;

  stepDebugged:boolean;
  stepTimer:HANDLE;
  stepProcess:HANDLE;
  stepThread:HANDLE;
  stepProcessId:HANDLE;
  stepThreadId:HANDLE;

  stepWnd:HWND;
  identWnd:HWND;
  stepLastWnd:HWND;
  stepLastLine:integer;
  stepHexdec:boolean;
  stepErrorRead:boolean;

  stepCarNom:integer;
  stepCarInd:integer;

//===============================================
//             ������� ���������������
//===============================================

//--------- ������ ��������������� ------------

type
  classID=(idNULL,
           idcCHAR,idcINT,idcSCAL,//����� ���������
           idcREAL, //������������ ���������
           idcSTR,//������
           idcSET,//���������
           idcSTRU, //����������� ���������
           idtBAS,idtARR,idtREC,idtPOI,idtSET,idtSCAL,//����
           idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR,//����������
           idPROC,//���������
           idMODULE,//������
           idREZ);//����������������� �����

const idBeg=idcCHAR; idEnd=idREZ; //����� ���� ���������������

type
  classTab=(tabMods,tabMod,tabLoc,tabWith);
  classSub=(subNULL,subTYPE,subPROC,subMETHOD,subFIELD,subLOC,subPAR);
  classPRO=(proNULL,proPUBLIC,proPROTECTED,proPRIVATE,proPRIVATE_IMP);
  pID=pointer to recID;
  arrLIST=array[1..maxLIST]of pID;
  arrName=array[1..maxLIST]of pstr;
  arrSubs=array[1..maxSubs]of pID;
  pLIST=pointer to arrLIST;
  pName=pointer to arrName;
  pSubs=pointer to arrSubs;

  recID=record
    idName:pstr;
    idLeft:pID;
    idRight:pID;
    idOwn:pID;
    idTab:classTab;
    idNom:byte; //����� ������
    idActiv:byte; //������������� �������
    idH:byte; //������������� ��������� � def-�����
    idSou:integer; //������� ����� �������
    idPro:classPRO; //������������
    idtSize:integer;
    idClass:classID;
    case of
      | idInt:integer; //idcCHAR,idcINT
      | idReal:real; //idcREAL
      | idStr:pstr; idStrAddr:integer; //idcSTR
      | idStruType:pID; idStruAddr:integer; //idcSTRU
      | idSet:pointer to setbyte; //idcSET
      | idScalVal:integer; idScalType:pID; //idcSCAL

      | idBasNom:classTYPE; //idtBAS
      | idArrItem,idArrInd:pID; extArrBeg,extArrEnd:integer; //idtARR
      | idRecList:pLIST; idRecMax:integer; //idtREC
        idRecCla:pID; idRecMet:pLIST; idRecTop:integer;
      | idPoiType:pID; idPoiBitForward:boolean; idPoiPred:pstr; //idtPOI
      | idSetType:pID; //idtSET
      | idScalList:pLIST; idScalMax:integer; //idtSCAL

      | idVarType:pID; idVarAddr:integer; //idvFIELD,idvPAR,idvVAR,idvLOC,idvVPAR

      | idProcList:pLIST; idProcMax:integer; //idPROC
        idLocList:pLIST; idLocMax:integer;
        idProcAddr,idProcPar,idProcLock,idProcCode:integer;
        idProcASCII:boolean;
        idProcDLL:pstr;
        idProcType,idProcCla:pID;

      | idModNom:integer; //idMODULE
      | idRezVal:classREZ; //idREZ
  end;

//----- ������ call � var call ---------------

type
  lstCall=record
    top:integer;
    arr:array[1..maxCall]of record
      callSou:integer;
      callProc:pID;
    end;
  end;

  classVarCall=(vcCode,vcData,vcAddr,vcNew);
  arrVarCall=array[1..maxVarCall]of record
    track:integer; //����� � genCode(genData) �������� ������
    no:byte; //����� ������ genData
    cla:pstr; //��� ������ ��� vcNew
    cl:classVarCall;
      //vcCode - track � genCode(+genBegData)
      //vcData - track � genData(+genBegData)
      //vcAddr - track � genCode(+genBegCode)
      //vcNew - track � genCode(+genBegCode)
  end;

  arrProCall=array[1..maxProCall]of record
    track:integer; //����� call � genCode �������� ������
    sou:pstr; //��� ���������
    mo:pstr; //��� ������
  end;

//------- ������� ��������������� --------------

var
  tbMod:array[1..maxMod]of record //������
    modNam:pstr; //��� ������
    modTab:pID; //�� ������
    modTxt:integer; //����� ������ � txts
    modAct:boolean; //������ ������� � ������� ����������
    modSbs:array[classSub]of pSubs; //������� ������ ������ ��
    modTop:array[classSub]of integer;
    modComp:boolean; //����� ������ ������������
    modMain:boolean; //exe (dll) ������

    modDlg:pDlgs; topMDlg:integer;
    modBMP:pBMPs; topBMP:integer;
    modICON:pstr;

    genBegCode:integer;
    genBegData:integer;
    genCode:pointer to arrCode; topCode:integer;
    genData:pointer to arrData; topData:integer;
    genImport:pIMPORT; topImport:integer;
    genExport:pEXPORT; topExport:integer;
    genVarCall:pointer to arrVarCall; topVarCall:integer;
    genProCall:pointer to arrProCall; topProCall:integer;

    genStep:pointer to arrStep; topGenStep:integer;
  end;
  topMod:integer;

  tbModImp:array[1..maxMod]of pstr; //����� ������������� �������
  topModImp:integer;

  tbWith:array[1..maxWith]of pID; //���� with
  topWith:integer;
  withGlo:integer; //�������� ��������� idFindGlo

  idTYPE:array[classTYPE]of pID;

//-------------- ������ ����� -----------------

type
  arrSTRING=array[1..maxSTRING]of record
    stringSou:integer;
    stringPoi:pstr;
  end;
  pSTRING=pointer to arrSTRING;

var
  genSTRING:pSTRING;
  topSTRING:integer;

//===============================================
//             ����������� ������
//===============================================

//------------- ������� ����� -----------------

//������ ������
type
  classLex=(lexNULL,
    lexEOF,   //����� �����
    lexCHAR,   //������ ��� ��� �����.: 'a',10C(�����������),13�(����������)
    lexINT,    //����� ����� FFFFFFFFh ��� ��� �����.: 12,F90h,F90H,01110b,01110B
    lexREAL,   //������������ ��� ��� �����.: 31., 31.02, .87, 43.2e10, .12E-4
    lexSTR,    //������ ��� �� �����.: "a", 'abc', "ab'cd"
    lexSTRU,   //����������� ���������
    lexSET,    //������������� ���������-���������
    lexNIL,    //��������� NIL (NULL) ��� �� �����.:�������� ���������
    lexFALSE,  //��������� FALSE ��� �� �����.:�������� ���������
    lexTRUE,   //��������� TRUE ��� �� �����.:�������� ���������
    lexID,     //����� ������������� (� �.�.�����������������)
    lexNEW,    //����� �������������
    lexSCAL,   //������������� ��������� ���������� ����
    lexREZ,    //����������������� �������������
    lexASM,    //������� ����������
    lexREG,    //������� ����������
    lexPARSE,  //�����������
    lexTYPE,   //��� ����
    lexFIELD,  //��� ���� ������
    lexVAR,    //��� ���������� ����������
    lexLOC,    //��� ��������� ����������
    lexPAR,    //��� ��������� ��� ��������� ����������
    lexVPAR,   //��� ��������� ������ VAR
    lexPROC,   //��� ���������
    lexCOMM,   //�����������
    lexMOD     //��� ������
    );
  const setID=[lexNEW,lexSCAL,lexTYPE,lexVAR,lexLOC,lexPAR,lexVPAR,lexFIELD,lexPROC,lexMOD,lexSTR,lexSTRU,lexID];

//{����� ������}
  type arrLex=array[classLex]of pstr;
  const nameLex=arrLex{
                 '���������',
                 '����� �����',
                 '������',
                 '�����',
                 '������������',
                 '������',
                 '����������� ���������',
                 '���������',
                 '��������� NIL',
                 '��������� FALSE',
                 '��������� TRUE',
                 '���',
                 '����� ���',
                 '������',
                 '����������������� ���',
                 '������� ����������',
                 '������� ����������',
                 '�����������',
                 '��� ����',
                 '��� ���� ������',
                 '��� ���������� ����������',
                 '��� ��������� ����������',
                 '��� ���������',
                 '��� ��������� VAR',
                 '��� ���������',
                 '�����������',
                 '��� ������'};

type
//{������� ������� � ������}
  recPos=record
    y:integer; //{����� ������}
    f:integer; //{����� ���������}
  end;

//{������� �����}
  recStream=record
    stFile:string[maxText]; //��� �����
    stPosLex:recPos; //������� ��������� ������
    stPosPred:recPos; //���������� ������� ��������� ������
    stLex:classLex; //������� �������
    stLexID:pID; //�������-�������������
    stLexInt:integer; //�������� ������� �������:
                             //lexCHAR,lexINT,lexREZ,
                             //lexNIL,lexFALSE,lexTRUE,
                             //lexSTRUCT,
                             //lexONE,lexDOUBLE,
                             //lexTYPE,lexVAR,lexPAR,lexVPAR,lexFIELD,lexPROC
    stLexStr:string[maxText]; //�������� ������� ������� lexSTR,lexID,lexNEW
    stLexOld:string[maxText]; //���������� �������� stLexStr
    stLexSet:setbyte; //�������� ������� lexSET
    stLexReal:real; //�������� ������� lexREAL
    stErr:boolean; //������� ������
    stErrPos:recPos; //������� ������
    stErrText:string[maxText]; //����� ������
    stErrExt:integer; //����� IMP/DEF ������
    stLoad:boolean; //������� �������� ������ ��� �������� ������
    stTxt:integer; //����� �������������� ������
    stExt:integer; //����� IMP/DEF
  end;

//���� ������������ ���������
type
  classConOp=(conNULL,conAdd,conSub,conMul,conDiv,conMod,conOr,conAnd);

type arrConOp=array[classConOp]of classPARSE;
const lexConOp=arrConOp{pNULL,pPlu,pMin,pMul,pDiv,pPro,pVer,pAmp};

type
  recConExp=record
    conOp:classConOp;
    conLex:classLex;
    case of
      | conInt:integer; //lexINT
      | conReal:real; //lexREAL
      | conStr:pstr; //lexSTR
      | conChar:char; //lexCHAR
  end;

var
  lexStackCon:array[1..maxStackCon]of recConExp;
  topStackCon:integer;
  lexBitConst:boolean; //{������ ������������ ���������}

//===============================================
//                ��������� ����
//===============================================

//----------------- �������� ------------------

type classRegister=(regNULL,
                          rEAX,rEBX,rECX,rEDX,
                          rAX,rBX,rCX,rDX,rSP,rBP,rSI,rDI,
                          rAL,rBL,rCL,rDL,
                          rAH,rBH,rCH,rDH,
                          rESP,rEBP,rESI,rEDI,
                          rCS,rSS,rDS,rES,rFS,rGS,
                          rST0,rST1,rST2,rST3,rST4,rST5,rST6,rST7);
type arrRegs=array[classRegister]of record
        rNa:pstr;
        rCo:byte;
      end;
const asmRegs=arrRegs{
  {'',0},
  {'EAX',0},{'EBX',3},{'ECX',1},{'EDX',2},
  {'AX',0},{'BX',3},{'CX',1},{'DX',2},{'SP',4},{'BP',5},{'SI',6},{'DI',7},
  {'AL',0},{'BL',3},{'CL',1},{'DL',2},
  {'AH',4},{'BH',7},{'CH',5},{'DH',6},
  {'ESP',4},{'EBP',5},{'ESI',6},{'EDI',7},
  {'CS',1},{'SS',2},{'DS',3},{'ES',0},{'FS',4},{'GS',5},
  {'ST0',0},{'ST1',1},{'ST2',2},{'ST3',3},
  {'ST4',4},{'ST5',5},{'ST6',6},{'ST7',7}};

type classOperand=(oNULL,oE, //�������
                         oS, //���������� �������
                         oM, //������
                         oD); //���������

//----------------- ������� -------------------

type  classCommand=(cNULL,
  //����� RM/RD
       cADD,cSUB,cADC,cSBB,cAND,cOR,cXOR,
       cCMP,cTEST,cMOV,cLEA,cLDS,cLES,cXCHG,
       cBT,cBTC,cBTR,cBTS,
  //����� FM
       cFLD,cFST,cFSTP,cFCOM,cFCOMP,cFADD,cFSUB,cFSUBR,
       cFMUL,cFDIV,cFDIVR,
  //����� FIM
       cFILD,cFIST,cFISTP,cFICOM,cFICOMP,cFIADD,cFISUB,
       cFISUBR,cFIMUL,cFIDIV,cFIDIVR,cFBLD,cFBSTP,
  //����� FM
       cFSTENV,cFLDENV,cFLDCW,cFSTCW,cFSTSW,cFSAVE,cFRSTOR,
  //����� FR
       cFXCH,cFADDP,cFSUBP,cFSUBRP,cFMULP,cFDIVP,cFDIVRP,
       cFFREE,
  //����� F
       cFLDZ,cFLD1,cFLDPI,cFLDL2T,cFLDL2E,cFLDLG2,cFLDLN2,
       cFCOMPP,cFTST,cFXAM,cFSQRT,cFSCALE,cFPREM,cFRNDINT,
       cFXTRACT,cFABS,cFCHS,cFPTAN,cFPATAN,cF2FM1,cFYL2X,
       cFYL2XP1,cFINIT,cFENT,cFDISI,cFCLEX,cFINCSTP,
       cFDECSTP,cFNOP,
  //����� ROL
       cRCL,cRCR,cROL,cROR,cSAL,cSAR,cSHL,cSHR,
  //����� RM
       cMUL,cDIV,cIMUL,cIDIV,cINC,cDEC,cNEG,cNOT,
       cPOP,cPUSH,
  //����� L
       cJMP,cJCXZ,cLOOPE,cLOOPNE,cLOOP,
       cJL,cJLE,cJG,cJGE,cJE,cJNE,
       cJA,cJAE,cJB,cJBE,cJZ,cJNZ,
       cJC,cJO,cJP,cJS,cJNC,cJNO,cJNP,cJNS,cJPO,cJPE,
  //����� OTHER
       cIN,cOUT,cINT,cAAD,cAAM,
       cCALL,cCALLF,cRET,
  //����� NULL
       cCMPS,cMOVS,cSTOS,cSCAS,cLODS,
       cCLC,cCLD,cCLI,cSTC,cSTD,cSTI,cCMC,
       cAAA,cAAS,cDAA,cDAS,cHLT,cINT0,cINT3,cIRET,
       cREP,cREPE,cREPNE,cENTER,cLEAVE,
       cLAHF,cSAHF,cPOPF,cPUSHF,cNOP,cWAIT,cXLAT,cCBW,cCWD);

type arrCommands=array[classCommand]of record
    cNam:pstr;
    cPri:byte;  //�������� �������: 1-w,2-d,4-dat,8-ext
    cCod:byte;  //��� ������� ����� (������� mr)
    cDat:byte;  //��� ������� ����� (������� md)
    cExt:byte;  //��� ����������    (������� md)
  end;
const asmCommands=arrCommands{
{'',0x00,0x00,0x00,0x00},

{'ADD' ,0x0F,0x00,0x80,0x00},
{'SUB' ,0x0F,0x28,0x80,0x28},
{'ADC' ,0x0F,0x10,0x80,0x10},
{'SBB' ,0x0F,0x18,0x80,0x18},
{'AND' ,0x0F,0x20,0x80,0x20},
{'OR'  ,0x0F,0x08,0x80,0x08},
{'XOR' ,0x0F,0x30,0x80,0x30},
{'CMP' ,0x0F,0x38,0x80,0x38},
{'TEST',0x0D,0x84,0xF6,0x00},
{'MOV' ,0x0F,0x88,0xC6,0x00},
{'LEA' ,0x00,0x8D,0x00,0x00},
{'LDS' ,0x00,0xC5,0x00,0x00},
{'LES' ,0x00,0xC4,0x00,0x00},
{'XCHG',0x01,0x86,0x00,0x00},
{'BT' ,0x0C,0xA3,0xBA,0x20},
{'BTC',0x0C,0xBB,0xBA,0x38},
{'BTR',0x0C,0xB3,0xBA,0x30},
{'BTS',0x0C,0xAB,0xBA,0x28},

{'FLD'  ,0x0C,0xDD,0x20,0x00},
{'FST'  ,0x0C,0xDD,0xA2,0x10},
{'FSTP' ,0x0C,0xDD,0xA3,0x18},
{'FCOM' ,0x0C,0xDC,0x02,0x10},
{'FCOMP',0x0C,0xDC,0x03,0x18},
{'FADD' ,0x0C,0xDC,0x00,0x00},
{'FSUB' ,0x0C,0xDC,0x04,0x20},
{'FSUBR',0x0C,0xDC,0x05,0x28},
{'FMUL' ,0x0C,0xDC,0x01,0x08},
{'FDIV' ,0x0C,0xDC,0x06,0x30},
{'FDIVR',0x0C,0xDC,0x07,0x38},

{'FILD'  ,0x08,0xDB,0x00,0x00},
{'FIST'  ,0x08,0xDB,0x00,0x10},
{'FISTP' ,0x08,0xDB,0x00,0x18},
{'FICOM' ,0x08,0xDA,0x00,0x10},
{'FICOMP',0x08,0xDA,0x00,0x18},
{'FIADD' ,0x08,0xDA,0x00,0x00},
{'FISUB' ,0x08,0xDA,0x00,0x20},
{'FISUBR',0x08,0xDA,0x00,0x28},
{'FIMUL' ,0x08,0xDA,0x00,0x08},
{'FIDIV' ,0x08,0xDA,0x00,0x30},
{'FIDIVR',0x08,0xDA,0x00,0x38},
{'FBLD'  ,0x08,0xDF,0x00,0x20},
{'FBSTP' ,0x08,0xDF,0x00,0x30},

{'FSTENV',0x08,0xD9,0x00,0x30},
{'FLDENV',0x08,0xD9,0x00,0x20},
{'FLDCW' ,0x08,0xD9,0x00,0x28},
{'FSTCW' ,0x08,0xD9,0x00,0x38},
{'FSTSW' ,0x08,0xDD,0x00,0x38},
{'FSAVE' ,0x08,0xDD,0x00,0x30},
{'FRSTOR',0x08,0xDD,0x00,0x20},

{'FXCH'  ,0x04,0x01,0x02,0x00},
{'FADDP' ,0x04,0x00,0xC0,0x00},
{'FSUBP' ,0x04,0x01,0xC5,0x00},
{'FSUBRP',0x04,0x01,0xC4,0x00},
{'FMULP' ,0x04,0x01,0xC1,0x00},
{'FDIVP' ,0x04,0x01,0xC7,0x00},
{'FDIVRP',0x04,0x01,0xC6,0x00},
{'FFREE' ,0x04,0xDD,0xC0,0x00},

{'FLDZ'   ,0x04,0xD9,0xEE,0x00},
{'FLD1'   ,0x04,0xD9,0xE8,0x00},
{'FLDPI'  ,0x04,0xD9,0xEB,0x00},
{'FLDL2T' ,0x04,0xD9,0xE9,0x00},
{'FLDL2E' ,0x04,0xD9,0xEA,0x00},
{'FLDLG2' ,0x04,0xD9,0xEC,0x00},
{'FLDLN2' ,0x04,0xD9,0xED,0x00},
{'FCOMPP' ,0x04,0xDE,0xD9,0x00},
{'FTST'   ,0x04,0xD9,0xE4,0x00},
{'FXAM'   ,0x04,0xD9,0xE5,0x00},
{'FSQRT'  ,0x04,0xD9,0xFA,0x00},
{'FSCALE' ,0x04,0xD9,0xFD,0x00},
{'FPREM'  ,0x04,0xD9,0xF8,0x00},
{'FRNDINT',0x04,0xD9,0xFC,0x00},
{'FXTRACT',0x04,0xD9,0xF4,0x00},
{'FABS'   ,0x04,0xD9,0xE1,0x00},
{'FCHS'   ,0x04,0xD9,0xE0,0x00},
{'FPTAN'  ,0x04,0xD9,0xF2,0x00},
{'FPATAN' ,0x04,0xD9,0xF3,0x00},
{'F2XM1'  ,0x04,0xD9,0xF0,0x00},
{'FYL2X'  ,0x04,0xD9,0xF1,0x00},
{'FYL2XP1',0x04,0xD9,0xF9,0x00},
{'FINIT'  ,0x04,0xDB,0xE3,0x00},
{'FENI'   ,0x04,0xDB,0xE0,0x00},
{'FDISI'  ,0x04,0xDB,0xE1,0x00},
{'FCLEX'  ,0x04,0xDB,0xE2,0x00},
{'FINCSTP',0x04,0xD9,0xF7,0x00},
{'FDECSTP',0x04,0xD9,0xF6,0x00},
{'FNOP'   ,0x04,0xD9,0xD0,0x00},

{'RCL',0x0D,0xD2,0xD0,0x10},
{'RCR',0x0D,0xD2,0xD0,0x18},
{'ROL',0x0D,0xD2,0xD0,0x00},
{'ROR',0x0D,0xD2,0xD0,0x08},
{'SAL',0x0D,0xD2,0xD0,0x20},
{'SAR',0x0D,0xD2,0xD0,0x38},
{'SHL',0x0D,0xD2,0xD0,0x20},
{'SHR',0x0D,0xD2,0xD0,0x28},

{'MUL'  ,0x09,0xF6,0x00,0x20},
{'DIV'  ,0x09,0xF6,0x00,0x30},
{'IMUL' ,0x09,0xF6,0x00,0x28},
{'IDIV' ,0x09,0xF6,0x00,0x38},
{'INC'  ,0x09,0xFE,0x00,0x00},
{'DEC'  ,0x09,0xFE,0x00,0x08},
{'NEG'  ,0x09,0xF6,0x00,0x18},
{'NOT'  ,0x09,0xF6,0x00,0x10},
{'POP'  ,0x08,0x8F,0x00,0x00},
{'PUSH' ,0x0C,0xFF,0x68,0x30},

{'JMP'   ,0x00,0xE9,0x00,0x00},
{'JCXZ'  ,0x00,0xE3,0x00,0x00},
{'LOOPE' ,0x00,0xE1,0x00,0x00},
{'LOOPNE',0x00,0xE0,0x00,0x00},
{'LOOP'  ,0x00,0xE2,0x00,0x00},

{'JL'    ,0x00,0x8C,0x00,0x00},
{'JLE'   ,0x00,0x8E,0x00,0x00},
{'JG'    ,0x00,0x8F,0x00,0x00},
{'JGE'   ,0x00,0x8D,0x00,0x00},
{'JE'    ,0x00,0x84,0x00,0x00},
{'JNE'   ,0x00,0x85,0x00,0x00},
{'JA'    ,0x00,0x87,0x00,0x00},
{'JAE'   ,0x00,0x83,0x00,0x00},
{'JB'    ,0x00,0x82,0x00,0x00},
{'JBE'   ,0x00,0x86,0x00,0x00},
{'JZ'    ,0x00,0x84,0x00,0x00},
{'JNZ'   ,0x00,0x85,0x00,0x00},
{'JC'    ,0x00,0x82,0x00,0x00},
{'JO'    ,0x00,0x80,0x00,0x00},
{'JP'    ,0x00,0x8A,0x00,0x00},
{'JS'    ,0x00,0x88,0x00,0x00},
{'JNC'   ,0x00,0x83,0x00,0x00},
{'JNO'   ,0x00,0x81,0x00,0x00},
{'JNP'   ,0x00,0x8B,0x00,0x00},
{'JNS'   ,0x00,0x89,0x00,0x00},
{'JPO'   ,0x00,0x8B,0x00,0x00},
{'JPE'   ,0x00,0x8A,0x00,0x00},

{'IN'   ,0x05,0xE4,0xEC,0x00},
{'OUT'  ,0x05,0xE6,0xEE,0x00},
{'INT'  ,0x00,0xCD,0xCD,0x00},
{'AAD'  ,0x04,0xD5,0x0A,0x00},
{'AAM'  ,0x04,0xD4,0x0A,0x00},
{'CALL' ,0x00,0xE8,0x00,0x00},
{'CALLF',0x08,0xFF,0x00,0x10},
{'RET'  ,0x00,0xC3,0xC2,0x00},

{'CMPS',0x01,0xA6,0x00,0x00},
{'MOVS',0x01,0xA4,0x00,0x00},
{'STOS',0x01,0xAA,0x00,0x00},
{'SCAS',0x01,0xAE,0x00,0x00},
{'LODS',0x01,0xAC,0x00,0x00},

{'CLC',0x00,0xF8,0x00,0x00},
{'CLD',0x00,0xFC,0x00,0x00},
{'CLI',0x00,0xFA,0x00,0x00},
{'STC',0x00,0xF9,0x00,0x00},
{'STD',0x00,0xFD,0x00,0x00},
{'STI',0x00,0xFB,0x00,0x00},
{'CMC',0x00,0xF5,0x00,0x00},

{'AAA',0x00,0x37,0x00,0x00},
{'AAS',0x00,0x3F,0x00,0x00},
{'DAA',0x00,0x27,0x00,0x00},
{'DAS',0x00,0x2F,0x00,0x00},

{'HLT'  ,0x00,0xF4,0x00,0x00},
{'INTO' ,0x00,0xCE,0x00,0x00},
{'INT3' ,0x00,0xCC,0x00,0x00},
{'IRET' ,0x00,0xCF,0x00,0x00},
{'REP'  ,0x00,0xF3,0x00,0x00},
{'REPE' ,0x00,0xF3,0x00,0x00},
{'REPNE',0x00,0xF2,0x00,0x00},
{'ENTER',0x00,0xC8,0x00,0x00},
{'LEAVE',0x00,0xC9,0x00,0x00},
{'LAHF' ,0x00,0x9F,0x00,0x00},
{'SAHF' ,0x00,0x9E,0x00,0x00},
{'POPF' ,0x00,0x9D,0x00,0x00},
{'PUSHF',0x00,0x9C,0x00,0x00},
{'NOP'  ,0x00,0x90,0x00,0x00},
{'WAIT' ,0x00,0x9B,0x00,0x00},
{'XLAT' ,0x00,0xD7,0x00,0x00},
{'CBW'  ,0x00,0x98,0x00,0x00},
{'CWD'  ,0x00,0x99,0x00,0x00}};

const
      loCom=cADD; hiCom=cCWD;
      loMDCom=cADD; hiMDCom=cBTS;
      loFMRCom=cFLD; hiFMRCom=cFDIVR;
      loFIMCom=cFILD; hiFIMCom=cFBSTP;
      loFMCom=cFSTENV; hiFMCom=cFRSTOR;
      loFRCom=cFXCH; hiFRCom=cFFREE;
      loFCom=cFLDZ; hiFCom=cFNOP;
      loRCom=cRCL; hiRCom=cSHR;
      loMCom=cMUL; hiMCom=cPUSH;
      loLCom=cJMP; hiLCom=cJPE;
      loOCom=cIN; hiOCom=cRET;
      loNCom=cCMPS; hiNCom=cCWD;

const setComFsize=[cFLD,cFST,cFSTP,cFCOM,cFCOMP,cFADD,cFSUB,cFSUBR,cFMUL,cFDIV,cFDIVR];

//----------- ������� exe-����� ---------------

type
  classExe=(exeNULL,exeOld,exeHeader,exeSect,exeData,exeIData,exeEData,exeText,exeRsrc,exeDebug);
var
  genPushAX:integer;
  genPushSI:integer;
  genNameModule:string[maxText];
  genStack:integer;

//--------------- ��������� -------------------

type arrOldHeader=array[1..0x100]of byte;
const OldHeader=arrOldHeader{
  0x4D, 0x5A, 0x00, 0x01, 0x05, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x08, 0x00
, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
, 0xBA, 0x10, 0x00, 0x0E, 0x1F, 0xB4, 0x09, 0xCD, 0x21, 0xB8, 0x01, 0x4C, 0xCD, 0x21, 0x90, 0x90
, 0x54, 0x68, 0x69, 0x73, 0x20, 0x70, 0x72, 0x6F, 0x67, 0x72, 0x61, 0x6D, 0x20, 0x72, 0x65, 0x71
, 0x75, 0x69, 0x72, 0x65, 0x73, 0x20, 0x4D, 0x69, 0x63, 0x72, 0x6F, 0x73, 0x6F, 0x66, 0x74, 0x20
, 0x57, 0x69, 0x6E, 0x64, 0x6F, 0x77, 0x73, 0x2E, 0x0D, 0x0A, 0x24, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20};

type
    recWinHeader=record
      signature:array[0..3]of char; //PE00
      machine:word; //$14C
      numSection:word; //4
      TimeDateStamp:integer; //����.,$073924CA
      begSymbolTable:integer; //0
      numSymbolTable:integer; //0
      sizeOptionHeader:word; //$00E0
      flags:word; //$818E

      magic:word; //$010B
      linkerVersion:word; //$1902
      sizeOfCode:integer; //TopCode (��������� ����� �� $1000)
      sizeOfIniData:integer; //TopData (�����)
      sizeOfUnIniData:integer; //0
      entryPoint:integer; //$1000+�������� ����� �����
      baseOfCode:integer; //$1000 (RVA ������ .text)
      baseOfData:integer; //$1000 (RVA ������ .data)
      imageBase:integer; //$400000
      sectionAlgnment :integer; //$1000
      fileAlgnment:integer; //$200
      osVersion:integer; //1
      imageVersion:integer; //0
      subsystVersion:integer; //$000A0003
      reserved1:integer; //0
      sizeofImage:integer; //RVA ��������� ������+�� ������-RVA ������ ������
      sizeofHeaders:integer; //������ ��������� � ������� ������ (� proba - $400)
      checkSum:integer; //0
      subSystem:word;    //3
      dllFlags:word;    //0
      stackReserve:integer; //$100000
      stackCommit:integer; //$2000
      heapReserve:integer; //$100000
      heapCommit:integer; //$1000
      loaderFlags:integer; //0
      numRvaAndSizes:integer; //16
      dirs:array[0..15]of record
        //0-������� (proba:$10000,$CA)
        //1-������  (proba:$F000,$4C4)
        virtualAddress:integer;
        vsize:integer;
      end;
    end;

var WinHeader:recWinHeader;

type arrSection=array[exeData..exeDebug]of record
      name:array[0..7]of char; //��� ������
      virtualSize:integer; //������ ������ (������ ��������)
      virtualAddress:integer; //RVA ������ ($1000 ��� .text � �.�.)
      sizeofRawData:integer; //������ ������ (��������� �� $200)
      pointerRawData:integer; //����� ������ (�� ������ �����)
      pointerReloc:integer; //0
      pointerLineNum:integer; //0
      numReloc:word; //0
      numLineNum:word; //0
      flags:integer;
        //.text :$60000020
        //.data :$C0000040
        //.idata:$40000040
        //.edata:$40000040
        //.rsrc :$40000040
        //.debug :$40000040
    end;
var tbSection:arrSection;

//------------ ������ ������� -----------------

type
  imageImportDesctriptor=record
    origFirstThunk:integer; //0
    timeDateStump:integer; //0
    forwardChain:integer; //0
    name:integer; //RVA �����-����� ����� DLL
    FirstThunk:integer; //RVA ������� ���������� �� ���.�������
  end;
  //������ Thunk ������� �� RVA ���������� (zeroend)
  //������ ��������� �� 0,0,��� ������� zeroend
  //�������� �� ������� Thunk (�� RVA-������
  //������ ������������ � ������� CALL PTR[]

//----------- ������ �������� -----------------

type
  imageExportDesctriptor=record
    Characteristics:integer; //0
    TimeDateStump:integer; //0
    MajorVersion:word; //0
    MinorVersion:word; //0
    Name:integer; //RVA ������ � ������ ����� DLL
    Base:integer; //1
    NumberOfFunctions:integer; //gloTopExp
    NumberOfNames:integer; //gloTopExp
    AddressOfFunctions:integer; //RVA ������� ����� �����
    AddressOfNames:integer; //RVA ������� ���������� �� �����
    AddressOfNameOrdinals:integer; //RVA ������� ���� (������� ��������) �� 1 �� gloTopExp
  end;

//----- ������ ��������� ---------------

type
  lstJamp=record
    top:integer;
    arr:array[1..maxJamp]of record
      jaddr:integer;
      jcomm:classCommand;
    end;
  end;

//----- ��������� ������ �������� -------------

type
  recSortRes=record
    resDLG:boolean;
    resMod:integer;
    resNom:integer;
    s:pstr;
  end;
  arrSortRes=array[1..maxRes]of recSortRes;

  image_resource_directory=record
    Characteristics:integer; //{0}
    TimeDateStamp:integer; //{���� � �����}
    Version:integer; //{4}
    NumberOfNamedEntries:word; //{1 (������ �������)}
    NumberOfIdEntries:word; //{0}
  end;
  image_resource_directory_entry=record
    Name:integer;
    OffsetToData:integer;
  end;
  image_resource_data_entry=record
    RVA:integer;
    Size:integer;
    CodePage:integer;
    Rezerved:integer;
  end;
  res_icon=record
    irReserved:word; //0
    irType:word; //1
    irCount:word; //1
    bWight:byte; //32
    bHeight:byte; //32
    bColorCount:byte; //16
    bReserved:byte; //0
    wReserved1:word; //1
    wReserved2:word; //4
    dwBytesInRes:cardinal; //2e8
    wOriginalNumber:word; //1
  end;

type arrClasses=array[1..maxClasses]of record
  claBas:pID;
  claList:pLIST;
  claListTop:integer;
  claName:pName;
  claNameTop:integer;
  claAddr:pLIST;
end;
type pClasses=pointer to arrClasses;

var
  genCall:pointer to lstCall;
  genSort:pointer to arrSortRes; topSortRes:integer;
  genRezTop,genRezMax:integer;
  envError:integer;
  envBitInit:boolean;

  genEntry:integer; //����� ����� (����� � genCode)
  genEntryNo:integer; //����� ����� (����� ������)
  genEntryStep:integer; //����� ����� (����� ������)
  genClasses:pClasses;
  genClassesTop:integer;
  genClassBegin:integer; //������ ������� �������

//��������� ���������� ����������
type IMAGE_COFF_SYMBOLS_HEADER=record
  NumberOfSymbols:cardinal;
  LvaToFirstSymbol:cardinal;
  NumberOfLinenumbers:cardinal;
  LvaToFirstLinenumber:cardinal;
  RvaToFirstByteOfCode:cardinal;
  RvaToLastByteOfCode:cardinal;
  RvaToFirstByteOfData:cardinal;
  RvaToLastByteOfData:cardinal;
end;

type IMAGE_LINENUMBER=record
  VirtualAddress:cardinal;
  Linenumber:cardinal;
end;

type IMAGE_SYMBOL=record
  ShortName:array[0..7]of char;
  Value:cardinal;
  SectionNumber:word;
  Type:word;
  StorageClass:byte;
  NumberOfAuxSymbols:byte;
end;

type AUX_SECTION=record
  Length:cardinal; // section length
  NumberOfRelocations:word; // number of relocation entries
  NumberOfLinenumbers:word; // number of line numbers
  CheckSum:cardinal; // checksum for communal
  Number:word; // section number to associate with
  Selection:byte; // communal selection type
  unused:array[0..2]of byte;
end;

type AUX_FUNCTION=record
  TagIndex:cardinal;
  TotalSize:cardinal;
  PointerToLinenumber:cardinal;
  PointerToNextFunction:cardinal;
  unused:array[0..1]of byte;
end;

type AUX_BF_EF=record
  unused:cardinal;
  Linenumber:word;
  unused2:array[0..5]of byte;
  PointerToNextFunction:cardinal;
  unused3:word;
end;

type IMAGE_DEBUG_DIRECTORY=record
  Characteristics:cardinal;
  TimeDateStamp:cardinal;
  MajorVersion:word;
  MinorVersion:word;
  Type:cardinal;
  SizeOfData:cardinal;
  AddressOfRawData:cardinal;
  PointerToRawData:cardinal;
  unused:cardinal; //�� �������� ������ IMAGE_DEBUG_DIRECTORY
end;

//===============================================
//            ������ ���������� TRA
//===============================================

type
  classFor=(forNULL,forBYTE,forINT,forDWORD);
  classModif=(modifNULL,modifTO,modifTONE,modifDOWNTO,modifDOWNTONE);
  classOp=(opNULL,
    opADD,opSUB,opMUL,opMULZ,opDIV,opDIVZ,opMOD,opMODZ,
    opOR,opAND,opNOT,opORB,opANDB,opNOTB,
    opABS,opNEG,opINT,opRND,opFLO,opUgLUgL,opUgRUgR,
    opE,opNE,opL,opG,opLZ,opGZ,opLE,opGE,opLEZ,opGEZ,
    opSETADD,opSETSUB,opSETADDE,opSETSUBE,opSETIN);
type
  recPars=record
    arrPars:array[1..maxPars]of record
      parBeg:integer;
      parEnd:integer;
    end;
    carPar:integer;
  end;

  arrModif=array[1..maxModif]of record
    modAddr:pinteger;
    modNew:integer;
  end;

var
  traCarProc:pID;
  traModName:string[100];
  traBitIMP:boolean; //imp-������
  traBitDEF:boolean; //def-������
  traBitDEFmod:boolean; //def-������ (�������)
  traBitH:boolean; //����-���������
  traBitLoadString:boolean; //�������� pstr
  traLastLoad:integer; //topCode ��� ��������� ������ traLOAD
  traBitOptim:boolean; //��� ������������� ��� � traLOAD
  traRecId:pID; //������������� ���� ������
  traFromDLL:pstr; //������� ������ DLL
  traListPre:pLIST; //������ ������������ ����������
  traTopPre:integer;
  traBitAND:boolean; //������� ������������� �������� ����� � traEXPRESSION
  traLANG:classLANG;
  traIcon:pstr;
  traCarParam:integer; //����� ��������� ��� �������� ��������� traTITLEtest
  traStackMet:array[1..maxStackMet]of integer; //������ traVARIABLE
  traStackTop:integer;
  traCarPro:classPRO; //������� ������� ������������

//===============================================
//            ������ �������� PRE
//===============================================

const maxPreList=5000;
const maxInput=0xFFFF;

//---------------- ������ ----------------------

type
  preArrLIST=record
    listTop:integer;
    listArr:array[1..maxPreList]of address;
  end;
  preLIST=pointer to preArrLIST;

//---------------- �������� ----------------------

type
  classDEF=(defNULL,
    defCONST,defTYPE,defVAR,defPROCEDURE,defDIALOG,defBITMAP,defICON,defFROM);
  classPreTYPE=(ptypeNULL,
    ptypeDOUBLE,ptypeBASE,ptypeRECORD,ptypeARRAY,ptypePOINTER,ptypeSCAL);

  pTYPE=pointer to recTYPE;
  recTYPE=record
  case Class:classPreTYPE of
    |doubleType:pstr; //ptypeDOUBLE
    |baseType:pstr; //ptypeBASE
    |recordList,recordCase:preLIST; //ptypeRECORD (recordList,recordCase - ������ ���� pDEF)
    |arrayBeg,arrayEnd:pstr; arrayType:pTYPE; //ptypeARRAY
    |pointerType:pTYPE; //ptypePOINTER
    |scalLIST:preLIST; //ptypeSCAL (scalLIST - ������ ���� pstr)
  end;

  recPARAM=record
    paramVar:boolean;
    paramName:pstr;
    paramType:pTYPE;
  end;
  pPARAM=pointer to recPARAM;

  recDEF=record
  case Class:classDEF of
    |constName:pstr; constVal:pstr; //defCONST
    |typeName:pstr; typeType:pTYPE; //defTYPE *
    |varName:pstr; varType:pTYPE; //defVAR
    |procName:pstr; procRez:pTYPE; procPar,procVar,procStat:preLIST; //defPROC (������ ����� pPARAM,pDEF � pSTAT)
    |defStr:pstr; //defDIALOG,defBITMAP,defICON,defFROM
  end;
  pDEF=pointer to recDEF;

//---------------- ��������� � ������ ----------------------

type
  classSTAT=(statNULL,
    statEQUAL,statPROC,statRETURN,statIF,statCASE,
    statWHILE,statREPEAT,statFOR,statASM,statWITH,
    statINC,statDEC);

  recELSIF=record
    elsifEXP:pstr;
    elsifLIST:preLIST;
  end;
  pELSIF=pointer to recELSIF;

  recCASECOND=record
    condCONST:pstr;
    condCONST2:pstr;
  end;
  pCASECOND=pointer to recCASECOND;

  recCASESEL=record
    caseCOND:preLIST; //������ ���� pCASECOND
    caseLIST:preLIST;
  end;
  pCASESEL=pointer to recCASESEL;

  recCALL=record
    callPROC:pstr;
    callLIST:preLIST; //������ ���� pEXP
  end;

  recSTAT=record
  case Class:classSTAT of
    |equalVAR:pstr; equalEXP:pstr; //statEQUAL
    |procCALL:pCALL; //statPROC
    |returnEXP:pstr; //statRETURN
    |ifEXP:pstr; ifTHEN,ifELSIF,ifELSE:preLIST; //statIF (ifELSIF - ������ ���� pELSIF)
    |caseEXP:pstr; caseLIST,caseELSE:preLIST; //statCASE (caseLIST - ������ ���� pCASESEL)
    |whileEXP:pstr; whileLIST:preLIST; //statWHILE
    |repeatEXP:pstr; repeatLIST:preLIST; //statREPEAT
    |forClass:classFor; forVAR:pstr; forBEG,forEND:pstr; forLIST:preLIST; //statFOR
    |asmLIST:preLIST; //statASM
    |withEXP:pstr; withLIST:preLIST; //statWITH
    |incdecVAR:pstr; incdecEXP:pstr; //statINC,statDEC
  end;
  pSTAT=pointer to recSTAT;

  recMODULE=record
    moduleName:pstr;
    moduleImport:preLIST; //������ ���� pstr
    moduleExport:preLIST; //������ ���� pstr
    moduleDef:preLIST; //������ ���� pDEF
    moduleStat:preLIST; //������ ���� pSTAT
  end;

//---------------- ������� ����� ----------------------

  preStream=record
    stFile:string[maxText]; //��� ������
    stTxt:integer; //����� ������
    stPosLex:recPos; //������� ��������� ������
    stPosPred:recPos; //���������� ������� ��������� ������
    stLex:classLex; //������� �������
    stLexStr:string[maxText]; //�������� ������� ������� lexSTR,lexID,lexNEW
    stLexOld:string[maxText]; //���������� �������� stLexStr
    stLexInt:cardinal;
    stInput:pstr; //����� ���������
    stComment:pstr; //������ ������������
    stErr:boolean; //������� ������
    stErrPos:recPos; //������� ������
    stErrText:string[maxText]; //����� ������
  end;

//===============================================
//             ��������������� ����� ENV
//===============================================

//---------------- ������ ----------------------

type classFrag=(fNULL, //�������������� ��������
                fINT,  //�����
                fREAL, //������������
                fCEP,  //�������
                fPARSE,//�����������
                fREZ,  //����������������� �������������
                fID,   //������������� ������������
                fASM,  //������� ����������
                fREG,  //������� ����������
                fCOMM);//�����������

//�������� ������
type recFrag=record
       tab:integer;
       txt:pstr;
       beg,len:integer;
       cla:classFrag;
     case of
       | iv:integer; //fINT
       | fv:real; //fREAL
       | rv:classREZ; //fREZ
       | pv:classPARSE; //fPARSE
       | av:classCommand; //fASM
       | mv:classRegister; //fREG
     end;
     pFrag=pointer to recFrag;

type listFrag=record
       topf:integer;
       arrf:array[1..maxFrag]of pFrag;
     end;
     pFrags=pointer to listFrag;
     listStr=record
       tops:integer;
       arrs:array[1..maxStr]of pFrags;
     end;
     pStrs=pointer to listStr;

//����� ������
type recTxt=record
       txtFile:string[maxTxtFile];
       txtTitle:string[maxTxtTitle];
       txtStrs:pStrs;

       txtTrackX:integer;
       txtTrackY:integer;
       txtCarX:integer;
       txtCarY:integer;

       txtMod:boolean; //����� �������
       txtLoad:boolean; //����� ��������

       blkSet:boolean;
       blkX:integer;
       blkY:integer;
     end;

var
    txts:array[0..1]of array[1..maxTxt]of recTxt;
    txtn:array[1..maxTxt]of integer; //0-imp, 1-def
    topt:integer;
    tekt:integer;
    mait:integer;
    envER:classER;

//----------- ������ ��������� ----------------

type classOtr=(oW,oB,oWB,oBW,oWBW);

  recFont=record
    fFace:string[maxStrID];
    fSize:integer;
    fBold:boolean;
    fItal:boolean;
    fCol:cardinal;
    foID:HFONT;
    fY:byte;
    fABC:array['\0'..'\255']of byte;
  end;
  arrFont=array[classFrag]of recFont;

const _stFont=arrFont{
  {"Arial Cyr",10,true,false,0x0000FF,,,},
  {"Arial Cyr",10,false,false,0xFF0000,,,},
  {"Arial Cyr",10,false,false,0xFF0000,,,},
  {"Arial Cyr",10,false,false,0xFF0000,,,},
  {"Arial Cyr",10,false,false,0x000000,,,},
  {"Arial Cyr",10,true,false,0x000000,,,},
  {"Arial Cyr",10,false,false,0x000000,,,},
  {"Courier New Cyr",10,false,true,0x000000,,,},
  {"Courier New Cyr",10,false,true,0x000000,,,},
  {"Arial Cyr",10,true,false,0x8F008F,,,}};

var stFont:arrFont; carFont:recFont;

//-------------- ������-������ --------------------

type classStatus=(staMod,staStr,staSto,staDeb,staIdent);

//-------------- ���������� --------------------

var //mainWnd:HWND; ���������� � win32ext
    editWnd:HWND;
    wndToolbar:HWND;
    wndTabs:HWND;
    wndExt:HWND;
    wndStatus:HWND;
    infDlg:HWND;
    infCancel:boolean;

    errTxt:integer;
    errExt:integer;
    modVarCallAsm:integer;

    findBeg,findReg:boolean;
    findStr,findRep:pstr;
    findArr:array[0..maxFind]of pstr; findTop:integer;

    blkBegX,blkBegY:integer;
    blkEndX,blkEndY:integer;

    envErrPos:pstr;
    envIdName:pstr;
    lastIdName:pstr;
    envIdVal:pstr;
    envIdMod:pstr;
    envIdMods:pstr;
    envBitSaveFiles:boolean;
    envSelectMouse:boolean;
    envUndo:pointer to arrUndo;
    envTopUndo:integer;
    envMenuH:array[classGroup]of HMENU;
    traMakeDLL:boolean;
    envOldFolder:string[300];

    time:integer;

    buffer:boolean;

//--------------- ��������� --------------------

procedure datInitial();
procedure datDestroy();
procedure datDefaultComp();
procedure datDefaultEnv();
procedure datLoadConst();
procedure datSaveConst();
procedure lexError(var Stream:recStream; errText,errMes:pstr);
procedure lexTest(bitTest:boolean; var Stream:recStream; errText,errMes:pstr);
procedure okREZ(var S:recStream; rez:classREZ):boolean;
procedure okPARSE(var S:recStream; par:classPARSE):boolean;
procedure okASM(var S:recStream; instr:classCommand):boolean;

//end SmDat.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TAB (������� ���������������)
//���� SMTAB.D

//definition module SmTab;
//import Win32,SmDat;

//������ � �������� ���������������
  procedure idInitial(var tab:pID; no:integer);
  procedure idDestroy(var tab:pID);
  procedure idDestroys();
  procedure idInsert(var tab:pID; name:pstr; Class:classID; ta:classTab; no:integer):pID;
  procedure idInsertGlo(name:pstr; Class:classID):pID;
  procedure idFind(var tab:pID; name:pstr):pID;
  procedure idFindGlo(name:pstr; bitFix:boolean):pID;
  procedure idWriteS(fil:integer; s:pstr);
  procedure idReadS(fil:integer; var s:pstr);
  procedure tabGetImpNo(var S:recStream; oldNo:integer; bitMess:boolean):integer;
  procedure tabGetImpId(var S:recStream; no:integer; name:pstr; bitMess:boolean):pID;
  procedure idWrite(var tab:pID; fil:integer);
  procedure idRead(var S:recStream; var tab:pID; fil:integer; no:integer);
  procedure idChangeMod(tab:pID; old,New:integer);
  procedure idViewMod0(filName:pstr);

//������ �� �������� ��������������� � ����
  procedure listAdd(addLIST:pLIST; addID:pID; var addTop:integer);
  procedure listFind(list:pLIST; top:integer; name:pstr):pID;
  procedure subAdd(addSUB:pSubs; addID:pID; var addTop:integer);
  procedure nameAdd(list:pName; name:pstr; var top:integer);
  procedure nameFind(list:pName; top:integer; name:pstr):integer;

//������ �� �������� ������� � ��������
  procedure impFind(addIMP:pIMPORT; addDLL,addFun:pstr; var addTop,nomDLL,nomFun:integer);
  procedure impAdd(addIMP:pIMPORT; addDLL,addFun:pstr; addAddr:integer; var addTop:integer):address;
  procedure impDestroy(addIMP:pIMPORT; addTop:integer);
  procedure impWrite(addIMP:pIMPORT; addTop:integer; fil:integer);
  procedure impRead(addIMP:pIMPORT; addTop:integer; fil:integer);
  procedure expAdd(expo:pEXPORT; name:pstr; var top:integer);
  procedure expDestroy(expo:pEXPORT; top:integer);
  procedure expWrite(expo:pEXPORT; top:integer; fil:integer);
  procedure expRead(expo:pEXPORT; top:integer; fil:integer);

//������ �� �������� �����
  procedure stringAdd(addSTRING:pSTRING; addStr:pstr; addSou:integer; var addTop:integer);
  procedure stringFree(addSTRING:pSTRING; var addTop:integer);

//������ �� ������� �������
  procedure stepAdd(var S:recStream; nom:integer; addClass:classStep);
  procedure stepPush(pushClass:classStep; pushParent:integer);
  procedure stepPop();

//�������������� ����
  procedure envInfBegin(title,title2:pstr);
  procedure envInfEnd();
  procedure envInf(s1,s2:pstr; pro:integer);

//end SmTab.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ GEN (��������� ����)
//���� SMGEN.D

//definition module SmGen;
//import Win32,SmDat;

  procedure genInitial();
  procedure genDestroy();

  procedure genAddJamp(var S:recStream; var aList:lstJamp; aVal:integer; aCom:classCommand);
  procedure genSetJamps(var S:recStream; var aList:lstJamp; aVal:integer);
  procedure genSetJamp(var S:recStream; aJamp,aLab:integer; aCom:classCommand);
  procedure genAddCall(var S:recStream; aSou:integer; aProc:pID);
  procedure genSetCalls(var S:recStream; var calls:lstCall; nom:integer; bitMessage:boolean);
  procedure genAddVarCall(var S:recStream; tekno,no,track:integer; cl:classVarCall; cla:pstr);
  procedure genAddProCall(var S:recStream; tekno,no,track:integer; sou:pstr);

  procedure genPutByte(var Stream:recStream; putByte:byte):integer;
  procedure genPutStr(var Stream:recStream; putStr:pstr):integer;
  procedure genPutVar(var Stream:recStream; putVar:pstr; putLen:integer):integer;

  procedure genByte(var Stream:recStream; b:byte);
  procedure genCard(var Stream:recStream; w:cardinal; bitW:boolean);
  procedure genLong(var Stream:recStream; l:integer; W:cardinal);
  procedure genPref(var Stream:recStream; prefReg:classRegister);
  procedure genFirst(var Stream:recStream; firstCod,firstPri:byte; D,W:cardinal);
  procedure genPost(var S:recStream; PostExt:byte; Base,Indx:classRegister; Dist:integer);
  procedure genSeg(var Stream:recStream; Instr:classCommand; Reg1,Reg2:classRegister);
  procedure genRR(var Stream:recStream; Instr:classCommand; Reg1,Reg2:classRegister);
  procedure genRD(var Stream:recStream; Instr:classCommand; Reg:classRegister; Data:integer);
  procedure genMR(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx,Reg:classRegister; Dist,D:integer);
  procedure genMD(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx:classRegister; Dist,Data:integer; W:cardinal);
  procedure genST(var Stream:recStream; Instr:classCommand; Reg:classRegister);
  procedure genR(var Stream:recStream; Instr:classCommand; Reg:classRegister);
  procedure genM(var Stream:recStream; Instr:classCommand; PrefS,Base,Indx:classRegister; Dist:integer; W:cardinal);
  procedure genD(var Stream:recStream; Instr:classCommand; D:integer);
  procedure genGen(var Stream:recStream; Instr:classCommand; W:integer);
  procedure genRegCL(var Stream:recStream; Instr:classCommand; Reg:classRegister);
  procedure genPOP(var Stream:recStream; Reg:classRegister; bitAND:boolean);

  procedure genBaseCla(cla:pID):pID;
  procedure genFindMetod(Class:pID; name:pstr):pID;
  procedure genAlign(siz,align:integer):integer;
  procedure genSize(sTab:classExe; align:integer):integer;
  procedure genExeName(sou,folder,res:pstr; bitDLL:boolean);
  procedure genExe(var S:recStream; gName:pstr; no:integer);
  procedure genDef(var S:recStream; gName:pstr; no:integer);
  procedure genImp(var S:recStream; gName:pstr; no:integer):boolean;

  procedure genSizeDlg(m,d:integer):integer;
  procedure genFreeRes(no:integer);
  procedure genLoadMod(var S:recStream; name:pstr; no:integer; bitLoadFile:boolean):boolean;
  procedure genCloseMod(no:integer);
  procedure genCloseMods();

//end SmGen.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ LEX (����������� ������)
//���� SMLEX.D

//definition module SmLex;
//import Win32,SmDat;

  var lexZEROSTR:string[4]; //'\0'

  procedure lexNextLex(var Stream:recStream; bitID:boolean);
  procedure lexOpen(var Stream:recStream; opFile:pstr; opTxt,opExt:integer);
  procedure lexClose(var Stream:recStream);
  procedure lexGetLex0(var Stream:recStream);
  procedure lexGetLex1(var Stream:recStream);
  procedure lexLexName(var Stream:recStream; lex:classLex; val:integer; name:pstr):pstr;
  procedure lexLexVal(var Stream:recStream; lex:classLex; val:integer; res :pstr):pstr;
  procedure lexAccept00(var Stream:recStream; lex:classLex; val:integer);
  procedure lexAccept0(var Stream:recStream; lex:classLex; val:integer);
  procedure lexAccept1(var Stream:recStream; lex:classLex; val:integer);

//end SmLex.
///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ ASM (���������� ���������)
//���� SMASM.D

//definition module SmAsm;
//import Win32,SmDat;

procedure asmInitial();
procedure asmDestroy();
procedure asmAssembly(var S:recStream);

//end SmAsm.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TRA (���������� ������, ���� ������-2)
//���� SMTRA.D

//definition module SmTra;
//import Win32,SmDat;

procedure traCall32(var S:recStream; mo,pr:pstr);
procedure traEqv(var S:recStream; e1,e2:pID; eErr:boolean):boolean;
procedure traFinish(var S:recStream);
procedure traAddModule(var S:recStream; name:pstr):integer;
procedure traGenEqv(S:recStream; eTypeVar,eTypeExp:pID);
procedure traCorrCall(var S:recStream; var modif:arrModif; var topModif:integer; oldBeg,oldEnd,newBeg,begCode:integer);
procedure traVarWITH(var S:recStream);
procedure traTITLEtest(var S:recStream; procId:pID);
procedure traMetNom(cla,own:pID):integer;

procedure traMODULE(var S:recStream);
procedure traSTRUCT(var S:recStream; typId:pID);
procedure traVARIABLE(var S:recStream; bitOnlyName,bitOnlyVar,bitStatMetod:boolean):pID;
procedure traEXPRESSION(var S:recStream):pID;
procedure traRETURN(var S:recStream);
procedure traDIALOG(var S:recStream);
procedure traBITMAP(var S:recStream);
procedure traICON(var S:recStream);
procedure traFROM(var S:recStream);
procedure traTEST(var S:recStream; cla:classFor; modif:classModif):integer;
procedure traMODIF(var S:recStream; cla:classFor; modif:classModif; forType:pID; labBeg,jmpEnd:cardinal);
procedure traPROTECTED(var S:recStream; bitDup:boolean);
procedure traSTRING(var S:recStream; typId:pID);
procedure traSET(var S:recStream; typId:pID);
procedure traSCALAR(var S:recStream; typId:pID);
procedure traCONSTs(var S:recStream);
procedure traSELECT(var S:recStream; sType:pID);
procedure traEQUAL(var S:recStream);
procedure traCALL(var S:recStream; bitStat:boolean; cProc:pID):pID;
procedure traREPEAT(var S:recStream);
procedure traASM(var S:recStream);
procedure traINCDEC(var S:recStream);
procedure traNEW(var S:recStream);
procedure traFORMAL(var S:recStream; procId:pID);
procedure traIMPORT(var S:recStream); forward;

//end SmTra.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TRAC (���������� ������, ���� ��)
//���� SMTRAC.D

//definition module SmTraC;
//import Win32,SmDat;

procedure tracMODULE(var S:recStream; modName:pstr);

//end SmTraC.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ TRAP (���������� ������, ���� �������)
//���� SMTRAP.D

//definition module SmTraP;
//import Win32,SmDat;

procedure trapMODULE(var S:recStream);

//end SmTraP.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ RES (��������� ��������)
//���� SMRES.D

//definition module SmRes;
//import Win32,SmDat;

const �������������="Str32DlgItem";
const ������������="Str32DlgMain";

procedure envCorrFont(f:classFrag);
procedure resTxtToDlg(cart:integer; var ���Y,���Y:integer):boolean;
procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean;
procedure �������������(��������:boolean):pstr;
procedure ������������();
procedure �������������();
procedure ������������();

//end SmRes.

///////////////////////////////////////////////////////////////////////////////
//�������� ������-��-������� ��� Win32
//������ ENV (������� ��������������� �����)
//���� SMENV.D

//definition module SmEnv;
//import Win32,SmDat;

procedure envCreateTitle(wnd:HWND);
procedure envDestroyTitle();
procedure envEnable();
procedure envUndoClear();
procedure envUndoPop(t:integer);
procedure envSetCaret(txt:integer);
procedure envEditCopy(t:integer);
procedure envUndoPush(cla:classUNDO; t:integer);
procedure envEditDel(t:integer);
procedure envUndoBlockEnd(t:integer);
procedure envEditIns(t:integer);
procedure envEditAll();
procedure envSetStatus(txt:integer);
procedure envButtonCreate();

procedure envNew();
procedure envOpen(iPath,iTitle:pstr; t:integer);
procedure envSelect(nom,ext:integer);
procedure envClose();
procedure envSave();
procedure envSaveAs();
procedure envSaveFiles(bitCancel:boolean):boolean;

procedure envStatusCreate(bitIni:boolean);
procedure envStatusLoad();
procedure envStatusSave();

procedure envTranslate();
procedure envTransAll(traFind,traDll:boolean):boolean;
procedure envExecute();
procedure envDebRun();
procedure envDebRunEnd();
procedure envDebEnd();
procedure envDebNextDown();
procedure envDebNext();
procedure envDebGoto();
procedure envDebView();
procedure envResource(cart:integer);
procedure envHelp(helpFile:pstr);
procedure envAbout();
procedure envIdentifier();
procedure envSetComp();
procedure envSetEnv();
procedure envInitClass();

procedure ������������();

//end SmEnv.
///////////////////////////////////////////////////////////////////////////////
end SmImp.
