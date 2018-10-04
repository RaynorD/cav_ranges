/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_initializeData

Description:
    Parses and initializes range data from user config

Compatible range types:
    All

Parameters:
    None

Locality:
    Server
    
Returns:
    Nothing

Examples:
    Called at postinit via config.

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

GVAR(mainConfig) = missionConfigFile >> "cav_ranges";
GVAR(rangesConfig) = GVAR(mainConfig) >> "ranges";
GVAR(rangeSetsActive) = []; // [["set1tag", active (bool)],["set2tag", active (bool)]]

_cfgsRanges = "true" configClasses GVAR(rangesConfig);

{
    _cfg = _x;
    _cfgName = configName _cfg;
    
    //pull from config into local variables
    _title = [_cfg, "title"] call BIS_fnc_returnConfigEntry;
    _type = [_cfg, "type"] call BIS_fnc_returnConfigEntry; //required
    _activation = [_cfg, "activation", "none"] call BIS_fnc_returnConfigEntry;
    _tag = [_cfg, "tag"] call BIS_fnc_returnConfigEntry; //required
    _targetCount = [_cfg, "targetCount"] call BIS_fnc_returnConfigEntry; //required
    _laneCount = [_cfg, "laneCount", 1] call BIS_fnc_returnConfigEntry;
    _qualTiers = [_cfg, "qualTiers", []] call BIS_fnc_returnConfigEntry;
    _instructorActions = [_cfg, "instructorActions", true] call BIS_fnc_returnConfigEntry;
    _controlObjectActions = [_cfg, "controlObjectActions", true] call BIS_fnc_returnConfigEntry;
    _civTargetCount = [_cfg, "civTargetCount", 1] call BIS_fnc_returnConfigEntry;
    _civTargetsAlwaysUp = [_cfg, "civTargetsAlwaysUp", true] call BIS_fnc_returnConfigEntry;
    _sequence = [_cfg, "sequence", []] call BIS_fnc_returnConfigEntry;
    
    // data verification
    _error = false;
    ASSERT_TYPE_WITH_TITLE(_title,STRING,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_type,STRING,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_activation,STRING,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_tag,STRING,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_targetCount,SCALAR,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_laneCount,SCALAR,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_qualTiers,ARRAY,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_instructorActions,SCALAR,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_controlObjectActions,SCALAR,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_civTargetCount,SCALAR,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_civTargetsAlwaysUp,SCALAR,_cfgName,_error);
    ASSERT_TYPE_WITH_TITLE(_sequence,ARRAY,_cfgName,_error);
    if(_error) exitWith {ERROR("There were config errors - aborting initialization.")};
    
    TO_BOOL(_instructorActions);
    TO_BOOL(_controlObjectActions);
    TO_BOOL(_civTargetsAlwaysUp);
    
    systemChat format ["range created: %1",_title]
} forEach _cfgsRanges;
