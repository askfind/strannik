//СТРАННИК Модула-Си-Паскаль для Win32
//Модуль ENV (утилиты интегрированной среды)
//Файл SMENV.D

definition module SmEnv;
import Win32,SmDat;

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

procedure отлЗакончить();

end SmEnv.

