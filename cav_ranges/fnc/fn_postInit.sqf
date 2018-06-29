/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_postInit

Description:
    Run on mission postInit.
    
    Currently just sets the qualification tier data, and outputs how long init took.
    
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

LOG("PostInit");

INFO_1("Overall mission init time: %1 seconds",diag_tickTime - GVAR(loadStartTime));

GVAR(scoreTiers) = [
    ["EX",QUOTE(IMAGE(expert)),"Expert"],
    ["SS",QUOTE(IMAGE(sharpshooter)),"Sharpshooter"],
    ["MM",QUOTE(IMAGE(marksman)),"Marksman"]
];
