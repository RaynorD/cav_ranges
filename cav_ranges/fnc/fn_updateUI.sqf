/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_updateUI

Description:
	Updates UI information on clients.

Parameters:
	Tag - Internal prefix used for the range, so it can find range objects [String]
	Element - The UI element that should be updated [String]
	Data - Payload data
		(not used, data is always saved to object namespace first for players that
		enter the range trigger to read)

Returns:
	Nothing

Locality:
	Global
	(Exited on dedicated server)

Examples:
    ["r1","message"] spawn CAV_Ranges_fnc_updateUI;

Author:
	Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

disableSerialization;

if(!hasInterface) exitWith {};

params ["_rangeTag","_element",["_showNoGo",true]];

_currentRange = GET_VAR(player,GVAR(rangeDialogTag));
if (isNil "_currentRange") exitWith {
	LOG_2("Ignoring UpdateUI call for range %1, currently not in a range",_rangeTag);
};
if(!(_currentRange isEqualTo _rangeTag)) exitWith {
	LOG_2("Ignoring UpdateUI call for range %1, currently in range %2",_rangeTag,_currentRange);
};

//SYSCHAT_VAR(_this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {ERROR_3("Range trigger (%1_%2) was null: %3",_rangeTag,"trg",_this)};

//if(!(player in list _objectUiTrigger)) exitWith {LOG("Not in trigger");};

_idcGroup = GET_VAR(_objectCtrl,GVAR(idcGroup));
if(isNil "_idcGroup") exitWith {
	// If spawning in a trigger this will error, ignore
	//NIL_ERROR(_idcGroup)
};
_ctrlGroup = GET_CTRL(_idcGroup);
_ctrlGroupPos = ctrlPosition _ctrlGroup;
_vertTxtPad = 0.2;

switch (_element) do {
	case "message" : {
		_idcMessage = GET_VAR(_objectCtrl,GVAR(idcMessage));
		if(isNil "_idcMessage") then {NIL_ERROR(_idcMessage)} else {
			_text = "";
			_delay = 0;
			
			_rangeMessage = GET_VAR(_objectCtrl,GVAR(rangeMessage));
			
			if(!isNil "_rangeMessage") then {
				LOG_2("UpdateUI: %1 - %2",_this,_rangeMessage);
				if(typeName _rangeMessage != "ARRAY") then {TYPE_ERROR(_rangeMessage)} else {
					if(count _rangeMessage > 0) then {
						_text = _rangeMessage select 0;
						if(typeName _text != "STRING") then {
							TYPE_ERROR(_text);
							_text = "";
						};
					};
					if(count _rangeMessage > 1) then {
						_delay = _rangeMessage select 1;
						if(typeName _delay != "SCALAR") then {
							TYPE_ERROR(_delay);
							_delay = 0;
						};
					};
				};
			};
			
			_ctrlMessage = GET_CTRL(_idcMessage);
			
			if(_text != ctrlText _ctrlMessage) then {
				_ctrlMessage ctrlSetText _text;
				if(_text != "") then {
					_objectCtrl say3d "Beep_Target";
				};
			};
			
			if(_delay > 0) then {
				_idcTimer = GET_VAR(_objectCtrl,GVAR(idcTimer));
				if(isNil "_idcTimer") then {NIL_ERROR(_idcTimer)} else {
					_ctrlTimer = GET_CTRL(_idcTimer);
					
					_ctrlPos = ctrlPosition _ctrlTimer;
					
					_ctrlPos set [2, _ctrlGroupPos select 2];
					_ctrlTimer ctrlSetPosition _ctrlPos;
					_ctrlTimer ctrlCommit _delay;
					
					sleep _delay;
					
					_ctrlPos set [2, 0];
					_ctrlTimer ctrlSetPosition _ctrlPos;
					_ctrlTimer ctrlCommit 0;
				};
			};
		};
	};
	case "scores" : {
		_scorePossible = GET_VAR(_objectCtrl,GVAR(rangeScorePossible));
		_idcLanes = GET_VAR(_objectCtrl,GVAR(idcLanes));
		_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
		if(!isNil "_rangeScores") then {
			LOG_2("UpdateUI: %1 - %2",_this,_rangeScores);
		};
		
		if(isNil "_idcLanes") then {NIL_ERROR(_idcLanes)} else {
			{
				_idcScore = _x select 1;
				if(isNil "_idcScore") then {NIL_ERROR_INDEX(_idcScore)} else {
					_scoreText = ["-","-"];
					
					if(!isNil "_rangeScores") then {
						
						if(typeName _rangeScores != "ARRAY") then {TYPE_ERROR_INDEX(_rangeScores)} else {
							_score = _rangeScores select _forEachIndex;
							if(typeName _score != "SCALAR") then {TYPE_ERROR_INDEX(_score)} else {
								_scoreText set [0,_score];
							};
						};
					};
					
					if(!isNil "_scorePossible") then {
						if(typeName _scorePossible != "SCALAR") then {TYPE_ERROR_INDEX(_scorePossible)} else {
							_scoreText set [1, _scorePossible];
						};
					};
					
					GET_CTRL(_idcScore) ctrlSetStructuredText parseText format [
						"<t size='%1'>&#160;</t><br/><t align='center'>%2 / %3</t>",
						_vertTxtPad,
						_scoreText select 0,
						_scoreText select 1
					];
				};
			} foreach _idcLanes;
		};
	};
	case "qual" : {
		_idcLanes = GET_VAR(_objectCtrl,GVAR(idcLanes));
		if(isNil "_idcLanes") then {NIL_ERROR(_idcLanes)} else {
			_rangeScoreQuals = GET_VAR(_objectCtrl,GVAR(rangeScoreQuals));
			_rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
			_shooterPlayers = GET_VAR(_objectCtrl,GVAR(rangeShooters));
			if(!isNil "_rangeScoreQuals") then {
				LOG_2("UpdateUI: %1 - %2",_this,_rangeScoreQuals);
			};
			
			{
				_idcQual = _x select 2;
				if(isNil "_idcQual") then {NIL_ERROR_INDEX(_idcQual)} else {
					_qualText = ["",""];
					if(!isNil "_rangeScoreQuals") then {
						if(count _rangeScoreQuals > _forEachIndex) then {
							_laneQual = _rangeScoreQuals select _forEachIndex;
							
							if(!isNil "_laneQual") then {
								if(typeName _laneQual != "SCALAR") then {TYPE_ERROR_INDEX(_laneQual)} else {
									if(_laneQual >= count GVAR(scoreTiers)) then {BOUNDS_ERROR_INDEX(GVAR(scoreTiers),_laneQual)} else {
										if(_laneQual >= 0) then {
											_qualText = GVAR(scoreTiers) select _laneQual;
										} else {
											if(count _rangeScores > _forEachIndex) then {
												_showScore = false;
												
												if(count _shooterPlayers > _forEachIndex) then {
													_shooter = _shooterPlayers select _forEachIndex;
													if(!isNil "_shooter") then {
														_showScore = true;
													};
												};
												
												if(_rangeScores select _forEachIndex > 0 && _showNoGo) then {
													_showScore = true;
												};
												
												if(_showScore) then {
													_qualText = ["NG",QUOTE(IMAGE(nogo))];
												};
											};
										};
									};
								};
							};
						};
					};
					
					GET_CTRL(_idcQual) ctrlSetStructuredText parseText format [
						"<t size='%1'>&#160;</t><br/><t align='center'><img image='%2' /> %3</t>",
						_vertTxtPad,
						_qualText select 1,
						_qualText select 0
					];
				};
			} foreach _idcLanes;
		};
	};
	case "shooter" : {
		_idcLanes = GET_VAR(_objectCtrl,GVAR(idcLanes));
		if(isNil "_idcLanes") then {NIL_ERROR(_idcLanes)} else {
			_shooterPlayers = GET_VAR(_objectCtrl,GVAR(rangeShooters));
			LOG_2("UpdateUI: %1 - %2",_this,_shooterPlayers);
			
			if(!isNil "_shooterPlayers") then {
				{
					_idcShooter = _x select 3;
					if(isNil "_idcShooter") then {NIL_ERROR_INDEX(_idcShooter)} else {
						_shooterText = "";

						if(!isNil "_shooterPlayers") then {
							if(typeName _shooterPlayers != "ARRAY") then {TYPE_ERROR_INDEX(_shooterPlayers)} else {
								if(count _shooterPlayers > _forEachIndex) then {
									_shooter = _shooterPlayers select _forEachIndex;
									if(!isNil "_shooter") then {
										if(typeName _shooterText != "STRING") then {TYPE_ERROR_INDEX(_shooterText)} else {
											_shooterText = name _shooter;
										};
									};
								};
							};
						};
						
						GET_CTRL(_idcShooter) ctrlSetStructuredText parseText format [
							"<t size='%1'>&#160;</t><br/><t align='right'>%2</t>",
							_vertTxtPad,
							_shooterText
						];
					};
				} foreach _idcLanes;
			};
		};
	};
};
