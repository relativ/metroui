unit klavye;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TechKlavye, jpeg, TransEff, teTimed, teMasked,
  teCircle, teForm, StdCtrls, Buttons, Vcl.Imaging.pngimage;

type
  TfrmKlavye = class(TForm)
    btn_q: TSpeedButton;
    btn_w: TSpeedButton;
    btn_e: TSpeedButton;
    btn_r: TSpeedButton;
    btn_t: TSpeedButton;
    btn_y: TSpeedButton;
    btn_u: TSpeedButton;
    btn_ii: TSpeedButton;
    btn_o: TSpeedButton;
    btn_p: TSpeedButton;
    btn_a: TSpeedButton;
    btn_s: TSpeedButton;
    btn_d: TSpeedButton;
    btn_f: TSpeedButton;
    btn_g: TSpeedButton;
    btn_h: TSpeedButton;
    btn_j: TSpeedButton;
    btn_k: TSpeedButton;
    btn_l: TSpeedButton;
    btn_gg: TSpeedButton;
    btn_uu: TSpeedButton;
    btn_z: TSpeedButton;
    btn_x: TSpeedButton;
    btn_c: TSpeedButton;
    btn_v: TSpeedButton;
    btn_b: TSpeedButton;
    btn_n: TSpeedButton;
    btn_m: TSpeedButton;
    btn_ss: TSpeedButton;
    btn_i: TSpeedButton;
    btn_noktasi: TSpeedButton;
    btn_gir: TSpeedButton;
    btn_buyuk: TSpeedButton;
    btn_ozelkarakter: TSpeedButton;
    btn_bosluk: TSpeedButton;
    btn_oo: TSpeedButton;
    btn_cc: TSpeedButton;
    btn_iptal: TSpeedButton;
    sayi_1: TSpeedButton;
    sayi_2: TSpeedButton;
    sayi_3: TSpeedButton;
    sayi_4: TSpeedButton;
    sayi_8: TSpeedButton;
    sayi_7: TSpeedButton;
    sayi_6: TSpeedButton;
    sayi_5: TSpeedButton;
    ozelBtn: TSpeedButton;
    sayi_0: TSpeedButton;
    sayi_9: TSpeedButton;
    FormTransitions: TFormTransitions;
    TransitionList1: TTransitionList;
    Transition: TCircleTransition;
    txtBoxPanel: TPanel;
    textbox: TEdit;
    SpeedButton1: TSpeedButton;
    altOrtaImg: TImage;
    Image1: TImage;
    procedure ozelBtnClick(Sender: TObject);
    procedure sayi_1Click(Sender: TObject);
    procedure btn_iptalClick(Sender: TObject);
    procedure btn_buyukClick(Sender: TObject);
    procedure btn_ozelkarakterClick(Sender: TObject);
    procedure btn_girClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton1Click(Sender: TObject);
  private
    upCase,ozelkarakter: boolean;
    oldW,oldH: integer;
  public
    Text: string;
  end;

var
  frmKlavye: TfrmKlavye;

implementation

{$R *.dfm}

function SetScreenResolution(Width, Height: integer): Longint;
var
  DeviceMode: TDeviceMode;
begin
  with DeviceMode do begin
    dmSize := SizeOf(TDeviceMode);
    dmPelsWidth := Width;
    dmPelsHeight := Height;
    dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
  end;
  Result := ChangeDisplaySettings(DeviceMode, CDS_UPDATEREGISTRY);
end;

function BuyukKarakter(str: char): string;
begin
  case str of
    'a': result := 'A';  'b': result := 'B';
    'c': result := 'C';  'ç': result := 'Ç';
    'd': result := 'D';  'e': result := 'E';
    'f': result := 'F';  'g': result := 'G';
    'ð': result := 'Ð';  'h': result := 'H';
    'ý': result := 'I';  'i': result := 'Ý';
    'j': result := 'J';  'k': result := 'K';
    'l': result := 'L';  'm': result := 'M';
    'n': result := 'N';  'o': result := 'O';
    'ö': result := 'Ö';  'p': result := 'P';
    'q': result := 'Q';  'r': result := 'R';
    's': result := 'S';  'þ': result := 'Þ';
    't': result := 'T';  'u': result := 'U';
    'ü': result := 'Ü';  'v': result := 'V';
    'w': result := 'W';  'x': result := 'X';
    'y': result := 'Y';  'z': result := 'Z';
    '.': result := ':';
    else Result := str;
  end;
end;

function fncOzelKarakter(str: char): string;
begin
  case str of
    '1': result := '!';  '!': result := '1';
    '2': result := '@';  '@': result := '2';
    '3': result := '#';  '#': result := '3';
    '4': result := '$';  '$': result := '4';
    '5': result := '%';  '%': result := '5';
    '6': result := '^';  '^': result := '6';
    '7': result := '&';  '&': result := '7';
    '8': result := '*';  '*': result := '8';
    '9': result := '(';  '(': result := '9';
    '0': result := ')';  ')': result := '0';
    else Result := str;
  end;
end;

function KucukKarakter(str: char): string;
begin
  case str of
    'A': result := 'a';  'B': result := 'b';
    'C': result := 'c';  'Ç': result := 'ç';
    'D': result := 'd';  'E': result := 'e';
    'F': result := 'f';  'G': result := 'g';
    'Ð': result := 'ð';  'H': result := 'h';
    'I': result := 'ý';  'Ý': result := 'i';
    'J': result := 'j';  'K': result := 'k';
    'L': result := 'l';  'M': result := 'm';
    'N': result := 'n';  'O': result := 'o';
    'Ö': result := 'ö';  'P': result := 'p';
    'Q': result := 'q';  'R': result := 'r';
    'S': result := 's';  'Þ': result := 'þ';
    'T': result := 't';  'U': result := 'u';
    'Ü': result := 'ü';  'V': result := 'v';
    'W': result := 'w';  'X': result := 'x';
    'Y': result := 'y';  'Z': result := 'z';
    ':': result := '.';
    else Result := str;
  end;
end;

procedure TfrmKlavye.ozelBtnClick(Sender: TObject);
begin
  if sayi_1.Caption = '1' then
  begin
    sayi_1.Caption := #96;
    sayi_2.Caption := '~';
    sayi_3.Caption := '-';
    sayi_4.Caption := '+';
    sayi_5.Caption := '_';
    sayi_6.Caption := '=';
    sayi_7.Caption := '|';
    sayi_8.Caption := '\';
    sayi_9.Caption := '/';
  end else begin
    sayi_1.Caption := '1';
    sayi_2.Caption := '2';
    sayi_3.Caption := '3';
    sayi_4.Caption := '4';
    sayi_5.Caption := '5';
    sayi_6.Caption := '6';
    sayi_7.Caption := '7';
    sayi_8.Caption := '8';
    sayi_9.Caption := '9';

  end;
end;

procedure TfrmKlavye.sayi_1Click(Sender: TObject);
begin
  textbox.Text := textbox.Text + TSpeedButton(Sender).Caption;
  textbox.SelStart := length(textbox.Text);
end;

procedure TfrmKlavye.btn_iptalClick(Sender: TObject);
begin
  close;
end;

procedure TfrmKlavye.btn_buyukClick(Sender: TObject);
var
  i: integer;
  str: string;
begin
  upCase := not upCase;
  ozelkarakter := not ozelkarakter;
  for i := 0 to ComponentCount -1 do
  begin
    if Components[i] is TSpeedButton then
    begin
      if TSpeedButton(Components[i]).Tag = 1 then
      begin
        str := TSpeedButton(Components[i]).Caption;
        if upCase then
          TSpeedButton(Components[i]).Caption := BuyukKarakter(str[1])
        else
          TSpeedButton(Components[i]).Caption := KucukKarakter(str[1]);

      end;
    end;
  end;

  for i := 0 to ComponentCount -1 do
  begin
    if Components[i] is TSpeedButton then
    begin
      if TSpeedButton(Components[i]).Tag = 2 then
      begin
        str := TSpeedButton(Components[i]).Caption;
        TSpeedButton(Components[i]).Caption := fncOzelKarakter(str[1])

      end;
    end;
  end;
end;

procedure TfrmKlavye.btn_ozelkarakterClick(Sender: TObject);
var
  i: integer;
  str: string;
begin
  upCase := not upCase;
  for i := 0 to ComponentCount -1 do
  begin
    if Components[i] is TSpeedButton then
    begin
      if TSpeedButton(Components[i]).Tag = 1 then
      begin
        str := TSpeedButton(Components[i]).Caption;
        if upCase then
          TSpeedButton(Components[i]).Caption := BuyukKarakter(str[1])
        else
          TSpeedButton(Components[i]).Caption := KucukKarakter(str[1]);

      end;
    end;
  end;

end;

procedure TfrmKlavye.btn_girClick(Sender: TObject);
begin
  Text := textbox.Text;
  ModalResult := mrOk;
end;

procedure TfrmKlavye.FormShow(Sender: TObject);
begin
  oldW := Screen.Width;
  oldH := Screen.Height;
  Text :='';
  textbox.Text := '';
end;

procedure TfrmKlavye.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  str: string;
  cKey: Char;
begin
 { cKey := chr(Key);
  if (cKey in ['a'..'z']) or (cKey in ['A'..'Z']) or (cKey in ['0'..'9']) or (fncOzelKarakter(cKey) <> cKey) then
    textbox.Caption := textbox.Caption + cKey;
  if Key = VK_BACK then
  begin
    str := textbox.Caption;
    delete(str,length(str),length(str));
    textbox.Caption := str;
  end;   }

end;

procedure TfrmKlavye.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmKlavye.SpeedButton1Click(Sender: TObject);
var
  s: string;
begin
  s := textbox.Text;
  if s <> '' then
  begin
    Delete(s,length(s),length(s));
    textbox.Text := s;
    if length(textbox.Text) > 0 then
      textbox.SelStart := length(textbox.Text);
  end;
end;


end.
