library web;


uses
  SysUtils,
  Classes,
  Forms,
  browser in 'browser.pas' {frmWeb},
  klavye in 'klavye.pas' {frmKlavye};

{$R *.res}

function ShowBrowserForm: TForm; stdcall; export;
begin
  frmWeb:= TfrmWeb.Create(nil);
  Result := frmWeb;
end;

exports
  ShowBrowserForm;

begin
end.
