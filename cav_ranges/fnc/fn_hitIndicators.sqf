/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_hitIndicators

Description:
	Toggles hit indicators for a range

Parameters:
  rangeTag: String - Range tag for given range
  state: Boolean - whether indicators should be turned on or off

Returns:
	Nothing

Locality:
	Client

Examples:
    [] spawn CAV_Ranges_fnc_hitIndicators;

Author:
	=7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

params ["_rangeTag","_state"];

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_3("Range control object (%1_%2) was null: %3",_rangeTag,"ctrl",_this)};

_currentState = GET_VAR_D(_objectCtrl,GVAR(hitIndicators),true);

if(!(_currentState isEqualTo _state)) then {
  _readout = GET_ROBJ(_rangeTag,"readout");
  if (isNil "_readout") exitWith {
      NIL_ERROR(_readout);
  };
  _readoutPedestal = GET_ROBJ(_rangeTag,"readoutPedestal");

  SET_VAR_G(_objectCtrl,GVAR(hitIndicators),_state);

  _readout hideObjectGlobal !_state;
  if (!isNil "_readoutPedestal") then {
      _readoutPedestal hideObjectGlobal !_state;
  };
};
