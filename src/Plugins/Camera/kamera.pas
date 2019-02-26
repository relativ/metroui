unit kamera;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TransEff, teTimed, teMasked, teWFall, teForm,
  Vcl.Imaging.pngimage, AppEvnts, Buttons, IniFiles, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, jpeg;

type
  TfrmKamera = class(TForm)
    FormTransitions: TFormTransitions;
    TransitionList1: TTransitionList;
    Transition: TWaterfallTransition;
    ApplicationEvents: TApplicationEvents;
    ustOrta: TImage;
    altOrtaImg: TImage;
    CloseBtn: TSpeedButton;
    CloseImg: TImage;
    PrevImage: TImage;
    IdTCPClient: TIdTCPClient;
    readTimer: TTimer;
    procedure CloseBtnClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure readTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmKamera: TfrmKamera;

implementation

{$R *.dfm}

procedure TfrmKamera.CloseBtnClick(Sender: TObject);
begin
  close;
end;

procedure TfrmKamera.ApplicationEventsException(Sender: TObject;
  E: Exception);
begin
  E := nil;
end;

procedure TfrmKamera.FormShow(Sender: TObject);
var
  ini: TIniFile;
  port: integer;
  host: string;
begin
  ini:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
  host := ini.ReadString('Server','IP','');
  port := ini.ReadInteger('Server','Port',3456);
  if host <> '' then
  begin
    IdTCPClient.Host := host;
    IdTCPClient.Port := port;
    IdTCPClient.Connect;
    readTimer.Enabled := true;
  end;
end;

procedure TfrmKamera.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  readTimer.Enabled := false;
  IdTCPClient.Disconnect;

end;

procedure TfrmKamera.readTimerTimer(Sender: TObject);
var
  MStream: TMemoryStream;
  jpg: TJPEGImage;
begin
  readTimer.Enabled := false;
  if IdTCPClient.Connected then
  begin
    MStream:= TMemoryStream.Create;
    IdTCPClient.IOHandler.ReadStream(MStream);
    jpg:= TJPEGImage.Create;
    jpg.LoadFromStream(MStream);
    MStream.Free;
    PrevImage.Picture.Assign(jpg);
    jpg.Free;
  end;
  readTimer.Enabled := true;
end;

end.
