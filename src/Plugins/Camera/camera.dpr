library camera;

uses
  SysUtils,
  Classes,
  Forms,
  kamera in 'kamera.pas' {frmKamera};

{$R *.res}

function ShowCameraForm: TForm; stdcall; export;
begin
  frmKamera:= TfrmKamera.Create(nil);
  Result := frmKamera;
end;

exports
  ShowCameraForm;


begin
end.
