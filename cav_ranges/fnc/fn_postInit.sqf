#include "..\script_macros.hpp"

LOG("PostInit");

INFO_1("Overall mission init time: %1 seconds",diag_tickTime - GVAR(loadStartTime));

GVAR(scoreTiers) = [
	["EX",QUOTE(IMAGE(expert)),"Expert"],
	["SS",QUOTE(IMAGE(sharpshooter)),"Sharpshooter"],
	["MM",QUOTE(IMAGE(marksman)),"Marksman"]
];
