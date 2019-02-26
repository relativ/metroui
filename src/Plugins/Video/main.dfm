object frmVideo: TfrmVideo
  Left = 299
  Top = 132
  BorderStyle = bsNone
  Caption = 'Video'
  ClientHeight = 380
  ClientWidth = 696
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ustPanel: TPanel
    Left = 0
    Top = 0
    Width = 696
    Height = 294
    Align = alClient
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 0
    object ustOrta: TImage
      Left = 0
      Top = 0
      Width = 696
      Height = 83
      Align = alTop
      Stretch = True
    end
    object playImg: TImage
      Left = 9
      Top = 3
      Width = 64
      Height = 72
      Stretch = True
    end
    object pauseImg: TImage
      Left = 87
      Top = 3
      Width = 66
      Height = 72
      Stretch = True
    end
    object stopImg: TImage
      Left = 167
      Top = 3
      Width = 66
      Height = 72
      Stretch = True
    end
    object soundIncImg: TImage
      Left = 407
      Top = 3
      Width = 66
      Height = 69
      Stretch = True
    end
    object soundDecImg: TImage
      Left = 487
      Top = 3
      Width = 66
      Height = 69
      Stretch = True
    end
    object soundImg: TImage
      Left = 564
      Top = 3
      Width = 62
      Height = 69
      Stretch = True
    end
    object btnPlay: TSpeedButton
      Left = 8
      Top = 3
      Width = 65
      Height = 73
      Flat = True
      OnClick = btnPlayClick
    end
    object pauseBtn: TSpeedButton
      Left = 80
      Top = 3
      Width = 73
      Height = 73
      Flat = True
      OnClick = pauseBtnClick
    end
    object btnStop: TSpeedButton
      Left = 160
      Top = 3
      Width = 73
      Height = 73
      Flat = True
      OnClick = btnStopClick
    end
    object btnVolume_arti: TSpeedButton
      Left = 400
      Top = 3
      Width = 73
      Height = 73
      Flat = True
      OnClick = btnVolume_artiClick
    end
    object btnVolume_eksi: TSpeedButton
      Left = 480
      Top = 3
      Width = 73
      Height = 73
      Flat = True
      OnClick = btnVolume_eksiClick
    end
    object btnVolumeMute: TSpeedButton
      Left = 560
      Top = 3
      Width = 73
      Height = 73
      Flat = True
      OnClick = btnVolumeMuteClick
    end
    object rewindImg: TImage
      Left = 247
      Top = 3
      Width = 66
      Height = 72
      Stretch = True
    end
    object forwardImg: TImage
      Left = 327
      Top = 3
      Width = 66
      Height = 74
      Stretch = True
    end
    object rewindBtn: TSpeedButton
      Left = 240
      Top = 3
      Width = 73
      Height = 73
      Flat = True
      OnClick = rewindBtnClick
    end
    object forwardBtn: TSpeedButton
      Left = 320
      Top = 3
      Width = 73
      Height = 73
      Flat = True
      OnClick = forwardBtnClick
    end
    object pageList: TNotebook
      Left = 0
      Top = 83
      Width = 696
      Height = 211
      Align = alClient
      Color = clBlack
      ParentColor = False
      TabOrder = 0
      OnPageChanged = pageListPageChanged
      object TPage
        Left = 0
        Top = 0
        Caption = 'playlist'
        object DirectoryParentPanel: TPanel
          Left = 0
          Top = 0
          Width = 696
          Height = 211
          Align = alClient
          BevelOuter = bvNone
          Color = clBlack
          TabOrder = 0
        end
      end
      object TPage
        Left = 0
        Top = 0
        Caption = 'video'
        object VideoBackPanel: TPanel
          Left = 0
          Top = 0
          Width = 696
          Height = 211
          Align = alClient
          BevelOuter = bvNone
          Caption = 'VideoBackPanel'
          Color = clBlack
          TabOrder = 0
        end
      end
    end
  end
  object altPanel: TPanel
    Left = 0
    Top = 294
    Width = 696
    Height = 86
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      696
      86)
    object altOrtaImg: TImage
      Left = 0
      Top = 0
      Width = 696
      Height = 86
      Align = alClient
      Stretch = True
    end
    object VideoBackImage: TImage
      Left = 242
      Top = 8
      Width = 70
      Height = 70
      AutoSize = True
    end
    object btnGeri: TSpeedButton
      Left = 240
      Top = 6
      Width = 73
      Height = 73
      Flat = True
      OnClick = btnGeriClick
    end
    object VideoNextImage: TImage
      Left = 322
      Top = 8
      Width = 70
      Height = 70
      Stretch = True
    end
    object btnIleri: TSpeedButton
      Left = 320
      Top = 5
      Width = 73
      Height = 73
      Flat = True
      OnClick = btnIleriClick
    end
    object KapamaPaneli: TPanel
      Left = 528
      Top = 0
      Width = 168
      Height = 86
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 0
      object FullScreenImg: TImage
        Left = 9
        Top = 8
        Width = 71
        Height = 71
        AutoSize = True
      end
      object CloseImg: TImage
        Left = 90
        Top = 8
        Width = 70
        Height = 70
        AutoSize = True
      end
      object CloseBtn: TSpeedButton
        Left = 88
        Top = 6
        Width = 73
        Height = 73
        Flat = True
        OnClick = CloseBtnClick
      end
      object btnFullScreen: TSpeedButton
        Left = 8
        Top = 6
        Width = 73
        Height = 73
        Flat = True
        OnClick = btnFullScreenClick
      end
    end
    object playlistPanel: TPanel
      Left = 0
      Top = 0
      Width = 161
      Height = 86
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object BackFolderImg: TImage
        Left = 81
        Top = 7
        Width = 71
        Height = 71
        AutoSize = True
      end
      object BackFolderBtn: TSpeedButton
        Left = 80
        Top = 6
        Width = 73
        Height = 73
        Flat = True
        OnClick = BackFolderBtnClick
      end
      object playlistImg: TImage
        Left = 8
        Top = 5
        Width = 64
        Height = 75
        AutoSize = True
      end
      object playlistBtn: TSpeedButton
        Left = 8
        Top = 6
        Width = 65
        Height = 73
        Flat = True
        OnClick = playlistBtnClick
      end
    end
  end
  object FormTransitions: TFormTransitions
    DestroyTransitions = False
    ShowTransition = Transition
    Left = 328
    Top = 216
  end
  object TransitionList1: TTransitionList
    Left = 400
    Top = 224
    object Transition: TInterlacedTransition
      Milliseconds = 1000
    end
  end
  object ApplicationEvents: TApplicationEvents
    OnException = ApplicationEventsException
    Left = 432
    Top = 168
  end
end
