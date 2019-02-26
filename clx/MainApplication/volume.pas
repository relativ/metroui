unit volume;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, QComCtrls, QExtCtrls, Math, IniFiles;

  procedure SetVolume(Vol, Balance : Integer);
  function GetVolume: integer;
  function GetBalance: integer;
  procedure SetMute(Value : Boolean);
  procedure InitMixerControls;
  procedure IncVolume;
  procedure DecVolume;
  procedure Mute;

  var
    FMute         : boolean;


implementation


procedure SetVolume(Vol, Balance : Integer);
begin
 //
end;

function GetVolume: integer;
begin
//--
end;

function GetBalance: integer;
begin
//---

end;

procedure SetMute(Value : Boolean);
begin
//--
end;

procedure InitMixerControls;
begin
//---
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
