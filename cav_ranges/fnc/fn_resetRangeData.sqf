/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_resetRangeData

Description:
	Resets score/UI data for a range.

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
    _this spawn CAV_Ranges_fnc_resetRangeData;

Author:
	=7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

LOG_1("ResetRangeData: %1",_this);

DEF_RANGE_PARAMS;

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

SET_RANGE_VAR(rangeMessage,nil);
[_rangeTag,"message"] remoteExec [QFUNC(updateUI),0];

SET_RANGE_VAR(rangeScores,nil);
SET_RANGE_VAR(rangeScorePossible,nil);
[_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];

SET_RANGE_VAR(rangeScoreQuals,nil);
[_rangeTag,"qual"] remoteExec [QFUNC(updateUI),0];