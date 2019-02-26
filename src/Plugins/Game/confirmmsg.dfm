object frmConfirmMessage: TfrmConfirmMessage
  Left = 203
  Top = 123
  BorderStyle = bsNone
  Caption = 'Confirm Message'
  ClientHeight = 244
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object BackgroundImage: TImage
    Left = 0
    Top = 0
    Width = 458
    Height = 244
  end
  object MsgLabel: TLabel
    Left = 24
    Top = 16
    Width = 409
    Height = 113
    AutoSize = False
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWhite
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object LblYes: TLabel
    Left = 156
    Top = 152
    Width = 149
    Height = 61
    Alignment = taCenter
    AutoSize = False
    Caption = 'Tamam'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
    Layout = tlCenter
    OnClick = LblYesClick
  end
end
