unit QNotebook;

interface

uses
  SysUtils, Classes, QControls, QGraphics, QForms;

const
  SDefault = 'Default';

type
  TNotebook = class;

  TPage = class(TCustomControl)
  private

  protected
    procedure ReadState(Reader: TReader); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Height stored False;
    property TabOrder stored False;
    property Visible stored False;
    property Width stored False;
  end;

  TPageAccess = class(TStrings)
  private
    PageList: TList;
    Notebook: TNotebook;
  protected
    function GetCount: Integer; override;
    function Get(Index: Integer): string; override;
    procedure Put(Index: Integer; const S: string); override;
    function GetObject(Index: Integer): TObject; override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    constructor Create(APageList: TList; ANotebook: TNotebook);
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure Move(CurIndex, NewIndex: Integer); override;
  end;
  
  TNotebook = class(TCustomControl)
  private
    FPageList: TList;
    FAccess: TStrings;
    FPageIndex: Integer;
    FOnPageChanged: TNotifyEvent;
    procedure SetPages(Value: TStrings);
    procedure SetActivePage(const Value: string);
    function GetActivePage: string;
    procedure SetPageIndex(Value: Integer);
  protected
    function GetChildOwner: TComponent; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure ReadState(Reader: TReader); override;
    procedure ShowControl(AControl: TControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ActivePage: string read GetActivePage write SetActivePage stored False;
    property Align;
    property Anchors;
    property Color;
    property Font;
    property Enabled;
    property Constraints;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 0;
    property Pages: TStrings read FAccess write SetPages stored False;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
    property OnStartDrag;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard', [TNotebook]);
end;

constructor TPage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Visible := False;
  ControlStyle := ControlStyle + [csAcceptsControls, csNoDesignVisible];
  Align := alClient;
end;

procedure TPage.Paint;
begin
  inherited Paint;
  if csDesigning in ComponentState then
    with Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
end;

procedure TPage.ReadState(Reader: TReader);
begin
  if Reader.Parent is TNotebook then
    TNotebook(Reader.Parent).FPageList.Add(Self);
  inherited ReadState(Reader);
end;


{TPageAccess}

constructor TPageAccess.Create(APageList: TList; ANotebook: TNotebook);
begin
  inherited Create;
  PageList := APageList;
  Notebook := ANotebook;
end;

function TPageAccess.GetCount: Integer;
begin
  Result := PageList.Count;
end;

function TPageAccess.Get(Index: Integer): string;
begin
  Result := TPage(PageList[Index]).Caption;
end;

procedure TPageAccess.Put(Index: Integer; const S: string);
begin
  TPage(PageList[Index]).Caption := S;
end;

function TPageAccess.GetObject(Index: Integer): TObject;
begin
  Result := PageList[Index];
end;

procedure TPageAccess.SetUpdateState(Updating: Boolean);
begin
  { do nothing }
end;

procedure TPageAccess.Clear;
var
  I: Integer;
begin
  for I := 0 to PageList.Count - 1 do
    TPage(PageList[I]).Free;
  PageList.Clear;
end;

procedure TPageAccess.Delete(Index: Integer);
var
  Form: TCustomForm;
begin
  TPage(PageList[Index]).Free;
  PageList.Delete(Index);
  NoteBook.PageIndex := 0;

  if csDesigning in NoteBook.ComponentState then
  begin
    Form := GetParentForm(NoteBook);
    if (Form <> nil) and (Form.DesignerHook <> nil) then
      Form.DesignerHook.Modified;
  end;
end;

procedure TPageAccess.Insert(Index: Integer; const S: string);
var
  Page: TPage;
  Form: TCustomForm;
begin
  Page := TPage.Create(Notebook);
  with Page do
  begin
    Parent := Notebook;
    Caption := S;
  end;
  PageList.Insert(Index, Page);

  NoteBook.PageIndex := Index;

  if csDesigning in NoteBook.ComponentState then
  begin
    Form := GetParentForm(NoteBook);
    if (Form <> nil) and (Form.DesignerHook <> nil) then
      Form.DesignerHook.Modified;
  end;
end;

procedure TPageAccess.Move(CurIndex, NewIndex: Integer);
var
  AObject: TObject;
begin
  if CurIndex <> NewIndex then
  begin
    AObject := PageList[CurIndex];
    PageList[CurIndex] := PageList[NewIndex];
    PageList[NewIndex] := AObject;
  end;
end;

{ TNotebook }

var
  Registered: Boolean = False;

constructor TNotebook.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 150;
  Height := 150;
  FPageList := TList.Create;
  FAccess := TPageAccess.Create(FPageList, Self);
  FPageIndex := -1;
  FAccess.Add(SDefault);
  PageIndex := 0;
  Exclude(FComponentStyle, csInheritable);
  if not Registered then
  begin
    Classes.RegisterClasses([TPage]);
    Registered := True;
  end;
end;

destructor TNotebook.Destroy;
begin
  FAccess.Free;
  FPageList.Free;
  inherited Destroy;
end;

function TNotebook.GetChildOwner: TComponent;
begin
  Result := Self;
end;

procedure TNotebook.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to FPageList.Count - 1 do Proc(TControl(FPageList[I]));
end;

procedure TNotebook.ReadState(Reader: TReader);
begin
  Pages.Clear;
  inherited ReadState(Reader);
  if (FPageIndex <> -1) and (FPageIndex >= 0) and (FPageIndex < FPageList.Count) then
    with TPage(FPageList[FPageIndex]) do
    begin
      BringToFront;
      Visible := True;
      Align := alClient;
    end
  else FPageIndex := -1;
end;

procedure TNotebook.ShowControl(AControl: TControl);
var
  I: Integer;
begin
  for I := 0 to FPageList.Count - 1 do
    if FPageList[I] = AControl then
    begin
      SetPageIndex(I);
      Exit;
    end;
  inherited ShowControl(AControl);
end;

procedure TNotebook.SetPages(Value: TStrings);
begin
  FAccess.Assign(Value);
end;

procedure TNotebook.SetPageIndex(Value: Integer);
var
  ParentForm: TCustomForm;
begin
  if csLoading in ComponentState then
  begin
    FPageIndex := Value;
    Exit;
  end;
  if (Value <> FPageIndex) and (Value >= 0) and (Value < FPageList.Count) then
  begin
    ParentForm := GetParentForm(Self);
    if ParentForm <> nil then
      if ContainsControl(ParentForm.ActiveControl) then
        ParentForm.ActiveControl := Self;
    with TPage(FPageList[Value]) do
    begin
      BringToFront;
      Visible := True;
      Align := alClient;
    end;
    if (FPageIndex >= 0) and (FPageIndex < FPageList.Count) then
      TPage(FPageList[FPageIndex]).Visible := False;
    FPageIndex := Value;
    if ParentForm <> nil then
      if ParentForm.ActiveControl = Self then SelectFirst;
    if Assigned(FOnPageChanged) then
      FOnPageChanged(Self);
  end;
end;

procedure TNotebook.SetActivePage(const Value: string);
begin
  SetPageIndex(FAccess.IndexOf(Value));
end;

function TNotebook.GetActivePage: string;
begin
  Result := FAccess[FPageIndex];
end;

end.
