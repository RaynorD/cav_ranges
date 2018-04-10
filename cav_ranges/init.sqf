#include ".\script_macros.hpp"

LOG("init.sqf");

GVAR(ranges) = nil;

INFO("==========================================================");
INFO_1("Initializing - Build: %1",QUOTE(PROJECT_VERSION));

[
	"Range 1",				// title text
	"r1",					// scripting prefix
	1,						// lane count
	10,						// targets per lane
	1,						// targets per group
	false,					// has target indicators
	false,					// has lane cameras
	true,					// runs range sequence
	[						// Range sequence
		["Load your magazine",5],
		[[1],5],
		[[4],5],
		[[4],5],
		[[7],5],
		["Reload",5],
		[[5,10],5],
		[[8,2],5],
		[[1,9],5],
		[[7,8],5]
	]
] call FUNC(createRange);

GVAR(loadDone) = true;
