#include "..\script_macros.hpp"

LOG("PreInit");

INFO("==========================================================");
INFO_1("Initializing - Build: %1",QUOTE(PROJECT_VERSION));
GVAR(loadStartTime) = diag_tickTime;

KK_fnc_trueZoom = {
    ([0.5,0.5] distance2D worldToScreen positionCameraToWorld [0,3,4]) * (getResolution select 5) / 2
};