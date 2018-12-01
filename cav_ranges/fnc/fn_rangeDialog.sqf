/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_rangeDialog

Description:
	Initializes a range's dialog on clients.

Parameters:
	
	Type - Sets mode of operation for the range [String, ["targets","spawn"]]
	Title - String representation of the range [String]
	Tag - Internal prefix used for the range, so it can find range objects [String]
	Lane Count - How many lanes there are [Integer]
	Target Count - Number of targets per range [Integer]
	Sequence - List of events when the range is started [Array of Arrays of [event, delay]]
	Grouping - target groupings [Array of Arrays of Numbers]
	Qualification Tiers - number of targets to attain each qual [Array of Integers]

Returns:
	Nothing

Locality:
	Clients

Examples:
    _this spawn CAV_Ranges_fnc_rangeDialog;

Author:
	=7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

if(isDedicated) exitWith {};

DEF_RANGE_PARAMS;

LOG_1("RangeDialog: %1", str _this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) is null: %3",_rangeTag,"ctrl",_this)};

_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {ERROR_3("Range UI Trigger (%1_%2) is null: %3",_rangeTag,"trg", _this)};

_textSize = (0.47 / (getResolution select 5));

_lineHeight = (safeZoneH * 0.035);
_vertTxtPad = 0.2;

_uiX = safeZoneX + safeZoneW * 0.8;
_uiX0 = safeZoneX + safeZoneW;
_uiY = safeZoneY + safeZoneH * 0.3;
_uiW = safeZoneW * 0.2;
_uiH = safeZoneH * 0.12;

// animation time for dialog to slide in/out
_animTime = 1;

_rangeLanes = GET_VAR(_objectCtrl,GVAR(rangeTargets));

disableSerialization;

while{true} do {
	// wait until player enters the trigger area for this range
	waitUntil {sleep 1; player in list _objectUiTrigger};
	
	INFO_1("Entered %1",_rangeTitle);
	
	// If player teleported between ranges, wait until previous UI has finished being destroyed
	waitUntil {sleep 0.1; !(GET_VAR_D(player,GVAR(rangeDialogShown),false))};
	// prevent other UIs from opening until this one is destroyed
	SET_VAR_G(player,GVAR(rangeDialogShown),true);
	SET_VAR_G(player,GVAR(rangeDialogTag),_rangeTag);
	
	LOG_1("Start showing %1 UI",_rangeTitle);

	_idc = IDC_ROOT;
	
	_laneControls = [];
	_mainCtrls = [];
	
	// Control group which all controls live inside
	// This is so the dialog can be moved
	_ctrlGroup = (findDisplay 46) ctrlCreate ["RscControlsGroup", _idc];
	_ctrlGroup ctrlSetPosition [_uiX0, _uiY, _uiW, _uiH];
	_ctrlGroup ctrlCommit 0;
	_mainCtrls pushBack _idc;
	SET_VAR(_objectCtrl,GVAR(idcGroup),_idc);
	_idc = _idc + 1;
	
	// Background color
	_bg = (findDisplay 46) ctrlCreate ["RscText", _idc, _ctrlGroup];
	_bg ctrlSetBackgroundColor [0, 0, 0, 0.5];
	_bg ctrlSetPosition [0, 0, _uiW, _uiH];
	_bg ctrlCommit 0;
	_mainCtrls pushBack _idc;
	_idc = _idc + 1;
	
	// Dialog title, shows range title
	_lblTitle = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
	_lblTitle ctrlSetPosition [0, 0, _uiW, (safeZoneH * 0.027)];
	_lblTitle ctrlSetBackgroundColor [0,0,0,0.5];
	_lblTitle ctrlSetStructuredText parseText format ["<t align='center' shadow='2' size='%1'>%2</t>", 1.4 * _textSize, _rangeTitle];
	_lblTitle ctrlCommit 0;
	_mainCtrls pushBack _idc;
	_idc = _idc + 1;
	
	_nextLineY = (ctrlPosition _lblTitle select 1) + (ctrlPosition _lblTitle select 3);
	
	// Range message that shows text events in the range sequence
	_txtMessage = (findDisplay 46) ctrlCreate ["RscText", _idc, _ctrlGroup];
	_txtMessage ctrlSetPosition [0, _nextLineY, _uiW, _lineHeight * 1.1];
	_txtMessage ctrlSetBackgroundColor [0,0,0,0.3];
	_txtMessage ctrlSetTextColor [1, 1, 1, 1];
	_txtMessage ctrlCommit 0;
	_mainCtrls pushBack _idc;
	SET_VAR(_objectCtrl,GVAR(idcMessage),_idc);
	_idc = _idc + 1;
	
	// check if message is set already
	_message = GET_VAR(_objectCtrl,GVAR(rangeMessage));
	if(!isNil "_message") then {
		_txtMessage ctrlSetText (_message select 0);
	};
	
	
	// Yellow progress bar for text events
	_ctrlTimer = (findDisplay 46) ctrlCreate ["RscText", _idc, _ctrlGroup];
	_ctrlTimer ctrlSetPosition [0, _nextLineY, 0, _lineHeight * 0.1];
	_ctrlTimer ctrlSetBackgroundColor [1,0.8,0,1];
	_ctrlTimer ctrlSetTextColor [1, 1, 1, 1];
	_ctrlTimer ctrlCommit 0;
	_mainCtrls pushBack _idc;
	SET_VAR(_objectCtrl,GVAR(idcTimer),_idc);
	_idc = _idc + 1;
	
	_nextLineY = (ctrlPosition _txtMessage select 1) + (ctrlPosition _txtMessage select 3);
	
	// load range data if it exists
	_scores = GET_VAR(_objectCtrl,GVAR(rangeScores));
	_qual = GET_VAR(_objectCtrl,GVAR(rangeScoreQuals));
	_shooters = GET_VAR(_objectCtrl,GVAR(rangeShooters));
	
	{
		_rowCtrls = [];
		
		// Far left static label for lane, L-1, L-2, etc
		_lblLane = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_lblLane ctrlSetPosition [0, _nextLineY, _uiW * 0.1, _lineHeight];
		_lblLane ctrlSetStructuredText parseText format ["<t size='%1'>&#160;</t><br/><t align='left'>L-%2</t>", _vertTxtPad, _forEachIndex + 1];
		_lblLane ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		// Shows current/possible score for that lane, 40/40
		_txtScore = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_txtScore ctrlSetPosition [_uiW * 0.1, _nextLineY, _uiW * 0.2, _lineHeight];
		_txtScore ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		_scoreText = "-";
		_scorePossibleText = "-";
		
		// read current score
		_text = format ["<t size='%1'>&#160;</t><br/><t align='center'>- / -</t>", _vertTxtPad];
		if(!isNil "_scores") then {
			_laneScore = _scores select _forEachIndex;
			if(!isNil "_lanescore") then {
				_scoreText = _lanescore;
			};
		};
		
		// read possible score
		_rangeScorePossible = GET_VAR(_objectCtrl,GVAR(rangeScorePossible));
		if(!isNil "_rangeScorePossible") then {
			_scorePossibleText = _rangeScorePossible;
		};
		
		// actually set text
		_txtScore ctrlSetStructuredText parseText format [
			"<t size='%1'>&#160;</t><br/><t align='center'>%2 / %3</t>",
			_vertTxtPad,
			_scoreText,
			_scorePossibleText
		];
		
		// Qualification tier. Shows badge and two letter abbreviation.
		_txtQual = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_txtQual ctrlSetPosition [_uiW * 0.3, _nextLineY, _uiW * 0.2, _lineHeight];
		_txtQual ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		_rangeScoreQuals = GET_VAR(_objectCtrl,GVAR(rangeScoreQuals));
		if(!isNil "_rangeScoreQuals") then {
			_laneQual = _rangeScoreQuals select _forEachIndex;
			
			if(!isNil "_laneQual") then {
				_qualText = ["",""];
				
				if(_laneQual >= count GVAR(scoreTiers)) then {ERROR_3("%1: _laneQual %2 was outside bounds: %3", "_idcQual", _forEachIndex + 1, _this)} else {
					if(_laneQual >= 0) then {
						_qualText = GVAR(scoreTiers) select _laneQual;
					} else {
						// need to find a better place for this, maybe not use -1 for it
						_qualText = ["NG",QUOTE(IMAGE(nogo))];
					};
					
					_txtQual ctrlSetStructuredText parseText format [
						"<t size='%1'>&#160;</t><br/><t align='center'><img image='%2' /> %3</t>",
						_vertTxtPad,
						_qualText select 1,
						_qualText select 0
					];
				};
			};
		};
		
		// Shows current person shooting at this lane
		_txtShooter = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_txtShooter ctrlSetPosition [_uiW * 0.50, _nextLineY, _uiW * 0.5, _lineHeight];
		_txtShooter ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		_shooters = GET_VAR(_objectCtrl,GVAR(rangeShooters));
		if(!isNil "_shooters") then {
			if(count _shooters > _forEachIndex) then {
				_shooter = _shooters select _forEachIndex;
				if(!isNil "_shooter") then {
					_txtShooter ctrlSetStructuredText parseText format [
						"<t size='%1'>&#160;</t><br/><t align='right'>%2</t>",
						_vertTxtPad,
						_shooter
					];
				};
			};
		};
		
		_nextLineY = _nextLineY + _lineHeight;
		_laneControls pushBack _rowCtrls;
	} foreach _rangeLanes;
	
	// save idcs to control object so other functions can update their text
	SET_VAR(_objectCtrl,GVAR(idcLanes),_laneControls);
	
	// set ui height based on how many lanes there were
	_uiH = _nextLineY;
	_uiPos = ctrlPosition _ctrlGroup;
	_uiPos set [3, _uiH];
	_ctrlGroup ctrlSetPosition _uiPos;
	_ctrlGroup ctrlCommit 0;
	_bgPos = [0,0,_uiW,_uiH];
	_bg ctrlSetPosition _bgPos;
	_bg ctrlCommit 0;

	// start slide out animation
	_ctrlGroup ctrlSetPosition [_uiX, _uiY, _uiW, _uiH];
	_ctrlGroup ctrlCommit _animTime;
	
	// wait for animation to finish
	sleep _animTime;
	
	LOG_1("Finished showing %1 UI",_rangeTitle);
	
	// wait until player leaves the range trigger
	waitUntil {sleep 1; !(player in list _objectUiTrigger)};
	LOG_1("Start hiding %1 UI",_rangeTitle);
	
	// slide dialog off screen
	_ctrlGroup ctrlSetPosition [_uiX0, _uiY, _uiW, _uiH];
	_ctrlGroup ctrlCommit _animTime;
	sleep _animTime;
	
	// delete controls
	{
		ctrlDelete GET_CTRL(_x);
	} foreach _mainCtrls;
	{
		{
			ctrlDelete GET_CTRL(_x);
		} foreach _x;
	} foreach _laneControls;
	
	LOG_1("Finished hiding %1 UI",_rangeTitle);
	
	// Tell other range dialogs that they can start constructing
	SET_VAR_G(player,GVAR(rangeDialogShown),false);
	SET_VAR_G(player,GVAR(rangeDialogTag),nil);
};
