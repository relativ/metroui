unit VLCLib;

{ VideoLAN libvcl.dll (0.8.5) Interface for Delphi (c)2006 by Paul TOTH }

{
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
}

{

 fix #1 VLC_PositionSet return a single, not an integer

}

{-$define console}

interface

const
 {$IFDEF MSWINDOWS}
 lib='libvlc.dll';
 {$ENDIF}
 {$IFDEF LINUX}
 lib='libvlc.so';
 {$ENDIF}

 VLC_SUCCESS       =  -0;                                  // No error
 VLC_ENOMEM        =  -1;                         // Not enough memory
 VLC_ETHREAD       =  -2;                              // Thread error
 VLC_ETIMEOUT      =  -3;                                   // Timeout

 VLC_ENOMOD        = -10;                          // Module not found

 VLC_ENOOBJ        = -20;                          // Object not found
 VLC_EBADOBJ       = -21;                           // Bad object type

 VLC_ENOVAR        = -30;                        // Variable not found
 VLC_EBADVAR       = -31;                        // Bad variable value

 VLC_EEXIT         =-255;                            // Program exited
 VLC_EEXITSUCCESS  =-999;               // Program exited successfully
 VLC_EGENERIC      =-666;                             // Generic error

 VLC_FALSE = 0;
 VLC_TRUE  = 1;

 PLAYLIST_INSERT   = 1;
 PLAYLIST_APPEND   = 2;
 PLAYLIST_GO       = 4;
 PLAYLIST_PREPARSE = 8;
 PLAYLIST_END      = -666;

{$ifndef static}
 VLD_SUCCESS  = 0;
 VLD_NOLIB    =-1;
 VLD_NOTFOUND =-2;
{$endif}

type
 TValue=packed record
 case byte of
  0:(AsInteger:integer);
  1:(AsBoolean:longbool);
  2:(AsFloat  :single);
  3:(AsPChar  :pchar);
  4:(AsPointer:pointer);
  5:(AsObject :pointer); // ^vcl_object_t
  6:(AsList   :pointer); // ^vcl_list_t
  7:(AsTime   :int64);
  8:(AsVar    :record name:pchar; id:integer end );
 end;

{$ifdef static} // you have to put your application in VLC install path !

procedure rootwrap; cdecl external lib;
function VLC_AddIntf(id:integer; module:pchar; block,play:longbool):integer; cdecl external lib;
function VLC_AddTarget(id:integer; target:pchar; szoptions:ppchar; options,mode,pos:integer):integer; cdecl external lib;
function VLC_CleanUp(id:integer):integer; cdecl external lib;
function VLC_CompileBy:pchar; cdecl external lib;
function VLC_CompileDomain:pchar; cdecl external lib;
function VLC_CompileHost:pchar; cdecl external lib;
function VLC_Compiler:pchar; cdecl external lib;
function VLC_Create:integer; cdecl external lib;
function VLC_Destroy(id:integer):integer; cdecl external lib;
function VLC_Die(id:integer):integer; cdecl external lib;
function VLC_Error(id:integer):pchar; cdecl external lib;
function VLC_FullScreen(id:integer):integer; cdecl external lib;
function VLC_Init(id,argc:integer; args:ppchar):integer; cdecl external lib;
function VLC_IsPlaying(id:integer):longbool; cdecl external lib;
function VLC_LengthGet(id:integer):integer; cdecl external lib;
function VLC_Pause(id:integer):integer; cdecl external lib;
function VLC_Play(id:integer):integer; cdecl external lib;
function VLC_PlaylistClear(id:integer):integer; cdecl external lib;
function VLC_PlaylistIndex(id:integer):integer; cdecl external lib;
function VLC_PlaylistNext(id:integer):integer; cdecl external lib;
function VLC_PlaylistNumberOfItems(id:integer):integer; cdecl external lib;
function VLC_PlaylistPrev(id:integer):integer; cdecl external lib;
function VLC_PositionGet(id:integer):single; cdecl external lib;
function VLC_PositionSet(id:integer; pos:single):single; cdecl external lib;
function VLC_SpeedFaster(id:integer):single; cdecl external lib;
function VLC_SpeedSlower(id:integer):single; cdecl external lib;
function VLC_Stop(id:integer):integer; cdecl external lib;
function VLC_TimeGet(id:integer):integer; cdecl external lib;
function VLC_TimeSet(id,seconds:integer; relative:longbool):integer; cdecl external lib;
function VLC_VariableGet(id:integer; Name:pchar; var   value:TValue):integer; cdecl external lib;
function VLC_VariableSet(id:integer; Name:pchar; value:TValue):integer; cdecl external lib;
function VLC_VariableType(id:integer; Name:pchar; var typeid:integer):integer; cdecl external lib;
function VLC_Version:pchar; cdecl external lib;
function VLC_VolumeGet(id:integer):integer; cdecl external lib;
function VLC_VolumeMute(id:integer):integer; cdecl external lib;
function VLC_VolumeSet(id,volume:integer):integer; cdecl external lib;

{$else} // dynamic load of libvlc.dll

{
  WARNING !

  VLCLib can find libvlc.dll from the Install path of VLC in the registry,
  but VLC_Init() return error -666 if you don't set args[0] to VLC install path (VLD_LibPath)
}

var
 rootwrap:procedure; cdecl;
 VLC_AddIntf:function(id:integer; module:pchar; block,play:longbool):integer; cdecl;
 VLC_AddTarget:function(id:integer; target:pchar; szoptions:ppchar; options,mode,pos:integer):integer; cdecl;
 VLC_CleanUp:function(id:integer):integer; cdecl;
 VLC_CompileBy:function:pchar; cdecl;
 VLC_CompileDomain:function:pchar; cdecl;
 VLC_CompileHost:function:pchar; cdecl;
 VLC_Compiler:function:pchar; cdecl;
 VLC_Create:function:integer; cdecl;
 VLC_Destroy:function(id:integer):integer; cdecl;
 VLC_Die:function(id:integer):integer; cdecl;
 VLC_Error:function(id:integer):pchar; cdecl;
 VLC_FullScreen:function(id:integer):integer; cdecl;
 VLC_Init:function(id,argc:integer; args:ppchar):integer; cdecl;
 VLC_IsPlaying:function(id:integer):longbool; cdecl;
 VLC_LengthGet:function(id:integer):integer; cdecl;
 VLC_Pause:function(id:integer):integer; cdecl;
 VLC_Play:function(id:integer):integer; cdecl;
 VLC_PlaylistClear:function(id:integer):integer; cdecl;
 VLC_PlaylistIndex:function(id:integer):integer; cdecl;
 VLC_PlaylistNext:function(id:integer):integer; cdecl;
 VLC_PlaylistNumberOfItems:function(id:integer):integer; cdecl;
 VLC_PlaylistPrev:function(id:integer):integer; cdecl;
 VLC_PositionGet:function(id:integer):single; cdecl;
 VLC_PositionSet:function(id:integer; pos:single):single; cdecl;
 VLC_SpeedFaster:function(id:integer):single; cdecl;
 VLC_SpeedSlower:function(id:integer):single; cdecl;
 VLC_Stop:function(id:integer):integer; cdecl;
 VLC_TimeGet:function(id:integer):integer; cdecl;
 VLC_TimeSet:function(id,seconds:integer; relative:longbool):integer; cdecl;
 VLC_VariableGet:function(id:integer; Name:pchar; var   value:TValue):integer; cdecl;
 VLC_VariableSet:function(id:integer; Name:pchar; value:TValue):integer; cdecl;
 VLC_VariableType:function(id:integer; Name:pchar; var typeid:integer):integer; cdecl;
 VLC_Version:function:pchar; cdecl;
 VLC_VolumeGet:function(id:integer):integer; cdecl;
 VLC_VolumeMute:function(id:integer):integer; cdecl;
 VLC_VolumeSet:function(id,volume:integer):integer; cdecl;

// load libvlc.dll (get Install path from registry)
function VLD_LoadLibrary:integer;
// return Install path found in registry by VLD_LoadLibrary
function VLD_LibPath:string;
// return libvlc.dll proc adress
function VLD_GetProcAddress(Name:pchar; var addr:pointer):integer;
// return (and clear) last VLD error
function VLD_LastError:integer;
// load everything (dll & procs) and return last VLD error
function VLD_Startup:integer;

{$endif}

implementation

{$ifndef static}

uses
 {$IFDEF MSWINDOWS}
 Windows;
 {$ENDIF}
 {$IFDEF LINUX}
 SysUtils;
 {$ENDIF}
 
var
 libvcl:THandle=0;
 libPath:string;
 lastError:integer=VLC_SUCCESS;

function getLibPath:boolean;
var
 Handle:HKEY;
 RegType:integer;
 DataSize:integer;
begin
 Result:=False;
 if (RegOpenKeyEx(HKEY_LOCAL_MACHINE,'Software\VideoLAN\VLC',0,KEY_ALL_ACCESS,Handle)=ERROR_SUCCESS) then begin
  if RegQueryValueEx(Handle,'InstallDir',nil,@RegType,nil,@DataSize)=ERROR_SUCCESS then begin
   SetLength(libPath,Datasize);
   RegQueryValueEx(Handle,'InstallDir',nil,@RegType,PByte(@libPath[1]),@DataSize);
   libPath[DataSize]:='\';
   Result:=True;
  end;
  RegCloseKey(Handle);
 end;
end;

function VLD_LibPath:string;
begin
 if libPath='' then getLibPath;
 Result:=libPath;
end;

function VLD_LoadLibrary:integer;
begin
 if libvcl=0 then begin
  libvcl:=LoadLibrary(lib);
  if (libvcl=0)and(getLibPath) then begin
   libvcl:=LoadLibrary(pchar(libPath+lib));
  end;
 end;
 if libvcl<>0 then
  Result:=VLD_SUCCESS
 else begin
 {$ifdef console}
  WriteLn(libPath,lib,' not found');
 {$endif}
  lastError:=VLD_NOLIB;
  Result:=lastError;
 end;
end;

function VLD_GetProcAddress(Name:pchar; var addr:pointer):integer;
begin
 if libvcl=0 then begin
  Result:=VLD_LoadLibrary;
  if Result<>VLD_SUCCESS then exit;
 end;
 addr:=getProcAddress(libvcl,Name);
 if addr<>nil then
  Result:=VLD_SUCCESS
 else begin
 {$ifdef console}
  WriteLn(Name,' not found in ',libPath,lib);
 {$endif}
  lastError:=VLD_NOTFOUND;
  Result:=lastError;
 end;
end;

function VLD_LastError:integer;
begin
 Result:=lastError;
 lastError:=VLD_SUCCESS;
end;

function VLD_Startup:integer;
begin
 lastError:=VLD_SUCCESS;
 if VLD_LoadLibrary=VLD_SUCCESS then begin
  VLD_GetProcAddress('rootwrap',@rootwrap);
  VLD_GetProcAddress('VLC_AddIntf',@VLC_AddIntf);
  VLD_GetProcAddress('VLC_AddTarget',@VLC_AddTarget);
  VLD_GetProcAddress('VLC_CleanUp',@VLC_CleanUp);
  VLD_GetProcAddress('VLC_CompileBy',@VLC_CompileBy);
  VLD_GetProcAddress('VLC_CompileDomain',@VLC_CompileDomain);
  VLD_GetProcAddress('VLC_CompileHost',@VLC_CompileHost);
  VLD_GetProcAddress('VLC_Compiler',@VLC_Compiler);
  VLD_GetProcAddress('VLC_Create',@VLC_Create);
  VLD_GetProcAddress('VLC_Destroy',@VLC_Destroy);
  VLD_GetProcAddress('VLC_Die',@VLC_Die);
  VLD_GetProcAddress('VLC_Error',@VLC_Error);
  VLD_GetProcAddress('VLC_FullScreen',@VLC_FullScreen);
  VLD_GetProcAddress('VLC_Init',@VLC_Init);
  VLD_GetProcAddress('VLC_IsPlaying',@VLC_IsPlaying);
  VLD_GetProcAddress('VLC_LengthGet',@VLC_LengthGet);
  VLD_GetProcAddress('VLC_Pause',@VLC_Pause);
  VLD_GetProcAddress('VLC_Play',@VLC_Play);
  VLD_GetProcAddress('VLC_PlaylistClear',@VLC_PlaylistClear);
  VLD_GetProcAddress('VLC_PlaylistIndex',@VLC_PlaylistIndex);
  VLD_GetProcAddress('VLC_PlaylistNext',@VLC_PlaylistNext);
  VLD_GetProcAddress('VLC_PlaylistNumberOfItems',@VLC_PlaylistNumberOfItems);
  VLD_GetProcAddress('VLC_PlaylistPrev',@VLC_PlaylistPrev);
  VLD_GetProcAddress('VLC_PositionGet',@VLC_PositionGet);
  VLD_GetProcAddress('VLC_PositionSet',@VLC_PositionSet);
  VLD_GetProcAddress('VLC_SpeedFaster',@VLC_SpeedFaster);
  VLD_GetProcAddress('VLC_SpeedSlower',@VLC_SpeedSlower);
  VLD_GetProcAddress('VLC_Stop',@VLC_Stop);
  VLD_GetProcAddress('VLC_TimeGet',@VLC_TimeGet);
  VLD_GetProcAddress('VLC_TimeSet',@VLC_TimeSet);
  VLD_GetProcAddress('VLC_VariableGet',@VLC_VariableGet);
  VLD_GetProcAddress('VLC_VariableSet',@VLC_VariableSet);
  VLD_GetProcAddress('VLC_VariableType',@VLC_VariableType);
  VLD_GetProcAddress('VLC_Version',@VLC_Version);
  VLD_GetProcAddress('VLC_VolumeGet',@VLC_VolumeGet);
  VLD_GetProcAddress('VLC_VolumeMute',@VLC_VolumeMute);
  VLD_GetProcAddress('VLC_VolumeSet',@VLC_VolumeSet);
 end;
 Result:=lastError;
end;

{$endif}

{$ifdef console}
initialization
 AllocConsole;
{$endif}
end.

