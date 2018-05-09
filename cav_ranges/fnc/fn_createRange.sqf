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

if(typeOf _objectCtrl in ["Land_InfoStand_V1_F", "Land_InfoStand_V2_F"]) then {
	_objectCtrl setObjectTexture [0, QUOTE(IMAGE(7th))];
};

_rangeTargets = [];
_rangeTargetData = [];

for "_i" from 1 to _laneCount do {
	_laneTargets = [];
	_laneTargetData = [];
	for "_j" from 1 to _targetCount do {
		_target = missionNamespace getVariable [format["%1_target_l%2_t%3", _rangeTag, _i, _j], objNull];
		if(isNull _target) then {
			ERROR_1("Range target is null: %1",FORMAT_3("%1_target_l%2_t%3",_rangeTag,_i,_j));
		};
		_laneTargets pushBack _target;
		
		if(_rangeType == "spawn") then {
			_laneTargetData pushBack [typeOf _target, getPos _target, [vectorDir _target,vectorUp _target]];
			// [classname, position, vectorDirAndUp]
		};
	};
	if(_rangeType == "spawn") then {
		_rangeTargetData pushBack _laneTargetData;
	};
	_rangeTargets pushBack _laneTargets;
};

SET_VAR_G(_objectCtrl,GVAR(rangeTargets),_rangeTargets);

if(_rangeType == "spawn") then {
	SET_VAR_G(_objectCtrl,GVAR(rangeTargetData),_rangeTargetData);
};

switch _rangeType do {
	case "targets" : {
		if(GET_VAR_D(player,GVAR(instructor),false)) then {
			_objectCtrl addAction ["Start Range", {
				SET_VAR_G((_this select 0),GVAR(rangeActive),true);
				SET_VAR_G((_this select 0),GVAR(rangeActivator),(_this select 1));
				SET_VAR_G((_this select 0),GVAR(rangeInteractable),false);
			}, nil, 1.5, true, true, "", QUOTE(!(GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
			_objectCtrl addAction ["Stop Range", {
				//(_this select 0) setVariable [QGVAR(rangeActive),false,true];
				SET_VAR_G((_this select 0),GVAR(rangeActivator),(_this select 1));
				//(_this select 0) setVariable [QGVAR(rangeInteractable),false,true];
				(_this select 3) remoteExec [QFUNC(cancelRange),2];
			}, _this, 1.5, true, true, "", QUOTE((GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
			_objectCtrl addAction ["Reset Range Data", {
				(_this select 3) spawn FUNC(resetRangeData);
			}, _this, 1.5, true, true, "", QUOTE(!(GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
		};
		
		if(isServer) then {
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
		/*
		no modes
		just counting which ones are dead
		scroll wheel to reset range
		
		*/
		
		if(isServer) then {
			_this spawn FUNC(watchCurrentShooter);
		};
		
		if(!isDedicated) then {
			_this spawn FUNC(rangeDialog);
		};
		
		_objectCtrl addAction ["Reset Range", {
			SET_VAR_G((_this select 0),GVAR(rangeReset),true);
			SET_VAR_G((_this select 0),GVAR(rangeInteractable),false);
		}, _this, 1.5, true, true, "", QUOTE((GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
		
		
		SET_VAR_G(_objectCtrl,GVAR(rangeScorePossible), count (_rangeTargets select 0));
		
		_scores = [];
		for "_i" from 1 to (count (_rangeTargets select 0)) do {
			_scores pushBack 0;
		};
		
		SET_VAR_G(_objectCtrl,GVAR(rangeScores),_scores);
		[_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];
		
		// _rangeTargetData
		
		while{true} do {
			if(GET_VAR_D(_objectCtrl,GVAR(rangeReset),false)) then {
				LOG_1("Resetting %1",_rangeTitle);
				
				{
					_targets = _x;
					{
						_target = _x;
						if(!isNil "_target") then {
							deleteVehicle _target;
							systemchat format ["deleting target %1",_target];
						};
					} foreach _targets;
				} foreach _rangeTargets;
				
				sleep 2;
				
				_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
				_newRangeTargets = [];
				{
					_targets = _x;
					_laneIndex = _forEachIndex;
					_thisLaneData = _rangeTargetData select _laneIndex;
					_newTargets = [];
					{
						_target = _x;

						_thisTargetData = _thisLaneData select _forEachIndex;
						_thisTargetData params ["_type","_pos","_vectorDirAndUp"];
						
						_newTarget = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
						_newTarget setVectorDirAndUp _vectorDirAndUp;
						
						//set object variable name where it is local
						_name = format["%1_target_l%2_t%3", _rangeTag, _laneIndex + 1, _forEachIndex + 1];
						missionNamespace setVariable [_name,_newTarget];
						[_newTarget, _name] remoteExec ["setVehicleVarName",0,_newTarget];
						
						_newTargets pushBack _newTarget;
						systemchat format ["pushing target %1",_newTarget];
					} foreach _targets;
					
					systemchat format ["pushing targets %1",_newTargets];
					_newRangeTargets pushBack _newTargets;
					_rangeScores set [_forEachIndex, 0];
				} foreach _rangeTargets;
				
				systemchat format ["setting Rangetargets %1",_newRangeTargets];
				_rangeTargets = _newRangeTargets;
				
				SET_VAR_G(_objectCtrl,GVAR(rangeScores),_rangeScores);
				[_rangeTag, "scores"] remoteExec [QFUNC(updateUI),0];
				
				if(!isNil "_qualTiers") then {
					[_this,false] spawn FUNC(updateQuals);
				};
				
				SET_VAR_G(_objectCtrl,GVAR(rangeTargets),_rangeTargets);
				SET_VAR_G(_objectCtrl,GVAR(rangeReset),false);
				SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);
			} else {
				_oldRangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
				_rangeScores = [];
				{
					_targets = _x;
					_laneIndex = _forEachIndex;
					_laneScore = 0;
					{
						_target = _x;
						if(isNil "_target") then {
							_laneScore = _laneScore + 1;
						} else {
							if(!(alive _target) || !(canMove _target)) then {
								_laneScore = _laneScore + 1;
							};
						};						
					} foreach _targets;
					_rangeScores pushBack _laneScore;
				} foreach _rangeTargets;
				
				if(!(_rangeScores isEqualTo _oldRangeScores)) then {
					SET_VAR_G(_objectCtrl,GVAR(rangeScores),_rangeScores);
					[_rangeTag, "scores"] remoteExec [QFUNC(updateUI),0];
					
					if(!isNil "_qualTiers") then {
						[_this,false] spawn FUNC(updateQuals);
					};
				};
			};
			sleep 1;
		};
	};
	default {
		ERROR_1("CreateRange received unknown range type: %1",_rangeType);
	};
};






























