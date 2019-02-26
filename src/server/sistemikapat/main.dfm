object Form1: TForm1
  Left = 322
  Top = 197
  BorderStyle = bsSingle
  Caption = 'Sistemi Kapat'
  ClientHeight = 160
  ClientWidth = 451
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 24
    Top = 32
    Width = 401
    Height = 89
    Caption = 'Sistemi Kapat'
    Font.Charset = TURKISH_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object MainIdTCPServer: TIdTCPServer
    Bindings = <>
    DefaultPort = 15419
    ListenQueue = 50
    MaxConnections = 200
    OnConnect = MainIdTCPServerConnect
    OnDisconnect = MainIdTCPServerDisconnect
    OnException = MainIdTCPServerException
    Scheduler = IdSchedulerOfThreadDefault2
    OnExecute = MainIdTCPServerExecute
    Left = 40
    Top = 64
  end
  object IdSchedulerOfThreadDefault2: TIdSchedulerOfThreadDefault
    MaxThreads = 200
    Left = 248
    Top = 64
  end
end
