#include "..\script_macros.hpp"

LOG_1("CreateRange: %1", str (_this select 0));

DEF_GVAR(rangeData,[]);

GVAR(rangeData) pushBack [_this select 0];
