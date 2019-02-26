unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, IdContext, Registry,
  IdServerIOHandler, IdServerIOHandlerSocket, IdServerIOHandlerStack,
  ScktComp, IdScheduler, IdSchedulerOfThread, IdSchedulerOfThreadDefault,
  IdAntiFreezeBase, IdAntiFreeze, IdIPWatch, SyncObjs, Winsock;

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

  TAracDizaynService = class(TService)
    SatrancTCPServer: TIdTCPServer;
    IdAntiFreeze1: TIdAntiFreeze;
    IdSchedulerOfThreadDefault1: TIdSchedulerOfThreadDefault;
    procedure SatrancTCPServerConnect(AContext: TIdContext);
    procedure SatrancTCPServerDisconnect(AContext: TIdContext);
    procedure SatrancTCPServerExecute(AContext: TIdContext);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceCreate(Sender: TObject);
    procedure SatrancTCPServerException(AContext: TIdContext;
      AException: Exception);
  private

  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  AracDizaynService: TAracDizaynService;
  Clients         : TList;

implementation

uses IdTCPConnection, IdIOHandlerSocket, IdSocketHandle;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  AracDizaynService.Controller(CtrlCode);
end;

function GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;
type 
  Name = array[0..100] of Char; 
  PName = ^Name; 
var 
  HEnt: pHostEnt; 
  HName: PName; 
  WSAData: TWSAData; 
  i: Integer; 
begin 
  Result := False;     
  if WSAStartup($0101, WSAData) <> 0 then begin 
    WSAErr := 'Winsock yanýt vermiyor."'; 
    Exit; 
  end; 
  IPaddr := ''; 
  New(HName); 
  if GetHostName(HName^, SizeOf(Name)) = 0 then
  begin 
    HostName := StrPas(HName^); 
    HEnt := GetHostByName(HName^); 
    for i := 0 to HEnt^.h_length - 1 do 
     IPaddr :=
      Concat(IPaddr,
      IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.'); 
    SetLength(IPaddr, Length(IPaddr) - 1); 
    Result := True; 
  end
  else begin 
   case WSAGetLastError of
    WSANOTINITIALISED:WSAErr:='WSANotInitialised'; 
    WSAENETDOWN      :WSAErr:='WSAENetDown'; 
    WSAEINPROGRESS   :WSAErr:='WSAEInProgress'; 
   end; 
  end; 
  Dispose(HName); 
  WSACleanup; 
end;

procedure AddLog(s: string);
var
  sList: TStringList;
begin
  try
    sList:= TStringList.Create;
    if FileExists(ExtractFilePath(ParamStr(0))+'eLogs.dat') then
      sList.LoadFromFile(ExtractFilePath(ParamStr(0))+'eLogs.dat');
    if sList.Count > 5000 then
      DeleteFile(ExtractFilePath(ParamStr(0))+'eLogs.dat');
    sList.Add(DateTimeToStr(now)+' '+s);
    sList.SaveToFile(ExtractFilePath(ParamStr(0))+'eLogs.dat');
  finally
    sList.Free;
  end;
end;


function TAracDizaynService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TAracDizaynService.SatrancTCPServerConnect(AContext: TIdContext);
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
  on E: Exception do
    AddLog('Hata :SatrancTCPServerConnect -- '+ E.Message);
end;

end;

procedure TAracDizaynService.SatrancTCPServerDisconnect(AContext: TIdContext);
var
  Client: TClient;
begin
try
  Client := TClient(AContext.Data);

  Clients.Remove(Client);

  Client.Free;
  AContext.Data := nil;
except
  on E: Exception do
    AddLog('Hata :SatrancTCPServerDisconnect -- '+ E.Message);
end;

end;

procedure TAracDizaynService.SatrancTCPServerExecute(AContext: TIdContext);
var
  lineStr,str,command,roomlist: string;
  Client: TClient;
  RakipUniqID: string;
  cmdList: TStringList;
  i,MasaKullaniciSayisi: integer;
  MasaKullaniciList: Array[0..27] of integer;
begin
    try

      MasaKullaniciSayisi := 0;
      lineStr := AContext.Connection.IOHandler.ReadLn;
      if lineStr = '' then exit;
      if Pos('>',lineStr) = 0 then exit;
      command := copy(lineStr,1,Pos('>',lineStr)-1);
      str     := trim(copy(lineStr,Pos('>',lineStr)+1,length(lineStr)));
      if command = 'SETID' then
      begin
        Client := TClient(AContext.Data);
        Client.UniqID := str;
        AContext.Data := Client;
      end else if command = 'SETMASAID' then
      begin
        Client := TClient(AContext.Data);
        Client.MasaID := str;
        AContext.Data := Client;
        for i := 0 to Clients.Count -1 do
        begin
          if (TClient(Clients[i]).MasaID = str) and (TClient(Clients[i]).UniqID <> Client.UniqID) then
          begin
            RakipUniqID := TClient(Clients[i]).UniqID;
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn('SETALICIID>'+Client.UniqID);
          end;
          if TClient(Clients[i]).MasaID = str then
            inc(MasaKullaniciSayisi);
        end;

        for i := 0 to Clients.Count -1 do
        begin
          if (TClient(Clients[i]).MasaID = str) and (TClient(Clients[i]).UniqID = Client.UniqID) then
          begin
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn('SETALICIID>'+RakipUniqID);
          end;
        end;

        for i := 0 to Clients.Count -1 do
        begin
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn('MASAKULNICISAYISI>'+str+'/'+IntToStr(MasaKullaniciSayisi));
        end;

      end else if command = 'MOVEOBJECT' then
      begin
        cmdList:= TStringList.Create;
        cmdList.Text := StringReplace(str,'/',#13#10,[rfReplaceAll]);
        for i := 0 to Clients.Count -1 do
        begin
          if TClient(Clients[i]).UniqID = cmdList[1] then
          begin
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn('MOVEOBJECT>'+str);
          end;
        end;
      end else if command = 'NEWGAME' then
      begin
        Client := TClient(AContext.Data);
        for i := 0 to Clients.Count -1 do
        begin
          if (TClient(Clients[i]).MasaID = str) and (TClient(Clients[i]).UniqID <> Client.UniqID) then
          begin
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn('NEWGAME>'+Client.UniqID);
          end;
        end;
      end else if command = 'NEWGAME_APPROVED' then
      begin
        Client := TClient(AContext.Data);
        for i := 0 to Clients.Count -1 do
        begin
          if (TClient(Clients[i]).MasaID = str) and (TClient(Clients[i]).UniqID <> Client.UniqID) then
          begin
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn('NEWGAME_APPROVED>'+Client.UniqID);
          end;
        end;
      end else if command = 'NEWGAME_NOTAPPROVED' then
      begin
        Client := TClient(AContext.Data);
        for i := 0 to Clients.Count -1 do
        begin
          if (TClient(Clients[i]).MasaID = str) and (TClient(Clients[i]).UniqID <> Client.UniqID) then
          begin
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn('NEWGAME_NOTAPPROVED>'+Client.UniqID);
          end;
        end;
      end else if command = 'GAME_ROOM_LIST' then
      begin
        for i:= 0 to 27 do
          MasaKullaniciList[i] := 0;
          
        roomlist := 'GAME_ROOM_LIST>';
        for i := 0 to Clients.Count -1 do
        begin
          if TClient(Clients[i]).MasaID <> '' then
            MasaKullaniciList[StrToInt(TClient(Clients[i]).MasaID)-1] := MasaKullaniciList[StrToInt(TClient(Clients[i]).MasaID)-1] +1;

        end;

        for i := 0 to 27 do
          if i< 27 then
            roomlist := roomlist + IntToStr(i)+'='+IntToStr(MasaKullaniciList[i])+'/'
          else
            roomlist := roomlist + IntToStr(i)+'='+IntToStr(MasaKullaniciList[i]);

        for i := 0 to Clients.Count -1 do
        begin
          if (TClient(Clients[i]).UniqID = str) then
          begin
            TClient(Clients[i]).Thread.Connection.IOHandler.WriteLn(roomlist);
          end;
        end;

      end;
      
    except
      on E: Exception do  begin
        AddLog('Hata :SatrancTCPServerExecute -- '+ E.Message);
      end;
    end;
end;


procedure TAracDizaynService.ServiceAfterInstall(Sender: TService);
var
  Key: string;
  Reg: TRegistry;
begin
  Key := '\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Self.Name;
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(Key, True) then
    begin
      Reg.WriteString('EventMessageFile', ParamStr(0));
      Reg.WriteInteger('TypesSupported', 7);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;

end;

procedure TAracDizaynService.ServiceAfterUninstall(Sender: TService);
var
  Reg: TRegistry;
  Key: string;
begin
  // Delete registry entries for event viewer.
  Key := '\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Self.Name;
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.KeyExists(Key) then
      Reg.DeleteKey(Key);
  finally
    Reg.Free;
  end;

end;

procedure TAracDizaynService.ServiceExecute(Sender: TService);
begin
  while not Terminated do
    ServiceThread.ProcessRequests(True);
end;


procedure TAracDizaynService.ServiceDestroy(Sender: TObject);
var
  i: integer;
begin

  SatrancTCPServer.Active := false;
  SatrancTCPServer.Free;
  
  for i := Clients.Count -1 downto 0 do
  begin
    TObject(Clients.Items[i]).Free;
    Clients.Delete(i);
  end;

  Clients.Free;
end;

procedure TAracDizaynService.ServiceCreate(Sender: TObject);
begin
  Clients := TList.Create;
  SatrancTCPServer.DefaultPort := 15420;
  with SatrancTCPServer.Bindings.Add do
  begin
    Port := 15420;
  end;

  SatrancTCPServer.OnConnect  := SatrancTCPServerConnect;
  SatrancTCPServer.OnDisconnect:= SatrancTCPServerDisconnect;
  SatrancTCPServer.OnExecute   := SatrancTCPServerExecute;
  SatrancTCPServer.Active      := true;


end;

procedure TAracDizaynService.SatrancTCPServerException(AContext: TIdContext;
  AException: Exception);
var
  Client: TClient;
begin
  Client := TClient(AContext.Data);

  Clients.Remove(Client);

  Client.Free;
  AContext.Data := nil;

  AddLog('Hata :SatrancTCPServerException -- '+ AException.Message);

end;

end.
