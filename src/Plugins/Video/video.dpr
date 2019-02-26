library video;


uses
  SysUtils,
  Classes,
  Forms,
  main in 'main.pas' {frmVideo},
  hatamsg in 'hatamsg.pas' {frmMessage};

{$R *.res}

function ShowVideoForm: TForm; stdcall; export;
begin
  frmVideo:= TfrmVideo.Create(nil);
  Result := frmVideo;
end;

exports
  ShowVideoForm;

begin


end.
 