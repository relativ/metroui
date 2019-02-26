program video;

uses
  Forms,
  main in 'main.pas' {frmVideo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmVideo, frmVideo);
  Application.Run;
end.
