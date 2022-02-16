/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_stopRange

Description:
	Stops the sequence for a popup target range.
	Used for both normal and premature end of the sequence.
	
	Not used for spawn ranges.

Parameters (Standard range parameters, see fn_createRange for detailed info).

Returns:
	Nothing

Locality:
	Server

Examples:
    _this spawn CAV_Ranges_fnc_stopRange;

Author:
	Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

DEF_RANGE_PARAMS;

LOG_1("StopRange: %1",_this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));

// raise targets, clear nopop
{
	_laneTargets = _x;
	{
		_target = _x;
		_target setVariable ["nopop", nil, true];
		_target animate ["terc",0];
		if(_target animationPhase "terc" != 0) then {
			[_target, "FD_Target_PopDown_Large_F"] remoteExec ["say3d"];
		};
	} foreach _laneTargets;
} foreach _rangeTargets;

SET_RANGE_VAR(rangeActive,false);
SET_RANGE_VAR(rangeInteractable,true);
