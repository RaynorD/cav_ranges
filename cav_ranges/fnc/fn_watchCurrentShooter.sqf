#include "..\script_macros.hpp"

// Running on server only

// When a player is present in the range trigger, 
// checks for a player close to each shooting position and saves it to the ctrl object

DEF_RANGE_PARAMS;

LOG_1("watchCurrentShooter: %1", str _this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");

if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};
if(isNull _objectUiTrigger) exitWith {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_rangeLanes = GET_VAR(_objectCtrl,GVAR(rangeTargets));

while {true} do {
	waitUntil {sleep 3; count list _objectUiTrigger > 0};
	while {count list _objectUiTrigger > 0} do {
		_rangeShooters = GET_VAR(_objectCtrl,GVAR(rangeShooters));
		_newShooters = [];
		{
			_shootingPos = GET_ROBJ_L(_rangeTag,"shootingPos",(_forEachIndex + 1));
			if(isNull _shootingPos) exitWith {ERROR_2("Shooting pos (%1) is null: %2", FORMAT_3("%1_%2_l%3",_rangeTag,"shootingPos",(_forEachIndex + 1)), _this)};
			_shooter = ((_shootingPos nearEntities ["Man", 1.5]) select 0);
			if(!isNil "_shooter") then {
				if(typeName _shooter != "OBJECT") then {TYPE_ERROR(_shooter)} else {
					_newShooters set [_forEachIndex, _shooter];
				};
			};
		} foreach _rangeLanes;
		
		_update = true;
		
		if(!isNil "_rangeShooters") then {
			if(_newShooters isEqualTo _rangeShooters) then {
				_update = false;
			};
		};
		
		if(_update) then {
			SET_VAR_G(_objectCtrl,GVAR(rangeShooters),_newShooters);
			[_rangeTag, "shooter"] remoteExec [QFUNC(updateUI),0];
		};
		
		sleep 1;
	};
	_rangeShooters = [];
	SET_VAR_G(_objectCtrl,GVAR(rangeShooters),[]);
	[_rangeTag, "shooter"] remoteExec [QFUNC(updateUI),0];
};
