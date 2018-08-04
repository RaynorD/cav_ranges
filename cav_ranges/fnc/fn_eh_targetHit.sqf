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

Compatible range types:
    targets

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

params ["_target", "_shooter", "_projectile", "_position", "_velocity", "_selection", "_ammo", "_vector", "_radius", "_surfaceType", "_direct", "_readout", ["_round",50]];

//systemChat format ["Target hit: %1", _this];

if(!isNil "_readout") then {
    if(_target animationPhase "terc" == 0 && count _selection > 0 && _direct) then {
        _targetCenter = GET_VAR(_target,GVAR(targetCenter));
        if(isNil "_targetCenter") exitWith {ERROR_1("targetCenter was nil for %1",_target)};
        
        _iconMarkPos = _target worldToModel _position;
        _iconMarkPos set [1, (_targetCenter select 1) - 0.03];
        
        // save location for icons
        _marks = GET_VAR_ARR(_readout,GVAR(rangeHits));
        _marks pushback _iconMarkPos;
        SET_VAR_G(_readout,GVAR(rangeHits),_marks);
        
        _modelHitPos = _target worldToModel (ASLtoATL(_position));
        _modelHitPosFlat = [
          (_modelHitPos select 0) - (_targetCenter select 0),
          _targetCenter select 1,
          (_modelHitPos select 2) - (_targetCenter select 2)
        ];
        
        _distanceOffsetCenter = parseNumber ((_modelHitPosFlat distance _targetCenter) toFixed 5);
        
        private _animStateChars = toArray animationState _shooter;
        private _animShort = toUpper (toString [_animStateChars select 5,_animStateChars select 6,_aniMStateChars select 7]);
        private _playerStance = "";
        switch (_animShort) do {
            case "ERC" : {_playerStance = "Standing"};
            case "KNL" : {_playerStance = "Kneeling"};
            case "PNE" : {_playerStance = "Prone"};
            case "BIP" : {_playerStance = "Prone Supported"};
        };
        
        // save accuracy for averaging
        private _accuracyData = GET_VAR_ARR(_readout,GVAR(accuracyData));
        _errorCm = (_distanceOffsetCenter * 100);
        _accuracyData pushBack _errorCm;
        SET_VAR_G(_readout,GVAR(accuracyData),_accuracyData);
        
        // save distance for averaging
        _distanceData = GET_VAR_ARR(_readout,GVAR(distanceData));
        _distance = ((round ((_shooter distance _target) / _round)) * _round);
        _distanceData pushBack _distance;
        SET_VAR_G(_readout,GVAR(distanceData),_distanceData);
        
        _weapon = getText (configFile >> "CfgWeapons" >> primaryWeapon _shooter >> "displayName");
        _ammoName = getText (configFile >> "CfgMagazines" >> currentMagazine _shooter >> "displayName");
        _optics =  ((primaryWeaponItems _shooter) select 2);
        _bipod =  ((primaryWeaponItems _shooter) select 3);
        
        _weaponText = _weapon;
        _attachments = [];
        _hasAttachment = false;
        if(_optics != "") then {
            _hasAttachment = true;
            _attachments pushBack getText (configFile >> "CfgWeapons" >> _optics >> "displayName");
        };
        
        if(_bipod != "") then {
            _hasAttachment = true;
            _attachments pushBack getText (configFile >> "CfgWeapons" >> _bipod >> "displayName");
        };
        
        if(_hasAttachment) then {
            _weapon = format ["%1 + %2", _weapon, _attachments joinString ", "];
        };
        
        _laneInfo = GET_VAR_ARR(_target,GVAR(hitIndicatorData));
        _laneInfo params [["_laneName","?"],["_targetIndex","?"]];
        _message = format["Rangemaster: Hit! %1, T%2 - Off Center: %3cm (%4, ", _laneName, _targetIndex, _errorCm, name _shooter];
        _message = _message + format ["%1m, ", _distance];
        _message = _message + format ["%1, %2, %3)", _playerStance, _weapon, _ammoName];
        
        systemChat _message;
    };
};
