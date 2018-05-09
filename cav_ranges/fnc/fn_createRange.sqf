#include "..\script_macros.hpp"

// Ran on both server and clients at mission init

DEF_RANGE_PARAMS;

LOG_1("CreateRange: %1",_rangeTitle);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

SET_VAR_G(_objectCtrl,GVAR(rangeActive),false);
SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);

if(GET_VAR_D(player,GVAR(instructor),false)) then {
	_objectCtrl addAction ["Start Range", {
		(_this select 0) setVariable [QGVAR(rangeActive),true,true];
		(_this select 0) setVariable [QGVAR(rangeActivator),(_this select 1),true];
		(_this select 0) setVariable [QGVAR(rangeInteractable),false,true];
	}, nil, 1.5, true, true, "", QUOTE(!(GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
	_objectCtrl addAction ["Stop Range", {
		//(_this select 0) setVariable [QGVAR(rangeActive),false,true];
		(_this select 0) setVariable [QGVAR(rangeActivator),(_this select 1),true];
		//(_this select 0) setVariable [QGVAR(rangeInteractable),false,true];
		(_this select 3) remoteExec [QFUNC(cancelRange),2];
	}, _this, 1.5, true, true, "", QUOTE((GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
	_objectCtrl addAction ["Reset Range Data", {
		(_this select 3) spawn FUNC(resetRangeData);
	}, _this, 1.5, true, true, "", QUOTE(!(GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
};

if(typeOf _objectCtrl in ["Land_InfoStand_V1_F", "Land_InfoStand_V2_F"]) then {
	_objectCtrl setObjectTexture [0, QUOTE(IMAGE(7th))];
};

_rangeLanes = [];

switch _rangeType do {
	case "targets" : {
		if(isServer) then {
			for "_i" from 1 to _laneCount do {
				_laneTargets = [];
				for "_j" from 1 to _targetCount do {
					_target = missionNamespace getVariable [format["%1_target_l%2_t%3", _rangeTag, _i, _j], objNull];
					if(isNull _target) then {
						ERROR_1("Range target is null: %1",FORMAT_3("%1_target_l%2_t%3",_rangeTag,_i,_j));
					};
					_laneTargets pushBack _target;
					
				};
				_rangeLanes pushBack _laneTargets;
			};

			SET_VAR_G(_objectCtrl,GVAR(rangeTargets),_rangeLanes);
		
			[_objectCtrl,_this] spawn {
				params ["_objectCtrl","_args"];
				while{true} do {
					waitUntil { sleep 0.5; _objectCtrl getVariable [QGVAR(rangeActive), false]};
					SET_VAR_G(_objectCtrl,GVAR(sequenceHandle),_args spawn FUNC(startRange));
					//_objectCtrl setVariable [QGVAR(sequenceHandle), _args call FUNC(startRange)];
					waitUntil { sleep 0.5; !(_objectCtrl getVariable [QGVAR(rangeActive), false])};
					//_args call FUNC(stopRange);
					//SET_VAR(_objectCtrl,GVAR(sequenceHandle),nil);
				};
			};			
			
			_this spawn FUNC(watchCurrentShooter);
		};
		
		if(!isDedicated) then {
			_this spawn FUNC(rangeDialog);
		};
	};
	case "spawn" : {
		
	};
	default {
		ERROR_1("CreateRange received unknown range type: %1",_rangeType);
	};
};
