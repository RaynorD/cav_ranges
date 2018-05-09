#include "..\script_macros.hpp"

// Running on server only

DEF_RANGE_PARAMS;

LOG_1("StopRange: %1",_this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));

{ 
	_laneTargets = _x;
	{
		_target = _x;
		_target setVariable ["nopop", nil, true];
		_target animate ["terc",0];
		if(_target animationPhase "terc" != 0) then {
			[_target, "FD_Target_PopDown_Large_F"] call CBA_fnc_globalSay3d;
		};
	} foreach _laneTargets;
} foreach _rangeTargets;

SET_VAR_G(_objectCtrl,GVAR(rangeActive),false);
SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);

