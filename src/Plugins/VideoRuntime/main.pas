unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TfrmVideo = class(TForm)
  private
    procedure DrawFormTop;
    procedure DrawFormMiddle;
    procedure DrawFormBottom;
  public
    { Public declarations }
  end;

var
  frmVideo: TfrmVideo;

implementation

{$R *.dfm}

const
  InterfacePath = 'D:\projeler\metro_test\compiled\client\Plugins\Video\Skin\';
  ButtonsPath   = 'buttons/';
  ScreenPath    = 'screen/';

  //-------------Screen--------------------------
  TopBackground     = 'top_bar.png';
  BottomBackground  = 'top_bar.png';
  YesNoDialog       = 'yesno_off.png';

  //---------------------------------------------

  //-------------Buttons-------------------------
  BtnPlay       = 'play.png';
  BtnPause      = 'pause.png';
  BtnStop       = 'stop.png';
  BtnRewind     = 'rewind.png';
  BtnForward    = 'forward.png';
  BtnVolumeInc  = 'volume_inc.png';
  BtnVolumeDec  = 'volume_dec.png';
  BtnVolumeOpen = 'volume_open.png';
  BtnVolumeClose= 'volume_close.png';
  BtnPlayList   = 'playlist.png';
  BtnBackFolder = 'upfolder.png';
  BtnBackFrame  = 'gerisar.png';
  BtnNextFrame  = 'ilerisar.png';
  BtnFullScreen = 'fullscreen.png';
  BtnClose      = 'close.png';

  BtnVideo      = 'video.png';
  //--------------------------------------------

procedure TfrmVideo.DrawFormTop;
begin

end;

procedure TfrmVideo.DrawFormMiddle;
begin

end;

procedure TfrmVideo.DrawFormBottom;
begin

end;

end.
