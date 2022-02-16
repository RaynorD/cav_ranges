/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_cancelRange

Description:
	Cancels a range sequence in progress.
	
	It is called via remoteExec at the request of a client via action.
	
Parameters (Standard range parameters, see createRange function for detailed info).

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
