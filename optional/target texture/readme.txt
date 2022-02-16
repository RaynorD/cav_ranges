I made an alternate target texture which is dark for better contrast against light backgrounds and has precision target marks to support marksman competitions. However it is quite large (almost 400kb), so I made a smaller one if you just want dark targets that will only be at a distance. The texture should fit any of the pop-up targets under Props > Things > Targets.

Large: 1024x1024 - Size: 392 kb
Small: 256x256 - Size: 47 kb

To use one of the included textures, do the following:

1. Move one of the target.paa files into your cav_ranges\data folder.
2. Add the following code to your init.sqf (or any other code that runs on the server post init):

    if(isServer) then {
        {
            _x setObjectTextureGlobal [0, "cav_ranges\data\target.paa"];
        } foreach allMissionObjects "TargetP_Inf_F";
    };

3. Change the classname (TargetP_Inf_F) to whatever target type you're using. You can see this info in the editor by holding your mouse over the target, or right click > Log > Log Classes.
 