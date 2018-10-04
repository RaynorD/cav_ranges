/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_postInit

Description:
    Run on mission postInit.

Compatible range types:
    All

Parameters:
    None

Locality:
    Server
    
Returns:
    Nothing

Examples:
    Called via config only
    

Author:
    =7Cav=WO1.Raynor.D

---------------------------------------------------------------------------- */

#include "..\script_macros.hpp"

LOG("PostInit");

INFO_1("Overall mission init time: %1 seconds",diag_tickTime - GVAR(loadStartTime));

GVAR(scoreTiers) = [
    ["EX",QUOTE(IMAGE(expert)),"Expert"],
    ["SS",QUOTE(IMAGE(sharpshooter)),"Sharpshooter"],
    ["MM",QUOTE(IMAGE(marksman)),"Marksman"]
];

KK_fnc_trueZoom = {
    ([0.5,0.5] distance2D worldToScreen positionCameraToWorld [0,3,4]) * (getResolution select 5) / 2
};
