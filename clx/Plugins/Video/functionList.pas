unit functionList;

interface

uses windows, forms, MMSystem, Math, ShellApi, SysUtils, IniFiles;

type
  TDriveType = (dtUnknown, dtNoDrive, dtFloppy, dtFixed, dtNetwork, dtCDROM,
    dtRAM);
    
  procedure SetVolume(Vol, Balance : Integer);
  function GetVolume: integer;
  function GetBalance: integer;
  procedure SetMute(Value : Boolean);
  procedure InitMixerControls;
  function UpFolder(basefolder,folder: string): string;
  function DelDir(dir: string): Boolean;
  function MoveDir(const fromDir, toDir: string): Boolean;
  function CopyDir(const fromDir, toDir: string): Boolean;
  function IsLogicalDrive(Drive: string): boolean;
  function SetScreenResolution(Width, Height: integer): Longint;
  function GetIni(Section, Ident: string; Default: string = ''): string;
  function FindDVDDevice: string;

var
  m_mixerHandle : Cardinal;
  m_MuteControl : MixerControl;
  m_VolControl : MixerControl;

implementation

function FindDVDDevice: string;
var
  DriveNum: Integer;
  DriveChar: Char;
  DriveType: TDriveType;
  DriveBits: set of 0..25;
begin
try
  Result := '';
  Integer(DriveBits) := GetLogicalDrives;
  for DriveNum := 0 to 25 do
  begin
    if not (DriveNum in DriveBits) then Continue;
    DriveChar := Char(DriveNum + Ord('a'));
    DriveType := TDriveType(GetDriveType(PChar(DriveChar + ':\')));
    if DriveType = dtCDROM then
    begin
        if DirectoryExists(DriveChar+':\VIDEO_TS') then
        begin
          Result := DriveChar+':\VIDEO_TS';
          Break;
        end;
    end;
  end;
except

end;
end;

function GetIni(Section, Ident: string; Default: string = ''): string;
var
  ini: TIniFile;
  iniFile: string;
begin
  iniFile := ExtractFilePath(Application.ExeName)+'conf.ini';

  ini:= TIniFile.Create(iniFile);
  Result := ini.ReadString(Section,Ident,Default);
end;

function SetScreenResolution(Width, Height: integer): Longint;
var
  DeviceMode: TDeviceMode;
begin
  with DeviceMode do begin
    dmSize := SizeOf(TDeviceMode);
    dmPelsWidth := Width;
    dmPelsHeight := Height;
    dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
  end;
  Result := ChangeDisplaySettings(DeviceMode, CDS_UPDATEREGISTRY);
end;

function UpFolder(basefolder,folder: string): string;
var
  tmp,base: string;
begin
  base := LowerCase(basefolder);
  tmp := LowerCase(folder);
  if base[length(base)] = '\' then delete(base,length(base),length(base));
  if tmp[length(tmp)] = '\' then delete(tmp,length(tmp),length(tmp));
  if pos('\',tmp) > 0 then
  begin
    while tmp[length(tmp)] <> '\' do
      delete(tmp,length(tmp),length(tmp));
    if Pos(base,tmp) > 0 then
      Result := tmp
    else
      Result := folder;
  end else Result := '';
end;

procedure InitMixerControls;
var
    LineControls : MIXERLINECONTROLS;
  	MixerLine : TMIXERLINE;
    Controls : array [0 .. 30] of TMixerControl;
    i : integer;
begin
    ZeroMemory(@Controls[0], sizeof(TMixerControl) * 31);
    mixerOpen(@m_MixerHandle, 0, 0, 0, MIXER_OBJECTF_MIXER);

    ZeroMemory(@MixerLine, sizeof(TMIXERLINE));
    MixerLine.cbStruct := sizeof(TMIXERLINE);
    MixerLine.dwDestination := 1;
    MixerLine.dwComponentType := MIXERLINE_COMPONENTTYPE_DST_SPEAKERS;
    mixerGetLineInfo(m_MixerHandle, @MixerLine, MIXER_GETLINEINFOF_COMPONENTTYPE);

    ZeroMemory(@LineControls, sizeof(MIXERLINECONTROLS));
    LineControls.cbStruct := sizeof(MIXERLINECONTROLS);
    LineControls.dwControlType := MIXERCONTROL_CONTROLTYPE_VOLUME;
    LineControls.dwLineID := MixerLine.dwLineID;
    LineControls.cControls := MixerLine.cControls;
    LineControls.cbmxctrl := sizeof(MIXERCONTROL);
    LineControls.pamxctrl := @Controls[0];
    mixerGetLineControls(m_MixerHandle, @LineControls, MIXER_GETLINECONTROLSF_ALL);

    for i := 31 downto 0 do
    begin
        if Controls[i].dwControlType = MIXERCONTROL_CONTROLTYPE_VOLUME then
            m_VolControl := Controls[i];

        if Controls[i].dwControlType = MIXERCONTROL_CONTROLTYPE_MUTE then
            m_MuteControl := Controls[i];
    end;

    m_VolControl.Metrics.dwReserved[1] := 1;
    m_VolControl.Metrics.dwReserved[2] := 1;
end;

procedure SetVolume(Vol, Balance : Integer);
var
    V : integer;
    aDetails : array [0 .. 1] of MIXERCONTROLDETAILS_UNSIGNED;
    ControlDetails : TMIXERCONTROLDETAILS;
begin
    V := Vol * $FFFF div 100;

    if Balance < 0 then
    begin
        aDetails[0].dwValue := V;
        aDetails[1].dwValue := V * (100 + Balance) div 100;
    end
    else
    begin
        aDetails[0].dwValue := V * (100 - Balance) div 100;
        aDetails[1].dwValue := V;
    end;

    ZeroMemory(@ControlDetails, sizeof(TMIXERCONTROLDETAILS));
    ControlDetails.cbStruct := sizeof(TMIXERCONTROLDETAILS);
    ControlDetails.dwControlID := m_VolControl.dwControlID;
    ControlDetails.cChannels := 2; // 2 sound channels
    ControlDetails.cMultipleItems := 0;
    ControlDetails.cbDetails := sizeof(MIXERCONTROLDETAILS_UNSIGNED);
    ControlDetails.paDetails := @aDetails[0];
    mixerSetControlDetails(0, @ControlDetails, MIXER_SETCONTROLDETAILSF_VALUE);
end;

function GetVolume: integer;
var
    aDetails : array [0 .. 30] of Integer;
    ControlDetails : TMIXERCONTROLDETAILS;
    L, R, Vol: Integer;
begin
    ZeroMemory(@ControlDetails, sizeof(TMIXERCONTROLDETAILS));
    ControlDetails.cbStruct := sizeof(TMIXERCONTROLDETAILS);
    ControlDetails.dwControlID := m_VolControl.dwControlID;
    ControlDetails.cbDetails := sizeof(integer);
    ControlDetails.hwndOwner := 0;
    ControlDetails.cChannels := 2;
    ControlDetails.paDetails := @aDetails;
    MixerGetControlDetails(m_mixerHandle, @ControlDetails, MIXER_GETCONTROLDETAILSF_VALUE);
    L := aDetails[0];
    R := aDetails[1];
    Vol:= Max(L, R) * 100 div $FFFF;

    result := Vol;
end;

function GetBalance: integer;
var
    aDetails : array [0 .. 30] of Integer;
    ControlDetails : TMIXERCONTROLDETAILS;
    L, R, Vol: Integer;
    Balance: integer;
begin
    ZeroMemory(@ControlDetails, sizeof(TMIXERCONTROLDETAILS));
    ControlDetails.cbStruct := sizeof(TMIXERCONTROLDETAILS);
    ControlDetails.dwControlID := m_VolControl.dwControlID;
    ControlDetails.cbDetails := sizeof(integer);
    ControlDetails.hwndOwner := 0;
    ControlDetails.cChannels := 2;
    ControlDetails.paDetails := @aDetails;
    MixerGetControlDetails(m_mixerHandle, @ControlDetails, MIXER_GETCONTROLDETAILSF_VALUE);
    L := aDetails[0];
    R := aDetails[1];
    Vol:=Max(L, R) * 100 div $FFFF;

    if Vol <> 0 then
        if L>R then
            Balance := -(L - R) * 100 div L
        else
            Balance := (R - L) * 100 div R
    else
        Balance := 0;

    result := Balance;

end;

procedure SetMute(Value : Boolean);
var
    cdetails : TMixerControlDetails;
    details : array [0 .. 30] of Integer;
begin
    cdetails.cbStruct := sizeof(cdetails);
    cdetails.dwControlID := m_MuteControl.dwControlID;
    cdetails.cbDetails := sizeof(integer);
    cdetails.hwndOwner := 0;
    cdetails.cChannels := 1;
    cdetails.paDetails := @details[0];
    details[0] := Integer(Value);
    MixerSetControlDetails(m_mixerhandle, @cdetails, MIXER_GETCONTROLDETAILSF_VALUE);
end;

function CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function MoveDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_MOVE;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function DelDir(dir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(dir + #0);
  end;
  RemoveDirectory(pchar(dir));
  Result := (0 = ShFileOperation(fos));
end;

function IsLogicalDrive(Drive: string): boolean;
  var 
    sDrive: string; 
    cDrive: char; 
  begin 
    sDrive := ExtractFileDrive(Drive); 
    if sDrive = '' then 
      Result := False 
    else begin 
      cDrive := UpCase(sDrive[1]); 
      if cDrive in ['A'..'Z'] then 
        result := (GetLogicalDrives And 
          (1 Shl (Ord(cDrive) - Ord('A')))) <> 0 
      else 
        Result := False; 
    end; 
  end;

end.
