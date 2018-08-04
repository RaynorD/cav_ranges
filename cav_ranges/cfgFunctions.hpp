
#include ".\script_macros.hpp"

class DOUBLES(PREFIX,COMPONENT) //tag
{
    class COMPONENT //category
    {
        DEF_FUNC(addInstructorActions);
        DEF_FUNC(cancelRange);
        DEF_FUNC(createRange);
        DEF_FUNC(drawHitIndicators);
        DEF_FUNC(eh_explosion);
        DEF_FUNC(eh_targetHit);
        DEF_FUNC(initializeTargets);
        DEF_FUNC(hitIndicators);
        DEF_FUNC(playRangeSound);
        DEF_FUNC(updateQuals);
        DEF_FUNC(rangeDialog);
        DEF_FUNC(resetRangeData);
        DEF_FUNC(startRange);
        DEF_FUNC(stopRange);
        DEF_FUNC(updateUI);
        DEF_FUNC(watchCurrentShooter);

        DEF_FUNC_POST(postInit);
        DEF_FUNC_PRE(preInit);
    };
};
