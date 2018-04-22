#include "..\script_macros.hpp"

// Running on both server and clients

RANGE_PARAMS;

LOG_1("CreateRange: %1", _rangeTitle);

//_objectCtrl = missionNamespace getVariable [format ["%1_ctrl",_rangeTag],objNull];
//_objectUiTrigger = missionNamespace getVariable [format ["%1_trg",_rangeTag],objNull];
_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");

if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};
if(isNull _objectUiTrigger) exitWith {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

SET_VAR_G(_objectCtrl,GVAR(rangeActive),false);
SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);

_objectCtrl addAction ["Start Range", {
	(_this select 0) setVariable [QGVAR(rangeActive),true,true];
	(_this select 0) setVariable [QGVAR(rangeActivator),(_this select 1),true];
	(_this select 0) setVariable [QGVAR(rangeInteractable),false,true];
}, _this, 1.5, true, true, "", QUOTE(!(GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
_objectCtrl addAction ["Stop Range", {
	(_this select 0) setVariable [QGVAR(rangeActive),false,true];
	(_this select 0) setVariable [QGVAR(rangeActivator),(_this select 1),true];
	(_this select 0) setVariable [QGVAR(rangeInteractable),false,true];
}, _this, 1.5, true, true, "", QUOTE((GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
_objectCtrl setObjectTexture [0, QUOTE(IMAGE(7th))];

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
					} else {
						if(_useCustomTexture) then {
							_target setObjectTexture [0, QUOTE(IMAGE(range_target))];
						};
					};
					_laneTargets pushBack _target;
					
				};
				_rangeLanes pushBack _laneTargets;
			};

			SET_VAR_G(_objectCtrl,GVAR(rangeTargets),_rangeLanes);
		
			_this spawn {
				params ["_rangeType","_rangeTitle","_rangeTag","_laneCount","_targetCount","_rangeSequence",["_rangeGrouping",[]],"_useCustomTexture","_qualTiers"];				_objectCtrl = missionNamespace getVariable [format ["%1_ctrl",_rangeTag],objNull];
				
				while{true} do {
					waitUntil { sleep 1; _objectCtrl getVariable [QGVAR(rangeActive), false]; };
					_objectCtrl setVariable [QGVAR(sequenceHandle), _this call FUNC(startRange)];
					waitUntil { sleep 1; !(_objectCtrl getVariable [QGVAR(rangeActive), false]); };
					_this call FUNC(stopRange);
					SET_VAR(_objectCtrl,GVAR(sequenceHandle),nil);
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
