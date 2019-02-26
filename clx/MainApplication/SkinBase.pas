unit SkinBase;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QComCtrls, QExtCtrls, JvSimpleXml, Vcl.Imaging.pngimage, ButtonEventList;

type
  TSkinBase = class(TComponent)
  private
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

constructor TSkinBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TSkinBase.Destroy;
begin
  inherited Destroy;
end;

end.
 