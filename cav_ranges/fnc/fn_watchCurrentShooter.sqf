/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_watchCurrentShooter

Description:
	Checks for a player close to each shooting position and saves it to the ctrl object
	It is only run if ther is a player currently in the trigger

Parameters:
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
    [
		"targets", 	//	"targets" : pop up targets, terc animation is used
					//	"spawn"   : spawned units, targets being alive/dead is used
		"Pistol Range",	// Title
		"r1",			// Tag
		1,				// Lane count
		10,				// Targets per lane
		[				
										// Range sequence
											// First element defines the type of event:
											//		ARRAY: target(s)/group(s) to raise. Multiple elements for multiple targets/groups
											//		STRING: Message to show on the lane UI. Third element is not used in this case
											// Second element: seconds length/delay for that event
											// Third element (optional): delay between end of this event and start of the next, default 2 if not present
			["Load a magazine.",5], 	//show message for 5 seconds
			["Range is hot!",3],
			[[1],5], 					// raise first target for 5 seconds
			[[3],5],
			[[7],2],
			[[4],2],
			[[9],5],
			["Reload.",5],
			["Range is hot!",3],
			[[2,7],8], 					// raise targets 2 and 7 for 5 seconds
			[[1,10],8],
			[[7,4],5],
			[[6,2],5],
			[[7,10],5],
			["Safe your weapon.",3],
			["Range complete.",0]
		],
		nil,							// target grouping, nil to disable grouping, otherwise group as define nested arrays: [[0,1],[2,3]] etc
										//     a particular target can be in multiple groups
		[13,11,9]						// qualification tiers, [expert, sharpshooter, marksman], nil to disable qualifications altogether
										//     values below the last element will show no go
										//     Not all three are required, [35] would simply return expert above 35, and no go below that
	] spawn CAV_Ranges_fnc_watchCurrentShooter;

Author:
	=7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

// When a player is present in the range trigger, 
// 

DEF_RANGE_PARAMS;

LOG_1("watchCurrentShooter: %1", str _this);

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
_objectUiTrigger = GET_ROBJ(_rangeTag,"trg");

if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};
if(isNull _objectUiTrigger) exitWith {ERROR_2("Range UI Trigger (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

_rangeLanes = GET_VAR(_objectCtrl,GVAR(rangeTargets));

while {true} do {
	// waitUntil a player is in the trigger
	waitUntil {sleep 3; count list _objectUiTrigger > 0};
	
	while {count list _objectUiTrigger > 0} do {
		_rangeShooters = GET_VAR(_objectCtrl,GVAR(rangeShooters));
		_newShooters = [];
		{
			// get closest player to lane's shooting pos object
			_shootingPos = GET_ROBJ_L(_rangeTag,"shootingPos",(_forEachIndex + 1));
			if(isNull _shootingPos) exitWith {ERROR_2("Shooting pos (%1) is null: %2", FORMAT_3("%1_%2_l%3",_rangeTag,"shootingPos",(_forEachIndex + 1)), _this)};
			_shooter = ((_shootingPos nearEntities ["Man", 1.5]) select 0);
			if(!isNil "_shooter") then {
				if(typeName _shooter != "OBJECT") then {TYPE_ERROR(_shooter)} else {
					_newShooters set [_forEachIndex, _shooter];
				};
			};
		} foreach _rangeLanes;
		
		_update = true;
		
		// if the list previously existed and hasn't changed, don't update the UI
		if(!isNil "_rangeShooters") then {
			if(_newShooters isEqualTo _rangeShooters) then {
				_update = false;
			};
		};
		
		if(_update) then {
			SET_VAR_G(_objectCtrl,GVAR(rangeShooters),_newShooters);
			[_rangeTag, "shooter"] remoteExec [QFUNC(updateUI),0];
		};
		
		sleep 1;
	};
	
	// once everyone has left the trigger, clear the data
	_rangeShooters = [];
	SET_VAR_G(_objectCtrl,GVAR(rangeShooters),[]);
	[_rangeTag, "shooter"] remoteExec [QFUNC(updateUI),0];
};
