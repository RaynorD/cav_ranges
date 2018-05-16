/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_startRange

Description:
	Starts the sequence for a popup target range.
	Not used for spawn ranges.

Parameters (Standard range parameters, see fn_createRange for detailed info):
	Type - Sets mode of operation for the range [String, ["targets","spawn"]]
	Title - String representation of the range [String]
	Tag - Internal prefix used for the range, so it can find range objects [String]
	Lane Count - How many lanes there are [Integer]
	Target Count - Number of targets per range [Integer]
	Sequence - List of events when the range is started [Array of Arrays of [event, delay]]
	Grouping - target groupings [Array of Arrays of Numbers]
	Qualitification Tiers - number of targets to attain each qual [Array of Integers]

Returns: 
	Nothing

Locality:
	Server

Examples:
    _this spawn CAV_Ranges_fnc_startRange;

Author:
	=7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

DEF_RANGE_PARAMS;

LOG_1("StartRange: %1", str _this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {ERROR_3("Range trigger (%1_%2) was null: %3",_rangeTag,"trg",_this)};

systemChat format ["%1 started %2", name (GET_VAR(_objectCtrl,GVAR(rangeActivator))), _rangeTitle];
_rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));

_rangeScores = [];

if(isNil "_rangeTargets") exitWith {ERROR_1("Range targets were empty: %1",_this)};

// make sure all targets are up, if not wait until they are
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
	SET_RANGE_VAR(rangeMessage,_msgData);
	[_rangeTag, "message"] remoteExec [QFUNC(updateUI),0];
	sleep 2;
};

// lower all targets, set nopop
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

SET_RANGE_VAR(rangeInteractable,true);

sleep 0.1;

// reset range scores
SET_RANGE_VAR(rangeScores,_rangeScores);
SET_RANGE_VAR(rangeScorePossible,0);
[_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];

// start range sequence
{
	_x params [["_event","Standby..."],["_delay",5],["_delay2",2]];
	_handled = false;
	if(typeName _event == "STRING") then { // range message, show message and progress bar
		SET_RANGE_VAR(rangeMessage,_x);
		[_rangeTag, "message"] remoteExec [QFUNC(updateUI),0];
		sleep _delay;
		_handled = true;
	};
	if(typeName _event == "ARRAY") then { // targets to raise
		
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
			} else { // grouping was used TODO: Doesn't work
				{
					_groupTargets = _x;
					{
						_target = _laneTargets select (_x - 1);
						_target animate ["terc", 0];
						if(_target animationPhase "terc" != 0) then {
							[_target, "FD_Target_PopDown_Large_F"] call CBA_fnc_globalSay3d;
						};
						_targetsRaised pushBack _target;
					} foreach _groupTargets;
				} foreach _event;
			};
		} foreach _rangeTargets;
		
		sleep _delay;
		
		// count downed targets
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
				// update possible score
				SET_RANGE_VAR(rangeScorePossible,((GET_VAR_D(_objectCtrl,GVAR(rangeScorePossible),0))+1));
			} foreach _targetsRaised;
			_rangeScores set [_forEachIndex, _laneScore];
			
		} foreach _rangeTargets;
		
		SET_RANGE_VAR(rangeScores,_rangeScores);
		[_rangeTag, "scores"] remoteExec [QFUNC(updateUI),0];
		_handled = true;
		sleep _delay2;
	};
	if(!_handled) then { // shouldn't happen, means range is misconfigured
		ERROR_1("Range event was not handled: %1", str _x);
		sleep _delay;
	};
} foreach _rangeSequence;

SET_RANGE_VAR(rangeInteractable,false);

sleep 1;

_rangeScores = GET_VAR_ARR(_objectCtrl,GVAR(rangeScores));

if(!isNil "_qualTiers") then {
	[_this,true] spawn FUNC(updateQuals);
};

SET_RANGE_VAR(rangeActive,false);

// This is all just for a systemChat of the results after a range is done, so a chat record is available
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
