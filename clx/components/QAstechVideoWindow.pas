unit QAstechVideoWindow;

interface

uses
  SysUtils,
   Classes, Qt, QControls, QExtCtrls, QGraphics, QForms, VLCLib;

type
  TPositionEvent  = procedure(Sender: TObject; Pos,Max: integer) of object;
  TErrorEvent     = procedure(Sender: TObject; ErrorCode: integer; ErrorMsg: string) of object;

  TLinVideoWindow = class(TCustomPanel)
  private
    FOnComplate,FOnStart,FOnStop: TNotifyEvent;
    FPosEvent   : TPositionEvent;
    FErrorEvent : TErrorEvent;
    FFullscreenControl : TForm;


    FObjID      : string;
    FFileName   : string;
    FTimer,FLengthTimer : TTimer;

    vlc         : integer;
    initVLD     : boolean;
    videoLength : integer;
    FPosition   : integer;

    procedure PositionTimer(Sender: TObject);
    procedure LengthTimer(Sender: TObject);
    procedure SetFileName(val: string);
    procedure FullScreenCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Wait;
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;
    procedure Play;
    procedure Pause;
    procedure Stop;
    procedure Open;
    procedure StartAudioEffect;
    procedure StopAudioEffect;
    procedure StartFullScreen;
    function GetLength: integer;
    function GetPosition: integer;
    procedure SetPosition(val: integer);
    function isPlaying: boolean;
  published
    property Color;
    property Align;
    property FileName   : string read FFileName write SetFileName;
    property ObjID      : string    read FObjID    write FObjID;
    property OnComplate : TNotifyEvent read FOnComplate write FOnComplate;
    property OnStart    : TNotifyEvent read FOnStart write FOnStart;
    property OnStop     : TNotifyEvent read FOnStop write FOnStop;
    property OnPosition : TPositionEvent read FPosEvent write FPosEvent;
    property OnError    : TErrorEvent read FErrorEvent write FErrorEvent;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard', [TLinVideoWindow]);
end;


constructor TLinVideoWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := '';
  Color := clBlack;
  BevelInner := bvNone;
  BevelOuter := bvNone;
 FTimer := TTimer.Create(nil);
 FTimer.Interval := 1000;
 FTimer.OnTimer  := PositionTimer;
 FTimer.Enabled  := false;

 FLengthTimer := TTimer.Create(nil);
 FLengthTimer.Interval := 2000;
 FLengthTimer.OnTimer  := LengthTimer;
 FLengthTimer.Enabled  := false;

 FFullScreenControl := TForm.Create(nil);
 FFullScreenControl.Color := Color;
 FFullScreenControl.BorderStyle := fbsNone;
 FFullScreenControl.OnCloseQuery := FullScreenCloseQuery;

 videoLength := 0;
 vlc := -1; 

 FPosition       := 2;
end;

destructor TLinVideoWindow.Destroy;
begin
  FTimer.Enabled := false;
  FTimer.Free;

  FLengthTimer.Enabled := false;
  FLengthTimer.Free;

 { if vlc > -1 then
  begin
  //  VLC_CleanUp(vlc);
    Sleep(200);
    VLC_Destroy(vlc);
    Sleep(200);
  end;}
  FFullScreenControl.Free;
  inherited Destroy;
end;

procedure TLinVideoWindow.Wait;
begin
  Sleep(200);
end;

procedure TLinVideoWindow.Init;
var
  args:array[0..1] of pchar;
  val :TValue;
  err: integer;
begin
  try
     err:=VLD_Startup;
     if err<>VLD_SUCCESS then begin
      case err of
       VLD_NOLIB   : begin
          initVLD := false;
          if Assigned(FErrorEvent) then FErrorEvent(self,VLD_NOLIB,'libvlc.dll kitaplýðý bulunamadý.');
       end;
       VLD_NOTFOUND:  begin
          initVLD := false;
          if Assigned(FErrorEvent) then FErrorEvent(self,VLD_NOTFOUND,'libvlc.dll geçerli deðil.');
       end;
      end;
     end;
    vlc := VLC_Create;
    Wait;
    args[0]:=pchar(VLD_LibPath);
    args[1]:=nil;
    VLC_Init(vlc,1,@args[0]);
    Wait;
    val.AsInteger := Width;
    VLC_VariableSet(vlc,'conf::width',val);
    val.AsInteger := Height;
    VLC_VariableSet(vlc,'conf::height',val);
    val.AsInteger := QWidget_winId(Handle);
    VLC_VariableSet(vlc,'drawable',val);
  finally
    initVLD := true;
  end;
end;


procedure TLinVideoWindow.FullScreenCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if csDestroying in componentstate then
  begin
    CanClose := True;
  end
  else
    CanClose := False;
end;

procedure TLinVideoWindow.StartAudioEffect;
var
  val :TValue;
  playing: boolean;
begin
  playing := VLC_IsPlaying(vlc);
  Wait;
  Stop;
  Wait;
  VLC_CleanUp(vlc);
  Wait;
  val.AsPChar:= 'goom';
  VLC_VariableSet(vlc,'conf::audio-visual',val);
  if FFullscreenControl.Showing then
  begin
    val.AsInteger := FFullscreenControl.Width;
    VLC_VariableSet(vlc,'conf::width',val);
    val.AsInteger := FFullscreenControl.Height;
    VLC_VariableSet(vlc,'conf::height',val);
    val.AsInteger := QWidget_winId(FFullscreenControl.Handle);
    VLC_VariableSet(vlc,'drawable',val);
  end else begin
    val.AsInteger := Width;
    VLC_VariableSet(vlc,'conf::width',val);
    val.AsInteger := Height;
    VLC_VariableSet(vlc,'conf::height',val);
    val.AsInteger := QWidget_winId(Handle);
    VLC_VariableSet(vlc,'drawable',val);
  end;
  if playing then
  begin
    Open;
    Wait;
    Play;
  end;
end;

function TLinVideoWindow.GetLength: integer;
begin
  Result := VLC_LengthGet(vlc);
  Wait;
end;

function TLinVideoWindow.GetPosition: integer;
begin
  Result := VLC_TimeGet(vlc);
  Wait;
end;

procedure TLinVideoWindow.SetPosition(val: integer);
begin
  VLC_TimeSet(vlc,val,false);
  Wait;
end;

procedure TLinVideoWindow.StartFullScreen;
begin
  VLC_FullScreen(vlc);
  Wait;
end;

function TLinVideoWindow.isPlaying: boolean;
begin
  result := VLC_IsPlaying(vlc);
  Wait;
end;

procedure TLinVideoWindow.StopAudioEffect;
var
  val :TValue;
  playing: boolean;
begin
  playing := VLC_IsPlaying(vlc);
  Wait;
  Stop;
  Wait;
  VLC_CleanUp(vlc);
  Wait;
  val.AsPChar:= '';
  VLC_VariableSet(vlc,'conf::audio-visual',val);
  if FFullscreenControl.Showing then
  begin
    val.AsInteger := FFullscreenControl.Width;
    VLC_VariableSet(vlc,'conf::width',val);
    val.AsInteger := FFullscreenControl.Height;
    VLC_VariableSet(vlc,'conf::height',val);
    val.AsInteger := QWidget_winId(FFullscreenControl.Handle);
    VLC_VariableSet(vlc,'drawable',val);
  end else begin
    val.AsInteger := Width;
    VLC_VariableSet(vlc,'conf::width',val);
    val.AsInteger := Height;
    VLC_VariableSet(vlc,'conf::height',val);
    val.AsInteger := QWidget_winId(Handle);
    VLC_VariableSet(vlc,'drawable',val);
  end;
  if playing then
  begin
    Open;
    Wait;
    Play;
  end;
end;

procedure TLinVideoWindow.PositionTimer(Sender: TObject);
var
  pos,len: integer;
begin
  if initVLD then
  begin
 //   if VLC_IsPlaying(vlc) then
    begin
      pos := GetPosition;
      len := GetLength;
      if (pos > 0) and (len > 0) and (Assigned(FPosEvent)) then FPosEvent(Self,pos,len);
      if FPosition = videoLength then
      begin
        FPosition := 0;
        FTimer.Enabled := false;
        if Assigned(FOnComplate) then FOnComplate(self);
      end else inc(FPosition);
    end;
  end;
end;

procedure TLinVideoWindow.LengthTimer(Sender: TObject);
begin
  FLengthTimer.Enabled := false;
  videoLength := VLC_LengthGet(vlc);
  FTimer.Enabled := true;
end;

procedure TLinVideoWindow.Resize;
var
  val :TValue;
begin
  inherited Resize;
  if initVLD then
  begin
    val.AsInteger := Width;
    VLC_VariableSet(vlc,'conf::width',val);
    val.AsInteger := Height;
    VLC_VariableSet(vlc,'conf::height',val);
  end else Init;
end;

procedure TLinVideoWindow.SetFileName(val: string);
begin
  if initVLD then
  begin
    FFileName := UTF8Encode(val);
  end else Init;
end;

procedure TLinVideoWindow.Play;
begin
  if initVLD then
  begin
    Wait;
    VLC_Play(vlc);
    Wait;
    FPosition := 2;
    FLengthTimer.Enabled := true;
    if Assigned(FOnStart) then FOnStart(Self);
  end;
end;

procedure TLinVideoWindow.Pause;
begin
  if initVLD then
  begin
    Wait;
    VLC_Pause(vlc);
    Wait;
    FTimer.Enabled := false;
  end;
end;

procedure TLinVideoWindow.Stop;
begin
  if initVLD then
  begin
    FPosition := 2;
    FTimer.Enabled := false;
    Wait;
    VLC_Stop(vlc);
    Wait;
    VLC_PlaylistClear(vlc);
    Wait;
    if Assigned(FOnStop) then FOnStop(Self);
  end;
end;

procedure TLinVideoWindow.Open;
begin
  if FFileName <> '' then
  begin
    FTimer.Enabled := false;
    Wait;
    VLC_Stop(vlc);
    Wait;
    VLC_CleanUp(vlc);
    Wait;
    VLC_PlaylistClear(vlc);
    Wait;
    VLC_AddTarget(vlc,PChar(FFileName),nil,0,PLAYLIST_APPEND,PLAYLIST_END);
    Wait;
  end;
end;

end.
