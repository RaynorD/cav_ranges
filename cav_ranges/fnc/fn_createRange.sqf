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
    [
        "targets",  // Mode
        //     "targets" : pop up targets, terc animation is used
        //     "spawn"   : spawned units, targets being alive/dead is used
        "Pistol Range", // Title
        "r1", // Tag
        1, // Lane count
        10, // Targets per lane
        [
            // Range sequence
                // First element defines the type of event:
                //        ARRAY: target(s)/group(s) to raise. Multiple elements for multiple targets/groups
                //        STRING: Message to show on the lane UI. Third element is not used in this case
                // Second element: seconds length/delay for that event
                // Third element (optional): delay between end of this event and start of the next, default 2 if not present
            ["Load a magazine.",5],     //show message for 5 seconds
            ["Range is hot!",3],
            [[1],5],                     // raise first target for 5 seconds
            [[3],5],
            [[7],2],
            [[4],2],
            [[9],5],
            ["Reload.",5],
            ["Range is hot!",3],
            [[2,7],8],           // raise targets 2 and 7 for 5 seconds
            [[1,10],8],
            [[7,4],5],
            [[6,2],5],
            [[7,10],5],
            ["Safe your weapon.",3],
            ["Range complete.",0]
        ],
        nil,        // target grouping, nil to disable grouping, otherwise group as define nested arrays: [[0,1],[2,3]] etc
                    //     a particular target can be in multiple groups
        [13,11,9],  // qualification tiers, [expert, sharpshooter, marksman], nil to disable qualifications altogether
                    //     values below the last element will show no go
                    //     Not all three are required, [35] would simply return expert above 35, and no go below that
        true,       // add instructor actions
        true,       // use custom black target texture
    ] spawn cav_ranges_fnc_createRange;

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

// Run on both server and clients at mission init

DEF_RANGE_PARAMS;

LOG_1("CreateRange: %1",_rangeTitle);

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

private _rangeTargets = [];
private _rangeTargetData = [];
private _rangeReadouts = [];

// iterate targets making sure they exist and save to array
// if spawn mode, save target data (type, position, direction)
for "_i" from 1 to _laneCount do {
    private _laneTargets = [];
    private _laneTargetData = [];
    private _readout = nil;
    
    if(_hasHitIndicators) then {
        _thisReadoutData = [];
        _readout = missionNamespace getVariable [format ["%1_readout_l%2", _rangeTag, _i], objNull];
        if(isNull _readout) then {
            ERROR_3("Range readout %1_readout_l%2 was nil: %3", _rangeTag, _i,_this)
        } else {
            _thisReadoutData pushBack _readout;
        };
        _readoutPedestal = missionNamespace getVariable [format ["%1_readoutPedestal_l%2", _rangeTag, _i], objNull];
        if(!isNull _readoutPedestal) then {
            _thisReadoutData pushBack _readoutPedestal;
        };
        
        _rangeReadouts pushBack _thisReadoutData;
        
        if(isServer) then {
            if(_readout isKindOf "TargetP_Inf_F" && _useCustomTexture) then {
                _readout setObjectTextureGlobal [0, QUOTE(IMAGE(target))];
            };
        };
    };
    
    for "_j" from 1 to _targetCount do {
        private _target = missionNamespace getVariable [format["%1_target_l%2_t%3", _rangeTag, _i, _j], objNull];
        if(isNull _target) then {
            ERROR_1("Range target is null: %1",FORMAT_3("%1_target_l%2_t%3",_rangeTag,_i,_j));
        };
        _laneTargets pushBack _target;
        
        // Save ctrl object reference to object for later reference
        SET_VAR_G(_target,GVAR(objectCtrl),_objectCtrl);
        _hitIndicatorData = [format ["%1 L%2",_rangeTitle,_i], _j];
        SET_VAR_G(_target,GVAR(hitIndicatorData),_hitIndicatorData);
        
        if(_rangeType == "spawn") then {
            _laneTargetData pushBack [typeOf _target, getPos _target, [vectorDir _target,vectorUp _target]];
        } else {
            if(isServer) then {
                if(_target isKindOf "TargetP_Inf_F") then {
                    if(_useCustomTexture) then {
                        _target setObjectTextureGlobal [0, QUOTE(IMAGE(target))];
                        SET_VAR_G(_target,GVAR(targetCenter),[ARR_3(-0.001, 0.21, 0.3684)]); // custom target center
                    } else {
                        SET_VAR_G(_target,GVAR(targetCenter),[ARR_3(-0.004,0.161,-0.023)]); //vanilla target accurate
                    };
                };
            };
            
            if(!isDedicated) then {
                if(_hasHitIndicators) then {
                    _target addEventHandler ["HitPart", format [QUOTE(((_this select 0) + [%1]) spawn FUNC(eh_targetHit)), _readout]];
                } else {
                    _target addEventHandler ["HitPart", {(_this select 0) spawn FUNC(eh_targetHit)}];
                };
            };
        };
    };
    if(_rangeType == "spawn") then {
        _rangeTargetData pushBack _laneTargetData;
    };
    _rangeTargets pushBack _laneTargets;
};

SET_RANGE_VAR(rangeTargets,_rangeTargets);

if(_hasHitIndicators) then {
    SET_RANGE_VAR(rangeReadouts,_rangeReadouts);
};

if(_rangeType == "spawn") then {
    SET_RANGE_VAR(rangeTargetData,_rangeTargetData);
};

if(!isDedicated) then {
    // run dialog on clients
    _this spawn FUNC(rangeDialog);
};

if(isServer) then {
    // watch and update lanes' shooters
    _this spawn FUNC(watchCurrentShooter);
};

if(isNil QGVAR(currentActionPriority)) then {
    GVAR(currentActionPriority) = 300;
};

if(GET_VAR_D(player,GVAR(instructor),false) && _addInstructorActions) then {
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
    // popup targets are used, "terc" animation
    case "targets" : {
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

            if(_addInstructorActions) then {
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

    // targets are killed, like an AT range
    case "spawn" : {
        _objectCtrl addAction ["Reset Range", {
            SET_VAR_G((_this select 0),GVAR(rangeReset),true);
            SET_VAR_G((_this select 0),GVAR(rangeInteractable),false);
        }, _this, 1.5, true, true, "", QUOTE((GET_VAR_D(_target,QGVAR(rangeInteractable),false))), 5];

        if(isServer) then {
            SET_RANGE_VAR(rangeScorePossible,count (_rangeTargets select 0));

            //initialize range scores to 0: [0,0,0,0];
            private _scores = [];
            for "_i" from 1 to (count (_rangeTargets select 0)) do {
                _scores pushBack 0;
            };
            SET_RANGE_VAR(rangeScores,_scores);
            [_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];

            LOG_1("rangeScores: %1",_this);
            //begin main loop
            [_this,_objectCtrl] spawn {
                params ["_args","_objectCtrl"];
                _args DEF_RANGE_PARAMS;

                while{true} do {
                    // a player has pressed the range reset
                    if(GET_VAR_D(_objectCtrl,GVAR(rangeReset),false)) then {
                        LOG_1("Resetting %1",_rangeTitle);

                        // first iterates to delete all targets that remain
                        private _rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));
                        {
                            private _targets = _x;
                            {
                                private _target = _x;
                                if(!isNil "_target") then {
                                    deleteVehicle _target;
                                    systemchat format ["deleting target %1",_target];
                                };
                            } foreach _targets;
                        } foreach _rangeTargets;

                        // give time for vehicles to fully delete
                        sleep 2;

                        // iteration to spawn new vehicles
                        private _rangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
                        private _rangeTargetData = GET_VAR(_objectCtrl,GVAR(rangeTargetData));
                        private _newRangeTargets = [];
                        {
                            private _targets = _x;
                            private _laneIndex = _forEachIndex;
                            private _thisLaneData = _rangeTargetData select _laneIndex;
                            private _newTargets = [];
                            {
                                private _target = _x;

                                // open saved target data
                                private _thisTargetData = _thisLaneData select _forEachIndex;
                                _thisTargetData params ["_type","_pos","_vectorDirAndUp"];

                                // create vehicle and set direction
                                private _newTarget = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
                                _newTarget setVectorDirAndUp _vectorDirAndUp;

                                // globalize new object as the correct name
                                private _name = format["%1_target_l%2_t%3", _rangeTag, _laneIndex + 1, _forEachIndex + 1];
                                missionNamespace setVariable [_name,_newTarget];
                                [_newTarget, _name] remoteExec ["setVehicleVarName",0,_newTarget];

                                _newTargets pushBack _newTarget;
                            } foreach _targets;

                            _newRangeTargets pushBack _newTargets;
                            _rangeScores set [_forEachIndex, 0];
                        } foreach _rangeTargets;

                        _rangeTargets = _newRangeTargets;

                        // reset score
                        SET_RANGE_VAR(rangeScores,_rangeScores);
                        [_rangeTag, "scores"] remoteExec [QFUNC(updateUI),0];

                        // if qualTiers were specified and possibly used, reset those
                        if(!isNil "_qualTiers") then {
                            [_args,false] spawn FUNC(updateQuals);
                        };

                        // save new targets
                        SET_RANGE_VAR(rangeTargets,_rangeTargets);
                        SET_RANGE_VAR(rangeReset,false);
                        SET_RANGE_VAR(rangeInteractable,true);
                    } else {
                        // get current range scores to compare later
                        private _oldRangeScores = GET_VAR(_objectCtrl,GVAR(rangeScores));
                        private _rangeTargets = GET_VAR(_objectCtrl,GVAR(rangeTargets));
                        private _rangeScores = [];
                        {
                            private _targets = _x;
                            private _laneIndex = _forEachIndex;
                            private _laneScore = 0;
                            {
                                private _target = _x;
                                // count as a kill if target is nil or dead/immobilized
                                if(isNil "_target") then {
                                    _laneScore = _laneScore + 1;
                                } else {
                                    if(!(alive _target) || !(canMove _target)) then {
                                        _laneScore = _laneScore + 1;
                                    };
                                };
                            } foreach _targets;
                            _rangeScores pushBack _laneScore;
                        } foreach _rangeTargets;

                        // if the scores have changed, fire UI update
                        if(!(_rangeScores isEqualTo _oldRangeScores)) then {
                            SET_RANGE_VAR(rangeScores,_rangeScores);
                            [_rangeTag, "scores"] remoteExec [QFUNC(updateUI),0];

                            if(!isNil "_qualTiers") then {
                                [_args,false] spawn FUNC(updateQuals);
                            };
                        };
                    };
                    sleep 1;
                };
            };
        };
    };
    default { // shouldn't happen unless misconfigured
        ERROR_1("CreateRange received unknown range type: %1",_rangeType);
    };
};
