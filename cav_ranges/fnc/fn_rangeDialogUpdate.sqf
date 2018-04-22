#include "..\script_macros.hpp"

// Running on client only

// Watches the range control object for changing variables for the ui

RANGE_PARAMS;

LOG_1("rangeDialogUpdate: %1", str _this);

//GVAR(idcLanes) [score, qual, shooter]

//GVAR(rangeScores)
//GVAR(rangeScorePossible)
//GVAR(shooterPlayers)


_vertTxtPad = 0.2;

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_idcMessage = GET_VAR(_objectCtrl,GVAR(idcMessage));
if(isNil "_idcMessage") then {ERROR_2("%1 was nil: %2", "_idcMessage", _this)} else {
	_rangeMessage = GET_VAR(_objectCtrl,GVAR(rangeMessage));
	if(!isNil "_rangeMessage") then {
		((findDisplay 46) displayCtrl _idcMessage) ctrlSetText _rangeMessage;
	};
};

_idcLanes = GET_VAR(_objectCtrl,GVAR(idcLanes));
if(isNil "_idcLanes") then {ERROR_2("%1 was nil: %2", "_idcLanes", _this)} else {
	{
		_x params ["_idcLaneLbl","_idcScore", "_idcQual", "_idcShooter"];
		_scoreText = "-";
		_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));	
		if(isNil "_rangeScores") then {ERROR_2("%1 %2 was nil: %3", "_rangeScores", _forEachIndex + 1, _this)} else {
			_scoreText = _rangeScores select _forEachIndex;
		};
		
		_scorePossibleText = "-";
		_rangeScorePossible = GET_VAR(_objectCtrl,GVAR(rangeScorePossible));
		if(isNil "_rangeScorePossible") then {ERROR_2("%1 %2 was nil: %3", "_rangeScorePossible", _forEachIndex + 1, _this)} else {
			_scorePossibleText = _rangeScorePossible;
		};
		
		if(isNil "_idcScore") then {ERROR_2("%1 %2 was nil: %3", "_idcScore", _forEachIndex + 1, _this)} else {
			((findDisplay 46) displayCtrl _idcScore) ctrlSetStructuredText parseText format [
				"<t size='%1'>&#160;</t><br/><t align='center'>%2 / %3</t>",
				_vertTxtPad,
				_scoreText,
				_scorePossibleText
			];
		};
		
		_shooterPlayers = GET_VAR_ARR(_objectCtrl,GVAR(shooterPlayers));
		systemChat format ["getting _shooterPlayers: %1", _shooterPlayers];
		if(isNil "_idcShooter") then {ERROR_2("%1 %2 was nil: %3", "_idcShooter", _forEachIndex + 1, _this)} else {
			if(count _shooterPlayers == 0) then {
				((findDisplay 46) displayCtrl _idcShooter) ctrlSetStructuredText parseText "";
			} else {
				_shooter = (_shooterPlayers select _forEachIndex);
				
				if(isNil "_shooter") then {_shooter = "nil"};
				systemChat format ["getting _shooter: %1", _shooter];
				((findDisplay 46) displayCtrl _idcShooter) ctrlSetStructuredText parseText format [
					"<t size='%1'>&#160;</t><br/><t align='right'>%2</t>",
					_vertTxtPad,
					name _shooter
				];
			};
		};
	} foreach _idcLanes;
};
