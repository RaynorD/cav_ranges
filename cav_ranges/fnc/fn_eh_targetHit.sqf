/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_eh_targetHit

Description:
    Fired when a target is hit.

Parameters:
  HitPart Arguments:
    target: Object - Object that got injured/damaged.
    shooter: Object - Unit or vehicle that inflicted the damage. If injured by a vehicle impact or a fall the target itself is returned, or, in case of explosions, the null object.
      In case of explosives that were planted by someone (e.g. satchel charges), that unit is returned.
    projectile: Object - Object that was fired.
    position: Position3D - Position the bullet impacted (ASL).
    velocity: Vector3D - 3D speed at which bullet impacted.
    selection: Array - Array of Strings with named selection of the object that were hit.
    ammo: Array - Ammo info: [hit value, indirect hit value, indirect hit range, explosive damage, ammo class name] OR, if there is no shot object: [impulse value on object collided with,0,0,0]
    vector: Vector3D - vector that is orthogonal (perpendicular) to the surface struck. For example, if a wall was hit, vector would be pointing out of the wall at a 90 degree angle.
    radius: Number - Radius (size) of component hit.
    surface: String - Surface type struck.
    direct: Boolean - true if object was directly hit, false if it was hit by indirect/splash damage.

Returns:
    Nothing

Locality:
    Client

Examples:
    _target addEventHandler ["HitPart", {(_this select 0) spawn FUNC(eh_targetHit)}];
    Note: hitPart returns an array of parts hit, so select 0 is needed.

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_direct", "_readout"];

//systemChat format ["Target hit: %1", _this];

if(!isNil "_readout") then {
    if(_target animationPhase "terc" == 0 && count _selection > 0 && _direct) then {
        //_targetCenter = [-0.004,0.161,-0.023]; default target 2 accurate
        _targetCenter = [-0.001, 0.21, 0.3684]; // custom target center
        
        _iconMarkPos = _target worldToModel _position;
        _iconMarkPos set [1, (_targetCenter select 1) - 0.03];
        //LOG_VAR(_iconMarkPos);
        
        _marks = _readout getVariable [QGVAR(rangeHits), []];
    	_marks pushback _iconMarkPos;
        LOG_VAR(_marks);
    	_readout setVariable [QGVAR(rangeHits), _marks, true];
        
        _modelHitPos = _target worldToModel (ASLtoATL(_position));
        _modelHitPosFlat = [
          (_modelHitPos select 0) - (_targetCenter select 0),
          _targetCenter select 1,
          (_modelHitPos select 2) - (_targetCenter select 2)
        ];
        //LOG_VAR(_modelHitPosFlat);
        
        _distanceOffsetCenter = (_modelHitPosFlat distance _targetCenter) toFixed 5;
        //LOG_VAR(_distanceOffsetCenter);
        
                
    };
};
