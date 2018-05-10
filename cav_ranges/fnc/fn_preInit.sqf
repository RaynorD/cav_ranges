/* ----------------------------------------------------------------------------
Function: CAV_Ranges_fnc_postInit

Description:
	Run on mission postInit.
	
	Currently just sets a time to use to later calculate mission init time.
	
	KK_fnc_trueZoom not used in this version.
	
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

LOG("PreInit");

INFO("==========================================================");
INFO_1("Initializing - Build: %1",QUOTE(PROJECT_VERSION));
GVAR(loadStartTime) = diag_tickTime;

KK_fnc_trueZoom = {
    ([0.5,0.5] distance2D worldToScreen positionCameraToWorld [0,3,4]) * (getResolution select 5) / 2
};