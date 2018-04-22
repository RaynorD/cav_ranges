
#include ".\script_macros.hpp"  

class DOUBLES(PREFIX,COMPONENT) //tag
{
	class COMPONENT //category
	{
		DEF_FUNC(createRange);
		DEF_FUNC(startRange);
		DEF_FUNC(stopRange);
		DEF_FUNC(eh_explosion);
		DEF_FUNC(rangeDialog);
		DEF_FUNC(rangeDialogUpdate);
		DEF_FUNC(watchCurrentShooter);
		DEF_FUNC_POST(postInit);
		DEF_FUNC_PRE(preInit);
	};
};