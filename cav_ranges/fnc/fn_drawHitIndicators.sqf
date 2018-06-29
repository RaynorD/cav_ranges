/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_drawHitIndicators

Description:
    Draws hit indicators for a range

Parameters:
  

Returns:
    Nothing

Locality:
    Client

Examples:
    [] spawn CAV_Ranges_fnc_drawHitIndicators;

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

params ["_readout"];

// 0.0013 ms
_distance = _readout distance player;
if(_distance > 40) exitWith {
    //if(GET_VAR_D(_readout,GVAR(exitReason),"") != "distance") then {
    //    systemChat format ["%1 drawHitIndicators exit: distance",_readout];
    //    LOG_1("%1 drawHitIndicators exit: distance",_readout);
    //    SET_VAR(_readout,GVAR(exitReason),"distance");
    //};
};

// 0.0025 ms
private _thisLaneHits = GET_VAR_ARR(_readout,GVAR(rangeHits));
if(count _thisLaneHits == 0) exitWith {
    //if(GET_VAR_D(_readout,GVAR(exitReason),"") != "count") then {
    //    systemChat format ["%1 drawHitIndicators exit: count",_readout];
    //    LOG_1("%1 drawHitIndicators exit: count",_readout);
    //    SET_VAR(_readout,GVAR(exitReason),"count");
    //};
};

// 0.0039 ms
private _relAngle = (_readout getRelDir positionCameraToWorld [0,0,0]);
if(_relAngle > 270 || _relAngle < 90) exitWith {
    //if(GET_VAR_D(_readout,GVAR(exitReason),"") != "angle") then {
    //    systemChat format ["%1 drawHitIndicators exit: angle",_readout];
    //    LOG_1("%1 drawHitIndicators exit: angle",_readout);
    //    SET_VAR(_readout,GVAR(exitReason),"angle");
    //};
};

private _angleAlphaMultiplier = (((90 - abs(_relAngle - 180)) * (1/90)) * 2.0) - 0.5;

_angleAlphaMultiplier = _angleAlphaMultiplier max 0;
_angleAlphaMultiplier = _angleAlphaMultiplier min 1;

if(_distance > 30) then {
    _angleAlphaMultiplier = _angleAlphaMultiplier - ((_distance - 30) * (1/10));
};

private _alphaMultiplier = _angleAlphaMultiplier * 0.7; // final alpha scale
private _alphaMultiplierFirst2 = _angleAlphaMultiplier;

private _fovAdd = (((call KK_fnc_trueZoom) - 0.33) * 0.5);

private _scale = 1.5 * ((1 / _distance) * 2) + _fovAdd;

for "_j" from 0 to (count _thisLaneHits - 1) do {
    private _rgba = [1,1,0,_alphaMultiplier];
    if(_j == (count _thisLaneHits - 1)) then {
        _rgba = [1,0,0,_alphaMultiplierFirst2];
    };
    if(_j == (count _thisLaneHits - 2)) then {
        _rgba = [1,0.3,0,_alphaMultiplierFirst2];
    };
    
    _args = [MISSION_ROOT + QUOTE(IMAGE(hitMarker)), _rgba, ASLtoATL (_readout modelToWorld (_thisLaneHits select _j)), _scale, _scale, 0];
    systemChat str _args;
    drawIcon3D _args;
};
