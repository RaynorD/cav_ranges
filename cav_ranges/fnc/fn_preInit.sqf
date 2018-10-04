/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_postInit

Description:
    Run on mission preInit.

Compatible range types:
    All

Parameters:
    None

Locality:
    Server
    
Returns:
    Nothing

Examples:
    Called via config
    

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

INFO_1("Initializing - Build: %1",QUOTE(PROJECT_VERSION));
GVAR(loadStartTime) = diag_tickTime;

KK_fnc_trueZoom = {
    ([0.5,0.5] distance2D worldToScreen positionCameraToWorld [0,3,4]) * (getResolution select 5) / 2
};
