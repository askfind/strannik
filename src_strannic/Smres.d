//—“–јЌЌ»  ћодула-—и-ѕаскаль дл€ Win32
//ћодуль RES (редакторы ресурсов)
//‘айл SMRES.D

definition module SmRes;
import Win32,SmDat;

const классЁлемента="Str32DlgItem";
const классƒиалога="Str32DlgMain";

procedure envCorrFont(f:classFrag);
procedure resTxtToDlg(cart:integer; var начY,конY:integer):boolean;
procedure resTxtToBmp(cart:integer; str:pstr; bitBmp:boolean):boolean;
procedure рес оррƒиалог(битЌовый:boolean):pstr;
procedure ресЌастройки();
procedure рес»ниц лассы();
procedure рес«агрѕарам();

end SmRes.

