#include "..\script_macros.hpp"

// Running on client only

DEF_RANGE_PARAMS;

LOG_1("rangeDialogUpdate: %1", str _this);

GVAR(rangeDialogFirstUpdate) = if(isNil QGVAR(rangeDialogFirstUpdate)) then {true} else {false};

//GVAR(idcLanes) [score, qual, shooter]

//GVAR(rangeScores)
//GVAR(rangeScorePossible)
//GVAR(rangeScoresQual)
//GVAR(shooterPlayers)
//FD_Timer_F, FD_Start_F, FD_Finish_F, FD_Course_Active_F, FD_CP_Clear_F, FD_CP_Not_Clear_F, Beep_Target, addItemOK, addItemFailed


_vertTxtPad = 0.2;

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {if(GVAR(rangeDialogFirstUpdate)) then {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)}};

_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {if(GVAR(rangeDialogFirstUpdate)) then {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)}};

_idcMessage = GET_VAR(_objectCtrl,GVAR(idcMessage));
if(isNil "_idcMessage") then {if(GVAR(rangeDialogFirstUpdate)) then {ERROR_2("%1 was nil: %2", "_idcMessage", _this)}} else {
	_rangeMessage = GET_VAR(_objectCtrl,GVAR(rangeMessage));
	if(isNil "_rangeMessage") then {
		if(ctrlText ((findDisplay 46) displayCtrl _idcMessage) != "") then {
			((findDisplay 46) displayCtrl _idcMessage) ctrlSetText "";
		};
	} else {
		if(_rangeMessage != (ctrlText ((findDisplay 46) displayCtrl _idcMessage))) then {
			((findDisplay 46) displayCtrl _idcMessage) ctrlSetText _rangeMessage;
			[_objectCtrl, "Beep_Target"] call CBA_fnc_globalSay3d;
		};
	};
};

_idcLanes = GET_VAR(_objectCtrl,GVAR(idcLanes));
if(isNil "_idcLanes") then {if(GVAR(rangeDialogFirstUpdate)) then {ERROR_2("%1 was nil: %2", "_idcLanes", _this)}} else {
	{
		_x params ["_idcLaneLbl","_idcScore", "_idcQual", "_idcShooter"];

		if(isNil "_idcScore") then {if(GVAR(rangeDialogFirstUpdate)) then {ERROR_2("%1 %2 was nil: %3", "_idcScore", _forEachIndex + 1, _this)}} else {
			_scoreText = "-";
			_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
			if(isNil "_rangeScores") then {
				if(ctrlText ((findDisplay 46) displayCtrl _idcScore) != "") then {
					((findDisplay 46) displayCtrl _idcScore) ctrlSetText "";
				};
			} else {
				_scoreText = _rangeScores select _forEachIndex;
			};
			
			_scorePossibleText = "-";
			_rangeScorePossible = GET_VAR(_objectCtrl,GVAR(rangeScorePossible));
			if(isNil "_rangeScorePossible") then {
				if(ctrlText ((findDisplay 46) displayCtrl _idcScore) != "") then {
					((findDisplay 46) displayCtrl _idcScore) ctrlSetText "";
				};
			} else {
				_scorePossibleText = _rangeScorePossible;
			};
			
			((findDisplay 46) displayCtrl _idcScore) ctrlSetStructuredText parseText format [
				"<t size='%1'>&#160;</t><br/><t align='center'>%2 / %3</t>",
				_vertTxtPad,
				_scoreText,
				_scorePossibleText
			];
		};
		
		if(isNil "_idcQual") then {if(GVAR(rangeDialogFirstUpdate)) then {ERROR_2("%1 %2 was nil: %3", "_idcQual", _forEachIndex + 1, _this)}} else {
			
			_rangeScoreQuals = GET_VAR(_objectCtrl,GVAR(rangeScoreQuals));
			if(isNil "_rangeScoreQuals") then {
				//LOG_2("%1 was nil: %2", "_rangeScoreQuals",  _this);
				// clear text if present
				if(ctrlText ((findDisplay 46) displayCtrl _idcQual) != "") then {
					((findDisplay 46) displayCtrl _idcQual) ctrlSetText "";
				};
			} else {
				_qualText = ["",""];
				_qual = _rangeScoreQuals select _forEachIndex;
				
				
				if(!isNil "_qual") then {
					if(_qual >= count GVAR(scoreTiers)) then {ERROR_2("%1: _qual %2 was outside bounds: %3", "_idcQual", _forEachIndex + 1, _this)};
					if(_qual >= 0) then {
						_qualText = GVAR(scoreTiers) select _qual;
					} else {
						_qualText = ["NG",QUOTE(IMAGE(nogo))];
					};
				};

				((findDisplay 46) displayCtrl _idcQual) ctrlSetStructuredText parseText format [
					"<t size='%1'>&#160;</t><br/><t align='center'><img image='%2' /> %3</t>",
					_vertTxtPad,
					_qualText select 1,
					_qualText select 0
				];
			};
		};
		
		_shooterPlayers = GET_VAR_ARR(_objectCtrl,GVAR(shooterPlayers));
		//systemChat format ["getting _shooterPlayers: %1", _shooterPlayers];
		if(isNil "_idcShooter") then {if(GVAR(rangeDialogFirstUpdate)) then {ERROR_2("%1 %2 was nil: %3", "_idcShooter", _forEachIndex + 1, _this)}} else {
			if(count _shooterPlayers == 0) then {
				((findDisplay 46) displayCtrl _idcShooter) ctrlSetText "";
			} else {
				_shooter = (_shooterPlayers select _forEachIndex);
				
				if(isNil "_shooter") then {_shooter = "nil"};
				//systemChat format ["getting _shooter: %1", _shooter];
				((findDisplay 46) displayCtrl _idcShooter) ctrlSetStructuredText parseText format [
					"<t size='%1'>&#160;</t><br/><t align='right'>%2</t>",
					_vertTxtPad,
					name _shooter
				];
			};
		};
	} foreach _idcLanes;
};
