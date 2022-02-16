/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_resetRangeData

Description:
	Resets score/UI data for a range.

Parameters (Standard range parameters, see fn_createRange for detailed info).

Returns:
	Nothing

Locality:
	Server

Examples:
    _this spawn CAV_Ranges_fnc_resetRangeData;

Author:
	Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

LOG_1("ResetRangeData: %1",_this);

DEF_RANGE_PARAMS;

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

SET_RANGE_VAR(rangeMessage,nil);
[_rangeTag,"message"] remoteExec [QFUNC(updateUI),0];

SET_RANGE_VAR(rangeScores,nil);
SET_RANGE_VAR(rangeScorePossible,nil);
[_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];

SET_RANGE_VAR(rangeScoreQuals,nil);
[_rangeTag,"qual"] remoteExec [QFUNC(updateUI),0];
