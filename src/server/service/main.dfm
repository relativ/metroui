object AracDizaynService: TAracDizaynService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  AllowPause = False
  DisplayName = 'Astech Arac Dizayn TCP Service'
  AfterInstall = ServiceAfterInstall
  AfterUninstall = ServiceAfterUninstall
  OnExecute = ServiceExecute
  Left = 307
  Top = 161
  Height = 299
  Width = 420
  object SatrancTCPServer: TIdTCPServer
    Bindings = <>
    DefaultPort = 15420
    ListenQueue = 50
    MaxConnections = 200
    OnConnect = SatrancTCPServerConnect
    OnDisconnect = SatrancTCPServerDisconnect
    OnException = SatrancTCPServerException
    Scheduler = IdSchedulerOfThreadDefault1
    OnExecute = SatrancTCPServerExecute
    Left = 40
    Top = 8
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 136
    Top = 8
  end
  object IdSchedulerOfThreadDefault1: TIdSchedulerOfThreadDefault
    MaxThreads = 200
    Left = 248
    Top = 8
  end
end
