#include "..\script_macros.hpp"

LOG_1("ResetRangeData: %1",_this);

// can be run server or client

DEF_RANGE_PARAMS;

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

SET_VAR_G(_objectCtrl,GVAR(rangeMessage),nil);
[_rangeTag,"message"] remoteExec [QFUNC(updateUI),0];

SET_VAR_G(_objectCtrl,GVAR(rangeScores),nil);
SET_VAR_G(_objectCtrl,GVAR(rangeScorePossible),nil);
[_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];

SET_VAR_G(_objectCtrl,GVAR(rangeScoreQuals),nil);
[_rangeTag,"qual"] remoteExec [QFUNC(updateUI),0];