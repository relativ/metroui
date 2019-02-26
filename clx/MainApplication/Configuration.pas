unit Configuration;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QComCtrls, QExtCtrls, JvSimpleXml, pluginlist;

type
//-----------------------------TSettings----------------------------------------
  TSkinImage = packed record
    Width, Height: integer;
  end;

  TExternalApps = packed record
    X,Y,Width, Height,FullX,FullY,FullWidth,FullHeight: integer;
  end;

  TButtonPosition = class(TComponent)
  public
    X,Y, Width, Height : integer;
    CaptionX,CaptionY  : integer;
    IconX,IconY  : integer;
    FontSize: integer;
    ButtonName,FormName, FontName : string;
    PluginButtonName: string;
  end;

  TSettings = class(TComponent)
  private

  public
    SkinPath: string;
    MenuButtonBaseName: string;
    ScreenWidth,ScreenHeight: integer;
    SkinImage : TSkinImage;
    ExternalApps: TExternalApps;
    ButtonList: TList;
    PluginList: TPluginList;
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
    procedure GetSkinSettings;
  end;
//-----------------------------TSettings----------------------------------------

implementation

uses JclSimpleXml;

//-----------------------------TSettings----------------------------------------
constructor TSettings.Create(AOwner: TComponent) ;
var
  path,skin: string;
  SimpleXML: TJvSimpleXML;
  Root,Current,Protokol,Buttons,Button: TJvSimpleXMLElem;
begin
  inherited Create(AOwner);
  PluginList:= TPluginList.Create(nil);
  ButtonList:= TList.Create;
  path := ExtractFilePath(ParamStr(0))+'System\settings.xml';
  if FileExists(path) then
  begin
    SimpleXML := TJvSimpleXML.Create(nil);
    SimpleXML.LoadFromFile(path);
    Root    := SimpleXML.Root;
    Current := Root.Items[0];
    skin    := Current.Items.ItemNamed['SKIN'].Value;
    SkinPath := ExtractFilePath(ParamStr(0))+'Skins\'+skin;
    ScreenWidth  := Current.Items.ItemNamed['SCREEN'].Properties.IntValue('WIDTH',848);
    ScreenHeight := Current.Items.ItemNamed['SCREEN'].Properties.IntValue('HEIGHT',848);
    SimpleXML.Free;
  end else begin
    ShowMessage('Ayar dosyasý bulunamadý. Bu dosya olmadan program düzgün çalýþmaz.');
    Application.Terminate;
  end;
end;

destructor TSettings.Destroy;
var
  i: integer;
begin
  for i := ButtonList.Count -1 downto 0 do
  begin
    TButtonPosition(ButtonList[i]).Free;
    ButtonList.Delete(i);
  end;
  PluginList.Free;
  inherited Destroy;
end;

procedure TSettings.GetSkinSettings;
var
  path,skin, FormName: string;
  SimpleXML: TJvSimpleXML;
  Root,SImage,EApps,Components,FormItem,ButtonItem,MenuButtonBaseNameItem: TJvSimpleXMLElem;
  ButtonPosition: TButtonPosition;
  i,a: integer;
begin
  path := SkinPath+'\skin.xml';
  if FileExists(path) then
  begin
    SimpleXML  := TJvSimpleXML.Create(nil);
    SimpleXML.LoadFromFile(path);
    Root       := SimpleXML.Root;
    SImage     := Root.Items.ItemNamed['SKINIMAGE'];
    EApps      := Root.Items.ItemNamed['EXTERNALAPPS'];
    Components := Root.Items.ItemNamed['COMPONENTS'];
    MenuButtonBaseNameItem := Root.Items.ItemNamed['MENUBUTTON'];

    MenuButtonBaseName     := MenuButtonBaseNameItem.Properties.Value('BASENAME');
    SkinImage.Width  := SImage.Items.ItemNamed['WIDTH'].IntValue;
    SkinImage.Height := SImage.Items.ItemNamed['HEIGHT'].IntValue;
    ExternalApps.X   := EApps.Items.ItemNamed['X'].IntValue;
    ExternalApps.Y   := EApps.Items.ItemNamed['Y'].IntValue;
    ExternalApps.Width    := EApps.Items.ItemNamed['WIDTH'].IntValue;
    ExternalApps.Height   := EApps.Items.ItemNamed['HEIGHT'].IntValue;
    ExternalApps.FullX    := EApps.Items.ItemNamed['FULLX'].IntValue;
    ExternalApps.FullY    := EApps.Items.ItemNamed['FULLY'].IntValue;
    ExternalApps.FullWidth   := EApps.Items.ItemNamed['FULLWIDTH'].IntValue;
    ExternalApps.FullHeight  := EApps.Items.ItemNamed['FULLHEIGHT'].IntValue;

    for i := 0 to Components.Items.Count -1 do
    begin
      FormItem := Components.Items[i];
      FormName := LowerCase(FormItem.Properties.Value('NAME'));
      for a := 0 to FormItem.Items.Count -1 do
      begin
        ButtonPosition:= TButtonPosition.Create(nil);
        ButtonPosition.FormName := FormName;
        ButtonItem := FormItem.Items[a];
        ButtonPosition.X := ButtonItem.Properties.IntValue('X',0);
        ButtonPosition.Y := ButtonItem.Properties.IntValue('Y',0);
        ButtonPosition.Width := ButtonItem.Properties.IntValue('WIDTH',0);
        ButtonPosition.Height := ButtonItem.Properties.IntValue('HEIGTH',0);
        ButtonPosition.CaptionX := ButtonItem.Properties.IntValue('CAPTIONX',0);
        ButtonPosition.CaptionY := ButtonItem.Properties.IntValue('CAPTIONY',0);
        ButtonPosition.FontName := ButtonItem.Properties.Value('FONTNAME','Tahoma');
        ButtonPosition.FontSize := ButtonItem.Properties.IntValue('FONTSIZE',16);
        ButtonPosition.IconX := ButtonItem.Properties.IntValue('ICONX',0);
        ButtonPosition.IconY := ButtonItem.Properties.IntValue('ICONY',0);

        ButtonPosition.ButtonName := ButtonItem.Properties.Value('NAME');
        ButtonList.Add(ButtonPosition);
      end;
    end;
  end;

end;
//-----------------------------TSettings----------------------------------------




end.
