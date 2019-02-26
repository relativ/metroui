library game;


uses
  SysUtils,
  Classes,
  Forms,
  GameList in 'GameList.pas' {frmGameList},
  Satranc in 'Satranc.pas' {frmSatranc},
  hatamsg in 'hatamsg.pas' {frmMessage},
  confirmmsg in 'confirmmsg.pas' {frmConfirmMessage};

{$R *.res}

function ShowGameForm(): TForm; stdcall; export;
begin
  frmGameList := TfrmGameList.Create(nil);
  Result := frmGameList;
end;

exports
  ShowGameForm;

begin
end.
