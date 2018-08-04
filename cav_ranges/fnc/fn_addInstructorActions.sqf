/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_addInstructorActions

Description:
    Adds player actions to instructors for controlling the range.

Compatible range types:
    targets
    spawn

Parameters:
    Standard range parameters

Returns:
    Nothing

Locality:
    Global

Examples:
    [_args] call CAV_Ranges_fnc_hitIndicators

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

DEF_RANGE_PARAMS;

LOG_1("AddInstructorActions: %1",_this);

if(isNil QGVAR(currentActionPriority)) then {
    GVAR(currentActionPriority) = 300;
};

if(GET_VAR_D(player,GVAR(instructor),false)) then {
    if(isNil {GET_VAR(player,GVAR(rangeControlsAdded))}) then {
        SET_VAR(player,GVAR(rangeControlsAdded),true);
        player addAction [
            "<t color='#00ff00'>Open Range Controls</t>",
            {player setVariable ['Cav_showRangeActions',true]},
            nil,
            0,
            false,
            false,
            "",
            "!(player getVariable ['Cav_showRangeActions',false])" //TODO: convert to framework variable
        ];
        
        player addAction [
            "<t color='#ff0000'>Collapse Range Controls</t>",
            {player setVariable ['Cav_showRangeActions',false]},
            nil,
            GVAR(currentActionPriority),
            false,
            true,
            "",
            "(player getVariable ['Cav_showRangeActions',false])" //TODO: convert to framework variable
        ];
    };
};

GVAR(currentActionPriority) = GVAR(currentActionPriority) - 1;

switch _rangeType do {
    case "targets" : {
        _rangeArgs params ["_targetCount","_laneCount","_rangeSequence",["_hasHitIndicators",false],["_useCustomTexture",false],["_rangeGrouping",[]]];
        
        if(GET_VAR_D(player,GVAR(instructor),false)) then {
            GVAR(currentActionPriority) = GVAR(currentActionPriority) - 1;
            
            player addAction [
                format ["<t color='#00ff00'>    %1 - Start</t>",_rangeTitle],
                {
                    SET_VAR_G((_this select 3),GVAR(rangeActive),true);
                    SET_VAR_G((_this select 3),GVAR(rangeActivator),(_this select 1));
                    SET_VAR_G((_this select 3),GVAR(rangeInteractable),false);
                },
                _objectCtrl,
                GVAR(currentActionPriority),
                false,
                true,
                "",
                format ["(player getVariable ['Cav_showRangeActions',false]) && !(%1 getVariable ['%2', false]) && (%1 getVariable ['%3', false])", _objectCtrl, QGVAR(rangeActive), QGVAR(rangeInteractable)] //TODO: convert to framework variable
            ];
            
            player addAction [
                format ["<t color='#ff0000'>    %1 - Stop</t>",_rangeTitle],
                {
                    SET_VAR_G(((_this select 3) select 0),GVAR(rangeActivator),(_this select 1));
                    ((_this select 3) select 1) remoteExec [QFUNC(cancelRange),2];
                },
                [_objectCtrl,_this],
                GVAR(currentActionPriority),
                false,
                true,
                "",
                format ["(player getVariable ['Cav_showRangeActions',false]) && (%1 getVariable ['%2', false]) && (%1 getVariable ['%3', false])", _objectCtrl, QGVAR(rangeActive), QGVAR(rangeInteractable)] //TODO: convert to framework variable
            ];
            
            if (_hasHitIndicators) then {
                GVAR(currentActionPriority) = GVAR(currentActionPriority) - 1;
                
                player addAction [
                    format ["<t color='#00ff00'>        %1 - Show Hit Indicators</t>",_rangeTitle],
                    {(_this select 3) spawn FUNC(hitIndicators)},
                    [_rangeTag, true],
                    GVAR(currentActionPriority),
                    false,
                    true,
                    "",
                    format ["(player getVariable ['Cav_showRangeActions',false]) && !(%1 getVariable ['%2', false]) && (%1 getVariable ['%3', false])", _objectCtrl, QGVAR(hitIndicators), QGVAR(rangeInteractable)] //TODO: convert to framework variable
                ];
                
                player addAction [
                    format ["<t color='#ff0000'>        %1 - Hide Hit Indicators</t>",_rangeTitle],
                    {(_this select 3) spawn FUNC(hitIndicators)},
                    [_rangeTag, false],
                    GVAR(currentActionPriority),
                    false,
                    true,
                    "",
                    format ["(player getVariable ['Cav_showRangeActions',false]) && (%1 getVariable ['%2', false]) && (%1 getVariable ['%3', false])", _objectCtrl, QGVAR(hitIndicators), QGVAR(rangeInteractable)] //TODO: convert to framework variable
                ];
            };
        };
    };

    case "spawn" : {
        
    };
};
