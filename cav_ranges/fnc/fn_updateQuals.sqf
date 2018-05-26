/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_stopRange

Description:
	Stops the sequence for a popup target range.
	Used for both normal and premature end of the sequence.
	
	Not used for spawn ranges.

Parameters:
	Args - (Standard range parameters, see fn_createRange for detailed info):
		Type - Sets mode of operation for the range [String, ["targets","spawn"]]
		Title - String representation of the range [String]
		Tag - Internal prefix used for the range, so it can find range objects [String]
		Lane Count - How many lanes there are [Integer]
		Target Count - Number of targets per range [Integer]
		Sequence - List of events when the range is started [Array of Arrays of [event, delay]]
		Grouping - target groupings [Array of Arrays of Numbers]
		Qualitification Tiers - number of targets to attain each qual [Array of Integers]
	Show No Go - Whether to set the flag to -1 if below no go threshold [Boolean, optional - default true]
		(So that AT range doesn't just show no go all the time)

Returns: 
	Nothing

Locality:
	Server

Examples:
   [_this,false] spawn CAV_Ranges_fnc_stopRange;

Author:
	=7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

_this params ["_args",["_showNoGo",true]];

_args DEF_RANGE_PARAMS;

LOG_1("GetQual: %1",_this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));
if(isNil "_rangeTargets") exitWith {NIL_ERROR(_rangeTargets)};

_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
if(isNil "_rangeScores") exitWith {NIL_ERROR(_rangeScores)};

if(isNil "_qualTiers") exitWith {LOG_1("%1 qualTiers is nil", _rangeTitle)};

// return qualification tier, need to make this scalable
_rangeScoreQuals = [];
{
	if((count _rangeScores) > _forEachIndex) then {
		_score = _rangeScores select _forEachIndex;
		if(!isNil "_score") then {
			_qual = -1;
			if(_score > 0) then {
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
			};
			
			if(!(_qual == -1 && !_showNoGo)) then {
				_rangeScoreQuals set [_forEachIndex, _qual];
			};

		};
	};
} foreach _rangeTargets;

SET_RANGE_VAR(rangeScoreQuals,_rangeScoreQuals);
[_rangeTag, "qual"] remoteExec [QFUNC(updateUI),0];