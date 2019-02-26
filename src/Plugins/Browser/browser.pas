unit browser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, Vcl.Imaging.pngimage, ExtCtrls, Buttons, StdCtrls,
  TransEff, teTimed, teWipe, teForm, TechGradPanel;

type
  TfrmWeb = class(TForm)
    topImage: TImage;
    bottomImage: TImage;
    WebBrowser: TWebBrowser;
    asagiBtn: TSpeedButton;
    yukariBtn: TSpeedButton;
    klavyeBtn: TSpeedButton;
    solBtn: TSpeedButton;
    sagBtn: TSpeedButton;
    durBtn: TSpeedButton;
    yenileBtn: TSpeedButton;
    adresLabel: TLabel;
    closeBtn: TSpeedButton;
    FormTransitions: TFormTransitions;
    TransitionList1: TTransitionList;
    Transition: TWipeTransition;
    ScrollingPanel: TPanel;
    procedure durBtnClick(Sender: TObject);
    procedure yenileBtnClick(Sender: TObject);
    procedure klavyeBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure closeBtnClick(Sender: TObject);
    procedure yukariBtnClick(Sender: TObject);
    procedure solBtnClick(Sender: TObject);
    procedure asagiBtnClick(Sender: TObject);
    procedure sagBtnClick(Sender: TObject);
    procedure ScrollingPanelMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ScrollingPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrollingPanelMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure TransitionAfterTransition(Sender: TObject);
  private
    ScrollingBrowser: boolean;
  public
    { Public declarations }
  end;

var
  frmWeb: TfrmWeb;

implementation

uses klavye;

{$R *.dfm}

procedure TfrmWeb.durBtnClick(Sender: TObject);
begin
  WebBrowser.Stop;
end;

procedure TfrmWeb.yenileBtnClick(Sender: TObject);
begin
  WebBrowser.Refresh;
end;

procedure TfrmWeb.klavyeBtnClick(Sender: TObject);
begin
  if Application.FindComponent('frmKlavye') = nil then
    Application.CreateForm(TfrmKlavye, frmKlavye);
    
  if frmKlavye.ShowModal = mrOk then
  begin
    if frmKlavye.Text <> '' then
    begin
      adresLabel.Caption := frmKlavye.Text;
      WebBrowser.Navigate(frmKlavye.Text);
    end;
  end;
end;

procedure TfrmWeb.FormShow(Sender: TObject);
begin
  adresLabel.Width := Width;
end;

procedure TfrmWeb.closeBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmWeb.yukariBtnClick(Sender: TObject);
begin
  WebBrowser.OleObject.Document.ParentWindow.ScrollBy(0, -100); 
end;

procedure TfrmWeb.solBtnClick(Sender: TObject);
begin
try
  WebBrowser.GoBack;
except

end;
  //WebBrowser.OleObject.Document.ParentWindow.ScrollBy(-100, 0);
end;

procedure TfrmWeb.asagiBtnClick(Sender: TObject);
begin

  WebBrowser.OleObject.Document.ParentWindow.ScrollBy(0, +100);
end;

procedure TfrmWeb.sagBtnClick(Sender: TObject);
begin
try
  WebBrowser.GoForward;
except

end;
  //WebBrowser.OleObject.Document.ParentWindow.ScrollBy(+100, 0);
end;

procedure TfrmWeb.ScrollingPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ScrollingBrowser := true;
end;

procedure TfrmWeb.ScrollingPanelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ScrollingBrowser := false;
end;

procedure TfrmWeb.ScrollingPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  webheight, step, pos: integer;
begin
  if ScrollingBrowser then
  begin
    if WebBrowser.LocationURL <> '' then
    begin
      webheight := WebBrowser.OleObject.Document.ParentWindow.Screen.Height;
      step      := webheight div ScrollingPanel.Height;
      pos       := step * Y;
      WebBrowser.OleObject.Document.ParentWindow.scroll(0,pos);
    end;
  end;
end;

procedure TfrmWeb.TransitionAfterTransition(Sender: TObject);
begin
  ScrollingPanel.Repaint;
end;

end.
