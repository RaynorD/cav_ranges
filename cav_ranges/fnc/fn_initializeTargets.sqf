/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_initializeTargets

Description:
    Initialize target data for targets and spawn modes.
    
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
    _this call CAV_Ranges_fnc_initializeTargets

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

DEF_RANGE_PARAMS;

LOG_1("initializeTargets: %1",_this);

if (_rangeType in ["targets","spawn"]) then {
    
    _rangeArgs params ["_targetCount","_laneCount","_rangeSequence",["_hasHitIndicators",false],["_useCustomTexture",false],["_rangeGrouping",[]]];
    
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
        
        // civ targets
        if(_hasCivTargets) then {
            _civtargets = _hasCivTargets;
            for [{_i=0},{_civtargets},{_i=_i+1}] do {
                private _target = missionNamespace getVariable [format["%1_civtarget_l%2_t%3", _rangeTag, _i, _j], objNull];
            };
        };
    };
    
    SET_RANGE_VAR(rangeTargets,_rangeTargets);
    
    switch (_rangeType) do {
        case ("targets"): {
            if(_hasHitIndicators) then {
                SET_RANGE_VAR(rangeReadouts,_rangeReadouts);
            };
        };
        case ("spawn"): {
            _rangeArgs params ["_targetCount","_laneCount","_rangeSequence",["_hasHitIndicators",false],["_useCustomTexture",false],["_rangeGrouping",[]]];
            if(isServer) then {
                SET_RANGE_VAR(rangeScorePossible,count (_rangeTargets select 0));
                
                //initialize range scores to 0: [0,0,0,0];
                private _scores = [];
                for "_i" from 1 to (count (_rangeTargets select 0)) do {
                    _scores pushBack 0;
                };
                SET_RANGE_VAR(rangeScores,_scores);
                [_rangeTag,"scores"] remoteExec [QFUNC(updateUI),0];
                
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
    };
};
