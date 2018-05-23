// rifle range "rr" - TargetP_Inf_Acc2_F
// grenade range "gr" - TargetP_Inf_F 
// killhouse "kh" - TargetP_Inf_Acc2_NoPop_F (kh_target_1)


// grenade launcher range setup
//{
//	_x addEventHandler ["Explosion", {_this spawn cav_ranges_fnc_eh_explosion}];
//	_x addEventHandler ["HandleDamage", {0}];
//	_x setVariable ["cav_ranges_expDmgThreshold",0.001];
//} foreach allMissionObjects "TargetP_Inf3_F";
//
//// grenade range
//{
//	_x addEventHandler ["Explosion", {_this spawn cav_ranges_fnc_eh_explosion}];
//	_x addEventHandler ["HandleDamage", {0}];
//	_x setVariable ["cav_ranges_expDmgThreshold",0.04];
//} foreach allMissionObjects "TargetP_Inf2_F";

[
	"targets", 		//range type
					//	"targets" : pop up targets, terc animation is used
					//	"spawn"   : spawned units, targets being alive/dead is used
	"Rifle Range",	// title text
	"rr",			// range tag
	6,				// lane count
	8,				// targets per lane
	[				
		// Range sequence
			// First element defines the type of event:
			//		ARRAY: target(s)/group(s) to raise. Multiple elements for multiple targets/groups
			//		STRING: Message to show on the lane UI. Third element is not used in this case
			// Second element: seconds length/delay for that event
			// Third element (optional): delay between end of this event and start of the next, default 2 if not present
		["Load your magazine",5],
		["Assume a prone position and standby",3],
		["Range is hot!",1],
		[[1],5],
		[[2],5],
		[[6],5],
		[[3],5],
		[[8],5],
		[[4],5],
		[[7],5],
		[[2],5],
		[[1],5],
		[[5],5],
		[[2,4],8],
		[[1,5],8],
		[[7,3],8],
		[[3,6],8],
		[[2,5],8],
		["Reload your weapon",5],
		["Assume a prone position and standby",3],
		["Range is hot!",1],
		[[5],5],
		[[2],5],
		[[7],5],
		[[1],5],
		[[8],5],
		[[3],5],
		[[4],5],
		[[6],5],
		[[3],5],
		[[2],5],
		["Assume a kneeling position and standby",3],
		["Range is hot!",1],
		[[1],5],
		[[3],5],
		[[4],5],
		[[2],5],
		[[3],5],
		[[2],5],
		[[4],5],
		[[1],5],
		[[3],5],
		[[2],5],
		["Safe your weapon.",3],
		["Range complete.",0]
	],
	
	nil,	// target grouping, nil to disable grouping, otherwise group as define nested arrays: [[0,1],[2,3]] etc
				//   a particular target can be in multiple groups
	[38,30,23]	// qualification tiers, [expert, sharpshooter, marksman], nil to disable qualifications altogether
				//   values below the last element will show no go
				//   Not all three are required, [35] would simply return expert above 35, and no go below that
] spawn cav_ranges_fnc_createRange;

