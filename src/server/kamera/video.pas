unit video;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, VidGrab, IniFiles, IdScheduler, IdSchedulerOfThread,
  IdSchedulerOfThreadDefault, IdAntiFreezeBase, IdAntiFreeze,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,jpeg,IdContext,
  StdCtrls, Buttons, IdTCPConnection, IdTCPClient;

type
  TClient = class(TObject)
    MasaID      : string;
    UniqID      : string;
    PeerIP      : string[15];
    HostName    : String[40];
    Connected,
    LastAction  : TDateTime;
    Thread      : TIdContext;
  end;

  TfrmKamera = class(TForm)
    VideoGrabber: TVideoGrabber;
    KameraTCPServer: TIdTCPServer;
    IdSchedulerOfThreadDefault1: TIdSchedulerOfThreadDefault;
    PrevImage: TImage;
    IdTCPClient: TIdTCPClient;
    readTimer: TTimer;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure KameraTCPServerConnect(AContext: TIdContext);
    procedure KameraTCPServerDisconnect(AContext: TIdContext);
    procedure KameraTCPServerException(AContext: TIdContext;
      AException: Exception);
    procedure VideoGrabberFrameProgress(Sender: TObject;
      const FrameInfo: TFrameInfo);
    procedure KameraTCPServerExecute(AContext: TIdContext);
    procedure FormDestroy(Sender: TObject);
    procedure readTimerTimer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmKamera: TfrmKamera;
  Clients         : TList;

implementation

uses IdIOHandler;

{$R *.dfm}

procedure TfrmKamera.FormCreate(Sender: TObject);
var
  ini: TIniFile;
  deviceName: string;
  id,kameraPort: integer;
begin
  ini:= TIniFile.Create(ExtractFilePath(ParamStr(0))+'config.ini');
  kameraPort := ini.ReadInteger('Camera','ServerPort',3456);
  Clients := TList.Create;
  KameraTCPServer.DefaultPort := kameraPort;
  with KameraTCPServer.Bindings.Add do
  begin
    Port := kameraPort;
  end;
  KameraTCPServer.OnConnect  := KameraTCPServerConnect;
  KameraTCPServer.OnDisconnect:= KameraTCPServerDisconnect;
  KameraTCPServer.Active      := true;


  deviceName := ini.ReadString('Camera','VideoDevice','');
  if deviceName <> '' then
  begin
    id := VideoGrabber.VideoDeviceIndex(deviceName);
    VideoGrabber.VideoDevice := id;
    VideoGrabber.StartPreview;
  end;
end;

procedure TfrmKamera.KameraTCPServerConnect(AContext: TIdContext);
var
  NewClient: TClient;
begin
try
  NewClient:= TClient.Create;

  NewClient.PeerIP      := AContext.Binding.PeerIP;
  NewClient.HostName    := AContext.Binding.DisplayName;
  NewClient.Connected   := Now;
  NewClient.LastAction  := NewClient.Connected;
  NewClient.Thread      := AContext;

  AContext.Data := NewClient;

  Clients.Add(NewClient);
except
    //AddLog('Hata :KameraTCPServerConnect -- '+ E.Message);
end;

end;

procedure TfrmKamera.KameraTCPServerDisconnect(AContext: TIdContext);
var
  Client: TClient;
begin
try
  Client := TClient(AContext.Data);

  Clients.Remove(Client);

  Client.Free;
  AContext.Data := nil;
except
 // on E: Exception do
  //  AddLog('Hata :KameraTCPServerDisconnect -- '+ E.Message);
end;

end;

procedure TfrmKamera.KameraTCPServerException(AContext: TIdContext;
  AException: Exception);
var
  Client: TClient;
begin
  Client := TClient(AContext.Data);

  Clients.Remove(Client);

  Client.Free;
  AContext.Data := nil;
  
  //AddLog('Hata :KameraTCPServerException -- '+ AException.Message);

end;

function GetDcAsBitmap(DC: HDC; Bitmap: TBitmap; W, H: Cardinal): Boolean;
var
hdcCompatible: HDC;
hbmScreen: HBitmap;
begin
Result := False;
if DC = 0 then Exit;
hdcCompatible := CreateCompatibleDC(DC);
hbmScreen := CreateCompatibleBitmap(DC, W, H);
if (hbmScreen = 0) then Exit;
if (SelectObject(hdcCompatible, hbmScreen)=0) then Exit;
if not(BitBlt(hdcCompatible, 0,0, W, H, DC, 0,0, SRCCOPY)) then
Exit;
Bitmap.Handle := HbmScreen;
Bitmap.Dormant;
Result := True;
end;

procedure TfrmKamera.VideoGrabberFrameProgress(Sender: TObject;
  const FrameInfo: TFrameInfo);
var
  DCDesk: HDC;
  bmp: TBitmap;
  jpg: TJPEGImage;
  i: integer;
  MStream: TStringStream;
begin
  if Clients.Count > 0 then
  begin
    bmp:= TBitmap.Create;
    jpg:= TJPEGImage.Create;
    DCDesk:=VideoGrabber.Handle;
    GetDcAsBitmap(DCDesk,bmp,VideoGrabber.Width,VideoGrabber.Height);
    jpg.Assign(bmp);
    bmp.Free;

    MStream:= TStringStream.Create('');
    MStream.Position := 0;
    jpg.SaveToStream(MStream);

    for i := 0 to Clients.Count -1 do
    begin
      TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn(MStream.DataString);
    end;
    jpg.Free;
    MStream.Free;
  end;

end;

procedure TfrmKamera.KameraTCPServerExecute(AContext: TIdContext);
begin
 // boþ
end;

procedure TfrmKamera.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  VideoGrabber.StopPreview;
  KameraTCPServer.Active := false;
  for i := Clients.Count -1 downto 0 do
  begin
    TClient(Clients[i]).Free;
    Clients.Delete(i);
  end;

end;

procedure TfrmKamera.readTimerTimer(Sender: TObject);
var
  MStream: TStringStream;
  jpg: TJPEGImage;
  size: integer;
  s: string;
begin
  readTimer.Enabled := false;
  if IdTCPClient.Connected then
  begin
    s := IdTCPClient.IOHandler.ReadLn();
    size := StrToInt(Trim(s));
    MStream:= TStringStream.Create(s);
    jpg:= TJPEGImage.Create;
    jpg.LoadFromStream(MStream);

    PrevImage.Picture.Assign(jpg);
     MStream.Free;
    jpg.Free;
  end;
  readTimer.Enabled := true;

end;

procedure TfrmKamera.BitBtn1Click(Sender: TObject);
begin
    IdTCPClient.Host := '127.0.0.1';
    IdTCPClient.Port := 3456;
    IdTCPClient.Connect;
    readTimer.Enabled := true;

end;

end.
