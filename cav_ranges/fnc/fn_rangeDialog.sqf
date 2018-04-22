#include "..\script_macros.hpp"

// Running locally on clients only

RANGE_PARAMS;

LOG_1("RangeDialog: %1", str _this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");

if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};
if(isNull _objectUiTrigger) exitWith {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_textSize = (0.47 / (getResolution select 5));

_lineHeight = (safeZoneH * 0.035);
_vertTxtPad = 0.2;

_uiX = safeZoneX + safeZoneW * 0.8;
_uiY = safeZoneY + safeZoneH * 0.3;
_uiW = safeZoneW * 0.2;
_uiH = safeZoneH * 0.12;

_colorTest = [1,0,0,0.0];
_colorTest2 = [0,1,0,0.0];

_rangeLanes = GET_VAR(_objectCtrl,GVAR(rangeTargets));

disableSerialization;

while{true} do {
	
	waitUntil {sleep 1; player in list _objectUiTrigger};
	SystemChat format ["Player entered %1", _objectUiTrigger];
	_idc = 78918;
	
	_laneControls = [];
	_mainCtrls = [];
	
	// 78918
	_ctrlGroup = (findDisplay 46) ctrlCreate ["RscControlsGroup", _idc]; 
	_ctrlGroup ctrlSetPosition [_uiX, _uiY, _uiW, _uiH];
	_ctrlGroup ctrlCommit 0;
	_mainCtrls pushBack _idc;
	_idc = _idc + 1;
	
	// 78919
	_bg = (findDisplay 46) ctrlCreate ["RscText", _idc, _ctrlGroup];
	_bg ctrlSetBackgroundColor [0, 0, 0, 0.5];
	_bg ctrlSetPosition [0, 0, _uiW, _uiH];
	_bg ctrlCommit 0;
	_mainCtrls pushBack _idc;
	_idc = _idc + 1;
	
	// 78920
	_lblTitle = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
	_lblTitle ctrlSetPosition [0, 0, _uiW, (safeZoneH * 0.027)];
	_lblTitle ctrlSetBackgroundColor [0,0,0,0.5];
	_lblTitle ctrlSetStructuredText parseText format ["<t align='center' shadow='2' size='%1'>%2</t>", 1.4 * _textSize, _rangeTitle];
	_lblTitle ctrlCommit 0;
	_mainCtrls pushBack _idc;
	_idc = _idc + 1;
	
	_nextLineY = (ctrlPosition _lblTitle select 1) + (ctrlPosition _lblTitle select 3);
	
	// 78921
	_txtMessage = (findDisplay 46) ctrlCreate ["RscText", _idc, _ctrlGroup];
	_txtMessage ctrlSetPosition [0, _nextLineY, _uiW, _lineHeight];
	//_txtMessage ctrlSetBackgroundColor [0,0,0,0.2];
	_txtMessage ctrlSetTextColor [1, 0.75, 0, 1];
	_txtMessage ctrlSetText "Range on standby...";
	_txtMessage ctrlCommit 0;
	_mainCtrls pushBack _idc;
	SET_VAR_G(_objectCtrl,GVAR(idcMessage),_idc);
	_idc = _idc + 1;
	
	_nextLineY = (ctrlPosition _txtMessage select 1) + (ctrlPosition _txtMessage select 3);
	
	// 78922 and up
	{
		_rowCtrls = [];
		_lblLane = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_lblLane ctrlSetPosition [0, _nextLineY, _uiW * 0.1, _lineHeight];
		//_lblLane ctrlSetBackgroundColor _colorTest;
		_lblLane ctrlSetStructuredText parseText format ["<t size='%1'>&#160;</t><br/><t align='left'>L-%2</t>", _vertTxtPad, _forEachIndex + 1];
		_lblLane ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		_txtScore = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_txtScore ctrlSetPosition [_uiW * 0.1, _nextLineY, _uiW * 0.2, _lineHeight];
		_txtScore ctrlSetBackgroundColor _colorTest2;
		//_txtScore ctrlSetStructuredText parseText format ["<t size='%1'>&#160;</t><br/><t align='center'>- / -</t>", _vertTxtPad];
		_txtScore ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		_txtBadge = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_txtBadge ctrlSetPosition [_uiW * 0.3, _nextLineY, _uiW * 0.2, _lineHeight];
		//_txtBadge ctrlSetBackgroundColor _colorTest;
		//_txtBadge ctrlSetStructuredText parseText format ["<t size='%1'>&#160;</t><br/><t align='center'><img image='%2' /> %3</t>", _vertTxtPad, "cav_ranges\data\expert.paa", "EX"];
		_txtBadge ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		_txtShooter = (findDisplay 46) ctrlCreate ["RscStructuredText", _idc, _ctrlGroup];
		_txtShooter ctrlSetPosition [_uiW * 0.50, _nextLineY, _uiW * 0.5, _lineHeight];
		//_txtShooter ctrlSetBackgroundColor _colorTest2;
		//_txtShooter ctrlSetStructuredText parseText format ["<t size='%1'>&#160;</t><br/><t align='right'>%2</t>", _vertTxtPad, "WO1.Raynor.D"];
		_txtShooter ctrlCommit 0;
		_rowCtrls pushBack _idc;
		_idc = _idc + 1;
		
		_nextLineY = _nextLineY + _lineHeight;
		_laneControls pushBack _rowCtrls;
	} foreach _rangeLanes;
	
	SET_VAR_G(_objectCtrl,GVAR(idcLanes),_laneControls);
	
	
	while {player in list _objectUiTrigger} do {
		_this call FUNC(rangeDialogUpdate);
		sleep 1;
	};
	SystemChat format ["Player left %1", _objectUiTrigger];
	
	{
		ctrlDelete ((findDisplay 46) displayCtrl _x); 
	} foreach _mainCtrls;
	{
		{
			ctrlDelete ((findDisplay 46) displayCtrl _x); 
		} foreach _x;
	} foreach _laneControls;
};