#include "..\script_macros.hpp"

// Running on server only

RANGE_PARAMS;

LOG_1("StopRange: %1", str _this);

//_objectCtrl = missionNamespace getVariable [format ["%1_ctrl",_rangeTag],objNull];
_objectCtrl = GET_ROBJ(_rangeTag,"ctrl");

if(isNull _objectCtrl) exitWith {ERROR_2("Range control object (%1) is null: %2", format ["%1_ctrl",_rangeTag], _this)};

//terminate (_objectCtrl getVariable [QGVAR(sequenceHandle), nil]);
terminate (GET_VAR(_objectCtrl,GVAR(sequenceHandle)));

//systemChat format ["%1 stopped %2", name (_objectCtrl getVariable [QGVAR(rangeActivator),nil]), _rangeTitle];
systemChat format ["%1 stopped %2", name (GET_VAR(_objectCtrl,GVAR(rangeActivator))), _rangeTitle];

//_objectCtrl setVariable [QGVAR(rangeInteractable), true, true];
SET_VAR_G(_objectCtrl,GVAR(rangeInteractable),true);


