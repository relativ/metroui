unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Vcl.Imaging.pngimage, ExtCtrls, Buttons;

type
  TfrmMain = class(TForm)
    Image1: TImage;
    BtnVolumeDown: TSpeedButton;
    BtnVolumeUp: TSpeedButton;
    BtnVolumeMute: TSpeedButton;
    BtnMusicPrev: TSpeedButton;
    BtnMusicPlay: TSpeedButton;
    BtnMusicNext: TSpeedButton;
    BtnFullScreen: TSpeedButton;
    BtnBrigthness: TSpeedButton;
    BtnClose: TSpeedButton;
    BtnUpFile: TSpeedButton;
    BtnBottomFile: TSpeedButton;
    BtnUpFolder: TSpeedButton;
    PlayerPanel: TPanel;
    procedure FormPaint(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
  private
    function PngDrawBmp(filename: string): TBitmap;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

function TfrmMain.PngDrawBmp(filename: string): TBitmap;
var
  Png: TPNGObject;
  Bmp: TBitmap;
begin
  if FileExists(filename) then
  begin
    Png:= TPNGObject.Create;
    Png.LoadFromFile(filename);

    Bmp := TBitmap.Create;
    Bmp.Width := Png.Width;
    Bmp.Height := Png.Height;
    Bmp.Canvas.Brush.Style := bsSolid;
    Bmp.Canvas.Brush.Color := clBtnFace;
    Bmp.Canvas.FillRect(Rect(0, 0, Png.Width, Png.Height));
    Bmp.Canvas.Draw(0, 0, Png);
    Bmp.Canvas.Pixels[0, Bmp.Height-1] := clBtnFace;
    Png.Free;
    Result := Bmp;
  end else Result := nil;
end;

procedure TfrmMain.FormPaint(Sender: TObject);
var
  Bmp: TBitmap;
  path: string;
begin
  path := ExtractFilePath(GetModuleName(HInstance))+'Skin\screen\main_off.png';
  Bmp := PngDrawBmp(path);
  Canvas.Draw(0,0,Bmp);
end;

procedure TfrmMain.BtnCloseClick(Sender: TObject);
begin
  Hide;
end;

end.
