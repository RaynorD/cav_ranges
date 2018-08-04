/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_createRange

Description:
    Builds the range with user provided values.

    This would be the only "public" scope function.

Parameters:
    Type - Sets mode of operation for the range [String, ["targets","spawn"]]
    Title - String representation of the range [String]
    Tag - Internal prefix used for the range, so it can find range objects [String]
    Lane Count - How many lanes there are [Integer]
    Target Count - Number of targets per range [Integer]
    Sequence - List of events when the range is started [Array of Arrays of [event, delay]]
    Grouping - target groupings [Array of Arrays of Numbers]
    Qualification Tiers - number of targets to attain each qual [Array of Integers]
    Add Instructor Actions - whether to add player-bound actions to start/stop range [Boolean]

Returns:
    Nothing

Locality:
    Global

Examples:
    

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

// Run on both server and clients at mission init

DEF_RANGE_PARAMS;

//targets
//_rangeArgs params ["_targetCount","_laneCount","_rangeSequence",["_hasHitIndicators",false],["_useCustomTexture",false],["_rangeGrouping",[]]]

LOG_1("CreateRange: %1",_this);

if(hasInterface) then {
    waitUntil {sleep 0.1; !isNull player}; // a stab at fixing JIP addactions
};

private _objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

private _objectUiTrigger = GET_ROBJ(_rangeTag,"trg");
if(isNull _objectUiTrigger) exitWith {ERROR_3("Range trigger (%1_%2) was null: %3",_rangeTag,"trg",_this)};

SET_RANGE_VAR(rangeActive,false);
SET_RANGE_VAR(rangeInteractable,true);

// if the control object is a signpost, use 7Cav image
if(typeOf _objectCtrl in ["Land_InfoStand_V1_F", "Land_InfoStand_V2_F"]) then {
    _objectCtrl setObjectTexture [0, QUOTE(IMAGE(7th))];
};

if(_rangeType in ["targets","spawn"]) then {
    _this call FUNC(initializeTargets);
};

if(_addInstructorActions) then {
    _this call FUNC(addInstructorActions);
};

switch (_rangeType) do {
    case ("targets"): {
        if(GET_VAR_D(player,GVAR(instructor),false)) then {
            _objectCtrl addAction ["Start Range", {
                SET_VAR_G((_this select 0),GVAR(rangeActive),true);
                SET_VAR_G((_this select 0),GVAR(rangeActivator),(_this select 1));
                SET_VAR_G((_this select 0),GVAR(rangeInteractable),false);
            }, nil, 1.5, true, true, "", QUOTE(!(GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
            _objectCtrl addAction ["Stop Range", {
                SET_VAR_G((_this select 0),GVAR(rangeActivator),(_this select 1));
                (_this select 3) remoteExec [QFUNC(cancelRange),2];
            }, _this, 1.5, true, true, "", QUOTE((GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
            // reset range UI after running the course
            _objectCtrl addAction ["Reset Range Data", {
                (_this select 3) spawn FUNC(resetRangeData);
            }, _this, 1.5, true, true, "", QUOTE(!(GET_VAR_D(_target,QGVAR(rangeActive),false)) && (GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
        };
        if(isServer) then {
            [_objectCtrl,_this] spawn {
                params ["_objectCtrl","_args"];
                while{true} do {
                    // wait until someone presses the start range button
                    waitUntil { sleep 0.5; _objectCtrl getVariable [QGVAR(rangeActive), false]};
                    
                    // run range and save handle
                    SET_RANGE_VAR(sequenceHandle,_args spawn FUNC(startRange));
                    
                    // wait until range is done to restart loop
                    waitUntil { sleep 0.5; !(_objectCtrl getVariable [QGVAR(rangeActive), false])};
                };
            };
        };
    };
    case ("spawn"): {
        _objectCtrl addAction ["Reset Range", {
            SET_VAR_G((_this select 0),GVAR(rangeReset),true);
            SET_VAR_G((_this select 0),GVAR(rangeInteractable),false);
        }, _this, 1.5, true, true, "", QUOTE((GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];
    };
    default { // shouldn't happen unless misconfigured
        ERROR_1("CreateRange received unknown range type: %1",_rangeType);
    };
};

if(hasInterface) then {
    // run dialog on clients
    _this spawn FUNC(rangeDialog);
};

if(isServer) then {
    // watch and update lanes' shooters
    _this spawn FUNC(watchCurrentShooter);
};
