
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

