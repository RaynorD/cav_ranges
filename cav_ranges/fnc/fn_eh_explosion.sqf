
#include "..\script_macros.hpp"

params [["_target",objNull],["_damage",0]];

systemChat str _this; 

if(_damage < (_target getVariable [QGVAR(expDmgThreshold), missionNamespace getVariable [QGVAR(expDmgThreshold),0.04]])) exitWith {true};

_target animate ["terc", 1]; 

if((_target getVariable ["nopop", !isNil "nopop" && {nopop isEqualTo true}]) isEqualTo true) exitWith {true};

sleep 3; 

_target animate ["terc", 0];

_target setDamage 0;

true