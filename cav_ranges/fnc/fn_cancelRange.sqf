/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_cancelRange

Description:
	Cancels a range sequence in progress.
	
	It is called via remoteExec at the request of a client via action.
	
Parameters (Standard range parameters, see fn_createRange for detailed info):
	Type - Sets mode of operation for the range [String, ["targets","spawn"]]
	Title - String representation of the range [String]
	Tag - Internal prefix used for the range, so it can find range objects [String]
	Lane Count - How many lanes there are [Integer]
	Target Count - Number of targets per range [Integer]
	Sequence - List of events when the range is started [Array of Arrays of [event, delay]]
	Grouping - target groupings [Array of Arrays of Numbers]
	Qualitification Tiers - number of targets to attain each qual [Array of Integers]

Locality:
	Server
	
Returns: 
	Nothing

Examples:
	_this remoteExec [CAV_Ranges_fnc_cancelRange,2];

Author:
	Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"



LOG_1("CancelRange: %1",_this);

DEF_RANGE_PARAMS;

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_activator = GET_VAR(_objectCtrl,GVAR(rangeActivator));

_text = format ["%1 cancelled %2", name _activator, _rangeTitle];
_text remoteExec ["systemChat"];

LOG_1("%1 cancelled %2",name _activator,_rangeTitle);

terminate (GET_VAR(_objectCtrl,GVAR(sequenceHandle)));

SET_RANGE_VAR(rangeMessage,[ARR_2("Range cancelled. Safe your weapon.",0)]);
[_rangeTag, "message"] remoteExec [QFUNC(updateUI),0];

_this call FUNC(stopRange);
_this call FUNC(resetRangeData);



