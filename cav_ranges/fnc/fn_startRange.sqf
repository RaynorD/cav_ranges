#include "..\script_macros.hpp"

// Running on server only

RANGE_PARAMS;

LOG_1("StartRange: %1", str _this);

//_objectCtrl = missionNamespace getVariable [format ["%1_ctrl",_rangeTag],objNull];
//_objectUiTrigger = missionNamespace getVariable [format ["%1_trg",_rangeTag],objNull];
_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");

if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};
if(isNull _objectUiTrigger) exitWith {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

//systemChat format ["%1 started %2", name (_objectCtrl getVariable [QGVAR(rangeActivator),nil]), _rangeTitle];
systemChat format ["%1 started %2", name (GET_VAR(_objectCtrl,GVAR(rangeActivator)))];

SET_VAR_G(_objectCtrl,GVAR(rangeScorePossible),0);

//rangeLanes = _objectCtrl getVariable [QGVAR(rangeTargets), nil];
_rangeLanes = GET_VAR(_objectCtrl,GVAR(rangeTargets));
_rangeScores = [];

{
	_rangeScores pushBack 0;
} foreach _rangeLanes;

SET_VAR_G(_objectCtrl,GVAR(rangeScores),_rangeScores);

{ 
	{
		_x setVariable ["nopop", true, true];
		_x animate ["terc",1];
	} foreach _x;
} foreach _rangeLanes;

_objectCtrl setVariable [QGVAR(rangeInteractable), true, true];
SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);

if(isNil "_rangeLanes") exitWith {ERROR_1("Range targets were empty: %1", _this)};

{
	_x params [["_event","Standby..."],["_delay",5],["_delay2",2]];
	systemChat str _x;
	_handled = false;
	if(typeName _event == "STRING") then {
		SET_VAR_G(_objectCtrl,GVAR(rangeMessage),_event);
		sleep _delay;
		_handled = true;
		sleep _delay2;
	};
	if(typeName _event == "ARRAY") then {
		_targetsRaised = [];
		{
			_laneTargets = _x;
			if(count _rangeGrouping == 0) then { // single target grouping
				{
					_target = _laneTargets select (_x - 1);
					_target animate ["terc", 0];
					_targetsRaised pushBack _target;
				} foreach _event;
			} else { // grouping is used [[0,1],[2,3,4]] etc
			
			};
		} foreach _rangeLanes;
		
		sleep _delay;
		
		_rangeScores = GET_VAR_ARR(_objectCtrl,GVAR(rangeScores));
		{
			_laneScore = (_rangeScores select _forEachIndex);
			if(isNil "_laneScore") then {_laneScore = 0};
			{
				_target = _x;
				if(_x animationPhase "terc" > 0.5) then {
					_laneScore = _laneScore + 1;
				};
				_x animate ["terc",1];
				SET_VAR_G(_objectCtrl,GVAR(rangeScorePossible),((GET_VAR(_objectCtrl,GVAR(rangeScorePossible))) + 1));
			} foreach _targetsRaised;
			_rangeScores set [_forEachIndex, _laneScore];
			systemChat format ["Lane 1: %1/%2", _rangeScores select _forEachIndex, GET_VAR(_objectCtrl,GVAR(rangeScorePossible))]; 
		} foreach _rangeLanes;
		SET_VAR_G(_objectCtrl,GVAR(rangeScores),_rangeScores);
		
		_handled = true;
	};
	if(!_handled) then {
		ERROR_1("Range event was not handled: %1", str _x);
		sleep _delay;
	};
	sleep _delay2;
} foreach _rangeSequence;

SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),false);

sleep 3;

systemChat "Range complete";

_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeTargets));

{ 
	_possibleScore = GET_VAR(_objectCtrl,GVAR(rangeScorePossible));
	systemChat format ["Lane 1: %1/%2",_rangeScores select _forEachIndex,_possibleScore];
	{
		_x setVariable ["nopop", nil, true];
		_x animate ["terc",0];
	} foreach _x;
} foreach _rangeLanes;

SET_VAR_G(_objectCtrl,GVAR(rangeActive),false);
SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);
