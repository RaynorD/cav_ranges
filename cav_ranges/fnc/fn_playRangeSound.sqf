/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_playRangeSound

Description:
    Plays a sound on the range loudspeaker

Compatible range types:
    targets

Parameters:
  rangeTag: String - Range tag for given range
  sound: String - sound to be played

Returns:
    Nothing

Locality:
    Client

Examples:
    ["rr","holdfire"] call CAV_Ranges_fnc_playRangeSound;

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

params ["_rangeTag","_sound"];

_continue = true;
_index = 1;

while {_continue} do {
    _speaker = missionNamespace getVariable [format["%1_speaker_%2", _rangeTag, _index], objNull];
    
    if(isNull _speaker) then {
        _continue = false;
    } else {
        _index = _index + 1;
        [_speaker, [_sound, 400]] remoteExec ["say3d"];
    };
};
