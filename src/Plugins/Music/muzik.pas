unit muzik;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Vcl.Imaging.pngimage, ExtCtrls, TechGradPanel, jpeg, MPlayer, JvExForms,
  JvBaseThumbnail, JvThumbViews, TechGradScroll, MediaPanel, functionList,
  teSlide, TransEff, teTimed, teBmpMsk, teForm, teMasked, teIntrlc, teFuse,
  ShellApi,IniFiles,
  AstechVideoWindow, Buttons, AppEvnts;

type
  TfrmMuzik = class(TForm)
    FormTransitions: TFormTransitions;
    TransitionList1: TTransitionList;
    Transition: TInterlacedTransition;
    ustCizgiImg: TImage;
    yanCizgiImg: TImage;
    altCizgiImg: TImage;
    sagCizgiImg: TImage;
    ustPanel: TPanel;
    ustOrta: TImage;
    playImg: TImage;
    pauseImg: TImage;
    stopImg: TImage;
    soundIncImg: TImage;
    soundDecImg: TImage;
    soundImg: TImage;
    btnPlay: TSpeedButton;
    pauseBtn: TSpeedButton;
    btnStop: TSpeedButton;
    btnVolume_arti: TSpeedButton;
    btnVolume_eksi: TSpeedButton;
    btnVolumeMute: TSpeedButton;
    rewindImg: TImage;
    forwardImg: TImage;
    rewindBtn: TSpeedButton;
    forwardBtn: TSpeedButton;
    altPanel: TPanel;
    altOrtaImg: TImage;
    playlistImg: TImage;
    playlistBtn: TSpeedButton;
    soundClosed: TImage;
    videoImg: TImage;
    KapamaPaneli: TTechGradPanel;
    CloseImg: TImage;
    CloseBtn: TSpeedButton;
    playlistPanel: TTechGradPanel;
    BackFolderImg: TImage;
    BackFolderBtn: TSpeedButton;
    soundOpen: TImage;
    playListTmp: TImage;
    DirectoryParentPanel: TPanel;
    ApplicationEvents: TApplicationEvents;
    procedure FormShow(Sender: TObject);
    procedure DirectoryPanelItemButtonClickEvent(Sender: TObject; Checked: boolean;
      FileName: String);
    procedure btnVolumeMuteClick(Sender: TObject);
    procedure btnVolume_artiClick(Sender: TObject);
    procedure btnVolume_eksiClick(Sender: TObject);
    procedure BackFolderBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStopClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure TransitionAfterTransition(Sender: TObject);
    procedure pauseBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure playlistBtnClick(Sender: TObject);
    procedure PlayerComplate(Sender: TObject);
    procedure forwardBtnClick(Sender: TObject);
    procedure rewindBtnClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
  private
    BaseFolder: string;
    var_Muzik_Sira_No: integer;
    Mute,FullScreen: boolean;
    sMuzikList: TStringList;
    SelectedFile: string;
    VolumeValue: integer;
    DirectoryListIsActive: boolean;
    DirectoryPanel: TTechDirectoryPanel;
    pausedMusic: boolean;
    isEffect : boolean;
    isPlaying: boolean;
    Player: TAstechVideoWindow;
    procedure LoadTemplate;
    procedure DirectoryPanelClick(Sender: TObject; Checked: boolean; FileName: string);
  public
    DefaultFileName: string;

  end;

var
  frmMuzik: TfrmMuzik;

implementation


{$R *.dfm}


procedure TfrmMuzik.LoadTemplate;
begin
  //boþ sonra devam
end;

procedure TfrmMuzik.FormShow(Sender: TObject);
begin
  LoadTemplate;
  var_Muzik_Sira_No := 0;
  if not isEffect then
  begin
    isEffect := true;
    Player.StartAudioEffect;
  end;
end;

procedure TfrmMuzik.DirectoryPanelItemButtonClickEvent(Sender: TObject; Checked: boolean;
  FileName: String);
var
  i: integer;
begin
  if DirectoryExists(FileName) then
  begin
    DirectoryPanel.Directory := FileName;
    for i := 0 to sMuzikList.Count -1 do
      DirectoryPanel.ItemCheckedWithFileName(sMuzikList[i]);
  end; {
  else if (UpperCase(ExtractFileExt(FileName)) <> '.MP3') and (UpperCase(ExtractFileExt(FileName)) <> '.WAV') then
    ShellExecute(handle,'open',pchar(FileName),nil,nil,SW_SHOWMAXIMIZED)
  else begin
    Player.StartAudioEffect;
    Player.FileName := FileName;
    Player.Open;
    Player.Play;
  end;  }
end;

procedure TfrmMuzik.btnVolumeMuteClick(Sender: TObject);
begin
  Mute := not Mute;
  if Mute then
  begin
    soundImg.Picture.Assign(soundClosed.Picture);
  end
  else begin
    soundImg.Picture.Assign(soundOpen.Picture);
  end;
  SetMute(Mute);
end;

procedure TfrmMuzik.btnVolume_artiClick(Sender: TObject);
var
  vol : integer;
begin
  vol := GetVolume + 10;
  if vol > 100 then vol := 100;
  SetVolume(vol,GetBalance);
end;

procedure TfrmMuzik.btnVolume_eksiClick(Sender: TObject);
var
  vol : integer;
begin
  vol := GetVolume - 10;
  if vol < 0 then vol := 0;
  SetVolume(vol,GetBalance);
end;

procedure TfrmMuzik.BackFolderBtnClick(Sender: TObject);
var
  updir: string;
  i: integer;
begin
  updir := UpFolder(BaseFolder, DirectoryPanel.Directory);
  if updir <> '' then
  begin
    DirectoryPanel.Directory := updir;
    for i := 0 to sMuzikList.Count -1 do
      DirectoryPanel.ItemCheckedWithFileName(sMuzikList[i]);
  end;
end;

procedure TfrmMuzik.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMuzik.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    DirectoryPanel.Free;
    DirectoryPanel := nil;
end;

procedure TfrmMuzik.btnStopClick(Sender: TObject);
begin
  isPlaying := false;
  pausedMusic := false;
  Player.Stop;
end;

procedure TfrmMuzik.btnPlayClick(Sender: TObject);
begin
  isPlaying := true;
  if (sMuzikList.Count > 0) and (not pausedMusic) then
  begin
    Player.FileName := sMuzikList[var_Muzik_Sira_No];
    Player.Open;
  end;
  Player.Play;

end;

procedure TfrmMuzik.TransitionAfterTransition(Sender: TObject);
var
  i: integer;
  folder: string;
  ini: TIniFile;
begin
    ini:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
    folder := ini.ReadString('GENERAL','MEDIADIR',ExtractFilePath(GetModuleName(HInstance))+'..\..\Media\Music\');
    ini.Free;
    BaseFolder := folder;
    DirectoryPanel:= TTechDirectoryPanel.Create(Self);
    DirectoryPanel.Parent := DirectoryParentPanel;
    DirectoryPanel.GradBegin := clBlack;
    DirectoryPanel.GradEnd   := clBlack;
    DirectoryPanel.Top  :=  0;
    DirectoryPanel.Width := DirectoryParentPanel.Width;
    DirectoryPanel.Left := 0;
    DirectoryPanel.Height := DirectoryParentPanel.Height;
    DirectoryPanel.ScrollButton := true;
    DirectoryPanel.Transparent := false;
    DirectoryPanel.MenuImage := true;
    DirectoryPanel.Directory := folder;
    DirectoryPanel.OnItemButtonClickEvent := DirectoryPanelItemButtonClickEvent;
    DirectoryPanel.OnItemClickEvent := DirectoryPanelClick;
    for i := 0 to sMuzikList.Count -1 do
      DirectoryPanel.ItemCheckedWithFileName(sMuzikList[i]);
    DirectoryListIsActive := true;
  //  playlistImg.Picture.Assign(videoImg.Picture);

 // playlistPanel.Visible := pagelist.ActivePage = 'playlist';
//  pageList.ActivePage := 'video';
  if DefaultFileName <> '' then
  begin
    Player.FileName := DefaultFileName;
    Player.Open;
    Player.Play;
  end;
end;

procedure TfrmMuzik.pauseBtnClick(Sender: TObject);
begin
  pausedMusic := Player.isPlaying;
  Player.Pause;
end;

procedure TfrmMuzik.DirectoryPanelClick(Sender: TObject; Checked: boolean; FileName: string);
begin
  if sMuzikList.IndexOf(FileName) < 0 then
  begin
    if Checked then
      sMuzikList.Add(FileName);
  end else begin
    if not Checked then
      sMuzikList.Delete(sMuzikList.IndexOf(FileName));
  end;
end;

procedure TfrmMuzik.FormCreate(Sender: TObject);
begin
  sMuzikList:= TStringList.Create;
  Player:= TAstechVideoWindow.Create(Self);
  Player.Parent := KapamaPaneli;
  Player.Align := alNone;
  Player.Height := 73;
  Player.Width := 73;
  Player.Top   := 6;
  Player.Left  := 41;
  Player.OnComplate := PlayerComplate;
end;

procedure TfrmMuzik.FormDestroy(Sender: TObject);
begin
  Player.Stop;
  Player.Free;
  sMuzikList.Free;
end;

procedure TfrmMuzik.playlistBtnClick(Sender: TObject);
begin
 // pageList.PageIndex := (pageList.PageIndex -1) * -1;  
end;

procedure TfrmMuzik.PlayerComplate(Sender: TObject);
begin
  inc(var_Muzik_Sira_No);
  if sMuzikList.Count = var_Muzik_Sira_No then var_Muzik_Sira_No := 0;

  Player.FileName := sMuzikList[var_Muzik_Sira_No];
  Player.Open;
  Player.Play;
end;

procedure TfrmMuzik.forwardBtnClick(Sender: TObject);
begin
  pausedMusic := false;
  if var_Muzik_Sira_No + 1 = sMuzikList.Count then
    var_Muzik_Sira_No := 0
  else
    inc(var_Muzik_Sira_No);

  btnPlayClick(Sender);
end;

procedure TfrmMuzik.rewindBtnClick(Sender: TObject);
begin
  pausedMusic := false;
  if var_Muzik_Sira_No -1 = -1 then
    var_Muzik_Sira_No := sMuzikList.Count -1
  else
    Dec(var_Muzik_Sira_No);

  btnPlayClick(Sender);
end;

procedure TfrmMuzik.ApplicationEventsException(Sender: TObject;
  E: Exception);
begin
  E := nil;
end;

end.
