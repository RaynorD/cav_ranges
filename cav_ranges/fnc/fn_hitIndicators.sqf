/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_hitIndicators

Description:
    Toggles hit indicators for a range

Compatible range types:
    targets

Parameters:
  rangeTag: String - Range tag for given range
  state: Boolean - whether indicators should be turned on or off

Returns:
    Nothing

Locality:
    Client

Examples:
    ["rr",true] call CAV_Ranges_fnc_hitIndicators;

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

params ["_rangeTag","_state"];

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_currentState = GET_RANGE_VAR_D(hitIndicators,false);

_rangeReadouts = GET_RANGE_VAR(rangeReadouts);
if (isNil "_rangeReadouts") exitWith {NIL_ERROR(_rangeReadouts)};

if(!(_currentState isEqualTo _state)) then {
    {
        _x params ["_readout","_readoutPedestal"];
        if (isNil "_readout") exitWith {NIL_ERROR(_readout)};
        
        _readout hideObjectGlobal !_state;
        if (!isNil "_readoutPedestal") then {
            _readoutPedestal hideObjectGlobal !_state;
        };
        
        if (_state) then {
            LOG_1("%1 hitIndicators starting EH",_readout);
            [format ["%1_l%2_%3",QGVAR(hitDrawEH),_rangeTag,_forEachIndex], "onEachFrame", FUNC(drawHitIndicators), [_readout]] call BIS_fnc_addStackedEventHandler;
        } else {
            LOG_1("%1 hitIndicators stopping EH",_readout);
            [format ["%1_l%2_%3",QGVAR(hitDrawEH),_rangeTag,_forEachIndex], "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
        };
    } forEach _rangeReadouts;
    
    SET_RANGE_VAR(hitIndicators,_state);
};
