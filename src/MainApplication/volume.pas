unit volume;

interface

uses windows, forms, MMSystem, Math, ShellApi, SysUtils, IniFiles;

  procedure SetVolume(Vol, Balance : Integer);
  function GetVolume: integer;
  function GetBalance: integer;
  procedure SetMute(Value : Boolean);
  procedure InitMixerControls;
  procedure IncVolume;
  procedure DecVolume;
  procedure Mute;

  var
    m_mixerHandle : Cardinal;
    m_MuteControl : MixerControl;
    m_VolControl  : MixerControl;
    FMute         : boolean;

implementation


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

procedure IncVolume;
var
  vol : integer;
begin
  vol := GetVolume + 10;
  if vol > 100 then vol := 100;
  SetVolume(vol,GetBalance);

end;

procedure DecVolume;
var
  vol : integer;
begin
  vol := GetVolume - 10;
  if vol < 0 then vol := 0;
  SetVolume(vol,GetBalance);

end;

procedure Mute;
begin
  FMute := not FMute;
  SetMute(FMute);
end;

end.
