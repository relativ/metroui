library music;


uses
  SysUtils,
  Classes,
  Forms,
  muzik in 'muzik.pas' {frmMuzik};

{$R *.res}

function ShowMusicForm: TForm; stdcall; export;
begin
  frmMuzik:= TfrmMuzik.Create(nil);
  Result := frmMuzik;
end;

exports
  ShowMusicForm;

begin


end.
 