unit navigasyon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, Vcl.Imaging.pngimage, teForm, TransEff, teTimed, teMasked,
  teCircle, Buttons;

type
  TfrmNavigasyon = class(TForm)
    NavImage: TImage;
    TransitionList1: TTransitionList;
    Transition: TCircleTransition;
    FormTransitions: TFormTransitions;
    ustOrta: TImage;
    altOrtaImg: TImage;
    CloseBtn: TSpeedButton;
    CloseImg: TImage;
    yanCizgiImg: TImage;
    sagCizgiImg: TImage;
    procedure closeBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNavigasyon: TfrmNavigasyon;

implementation

{$R *.dfm}

procedure TfrmNavigasyon.closeBtnClick(Sender: TObject);
begin
  close;
end;

end.
