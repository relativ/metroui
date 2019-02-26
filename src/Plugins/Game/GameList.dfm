object frmGameList: TfrmGameList
  Left = 200
  Top = 79
  BorderStyle = bsNone
  Caption = 'Oyun Listesi'
  ClientHeight = 480
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object BackgroundImage: TImage
    Left = 0
    Top = 0
    Width = 640
    Height = 480
    Align = alClient
    Stretch = True
  end
  object BtnDown: TSpeedButton
    Left = 0
    Top = 408
    Width = 57
    Height = 73
    Flat = True
  end
  object BtnUp: TSpeedButton
    Left = 58
    Top = 408
    Width = 57
    Height = 73
    Flat = True
  end
  object BtnClose: TSpeedButton
    Left = 576
    Top = 407
    Width = 63
    Height = 73
    Flat = True
    OnClick = BtnCloseClick
  end
  object MenuItem1: TLabel
    Left = 33
    Top = 119
    Width = 624
    Height = 41
    AutoSize = False
    Caption = 'Satran'#231
    Color = clBlack
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWhite
    Font.Height = -29
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = True
    OnClick = MenuItem1Click
  end
  object MenuItem2: TLabel
    Tag = 1
    Left = 33
    Top = 165
    Width = 624
    Height = 41
    AutoSize = False
    Caption = 'Okey'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWhite
    Font.Height = -29
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object MenuItem3: TLabel
    Tag = 2
    Left = 33
    Top = 209
    Width = 624
    Height = 41
    AutoSize = False
    Caption = 'Tavla'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWhite
    Font.Height = -29
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object MenuItem4: TLabel
    Tag = 3
    Left = 33
    Top = 254
    Width = 624
    Height = 41
    AutoSize = False
    Caption = 'Araba Yar'#305#351#305
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWhite
    Font.Height = -29
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Label1: TLabel
    Left = 24
    Top = 44
    Width = 593
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Oyunlar'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWhite
    Font.Height = -35
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
end
