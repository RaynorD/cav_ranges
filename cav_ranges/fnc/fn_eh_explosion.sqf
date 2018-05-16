/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_eh_explosion

Description:
	Event handler for explosion event on a popup target
	
	Max damage is really small for some reason, like 0.07.
	0.04 represents about 3 meters from a vanilla hand grenade
	
Parameters:
	Target - Object handler is tied to [Object]
	Damage - Amount of damage received [Scalar]

Locality:
	Server
	
Returns: 
	True - so that target is not actually damaged

Examples:
	_this addEventHandler ["Explosion", {_this spawn cav_ranges_fnc_eh_explosion}];

Author:
	=7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

params [["_target",objNull],["_damage",0]];

_text = format ["%1 - %2", _target, _damage];
systemChat _text;
LOG(_text);

// ignore damage below threshold
// check global, then object namespace, then default
if(_damage < (_target getVariable [QGVAR(expDmgThreshold), missionNamespace getVariable [QGVAR(expDmgThreshold),0.005]])) exitWith {true};

// lower target
_target animate ["terc", 1]; 

// if global or object namespace "nopop" variable is set, wait and raise target
if((_target getVariable ["nopop", !isNil "nopop" && {nopop isEqualTo true}]) isEqualTo true) exitWith {true};

sleep 3;

// raise target
_target animate ["terc", 0];

// reset target damage
_target setDamage 0;

// return that damage has been handled
true