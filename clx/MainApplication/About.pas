unit About;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QExtCtrls;

type
  TfrmAboutBox = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    CloseLabel: TLabel;
    Image2: TImage;
    procedure CloseLabelClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAboutBox: TfrmAboutBox;

implementation

uses main;

{$R *.xfm}

procedure TfrmAboutBox.CloseLabelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAboutBox.FormPaint(Sender: TObject);
var
  PngOffObj: TBitmap;
  BmpOff   : TBitmap;
  BackPath : string;
begin
  BackPath := MainForm.Settings.SkinPath + '\dialogs\okbox_down.png';
  PngOffObj := TBitmap.Create;
  PngOffObj.LoadFromFile(BackPath);

  BmpOff := TBitmap.Create;
  BmpOff.Width := PngOffObj.Width;
  BmpOff.Height := PngOffObj.Height;
  BmpOff.Canvas.Brush.Style := bsSolid;
  BmpOff.Canvas.Brush.Color := clBtnFace;
  BmpOff.Canvas.FillRect(Rect(0, 0, PngOffObj.Width, PngOffObj.Height));
  BmpOff.Canvas.Draw(0, 0, PngOffObj);
  BmpOff.Canvas.Pixels[0, BmpOff.Height-1] := clBtnFace;

  Canvas.StretchDraw(ClientRect,BmpOff);
  PngOffObj.Free;
  BmpOff.Free;

end;

end.
