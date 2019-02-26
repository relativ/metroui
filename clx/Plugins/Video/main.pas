unit main;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QNotebook, QButtons,
  QAstechVideoWindow, QDirectoryPanel, IniFiles, functionList;

type
  TfrmVideo = class(TForm)
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
    pageList: TNotebook;
    DirectoryParentPanel: TPanel;
    VideoBackPanel: TPanel;
    altPanel: TPanel;
    altOrtaImg: TImage;
    VideoBackImage: TImage;
    btnGeri: TSpeedButton;
    VideoNextImage: TImage;
    btnIleri: TSpeedButton;
    KapamaPaneli: TPanel;
    FullScreenImg: TImage;
    CloseImg: TImage;
    CloseBtn: TSpeedButton;
    btnFullScreen: TSpeedButton;
    playlistPanel: TPanel;
    BackFolderImg: TImage;
    BackFolderBtn: TSpeedButton;
    playlistImg: TImage;
    playlistBtn: TSpeedButton;

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
    procedure pauseBtnClick(Sender: TObject);
    procedure pageListPageChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure playlistBtnClick(Sender: TObject);
    procedure PlayerComplate(Sender: TObject);
    procedure forwardBtnClick(Sender: TObject);
    procedure rewindBtnClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure btnFullScreenClick(Sender: TObject);
    procedure btnGeriClick(Sender: TObject);
    procedure btnIleriClick(Sender: TObject);
  private
    PlayListTmp, VideoImgTmp, VolumeCloseImgTmp,VolumeOpenImgTmp: TBitmap;
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
    Player: TLinVideoWindow;
    ilkBaslangic: boolean;
    procedure LoadTemplate;
    procedure PlayerPosition(Sender: TObject; Pos,Max: integer);
    procedure DirectoryPanelClick(Sender: TObject; Checked: boolean; FileName: string);
  public
    DefaultFileName: string;
  end;

var
  frmVideo: TfrmVideo;

implementation

uses hatamsg;

{$R *.xfm}

procedure TfrmVideo.LoadTemplate;
var
  Path,SPath: string;
begin
  Path := ExtractFilePath(GetModuleName(HInstance))+'Skin\buttons\';
  SPath:= ExtractFilePath(GetModuleName(HInstance))+'Skin\screen\';

  PlayListTmp := TBitmap.Create;
  VideoImgTmp := TBitmap.Create;
  VolumeCloseImgTmp := TBitmap.Create;
  VolumeOpenImgTmp  := TBitmap.Create;

  PlayListTmp.LoadFromFile(Path + 'playlist.png');
  VideoImgTmp.LoadFromFile(Path + 'video.png');
  VolumeCloseImgTmp.LoadFromFile(Path + 'volume_close.png');
  VolumeOpenImgTmp.LoadFromFile(Path + 'volume_open.png');

  playImg.Picture.LoadFromFile(Path + 'play.png');
  pauseImg.Picture.LoadFromFile(Path + 'pause.png');
  stopImg.Picture.LoadFromFile(Path + 'stop.png');
  rewindImg.Picture.LoadFromFile(Path + 'rewind.png');
  forwardImg.Picture.LoadFromFile(Path + 'forward.png');
  soundIncImg.Picture.LoadFromFile(Path + 'volume_inc.png');
  soundDecImg.Picture.LoadFromFile(Path + 'volume_dec.png');
  soundImg.Picture.LoadFromFile(Path + 'volume_open.png');
  playlistImg.Picture.LoadFromFile(Path + 'playlist.png');
  BackFolderImg.Picture.LoadFromFile(Path + 'upfolder.png');
  VideoBackImage.Picture.LoadFromFile(Path + 'gerisar.png');
  VideoNextImage.Picture.LoadFromFile(Path + 'ilerisar.png');
  FullScreenImg.Picture.LoadFromFile(Path + 'fullscreen.png');
  CloseImg.Picture.LoadFromFile(Path + 'close.png');
  ustOrta.Picture.LoadFromFile(SPath + 'top_bar.png');
  altOrtaImg.Picture.LoadFromFile(SPath + 'bottom_bar.png');

end;

procedure TfrmVideo.FormShow(Sender: TObject);
var
  ini: TIniFile;
  pos: integer;
  videofile: string;
begin
  LoadTemplate;
  var_Muzik_Sira_No := 0;
  if not isEffect then
  begin
    isEffect := true;
    Player.StopAudioEffect;
  end;
  
  pageList.ActivePage := 'playlist';
  if DefaultFileName <> '' then
  begin
    Player.FileName := DefaultFileName;
    Player.Open;
    Player.Play;
  end else begin
    if ilkBaslangic then
    begin
      ilkBaslangic := false;
      ini:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
      pos := ini.ReadInteger('CONTROL','POSITION',0);
      videofile := ini.ReadString('CONTROL','FILENAME','');
      ini.Free;
      if (pos > 0) and (videofile <> '') then
      begin
        frmMessage := TfrmMessage.Create(nil);
        frmMessage.MsgLabel.Caption := 'Yarým býraktýðýnýz video görüntüsüne kaldýðýnýz yerden devam etmek ister misiniz?';
        if frmMessage.ShowModal = mrOk then
        begin
          Player.FileName := videofile;
          Player.Open;
          Player.Play;
          Sleep(50);
          Player.SetPosition(pos);
        end;
      end;
    end;
  end;
end;

procedure TfrmVideo.DirectoryPanelItemButtonClickEvent(Sender: TObject; Checked: boolean;
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

procedure TfrmVideo.btnVolumeMuteClick(Sender: TObject);
begin
  Mute := not Mute;
  if Mute then
  begin
    soundImg.Picture.Assign(VolumeCloseImgTmp);
  end
  else begin
    soundImg.Picture.Assign(VolumeOpenImgTmp);
  end;
 // SetMute(Mute);
end;

procedure TfrmVideo.btnVolume_artiClick(Sender: TObject);
var
  vol : integer;
begin
  //vol := GetVolume + 10;
  if vol > 100 then vol := 100;
 // SetVolume(vol,GetBalance);
end;

procedure TfrmVideo.btnVolume_eksiClick(Sender: TObject);
var
  vol : integer;
begin
//  vol := GetVolume - 10;
  if vol < 0 then vol := 0;
 // SetVolume(vol,GetBalance);
end;

procedure TfrmVideo.BackFolderBtnClick(Sender: TObject);
var
  updir: string;
  i: integer;
begin
  updir := UpFolder(BaseFolder,DirectoryPanel.Directory);
  if updir <> '' then
  begin
    DirectoryPanel.Directory := updir;
    for i := 0 to sMuzikList.Count -1 do
      DirectoryPanel.ItemCheckedWithFileName(sMuzikList[i]);
  end;
end;

procedure TfrmVideo.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVideo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if DirectoryPanel <> nil then
  begin
    DirectoryPanel.Free;
    DirectoryPanel := nil;
  end;
end;

procedure TfrmVideo.btnStopClick(Sender: TObject);
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
  ini.WriteInteger('CONTROL','POSITION',0);
  ini.WriteString('CONTROL','FILENAME','');
  ini.Free;
  isPlaying := false;
  pausedMusic := false;
  Player.Stop;
end;

procedure TfrmVideo.btnPlayClick(Sender: TObject);
begin
  isPlaying := true;
  if (sMuzikList.Count > 0) and (not pausedMusic) then
  begin
    Player.FileName := sMuzikList[var_Muzik_Sira_No];
    Player.Open;
  end;
  Player.Play;

end;

procedure TfrmVideo.pauseBtnClick(Sender: TObject);
begin
  pausedMusic := Player.isPlaying;
  Player.Pause;
end;

procedure TfrmVideo.DirectoryPanelClick(Sender: TObject; Checked: boolean; FileName: string);
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

procedure TfrmVideo.pageListPageChanged(Sender: TObject);
var
  i: integer;
  ini: TIniFile;
  folder: string;
begin
  if pagelist.ActivePage = 'playlist' then
  begin
    ini:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
    folder := ini.ReadString('GENERAL','MEDIADIR',ExtractFilePath(GetModuleName(HInstance))+'..\..\Media\Video\');
    ini.Free;
    BaseFolder := folder;
    DirectoryPanel:= TTechDirectoryPanel.Create(Self);
    DirectoryPanel.Parent := DirectoryParentPanel;
    DirectoryPanel.Color := clBlack;
    DirectoryPanel.Top  :=  0;
    DirectoryPanel.Width := DirectoryParentPanel.Width;
    DirectoryPanel.Left := 0;
    DirectoryPanel.Height := DirectoryParentPanel.Height;
    DirectoryPanel.ScrollButton := true;
    DirectoryPanel.MenuImage := true;
    DirectoryPanel.Directory := folder;
    DirectoryPanel.OnItemButtonClickEvent := DirectoryPanelItemButtonClickEvent;
    DirectoryPanel.OnItemClickEvent := DirectoryPanelClick;
    for i := 0 to sMuzikList.Count -1 do
      DirectoryPanel.ItemCheckedWithFileName(sMuzikList[i]);
    DirectoryListIsActive := true;
    playlistImg.Picture.Assign(VideoImgTmp);
  end else begin
    DirectoryPanel.Free;
    DirectoryPanel := nil;
    playlistImg.Picture.Assign(PlayListTmp);
  end;
  playlistPanel.Visible := pagelist.ActivePage = 'playlist';
end;

procedure TfrmVideo.FormCreate(Sender: TObject);
begin
  ilkBaslangic := true;
  sMuzikList:= TStringList.Create;
  Player:= TLinVideoWindow.Create(Self);
  Player.Parent := VideoBackPanel;
  Player.Align := alClient;
  Player.OnComplate := PlayerComplate;
  Player.OnPosition := PlayerPosition;
end;

procedure TfrmVideo.FormDestroy(Sender: TObject);
begin
  sMuzikList.Free;
end;

procedure TfrmVideo.playlistBtnClick(Sender: TObject);
begin
  pageList.PageIndex := (pageList.PageIndex -1) * -1;  
end;

procedure TfrmVideo.PlayerComplate(Sender: TObject);
begin
  inc(var_Muzik_Sira_No);
  if sMuzikList.Count = var_Muzik_Sira_No then var_Muzik_Sira_No := 0;

  Player.FileName := sMuzikList[var_Muzik_Sira_No];
  Player.Open;
  Player.Play;
end;

procedure TfrmVideo.forwardBtnClick(Sender: TObject);
begin
  pausedMusic := false;
  if var_Muzik_Sira_No + 1 = sMuzikList.Count then
    var_Muzik_Sira_No := 0
  else
    inc(var_Muzik_Sira_No);

  btnPlayClick(Sender);
end;

procedure TfrmVideo.rewindBtnClick(Sender: TObject);
begin
  pausedMusic := false;
  if var_Muzik_Sira_No -1 = -1 then
    var_Muzik_Sira_No := sMuzikList.Count -1
  else
    Dec(var_Muzik_Sira_No);

  btnPlayClick(Sender);
end;

procedure TfrmVideo.ApplicationEventsException(Sender: TObject;
  E: Exception);
begin
  E := nil;
end;

procedure TfrmVideo.btnFullScreenClick(Sender: TObject);
begin
  Player.StartFullScreen;
end;

procedure TfrmVideo.PlayerPosition(Sender: TObject; Pos,Max: integer);
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
  ini.WriteInteger('CONTROL','POSITION',Pos);
  ini.WriteString('CONTROL','FILENAME',Player.FileName);
  ini.Free;
end;

procedure TfrmVideo.btnGeriClick(Sender: TObject);
var
  pos: integer;
begin
  pos := Player.GetPosition - 4;
  Player.SetPosition(pos);
  Sleep(50);
end;

procedure TfrmVideo.btnIleriClick(Sender: TObject);
var
  pos: integer;
begin
  pos := Player.GetPosition + 4;
  Player.SetPosition(pos);
  Sleep(50);

end;

end.
