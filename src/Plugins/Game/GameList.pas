unit GameList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Vcl.Imaging.pngimage, Buttons, StdCtrls;

type
  TfrmGameList = class(TForm)
    BackgroundImage: TImage;
    BtnDown: TSpeedButton;
    BtnUp: TSpeedButton;
    BtnClose: TSpeedButton;
    MenuItem1: TLabel;
    MenuItem2: TLabel;
    MenuItem3: TLabel;
    MenuItem4: TLabel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
  private
    OyunID: integer;
    function PngDrawBmp(filename: string): TBitmap;
  public
    procedure DrawBackgound;
    procedure ClearBackgound;
  end;

var
  frmGameList: TfrmGameList;

implementation

uses Satranc;

{$R *.dfm}

function TfrmGameList.PngDrawBmp(filename: string): TBitmap;
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

procedure TfrmGameList.DrawBackgound;
begin
  BackgroundImage.Picture.Bitmap := PngDrawBmp(ExtractFilePath(GetModuleName(HInstance))+'Skin\screen\main_off.png');
end;

procedure TfrmGameList.ClearBackgound;
begin
  BackgroundImage.Picture.Bitmap.FreeImage;
end;

procedure TfrmGameList.FormCreate(Sender: TObject);
begin
  OyunID := -1;
  DrawBackgound;
end;

procedure TfrmGameList.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGameList.MenuItem1Click(Sender: TObject);
begin
  frmSatranc := TfrmSatranc.Create(nil);
  frmSatranc.ShowModal;
end;

end.
