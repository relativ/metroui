unit confirmmsg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Vcl.Imaging.pngimage, ExtCtrls;

type
  TfrmConfirmMessage = class(TForm)
    BackgroundImage: TImage;
    MsgLabel: TLabel;
    LblYes: TLabel;
    procedure LblYesClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    function PngDrawBmp(filename: string): TBitmap;
  public
    { Public declarations }
  end;

var
  frmConfirmMessage: TfrmConfirmMessage;

implementation

{$R *.dfm}

function TfrmConfirmMessage.PngDrawBmp(filename: string): TBitmap;
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

procedure TfrmConfirmMessage.LblYesClick(Sender: TObject);
begin
  close;
end;

procedure TfrmConfirmMessage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmConfirmMessage.FormCreate(Sender: TObject);
begin
  BackgroundImage.Picture.Bitmap.Assign(PngDrawBmp(ExtractFilePath(GetModuleName(HInstance))+'Skin\screen\okbox_off.png'));
end;

end.
