#include "..\script_macros.hpp"

LOG("PostInit");

//_bulletTypes = ["TargetP_Inf_Acc2_NoPop_F", "TargetP_Inf4_NoPop_F"];
//
//{
//	if(!isDedicated) then {
//		_type = _x;
//		{
//			_target = _x;
//			_target addEventHandler ["hitPart", {_data = _this; [_data, "scripts\targetPopManual\receiveHitPart.sqf"] remoteExec ["BIS_fnc_execVM",2]}];
//		} foreach allMissionObjects _type;
//	};
//} foreach _typesToConvert;

GVAR(loadDone) = true;

INFO_1("Overall mission init time: %1 seconds",diag_tickTime - GVAR(loadStartTime));


