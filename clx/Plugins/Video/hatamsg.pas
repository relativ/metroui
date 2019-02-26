unit hatamsg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QExtCtrls;

type
  TfrmMessage = class(TForm)
    BackgroundImage: TImage;
    MsgLabel: TLabel;
    LblYes: TLabel;
    LblNo: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LblNoClick(Sender: TObject);
    procedure LblYesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function PngDrawBmp(filename: string): TBitmap;
  public
    { Public declarations }
  end;

var
  frmMessage: TfrmMessage;

implementation

{$R *.xfm}

function TfrmMessage.PngDrawBmp(filename: string): TBitmap;
var
  Png: TBitmap;
  Bmp: TBitmap;
begin
  if FileExists(filename) then
  begin
    Png:= TBitmap.Create;
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

procedure TfrmMessage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmMessage.LblNoClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmMessage.LblYesClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmMessage.FormCreate(Sender: TObject);
begin
  BackgroundImage.Picture.Bitmap.Assign(PngDrawBmp(ExtractFilePath(GetModuleName(HInstance))+'Skin\screen\yesno_off.png'));
end;

end.
