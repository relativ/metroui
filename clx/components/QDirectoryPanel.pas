unit QDirectoryPanel;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, Math,
  QButtons;

const
  RT_RCDATA       = Types.RT_RCDATA;
type

  TTechDirectoryPanel = class;
  TTechGradScroll = class;


  TItemClickEvent = procedure(Sender: TObject; Checked: boolean; FileName: string) of object;

  THourPanel = class(TCustomPanel)
  public
    hourglass: TImage;
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;


  TTechPanel = class(TCustomPanel)
  private
    Image,ImageFocus,CheckImage: TImage;
    Png: TBitmap;
    SButton: TSpeedButton;
    lblCaption: TLabel;
    FFileName: string;
    FDosyaAdi: string;
    FImageID: string;
    procedure ItemButtonClick(Sender: TObject);
    procedure ItemImageClick(Sender: TObject);
    procedure ItemlblClick(Sender: TObject);
    procedure SetFileName(val: string);
    procedure SetDosyaAdi(val: string);
    procedure SetImageID(val: string);
    function GetMenuImageWithExt(ext: string): string;
  public
    GradScroll : TTechGradScroll;
    Selected, Checked: boolean;
    Folder  : boolean;
    constructor Create(AOwner: TComponent); override;
    constructor CreateWithParent(AOwner: TComponent; GPanel: TTechGradScroll);
    destructor  Destroy; override;
    procedure SetChecked;
    property FileName: string read FFileName write SetFileName;
    property DosyaAdi: string read FDosyaAdi write SetDosyaAdi;
    property ImageID: string read FImageID write SetImageID;
  end;

  TTechScrollBtn = class(TCustomPanel)
  private
    ImageUst,ImageAlt: TImage;
    FScrolling: boolean;
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    GradScroll: TTechGradScroll;
    procedure AsagiClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure YukariClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

  TTechGradScroll = class(TCustomPanel)
  private
    FList: TList;
    FDirectory: string;
    FItemHeight: integer;
    FMenuImage: boolean;
    FFilter: string;
    FSelectedFileName: string;

    procedure PanelClick(Sender: TObject);
    procedure SetItemHeight(val: integer);
    procedure SetDirectory(dir: string);
    procedure CreateDirList;
//    procedure BuildList;
  protected
    SelectedImage: TImage;
  public
    procedure ItemCheckedWithFileName(fname: string);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Filter   : string read FFilter     write FFilter;
    property MenuImage: boolean read FMenuImage write FMenuImage;
    property ItemHeight: integer read FItemHeight write SetItemHeight;
    property Directory: string read FDirectory write SetDirectory;
    property SelectedFileName: string read FSelectedFileName write FSelectedFileName;
  end;

  TTechDirectoryPanel = class(TCustomPanel)
  private
    TechGradScroll: TTechGradScroll;
    FList: TList;
    FDirectory: string;
    FMenuImage: boolean;
    FScrollButton: boolean;
    FScrollBtn: TTechScrollBtn;
    procedure SetScrollButton(val: boolean);
    procedure SetItemHeight(val: integer);
    function GetItemHeight: integer;
    procedure SetDirectory(dir: string);
    procedure SetFilter(val: string);
    function GetFilter: string;
    procedure SetSelectedFileName(val: string);
    function GetSelectedFileName: string;
    procedure SetMenuImage(val: boolean);
    function GetMenuImage: boolean;
  protected
    FItemClickEvent: TItemClickEvent;
    FItemButtonClickEvent: TItemClickEvent;
    procedure Resize; override;
  public
    CheckedList: TList;
    procedure ItemCheckedWithFileName(fname: string);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Color;
    property ScrollButton: boolean read FScrollButton write SetScrollButton;
    property Filter   : string read GetFilter     write SetFilter;
    property MenuImage: boolean read GetMenuImage write SetMenuImage;
    property ItemHeight: integer read GetItemHeight write SetItemHeight;
    property Directory: string read FDirectory write SetDirectory;
    property SelectedFileName: string read GetSelectedFileName write SetSelectedFileName;
    property OnItemClickEvent: TItemClickEvent read FItemClickEvent write FItemClickEvent;
    property OnItemButtonClickEvent: TItemClickEvent read FItemButtonClickEvent write FItemButtonClickEvent;
 //   property OnMouseWheelDown;
 //   property OnMouseWheelUp;
  end;

procedure Register;

implementation

{$R menu_item.RES}

procedure Register;
begin
  RegisterComponents('Standard', [TTechDirectoryPanel]);
end;

{constructor TDirListThread.CreateWithScroll(CreateSuspended: Boolean; GPanel: TTechGradScroll);
begin
  GradScroll := GPanel;
  Create(CreateSuspended);
end;



destructor TDirListThread.Destroy;
begin
  inherited Destroy;
end;

procedure TDirListThread.Execute;
begin
  CreateDirList;
  Free;

end;  }


procedure LoadBitmapFromResourceStream(ABitmap: TBitmap;
  ResourceStream: TCustomMemoryStream);
var
  TmpStream: TMemoryStream;
  Header: TBitmapFileHeader;
  BmpHeader: TBitMapInfoHeader;
begin
  TmpStream := TMemoryStream.Create;
  try
    // Reads bitmap header
    ResourceStream.ReadBuffer(BmpHeader, SizeOf(BmpHeader));
    ResourceStream.Seek(0, soBeginning);

    // Builds file header
    FillChar(Header, SizeOf(Header), 0);
    Header.bfType := $4D42;
    Header.bfSize := ResourceStream.Size;
    Header.bfReserved1 := 0;
    Header.bfReserved2 := 0;

    if BmpHeader.biBitCount > 8 then
      Header.bfOffBits := sizeof(Header) + sizeof(BmpHeader)
    else
      if BmpHeader.biClrUsed = 0 then
        Header.bfOffBits := sizeof(Header) + sizeof(BmpHeader) +
          (1 shl BmpHeader.biBitCount) * 4
      else
        Header.bfOffBits := sizeof(Header) + sizeof(BmpHeader) +
          BmpHeader.biClrUsed * 4;

    // Concatenates both in TmpStream
    TmpStream.WriteBuffer(Header, SizeOf(Header));
    TmpStream.CopyFrom(ResourceStream, ResourceStream.Size);
    TmpStream.Position := 0;
    ABitmap.LoadFromStream(TmpStream);
  finally
    TmpStream.Free;
  end;
end;

procedure LoadFromResourceName(BMP: TBitmap; Instance: Cardinal;
  const ResName: string);
var
  Stream: TCustomMemoryStream;
begin
  Stream := TResourceStream.Create(Instance, ResName, RT_RCDATA);
  try
    LoadBitmapFromResourceStream(BMP, Stream);
  finally
    Stream.Free;
  end;
end;     

constructor THourPanel.Create(AOwner: TComponent);
var
  Png: TBitmap;
begin
  inherited Create(AOwner);
  Caption := '';
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Png:= TBitmap.Create;
  LoadFromResourceName(Png,HInstance,'HOUR_CLAS');
  hourglass:= TImage.Create(Self);
  hourglass.Parent := Self;
  hourglass.AutoSize := true;
  hourglass.Picture.Assign(Png);

  Self.Width := hourglass.Width;
  Self.Height := hourglass.Height;
  hourglass.Top := 0;
  hourglass.Left:= 0;
  Png.Free;
end;

destructor THourPanel.Destroy;
begin
  hourglass.Free;
  inherited Destroy;
end;


procedure TTechScrollBtn.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FScrolling := true;
end;

procedure TTechScrollBtn.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  tmpY: integer;
  step: integer;
begin
  if FScrolling then
  begin
    tmpY := Y - ImageUst.Height;
    if tmpY > 0 then
    begin
      step := (GradScroll.Height div (Height - (ImageUst.Height + ImageAlt.Height)));
      GradScroll.Top := (tmpY * step) * -1;
      GradScroll.Repaint;
    end;
  end;
end;

procedure TTechScrollBtn.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FScrolling := false;
end;

procedure TTechScrollBtn.YukariClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if GradScroll.Top < 0 then
    GradScroll.Top := GradScroll.Top + 30
  else
    GradScroll.Top := 0;
  GradScroll.Repaint;
end;

procedure TTechScrollBtn.AsagiClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if GradScroll.Top + GradScroll.Height > GradScroll.Parent.Height then
    GradScroll.Top := GradScroll.Top - 30;
  GradScroll.Repaint;
end;

constructor TTechScrollBtn.Create(AOwner: TComponent);
var
  png: TBitmap;
begin
  inherited Create(AOwner);
  BevelInner := bvNone;
  BevelOuter := bvNone;
    png:= TBitmap.Create;
    LoadFromResourceName(png, HInstance,'YUKARI');
    ImageUst := TImage.Create(Self);
    ImageUst.Parent := Self;
    ImageUst.Align := alTop;
    ImageUst.Stretch := true;
    ImageUst.Picture.Assign(png);
    ImageUst.Width := 65;
    ImageUst.Height := 68;
    ImageUst.OnMouseDown := YukariClick;

    LoadFromResourceName(png, HInstance,'ASAGI');
    ImageAlt := TImage.Create(Self);
    ImageAlt.Parent := Self;
    ImageAlt.Align := alBottom;
    ImageAlt.Stretch := true;
    ImageAlt.Picture.Assign(png);
    ImageAlt.Width := 65;
    ImageAlt.Height := 68;
    ImageAlt.OnMouseDown := AsagiClick;
    png.Free;
    Width   := 69;
    Caption := '';

end;

destructor TTechScrollBtn.Destroy;
begin
  ImageUst.Free;
  ImageAlt.Free;
  inherited Destroy;
end;


constructor TTechPanel.CreateWithParent(AOwner: TComponent; GPanel: TTechGradScroll);
begin
  GradScroll := GPanel;
  Create(AOwner);
end;

constructor TTechPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelInner := bvNone;
  BevelOuter := bvNone;
  if GradScroll.MenuImage then
  begin

    Self.Color   := GradScroll.Color;
    Image:= TImage.Create(Self);
    Image.Parent := Self;
    Image.Stretch := true;
    Image.Width  := 530;
    Image.Height := 100;
    //Image.Align  := alClient;

    Image.Top := 0;
    Image.Left := 0;
    Image.OnClick := ItemImageClick;

    ImageFocus := TImage.Create(Self);
    ImageFocus.Parent := Self;
    ImageFocus.Left := 0;
    ImageFocus.Top  := 0;
    ImageFocus.Width := 530;
    ImageFocus.Height := 100;
    ImageFocus.Stretch := true;
    ImageFocus.OnClick := ItemImageClick;

    SButton:= TSpeedButton.Create(Self);
    SButton.Parent := Self;
    SButton.Left := 12;
    SButton.Top  := 12;
    SButton.Width := 78;
    SButton.Height:= 75;
    SButton.Flat  := true;
    SButton.OnClick := ItemButtonClick;
    lblCaption:= TLabel.Create(Self);
    lblCaption.Parent := Self;
    lblCaption.AutoSize := false;
    lblCaption.Font.Assign(Self.Font);
    lblCaption.Left := 106;
    lblCaption.Top  := 15;
    lblCaption.Width  := 410;
    lblCaption.Height := 72;
    lblCaption.WordWrap := true;
    lblCaption.Transparent := true;
    lblCaption.OnClick := ItemlblClick;

    CheckImage := TImage.Create(Self);
    CheckImage.Parent := Self;
    CheckImage.Left   := Width - CheckImage.Width;
    CheckImage.OnClick := ItemImageClick;
    

  end;

end;

destructor TTechPanel.Destroy;
begin
  if TTechGradScroll(Parent).SelectedImage = ImageFocus then
    TTechGradScroll(Parent).SelectedImage := nil;
  lblCaption.Free;
  SButton.Free;
  Image.Free;
  ImageFocus.Free;
  CheckImage.Free;
  GradScroll := nil;
  inherited Destroy;
end;

function TTechPanel.GetMenuImageWithExt(ext: string): string;
begin
  if (ext = '.doc') or (ext = '.rtf') or (ext = '.docx') or (ext = '.docm') or (ext = '.txt') then
    Result := 'MENU_WORD'
  else if (ext = '.pdf') then
    Result := 'MENU_PDF'
  else if (ext = '.avi') or (ext = '.mpg') or (ext = '.mpeg') or (ext = '.wmv') then
    Result := 'MENU_VIDEO'
  else if (ext = '.jpg') or (ext = '.gif') or (ext = '.png') or (ext = '.bmp') then
    Result := 'MENU_FOTO'
  else if (ext = '.mp3') or (ext = '.wav') then
    Result := 'MENU_MUZIK'
  else if (ext = '.exe') or (ext = '.dll') or (ext = '.ocx') then
    Result := 'MENU_UYGULAMA'
  else if (ext = '.xls') or (ext = '.xlsx') or (ext = '.xlsm') or (ext = '.xlsb') or (ext = '.xlam')
     or (ext = '.xltx') or (ext = '.xltm') then
    Result := 'MENU_EXCELL'
  else if Folder then
    Result := 'MENU_FOLDER'
  else
    Result := 'MENU_UNKNOWN';
end;

procedure TTechPanel.SetFileName(val: string);
var
  Png: TBitmap;
  ext: string;
begin
  if FFileName <> val then
  begin
    FFileName := val;
    if GradScroll.MenuImage then
    begin
      ext := LowerCase(ExtractFileExt(FFileName));
      Png:= TBitmap.Create;
      LoadFromResourceName(Png, HInstance,GetMenuImageWithExt(ext));
      Image.Picture.Assign(Png);
      Png.Free;
      Self.Width := Image.Width;
    end;
  end;
end;

procedure TTechPanel.SetDosyaAdi(val: string);
begin
  if FDosyaAdi <> val then
  begin
    FDosyaAdi := val;
    lblCaption.Caption := FDosyaAdi;
  end;
end;

procedure TTechPanel.SetImageID(val: string);
var
  Png: TBitmap;
begin
  FImageID := val;
  Png:= TBitmap.Create;
  LoadFromResourceName(Png, HInstance,val);
  Image.Picture.Assign(Png);
  Png.Free;
end;

procedure TTechPanel.ItemButtonClick(Sender: TObject);
var
  cnt: TWinControl;
  fname: string;
  chk: boolean;
begin
  cnt := Parent.Parent;
  fname := Self.FileName;
  chk := Self.Checked;
  if Assigned(TTechDirectoryPanel(cnt).FItemButtonClickEvent) then TTechDirectoryPanel(cnt).FItemButtonClickEvent(cnt,chk,fname);
  abort;
end;

procedure TTechPanel.ItemImageClick(Sender: TObject);
var
  Png: TBitmap;
  i: integer;
begin
  if TTechGradScroll(Parent).SelectedImage <> nil then
    TTechGradScroll(Parent).SelectedImage.Picture := nil;
    
  TTechGradScroll(Parent).SelectedImage := ImageFocus;
  
  Png:= TBitmap.Create;
  LoadFromResourceName(Png, HInstance,'FOCUS');
  ImageFocus.Picture.Assign(Png);
  Png.Free;
  Checked := not Checked;
  if Checked then
  begin
    Png:= TBitmap.Create;
    LoadFromResourceName(Png, HInstance,'CHECKED');
    CheckImage.AutoSize := true;
    CheckImage.Picture.Assign(Png);
    Png.Free;
    CheckImage.Left := Width - CheckImage.Width;
    TTechDirectoryPanel(GradScroll.Parent).CheckedList.Add(Self);
  end else begin
    CheckImage.Picture := nil;
    for i := TTechDirectoryPanel(GradScroll.Parent).CheckedList.Count -1 downto 0 do
      if TTechDirectoryPanel(GradScroll.Parent).CheckedList.Items[i] = Self then
        TTechDirectoryPanel(GradScroll.Parent).CheckedList.Delete(i);
  end;

  TTechGradScroll(Parent).SelectedFileName := FileName;
  TTechGradScroll(Parent).PanelClick(Self);

end;


procedure TTechPanel.SetChecked;
begin
  ItemlblClick(Self);
end;

procedure TTechPanel.ItemlblClick(Sender: TObject);
var
  Png: TBitmap;
  i: integer;
begin
  if TTechGradScroll(Parent).SelectedImage <> nil then
    TTechGradScroll(Parent).SelectedImage.Picture := nil;
    
  TTechGradScroll(Parent).SelectedImage := ImageFocus;
    
  Png:= TBitmap.Create;
  LoadFromResourceName(Png, HInstance,'FOCUS');
  ImageFocus.Picture.Assign(Png);
  Png.Free;

  Checked := not Checked;
  if Checked then
  begin
    Png:= TBitmap.Create;
    LoadFromResourceName(Png, HInstance,'CHECKED');
    CheckImage.AutoSize := true;
    CheckImage.Picture.Assign(Png);
    Png.Free;
    CheckImage.Left := Width - CheckImage.Width;
    TTechDirectoryPanel(GradScroll.Parent).CheckedList.Add(Self);
  end else begin
    CheckImage.Picture := nil;
    for i := TTechDirectoryPanel(GradScroll.Parent).CheckedList.Count -1 downto 0 do
      if TTechDirectoryPanel(GradScroll.Parent).CheckedList.Items[i] = Self then
        TTechDirectoryPanel(GradScroll.Parent).CheckedList.Delete(i);
  end;
  TTechGradScroll(Parent).SelectedFileName := FileName;
  TTechGradScroll(Parent).PanelClick(Self);
end;


{ TTechGradScroll }

constructor TTechGradScroll.Create(AOwner: TComponent);
begin
  FItemHeight := 100;
  FFilter     := '*.*';
  inherited Create(AOwner);
  Caption := '';
  FList:= TList.Create;
  BevelInner := bvNone;
  BevelOuter := bvNone;
end;

destructor TTechGradScroll.Destroy;
var
  i: integer;
begin

  for i := FList.Count -1 downto 0 do
  begin
    TTechPanel(FList.Items[i]).Free;
    FList.Delete(i);
  end;
  FList.Free;
  inherited Destroy;
end;

procedure TTechGradScroll.ItemCheckedWithFileName(fname: string);
var
  i: integer;
begin
  for i :=0 to FList.Count -1 do
  begin
    if TTechPanel(FList.Items[i]).FileName = fname then
    begin
      TTechPanel(FList.Items[i]).SetChecked;
    end;
  end;
end;

procedure TTechGradScroll.PanelClick(Sender: TObject);
var
  i: integer;
begin
  for i :=0 to FList.Count -1 do
  begin
    if TTechPanel(FList.Items[i]) = TTechPanel(Sender) then
    begin
      TTechPanel(FList.Items[i]).Selected := true;
    end else TTechPanel(FList.Items[i]).Selected := false;
  end;

  if Assigned(TTechDirectoryPanel(Parent).FItemClickEvent) then TTechDirectoryPanel(Parent).FItemClickEvent(Parent,TTechPanel(Sender).Checked,TTechPanel(Sender).FileName);
end;

procedure TTechGradScroll.SetItemHeight(val: integer);
var
  i: integer;
begin
  if FItemHeight <> val then
  begin
    FItemHeight := val;
    for i:= 0 to FList.Count -1 do
    begin
      TTechPanel(FList.Items[i]).Height := FItemHeight;
      TTechPanel(FList.Items[i]).Top    := FItemHeight * i;
    end;
  end;
end;



procedure TTechGradScroll.SetDirectory(dir: string);
var
  i: integer;
begin
try
  //if dir <> FDirectory then
  begin
    FDirectory := dir;
    if FDirectory <> '' then
    begin
      if FDirectory[1] <> '*' then
      begin
        if FDirectory[length(FDirectory)] <> '\' then FDirectory := FDirectory + '\';

        CreateDirList;
      end;// else BuildList;
    end else begin
        for i := TTechDirectoryPanel(Parent).CheckedList.Count -1 downto 0 do
          TTechDirectoryPanel(Parent).CheckedList.Delete(i);

        for i := Self.FList.Count -1 downto 0 do
          begin
            TTechPanel(Self.FList.Items[i]).Free;
            FList.Items[i] := nil;
            Self.FList.Delete(i);
          end;
    end;

  end;
except

end;
end;

{
procedure TTechGradScroll.BuildList;
var
  DriveNum: Integer;
  DriveChar: Char;
  DriveType: TDriveType;
  DriveBits: set of 0..25;
  TechPanel: TTechPanel;
  i: integer;

  procedure AddDrive(const imgID: string);
  begin
    TechPanel := TTechPanel.CreateWithParent(Self,Self);
    TechPanel.Parent := Self;
    if not Self.MenuImage then
      TechPanel.Width := Self.Width;
    TechPanel.Height  := Self.ItemHeight;
    TechPanel.Top     := (Self.ItemHeight+4) * Self.FList.Count;
    TechPanel.Folder  := true;
    TechPanel.FileName  := DriveChar+':\';
    TechPanel.DosyaAdi  := DriveChar+':\';
    TechPanel.Selected  := false;
    TechPanel.GradBegin := clMaroon;
    TechPanel.GradEnd   :=  $00A6A6FF;
    TechPanel.GradStyle := gsArrowL;
    TechPanel.Font.Name := 'Tahoma';
    TechPanel.Font.Size := 16;
    TechPanel.GradScroll:= Self;
    TechPanel.OnClick := Self.PanelClick;
    TechPanel.Caption := DriveChar+':\';
    TechPanel.ImageID := imgID;
    TechPanel.SendToBack;
    Self.FList.Add(TechPanel);
    Self.Height := (Self.ItemHeight+4) * (Self.FList.Count + 1);
  end;

begin


  for i := TTechDirectoryPanel(Parent).CheckedList.Count -1 downto 0 do
    TTechDirectoryPanel(Parent).CheckedList.Delete(i);

  for i := Self.FList.Count -1 downto 0 do
    begin
      TTechPanel(Self.FList.Items[i]).Free;
      FList.Items[i] := nil;
      Self.FList.Delete(i);
    end;

  Integer(DriveBits) := GetLogicalDrives;
  for DriveNum := 0 to 25 do
  begin
    if not (DriveNum in DriveBits) then Continue;
    DriveChar := Char(DriveNum + Ord('a'));
    DriveType := TDriveType(GetDriveType(PChar(DriveChar + ':\')));

    case DriveType of
      dtFloppy:
        AddDrive('CIKARILABILIRDISK');
      dtFixed:
        AddDrive('SABITDISK');
      dtNetwork:
        AddDrive('SABITDISK');
      dtCDROM:
        AddDrive('CDDISK');
      dtRAM:
        AddDrive('CIKARILABILIRDISK');
    end;
  end;
end;  }


procedure TTechGradScroll.CreateDirList;
var
  i: integer;
  HourPanel: THourPanel;
  SearchRec: TSearchRec;
  TechPanel: TTechPanel;
begin
try
  for i := TTechDirectoryPanel(Parent).CheckedList.Count -1 downto 0 do
    TTechDirectoryPanel(Parent).CheckedList.Delete(i);

  for i := Self.FList.Count -1 downto 0 do
    begin
      TTechPanel(Self.FList.Items[i]).Free;
      FList.Items[i] := nil;
      Self.FList.Delete(i);
    end;

    if FDirectory <> '' then
    begin
      HourPanel:= THourPanel.Create(Self);
      HourPanel.Parent := Self;
      HourPanel.Left := (Self.Width div 2) - (HourPanel.Width div 2);
      HourPanel.Top  := (Self.Parent.Height div 2) - (HourPanel.Height div 2);
      HourPanel.Caption := '';
      Top := 0;
      i := FindFirst(Self.FDirectory + FFilter,faAnyFile,SearchRec);
      while i = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and ((SearchRec.Attr and faDirectory) <> 0) then
        begin
          Self.Height := (Self.ItemHeight+4) * (Self.FList.Count + 1);
          HourPanel.BringToFront;
          TechPanel:= TTechPanel.CreateWithParent(Self,Self);
          TechPanel.Parent := Self;
          if not Self.MenuImage then
            TechPanel.Width := Self.Width;
          TechPanel.Height  := Self.ItemHeight;
          TechPanel.Top     := (Self.ItemHeight+4) * Self.FList.Count;
          TechPanel.Folder  := SearchRec.Attr = faDirectory;
          TechPanel.FileName  := Self.FDirectory + SearchRec.Name;
          TechPanel.DosyaAdi  := SearchRec.Name;
          TechPanel.Selected  := false;
          TechPanel.Color := clMaroon;
          TechPanel.Font.Name := 'adobe-courier';
          TechPanel.Font.Size := 18;
          TechPanel.GradScroll:= Self;
          TechPanel.OnClick := Self.PanelClick;
          TechPanel.Caption := SearchRec.Name;
          TechPanel.SendToBack;

          Self.FList.Add(TechPanel);
         // Application.ProcessMessages;
        end;
        i := FindNext(SearchRec);
      end;


      i := FindFirst(Self.FDirectory + FFilter,faAnyFile - faDirectory,SearchRec);
      while i = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          Self.Height := (Self.ItemHeight+4) * (Self.FList.Count + 1);
          HourPanel.BringToFront;
          TechPanel:= TTechPanel.CreateWithParent(Self,Self);
          TechPanel.Parent := Self;
          if not Self.MenuImage then
            TechPanel.Width := Self.Width;
          TechPanel.Height  := Self.ItemHeight;
          TechPanel.Top     := (Self.ItemHeight+4) * Self.FList.Count;
          TechPanel.Folder  := SearchRec.Attr = faDirectory;
          TechPanel.FileName  := Self.FDirectory + SearchRec.Name;
          TechPanel.DosyaAdi  := SearchRec.Name;
          TechPanel.Selected  := false;
          TechPanel.Color := clMaroon;
          TechPanel.Font.Name := 'adobe-courier';
          TechPanel.Font.Size := 18;
          TechPanel.GradScroll:= Self;
          TechPanel.OnClick := Self.PanelClick;
          TechPanel.Caption := SearchRec.Name;
          TechPanel.SendToBack;

          Self.FList.Add(TechPanel);
         // Application.ProcessMessages;
        end;
        i := FindNext(SearchRec);
      end;

      Self.Height := (Self.ItemHeight+2) * (Self.FList.Count + 1);
      HourPanel.Free;
    end;
except

end;

end;



{ TTechDirectoryPanel }

constructor TTechDirectoryPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Caption := '';
  TechGradScroll:= TTechGradScroll.Create(Self);
  TechGradScroll.Parent := Self;
  TechGradScroll.Color := Color;
  TechGradScroll.Font.Assign(Self.Font);
  TechGradScroll.Caption := '';
  TechGradScroll.Left := 0;
  TechGradScroll.Top  := 0;
  TechGradScroll.Height := Self.Height;
  if FMenuImage then
    TechGradScroll.Width := Self.Width - (FScrollBtn.Width+3)
  else
    TechGradScroll.Width := Self.Width;


  CheckedList := TList.Create;
  FList:= TList.Create;
end;

destructor TTechDirectoryPanel.Destroy;
var
  i: integer;
begin
  if Assigned(FScrollBtn) then
  begin
    FScrollBtn.Free;
  end;

  CheckedList.Free;
  for i := FList.Count -1 downto 0 do
  begin
    TTechPanel(FList.Items[i]).Free;
    FList.Delete(i);
  end;
  FList.Free;
  TechGradScroll.Free;
  inherited Destroy;
end;


procedure TTechDirectoryPanel.SetItemHeight(val: integer);
var
  i: integer;
begin
  if GetItemHeight <> val then
  begin
    TechGradScroll.ItemHeight := val;
  end;
end;

function TTechDirectoryPanel.GetItemHeight: integer;
begin
  Result := TechGradScroll.ItemHeight;
end;


procedure TTechDirectoryPanel.SetDirectory(dir: string);
begin
  //if dir <> FDirectory then
  begin
    FDirectory := dir;
    TechGradScroll.Color := Color;
    if FDirectory <> '' then
      if FDirectory[1] <> '*' then
        if FDirectory[length(FDirectory)] <> '\' then FDirectory := FDirectory + '\';

    TechGradScroll.Directory := FDirectory;
  end;
end;


procedure TTechDirectoryPanel.SetScrollButton(val: boolean);
begin
  if FScrollButton <> val then
  begin
    FScrollButton := val;
    if FScrollButton then
    begin
      FScrollBtn:= TTechScrollBtn.Create(Self);
      FScrollBtn.Parent := Self;
      FScrollBtn.GradScroll := TechGradScroll;
      FScrollBtn.Left := Self.Width - (FScrollBtn.Width + 3);
      FScrollBtn.Height := Self.Height;
      FScrollBtn.Color := Color;
      TechGradScroll.Width := Self.Width - (FScrollBtn.Width + 3);
    end else begin
      FScrollBtn.Free;
      TechGradScroll.Width := Self.Width;
    end;
  end;
end;

procedure TTechDirectoryPanel.Resize;
begin
  inherited Resize;
  if (FScrollBtn <> nil) and (TechGradScroll <> nil) then
  begin
    TechGradScroll.Color := Color;
    FScrollBtn.Left := Self.Width - (FScrollBtn.Width + 3);
    FScrollBtn.Height := Self.Height;
    FScrollBtn.Color := Color;
    TechGradScroll.Width := Self.Width - (FScrollBtn.Width + 3);
  end;

end;

procedure TTechDirectoryPanel.SetFilter(val: string);
begin
  if val <> GetFilter then
  begin
    TechGradScroll.Filter := val;
  end;
end;

function TTechDirectoryPanel.GetFilter: string;
begin
  Result := TechGradScroll.Filter;
end;

procedure TTechDirectoryPanel.SetSelectedFileName(val: string);
begin
  if TechGradScroll.SelectedFileName <> val then
    TechGradScroll.SelectedFileName := val;
end;

function TTechDirectoryPanel.GetSelectedFileName: string;
begin
  Result := TechGradScroll.SelectedFileName;
end;
procedure TTechDirectoryPanel.SetMenuImage(val: boolean);
begin
  if GetMenuImage <> val then
    TechGradScroll.MenuImage := val;
end;

function TTechDirectoryPanel.GetMenuImage: boolean;
begin
  Result := TechGradScroll.MenuImage;
end;

procedure TTechDirectoryPanel.ItemCheckedWithFileName(fname: string);
begin
  TechGradScroll.ItemCheckedWithFileName(fname);
end;



end.
