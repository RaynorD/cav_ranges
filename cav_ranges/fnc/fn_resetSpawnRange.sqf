#include "..\script_macros.hpp"

// Ran on server at client's action remoteExec

DEF_RANGE_PARAMS;

LOG_1("ResetSpawnRange: %1",_rangeTitle);

if(_rangeType != "spawn") exitWith {LOG("This range is not a spawned range, exiting.")};

_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");
if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

