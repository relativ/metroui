unit Satranc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Vcl.Imaging.pngimage, ExtCtrls, Buttons, ChessBrd, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IniFiles, AppEvnts, StdCtrls;

type
  TCommands = (MoveObject,SETALICIID,MASAKULNICISAYISI,NEWGAME,NEWGAME_APPROVED,NEWGAME_NOTAPPROVED,GAME_ROOM_LIST);

  TfrmSatranc = class(TForm)
    PageList: TNotebook;
    ImagePanel: TPanel;
    Panel1: TPanel;
    MasalarPanel: TPanel;
    btnBilgisayaraKarsi: TSpeedButton;
    btnMultiPlayer: TSpeedButton;
    IdTCPClient: TIdTCPClient;
    readLn: TTimer;
    check_connection_timer: TTimer;
    ImageStartGame: TImage;
    BtnStartGame: TSpeedButton;
    BtnMasa1: TSpeedButton;
    BtnMasa2: TSpeedButton;
    BtnMasa3: TSpeedButton;
    BtnMasa4: TSpeedButton;
    BtnMasa5: TSpeedButton;
    BtnMasa6: TSpeedButton;
    BtnMasa7: TSpeedButton;
    BtnMasa8: TSpeedButton;
    BtnMasa9: TSpeedButton;
    BtnMasa10: TSpeedButton;
    BtnMasa11: TSpeedButton;
    BtnMasa12: TSpeedButton;
    BtnMasa13: TSpeedButton;
    BtnMasa14: TSpeedButton;
    BtnMasa15: TSpeedButton;
    BtnMasa16: TSpeedButton;
    BtnMasa17: TSpeedButton;
    BtnMasa18: TSpeedButton;
    BtnMasa19: TSpeedButton;
    BtnMasa20: TSpeedButton;
    BtnMasa21: TSpeedButton;
    BtnMasa22: TSpeedButton;
    BtnMasa23: TSpeedButton;
    BtnMasa24: TSpeedButton;
    BtnMasa25: TSpeedButton;
    BtnMasa26: TSpeedButton;
    BtnMasa27: TSpeedButton;
    BtnMasa28: TSpeedButton;
    ChessBrd: TChessBrd;
    maskImg: TImage;
    LabelStatus: TLabel;
    BtnClose1: TSpeedButton;
    Image1: TImage;
    BtnMasaList: TSpeedButton;
    Image2: TImage;
    BtnKapat2: TSpeedButton;
    BtnClose2: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnCloseClick(Sender: TObject);
    procedure btnBilgisayaraKarsiClick(Sender: TObject);
    procedure btnMultiPlayerClick(Sender: TObject);
    procedure BtnMasaListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure check_connection_timerTimer(Sender: TObject);
    procedure readLnTimer(Sender: TObject);
    procedure IdTCPClientConnected(Sender: TObject);
    procedure IdTCPClientDisconnected(Sender: TObject);
    procedure ChessBrdLegalMove(Sender: TObject; oldSq, newSq: Square);
    procedure BtnStartGameClick(Sender: TObject);
    procedure PageListPageChanged(Sender: TObject);
    procedure BtnMasa1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure maskImgClick(Sender: TObject);
    procedure ChessBrdMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChessBrdMate(Sender: TObject; oldSq, newSq: Square);
    procedure ChessBrdStaleMate(Sender: TObject; oldSq, newSq: Square);
    procedure ChessBrdCheck(Sender: TObject; oldSq, newSq: Square);
  private
    MasaKullaniciSayisi: Array[0..27] of integer;
    UniqID,AliciID,TasRengi: string;
    GameType: integer;
    MasaNo: integer;
    ChessSelected: boolean;
    SelectedHamle: Square;
    function PngDrawBmp(filename: string): TBitmap;
    procedure CommandHandler(str: string);
    function GetCommandID(command: string): integer;
    procedure ObjectsParser(str: string);

  public
    { Public declarations }
  end;

var
  frmSatranc: TfrmSatranc;

const
  CommandsStr : array[0..6] of string =('MOVEOBJECT','SETALICIID','MASAKULNICISAYISI',
                                        'NEWGAME','NEWGAME_APPROVED','NEWGAME_NOTAPPROVED',
                                        'GAME_ROOM_LIST');

implementation

uses hatamsg, confirmmsg, GameList;

{$R *.dfm}

function GetConfig(const Section, Ident, Default: string): string;
var
  IniFile: TIniFile;
begin
  IniFile:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
  result := IniFile.ReadString(Section, Ident, Default);
  IniFile.Free;
end;

function TfrmSatranc.PngDrawBmp(filename: string): TBitmap;
var
  Png: TPNGObject;
  Bmp: TBitmap;
begin
  if FileExists(filename) then
  begin
    Png:= TPNGObject.Create;
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

procedure TfrmSatranc.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmGameList.DrawBackgound;
  Action := caFree;
end;

procedure TfrmSatranc.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSatranc.btnBilgisayaraKarsiClick(Sender: TObject);
begin
  GameType := 1;
  ChessBrd.ComputerPlaysWhite := false;
  ChessBrd.ComputerPlaysBlack := true;
  PageList.ActivePage := 'Satranc';
end;

procedure TfrmSatranc.btnMultiPlayerClick(Sender: TObject);
begin
  GameType := 2;
  if IdTCPClient.Connected then
  begin
    IdTCPClient.IOHandler.WriteLn('GAME_ROOM_LIST>'+UniqID);
  end else begin
    frmConfirmMessage := TfrmConfirmMessage.Create(nil);
    frmConfirmMessage.MsgLabel.Caption := 'Baðlantý olmadýðý için karþýlýklý oynayamazsýnýz.';
    frmConfirmMessage.ShowModal;
  end;
end;

procedure TfrmSatranc.BtnMasaListClick(Sender: TObject);
begin
  if GameType = 2 then
  begin
    frmMessage := TfrmMessage.Create(nil);
    frmMessage.MsgLabel.Caption := 'Masadan çýkmak istediðinizden eminmisiniz ?';
    if frmMessage.ShowModal = mrOk then
    begin
      IdTCPClient.IOHandler.WriteLn('SETMASAID>0');
      PageList.ActivePage := 'Giris';
    end;
  end else
    PageList.ActivePage := 'Giris';
end;

procedure TfrmSatranc.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
begin
  BtnMasa1.Caption := 'Masa 1';
  BtnMasa2.Caption := 'Masa 2';
  BtnMasa3.Caption := 'Masa 3';
  BtnMasa4.Caption := 'Masa 4';
  BtnMasa5.Caption := 'Masa 5';
  BtnMasa6.Caption := 'Masa 6';
  BtnMasa7.Caption := 'Masa 7';
  BtnMasa8.Caption := 'Masa 8';
  BtnMasa9.Caption := 'Masa 9';
  BtnMasa10.Caption := 'Masa 10';
  BtnMasa11.Caption := 'Masa 11';
  BtnMasa12.Caption := 'Masa 12';
  BtnMasa13.Caption := 'Masa 13';
  BtnMasa14.Caption := 'Masa 14';
  BtnMasa15.Caption := 'Masa 15';
  BtnMasa16.Caption := 'Masa 16';
  BtnMasa17.Caption := 'Masa 17';
  BtnMasa18.Caption := 'Masa 18';
  BtnMasa19.Caption := 'Masa 19';
  BtnMasa20.Caption := 'Masa 20';
  BtnMasa21.Caption := 'Masa 21';
  BtnMasa22.Caption := 'Masa 22';
  BtnMasa23.Caption := 'Masa 23';
  BtnMasa24.Caption := 'Masa 24';
  BtnMasa25.Caption := 'Masa 25';
  BtnMasa26.Caption := 'Masa 26';
  BtnMasa27.Caption := 'Masa 27';
  BtnMasa28.Caption := 'Masa 28';

//  TopImage.Picture.Bitmap := PngDrawBmp(ExtractFilePath(GetModuleName(HInstance))+'Skin\screen\fullexternal_off_secondary.png');

  Ini:= TIniFile.Create(ExtractFilePath(GetModuleName(HInstance))+'config.ini');
  IdTCPClient.Host := Ini.ReadString('TCP','ServerIP','127.0.0.1');
  IdTCPClient.Port := Ini.ReadInteger('TCP','ChessPort',15420);
  UniqID           := Ini.ReadString('TCP','KoltukNo','');
  Ini.Free;

  maskImg.Width := ChessBrd.SizeOfSquare;
  maskImg.Height := ChessBrd.SizeOfSquare;

  
end;

procedure TfrmSatranc.check_connection_timerTimer(Sender: TObject);
begin
try
  check_connection_timer.Enabled := false;
  if not IdTCPClient.Connected then
  begin
    IdTCPClient.Connect;
    if IdTCPClient.Connected then
    begin
      IdTCPClient.IOHandler.WriteLn('SETID>'+UniqID);
    end;
  end;
  check_connection_timer.Enabled := true;
except
  check_connection_timer.Enabled := true;
end;
end;

procedure TfrmSatranc.readLnTimer(Sender: TObject);
var
  Msg: string;
begin
try
  readLn.Enabled := false;
  if IdTCPClient.Connected then
  begin
    Msg := IdTCPClient.IOHandler.ReadLn;
    Msg := Trim(Msg);
    if Msg <> '' then
    begin
      CommandHandler(Msg);
    end;
  end;
  readLn.Enabled := true;
except
  readLn.Enabled := true;
end;
end;

procedure TfrmSatranc.IdTCPClientConnected(Sender: TObject);
begin
  readLn.Enabled := true;
end;

procedure TfrmSatranc.IdTCPClientDisconnected(Sender: TObject);
begin
  readLn.Enabled := false;
end;

function TfrmSatranc.GetCommandID(command: string): integer;
var
  i: integer;
begin
  result := -1;
  for i := low(CommandsStr) to High(CommandsStr) do
    if CommandsStr[i] = command then
    begin
      Result := i;
      break;
    end;
end;

procedure TfrmSatranc.CommandHandler(str: string);
var
  lineStr,command_s,txt: string;
  Command: TCommands;
  strList: TStringList;
  i,cint: integer;
  masaID,deger: integer;
begin
  lineStr   := str;
  command_s := copy(lineStr,1,Pos('>',lineStr)-1);
  txt       := trim(copy(lineStr,Pos('>',lineStr)+1,length(lineStr)));
  cint      := GetCommandID(command_s);
  Command   := TCommands(cint);
  case Command of
    MoveObject:
      begin
        ObjectsParser(txt);
      end;
    SETALICIID:
      begin
        if UniqID <> txt then
          AliciID := txt;
      end;
    MASAKULNICISAYISI:
      begin
        strList:= TStringList.Create;
        strList.Text := StringReplace(txt,'/',#13#10,[rfReplaceAll]);
        masaID := StrToInt(strList[0]);
        deger  := StrToInt(strList[1]);
        strList.Free;
        MasaKullaniciSayisi[masaID-1] := deger;
        case masaID of
          1: begin
            BtnMasa1.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa1.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          2: begin
            BtnMasa2.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa2.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          3: begin
            BtnMasa3.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa3.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          4: begin
            BtnMasa4.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa4.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          5: begin
            BtnMasa5.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa5.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          6: begin
            BtnMasa6.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa6.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          7: begin
            BtnMasa7.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa7.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          8: begin
            BtnMasa8.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa8.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          9: begin
            BtnMasa9.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa9.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          10: begin
            BtnMasa10.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa10.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          11: begin
            BtnMasa11.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa11.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          12: begin
            BtnMasa12.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa12.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          13: begin
            BtnMasa13.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa13.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          14: begin
            BtnMasa14.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa14.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          15: begin
            BtnMasa15.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa15.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          16: begin
            BtnMasa16.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa16.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          17: begin
            BtnMasa17.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa17.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          18: begin
            BtnMasa18.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa18.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          19: begin
            BtnMasa19.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa19.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          20: begin
            BtnMasa20.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa20.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          21: begin
            BtnMasa21.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa21.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          22: begin
            BtnMasa22.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa22.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          23: begin
            BtnMasa23.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa23.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          24: begin
            BtnMasa24.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa24.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          25: begin
            BtnMasa25.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa25.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          26: begin
            BtnMasa26.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa26.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          27: begin
            BtnMasa27.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa27.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          28: begin
            BtnMasa28.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa28.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
        end;
      end;
    NEWGAME:
      begin
        frmMessage := TfrmMessage.Create(nil);
        frmMessage.MsgLabel.Caption := 'Karþý taraf yeniden oynamak istiyor kabul ediyor musunuz ?';
        if frmMessage.ShowModal = mrOk then
        begin
          IdTCPClient.IOHandler.WriteLn('NEWGAME_APPROVED>'+IntToStr(MasaNo));
          ChessBrd.NewGame;
        end else begin
          IdTCPClient.IOHandler.WriteLn('NEWGAME_NOTAPPROVED>'+IntToStr(MasaNo));
        end;
      end;
    NEWGAME_APPROVED:
      begin
        ChessBrd.NewGame;
      end;

    NEWGAME_NOTAPPROVED:
      begin
        frmConfirmMessage := TfrmConfirmMessage.Create(nil);
        frmConfirmMessage.MsgLabel.Caption := 'Yeni oyun talebiniz kabul edilmedi.';
        frmConfirmMessage.ShowModal;
      end;
    GAME_ROOM_LIST:
      begin
        strList:= TStringList.Create;
        strList.Text := StringReplace(txt,'/',#13#10,[rfReplaceAll]);
        for i := 0 to 27 do
          MasaKullaniciSayisi[i] := 0;
          
        for i := 0 to strList.Count -1 do
          MasaKullaniciSayisi[StrToInt(strList.Names[i])] := StrToInt(strList.ValueFromIndex[i]);

        strList.Free;

        for masaID := 1 to 28 do
        case masaID of
          1: begin
            BtnMasa1.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa1.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          2: begin
            BtnMasa2.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa2.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          3: begin
            BtnMasa3.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa3.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          4: begin
            BtnMasa4.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa4.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          5: begin
            BtnMasa5.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa5.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          6: begin
            BtnMasa6.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa6.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          7: begin
            BtnMasa7.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa7.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          8: begin
            BtnMasa8.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa8.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          9: begin
            BtnMasa9.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa9.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          10: begin
            BtnMasa10.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa10.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          11: begin
            BtnMasa11.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa11.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          12: begin
            BtnMasa12.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa12.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          13: begin
            BtnMasa13.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa13.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          14: begin
            BtnMasa14.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa14.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          15: begin
            BtnMasa15.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa15.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          16: begin
            BtnMasa16.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa16.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          17: begin
            BtnMasa17.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa17.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          18: begin
            BtnMasa18.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa18.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          19: begin
            BtnMasa19.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa19.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          20: begin
            BtnMasa20.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa20.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          21: begin
            BtnMasa21.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa21.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          22: begin
            BtnMasa22.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa22.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          23: begin
            BtnMasa23.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa23.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          24: begin
            BtnMasa24.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa24.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          25: begin
            BtnMasa25.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa25.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          26: begin
            BtnMasa26.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa26.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          27: begin
            BtnMasa27.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa27.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
          28: begin
            BtnMasa28.Enabled := MasaKullaniciSayisi[masaID-1] < 2;
            BtnMasa28.Caption := 'Masa '+ IntToStr(masaID) + ' ['+IntToStr(MasaKullaniciSayisi[masaID -1])+']';
          end;
        end;
        PageList.ActivePage := 'Masalar';
      end;
  end;
end;

procedure TfrmSatranc.ObjectsParser(str: string);
var
  ObjStr: TStringList;
  TasRengi: string;
  OldPos,NewPos: string;
  OldSq,NewSq: Square;
begin
  ObjStr:= TStringList.Create;
  ObjStr.Text := StringReplace(str,'/',#13#10,[rfReplaceAll]);
  TasRengi := ObjStr[2];
  OldPos   := ObjStr[3];
  NewPos   := ObjStr[4];
  OldSq    := ChessBrd.StringToSquare(OldPos);
  NewSq    := ChessBrd.StringToSquare(NewPos);
  ChessBrd.Move(OldSq,NewSq);
end;

procedure TfrmSatranc.ChessBrdLegalMove(Sender: TObject; oldSq,
  newSq: Square);
const
  SquareStr: Array[0..64] of string = ('None', 'A8','B8','C8','D8','E8','F8','G8','H8',
                                      'A7','B7','C7','D7','E7','F7','G7','H7',
                                      'A6','B6','C6','D6','E6','F6','G6','H6',
                                      'A5','B5','C5','D5','E5','F5','G5','H5',
                                      'A4','B4','C4','D4','E4','F4','G4','H4',
                                      'A3','B3','C3','D3','E3','F3','G3','H3',
                                      'A2','B2','C2','D2','E2','F2','G2','H2',
                                      'A1','B1','C1','D1','E1','F1','G1','H1');
var
  OldPos,NewPos,PostStr: string;
begin
  if GameType = 2 then
  begin
    if AliciID <> '' then
    begin
      if IdTCPClient.Connected then
      begin
        OldPos := SquareStr[integer(oldSq)];
        NewPos := SquareStr[integer(newSq)];
        PostStr := 'MOVEOBJECT>'+UniqID+'/'+AliciID+'/'+TasRengi+'/'+OldPos+'/'+NewPos;
        IdTCPClient.IOHandler.WriteLn(PostStr);
      end;
    end;
  end;
end;

procedure TfrmSatranc.BtnStartGameClick(Sender: TObject);
begin
  if GameType = 2 then
  begin
    if IdTCPClient.Connected then
    begin
      IdTCPClient.IOHandler.WriteLn('NEWGAME>'+IntToStr(MasaNo));
    end;
  end else
    ChessBrd.NewGame;
end;

procedure TfrmSatranc.PageListPageChanged(Sender: TObject);
begin
  if PageList.ActivePage = 'Satranc' then
      ChessBrd.NewGame;
end;

procedure TfrmSatranc.BtnMasa1Click(Sender: TObject);
begin
  if IdTCPClient.Connected then
  begin
    IdTCPClient.IOHandler.WriteLn('SETMASAID>'+IntToStr(TSpeedButton(Sender).Tag));
    MasaKullaniciSayisi[TSpeedButton(Sender).Tag -1] := MasaKullaniciSayisi[TSpeedButton(Sender).Tag -1] + 1;
    if MasaKullaniciSayisi[TSpeedButton(Sender).Tag -1] = 2 then
      ChessBrd.WhiteOnTop := true
    else
      ChessBrd.WhiteOnTop := false;
    ChessBrd.ComputerPlaysBlack := false;
    ChessBrd.ComputerPlaysWhite := false;
    MasaNo := TSpeedButton(Sender).Tag;
    PageList.ActivePage := 'Satranc';
  end else begin
    frmConfirmMessage := TfrmConfirmMessage.Create(nil);
    frmConfirmMessage.MsgLabel.Caption := 'Baðlantý olmadýðý için oyun baþlatýlamadý.';
    frmConfirmMessage.ShowModal;
  end;
end;

procedure TfrmSatranc.FormShow(Sender: TObject);
begin
  frmGameList.ClearBackgound;
  check_connection_timer.Enabled := true;
end;

procedure TfrmSatranc.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  E := nil;
end;

procedure TfrmSatranc.maskImgClick(Sender: TObject);
begin
  ChessSelected := false;
  maskImg.Visible := false;
  SelectedHamle := None;
end;

procedure TfrmSatranc.ChessBrdMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  newSq: Square;
  xpos,ypos: integer;
  cwhite,Accept: boolean;
begin
  LabelStatus.Caption := '';
  if ChessSelected then
  begin
    if SelectedHamle = ChessBrd.WindowToSquare(X,Y) then
      SelectedHamle := None
    else begin
      newSq := ChessBrd.WindowToSquare(X,Y);
      ChessBrd.MoveWaitComputer := true;
      ChessBrd.Move(SelectedHamle,newSq);
    end;
    ChessSelected := false;
    SelectedHamle := None;
    maskImg.Visible := false;
  end else begin
    SelectedHamle := ChessBrd.WindowToSquare(X,Y);
    cwhite := not ChessBrd.WhiteOnTop;
    if cwhite then
      Accept := ChessBrd.SquareIsWhite(SelectedHamle)
    else
      Accept := not ChessBrd.SquareIsWhite(SelectedHamle);

    if Accept then
    begin
      ChessSelected := true;
      ChessBrd.SquareToCoords(SelectedHamle,xpos,ypos);

      maskImg.Left := xpos + ChessBrd.Left;
      maskImg.Top := ypos + ChessBrd.Top;
      maskImg.Visible := true;
      maskImg.BringToFront;
    end else SelectedHamle := None;
  end;

end;

procedure TfrmSatranc.ChessBrdMate(Sender: TObject; oldSq, newSq: Square);
begin
  LabelStatus.Caption := 'MAT';
  frmMessage := TfrmMessage.Create(nil);
  frmMessage.MsgLabel.Caption := 'Oyun bitti. Yeniden oynamak istermisiniz ?';
  if frmMessage.ShowModal = mrOk then
    ChessBrd.NewGame
  else
    PageList.ActivePage := 'Giris';
end;

procedure TfrmSatranc.ChessBrdStaleMate(Sender: TObject; oldSq,
  newSq: Square);
begin
  frmMessage := TfrmMessage.Create(nil);
  frmMessage.MsgLabel.Caption := 'Berabere kaldýnýz. Tekrar oynamak ister misiniz ?';
  if frmMessage.ShowModal = mrOk then
    ChessBrd.NewGame
  else
    PageList.ActivePage := 'Giris';
end;

procedure TfrmSatranc.ChessBrdCheck(Sender: TObject; oldSq, newSq: Square);
begin
  LabelStatus.Caption := 'ÞAH';
end;

end.
