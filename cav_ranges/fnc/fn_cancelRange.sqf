#include "..\script_macros.hpp"

// Running on server only

LOG_1("CancelRange: %1",_this);

DEF_RANGE_PARAMS;

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_text = format ["%1 cancelled", _rangeTitle];
_text remoteExec ["systemChat"];

terminate (GET_VAR(_objectCtrl,GVAR(sequenceHandle)));

SET_VAR_G(_objectCtrl,GVAR(rangeMessage),["Range cancelled. Safe your weapon.",0]);
[_rangeTag, "message"] remoteExec [QFUNC(updateUI),0];

_this call FUNC(stopRange);
_this call FUNC(resetRangeData);



