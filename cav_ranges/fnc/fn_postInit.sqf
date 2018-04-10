#include "..\script_macros.hpp"

LOG("PostInit");

KK_fnc_trueZoom = {
    ([0.5,0.5] distance2D worldToScreen positionCameraToWorld [0,3,4]) * (getResolution select 5) / 2
};

_bulletTypes = ["TargetP_Inf_Acc2_NoPop_F", "TargetP_Inf4_NoPop_F"];

{
	if(!isDedicated) then {
		_type = _x;
		{
			_target = _x;
			_target addEventHandler ["hitPart", {_data = _this; [_data, "scripts\targetPopManual\receiveHitPart.sqf"] remoteExec ["BIS_fnc_execVM",2]}];
		} foreach allMissionObjects _type;
	};
} foreach _typesToConvert;

INFO("==========================================================");
INFO_1("Initializing - Build: %1",QUOTE(PROJECT_VERSION));

[
	"Range 1",				// title text
	"r1",					// scripting prefix
	1,						// lane count
	10,						// targets per lane
	1,						// targets per group
	false,					// has target indicators
	false,					// has lane cameras
	true,					// runs range sequence
	[						// Range sequence
		["Load your magazine",5],
		[[1],5],
		[[4],5],
		[[4],5],
		[[7],5],
		["Reload",5],
		[[5,10],5],
		[[8,2],5],
		[[1,9],5],
		[[7,8],5]
	]
] call FUNC(createRange);

GVAR(loadDone) = true;


