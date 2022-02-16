/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_watchCurrentShooter

Description:
	Checks for a player close to each shooting position and saves it to the ctrl object
	It is only run if ther is a player currently in the trigger

Parameters (Standard range parameters, see fn_createRange for detailed info).

Returns:
	Nothing

Locality:
	Server

Examples:
    _this spawn CAV_Ranges_fnc_watchCurrentShooter;

Author:
	Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

// When a player is present in the range trigger,
//

DEF_RANGE_PARAMS;

LOG_1("watchCurrentShooter: %1", str _this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {ERROR_3("Range trigger (%1_%2) was null: %3",_rangeTag,"trg",_this)};

_rangeLanes = GET_VAR(_objectCtrl,GVAR(rangeTargets));

while {true} do {
	// waitUntil a player is in the trigger
	waitUntil {sleep 3; count list _objectUiTrigger > 0};
	
	while {count list _objectUiTrigger > 0} do {
		_rangeShooters = GET_VAR(_objectCtrl,GVAR(rangeShooters));
		_newShooters = [];
		{
			// get closest player to lane's shooting pos object
			_shootingPos = GET_ROBJ_L(_rangeTag,"shootingPos",(_forEachIndex + 1));
			if(isNull _shootingPos) exitWith {ERROR_2("Shooting pos (%1) is null: %2", FORMAT_3("%1_%2_l%3",_rangeTag,"shootingPos",(_forEachIndex + 1)), _this)};
			_shooter = ((_shootingPos nearEntities ["Man", 2.5]) select 0);
			if(!isNil "_shooter") then {
				if(typeName _shooter != "OBJECT") then {TYPE_ERROR(_shooter)} else {
					_newShooters set [_forEachIndex, _shooter];
				};
			};
		} foreach _rangeLanes;
		
		_update = true;
		
		// if the list previously existed and hasn't changed, don't update the UI
		if(!isNil "_rangeShooters") then {
			if(_newShooters isEqualTo _rangeShooters) then {
				_update = false;
			};
		};
		
		if(_update) then {
			SET_RANGE_VAR(rangeShooters,_newShooters);
			[_rangeTag, "shooter"] remoteExec [QFUNC(updateUI),0];
		};
		
		sleep 1;
	};
	
	// once everyone has left the trigger, clear the data
	_rangeShooters = [];
	SET_RANGE_VAR(rangeShooters,[]);
	[_rangeTag, "shooter"] remoteExec [QFUNC(updateUI),0];
};
