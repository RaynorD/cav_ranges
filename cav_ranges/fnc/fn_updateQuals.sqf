#include "..\script_macros.hpp"

// Running on server only

_this params ["_args",["_showNoGo",true]];

_args DEF_RANGE_PARAMS;

LOG_1("GetQual: %1",_this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));
if(isNil "_rangeTargets") exitWith {NIL_ERROR(_rangeTargets)};

_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
if(isNil "_rangeScores") exitWith {NIL_ERROR(_rangeScores)};

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
			
			if(!(_qual == -1 && !_showNoGo)) then {
				_rangeScoreQuals set [_forEachIndex, _qual];
			};

		};
	};
} foreach _rangeTargets;

SET_VAR_G(_objectCtrl,GVAR(rangeScoreQuals),_rangeScoreQuals);
[_rangeTag, "qual"] remoteExec [QFUNC(updateUI),0];