#include "..\script_macros.hpp"

// Running on server only

DEF_RANGE_PARAMS;

LOG_1("StartRange: %1", str _this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

systemChat format ["%1 started %2", name (GET_VAR(_objectCtrl,GVAR(rangeActivator))), _rangeTitle];
_rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));

_rangeScores = [];

if(isNil "_rangeTargets") exitWith {ERROR_1("Range targets were empty: %1",_this)};

while{true} do {
	_allTargetsUp = true;
	{
		_laneTargets = _x;
		_laneIndex = _forEachIndex;
		{
			_target = _x;
			//LOG_2("%1 - %2",_target,_target animationPhase "terc");
			if(_target animationPhase "terc" != 0) then {
				_allTargetsUp = false;
				LOG_3("Target not raised: %1 L%2 T%3",_rangeTag,_laneIndex+1,_forEachIndex+1);
			};
		} foreach _laneTargets;
	} foreach _rangeTargets;
	
	LOG_VAR(_allTargetsUp);
	if(_allTargetsUp) exitWith {};
	
	LOG("Waiting for all targets to reset");
	_msgData = ["Waiting for all targets to reset...",2];
	SET_VAR_G(_objectCtrl,GVAR(rangeMessage),_msgData);
	[_rangeTag, "message"] remoteExec [QFUNC(updateUI),0];
	sleep 2;
};

{ 
	_laneTargets = _x;
	{
		_target = _x;	
		_target setVariable ["nopop", true, true];
		_target animate ["terc",1];
		[_target, "FD_Target_PopDown_Large_F"] call CBA_fnc_globalSay3d;
	} foreach _laneTargets;
	_rangeScores pushBack 0;
} foreach _rangeTargets;

_this spawn FUNC(resetRangeData);

_rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));

SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);

sleep 0.1;

SET_VAR_G(_objectCtrl,GVAR(rangeScores),_rangeScores);
SET_VAR_G(_objectCtrl,GVAR(rangeScorePossible),0);
[_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];

{
	_x params [["_event","Standby..."],["_delay",5],["_delay2",2]];
	_handled = false;
	if(typeName _event == "STRING") then {
		SET_VAR_G(_objectCtrl,GVAR(rangeMessage),_x);
		[_rangeTag, "message"] remoteExec [QFUNC(updateUI),0];
		sleep _delay;
		_handled = true;
	};
	if(typeName _event == "ARRAY") then {
		_targetsRaised = [];
		{
			_laneTargets = _x;
			if(count _rangeGrouping == 0) then { // single target grouping
				{
					_target = _laneTargets select (_x - 1);
					_target animate ["terc", 0];
					if(_target animationPhase "terc" != 0) then {
						[_target, "FD_Target_PopDown_Large_F"] call CBA_fnc_globalSay3d;
					};
					_targetsRaised pushBack _target;
				} foreach _event;
			} else { // grouping was used
			
			};
		} foreach _rangeTargets;
		
		sleep _delay;
		
		_rangeScores = GET_VAR_ARR(_objectCtrl,GVAR(rangeScores));
		{
			_laneScore = (_rangeScores select _forEachIndex);
			if(isNil "_laneScore") then {_laneScore = 0};
			{
				_target = _x;
				if(_target animationPhase "terc" > 0.5) then {
					_laneScore = _laneScore + 1;
				};
				_target animate ["terc",1];
				if(_target animationPhase "terc" != 1) then {
					[_target, "FD_Target_PopDown_Large_F"] call CBA_fnc_globalSay3d;
				};
				SET_VAR_G(_objectCtrl,GVAR(rangeScorePossible),((GET_VAR_D(_objectCtrl,GVAR(rangeScorePossible),0))+1));
			} foreach _targetsRaised;
			_rangeScores set [_forEachIndex, _laneScore];
			
		} foreach _rangeTargets;
		SET_VAR_G(_objectCtrl,GVAR(rangeScores),_rangeScores);
		[_rangeTag, "scores"] remoteExec [QFUNC(updateUI),0];
		_handled = true;
		
		sleep _delay2;
	};
	if(!_handled) then {
		ERROR_1("Range event was not handled: %1", str _x);
		sleep _delay;
	};
} foreach _rangeSequence;

SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),false);

sleep 1;

// figure scores

_rangeScores = GET_VAR_ARR(_objectCtrl,GVAR(rangeScores));

if(!isNil "_qualTiers") then {
	_rangeScoreQuals = [];
	{
		if((count _rangeScores) > _forEachIndex) then {
			_score = _rangeScores select _forEachIndex;
			if(!isNil "_score") then {
				_qual = -1;
				if(count _qualTiers >= 1) then {
					if(_score >= _qualTiers select 0) then {
						_qual = 0;
					} else {
						if(count _qualTiers >= 2) then {
							if(_score >= _qualTiers select 1) then {
								_qual = 1;
							} else {
								if(count _qualTiers >= 3) then {
									if(_score >= _qualTiers select 2) then {
										_qual = 2;
									};
								};
							};
						};
					};
				};
				_rangeScoreQuals set [_forEachIndex, _qual];
			};
		};
	} foreach _rangeTargets;
	
	SET_VAR_G(_objectCtrl,GVAR(rangeScoreQuals),_rangeScoreQuals);
	[_rangeTag, "qual"] remoteExec [QFUNC(updateUI),0];
};

SET_VAR_G(_objectCtrl,GVAR(rangeActive),false);

_possibleScore = GET_VAR(_objectCtrl,GVAR(rangeScorePossible));
_shooters = GET_VAR(_objectCtrl,GVAR(rangeShooters));
_laneQuals = GET_VAR(_objectCtrl,GVAR(rangeScoreQuals));
{ 
	
	_rangeDoneText = format ["%1 - Lane %2: %3/%4", _rangeTitle, _forEachIndex + 1, _rangeScores select _forEachIndex, _possibleScore];
	
	if(!isNil "_laneQuals") then {
		if(count _laneQuals > _forEachIndex) then {
			_laneQual = _laneQuals select _forEachIndex;
			if(!isNil "_laneQual") then {
				_qualText = "No Go";
				if(_laneQual >= 0) then {
					_qualText = ((GVAR(scoreTiers) select _laneQual) select 2);
				};

				_rangeDoneText = _rangeDoneText + format [" (%1)",_qualText];
			};	
		};
	};
	
	if(!isNil "_shooters") then {
		if(count _shooters > _forEachIndex) then {
			_shooter = _shooters select _forEachIndex;
			if(!isNil "_shooter") then {
				_rangeDoneText = _rangeDoneText + format [" - Shooter: %1", name _shooter];
			};
			
		};
	};
	systemChat _rangeDoneText;
} foreach _rangeTargets;

_this call FUNC(stopRange);
