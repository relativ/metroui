unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdScheduler, IdSchedulerOfThread,
  IdSchedulerOfThreadDefault, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, IdContext;

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

  TForm1 = class(TForm)
    Button1: TButton;
    MainIdTCPServer: TIdTCPServer;
    IdSchedulerOfThreadDefault2: TIdSchedulerOfThreadDefault;
    procedure MainIdTCPServerConnect(AContext: TIdContext);
    procedure MainIdTCPServerDisconnect(AContext: TIdContext);
    procedure MainIdTCPServerException(AContext: TIdContext;
      AException: Exception);
    procedure MainIdTCPServerExecute(AContext: TIdContext);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  MainConnectionsList: TList;

implementation

{$R *.dfm}

procedure TForm1.MainIdTCPServerConnect(AContext: TIdContext);
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

  MainConnectionsList.Add(NewClient);
except

end;

end;

procedure TForm1.MainIdTCPServerDisconnect(AContext: TIdContext);
var
  Client: TClient;
begin
try
  Client := TClient(AContext.Data);

  MainConnectionsList.Remove(Client);

  Client.Free;
  AContext.Data := nil;
except

end;

end;

procedure TForm1.MainIdTCPServerException(AContext: TIdContext;
  AException: Exception);
var
  Client: TClient;
begin
  Client := TClient(AContext.Data);

  MainConnectionsList.Remove(Client);

  Client.Free;
  AContext.Data := nil;



end;

procedure TForm1.MainIdTCPServerExecute(AContext: TIdContext);
begin
//boþ
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  MainConnectionsList:= TList.Create;

  MainIdTCPServer.DefaultPort := 15419;
  with MainIdTCPServer.Bindings.Add do
  begin
    Port := 15419;
  end;
  if not MainIdTCPServer.Active then
    MainIdTCPServer.Active := true;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: integer;
begin
  for i := MainConnectionsList.Count -1 downto 0 do
  begin
    TClient(MainConnectionsList[i]).Thread.Connection.IOHandler.WriteLn('SHOTDOWN_PC');
  end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainIdTCPServer.Active := false;
end;

end.
