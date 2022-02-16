/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_stopRange

Description:
	Stops the sequence for a popup target range.
	Used for both normal and premature end of the sequence.
	
	Not used for spawn ranges.

Parameters (Standard range parameters, see fn_createRange for detailed info):
	Type - Sets mode of operation for the range [String, ["targets","spawn"]]
	Title - String representation of the range [String]
	Tag - Internal prefix used for the range, so it can find range objects [String]
	Lane Count - How many lanes there are [Integer]
	Target Count - Number of targets per range [Integer]
	Sequence - List of events when the range is started [Array of Arrays of [event, delay]]
	Grouping - target groupings [Array of Arrays of Numbers]
	Qualitification Tiers - number of targets to attain each qual [Array of Integers]

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

