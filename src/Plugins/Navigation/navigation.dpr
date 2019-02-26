library navigation;

uses
  SysUtils,
  Classes,
  Forms,
  navigasyon in 'navigasyon.pas' {frmNavigasyon};

{$R *.res}

function ShowNavigationForm: TForm; stdcall; export;
begin
  frmNavigasyon:= TfrmNavigasyon.Create(nil);
  Result := frmNavigasyon;
end;

exports
  ShowNavigationForm;

begin
end.
