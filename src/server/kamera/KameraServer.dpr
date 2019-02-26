program KameraServer;

uses
  Forms,
  video in 'video.pas' {frmKamera};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmKamera, frmKamera);
  Application.Run;
end.
