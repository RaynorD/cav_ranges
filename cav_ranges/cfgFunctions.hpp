
#include ".\script_macros.hpp"  

class DOUBLES(PREFIX,COMPONENT) //tag
{
	class fnc //category
	{
		DEF_FUNC(createRange);
		DEF_FUNC(addTarget);
		DEF_FUNC(hitPart);
		DEF_FUNC_POST(postInit);
	};
};