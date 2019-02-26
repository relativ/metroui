program mobiloto;

uses
  QForms,
  main in 'main.pas' {MainForm},
  ButtonEventList in 'ButtonEventList.pas',
  Configuration in 'Configuration.pas',
  MainSkinRect in 'MainSkinRect.pas',
  pluginlist in 'pluginlist.pas',
  SkinBase in 'SkinBase.pas',
  Skins in 'Skins.pas',
  volume in 'volume.pas',
  About in 'About.pas' {frmAboutBox},
  PluginForm in 'PluginForm.pas' {frmPluginForm};

{$R *.res}

begin
  
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmAboutBox, frmAboutBox);
  Application.Run;
end.
