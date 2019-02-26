program AracDizaynServis;

uses
  SvcMgr,
  main in 'main.pas' {AracDizaynService: TService};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TAracDizaynService, AracDizaynService);
  Application.Run;
end.
