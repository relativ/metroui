unit MainSkinRect;

interface

uses
  {$IFDEF MSWINDOWS}
    Windows,
  {$ENDIF}
  {$IFDEF LINUX}
    QTypes,
    Libc,
  {$ENDIF}
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QComCtrls, QExtCtrls,
  JvSimpleXml, Configuration, Vcl.Imaging.pngimage, ButtonEventList, Skins, pluginlist;

type
  TDLLFunc = function (): TForm;

  TClickEvent = procedure (Sender: TObject; FormName,Event: string) of object;
  TPos = class(TObject)
    X,Y,W,H: integer;
  end;

  TClickResult = packed record
    FormName, Text: string;
  end;

  TMainSkinsRect = class(TComponent)
  private
    FClickEvent: TClickEvent;
    FList: TStringList;
    procedure SetSettings(val: TSettings);
    procedure PluginLoadAndShow(PluginName: string; proc: PAnsiChar);
    procedure ButtonClick(FormName,Text: string);
    function GetButtonCaptionPosition(ButtonName: string): TButtonPosition;
  public
    FormWidth, FormHeight: integer;
    FSettings: TSettings;
    Skin : TSkins;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddPos(X,Y,W,H: integer; FormName,Text: string);
    function GetMouseCoordinateWithRect(aX,aY: integer): TRect;
    procedure ClickCoordinateButton(FormName: string; aX,aY: integer);
  published
    property OnClickEvent: TClickEvent read FClickEvent write FClickEvent;
    property Settings: TSettings read FSettings write SetSettings;
  end;


implementation

constructor TMainSkinsRect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FList := TStringList.Create;
end;

destructor TMainSkinsRect.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function GetClickResult(str: string): TClickResult;
var
  tmp: string;
begin
  tmp := str;
  Result.FormName := copy(tmp,1,Pos('=',tmp)-1);
  Result.Text     := copy(tmp,Pos('=',tmp)+1,length(tmp));
end;

procedure TMainSkinsRect.SetSettings(val: TSettings);
var
  i: integer;
  X,Y,W,H: integer;
  Text,FormName: string;
begin
  FSettings := val;
  for i := 0 to FSettings.ButtonList.Count -1 do
  begin
    X := TButtonPosition(FSettings.ButtonList[i]).X;
    Y := TButtonPosition(FSettings.ButtonList[i]).Y;
    W := TButtonPosition(FSettings.ButtonList[i]).Width;
    H := TButtonPosition(FSettings.ButtonList[i]).Height;
    Text := TButtonPosition(FSettings.ButtonList[i]).ButtonName;
    FormName := TButtonPosition(FSettings.ButtonList[i]).FormName;
    AddPos(X,Y,W,H,FormName,Text);
  end;
end;

procedure TMainSkinsRect.AddPos(X,Y,W,H: integer; FormName,Text: string);
var
  xPos: TPos;
begin
  xPos:= TPos.Create;
  xPos.X := X;
  xPos.Y := Y;
  xPos.W := W;
  xPos.H := H;
  FList.AddObject(FormName +'='+ Text,xPos);
end;

function TMainSkinsRect.GetMouseCoordinateWithRect(aX,aY: integer): TRect;
var
  i,X,Y: integer;
  xPos: TPos;
  tmp: TRect;
begin
  X := (aX * FSettings.SkinImage.Width) div FormWidth;
  Y := (aY * FSettings.SkinImage.Height) div FormHeight;

  for i := 0 to FList.Count -1 do
  begin
    xPos := TPos(FList.Objects[i]);
    if X >= xPos.X then
      if X <= (xPos.W + xPos.X) then
        if Y >=xPos.Y then
          if Y <= (xPos.H + xPos.Y) then
          begin
            tmp.Left := xPos.X;
            tmp.Top  := xPos.Y;
            tmp.Right := xPos.W + xPos.X;
            tmp.Bottom := xPos.H + xPos.Y;
            Result := tmp;
          end;
  end;
end;

procedure TMainSkinsRect.ClickCoordinateButton(FormName: string; aX,aY: integer);
var
  i,X,Y: integer;
  xPos: TPos;
  tmp: TRect;
begin
  X := (aX * FSettings.SkinImage.Width) div FormWidth;
  Y := (aY * FSettings.SkinImage.Height) div FormHeight;

  for i := 0 to FList.Count -1 do
  begin
    xPos := TPos(FList.Objects[i]);
    if X >= xPos.X then
      if X <= (xPos.W + xPos.X) then
        if Y >=xPos.Y then
          if Y <= (xPos.H + xPos.Y) then
          begin
            tmp.Left := xPos.X;
            tmp.Top  := xPos.Y;
            tmp.Right := xPos.W + xPos.X;
            tmp.Bottom := xPos.H + xPos.Y;
            ButtonClick(GetClickResult(FList[i]).FormName,GetClickResult(FList[i]).Text);
          end;
  end;
end;

function TMainSkinsRect.GetButtonCaptionPosition(ButtonName: string): TButtonPosition;
var
  i: integer;
begin
  for i := 0 to Settings.ButtonList.Count -1 do
  begin
    if LowerCase(TButtonPosition(Settings.ButtonList[i]).ButtonName) = LowerCase(ButtonName) then
    begin
      Result:= TButtonPosition(Settings.ButtonList[i]);
      break;
    end;
  end;
end;



procedure TMainSkinsRect.ButtonClick(FormName,Text: string);
var
  PluginName,eventName,callFunction,caption: string;
begin
  Skin.ButtonEventList.EventList.First;
  while not Skin.ButtonEventList.EventList.Eof do
  begin

    if (Skin.ButtonEventList.EventList.FieldByName('formname').AsString = FormName) and
          (Skin.ButtonEventList.EventList.FieldByName('buttonname').AsString = GetButtonCaptionPosition(Text).PluginButtonName) then
    begin
      PluginName  := Skin.ButtonEventList.EventList.FieldByName('pluginname').AsString;
      eventName := Skin.ButtonEventList.EventList.FieldByName('eventname').AsString;
      callFunction := Skin.ButtonEventList.EventList.FieldByName('callfunction').AsString;
      caption    := Skin.ButtonEventList.EventList.FieldByName('buttoncaption').AsString;
      break;
    end;
    Skin.ButtonEventList.EventList.Next;
  end;
  if PluginName <> '' then
  begin
    PluginLoadAndShow(PluginName,pchar(callFunction));
  end else begin

  end;
  if Assigned(FClickEvent) then FClickEvent(Self,FormName,Text);
end;

procedure TMainSkinsRect.PluginLoadAndShow(PluginName: string; proc: PAnsiChar);
const
   DLLFunc: TDLLFunc = nil;
var
  DLLHandle: THandle;
  Form,tmpForm: TForm;
  i: integer;
begin
  Form := FSettings.PluginList.GetPluginForm(PluginName);
  if Form = nil then
  begin
    if UpperCase(PluginName) = 'MUSIC' then
    begin
        tmpForm := FSettings.PluginList.GetPluginForm('VIDEO');
        if tmpForm <> nil then
        begin
          tmpForm := nil;
          FSettings.PluginList.DeletePluginForm('VIDEO');
        end;

      tmpForm := FSettings.PluginList.GetPluginForm('KLIP');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('KLIP');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YFILM');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YABFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YABFILM');
      end;
    end else if UpperCase(PluginName) = 'VIDEO' then
    begin
      tmpForm := FSettings.PluginList.GetPluginForm('MUSIC');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('MUSIC');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('KLIP');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('KLIP');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YFILM');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YABFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YABFILM');
      end;
    end else if UpperCase(PluginName) = 'KLIP' then
    begin
      tmpForm := FSettings.PluginList.GetPluginForm('MUSIC');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('MUSIC');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('VIDEO');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('VIDEO');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YFILM');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YABFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YABFILM');
      end;
    end else if UpperCase(PluginName) = 'YFILM' then
    begin
      tmpForm := FSettings.PluginList.GetPluginForm('MUSIC');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('MUSIC');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('VIDEO');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('VIDEO');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('KLIP');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('KLIP');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YABFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YABFILM');
      end;
    end else if UpperCase(PluginName) = 'YABFILM' then
    begin
      tmpForm := FSettings.PluginList.GetPluginForm('MUSIC');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('MUSIC');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('VIDEO');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('VIDEO');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('KLIP');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('KLIP');
      end;

      tmpForm := FSettings.PluginList.GetPluginForm('YFILM');
      if tmpForm <> nil then
      begin
        tmpForm := nil;
        FSettings.PluginList.DeletePluginForm('YFILM');
      end;
    end;

    DLLHandle := FSettings.PluginList.GetPluginHandle(PluginName);
    try
     @DLLFunc := GetProcAddress(DLLHandle, proc);
     Form     := DLLFunc;
     FSettings.PluginList.SetPluginForm(PluginName, Form);
     Form.Show;

    finally

    end;
  end else Form.Show;

end;

end.
